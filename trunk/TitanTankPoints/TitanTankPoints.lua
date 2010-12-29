-- **************************************************************************
-- * TitanTankPoints.lua
-- * Shows players TankPoints on the TitanBar.
-- **************************************************************************

-- ******************************** Constants *******************************
-- Setup the name we want in the global namespace
TitanTankPoints = {}
-- Reduce the chance of functions and variables colliding with another addon.
local TS = TitanTankPoints

TS.id = "TankPoints";
TS.addon = "TitanTankPoints";
-- NOTE : The Titan convention is to name your addon toc (and folder) "Titan"<your addon>.
--        In this case TitanTankPoints.


-- These strings will be used for display. Localized strings are outside the scope of this example.
TS.button_label = TS.id..": "
TS.menu_text = TS.id
TS.tooltip_header = TS.id.." Info"
TS.tooltip_hint_1 = "Hint: Left-click to show the TankPoints calculator"
TS.menu_option = "Options"
TS.menu_hide = "Hide"
TS.menu_show_tankPoints = "Show Tank Points"
TS.menu_show_effectiveHealth = "Show Effective Health"

--  Get data from the TOC file.
TS.version = tostring(GetAddOnMetadata(TS.addon, "Version")) or "Unknown" 
TS.author = GetAddOnMetadata(TS.addon, "Author") or "Unknown"
-- ******************************** Variables *******************************
-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelBagButton_OnLoad()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TS.Button_OnLoad(self)
-- SDK : "registry" is the data structure Titan uses to addon info it is displaying.
--       This is the critical structure!
-- SDK : This works because the button inherits from a Titan template. In this case
--       TitanPanelComboTemplate in the XML.
-- NOTE: LDB (LibDataBroker) type addons are NOT in the scope of this example.
	self.registry = {
		id = TS.id,
		-- SDK : "id" MUST be unique to all the Titan specific addons
		-- Last addon loaded with same name wins...
		version = TS.version,
		-- SDK : "version" the version of your addon that Titan displays
		category = "Information",
		-- SDK : "category" is where the user will find your addon when right clicking
		--       on the Titan bar.
		--       Currently: General, Combat, Information, Interfacem, Profession - These may change!
		menuText = TS.menu_text,
		-- SDK : "menuText" is the text Titan displays when the user finds your addon by right clicking
		--       on the Titan bar.
		buttonTextFunction = "TitanTankPoints_GetButtonText", 
		-- SDK : "buttonTextFunction" is in the global name space due to the way Titan uses the routine.
		--       This routine is called to set (or update) the button text on the Titan bar.
		tooltipTitle = TS.tooltip_header,
		-- SDK : "tooltipTitle" will be used as the first line in the tooltip.
		tooltipTextFunction = "TitanTankPoints_GetTooltipText", 
		-- SDK : "tooltipTextFunction" is in the global name space due to the way Titan uses the routine.
		--       This routine is called to fill in the tooltip of the button on the Titan bar.
		--       It is a typical tooltip and is drawn when the cursor is over the button.
		icon = "Interface\\AddOns\\TitanTankPoints\\TitanTankPoints",
		-- SDK : "icon" needs the path to the icon to display. Blizzard uses the default extension of .tga
		--       If not needed make nil.
		iconWidth = 16,
		-- SDK : "iconWidth" leave at 16 unless you need a smaller/larger icon
		savedVariables = {
		-- SDK : "savedVariables" are variables saved by character across logins.
		--      Get - TitanGetVar (id, name)
		--      Set - TitanSetVar (id, name, value)
			-- SDK : The variable below is our only configurable thing
			ShowValueNum = 1, --1=TankPoints, 2=EffectiveHealth, 3=Guaranteed Reduction (%), 4=Reduction (%)
			-- SDK : Titan will handle the 3 variables below but the addon code must put it on the menu
			ShowIcon = 1,
			ShowLabelText = 1,
			ShowColoredText = 1,               
		}
	};     

	-- Tell Blizzard the events we need
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	-- Any other addon specific "on load" code here
	
	-- shamelessly print a load message to chat window
	DEFAULT_CHAT_FRAME:AddMessage(
		GREEN_FONT_COLOR_CODE
		..TS.addon..TS.id.." "..TS.version
		.." by "
		..FONT_COLOR_CODE_CLOSE
		.."|cFFFFFF00"..TS.author..FONT_COLOR_CODE_CLOSE);
end

-- **************************************************************************
-- NAME : TS.Button_OnEvent()
-- DESC : Parse events registered to plugin and act on them
-- USE  : _OnEvent handler from the XML file
-- **************************************************************************
function TS.Button_OnEvent(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		-- do any set up needed          
		self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
		self:RegisterEvent("UNIT_AURA");
		self:RegisterEvent("PLAYER_LEVEL_UP");
	else
		--[[
		http://code.google.com/p/titanpanel/wiki/Developer_Changes_For_4_0_0_30000
		
		TitanPanelPluginHandle_OnUpdate({id, updateType})
			id -- id string of the plugin
			updateType 
				TITAN_PANEL_UPDATE_BUTTON for text updates on the button or
				TITAN_PANEL_UPDATE_TOOLTIP for tooltip updates or
				TITAN_PANEL_UPDATE_ALL for both text and tooltip updates
		Example:
			local MY_ADDON_ID = "MyAddon"
			TitanPanelPluginHandle_OnUpdate({MY_ADDON_ID, TITAN_PANEL_UPDATE_BUTTON})
		
		--]]
		TitanPanelPluginHandle_OnUpdate({TS.id, TITAN_PANEL_UPDATE_ALL})
	end
end


-- **************************************************************************
-- NAME : TS.Button_OnClick(button)
-- DESC : Opens all bags on a LeftClick
-- VARS : button = value of action
-- USE  : _OnClick handler from the XML file
-- **************************************************************************
function TS.Button_OnClick(self, button)
	if (button == "LeftButton") then
		TS.ShowCalculator();
	end
end

-- **************************************************************************
-- NAME : TitanTankPoints_GetButtonText(id)
-- DESC : Calculate bag space logic then display data on button
-- VARS : id = button ID
-- **************************************************************************
function TitanTankPoints_GetButtonText(id)
-- SDK : As specified in "registry"
--       Any button text to set or update goes here
	local button, id = TitanUtils_GetButton(id, true);
	-- SDK : "TitanUtils_GetButton" is used to get a reference to the button Titan created.
	--       The reference is not needed by this example.

	return TS.button_label, TS.GetTankPointsButtonCaption();
end

-- **************************************************************************
-- NAME : TitanTankPoints_GetTooltipText()
-- DESC : Display tooltip text
-- **************************************************************************
function TitanTankPoints_GetTooltipText()
-- SDK : As specified in "registry"
--       Create the tooltip text here

	local tankPoints, effectiveHealth, totalReduction, guaranteedReduction;
	tankPoints, effectiveHealth, totalReduction, guaranteedReduction = TS.GetTankPointsValues();

	local result = 
			"TankPoints:\t"..              TitanUtils_GetHighlightText(format("%d",   tankPoints)).."\n"..
			"Effective Health:\t"..        TitanUtils_GetHighlightText(format("%d",   effectiveHealth)).."\n"..
			"Total Reduction (%):\t"..     TitanUtils_GetHighlightText(format("%.2f%%", totalReduction)).."\n"..
			"Guaranteed Reduction (%):\t"..TitanUtils_GetHighlightText(format("%.2f%%", guaranteedReduction));

	result = 
			result.."\n"..
			TitanUtils_GetGreenText(TS.tooltip_hint_1);
			
	return result;
end

-- **************************************************************************
-- NAME : TitanPanelRightClickMenu_Prepare[AddonId]Menu()
-- DESC : Display rightclick menu options
-- **************************************************************************
function TitanPanelRightClickMenu_PrepareTankPointsMenu()
-- SDK : This is a routine that Titan 'assumes' will exist. The name is a specific format
--       "TitanPanelRightClickMenu_Prepare"..ID.."Menu"
--       where ID is the "id" from "registry"
	local info

-- menu creation is beyond the scope of this example
-- but note the Titan get / set routines and other Titan routines being used.
-- SDK : "TitanPanelRightClickMenu_AddTitle" is used to place the title in the (sub)menu

	-- level 2 menu
	if UIDROPDOWNMENU_MENU_LEVEL == 2 then
		if UIDROPDOWNMENU_MENU_VALUE == "Options" then
			TitanPanelRightClickMenu_AddTitle(TS.menu_option, UIDROPDOWNMENU_MENU_LEVEL)
			info = {};
			info.text = TS.menu_show_tankPoints;
			info.func = TitanPanelTankPointsButton_ShowTankPoints;
			info.checked = (TitanGetVar(TS.id, "ShowValueNum") == 1);
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

			info = {};
			info.text = TS.menu_show_effectiveHealth;
			info.func = TitanPanelTankPointsButton_ShowEffectiveHealth;
			info.checked = (TitanGetVar(TS.id, "ShowValueNum") == 2);
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
		end
		return -- so the menu does not create extra repeat buttons
	end
	
	-- level 1 menu
--	if "UIDROPDOWNMENU_MENU_LEVEL" == 1 then
		TitanPanelRightClickMenu_AddTitle(TitanPlugins[TS.id].menuText);
		 
		info = {};
		info.text = TS.menu_option
		info.value = "Options"
		info.hasArrow = 1;
		UIDropDownMenu_AddButton(info);

		TitanPanelRightClickMenu_AddSpacer();     
		-- SDK : "TitanPanelRightClickMenu_AddSpacer" is used to put a blank line in the menu
		TitanPanelRightClickMenu_AddToggleIcon(TS.id);
		-- SDK : "TitanPanelRightClickMenu_AddToggleIcon" is used to put a "Show icon" (localized) in the menu.
		--        registry.savedVariables.ShowIcon
		TitanPanelRightClickMenu_AddToggleLabelText(TS.id);
		-- SDK : "TitanPanelRightClickMenu_AddToggleLabelText" is used to put a "Show label text" (localized) in the menu.
		--        registry.savedVariables.ShowLabelText
		TitanPanelRightClickMenu_AddToggleColoredText(TS.id);
		-- SDK : "TitanPanelRightClickMenu_AddToggleLabelText" is used to put a "Show colored text" (localized) in the menu.
		--        registry.savedVariables.ShowColoredText
		TitanPanelRightClickMenu_AddSpacer();     
		TitanPanelRightClickMenu_AddCommand(TS.menu_hide, TS.id, TITAN_PANEL_MENU_FUNC_HIDE);
		-- SDK : The routine above is used to put a "Hide" (localized) in the menu.
--	end

end

-- **************************************************************************
-- NAME : TitanPanelBagButton_ShowUsedSlots()
-- DESC : Set option to show used slots
-- **************************************************************************
function TitanPanelTankPointsButton_ShowTankPoints()
	TitanSetVar(TS.id, "ShowValueNum", 1);
	TitanPanelButton_UpdateButton(TS.id);
end

-- **************************************************************************
-- NAME : TitanPanelBagButton_ShowAvailableSlots()
-- DESC : Set option to show available slots
-- **************************************************************************
function TitanPanelTankPointsButton_ShowEffectiveHealth()
	TitanSetVar(TS.id, "ShowValueNum", 2);
	TitanPanelButton_UpdateButton(TS.id);
end

-- **************************************************************************
-- NAME : TitanTankPoints_GetButtonText(id)
-- DESC : Calculate bag space using what the user wants to see
-- VARS : 
-- **************************************************************************
function TS.GetTankPointsButtonCaption()
-- SDK : As specified in "registry"
--       Any button text to set or update goes here

	local text, richText
	
	local tankPoints, effectiveHealth, totalReduction, guaranteedReduction;
	tankPoints, effectiveHealth, totalReduction, guaranteedReduction = TS.GetTankPointsValues();
	
	local showValueNum = TitanGetVar(TS.id, "ShowValueNum");
	if (showValueNum == nil) then
		showValueNum = 1; --default to showing TankPoints if something went haywire
	end
		
	if (showValueNum == 2) then --Effective Health
		text = "EH: "..TitanUtils_GetHighlightText(format("%d", effectiveHealth));
	else --TankPoints, and everything else
		text = "TP: "..TitanUtils_GetHighlightText(format("%d", tankPoints));
	end
     
	if ( TitanGetVar(TS.id, "ShowColoredText") ) then     
		richText = TitanUtils_GetColoredText(text, NORMAL_FONT_COLOR);
	else
		richText = TitanUtils_GetHighlightText(text);
	end

	return richText
end

function TS.ShowCalculator()

	local TP = TankPoints; --get ahold of the global TankPoints addon
	
	if (TP) then
		TP:ToggleCalculator();
	end;
	
end;

function TS.GetTankPointsValues()
	--[[Return four numbers:
			TankPoints
			EffectiveHealth
			Total Reduction
			Guaranteed Reduction
			
		e.g.
			432148
			218226
			76.289323898619
			53.332898649843
	]]--
		
	local tankPoints, effectiveHealth, totalReduction, guaranteedReduction
	
	tankPoints = 0;
	effectiveHealth = 0;
	totalReduction = 0;
	guaranteedReduction = 0;
	
	local TP = TankPoints; --get ahold of the global TankPoints addon
	
	--write our own tonumber function; the built-in one doesn't behave as expected
	local function ToNumberEx(v)
		local result = tonumber(v);

		if (result == nil) then
			result = 0;
		end;
		
		return result;
	end

	if (TP) and (TP.resultsTable) then
		local results = TankPoints.resultsTable;
		
		tankPoints = ToNumberEx(results.tankPoints[TP_MELEE]);
		effectiveHealth = ToNumberEx(results.effectiveHealth[TP_MELEE]);
		totalReduction = ToNumberEx(results.totalReduction[TP_MELEE])*100;
		guaranteedReduction = ToNumberEx(results.guaranteedReduction[TP_MELEE])*100;
	end;
	
	return tankPoints, effectiveHealth, totalReduction, guaranteedReduction;
end;
