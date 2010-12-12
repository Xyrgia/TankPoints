-- -*- indent-tabs-mode: t; tab-width: 4; lua-indent-level: 4 -*-
--[[
Name: TankPoints esES locale
Revision: $Revision: 105 $
Translated by: 
- shiftos
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
local esES = {
	-------------
	-- General --
	-------------
	["TankPoints"] = "Puntos de Tanque",
	["Block Value"] = "Valor de Bloqueo",
	--------------------
	-- Character Info --
	--------------------
	-- Stats
	[" TP"] = " PdT", -- concatenated after a school name for Spell TankPoints, ex: "Nature TP"
	[" DR"] = " RaD", -- concatenated after a school name for Damage Reductions, ex: "Nature DR"
	-- TankPoints Stat Tooltip
	["In "] = "En ", -- concatenated before stance name, ex: "In Battle Stance"
	["Mob Stats"] = "Estadísticas del Enemigo",
	["Mob Level"] = "Nivel del Enemigo",
	["Mob Damage"] = "Daño del Enemigo",
	["Mob Crit"] = "Crítico del Enemigo",
	["Mob Miss"] = "Fallo del Enemigo",
	["Per StatValue"] = "Por Valor de Estadística",
	["Per Stat"] = "Por Estadística",
        -- ["Click: show Per StatValue TankPoints"] = "",
        -- ["Click: show Per Stat TankPoints"] = "",

	-- Melee Reduction Tooltip
	[" Damage Reduction"] = " (Reducción a Daño)", -- concatenated after a school name for Damage Reductions, ex: "Nature Damage Reduction"
	["Player Level"] = "Nivel del Jugador",
	["Combat Table"] = "Tabla de Combate",
	["Crit"] = "Crítico",
	["Crushing"] = "Aplastamiento",
	["Hit"] = "Golpear",
	-- Block Value Tooltip
	["Mob Damage before DR"] = "Daño del Enemigo antes de RaD",
	["Mob Damage after DR"] = "Daño del Enemigo después de RaD",
	["Blocked Percentage"] = "Porcentaje Bloqueado",
	["Equivalent Block Mitigation"] = "Mitigación de Bloqueo Equivalente",
	["Shield Block Up Time"] = "Tiempo de Bloqueo con Escudo",
	-- Spell TankPoints Tooltip
	["Melee/Spell Damage Ratio"] = "Proporción de Daño Cuerpo a Cuerpo/Hechizo",
	["Left click: Show next school"] = "Clic Izquierdo: Mostrar escuela siguiente",
	["Right click: Show strongest school"] = "Clic Derecho: Mostrar escuela más fuerte",
	-- Spell Reduction Tooltip
	-- Toggle Calculator
	["Open Calculator"] = "Abrir Calculadora",
	["Close Calculator"] = "Cerrar Calculadora",
	---------------------------
	-- Slash Command Options --
	---------------------------
	-- /tp calc
	["TankPoints Calculator"] = "Calculadora de Puntos de Tanque",
	["Shows the TankPoints Calculator"] = "Muestra la Calculadora de Puntos de Tanque",
	-- /tp tooltip
	["Tooltip Options"] = "Opciones de Tooltip",
	["TankPoints tooltip options"] = "Opciones para el tooltip de Tankpoints",
	-- /tp tooltip diff
	["Show TankPoints Difference"] = "Mostrar Diferencia en Tooltips",
	["Show TankPoints difference in item tooltips"] = "Muestra la diferencia de Puntos de Tanque en los tooltip de objeto",
	-- /tp tooltip total
	["Show TankPoints Total"] = "Mostrar Total en Tooltip",
	["Show TankPoints total in item tooltips"] = "Muestra el total de Puntos de Tanque en los tooltip de objeto",
	-- /tp player
	["Player Stats"] = "Estadísticas del Jugador",
	["Change default player stats"] = "Cambia las estadísticas del jugador por defecto",
	-- /tp player sbfreq
	--["Shield Block Key Press Delay"] = "Frecuencia de pulsación de tecla de Bloqueo con Escudo",
	--["Sets the time in seconds after Shield Block finishes cooldown"] = "Establece el tiempo, en segundos, entre cada presión de tecla de Bloqueo con Escudo",
	-- /tp mob
	["Mob Stats"] = "Estadísticas del Enemigo",
	["Change default mob stats"] = "Cambia las estadísticas del enemigo por defecto",
	-- /tp mob level
	["Mob Level"] = "Nivel del Enemigo",
	["Sets the level difference between the mob and you"] = "Establece la diferencia de nivel entre el enemigo y tu",
	-- /tp mob damage
	["Mob Damage"] = "Daño del Enemigo",
	["Sets mob's damage before damage reduction"] = "Establece el daño del enemigo antes de la reducción del daño",
	-- /tp mob speed
	["Mob Attack Speed"] = "Vel. Ataque Enemigo",
	["Sets mob's attack speed"] = "Establece la velocidad de ataque del enemigo",
	-- /tp mob default
	["Restore Default"] = "Reestablecer valores por defecto",
	["Restores default mob stats"] = "Reestablece las estadísticas por defecto del enemigo",
	["Restored Mob Stats Defaults"] = "Los valores por defecto para las estadísticas del enemigo han sido reestablecidos", -- command feedback
	-- /tp mob advanced
	["Mob Stats Advanced Settings"] = "Ajustes Avanzados de Estadísticas del Enemigo",
	["Change advanced mob stats"] = "Cambia las estadísticas avanzadas del enemigo",
	-- /tp mob advanced crit
	["Mob Melee Crit"] = "Crítico Cuerpo a Cuerpo del Enemigo",
	["Sets mob's melee crit chance"] = "Establece las posibilidades de conseguir un crítico cuerpo a cuerpo del enemigo",
	-- /tp mob advanced critbonus
	["Mob Melee Crit Bonus"] = "Bonificación a Crítico Cuerpo a Cuerpo del Enemigo",
	["Sets mob's melee crit bonus"] = "Establece la bonificación a crítico cuerpo a cuerpo del enemigo",
	-- /tp mob advanced miss
	["Mob Melee Miss"] = "Fallo Cuerpo a Cuerpo del Enemigo",
	["Sets mob's melee miss chance"] = "Establece las posibilidades de fallo cuerpo a cuerpo del enemigo",
	-- /tp mob advanced spellcrit
	["Mob Spell Crit"] = "Crítico con Hechizos del Enemigo",
	["Sets mob's spell crit chance"] = "Establece la posibilidad de conseguir un crítico con hechizos del enemigo",
	-- /tp mob advanced spellcritbonus
	["Mob Spell Crit Bonus"] = "Bonificación a Crítico con Hechizos del Enemigo",
	["Sets mob's spell crit bonus"] = "Establece la bonificación a crítico con hechizos del enemigo",
	-- /tp mob advanced spellmiss
	["Mob Spell Miss"] = "Fallo con Hechizos del Enemigo",
	["Sets mob's spell miss chance"] = "Establece las posibilidades de fallo con hechizos del enemigo",
	----------------------
	-- GetDodgePerAgi() --
	----------------------
	["Cat Form"] = "Forma de gato",
	---------------------------
	-- GetTalantBuffEffect() --
	---------------------------
	["Soul Link"] = "Enlace de alma",
	["Voidwalker"] = "Abisario",
	["Righteous Fury"] = "Furia justa",
	["Pain Suppression"] = "Supresión de dolor",
	["Shield Wall"] = "Muro de escudo",
	["Death Wish"] = "Deseo de la Muerte",
	["Recklessness"] = "Temeridad",
	["Cloak of Shadows"] = "Capa de las Sombras",
	----------------------
	-- AlterSourceData() --
	----------------------
	["Bear Form"] = "Forma de oso",
	["Dire Bear Form"] = "Forma de oso temible",
	["Moonkin Form"] = "Forma de lechúcico lunar",
	-----------------------
	-- PlayerHasShield() --
	-----------------------
	["Shields"] = "Escudos",
	---------------------
	-- GetBlockValue() --
	---------------------
	["^(%d+) Block$"] = "^(%d+) bloqueo$",
	------------------------
	-- Item Scan Patterns --
	------------------------
	["ItemScan"] = {
		[TP_BLOCKVALUE] = {
			{"Aumenta el valor de bloqueo de tu escudo en (%d+)"},
			{"%+(%d+) valor de bloqueo"},        -- check  - índice /valor
		}
	},
	---------------------------
	-- TankPoints Calculator --
	---------------------------
	-- Title
	["TankPoints Calculator"] = "Calculadora de Puntos de Tanque",
	["Left click to drag\nRight click to reset position"] = "Clic Izquierdo para arrastrar\nClic Derecho para reestablecer la posición",
	-- Buttons
	["Reset"] = "Reestablecer",
	["Close"] = "Cerrar",
	-- Option frame box title
	["Results"] = "Resultados",
	["Player Stats"] = "Estadísticas del Jugador",
	["Total Reduction"] = "Reducción Total",
	["(%)"] = "(%)",
	["Max Health"] = "Salud Máxima",
	["Items"] = "Objetos",
	-------------------------
	-- TankPoints Tooltips --
	-------------------------
	[" (Top/Bottom):"] = " (Arriba/Abajo):",
	[" (Main/Off):"] = " (Derecha/Izquierda):",
	[" (Main+Off):"] = " (Derecha+Izquierda):",
	["Gems"] = "Gemas",
}
L:RegisterTranslations("esES", function() return esES end)
L:RegisterTranslations("esMX", function() return esES end)