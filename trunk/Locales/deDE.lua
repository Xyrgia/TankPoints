-- -*- indent-tabs-mode: t; tab-width: 4; lua-indent-level: 4 -*-
--[[
Name: TankPoints deDE locale
Revision: $Revision: 50 $
Translated by: 
- AbbedieD
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
L:RegisterTranslations("deDE", function() return {
	-------------
	-- General --
	-------------
	--["TankPoints"] = true,
	["Block Value"] = "Blockwert",
	--------------------
	-- Character Info --
	--------------------
	-- Stats
	--[" TP"] = true, -- concatenated after a school name for Spell TankPoints, ex: "Nature TP"
	[" DR"] = " SR", -- concatenated after a school name for Damage Reductions, ex: "Nature DR"
	-- TankPoints Stat Tooltip
	--["In "] = true, -- concatenated before stance name, ex: "In Battle Stance"
	--["Mob Stats"] = true,
	--["Mob Level"] = true,
	["Mob Damage"] = "Mob Schaden",
	["Mob Crit"] = "Mob kritisch",
	["Mob Miss"] = "Mob verfehlt",
	--["Per StatValue"] = true,
	--["Per Stat"] = true,
        --["Click: show Per StatValue TankPoints"] = true,
        --["Click: show Per Stat TankPoints"] = true,

	-- Melee Reduction Tooltip
	[" Damage Reduction"] = " Schadensreduzierung", -- concatenated after a school name for Damage Reductions, ex: "Nature Damage Reduction"
	["Player Level"] = "Spieler Level",
	["Combat Table"] = "Kampftabelle",
	["Crit"] = "Kritisch",
	["Crushing"] = "Schmetternd",
	["Hit"] = "Treffer",
	-- Block Value Tooltip
	["Mob Damage before DR"] = "Mob Schaden vor SR",
	["Mob Damage after DR"] = "Mob Schaden nach SR",
	["Blocked Percentage"] = "Prozentual geblockt",
	--["Equivalent Block Mitigation"] = true,
	-- Spell TankPoints Tooltip
	["Melee/Spell Damage Ratio"] = "Nahkampf-/Zauberschadensverhältnis",
	["Left click: Show next school"] = "Linksklick: Zeige nächste Magieschule",
	["Right click: Show strongest school"] = "Rechtsklick: Zeige stärkste Magieschule",
	-- Spell Reduction Tooltip
	-- Toggle Calculator
	["Open Calculator"] = "\195\150ffne Rechner",
	["Close Calculator"] = "Schliesse Rechner",
	---------------------------
	-- Slash Command Options --
	---------------------------
	-- /tp calc
	["TankPoints Calculator"] = "TankPoints Rechner",
	["Shows the TankPoints Calculator"] = "Zeigt den TankPoints Rechner an",
	-- /tp mob
	--["Mob Stats"] = true,
	["Change default mob stats"] = "\195\132ndern der Standard Mob Stats",
	-- /tp mob level
	--["Mob Level"] = true,
	["Sets the level difference between the mob and you"] = "Setzt den Levelunterschied zwischen dem Mob und dir",
	-- /tp mob damage
	["Mob Damage"] = "Mob Schaden",
	["Sets mob's damage before damage reduction"] = "Schaden des Mobs vor der Schadensreduzierung \195\164ndern",
	-- /tp mob default
	["Restore Default"] = "Standard wiederherstellen",
	["Restores default mob stats"] = "Stellt die Standard Mob Stats wieder her",
	["Restored Mob Stats Defaults"] = "Mob Standard Stats wiederhergestellt", -- command feedback
	-- /tp mob advanced
	["Mob Stats Advanced Settings"] = "Erweiterte Mobs Stats Einstellungen",
	["Change advanced mob stats"] = "\195\132ndern der erweiterten Mob Stats",
	-- /tp mob advanced crit
	["Mob Melee Crit"] = "Mob Nahkampf Kritisch",
	["Sets mob's melee crit chance"] = "\195\132ndern der Mob Nahkampf Krit Chance",
	-- /tp mob advanced critbonus
	["Mob Melee Crit Bonus"] = "Mob Nahkampf Krit Bonus",
	["Sets mob's melee crit bonus"] = "\195\132ndern des Mob Nahkampf Krit Bonus",
	-- /tp mob advanced miss
	["Mob Melee Miss"] = "Mob Nahkampf Verfehlt",
	["Sets mob's melee miss chance"] = "\195\132ndern der Mob Nahkampf Verfehl Chance",
	-- /tp mob advanced spellcrit
	["Mob Spell Crit"] = "Mob Zauber Kritsch",
	["Sets mob's spell crit chance"] = "\195\132ndern der Mob Zauber Krit Chance",
	-- /tp mob advanced spellcritbonus
	["Mob Spell Crit Bonus"] = "Mob Zauber Krit Bonus",
	["Sets mob's spell crit bonus"] = "\195\132ndern des Mob Zauber Krit Bonus",
	-- /tp mob advanced spellmiss
	["Mob Spell Miss"] = "Mob Zauber Verfehlt",
	["Sets mob's spell miss chance"] = "\195\132ndern der Mob Zauber Verfehl Chance",
	----------------------
	-- GetDodgePerAgi() --
	----------------------
	["Cat Form"] = "Katzengestalt",
	---------------------------
	-- GetTalantBuffEffect() --
	---------------------------
	["Soul Link"] = "Seelenverbindung",
	["Voidwalker"] = "Leerwandler",
	["Righteous Fury"] = "Zorn der Gerechtigkeit",
	["Pain Suppression"] = "Schmerzunterdrückung",
	["Shield Wall"] = "Schildwall",
	["Death Wish"] = "Todeswunsch",
	["Recklessness"] = "Tollkühnheit",
	["Cloak of Shadows"] = "Mantel der Schatten",
	-----------------------
	-- AlterDataTable() --
	-----------------------
	["Bear Form"] = "Bärengestalt",
	["Dire Bear Form"] = "Terrorbärengestalt",
	["Moonkin Form"] = "Moonkingestalt",
	-----------------------
	-- PlayerHasShield() --
	-----------------------
	["Shields"] = "Schilde",
	---------------------
	-- GetBlockValue() --
	---------------------
	["^(%d+) Block$"] = "^(%d+) Blocken",
	------------------------
	-- Item Scan Patterns --
	------------------------
	["ItemScan"] = {
		[TP_BLOCKVALUE] = {
			{"Erh\195\182ht den Blockwert Eures Schildes um (%d+)"},
			{"Erh\195\182ht den Blockwert Eures Schilds um (%d+)"},
			{"Blockwert %+(%d+)"},
		}
	},
	---------------------------
	-- TankPoints Calculator --
	---------------------------
	-- Title
	["TankPoints Calculator"] = "TankPoints Rechner",
	["Left click to drag\nRight click to reset position"] = "Links klick zum ziehen\nRechtsklick um die Position zur\195\188ckzusetzen",
	-- Buttons
	--["Reset"] = true,
	["Close"] = "Schliessen",
	-- Option frame box title
	["Results"] = "Ergebnis",
	["Player Stats"] = "Spieler Stats",
	["Total Reduction"] = "Endg\195\188ltige Reduzierung",
	--["(%)"] = true,
	["Max Health"] = "Max Leben",
} end)