-- -*- indent-tabs-mode: t; tab-width: 4; lua-indent-level: 4 -*-
--[[
Name: TankPoints
Description: Calculates and shows your TankPoints in the PaperDall Frame
Revision: $Revision$
Author: Whitetooth
Email: hotdogee [at] gmail [dot] com
LastUpdate: $Date$
]]

---------------
-- Libraries --
---------------
local L = LibStub("AceLocale-3.0"):GetLocale("TankPoints") --Get the localization for our addon
local StatLogic = LibStub("LibStatLogic-1.2")

--------------------
-- AceAddon Setup --
--------------------
-- AceAddon Initialization
TankPoints = LibStub("AceAddon-3.0"):NewAddon("TankPoints", "AceConsole-3.0", "AceEvent-3.0", "AceDebug-3.0")
local TankPoints = TankPoints

TankPoints.version = "2.9.0 (r"..gsub("$Revision$", "$Revision: (%d+) %$", "%1")..")"
--Append "a" (alpha) to revision if it's alpha. The wowace packager will convert alpha..end-alpha into a block level comment
--@alpha@
TankPoints.version = "2.9.0 (r"..gsub("$Revision$", "$Revision: (%d+) %$", "%1").."a)"
--@end-alpha@
TankPoints.date = gsub("$Date$", "^.-(%d%d%d%d%-%d%d%-%d%d).-$", "%1")


--[[
	The TankPoints has 3 main methods that do the bulk of the work
		- GetSourceData(TP_MELEE) retrieves the players current stats and attributes
		- AlterSourceData(dataTable, changesTable) applies any desired changes (stored in changesTable) to dataTable
		- GetTankPoints(dataTable, TP_MELEE) calculates the various TankPoints values and stores it in dataTable

	GetSourceData(TP_MELEE, [schoolOfMagic], [forceShield]) 
		This function is normally only ever called by the helper function UpdateDataTable.
		This method determintes the various attributes of the player (health, dodge, block chance, etc)
		and stores it in the passed table. 
		This this function is normally called by UpdateDataTable, which uses it to update the
		member varialbe TP_MELEE. Because of this, TP_MELEE is the variable that is understood to hold
		the player's current unmodified attributes.
		
	AlterSourceData(tpTable, changes, [forceShield])
		This function is used to apply changes to tpTable. The desired changes are specified in changes
		and alter the values in tpTable. forceShield is used to override if the player has a shield equipped or not
		
	GetTankPoints(dataTable, TP_MELEE)
		


	UpdateDataTable()
	=================
	UpdateDataTable is used to refresh information about the player held in member sourceTable, 
	and recalculate tankpoints held in member resultsTable.

	UpdateDataTable is called whenever something about the player changes (buffs, mounted, aura, etc).
	Internally it uses GetSourceData, passing sourceTable as the table to fill, e.g.:

		self:GetSourceData(self.sourceTable)
		CopyTable(self.resultsTable, self.sourceTable) --make a copy of sourceTable
		self:GetTankPoints(self.resultsTable)

	
-- 1. Players current DataTable is obtained from TP_Table = TankPoints:GetSourceData(newDT, TP_MELEE)
-- 2. Target stat changes are written in the changes table
-- 3. These 2 tables are passed in TankPoints:AlterSourceData(TP_Table, changes), and it makes changes to TP_Table
-- 4. TP_Table is then passed in TankPoints:GetTankPoints(TP_Table, TP_MELEE), and the results are writen in TP_Table
-- 5. Read the results from TP_Table
--]]


-------------------------
-- AceDebug-2.0 compat --
-------------------------
--[[
TankPoints.debugging = nil

function TankPoints:Debug(...)
	if self.debugging then
		DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff7fff7f(DEBUG) TankPoints:[%s.%3d]|r %s", date("%H:%M:%S"), (GetTime() % 1) * 1000, table.concat(tostringall(...), " ")))
	end
end

function TankPoints:IsDebugging()
	return self.debugging
end

function TankPoints:SetDebugging(value)
	self.debugging = value
end
]]--


----------------------
-- Global Variables --
----------------------
--Enumeration of the various kinds of damage the player can take
TP_RANGED = 0
TP_MELEE = 1
TP_HOLY = 2
TP_FIRE = 3
TP_NATURE = 4
TP_FROST = 5
TP_SHADOW = 6
TP_ARCANE = 7

--Initialize various sets of damage
TankPoints.ElementalSchools = {
    TP_HOLY, TP_FIRE, TP_NATURE, TP_FROST, TP_SHADOW, TP_ARCANE
}

-- schools you can get resist gear for
TankPoints.ResistableElementalSchools = {
    TP_FIRE, TP_NATURE, TP_FROST, TP_SHADOW, TP_ARCANE,
}

--GlobalStrings are strings made availabe by Wow, they're localized too!
--see http://wowprogramming.com/utils/xmlbrowser/diff/FrameXML/GlobalStrings.lua
--Note: The "cap" version of spell schools means capitalized (i.e. "Fire" vs "fire")
TankPoints.SchoolName = {
	[TP_RANGED] = PLAYERSTAT_RANGED_COMBAT,		--"Ranged"
	[TP_MELEE] = PLAYERSTAT_MELEE_COMBAT,		--"Melee"
	[TP_HOLY] = SPELL_SCHOOL1_CAP,				--"Holy"
	[TP_FIRE] = SPELL_SCHOOL2_CAP,				--"Fire"
	[TP_NATURE] = SPELL_SCHOOL3_CAP,			--"Nature"
	[TP_FROST] = SPELL_SCHOOL4_CAP,				--"Frost"
	[TP_SHADOW] = SPELL_SCHOOL5_CAP,			--"Shadow"
	[TP_ARCANE] = SPELL_SCHOOL6_CAP,			--"Arcane"
}

--LibStatLogic uses hard-coded strings as a lookup if a player takes a particular kind of damage
--This lookup translates our constants to those used by LibStatLogic
local schoolIDToString = {
	[TP_RANGED] = "RANGED",
	[TP_MELEE] = "MELEE",
	[TP_HOLY] = "HOLY",
	[TP_FIRE] = "FIRE",
	[TP_NATURE] = "NATURE",
	[TP_FROST] = "FROST",
	[TP_SHADOW] = "SHADOW",
	[TP_ARCANE] = "ARCANE",
}

-- SpellInfo
local SI = {
--	["Holy Shield'] = GetSpellInfo(48951),
	["Holy Shield"] = GetSpellInfo(20925), --Paladin: Using Shield of the Righteous or Inquisition increases your block chance by 15% for 20 sec.
	["Shield Block"] = GetSpellInfo(2565), --Warrior: Increases your chance to block by 100% for 10 sec.
}

---------------------
-- Local Variables --
---------------------
local profileDB -- Initialized in :OnInitialize()

-- Localize Lua globals
local _
local _G = getfenv(0) --returns the global environment (Lua standard)
local strfind = strfind
local strlen = strlen
local gsub = gsub
local pairs = pairs
local ipairs = ipairs
local type = type
local tinsert = tinsert
local tremove = tremove
local unpack = unpack
local max = max
local min = min
local floor = floor
local ceil = ceil
local round = function(n) return floor(n + 0.5) end
local loadstring = loadstring
local tostring = tostring
local setmetatable = setmetatable
local getmetatable = getmetatable
local format = format

-- Localize WoW globals
local GameTooltip = GameTooltip
local CreateFrame = CreateFrame
local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitLevel = UnitLevel
local UnitStat = UnitStat
--local UnitDefense = UnitDefense	20101018: defense removed from game in patch 4.0.1
local UnitHealthMax = UnitHealthMax
local UnitArmor = UnitArmor
local UnitResistance = UnitResistance
local IsEquippedItemType = IsEquippedItemType
local GetTime = GetTime
local GetInventorySlotInfo = GetInventorySlotInfo
local GetTalentInfo = GetTalentInfo
local GetShapeshiftForm = GetShapeshiftForm
local GetShapeshiftFormInfo = GetShapeshiftFormInfo
local GetDodgeChance = GetDodgeChance
local GetParryChance = GetParryChance
local GetBlockChance = GetBlockChance
local GetCombatRating = GetCombatRating
local GetPlayerBuffName = GetPlayerBuffName
local GetShieldBlock = GetShieldBlock

---------------
-- Constants --
---------------
--HEALTH_PER_STAMINA = 10 --removed 20101211: At best it's not used. At worst it was overwriting a global in Bliz FrameXml
BLOCK_DAMAGE_REDUCTION = 0.30 --blocked attacks reduce damage by 30%
ARDENT_DEFENDER_DAMAGE_REDUCTION  = 0.20 --Paladin Ardent Defender ability reduces all damage by 20% for 10 seconds


-----------
-- Tools --
-----------
-- clear "to", and copy "from"
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

--------------------
-- Schedule Tasks --
--------------------
TankPoints.ScheduledTasks = {}
function TankPoints:Schedule(taskName, timeAfter, functionName, ...)
	if (taskName and timeAfter) then -- functionName not required so we can use IsScheduled as a timer check
		self.ScheduledTasks[taskName] = {
			TargetTime = GetTime() + timeAfter,
			FunctionName = functionName,
			Arg = {...},
		}
	end
end

function TankPoints:ScheduleRepeat(taskName, repeatRate, functionName, ...)
	if (taskName and repeatRate and functionName) then -- functionName required
		self.ScheduledTasks[taskName] = {
			Elapsed = 0,
			RepeatRate = repeatRate,
			FunctionName = functionName,
			Arg = {...},
		}
	end
end

function TankPoints:UnSchedule(taskName)
	--WT_RaidWarningAPI.Announce({HOTDOG = taskName})
	if not taskName then return end
	self.ScheduledTasks[taskName] = nil
end

function TankPoints:IsScheduled(taskName)
	return (self.ScheduledTasks[taskName] ~= nil)
end

function TankPoints:OnUpdate(elapsed)
--[[	
	Run each time the screen is drawn by the game engine. 
	This handler runs for each frame (not Frame) drawn. If WoW is currently running at 27.5 frames per second, 
	the OnUpdate handlers for every visible Frame, Animation, and AnimationGroup (or descendant thereof) are run 
	approximately every 2/55ths of a second. 
	Therefore, OnUpdate handler can be useful for processes which need to be run very frequently 
	or with accurate timing, 
	but extensive processing in an OnUpdate handler can slow down the game's framerate.
--]]
--	TankPoints:Debug("OnUpdate(elapsed="..tostring(elapsed)..")")
	local currentTime = GetTime()
	for taskName, task in pairs(TankPoints.ScheduledTasks) do
		if type(task.TargetTime) ~= "nil" and (currentTime >= task.TargetTime) then
			TankPoints:UnSchedule(taskName)
			if (task.FunctionName) then
				task.FunctionName(unpack(task.Arg))
			end
		elseif type(task.Elapsed) ~= "nil" then
			task.Elapsed = task.Elapsed + arg1
			if (task.Elapsed >= task.RepeatRate) then
				task.FunctionName(unpack(task.Arg))
				task.Elapsed = task.Elapsed - task.RepeatRate
			end
		end
	end
end

function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, ", " ) .. "}"
end

function TankPoints:VarAsString(value)
--[[Convert a variable to a string
--]]

	local Result = "["..type(value).."] = "
	
	--[[
		Some types in LUA refuse to be converted to a string, so we have to do it for it.
	
		LUA type() function returns a lowercase string that contains one of the following:
			- "nil"			we must manually return "nil"
			- "boolean"		we must manually convert to "true" or "false"
			- "number"
			- "string"
			- "function"
			- "userdata"
			- "thread"
			- "table"		we must manually convert to a string
			
	]]--
	
	if (value == nil) then
		Result = Result.."nil"
	elseif (type(value) == "table") then
		Result = Result..table.tostring(value)
	elseif (type(value) == "boolean") then
		if (value) then
			Result = Result.."true"
		else
			Result = Result.."false"
		end
	else
		Result = Result..value
	end
	
	return Result;
end

---------------------
-- Initializations --
---------------------
--[[ Loading Process Event Reference
{
ADDON_LOADED - When this addon is loaded (exposed as :OnInitialize)
VARIABLES_LOADED - When all addons are loaded
PLAYER_LOGIN - Most information about the game world should now be available to the UI (exposed as :OnEnable)
}
--]]

-- Default values
local defaults = {
	profile = {
		showTooltipDiff = true,
		showTooltipTotal = false,
		showTooltipDRDiff = false,
		showTooltipDRTotal = false,
		showTooltipEHDiff = false,
		showTooltipEHTotal = false,
		showTooltipEHBDiff = false,
		showTooltipEHBTotal = false,
		mobLevelDiff = 3,
		mobDamage = 0,
		mobCritChance = 0.05,
		mobCritBonus = 1,
		mobMissChance = 0.05,
		mobSpellCritChance = 0,
		mobSpellCritBonus = 0.5,
		mobSpellMissChance = 0,
		shieldBlockDelay = 2,
	},
}

-- OnInitialize(name) called at ADDON_LOADED by WowAce 
function TankPoints:OnInitialize()
	self:Debug("TankPoints:OnInitialize()");
	self.db = LibStub("AceDB-3.0"):New("TankPointsDB", defaults)

	-- Initialize profileDB
	profileDB = self.db.profile
	
	-- OnUpdate Frame
	self.OnUpdateFrame = CreateFrame("Frame")
	self.OnUpdateFrame:SetScript("OnUpdate", self.OnUpdate)

	-- Player TankPoints table
	self.sourceTable = {}	--holds the current raw stats and attributes of the player. Populated by called UpdateDataTable, which calls GetSourceData(sourceTable)
	self.resultsTable = {}	--holds the adjusted and calculated stats as well as the calcualted TankPoints and EffectiveHealth

	-- Set player class, race, level
	TankPoints.playerClass = select(2, UnitClass("player"))
	TankPoints.playerRace = select(2, UnitRace("player"))

	--Call SetupOptions if we've included the options file. (Not like there's any reason not to include it, its not like you can use the addon. But it's modular, helps with testing)
	if (self.SetupOptions) then
		self:SetupOptions() --in options.lua
	end
end

-- OnEnable() called at PLAYER_LOGIN by WowAce
function TankPoints:OnEnable()
	self:Debug("TankPoints:OnEnable()")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED")
	-- Initialize TankPoints.playerLevel
	self.playerLevel = UnitLevel("player")
	-- by default don't show tank points per stat
	self.tpPerStat = nil
	-- Calculate TankPoints
	self:UpdateDataTable()

	-- Add "TankPoints" to playerstat drop down list
	self:AddStatFrames()
end

function TankPoints:ShowPerStat()
	return self.tpPerStat
end
function TankPoints:SetShowPerStat(x)
	self.tpPerStat = x
end

-------------------------
-- Updating TankPoints --
-------------------------
-- Update TankPoints panal stats if selected
function TankPoints:UpdateStats()
	self:UpdateDataTable()
	
	PaperDollFrame_UpdateStats()
	
--	self:Print("UpdateStats() - "..self.resultsTable.tankPoints[TP_MELEE]);
--	self:Debug("UpdateStats() - "..self.resultsTable.tankPoints[TP_MELEE]);
end

-- Update sourceTable, recalculate TankPoints, and store it in resultsTable
function TankPoints:UpdateDataTable()
	--self:Print("TankPoints:UpdateDataTable()");
	self:GetSourceData(self.sourceTable)

	copyTable(self.resultsTable, self.sourceTable) --destination, source
	self:GetTankPoints(self.resultsTable)

	if (TankPointsTooltips) then
		TankPointsTooltips.ClearCache();
	end;
	--print(self.resultsTable.tankPoints[TP_MELEE], StatLogic:GetStatMod("MOD_ARMOR"), self.sourceTable.armor, UnitArmor("player"))
end

------------
-- Events --
------------
-- event = UNIT_AURA
-- arg1 = UnitID of the entity
function TankPoints:UNIT_AURA(_, unit)
	if unit == "player" then
		self:Schedule("UpdateStats", 0.7, TankPoints.UpdateStats, TankPoints)
	end
end
TankPoints.UNIT_INVENTORY_CHANGED = TankPoints.UNIT_AURA

-- event = PLAYER_LEVEL_UP
-- arg1 = New player level
function TankPoints:PLAYER_LEVEL_UP(_, level)
	self.playerLevel = level
	self:Schedule("UpdateStats", 0.7, TankPoints.UpdateStats, TankPoints)
end


---------------------
-- TankPoints Core --
---------------------
--[[
armorReductionTemp = armor / ((85 * levelModifier) + 400)
armorReduction = armorReductionTemp / (armorReductionTemp + 1)
defenseEffect = (defense - attackerLevel * 5) * 0.04 * 0.01
blockValueFromStrength = (strength * 0.05) - 1
[removed] blockValue = floor(blockValueFromStrength) + floor((blockValueFromItems + blockValueFromShield) * blockValueMod)
[removed]mobDamage = (levelModifier * 55) * meleeTakenMod * (1 - armorReduction)
resilienceEffect = StatLogic:GetEffectFromRating(resilience, playerLevel) * 0.01
mobCritChance = max(0, 0.05 - defenseEffect - resilienceEffect)
mobCritBonus = 1
mobMissChance = max(0, 0.05 + defenseEffect)
mobCrushChance = 0.15 + max(0, (playerLevel * 5 - defense) * 0.02) (if mobLevel is +3)
mobCritDamageMod = max(0, 1 - resilienceEffect * 2)
blockedMod = 30/40/30*crit
mobSpellCritChance = max(0, 0 - resilienceEffect)
mobSpellCritBonus = 0.5
mobSpellMissChance = 0
mobSpellCritDamageMod = max(0, 1 - resilienceEffect * 2)
schoolReduction[SCHOOL] = 0.75 * (resistance[SCHOOL] / (mobLevel * 5))
totalReduction[MELEE] = 1 - ((mobCritChance * (1 + mobCritBonus) * mobCritDamageMod) + (mobCrushChance * 1.5) + (1 - mobCrushChance - mobCritChance - blockChance * blockedMod - parryChance - dodgeChance - mobMissChance)) * (1 - armorReduction) * meleeTakenMod
totalReduction[SCHOOL] = 1 - ((mobSpellCritChance * (1 + mobSpellCritBonus) * mobSpellCritDamageMod) + (1 - mobSpellCritChance - mobSpellMissChance)) * (1 - schoolReduction[SCHOOL]) * spellTakenMod
tankPoints = playerHealth / (1 - totalReduction)
effectiveHealth = playerHealth * 1/reduction (armor, school, etc) - this is by Ciderhelm. http://www.theoryspot.com/forums/theory-articles-guides/1060-effective-health-theory.html
effectiveHealthWithBlock = effectiveHealth modified by expected guaranteed blocks. This is done through simulation using the mob attack speed, etc. See GetEffectiveHealthWithBlock.
--]]
function TankPoints:GetArmorReduction(armor, attackerLevel)

	--Use LibStatLogic, it's been updated for Cataclysm
	return StatLogic:GetReductionFromArmor(armor, attackerLevel)

	--[[ Following hasn't been updated for Cataclysm. LibStatLogic is right.
	local levelModifier = attackerLevel
	if ( levelModifier > 59 ) then
		levelModifier = levelModifier + (4.5 * (levelModifier - 59))
	end
	local temp = armor / (85 * levelModifier + 400)
	local armorReduction = temp / (1 + temp)
	-- caps at 75%
	if armorReduction > 0.75 then
		armorReduction = 0.75
	end
	if armorReduction < 0 then
		armorReduction = 0
	end
	return armorReduction
	]]--
end

--[[
	20101018: Defense removed from game in patch 4.0.1 
function TankPoints:GetDefense()
	local base, modifier = UnitDefense("player");
	return base + modifier
end
--]]

function TankPoints:ShieldIsEquipped()
	--local _, _, _, _, _, _, itemSubType = GetItemInfo(GetInventoryItemLink("player", 17) or "")
	--return itemSubType == L["Shields"]
	return IsEquippedItemType("INVTYPE_SHIELD")
end

--[[
	Returns your shield block value, Whitetooth@Cenarius (hotdogee@bahamut.twbbs.org)
	If you don't have a shield equipped (or you force it false), then your blocked amount is zero
function TankPoints:GetBlockValue(mobDamageDepricated, forceShield)
	-- Block from Strength
	-- Talents: Pal, War
	-- (%d+) Block (on shield)
	-- %+(%d+) Block Value (ZG enchant)
	-- Equip: Increases the block value of your shield by (%d+)
	-- Set: Increases the block value of your shield by (%d+)
	-------------------------------------------------------
	-- Get Block Value from shield if shield is equipped --
	-------------------------------------------------------
	--self:Debug("TankPoints:GetBlockValue(mobDamage="..(mobDamage or "nil")..", forceShield="..(forceShield or "nil")..")")
	
	if (mobDamage == nil) then
		error("GetBlockValue: mobDamage cannot be nil")
	end
	
	if (not self:ShieldIsEquipped()) and (forceShield ~= true) then -- doesn't have shield equipped
		return 0
	end
	--return GetShieldBlock() --a built-in WoW api
	
	--As of patch 4.0.1 all blocked attacks are a straight 30% reduction
	--Note: paladin's HolyShield talent, when active, increases the amount blocked by 10%. But we don't handle that here
	return round(mobDamageDepricated * BLOCK_DAMAGE_REDUCTION);
end
--]]
------------------
-- GetMobDamage --
------------------
--[[
------------------------------------
-- mobDamage, for factoring in block
-- I designed this formula with the goal to model the normal damage of a raid boss at your level
-- the level modifier was taken from the armor reduction formula to base the level effects
-- at level 63 mobDamage is 4455, this is what Nefarian does before armor reduction
-- at level 73 mobDamage is 6518, which matches TBC raid bosses
-- at level 83 mobDamage is 10000 (todo: get a real Marrowgar number, 10/25/10H/25H)
-- at level 88 mobDamage is 14000 (todo: get a real number from something)
function TankPoints:GetMobDamage(mobLevel)
	--self:Debug("TankPoints:GetMobDamage(mobLevel="..(mobLevel or "nil")..")")

	if profileDB.mobDamage and profileDB.mobDamage ~= 0 then
		self:Debug("TankPoints:GetMobDamage: Using profile mob damage value of "..profileDB.mobDamage);
		return profileDB.mobDamage
	end
	local levelMod = mobLevel
	if ( levelMod > 80 ) then
		levelMod = levelMod + (30 * (levelMod - 59))
	elseif ( levelMod > 70 ) then
		levelMod = levelMod + (15 * (levelMod - 59))
	elseif ( levelMod > 59 ) then
		levelMod = levelMod + (4.5 * (levelMod - 59))
	end
	return levelMod * 55 -- this is the value before mitigation, which we will do in GetTankPoints
end
]]--

------------------------
-- Shield Block Skill --
------------------------
--[[ deprecated in WotLK
-- TankPoints:GetShieldBlockOnTime(4, 1, 70, nil)
function TankPoints:GetShieldBlockOnTime(atkCount, mobAtkSpeed, blockChance, talant)
	local time = 0
	if blockChance > 1 then
		blockChance = blockChance * 0.01
	end
	if not talant then
		-- Block =    70.0% = 50.0%
		-- ------------
		-- NNNN = 4 =  2.7% = 12.5% = 4 下平均是 3.5 * mobAtkSpeed秒
		-- NNB  = 3 =  6.3% = 12.5% = 3 下平均是 2.5 * mobAtkSpeed秒
		-- NB   = 2 = 21.0% = 25.0% = 2 下平均是 1.5 * mobAtkSpeed秒
		-- B    = 1 = 70.0% = 50.0% = 1 下平均是 0.5 * mobAtkSpeed秒
		if ((atkCount - 1) * mobAtkSpeed) > 5 then
			atkCount = ceil(5 / mobAtkSpeed)
		end
		for c = 1, atkCount do
			if c == atkCount then
				time = time + ((1 - blockChance) ^ (c - 1)) * (c - 0.5) * mobAtkSpeed
				--TankPoints:Print((((1 - blockChance) ^ (c - 1)) * 100).."%")
			else
				time = time + blockChance * ((1 - blockChance) ^ (c - 1)) * (c - 0.5) * mobAtkSpeed
				--TankPoints:Print((blockChance * ((1 - blockChance) ^ (c - 1)) * 100).."%")
			end
		end
		if atkCount <= 0 then
			time = 5
		end
	else
		-- Block =     70.0% = 50.0%
		-- ------------
		-- NNN   = 4 =  2.7% = 12.5%
		-- BNN   = 4 =  6.3% = 12.5%
		-- NBN   = 4 =  6.3% = 12.5%
		-- NNB   = 4 =  6.3% = 12.5%
		-- BNB   = 3 = 14.7% = 12.5%
		-- NBB   = 3 = 14.7% = 12.5%
		-- BB    = 2 = 49.0% = 24.0%
		if ((atkCount - 1) * mobAtkSpeed) > 6 then
			atkCount = ceil(6 / mobAtkSpeed)
		end
		for c = 2, atkCount do
			if c == atkCount then
				time = time + ((blockChance * ((1 - blockChance) ^ (c - 2)) * (c - 1)) + ((1 - blockChance) ^ (c - 1))) * (c - 0.5) * mobAtkSpeed
				--TankPoints:Print((((blockChance * ((1 - blockChance) ^ (c - 2)) * (c - 1)) + ((1 - blockChance) ^ (c - 1))) * 100).."%")
			else
				time = time + blockChance * blockChance * ((1 - blockChance) ^ (c - 2)) * (c - 1) * (c - 0.5) * mobAtkSpeed
				--TankPoints:Print((blockChance * blockChance * ((1 - blockChance) ^ (c - 2)) * (c - 1) * 100).."%")
			end
		end
		if atkCount <= 1 then
			time = 6
		end
	end
	return time
end

-- TankPoints:GetshieldBlockUpTime(10, 2, 55, 1)
function TankPoints:GetshieldBlockUpTime(timeBetweenPresses, mobAtkSpeed, blockChance, talant)
	local shieldBlockDuration = 5
	if talant then
		shieldBlockDuration = 6
	end
	local avgAttackCount = shieldBlockDuration / mobAtkSpeed
	local min = floor(avgAttackCount)
	local percentage = avgAttackCount - floor(avgAttackCount)
	local avgOnTime = self:GetShieldBlockOnTime(min, mobAtkSpeed, blockChance, talant) * (1 - percentage) + 
	                  self:GetShieldBlockOnTime(min + 1, mobAtkSpeed, blockChance, talant) * percentage
	return avgOnTime / timeBetweenPresses
end
--]]

-- mobContactChance is both regular hits, crits, and crushes
-- This works through simulation. Each mob attack until you run out of health
-- is evaluated for whether or not you can expect to have a guaranteed block.
-- 
-- Ciderhelm makes reference to how this would be calculated at http://www.theoryspot.com/forums/theory-articles-guides/1060-effective-health-theory.html
--
-- EHB (Effective Health w/ Block) will change depending upon how often you
-- press the shield block button, the mob attack speed, and mob damage.
-- This is not gear dependent.
-- mobDamage is after damage reductions
function TankPoints:GetEffectiveHealthWithBlock(TP_Table, mobDamage)

	local effectiveHealth = TP_Table.effectiveHealth[TP_MELEE]
	-- Check for shield
	local blockValue = 0; --floor(TP_Table.blockValue)
	if blockValue == 0 then
		return effectiveHealth
	end
	local mobContactChance = TP_Table.mobContactChance
	local sbCoolDown, sbDuration, sbDuration
	-- Check for guaranteed block
	if self.playerClass == "PALADIN" then
		if not (select(5, GetTalentInfo(2, 17)) > 0) then -- Check for Holy Shield talent
			return effectiveHealth
		end
		if ((10 / (8 + TP_Table.shieldBlockDelay) >= 1) and not UnitBuff("player", SI["Holy Shield"])) and mobContactChance > 0 then -- If Holy Shield has 100% uptime
			return effectiveHealth
		elseif UnitBuff("player", SI["Holy Shield"]) and mobContactChance > 0 then -- If Holy Shield is already up
			return effectiveHealth
		elseif mobContactChance > 30 then
			return effectiveHealth
		end
		sbCoolDown = 8
		sbDuration = 10
		sbCharges = 8
	elseif self.playerClass == "WARRIOR" then
		if not UnitBuff("player", SI["Shield Block"]) then
			blockValue = blockValue * 2
		end
		local _, _, _, _, r = GetTalentInfo(3, 8)
		sbCoolDown = 60 - r * 10
		sbDuration = 10
		sbCharges = 100
	else -- neither Paladin or Warrior
		return effectiveHealth
	end
	
	mobDamage = ceil(mobDamage)
	local shieldBlockDelay = TP_Table.shieldBlockDelay
	local timeBetweenPresses = sbCoolDown + shieldBlockDelay
	return effectiveHealth * mobDamage / ((mobDamage * (timeBetweenPresses - sbDuration) / timeBetweenPresses) + ((mobDamage - blockValue) * sbDuration / timeBetweenPresses))
end

----------------
-- TankPoints --
----------------
--[[
TankPoints:GetSourceData([TP_Table], [school], [forceShield])
TankPoints:AlterSourceData(TP_Table, changes, [forceShield])
TankPoints:CheckSourceData(TP_Table, [school], [forceShield])
TankPoints:GetTankPoints([TP_Table], [school], [forceShield])

-- school
TP_RANGED = 0
TP_MELEE = 1
TP_HOLY = 2
TP_FIRE = 3
TP_NATURE = 4
TP_FROST = 5
TP_SHADOW = 6
TP_ARCANE = 7

-- TP_Table Inputs
{
	playerLevel = ,
	playerHealth = ,
	playerClass = ,
	mobLevel = ,
	resilience = ,
	-- Melee
	mobCritChance = 0.05, -- talant effects
	mobCritBonus = 1,
	mobMissChance = 0.05,
	armor = ,
	defense = ,
	dodgeChance = ,
	parryChance = ,
	blockChance = ,
	blockValue = ,
	mobDamage = ,
	mobCritDamageMod = , -- from talants
	-- Spell
	mobSpellCritChance = 0, -- talant effects
	mobSpellCritBonus = 0.5,
	mobSpellMissChance = 0, -- this should change with mobLevel, but we don't have enough data yet
	resistance = {
		[TP_HOLY] = 0,
		[TP_FIRE] = ,
		[TP_NATURE] = ,
		[TP_FROST] = ,
		[TP_SHADOW] = ,
		[TP_ARCANE] = ,
	},
	mobSpellCritDamageMod = , -- from talants
	-- All
	damageTakenMod = {
		[TP_MELEE] = ,
		[TP_HOLY] = ,
		[TP_FIRE] = ,
		[TP_NATURE] = ,
		[TP_FROST] = ,
		[TP_SHADOW] = ,
		[TP_ARCANE] = ,
	},
}
-- TP_Table Output adds calculated fields to the table
{
	resilienceEffect = ,
	-- Melee - Added
	armorReduction = ,
	defenseEffect = ,
	mobCrushChance = ,
	mobCritDamageMod = , -- from resilience
	blockedMod = ,
	-- Melee - Changed
	mobMissChance = ,
	dodgeChance = ,
	parryChance = ,
	blockChance = ,
	mobHitChance = , -- chance for a mob to non-crit, non-crush, non-blocked hit you (regular hit)
	mobCritChance = ,
	mobCrushChance =,
	mobContactChance =, -- the chance for a mob to hit/crit/crush you
	mobDamage = ,
	-- Spell - Added
	mobSpellCritDamageMod = ,
	-- Spell - Changed
	mobSpellCritChance = ,
	-- Results
	schoolReduction = {
		[TP_MELEE] = , -- armorReduction
		[TP_HOLY] = ,
		[TP_FIRE] = ,
		[TP_NATURE] = ,
		[TP_FROST] = ,
		[TP_SHADOW] = ,
		[TP_ARCANE] = ,
	},
	guaranteedReduction = { -- armor/resist + talent + stance
		[TP_MELEE] = ,
		[TP_HOLY] = ,
		[TP_FIRE] = ,
		[TP_NATURE] = ,
		[TP_FROST] = ,
		[TP_SHADOW] = ,
		[TP_ARCANE] = ,
	},
	totalReduction = {
		[TP_MELEE] = ,
		[TP_HOLY] = ,
		[TP_FIRE] = ,
		[TP_NATURE] = ,
		[TP_FROST] = ,
		[TP_SHADOW] = ,
		[TP_ARCANE] = ,
	},
	tankPoints = {
		[TP_MELEE] = ,
		[TP_HOLY] = ,
		[TP_FIRE] = ,
		[TP_NATURE] = ,
		[TP_FROST] = ,
		[TP_SHADOW] = ,
		[TP_ARCANE] = ,
	},
	-- how much raw damage you can take without a block/dodge/miss/parry
	effectiveHealth = {
		[TP_MELEE] = ,
		[TP_HOLY] = ,
		[TP_FIRE] = ,
		[TP_NATURE] = ,
		[TP_FROST] = ,
		[TP_SHADOW] = ,
		[TP_ARCANE] = ,
	},
	-- how much raw damage you can take without a dodge/miss/parry and only caunting
	-- guaranteed blocks.
	effectiveHealthWithBlock = {
		[TP_MELEE] = ,
	},
}
--]]

--[[---------------------------------
{	:GetSourceData(TP_Table, school, forceShield)
-------------------------------------
-- Description
	GetSourceData is the slowest function here, dont call it unless you are sure the stats have changed.
-- Arguments
	[TP_Table]
	    table - obtained data is to be stored in this table
	[school]
	    number - specify a school id to get only data for that school
			TP_RANGED = 0
			TP_MELEE = 1
			TP_HOLY = 2
			TP_FIRE = 3
			TP_NATURE = 4
			TP_FROST = 5
			TP_SHADOW = 6
			TP_ARCANE = 7
	[forceShield]
		bool - arg added for tooltips
			true: force shield on
			false: force shield off
			nil: check if user has shield equipped
-- Returns
	TP_Table
	    table - obtained data is to be stored in this table
		
		{
			playerLevel=83,
			playerHealth = 66985,
			playerClass="PALADIN",
			mobLevel=86,
			resilience=0
			
			--Melee data
			mobCritChance=0.05,
			mobCritBonus=1,
			mobMissChance=0.05,
			armor=23576,
			defense=0,
			defenseRating=0,
			dodgeChance = 0.1197537982178,
			parryChance = 0.13563053131104,
			shieldBlockDelay=2,
			blockChance=0.26875,
			damageTakenMod={0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9),
			mobCritDamageMod=1,

			--Spell Data
			mobSpellCritChance = 0,
			mobSpellCritBonus = 0.5, 
			mobSpellMissChance = 0,
			resistance = { 
				[2]=0,
				[3]=15,
				[4]=0,
				[5]=0
				[6]=0,
				[7]=0},
			mobSpellCritDamageMod = 1,
		}
		
-- Examples
}
-----------------------------------]]
function TankPoints:GetSourceData(TP_Table, school, forceShield)
	--self:Print("TankPoints:GetSourceData");

	if not TP_Table then
		-- Acquire temp table
		TP_Table = {}
	end

	-- Unit
	local unit = "player"
	TP_Table.playerLevel = UnitLevel(unit)
	TP_Table.playerHealth = UnitHealthMax(unit)
	TP_Table.playerClass = self.playerClass
	TP_Table.mobLevel = UnitLevel(unit) + self.db.profile.mobLevelDiff

	-- Resilience
	TP_Table.resilience = GetCombatRating(COMBAT_RATING_RESILIENCE_CRIT_TAKEN) --20101017: Changed in Patch4.0 from CR_CRIT_TAKEN_MELEE --Ian

	TP_Table.damageTakenMod = {}
	TP_Table.mobSpellCritDamageMod = {} --20101213 added initialziation
	----------------
	-- Melee Data --
	----------------
--	if (not school) or school == TP_MELEE then
		-- Mob's Default Crit and Miss Chance
		TP_Table.mobCritChance = self.db.profile.mobCritChance --mob's melee crit change (e.g. 0.05 ==> 5%)
		TP_Table.mobCritBonus = self.db.profile.mobCritBonus		--mob's melee crit bonus (e.g. 1 ==> 200% damage, 0.5 ==> 150% damage)
		TP_Table.mobMissChance = self.db.profile.mobMissChance - StatLogic:GetStatMod("ADD_HIT_TAKEN", "MELEE")

		-- Armor
		_, TP_Table.armor = UnitArmor(unit)

		--[[
			Defense removed from game in patch 4.0.1
			TODO: 20101018: remove these lines entirely, and remove checks from CheckSourceTable
		--]]
		-- Defense
		TP_Table.defense = 0 --self:GetDefense()
		-- Defense Rating also needed because direct Defense gains are not affected by DR
		TP_Table.defenseRating = 0 --GetCombatRating(CR_DEFENSE_SKILL)
		--]]
		
		-- Mastery
		TP_Table.mastery = GetMastery(); --Mastery is a value, e.g. 14.16. (i.e. It isn't a percentage or a fraction)
		TP_Table.masteryRating = GetCombatRating(CR_MASTERY);

		-- Dodge, Parry
		-- 2.0.2.6144 includes defense factors in these functions
		TP_Table.dodgeChance = GetDodgeChance() * 0.01-- + TP_Table.defenseEffect
		TP_Table.parryChance = GetParryChance() * 0.01-- + TP_Table.defenseEffect

		-- Shield Block key press delay
		TP_Table.shieldBlockDelay = self.db.profile.shieldBlockDelay

		-- Block Chance, Block Value
		-- Check if player has shield or forceShield is set to true
		if (forceShield == true) or ((forceShield == nil) and self:ShieldIsEquipped()) then
			TP_Table.blockChance = GetBlockChance() * 0.01-- + TP_Table.defenseEffect
		else
			TP_Table.blockChance = 0
		end

		-- Melee Taken Mod
		TP_Table.damageTakenMod[TP_MELEE] = StatLogic:GetStatMod("MOD_DMG_TAKEN", "MELEE")
		-- mobCritDamageMod from talants
		TP_Table.mobCritDamageMod = StatLogic:GetStatMod("MOD_CRIT_DAMAGE_TAKEN", "MELEE")
--	end

	----------------
	-- Spell Data --
	----------------
--	if (not school) or school > TP_MELEE then
		TP_Table.mobSpellCritChance = self.db.profile.mobSpellCritChance
		TP_Table.mobSpellCritBonus = self.db.profile.mobSpellCritBonus
		TP_Table.mobSpellMissChance = self.db.profile.mobSpellMissChance - StatLogic:GetStatMod("ADD_HIT_TAKEN", "HOLY")
		-- Resistances
		TP_Table.resistance = {}
		if not school then
			for _, s in ipairs(self.ResistableElementalSchools) do
				_, TP_Table.resistance[s] = UnitResistance(unit, s - 1)
			end
			-- Holy Resistance always 0
			TP_Table.resistance[TP_HOLY] = 0
		else
			_, TP_Table.resistance[school] = UnitResistance(unit, school - 1)
		end
		-- Spell Taken Mod
		for _,s in ipairs(self.ElementalSchools) do
			TP_Table.damageTakenMod[s] = StatLogic:GetStatMod("MOD_DMG_TAKEN", schoolIDToString[s])
		end
		-- mobSpellCritDamageMod from talants
		TP_Table.mobSpellCritDamageMod = StatLogic:GetStatMod("MOD_CRIT_DAMAGE_TAKEN", TP_HOLY)
--	end

	------------------
	-- Return table --
	------------------
	return TP_Table
end

--[[
	AlterSourceData(source, changes, [forceShield])
	
	Arguments
	@param source A data table that contains the values to be modified
	@param changes
			A data table that contains the changes to be applied to tpTable
			The changes that can be applied are the following members:					
				changes = {
					-- player stats
					str = ,
					agi = ,
					sta = ,
					playerHealth = ,
					armor = ,
					armorFromItems = ,
					defense = ,
					dodgeChance = ,
					parryChance = ,
					blockChance = ,
					resilience = ,
					-- mob stats
					mobLevel = ,
					mastery = ,
					masteryRating = ,
				}
		
		forceShield
			An optional boolean value indicating whether to assume a shield is equipped or not (to perform blocks)
			true	block calculations will be applied
			false	block calculations will not be applied
			omitted	block calculations will depend if the player has a shield equipped
--]]
-- 1. Player's current DataTable is obtained from TP_Table = TankPoints:GetSourceData(newDT, TP_MELEE)
-- 2. Target stat changes are written in the changes table
-- 3. These 2 tables are passed in TankPoints:AlterSourceData(TP_Table, changes), and it makes changes to TP_Table
-- 4. TP_Table is then passed in TankPoints:GetTankPoints(TP_Table, TP_MELEE), and the results are writen in TP_Table
-- 5. Read the results from TP_Table
function TankPoints:AlterSourceData(tpTable, changes, forceShield)
	
	self:Debug("AlterSourceData(): changes="..self:VarAsString(changes));

	if changes.str and changes.str ~= 0 then
		------- Formulas -------
		-- totalStr = floor(baseStr * strMod) + floor(bonusStr * strMod)
		------- Talants -------
		-- StatLogic:GetStatMod("MOD_STR")
		-- ADD_PARRY_RATING_MOD_STR (formerly ADD_CR_PARRY_MOD_STR)
		------------------------
		local totalStr, _, bonusStr = UnitStat("player", 1) --1=Strength
		local strMod = StatLogic:GetStatMod("MOD_STR")
		-- WoW floors numbers after being multiplied by stat mods, so to obtain the original value, you need to ceil it after dividing it with the stat mods
		changes.str = max(0, floor((ceil(bonusStr / strMod) + changes.str) * strMod)) - bonusStr
		
		if GetParryChance() ~= 0 and StatLogic:GetStatMod("ADD_PARRY_RATING_MOD_STR") ~= 0 then
			local addParryRatingModStr = StatLogic:GetStatMod("ADD_PARRY_RATING_MOD_STR");
		
			local parryRatingIncrease = floor((bonusStr + changes.str) * addParryRatingModStr) - floor(bonusStr * addParryRatingModStr)
			
			local parry = StatLogic:GetEffectFromRating(parryRatingIncrease, CR_PARRY, tpTable.playerLevel); --GetEffectFromRating returns as percentage rather than fraction
			parry = StatLogic:GetAvoidanceGainAfterDR("PARRY", parry) * 0.01; --apply diminishing returns, and convert percentage to fraction
			
			self:Debug(string.format("   Adding %.4f%% Parry (%d Parry Rating from %d Strength) to existing %.4f%% Parry",
					parry*100, parryRatingIncrease, changes.str, tpTable.parryChance*100));
			
			tpTable.parryChance = tpTable.parryChance + parry;
		end
	end
	
	if (changes.agi and changes.agi ~= 0) then
		--self:Debug("TankPoints:AlterSourceData: altering agility by "..changes.agi)
		------- Formulas -------
		-- agi = floor(agi * agiMod)
		-- dodgeChance = baseDodge + dodgeFromRating + dodgeFromAgi + dodgeFromRacial + dodgeFromTalant + dodgeFromDefense
		-- armor = floor((armorFromItem * armorMod) + 0.5) + agi * 2 + posArmorBuff - negArmorBuff
		------- Talants -------
		-- Rogue: Vitality (Rank 2) - 2,20
		--        Increases your total Stamina by 2%/4% and your total Agility by 1%/2%.
		-- Rogue: Sinister Calling (Rank 5) - 3,21
		--        Increases your total Agility by 3%/6%/9%/12%/15%.
		-- Hunter: Combat Experience (Rank 2) - 2,14
		--         Increases your total Agility by 1%/2% and your total Intellect by 3%/6%.
		-- Hunter: Lightning Reflexes (Rank 5) - 3,18
		--         Increases your Agility by 3%/6%/9%/12%/15%.
		------------------------
		local _, _, agility = UnitStat("player", 2)
		local agiMod = StatLogic:GetStatMod("MOD_AGI")
		
		if (agiMod ~= 1.0) then
			changes.agi = max(0, floor((ceil(agility / agiMod) + changes.agi) * agiMod)) - agility
			self:Debug(string.format("   Adjusting agility change to %d because of MOD_AGI %.2f", changes.agi, agiMod));
		end
		
		-- Calculate dodge chance
		local dodgeThroughAgility = StatLogic:GetDodgePerAgi() * changes.agi; --could also use StatLogic:GetDodgeFromAgi(changes.agi)

		--Adjust dodge percentage for diminishing returns
		dodgeThroughAgility = StatLogic:GetAvoidanceGainAfterDR("DODGE", dodgeThroughAgility);
		--self:Debug("dodgeThroughAgility after DR = "..dodgeThroughAgility)

		self:Debug(string.format("   Adding %.4f%% dodge (from %d Agility) to existing %.4f%% Dodge", dodgeThroughAgility, changes.agi, tpTable.dodgeChance*100));
		
		--self:Debug("tpTable.dodgeChance = "..tpTable.dodgeChance)
		tpTable.dodgeChance = tpTable.dodgeChance + (dodgeThroughAgility * 0.01)
		--self:Debug("tpTable.dodgeChance after = "..tpTable.dodgeChance)
		
		-- Armor mods don't effect armor from agi
		--20110103: Agility no longer affects armor (at least it doesn't affect mine)
		--tpTable.armor = tpTable.armor + changes.agi * 2
	end
	
	if (changes.sta and changes.sta ~= 0) then
		------- Formulas -------
		-- sta = floor(sta * staMod)
		-- By testing with the hunter talants: Endurance Training and Survivalist,
		-- I found that the healthMods are mutiplicative instead of additive, this is the same as armor mod
		-- playerHealth = round((baseHealth + addedHealth + addedSta * 10) * healthMod)
		------- Talants -------
		-- Warrior: Vitality (Rank 3) - 3,20
		--          Increases your total Strength and Stamina by 2%/4%/6%
		-- Warrior: Strength of Arms (Rank 2) - 1,22
		--          Increases your total Strength and Stamina by 2%/4%
		-- Warlock: Demonic Embrace (Rank 5) - 2,3
		--          Increases your total Stamina by 2%/4%/6%/8%/10%.
		-- Priest: Enlightenment (Rank 5) - 1,17
		--         Increases your total Stamina and Spirit by 1%/2%/3%/4%/5%
		-- Druid: Bear Form - buff (didn't use stance because Bear Form and Dire Bear Form has the same icon)
		--        Shapeshift into a bear, increasing melee attack power by 30, armor contribution from items by 180%, and stamina by 25%.
		-- Druid: Dire Bear Form - buff
		--        Shapeshift into a dire bear, increasing melee attack power by 120, armor contribution from items by 400%, and stamina by 25%.
		-- Paladin: Sacred Duty (Rank 2) - 2,14
		--          Increases your total Stamina by 3%/6%
		-- Paladin: Combat Expertise (Rank 3) - 2,19
		--          Increases your total Stamina by 2%/4%/6%.
		-- Hunter: Survivalist (Rank 5) - 3,8
		--         Increases your Stamina by 2%/4%/6%/8%/10%.
		-- Death Knight: Veteran of the Third War (Rank 3) - 1,14
		--               Increases your total Strength by 2%/4%/6% and your total Stamina by 1%/2%/3%.
		-- Death Knight: Shadow of Death - 3,13
		--               Increases your total Strength and Stamina by 2%.
		------------------------
		local _, _, bonusSta = UnitStat("player", 3) --WoW api. 3=stamina
		local staMod = StatLogic:GetStatMod("MOD_STA")
		--self:Debug("AlterSourceData() LibStatLogic:GetStatMod(\"MOD_STA\") = "..staMod)

		--20101213 Updated to LibStatLogic1.2, it's returning real values. Hack removed
		--20101117 MOD_STA is temporarily returning 1.0. Let's force it a reasonable paladin default
		--staMod = staMod * 1.05 * 1.15 * 1.05 --Kings 5% * Touched by the Light 15% * Plate specialization 5%
		--self:Debug("AlterSourceData() [temp hack] setting staMod = "..staMod)

		
		--[[this floor/ceil contraption isn't working for a case i found:
				Protection paladin with 15% stamina bonus
					Paperdoll stamina before: 2548
					Equip item with stamina (listed in tooltip): 228
					Paperdoll stamina after: 2811 (increase of 263)
				
				Assume 15% applies to item: 228 * 1.15 = 262.2
				
		--]]
		if (staMod ~= 1.0) then
			changes.sta = max(0, round((ceil(bonusSta / staMod) + changes.sta) * staMod)) - bonusSta --20101213 Changed to ceil, from round, to make example i found work
			self:Debug(string.format("   Adjusting Stamina change to %d because of MOD_STA %.4f", changes.sta, staMod));
		end

		-- Calculate player health
		local healthMod = StatLogic:GetStatMod("MOD_HEALTH")
		--self:Debug("AlterSourceData()[modify stamina] GetStatMod(\"MOD_HEALTH\") = "..healthMod)

	
		local playerHealthWithoutModifiers = round(tpTable.playerHealth / healthMod);
		local healthFromStaminaWithoutModifiers = changes.sta * 10; --We will later reapply the MOD_HEALTH
		
		self:Debug(string.format("   Adding %.2f Health from %.2f Stamina (%d before health modifier of %.4f%%) to existing %d Health",
				healthFromStaminaWithoutModifiers*healthMod, changes.sta, healthFromStaminaWithoutModifiers, healthMod*100, tpTable.playerHealth));
		
		tpTable.playerHealth = round((playerHealthWithoutModifiers + healthFromStaminaWithoutModifiers) * healthMod)
--		self:Print("changes.sta = "..(changes.sta or "0")..", newHealth = "..(tpTable.playerHealth or "0"))
		--self:Debug("AlterSourceData()[modify stamina] Changing stamina by "..(changes.sta or "0")..", newHealth = "..(tpTable.playerHealth or "0"))
	end
	
	if (changes.playerHealth and changes.playerHealth ~= 0) then
		------- Formulas -------
		-- By testing with the hunter talants: Endurance Training and Survivalist,
		-- I found that the healMods are mutiplicative instead of additive, this is the same as armor mod
		-- playerHealth = round((baseHealth + addedHealth + addedSta * 10) * healthMod)
		------- Talants -------
		-- Warlock: Fel Vitality (Rank 3) - 2,6
		--          Increases your maximum health and mana by 1%/2%/3%.
		-- Hunter: Endurance Training (Rank 5) - 1,2
		--         Increases the Health of your pet by 2%/4%/6%/8%/10% and your total health by 1%/2%/3%/4%/5%.
		-- Death Knight: Frost Presence - Stance
		--               Increasing total health by 10%
		------------------------
		local healthMod = StatLogic:GetStatMod("MOD_HEALTH")
		--self:Debug("AlterSourceData()[modify health] GetStatMod(\"MOD_HEALTH\") = "..healthMod)
		
		self:Debug(string.format("   Adding %.2f Health (%.2f before health modifier of %.4f%%) to existing %d Health",
				changes.playerHealth*healthMod, changes.playerHealth, healthMod*100, tpTable.playerHealth));
		
		tpTable.playerHealth = round((round(tpTable.playerHealth / healthMod) + changes.playerHealth) * healthMod)

		--self:Debug("changes.playerHealth = "..(changes.playerHealth or "0")..", newHealth = "..(tpTable.playerHealth or "0"))
	end
	
	if (changes.armorFromItems and changes.armorFromItems ~= 0) or (changes.armor and changes.armor ~= 0) then
		------- Talants -------
		-- Hunter: Thick Hide (Rank 3) - 1,5
		--         Increases the armor rating of your pets by 20% and your armor contribution from items by 4%/7%/10%.
		-- Druid: Thick Hide (Rank 3) - 2,5
		--        Increases your Armor contribution from items by 4%/7%/10%.
		-- Druid: Bear Form - buff (didn't use stance because Bear Form and Dire Bear Form has the same icon)
		--        Shapeshift into a bear, increasing melee attack power by 30, armor contribution from items by 180%, and stamina by 25%.
		-- Druid: Dire Bear Form - buff
		--        Shapeshift into a dire bear, increasing melee attack power by 120, armor contribution from items by 400%, and stamina by 25%.
		-- Druid: Moonkin Form - buff
		--        While in this form the armor contribution from items is increased by 400%, attack power is increased by 150% of your level and all party members within 30 yards have their spell critical chance increased by 5%.
		-- Shaman: Toughness (Rank 5) - 2,11
		--          Increases your armor value from items by 2%/4%/6%/8%/10%.
		-- Warrior: Toughness (Rank 5) - 3,5
		--          Increases your armor value from items by 2%/4%/6%/8%/10%.
		------------------------
		-- Make sure armorFromItems and armor aren't nil
		changes.armorFromItems = changes.armorFromItems or 0
		changes.armor = changes.armor or 0
		local armorMod = StatLogic:GetStatMod("MOD_ARMOR")
		local _, _, _, pos, neg = UnitArmor("player")
		local _, agility = UnitStat("player", 2)
		if changes.agi then
			agility = agility + changes.agi
		end
		-- Armor is treated different then stats, 小數點採四捨五入法
		--local armorFromItem = floor(((tpTable.armor - agility * 2 - pos + neg) / armorMod) + 0.5)
		--tpTable.armor = floor(((armorFromItem + changes.armor) * armorMod) + 0.5) + agility * 2 + pos - neg
		--(floor((ceil(stamina / staMod) + changes.sta) * staMod) - stamina)
		tpTable.armor = 
				round(
					( round((tpTable.armor - agility * 2 - pos + neg) / armorMod) + changes.armorFromItems )*armorMod
				) + agility*2 + pos - neg + changes.armor
		--self:Print(tpTable.armor.." = floor(((floor((("..tpTable.armor.." - "..agility.." * 2 - "..pos.." + "..neg..") / "..armorMod..") + 0.5) + "..changes.armor..") * "..armorMod..") + 0.5) + "..agility.." * 2 + "..pos.." - "..neg)
	end
	
	local doBlock = (forceShield == true) or ((forceShield == nil) and self:ShieldIsEquipped())

	--[[20101018: Defense removed from game
	if changes.defense and changes.defense ~= 0 then
		tpTable.defense = tpTable.defense + changes.defense
		-- tpTable.dodgeChance = tpTable.dodgeChance + changes.defense * 0.0004
		-- if GetParryChance() ~= 0 then
			-- tpTable.parryChance = tpTable.parryChance + changes.defense * 0.0004
		-- end
		-- if doBlock then
			-- tpTable.blockChance = tpTable.blockChance + changes.defense * 0.0004
		-- end
	end
	if changes.defenseRating and changes.defenseRating ~= 0 then
		local defenseChange = floor(StatLogic:GetEffectFromRating(tpTable.defenseRating + changes.defenseRating, CR_DEFENSE_SKILL, tpTable.playerLevel)) - floor(StatLogic:GetEffectFromRating(tpTable.defenseRating, CR_DEFENSE_SKILL, tpTable.playerLevel))
		tpTable.defense = tpTable.defense + defenseChange
		tpTable.defenseRating = tpTable.defenseRating + changes.defenseRating
		tpTable.dodgeChance = tpTable.dodgeChance + StatLogic:GetAvoidanceGainAfterDR("DODGE", defenseChange * 0.04) * 0.01
		if GetParryChance() ~= 0 then
			tpTable.parryChance = tpTable.parryChance + StatLogic:GetAvoidanceGainAfterDR("PARRY", defenseChange * 0.04) * 0.01
		end
		if doBlock then
			tpTable.blockChance = tpTable.blockChance + defenseChange * 0.0004
		end
	end--]]
	
	if (changes.dodgeChance and changes.dodgeChance ~= 0) then
		tpTable.dodgeChance = tpTable.dodgeChance + changes.dodgeChance
	end
	
	if (changes.parryChance and changes.parryChance ~= 0) then
		if GetParryChance() ~= 0 then
			tpTable.parryChance = tpTable.parryChance + changes.parryChance
		end
	end
	
	if changes.blockChance and changes.blockChance ~= 0 then
		--self:Debug("Apply blockChance change "..changes.blockChance);
		if doBlock then
			tpTable.blockChance = tpTable.blockChance + changes.blockChance
		end
	end
	
	--Convert Mastery Rating & Mastery into Block (paladins and warriors)
	--self:Debug("changes.masteryRating="..self:VarAsString(changes.masteryRating));
	if (changes.masteryRating and changes.masteryRating ~= 0) then
		if (not changes.mastery) then --initialize mastery if needed
			changes.mastery = 0;
		end;

		local masteryFromRating = StatLogic:GetEffectFromRating(changes.masteryRating, "MASTERY_RATING", tpTable.playerLevel); --Mastery is not a percentage, or a fraction; it's a number, e.g. 1159 Mastery Rating grants +6.46 Mastery.
				
		self:Debug("   Adding %.4f Mastery (from %d Mastery Rating) to existing %.4f Mastery", masteryFromRating, changes.masteryRating, tpTable.mastery);
			
		changes.mastery = changes.mastery + masteryFromRating;
	end
	
	if (changes.mastery and changes.mastery ~= 0) then
		if (tpTable.playerClass == "WARRIOR") and IsSpellKnown(CLASS_MASTERY_SPELLS[tpTable.playerClass]) and (GetPrimaryTalentTree() == 3) then
			local blockChanceFromMastery = StatLogic:GetEffectFromMastery(changes.mastery, 3, tpTable.playerClass)*0.01;
			self:Debug(string.format("   Adding %.4f%% Block Chance (from %.4f warrior Mastery) to existing %.4f%% Block Chance", blockChanceFromMastery*100, changes.mastery, tpTable.blockChance*100));
			
			tpTable.blockChance = tpTable.blockChance + blockChanceFromMastery;
        elseif (tpTable.playerClass == "PALADIN") and IsSpellKnown(CLASS_MASTERY_SPELLS[tpTable.playerClass]) and (GetPrimaryTalentTree() == 2) then
			local blockChanceFromMastery = StatLogic:GetEffectFromMastery(changes.mastery, 2, tpTable.playerClass)*0.01

			self:Debug(string.format("   Adding %.4f%% Block Chance (from %.4f paladin Mastery) to existing %.4f%% Block Chance)", 
					blockChanceFromMastery*100, changes.mastery, tpTable.blockChance*100));
			
			tpTable.blockChance = tpTable.blockChance + blockChanceFromMastery;
        end	
	end
	
	if changes.resilience and changes.resilience ~= 0 then
		tpTable.resilience = tpTable.resilience + changes.resilience
	end
	if changes.mobLevel and changes.mobLevel ~= 0 then
		tpTable.mobLevel = tpTable.mobLevel + changes.mobLevel
	end
	if changes.mobDamage and changes.mobDamage ~= 0 then
		tpTable.mobDamage = (tpTable.mobDamage or 0) + changes.mobDamage
	end
	if changes.shieldBlockDelay and changes.shieldBlockDelay ~= 0 then
		tpTable.shieldBlockDelay = tpTable.shieldBlockDelay + changes.shieldBlockDelay
	end
	-- debug
	--self:Print("changes.str = "..(changes.str or "0")..", changes.sta = "..(changes.sta or "0"))
end

function TankPoints:CheckSourceData(TP_Table, school, forceShield)
	local result = true
	
	self.noTPReason = "should have TankPoints"
	
	local function cmax(var, maxi)
		if result then
			if nil == TP_Table[var] then
				local msg = var.." is nil"
				self.noTPReason = msg
				--self:Print(msg)
				result = nil
			else
				--self:Print("cmax("..var..")");
				TP_Table[var] = max(maxi, TP_Table[var])
			end
		end
	end
	local function cmax2(var1, var2, maxi)
		if result then
			if nil == TP_Table[var1][var2] then
				local msg = format("TP_Table[%s][%s] is nil", tostring(var1), tostring(var2))
				self.noTPReason = msg
				--self:Print(msg)
				result = nil
			else
				TP_Table[var1][var2] = max(maxi, TP_Table[var1][var2])
			end
		end
	end
	
	-- Check for nil
	-- Fix values that are below minimum
	cmax("playerLevel",1)
	cmax("playerHealth",0)
	cmax("mobLevel",1)
	cmax("resilience",0)
	
	-- Melee
	if (not school) or school == TP_MELEE then
		cmax("mobCritChance",0)
		cmax("mobCritBonus",0)
		cmax("mobMissChance",0)
		cmax("armor",0)
		--cmax("defense",0)
		--cmax("defenseRating",0)
		cmax("dodgeChance",0)
		if GetParryChance() == 0 then
			TP_Table.parryChance = 0
		end
		cmax("parryChance",0)
		if (forceShield == true) or ((forceShield == nil) and self:ShieldIsEquipped()) then
			cmax("blockChance",0)
			--cmax("blockValue",0)
		else
			TP_Table.blockChance = 0
			--TP_Table.blockValue = 0
		end
		--cmax("mobDamage",0)
		cmax2("damageTakenMod",TP_MELEE,0)
		cmax("shieldBlockDelay",0)
	end
	
	-- Spell
	if (not school) or school > TP_MELEE then
		cmax("mobSpellCritChance",0)
		cmax("mobSpellCritBonus",0)
		cmax("mobSpellMissChance",0)
		-- Negative resistances don't work anymore?
		if not school then
			for _,s in ipairs(self.ElementalSchools) do
				cmax2("resistance", s, 0)
				cmax2("damageTakenMod", s, 0)
			end
		else
			cmax2("resistance", school, 0)
			cmax2("damageTakenMod", school, 0)
		end
	end
	
	--force a display of the bad reason
	if (not result) then
		self:Debug("CheckSourceData: Source table is invalid ("..self.noTPReason..")")
	end
	return result
end

local shieldBlockChangesTable = {}

-- sometimes we only need to get TankPoints if there's nothing already there
-- sooooo....
function TankPoints:GetTankPointsIfNotFilled(table, school)
	if not table.effectiveHealth or not table.tankPoints then
		return self:GetTankPoints(table, school)
	else
		if school then
			if table.effectiveHealth[school] and table.tankPoints then
				return table
			else
				return self:GetTankPoints(table, school)
			end
		else
			for _, s in ipairs(self.ElementalSchools) do
				if not table.effectiveHealth[s] or not table.tankPoints[s] then
					return self:GetTankPoints(table, nil)
				end
			end
			return table
		end
	end
end

--local ArdentDefenderRankEffect = {0.07, 0.13, 0.2}  20101017 Removed in patch 4.0.1

-------------------
-- GetBlockedMod --
-------------------
function TankPoints:GetBlockedMod(forceShield)
	--[[
		GetBlockedMod returns the average damage reduction due to a shield.
		
		Arguments
			forceShield: Forces the calculation to assume that a shield is equipped. The default
				behaviour is to check if the player has a shield equipped.
				If the player has no shield equipped then GetBlockdMod returns zero (since nothing can be blocked)

		Returns
			The amount of damage blocked by a shield
			
			e.g. Warrior: 30%
			     Warriorreduction due to blocking attacks. For example: 
			
			A block chance of 36%, with paladin's shield blocking 40% of the damage the shield reduces damage by 14.4%. (36% * 40% = 14.4%)
	--]]

	if (not self:ShieldIsEquipped()) and (forceShield ~= true) then -- doesn't have shield equipped
		return 0
	end

	local result = 0.30; --by default all blocked attacks block a flat 30% of incoming damage
		
	if self.playerClass == "WARRIOR" and select(5, GetTalentInfo(3, 24)) > 0 then
		-- Warrior Talent: Critical Block (Rank 3) - 3,24
		--  Your successful blocks have a 20/40/60% chance to block double the normal amount
		local critBlock = 1 + select(5, GetTalentInfo(3, 24)) * 0.2
		result = result * critBlock
	elseif (self.playerClass == "PALADIN") then
		-- Paladin Talent: Holy Shield - 2,15
		-- 	Shield blocks for an additional 10% for 20 sec.
		local holyShieldTalentRank = select(5, GetTalentInfo(2, 15));

		--self:Debug("GetBlockedMod: Paladin has "..holyShieldTalentRank.." points in Holy Shield");
		if (holyShieldTalentRank > 0) then
			result = 0.40
		end;
	end;
	
	return result
end;


function TankPoints:CalculateTankPoints(TP_Table, school, forceShield)
	--Called by GetTankPoints(...)

	------------------
	-- Check Inputs --
	------------------
	if not self:CheckSourceData(TP_Table, school, forceShield) then return end

	-----------------
	-- Caculations --
	-----------------
	--[[
		Paldin Talent: Ardent Defender
			Reduces all damage by 20% for 10 seconds, with a 3 minute cooldown.
			We model this as a health increase of 1.01111% (1 + 0.2*(10s/180s))
	--]]
	if self.playerClass == "PALADIN" then
		--[[
			Ardent Defender is on talent page 2, 20

			Pre-patch 4.0.1
				Paladin Talent: Ardent Defender (Rank 3) - 2,18
				Damage that takes you below 35% health is reduced by 7/13/20%

				Note: Ardent Defender used to be page 2, talent 18 (i.e. GetTalentInfo(2,18))
		--]]
		local _, _, _, _, r = GetTalentInfo(2, 20) --page 2, talent 20

		--self:Debug("Ardent Defender points = "..r)

		local forceArdentDefender = false
		if (r > 0) or (forceArdentDefender) then
			--local inc = 0.35 / (1 - ArdentDefenderRankEffect[r]) - 0.35 -- 8.75% @ rank3    20101017: Old model, when ardent defender was passive
			local inc = round(TP_Table.playerHealth * ARDENT_DEFENDER_DAMAGE_REDUCTION * (10/180)); --20% increase for some fraction of the time

			TP_Table.playerHealth = TP_Table.playerHealth + inc

			--self:Debug("TankPoints:CalculateTankPoints(): Applied Ardent Defender health effective increase of "..inc..". New health = "..TP_Table.playerHealth)
		end
	end
	
	-- Resilience Mod
	TP_Table.resilienceEffect = StatLogic:GetEffectFromRating(TP_Table.resilience, COMBAT_RATING_RESILIENCE_CRIT_TAKEN, TP_Table.playerLevel) * 0.01;  --GetEffectFromRating returns as percentage rather than fraction (GRRRRRRRR!)
	if (not school) or school == TP_MELEE then
		-- Armor Reduction
		TP_Table.armorReduction = self:GetArmorReduction(TP_Table.armor, TP_Table.mobLevel)
		
		-- Defense Mod (may return negative)
		--self:Debug("TP_Table.defense = "..TP_Table.defense)
		
		--local defenseFromDefenseRating = floor(StatLogic:GetEffectFromRating(TP_Table.defenseRating, CR_DEFENSE_SKILL))
		--self:Debug("defenseFromDefenseRating = "..defenseFromDefenseRating)
		
		--local drFreeDefense = TP_Table.defense - defenseFromDefenseRating - TP_Table.mobLevel * 5 -- negative for mobs higher level then player
		--self:Debug("drFreeDefense = "..drFreeDefense)
		local drFreeAvoidance = 0; --drFreeDefense * 0.0004
		
		-- Mob's Crit, Miss
		--self:Debug("todo: figure out how levels affect a mob's crit chance")
		--TP_Table.mobCritChance = max(0, TP_Table.mobCritChance - (TP_Table.defense - TP_Table.mobLevel * 5) * 0.0004 - TP_Table.resilienceEffect + StatLogic:GetStatMod("ADD_CRIT_TAKEN", "MELEE"))
		TP_Table.mobCritChance = max(0, TP_Table.mobCritChance + StatLogic:GetStatMod("ADD_CRIT_TAKEN", "MELEE"))
		
		--local bonusDefense = TP_Table.defense - TP_Table.playerLevel * 5
		
		--self:Debug("before miss chance calc. mobMissChance = "..TP_Table.mobMissChance)
--		self:Debug("drFreeAvoidance = "..drFreeAvoidance)
		
		--self:Debug("todo: figure out what affects a mob's miss chance")
		--TP_Table.mobMissChance = max(0, TP_Table.mobMissChance + drFreeAvoidance + StatLogic:GetAvoidanceAfterDR("MELEE_HIT_AVOID", defenseFromDefenseRating * 0.04) * 0.01)
--		self:Debug("after miss chance calc. TP_Table.mobMissChance = "..TP_Table.mobMissChance)
		
		
		-- Dodge, Parry, Block
		TP_Table.dodgeChance = max(0, TP_Table.dodgeChance + drFreeAvoidance)
		TP_Table.parryChance = max(0, TP_Table.parryChance + drFreeAvoidance)
		
		-- Block Chance, Block Value
		-- Check if player has shield or forceShield is set to true
		if (forceShield == true) or ((forceShield == nil) and self:ShieldIsEquipped()) then
			TP_Table.blockChance = max(0, TP_Table.blockChance + drFreeAvoidance)
		else
			TP_Table.blockChance = 0
		end
		
		-- Crushing Blow Chance
		TP_Table.mobCrushChance = 0
		if (TP_Table.mobLevel - TP_Table.playerLevel) > 3 then -- if mob is 4 levels or above crushing blow will happen
			-- The chance is 10% per level difference minus 15%
			TP_Table.mobCrushChance = (TP_Table.mobLevel - TP_Table.playerLevel) * 0.1 - 0.15
		end
		
		-- Mob's Crit Damage Mod
		TP_Table.mobCritDamageMod = max(0, 1 - TP_Table.resilienceEffect * 2)
		
		--Get the percentage of an attack that is blocked, if it is blocked
		TP_Table.blockedMod = self:GetBlockedMod(forceShield);
	end
	if (not school) or school > TP_MELEE then
		-- Mob's Spell Crit
		TP_Table.mobSpellCritChance = max(0, TP_Table.mobSpellCritChance - TP_Table.resilienceEffect + StatLogic:GetStatMod("ADD_CRIT_TAKEN", "HOLY"))
		-- Mob's Spell Crit Damage Mod
		TP_Table.mobSpellCritDamageMod = max(0, 1 - TP_Table.resilienceEffect * 2)
	end
	---------------------
	-- High caps check --
	---------------------
	if (not school) or school == TP_MELEE then
		-- Hit < Crushing < Crit < Block < Parry < Dodge < Miss
		local combatTable = {}
		-- build total sums
		local total = TP_Table.mobMissChance
		tinsert(combatTable, total)
		total = total + TP_Table.dodgeChance
		tinsert(combatTable, total)
		total = total + TP_Table.parryChance
		tinsert(combatTable, total)
		total = total + TP_Table.blockChance
		tinsert(combatTable, total)
		total = total + TP_Table.mobCritChance
		tinsert(combatTable, total)
		total = total + TP_Table.mobCrushChance
		tinsert(combatTable, total)
		-- check caps
		if combatTable[1] > 1 then
			TP_Table.mobMissChance = 1
		end
		if combatTable[2] > 1 then
			TP_Table.dodgeChance = max(0, 1 - combatTable[1])
		end
		if combatTable[3] > 1 then
			TP_Table.parryChance = max(0, 1 - combatTable[2])
		end
		if combatTable[4] > 1 then
			TP_Table.blockChance = max(0, 1 - combatTable[3])
		end
		if combatTable[5] > 1 then
			TP_Table.mobCritChance = max(0, 1 - combatTable[4])
		end
		if combatTable[6] > 1 then
			TP_Table.mobCrushChance = max(0, 1 - combatTable[5])
		end
		-- Regular Hit Chance (non-crush, non-crit)
		TP_Table.mobHitChance = 1 - (TP_Table.mobCrushChance + TP_Table.mobCritChance + TP_Table.blockChance + TP_Table.parryChance + TP_Table.dodgeChance + TP_Table.mobMissChance)
		-- Chance mob will make contact with you that is not blocked/dodged/parried
		TP_Table.mobContactChance = TP_Table.mobHitChance + TP_Table.mobCrushChance + TP_Table.mobCritChance
	end
	if (not school) or school > TP_MELEE then
		-- Hit < Crit < Miss
		local combatTable = {}
		-- build total sums
		local total = TP_Table.mobSpellMissChance
		tinsert(combatTable, total)
		total = total + TP_Table.mobSpellCritChance
		tinsert(combatTable, total)
		-- check caps
		if combatTable[1] > 1 then
			TP_Table.mobSpellMissChance = 1
		end
		if combatTable[2] > 1 then
			TP_Table.mobSpellCritChance = max(0, 1 - combatTable[1])
		end
	end

	--self:Debug("TankPoints:CalculateTankPoints(): "..TP_Table.mobMissChance, TP_Table.dodgeChance, TP_Table.parryChance, TP_Table.blockChance, TP_Table.mobCritChance, TP_Table.mobCrushChance)
	
	------------------------
	-- Final Calculations --
	------------------------
	if type(TP_Table.schoolReduction) ~= "table" then
		TP_Table.schoolReduction = {}
	end
	if type(TP_Table.totalReduction) ~= "table" then
		TP_Table.totalReduction = {}
	end
	if type(TP_Table.tankPoints) ~= "table" then
		TP_Table.tankPoints = {}
	end
	if type(TP_Table.effectiveHealth) ~= "table" then
		TP_Table.effectiveHealth = {}
	end
	if type(TP_Table.effectiveHealthWithBlock) ~= "table" then
		TP_Table.effectiveHealthWithBlock = {}
	end
	if type(TP_Table.guaranteedReduction) ~= "table" then
		TP_Table.guaranteedReduction = {}
	end
	
	local function calc_melee()
		-- School Reduction
		TP_Table.schoolReduction[TP_MELEE] = TP_Table.armorReduction
		
		
		-- Total Reduction 
		TP_Table.totalReduction[TP_MELEE] = 1 - 
			(
				--this is the heart of the combat table
				1 
				- TP_Table.mobMissChance
				- TP_Table.dodgeChance 
				- TP_Table.parryChance 
				- TP_Table.blockChance * TP_Table.blockedMod 
				+ (TP_Table.mobCritChance * TP_Table.mobCritBonus * TP_Table.mobCritDamageMod)
				+ (TP_Table.mobCrushChance * 0.5)
			) * (1 - TP_Table.armorReduction) * TP_Table.damageTakenMod[TP_MELEE]
		-- TankPoints
		TP_Table.tankPoints[TP_MELEE] = TP_Table.playerHealth / (1 - TP_Table.totalReduction[TP_MELEE])
		-- Guaranteed Reduction
		TP_Table.guaranteedReduction[TP_MELEE] = 1 - ((1 - TP_Table.armorReduction) * TP_Table.damageTakenMod[TP_MELEE])
		-- Effective Health
		TP_Table.effectiveHealth[TP_MELEE] = TP_Table.playerHealth / (1 - TP_Table.guaranteedReduction[TP_MELEE])
		-- Effective Health with Block
		TP_Table.effectiveHealthWithBlock[TP_MELEE] = self:GetEffectiveHealthWithBlock(TP_Table, TP_Table.mobDamage or 0)
	end
	local function calc_spell_school(s)
		-- Resistance Reduction = 0.75 (resistance / (mobLevel * 5))
		TP_Table.schoolReduction[s] = 0.75 * (TP_Table.resistance[s] / (max(TP_Table.mobLevel, 20) * 5))
		-- Total Reduction
		TP_Table.totalReduction[s] = 1 - (1 - TP_Table.mobSpellMissChance + (TP_Table.mobSpellCritChance * TP_Table.mobSpellCritBonus * TP_Table.mobSpellCritDamageMod)) * (1 - TP_Table.schoolReduction[s]) * TP_Table.damageTakenMod[s]
		TP_Table.guaranteedReduction[s] = 1-((1 - TP_Table.schoolReduction[s]) * TP_Table.damageTakenMod[s])
		TP_Table.effectiveHealth[s] = TP_Table.playerHealth / (1 - TP_Table.guaranteedReduction[s])
		-- TankPoints
		TP_Table.tankPoints[s] = TP_Table.playerHealth / (1 - TP_Table.totalReduction[s])
	end
	
	--self:Debug("TankPoints:CalculateTankPoints: Preparing final calculations.")
	
	if not school then
		calc_melee()
		for _,s in ipairs(self.ElementalSchools) do
			calc_spell_school(s)
		end
	else
		if school == TP_MELEE then
			calc_melee()
		else
			calc_spell_school(school)
		end
	end
	
--	if (TP_Table.tankPoints == nil) then
		--self:Debug("TankPoints:CalcualteTankPoints: TP_Table.tankPoints is not assigned")
	--end
	
	return TP_Table
end

function TankPoints:GetTankPoints(TP_Table, school, forceShield)

	--self:Debug("TankPoints:GetTankPoints(...)");

	-----------------
	-- Aquire Data --
	-----------------
	-- Set true if temp table is created
	local tempTableFlag
	if not TP_Table then
		self:Debug("TankPoints:GetTankPoints(): Passed TP_Table is nil, constructing local copy")
		tempTableFlag = true
		-- Fill table with player values
		TP_Table = self:GetSourceData(nil, school)
	end
	
	------------------
	-- Check Inputs --
	------------------
	if (not self:CheckSourceData(TP_Table, school, forceShield)) then 
		self:Debug("TankPoints:GetTankPoints: CheckSourceData failed ("..self.noTPReason.."). Returning pre-maturely")
		return 
	end

	-----------------
	-- Caculations --
	-----------------
	-- Warrior Skill: Shield Block - 1 min cooldown
	-- 	Increases your chance to block and block value by 100% for 10 sec.
	-- Warrior Talent: Shield Mastery (Rank 2) - 3,8
	--	Increases your block value by 15%/30% and reduces the cooldown of your Shield Block ability by 10/20 sec.
	-- GetSpellInfo(2565) = "Shield Block"
	if self.playerClass == "WARRIOR" and (not school or school == TP_MELEE) and not UnitBuff("player", SI["Shield Block"]) then
		-- Get a copy for Shield Block skill calculations
		local inputCopy = {}
		copyTable(inputCopy, TP_Table)
		-- Build shieldBlockChangesTable
		shieldBlockChangesTable.blockChance = 1 -- 100%
		shieldBlockChangesTable.blockValue = 0 --inputCopy.blockValue -- +100%
		-- Calculate TankPoints assuming shield block is always up
		self:AlterSourceData(inputCopy, shieldBlockChangesTable, forceShield)
		self:CalculateTankPoints(inputCopy, TP_MELEE, forceShield)
		self:CalculateTankPoints(TP_Table, school, forceShield)
		-- Calculate Shield Block up time
		local _, _, _, _, r = GetTalentInfo(3, 8)
		local shieldBlockCoolDown = 60 - r * 10
		local shieldBlockUpTime = 10 / (shieldBlockCoolDown + inputCopy.shieldBlockDelay)
		TP_Table.totalReduction[TP_MELEE] = TP_Table.totalReduction[TP_MELEE] * (1 - shieldBlockUpTime) + inputCopy.totalReduction[TP_MELEE] * shieldBlockUpTime
		TP_Table.tankPoints[TP_MELEE] = TP_Table.tankPoints[TP_MELEE] * (1 - shieldBlockUpTime) + inputCopy.tankPoints[TP_MELEE] * shieldBlockUpTime
		TP_Table.shieldBlockUpTime = shieldBlockUpTime
		inputCopy = nil

	-- Paladin Talent: Holy Shield - 2,15
	-- 	Shield blocks for an additional 10% for 20 sec.
	elseif (self.playerClass == "PALADIN") and (select(5, GetTalentInfo(2, 15)) > 0)
			and (not school or school == TP_MELEE) and not UnitBuff("player", SI["Holy Shield"]) then

		--self:Debug("TankPoints:GetTankPoints: Player is a paladin who has Holy Shield talent, but it's not active. Increasing block by 10%")
		--normally all blocked attacks are reduced by a fixed 30%. Holy shield increases the blocked amount by 10%

		--Assume 100% uptime on Holy Shield
		
		--self:Debug("TankPoints:GetTankPoints: Calling paladin version of TankPoints:CalculateTankPoints")
		self:CalculateTankPoints(TP_Table, school, forceShield)
	else
		--self:Debug("TankPoints:GetTankPoints: Player is someone who doesn't need to have a block ability manually added")
		self:CalculateTankPoints(TP_Table, school, forceShield)
	end
	
	-------------
	-- Cleanup --
	-------------
	if tempTableFlag then
		local tankPoints, totalReduction, schoolReduction = TP_Table.tankPoints[school or TP_MELEE], TP_Table.totalReduction[school or TP_MELEE], TP_Table.schoolReduction[school or TP_MELEE]
		TP_Table = nil
		return tankPoints, totalReduction, schoolReduction
	end
	return TP_Table
end

function TankPoints:IntToStr(value)
	local s = tostring(value)
	local length = strlen(s)
	if length < 4 then
		return s
	elseif length < 7 then
		return (gsub(s, "^([+-]?%d%d?%d?)(%d%d%d)$", "%1,%2", 1))
	elseif length < 10 then
		return (gsub(s, "^([+-]?%d%d?%d?)(%d%d%d)(%d%d%d)$", "%1,%2,%3", 1))
	else
		return s
	end
end

function TankPoints:DumpTableRaw(tpTable)

	if not (tpTable) then
		self:Print("TankPoints table is empty");
		return;
	end

	self:Print(self:VarAsString(tpTable));
end;


function TankPoints:DumpTable(tpTable)

--	self:UpdateDataTable();

	if not (tpTable) then
		self:Print("TankPoints table is empty");
		return;
	end

	--self:Print(self:VarAsString(tpTable));
	
	--see UpdateDataTable for TP clculation
	
	local function IntToStr(value)
		return self:IntToStr(value)
	end;
	
	local function PercentToStr(value)
		value = tonumber(value);
		if (value == nil) then
			value = 0;
		end;
			
		return string.format("%.4f%%", value*100)
	end;
	
	self:Print("TankPoints table:");
	self:Print("   playerHealth: "..IntToStr(tpTable.playerHealth));
	self:Print("   playerLevel: "..IntToStr(tpTable.playerLevel));
	self:Print("   mobLevel: "..IntToStr(tpTable.mobLevel));
	self:Print("   armor: "..IntToStr(tpTable.armor));
	self:Print("   mobMissChance: "..PercentToStr(tpTable.mobMissChance));
	self:Print("   dodgeChance: "..PercentToStr(tpTable.dodgeChance));
	self:Print("   parryChance: "..PercentToStr(tpTable.parryChance));
	self:Print("   blockChance: "..PercentToStr(tpTable.blockChance));
	self:Print(string.format("   mastery: %.2f", tpTable.mastery)); --Mastery isn't a percentage, it's a real number, e.g. 14.46
	self:Print("   mobCritChance: "..PercentToStr(tpTable.mobCritChance));
	self:Print("   mobCritBonus: "..PercentToStr(tpTable.mobCritBonus));
	self:Print("   mobCritDamageMod: "..PercentToStr(tpTable.mobCritDamageMod));
	self:Print("   mobCrushChance: "..PercentToStr(tpTable.mobCrushChance));
	self:Print("   armorReduction: "..PercentToStr(tpTable.armorReduction));
	self:Print("   blockedMod: "..PercentToStr(tpTable.blockedMod));
	self:Print("   mobHitChance: "..PercentToStr(tpTable.mobHitChance));
	self:Print("   mobContactChance: "..PercentToStr(tpTable.mobContactChance));
	self:Print("   guaranteedReduction: "..PercentToStr(tpTable.guaranteedReduction[TP_MELEE]));
	self:Print("   effectiveHealth: "..IntToStr(tpTable.effectiveHealth[TP_MELEE]));
	self:Print("   effectiveHealthWithBlock: "..IntToStr(tpTable.effectiveHealthWithBlock[TP_MELEE]));
	self:Print("   totalReduction: "..PercentToStr(tpTable.totalReduction[TP_MELEE]));
	self:Print("   tankPoints: "..IntToStr(tpTable.tankPoints[TP_MELEE]));

end;


---------------------------------------------------------
-- Toggle the TankPoints calculator, if it's available --
---------------------------------------------------------
function TankPoints:ToggleCalculator()
	local tpc = TankPointsCalculatorFrame;
	if (tpc) then
		if(tpc:IsVisible()) then
			tpc:Hide()
		else
			tpc:Show()
		end
		self:UpdateStats()
	end
end;								

