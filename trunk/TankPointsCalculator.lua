-- -*- indent-tabs-mode: t; tab-width: 4; lua-indent-level: 4 -*-
--[[
Name: TankPoints Calculator
Description: Interactive Calculator for TankPoints
Revision: $Revision: 2 $
Developed by: Whitetooth@Cenarius (hotdogee@¤Ú«¢©i¯Sbaha)
]]

---------------
-- Libraries --
---------------
local StatLogic = AceLibrary("StatLogic-1.0")
local L = AceLibrary("AceLocale-2.2"):new("TankPoints")


--------------------
-- Initialization --
--------------------
TPCalc = {}
TPCalc.sourceDT = {}
TPCalc.resultsDT = {}
local TPCalc = TPCalc


---------------------
-- Local Variables --
---------------------
-- Localize Lua globals
local _G = getfenv(0)
local pairs = pairs
local ipairs = ipairs
local setmetatable = setmetatable
local getmetatable = getmetatable
local tinsert = tinsert
local tostring = tostring
local select = select


-------------------
-- General Tools --
-------------------
-- copyTable
local function copyTable(to, from)
	if to then
		for k in pairs(to) do
			to[k] = nil
		end
		setmetatable(to, nil)
	else
		to = {}
	end
	for k,v in pairs(from) do
		if type(k) == "table" then
			k = copyTable({}, k)
		end
		if type(v) == "table" then
			v = copyTable({}, v)
		end
		to[k] = v
	end
	setmetatable(to, getmetatable(from))
	return to
end

-------------------------------
-- TankPointsCalculatorFrame --
-------------------------------
function TankPointsCalculatorFrame_OnLoad()
	-- Esc closes the window
	tinsert(UISpecialFrames, this:GetName())
	
	-- Set title text
	TankPointsCalculatorFrame_HeaderText:SetText(L["TankPoints Calculator"])
	-- Set drag frame tooltip
	TankPointsCalculatorFrame_DragFrame.tooltip = L["Left click to drag\nRight click to reset position"]
	-- Set button text
	TankPointsCalculatorFrame_ResetButton:SetText(L["Reset"])
	TankPointsCalculatorFrame_CloseButton:SetText(L["Close"])
	-- Set option frame box title
	TPCResultsFrameTitle:SetText(L["Results"])
	TPCCombatTableFrameTitle:SetText(L["Combat Table"])
	TPCPlayerStatsFrameTitle:SetText(L["Player Stats"])
	TPCMobStatsFrameTitle:SetText(L["Mob Stats"])
	-- Set label text
	TPCalc:SetLabels()
	TPCalc:AdjustResultFrameSize()
	
	-- Set tooltips
	TPCMobStats2.tooltip = L["Mob Damage before DR"]
	
	-- Register events
	this:RegisterEvent("UNIT_LEVEL")
	this:RegisterEvent("UNIT_RESISTANCES")
	this:RegisterEvent("UNIT_STATS")
	this:RegisterEvent("UNIT_DEFENSE")
	this:RegisterEvent("UNIT_MAXHEALTH")
	this:RegisterEvent("UNIT_AURA")
	this:RegisterEvent("UNIT_INVENTORY_CHANGED")
end

function TankPointsCalculatorFrame_OnEvent(self, event, ...)
	--TankPoints:Print(tostring(self)..", "..event..", "..select(1, ...))
	-- Do nothing if Calculator frame is not visable
	if (not self:IsVisible()) then
		return
	end
	-- Do nothing if event target is not player
	if (not select(1, ...) == "player") then
		return
	end
	-- Update stuff
        TPCalc:UpdateResults()
end

function TankPointsCalculatorFrame_OnShow()
        TPCalc:UpdateResults()
end

-- VariableFrame
function TankPointsCalculatorVariables_IncrementButton_OnClick(self, button, down)
	--TankPoints:Print(tostring(self)..", "..tostring(button)..", "..tostring(this)..", "..tostring(down))
	local inputBox = _G[self:GetParent():GetName().."_InputEditBox"]
	inputBox:SetNumber(inputBox:GetNumber() + 1)
	inputBox:ClearFocus()
end

function TankPointsCalculatorVariables_DecrementButton_OnClick(self, button, down)
	local inputBox = _G[self:GetParent():GetName().."_InputEditBox"]
	inputBox:SetNumber(inputBox:GetNumber() - 1)
	inputBox:ClearFocus()
end

function TankPointsCalculatorVariables_InputEditBox_OnTextChanged()
	--TankPoints:Print(tostring(self)..", "..tostring(this))
	local self = this
	if (self:GetNumber() > 0) then
		self:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (self:GetNumber() < 0) then
		self:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		self:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	TPCalc:UpdateResults()
end

TPCalc.LabelText = {
	{-- TPCResults1 (also see TPCalc:SetLabels())
		L["TankPoints"],
		L["Effective Health"],
		L["Total Reduction"]..L["(%)"],
		L["Guaranteed Reduction"]..L["(%)"],
	},
	{-- TPCCombatTable1
		MISS..L["(%)"],
		DODGE..L["(%)"],
		PARRY..L["(%)"],
		BLOCK..L["(%)"],
		L["Crit"]..L["(%)"],
		L["Crushing"]..L["(%)"],
		L["Hit"]..L["(%)"],
	},
	{-- TPCPlayerStats1
		SPELL_STAT1_NAME, -- "Strength"
		SPELL_STAT2_NAME, -- "Agility"
		SPELL_STAT3_NAME, -- "Stamina"
		L["Max Health"],
		"["..ARMOR.." - "..L["Items"].."]",
		"["..ARMOR.."]",
		"["..COMBAT_RATING_NAME2.."]", -- "Defense Rating"
		"["..DEFENSE.."]",
		"["..COMBAT_RATING_NAME3.."]", -- "Dodge Rating"
		"["..DODGE..L["(%)"].."]",
		"["..COMBAT_RATING_NAME4.."]", -- "Parry Rating"
		"["..PARRY..L["(%)"].."]",
		"["..COMBAT_RATING_NAME5.."]", -- "Block Rating"
		"["..BLOCK..L["(%)"].."]",
		L["Block Value"],
		COMBAT_RATING_NAME15, -- "Resilience"
	},
	{-- TPCMobStats1
		L["Mob Level"],
		L["Mob Damage"],
		L["Mob Attack Speed"],
	},
}
-- Set label text
function TPCalc:SetLabels()
	if self:ShouldShowEHB() then
		if self.LabelText[1][3] ~= L["Effective Health with Block"] then
			table.insert(self.LabelText[1], 3, L["Effective Health with Block"])
		end
	end
	for i, text in ipairs(self.LabelText[1]) do
		_G["TPCResults"..i.."_LabelText"]:SetText(text)
	end
	for i, text in ipairs(self.LabelText[2]) do
		_G["TPCCombatTable"..i.."_LabelText"]:SetText(text)
	end
	for i, text in ipairs(self.LabelText[3]) do
		_G["TPCPlayerStats"..i.."_LabelText"]:SetText(text)
	end
	for i, text in ipairs(self.LabelText[4]) do
		_G["TPCMobStats"..i.."_LabelText"]:SetText(text)
	end
end

function TPCalc:AdjustResultFrameSize()
	if self:ShouldShowEHB() then
		 -- see TankPointsCalculator.xml for the origin of these constants!
		TPCResultsFrame:SetHeight(98 + 22)
		TankPointsCalculatorFrame:SetHeight(715 + 22)
		TPCResults5:Show()
	end
end

-- yes, there is a playerClass var in TankPoints, but this ShouldShow is called
-- at load time - before TankPoints.playerClass is initialized. Speed isn't too
-- big of a deal here.
function TPCalc:ShouldShowEHB()
	local _, class = UnitClass("player")
	if "WARRIOR" == class then
		return true
	end
end

function TankPointsCalculatorFrame_ResetButton_OnClick(self, button, down)
	for i, _ in ipairs(TPCalc.LabelText[3]) do
		local inputBox = _G["TPCPlayerStats"..i.."_InputEditBox"]
		inputBox:SetText("0")
		inputBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	for i, _ in ipairs(TPCalc.LabelText[4]) do
		local inputBox = _G["TPCMobStats"..i.."_InputEditBox"]
		inputBox:SetText("0")
		inputBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
end

local round = function(n,decimal_places)
	decimal_places = decimal_places or 0
	return floor((n + 0.5) * (10^decimal_places))/(10^decimal_places)
end

function TPCalc:UpdateResults()
	-- Update base data
	TankPoints:GetSourceData(self.sourceDT)
	copyTable(self.resultsDT, self.sourceDT)
	TankPoints:GetTankPoints(self.resultsDT)
	local newDT = {}
	copyTable(newDT, self.sourceDT)
	local prefix
	--------------------
	-- Get input data --
	--------------------
	-- input data is writen in the changes table
	local changes = {}
	local inputEditBox = "_InputEditBox"
	local currentText = "_CurrentText"
	local resultText = "_ResultText"
	local differenceText = "_DifferenceText"
	local originalStatText = "_OriginalStatText"
	local newStatText = "_NewStatText"
	
	local current, new, diff
	
	prefix = "TPCPlayerStats"
	local i = 1
	-- Strength
	changes.str = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- Agility
	changes.agi = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- Stamina
	changes.sta = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- Max Health
	changes.playerHealth = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- Armor (Items)
	changes.armorFromItems = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- Armor
	changes.armor = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- Defense Rating
	changes.defense = 0
	diff = _G[prefix..i..inputEditBox]:GetNumber()
	if diff then
		-- Ratings are floored in game
		current = GetCombatRating(CR_DEFENSE_SKILL)
		changes.defense = floor(StatLogic:GetEffectFromRating(current + diff, CR_DEFENSE_SKILL, newDT.playerLevel)) - floor(StatLogic:GetEffectFromRating(current, CR_DEFENSE_SKILL, newDT.playerLevel))
	end
	i = i + 1
	-- Defense
	changes.defense = changes.defense + _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- Dodge Rating
	changes.dodgeChance = 0
	diff = _G[prefix..i..inputEditBox]:GetNumber()
	if diff then
		changes.dodgeChance = StatLogic:GetEffectFromRating(diff, CR_DODGE, newDT.playerLevel) * 0.01
	end
	i = i + 1
	-- Dodge
	changes.dodgeChance = changes.dodgeChance + _G[prefix..i..inputEditBox]:GetNumber() * 0.01
	i = i + 1
	-- Parry Rating
	changes.parryChance = 0
	diff = _G[prefix..i..inputEditBox]:GetNumber()
	if diff then
		changes.parryChance = StatLogic:GetEffectFromRating(diff, CR_PARRY, newDT.playerLevel) * 0.01
	end
	i = i + 1
	-- Parry
	changes.parryChance = changes.parryChance + _G[prefix..i..inputEditBox]:GetNumber() * 0.01
	i = i + 1
	-- Block Rating
	changes.blockChance = 0
	diff = _G[prefix..i..inputEditBox]:GetNumber()
	if diff then
		changes.blockChance = StatLogic:GetEffectFromRating(diff, CR_BLOCK, newDT.playerLevel) * 0.01
	end
	i = i + 1
	-- Block
	changes.blockChance = changes.blockChance + _G[prefix..i..inputEditBox]:GetNumber() * 0.01
	i = i + 1
	-- Block Value
	changes.blockValue = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- Resilience
	changes.resilience = _G[prefix..i..inputEditBox]:GetNumber()
	
	prefix = "TPCMobStats"
	i = 1
	-- mobLevel
	changes.mobLevel = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- mobDamage
	changes.mobDamage = _G[prefix..i..inputEditBox]:GetNumber()
	i = i + 1
	-- mobDamage
	changes.mobAttackSpeed = _G[prefix..i..inputEditBox]:GetNumber()
	
	----------------
	-- AlterTable --
	----------------
	TankPoints:AlterSourceData(newDT, changes)
	
	------------------------------
	-- Calculate new TankPoints --
	------------------------------
	TankPoints:GetTankPoints(newDT, TP_MELEE)
	
	------------------
	-- Display data --
	------------------
	--TPCPlayerStats1_OriginalStatText
	--TPCPlayerStats1_NewStatText
	--TPCResults1_CurrentText
	--TPCResults1_DifferenceText
	--TPCResults1_ResultText
	
	
	-------------------
	-- Results Frame --
	-------------------
	prefix = "TPCResults"
	local function paint_result_line(nformat)
		_G[prefix..i..currentText]:SetText(format(nformat, current))
		_G[prefix..i..resultText]:SetText(format(nformat, new))
		_G[prefix..i..differenceText]:SetText(format(nformat, (new - current)))
		if (new > current) then
			_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
			_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		elseif (new < current) then
			_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
			_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		else
			_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
			_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
	end

	-- TankPoints
	i = 1
	current = floor(self.resultsDT.tankPoints[TP_MELEE])
	new = floor(newDT.tankPoints[TP_MELEE])
	paint_result_line("%.0f")

	-- Effective Health
	i = i + 1
	current = round(self.resultsDT.effectiveHealth[TP_MELEE])
	new = round(newDT.effectiveHealth[TP_MELEE])
	paint_result_line("%.0f")

	-- Effective Health with Block
	if self:ShouldShowEHB() then
		i = i + 1
		current = floor(self.resultsDT.effectiveHealthWithBlock[TP_MELEE])
		new = floor(newDT.effectiveHealthWithBlock[TP_MELEE])
		paint_result_line("%.0f")
	end
	
	-- Damage Reduction
	i = i + 1
	current = floor(self.resultsDT.totalReduction[TP_MELEE] * 100 * 100) / 100
	new = floor(newDT.totalReduction[TP_MELEE] * 100 * 100) / 100
	paint_result_line("%.2f")

	-- Guaranteed Reduction
	i = i + 1
	current = round(self.resultsDT.guaranteedReduction[TP_MELEE]*100, 2)
	new = round(newDT.guaranteedReduction[TP_MELEE]*100, 2)
	paint_result_line("%.2f")

	------------------------
	-- Combat Table Frame --
	------------------------
	prefix = "TPCCombatTable"
	-- mobMissChance
	i = 1
	current = floor(self.resultsDT.mobMissChance * 100 * 100) / 100
	new = floor(newDT.mobMissChance * 100 * 100) / 100
	_G[prefix..i..currentText]:SetText(format("%.2f", current))
	_G[prefix..i..resultText]:SetText(format("%.2f", new))
	_G[prefix..i..differenceText]:SetText(format("%.2f", (new - current)))
	if (new > current) then
		_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- dodgeChance
	i = i + 1
	current = floor(self.resultsDT.dodgeChance * 100 * 100) / 100
	new = floor(newDT.dodgeChance * 100 * 100) / 100
	_G[prefix..i..currentText]:SetText(format("%.2f", current))
	_G[prefix..i..resultText]:SetText(format("%.2f", new))
	_G[prefix..i..differenceText]:SetText(format("%.2f", (new - current)))
	if (new > current) then
		_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- parryChance
	i = i + 1
	current = floor(self.resultsDT.parryChance * 100 * 100) / 100
	new = floor(newDT.parryChance * 100 * 100) / 100
	_G[prefix..i..currentText]:SetText(format("%.2f", current))
	_G[prefix..i..resultText]:SetText(format("%.2f", new))
	_G[prefix..i..differenceText]:SetText(format("%.2f", (new - current)))
	if (new > current) then
		_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- blockChance
	i = i + 1
	current = floor(self.resultsDT.blockChance * 100 * 100) / 100
	new = floor(newDT.blockChance * 100 * 100) / 100
	_G[prefix..i..currentText]:SetText(format("%.2f", current))
	_G[prefix..i..resultText]:SetText(format("%.2f", new))
	_G[prefix..i..differenceText]:SetText(format("%.2f", (new - current)))
	if (new > current) then
		_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- mobCritChance
	i = i + 1
	current = floor(self.resultsDT.mobCritChance * 100 * 100) / 100
	new = floor(newDT.mobCritChance * 100 * 100) / 100
	_G[prefix..i..currentText]:SetText(format("%.2f", current))
	_G[prefix..i..resultText]:SetText(format("%.2f", new))
	_G[prefix..i..differenceText]:SetText(format("%.2f", (new - current)))
	if (new < current) then
		_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new > current) then
		_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- mobCrushChance
	i = i + 1
	current = floor(self.resultsDT.mobCrushChance * 100 * 100) / 100
	new = floor(newDT.mobCrushChance * 100 * 100) / 100
	_G[prefix..i..currentText]:SetText(format("%.2f", current))
	_G[prefix..i..resultText]:SetText(format("%.2f", new))
	_G[prefix..i..differenceText]:SetText(format("%.2f", (new - current)))
	if (new < current) then
		_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new > current) then
		_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- mobHitChance
	i = i + 1
	current = floor(max(0, (1 - self.resultsDT.mobCrushChance - self.resultsDT.mobCritChance - self.resultsDT.blockChance - self.resultsDT.parryChance - self.resultsDT.dodgeChance - self.resultsDT.mobMissChance)) * 100 * 100) / 100
	new = floor(max(0, (1 - newDT.mobCrushChance - newDT.mobCritChance - newDT.blockChance - newDT.parryChance - newDT.dodgeChance - newDT.mobMissChance)) * 100 * 100) / 100
	_G[prefix..i..currentText]:SetText(format("%.2f", current))
	_G[prefix..i..resultText]:SetText(format("%.2f", new))
	_G[prefix..i..differenceText]:SetText(format("%.2f", (new - current)))
	if (new < current) then
		_G[prefix..i..resultText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new > current) then
		_G[prefix..i..resultText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..resultText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		_G[prefix..i..differenceText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	------------------------
	-- Player Stats Frame --
	------------------------
	prefix = "TPCPlayerStats"
	-- Strength
	i = 1
	_, current = UnitStat("player", 1)
	new = floor(current + changes.str)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Agility
	i = i + 1
	_, current = UnitStat("player", 2)
	new = floor(current + changes.agi)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Stamina
	i = i + 1
	_, current = UnitStat("player", 3)
	new = floor(current + changes.sta)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Max Health
	i = i + 1
	current = self.resultsDT.playerHealth
	new = floor(newDT.playerHealth)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Armor (Items)
	i = i + 1
	current = self.resultsDT.armor
	new = floor(newDT.armor)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Armor
	i = i + 1
	current = self.resultsDT.armor
	new = floor(newDT.armor)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Defense Rating
	i = i + 1
	current = GetCombatRating(CR_DEFENSE_SKILL)
	new = floor(current + _G[prefix..i..inputEditBox]:GetNumber())
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Defense
	i = i + 1
	current = self.resultsDT.defense
	new = floor(newDT.defense)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Dodge Rating
	i = i + 1
	current = GetCombatRating(CR_DODGE)
	new = floor(current + _G[prefix..i..inputEditBox]:GetNumber())
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Dodge
	i = i + 1
	current = floor(self.resultsDT.dodgeChance * 100 * 100) / 100
	new = floor(newDT.dodgeChance * 100 * 100) / 100
	_G[prefix..i..originalStatText]:SetText(format("%.2f", current))
	_G[prefix..i..newStatText]:SetText(format("%.2f", new))
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Parry Rating
	i = i + 1
	current = GetCombatRating(CR_PARRY)
	new = floor(current + _G[prefix..i..inputEditBox]:GetNumber())
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Parry
	i = i + 1
	current = floor(self.resultsDT.parryChance * 100 * 100) / 100
	new = floor(newDT.parryChance * 100 * 100) / 100
	_G[prefix..i..originalStatText]:SetText(format("%.2f", current))
	_G[prefix..i..newStatText]:SetText(format("%.2f", new))
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Block Rating
	i = i + 1
	current = GetCombatRating(CR_BLOCK)
	new = floor(current + _G[prefix..i..inputEditBox]:GetNumber())
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Block
	i = i + 1
	current = floor(self.resultsDT.blockChance * 100 * 100) / 100
	new = floor(newDT.blockChance * 100 * 100) / 100
	_G[prefix..i..originalStatText]:SetText(format("%.2f", current))
	_G[prefix..i..newStatText]:SetText(format("%.2f", new))
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Block Value
	i = i + 1
	current = self.resultsDT.blockValue
	new = floor(newDT.blockValue)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- Resilience
	i = i + 1
	current = self.resultsDT.resilience
	new = floor(newDT.resilience)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	---------------------
	-- Mob Stats Frame --
	---------------------
	prefix = "TPCMobStats"
	-- mobLevel
	i = 1
	current = self.resultsDT.mobLevel
	new = floor(newDT.mobLevel)
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- mobDamage
	i = i + 1
	current = floor(TankPoints:GetMobDamage(self.resultsDT.mobLevel))
	new = floor(TankPoints:GetMobDamage(newDT.mobLevel) + _G[prefix..i..inputEditBox]:GetNumber())
	_G[prefix..i..originalStatText]:SetText(current)
	_G[prefix..i..newStatText]:SetText(new)
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	-- mobAttackSpeed
	i = i + 1
	current = floor(self.resultsDT.mobAttackSpeed * 10) / 10
	new = floor(newDT.mobAttackSpeed * 10) / 10
	_G[prefix..i..originalStatText]:SetText(format("%.1f", current))
	_G[prefix..i..newStatText]:SetText(format("%.1f", new))
	if (new > current) then
		_G[prefix..i..newStatText]:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
	elseif (new < current) then
		_G[prefix..i..newStatText]:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
	else
		_G[prefix..i..newStatText]:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
	
	--------------
	-- Clean up --
	--------------
end
