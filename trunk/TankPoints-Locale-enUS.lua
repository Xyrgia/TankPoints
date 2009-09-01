-- -*- indent-tabs-mode: t; tab-width: 4; lua-indent-level: 4 -*-
--[[
Name: TankPoints enUS locale
Revision: $Revision$
Translated by: 
- Whitetooth@Cenarius (hotdogee@bahamut.twbbs.org)
]]
-- Global Strings that don't need translations
--[[
PLAYERSTAT_MELEE_COMBAT = "Melee"
SPELL_SCHOOL0_CAP = "Physical"
SPELL_SCHOOL0_NAME = "physical"
SPELL_SCHOOL1_CAP = "Holy"
SPELL_SCHOOL1_NAME = "holy"
SPELL_SCHOOL2_CAP = "Fire"
SPELL_SCHOOL2_NAME = "fire"
SPELL_SCHOOL3_CAP = "Nature"
SPELL_SCHOOL3_NAME = "nature"
SPELL_SCHOOL4_CAP = "Frost"
SPELL_SCHOOL4_NAME = "frost"
SPELL_SCHOOL5_CAP = "Shadow"
SPELL_SCHOOL5_NAME = "shadow"
SPELL_SCHOOL6_CAP = "Arcane"
SPELL_SCHOOL6_NAME = "arcane"
SPELL_STAT1_NAME = "Strength"
SPELL_STAT2_NAME = "Agility"
SPELL_STAT3_NAME = "Stamina"
SPELL_STAT4_NAME = "Intellect"
SPELL_STAT5_NAME = "Spirit"
COMBAT_RATING_NAME1 = "Weapon Skill"
COMBAT_RATING_NAME2 = "Defense Rating"
COMBAT_RATING_NAME3 = "Dodge Rating"
COMBAT_RATING_NAME4 = "Parry Rating"
COMBAT_RATING_NAME5 = "Block Rating"
COMBAT_RATING_NAME6 = "Hit Rating"
COMBAT_RATING_NAME7 = "Hit Rating" -- Ranged hit rating
COMBAT_RATING_NAME8 = "Hit Rating" -- Spell hit rating
COMBAT_RATING_NAME9 = "Crit Rating" -- Melee crit rating
COMBAT_RATING_NAME10 = "Crit Rating" -- Ranged crit rating
COMBAT_RATING_NAME11 = "Crit Rating" -- Spell Crit Rating
COMBAT_RATING_NAME15 = "Resilience"
ARMOR = "Armor"
DEFENSE = "Defense"
DODGE = "Dodge"
PARRY = "Parry"
BLOCK = "Block"
--]]

TP_STR = 1
TP_AGI = 2
TP_STA = 3
TP_HEALTH = 4
TP_ARMOR = 5
TP_DEFENSE = 6
TP_DODGE = 7
TP_PARRY = 8
TP_BLOCK = 9
TP_BLOCKVALUE = 10
TP_RESILIENCE = 11

local L = AceLibrary("AceLocale-2.2"):new("TankPoints")
-- To translate AceLocale strings, replace true with the translation string
-- Before: ["Show Item ID"] = true,
-- After:  ["Show Item ID"] = "顯示物品編號",
L:RegisterTranslations("enUS", function() return {
	-------------
	-- General --
	-------------
	["TankPoints"] = true,
	["EH"] = true, -- "Effective Health" is a long phrase
	["EHB"] = true, -- "Effective Health with Block" is a very long phrase
	["Block Value"] = true,
	--------------------
	-- Character Info --
	--------------------
	-- Stats
	["EH Block"] = true,
	[" EH"] = true,
	[" TP"] = true, -- concatenated after a school name for Spell TankPoints, ex: "Nature TP"
	[" DR"] = true, -- concatenated after a school name for Damage Reductions, ex: "Nature DR"
	-- TankPoints Stat Tooltip
	["In "] = true, -- concatenated before stance name, ex: "In Battle Stance"
	["Mob Stats"] = true,
	["Mob Level"] = true,
	["Mob Damage"] = true,
	["Mob Crit"] = true,
	["Mob Miss"] = true,
	["Per StatValue"] = true,
	["Per Stat"] = true,
	["Click: show Per StatValue TankPoints"] = true,
	["Click: show Per Stat TankPoints"] = true,
	-- Melee Reduction Tooltip
	[" Damage Reduction"] = true, -- concatenated after a school name for Damage Reductions, ex: "Nature Damage Reduction"
	["Player Level"] = true,
	["Combat Table"] = true,
	["Crit"] = true,
	["Crushing"] = true,
	["Hit"] = true,
	["Avoidance Diminishing Returns"] = true,
	["Only includes Dodge, Parry, and Missed"] = true,
	-- Block Value Tooltip
	["Mob Damage before DR"] = true,
	["Mob Damage after DR"] = true,
	["Blocked Percentage"] = true,
	["Equivalent Block Mitigation"] = true,
	["Shield Block Up Time"] = true,
	-- Spell TankPoints Tooltip
	["Melee/Spell Damage Ratio"] = true,
	["Left click: Show next school"] = true,
	["Right click: Show strongest school"] = true,
	[" resist "] = true,
	-- Spell Reduction Tooltip
	-- Toggle Calculator
	["Open Calculator"] = true,
	["Close Calculator"] = true,
	-- talent names
	["imp. Shield Block"] = true, -- short for Improved Shield Block
	-- Effective Health stuff
	["Effective Health"] = true,
	["Effective Health vs %s %s"] = true, -- Melee/Nature/Fire followed by EH
	["Effective Health (with Block) vs Melee "] = true, -- followed by EHB
	["Effective Health with Block"] = "Effective Health w/ Block",
	["Effective Health - All Schools"] = true, -- heading for the all schools of damage tooltip
	["Health"] = true, -- player health
	["Armor Reduction"] = true, -- how much armor reduces damage
	["Resistance Reduction"] = true, -- reduction due to elemental resist (nature, etc)
	["Talent/Buff/Stance Reductions"] = true, -- things like stances, talents
	["Your Reductions"] = true, -- section header
	["Guaranteed Reduction"] = true, -- how much damage you're guaranteed to mitigate
	["Mob attacks can critically hit"] = true,
	["Mob attacks cannot critically hit"] = true,
	["Mob attacks will crush"] = true,
	["Mob attacks should not crush"] = true,
	-- an array with lines to be put at the bottom of the Effective Health Tooltip
	-- saying what EH is
	["TP_EXPLANATION"] = {"TankPoints is a measure of your theoretical", "mitigation (dodge, parry, etc) in proportion", "to your health."},
	["EH_EXPLANATION"] = {"Effective Health is how much raw", "damage you can take without", "a miss/block/dodge/parry."},
	["EHB_EXPLANATION"] = {"Effective Health with Block is how much raw", "damage you can take without a miss/dodge/parry", "and only guaranteed blocks. Dependant", "on mob stats and you being able to block."},
	["See /tp optionswin to turn on tooltip."] = true,
        
	---------------------------
	-- Slash Command Options --
	---------------------------
	-- /tp optionswin
	["Options Window"] = true,
	["Shows the Options Window"] = true,
	-- /tp calc
	["TankPoints Calculator"] = true,
	["Shows the TankPoints Calculator"] = true,
	-- /tp tooltip
	["Tooltip Options"] = true,
	["TankPoints tooltip options"] = true,
	-- /tp tooltip diff
	["Show TankPoints Difference"] = true,
	["Show TankPoints difference in item tooltips"] = true,
	-- /tp tooltip total
	["Show TankPoints Total"] = true,
	["Show TankPoints total in item tooltips"] = true,
	-- /tp tooltip drdiff
	["Show Melee DR Difference"] = true,
	["Show Melee Damage Reduction difference in item tooltips"] = true,
	-- /tp tooltip drtotal
	["Show Melee DR Total"] = true,
	["Show Melee Damage Reduction total in item tooltips"] = true,
	-- /tp tooltip ehdiff
	["Show Effective Health Difference"] = true,
	["Show Effective Health difference in item tooltips"] = true,
	-- /tp tooltip ehtotal
	["Show Effective Health Total"] = true,
	["Show Effective Health total in item tooltips"] = true,
	-- /tp tooltip ehbdiff
	["Show Effective Health (with Block) Difference"] = true,
	["Show Effective Health (with Block) difference in item tooltips"] = true,
	-- /tp tooltip ehbtotal
	["Show Effective Health (with Block) Total"] = true,
	["Show Effective Health (with Block) total in item tooltips"] = true,
	-- /tp player
	["Player Stats"] = true,
	["Change default player stats"] = true,
	-- /tp player sbfreq
	["Shield Block Key Press Delay"] = true,
	["Sets the time in seconds after Shield Block finishes cooldown"] = true,
	-- /tp mob
	["Mob Stats"] = true,
	["Change default mob stats"] = true,
	-- /tp mob level
	["Mob Level"] = true,
	["Sets the level difference between the mob and you"] = true,
	-- /tp mob damage
	-- /tp mob drdamage
	["Mob Damage"] = true,
	["Sets mob's damage before damage reduction"] = true,
	["Sets mob's damage after melee damage reduction"] = true,
	-- /tp mob speed
	["Mob Attack Speed"] = true,
	["Sets mob's attack speed"] = true,
	-- /tp mob default
	["Restore Default"] = true,
	["Restores default mob stats"] = true,
	["Restored Mob Stats Defaults"] = true, -- command feedback
	-- /tp mob advanced
	["Mob Stats Advanced Settings"] = true,
	["Change advanced mob stats"] = true,
	-- /tp mob advanced crit
	["Mob Melee Crit"] = true,
	["Sets mob's melee crit chance"] = true,
	-- /tp mob advanced critbonus
	["Mob Melee Crit Bonus"] = true,
	["Sets mob's melee crit bonus"] = true,
	-- /tp mob advanced miss
	["Mob Melee Miss"] = true,
	["Sets mob's melee miss chance"] = true,
	-- /tp mob advanced spellcrit
	["Mob Spell Crit"] = true,
	["Sets mob's spell crit chance"] = true,
	-- /tp mob advanced spellcritbonus
	["Mob Spell Crit Bonus"] = true,
	["Sets mob's spell crit bonus"] = true,
	-- /tp mob advanced spellmiss
	["Mob Spell Miss"] = true,
	["Sets mob's spell miss chance"] = true,
	----------------------
	-- GetDodgePerAgi() --
	----------------------
	["Cat Form"] = true,
	---------------------------
	-- GetTalantBuffEffect() --
	---------------------------
	["Soul Link"] = true,
	["Voidwalker"] = true,
	["Righteous Fury"] = true,
	["Pain Suppression"] = true,
	["Shield Wall"] = true,
	["Death Wish"] = true,
	["Recklessness"] = true,
	["Cloak of Shadows"] = true,
	----------------------
	-- AlterSourceData() --
	----------------------
	["Bear Form"] = true,
	["Dire Bear Form"] = true,
	["Moonkin Form"] = true,
	-----------------------
	-- PlayerHasShield() --
	-----------------------
	["Shields"] = true,
	---------------------
	-- GetBlockValue() --
	---------------------
	["^(%d+) Block$"] = true,
	------------------------
	-- Item Scan Patterns --
	------------------------
	["ItemScan"] = {
		[TP_BLOCKVALUE] = {
			{"Increases the block value of your shield by (%d+)"},
			{"%+(%d+) Block Value"},
		}
	},
	---------------------------
	-- TankPoints Calculator --
	---------------------------
	-- Title
	["TankPoints Calculator"] = true,
	["Left click to drag\nRight click to reset position"] = true,
	-- Buttons
	["Reset"] = true,
	["Close"] = true,
	-- Option frame box title
	["Results"] = true,
	["Player Stats"] = true,
	["Total Reduction"] = true,
	["(%)"] = true,
	["Max Health"] = true,
	["Items"] = true,
	-------------------------
	-- TankPoints Tooltips --
	-------------------------
	[" (Top/Bottom):"] = true,
	[" (Main/Off):"] = true,
	[" (Main+Off):"] = true,
	["Gems"] = true,
	---------------
	-- Waterfall --
	---------------
	["TankPoints Options"] = true,	
} end)