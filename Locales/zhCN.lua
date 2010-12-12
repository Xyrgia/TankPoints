--[[
Name: TankPoints zhCN locale
Revision: $Revision: 84 $
Translated by: 
- 自由之名@白银之手
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
-- After:  ["Show Item ID"] = "显示物品编号",
L:RegisterTranslations("zhCN", function() return {
	-------------
	-- General --
	-------------
	["TankPoints"] = "坦点",
	["EH"] = "实命", -- "Effective Health" is a long phrase
	["EHB"] = "计挡实命", -- "Effective Health with Block" is a very long phrase
	["Block Value"] = "格挡值",
	--------------------
	-- Character Info --
	--------------------
	-- Stats
	["EH Block"] = "计挡实命",
	[" EH"] = "实命",
	[" TP"] = "坦点", -- concatenated after a school name for Spell TankPoints, ex: "Nature TP"
	[" DR"] = "免伤", -- concatenated after a school name for Damage Reductions, ex: "Nature DR"
	-- TankPoints Stat Tooltip
	["In "] = "在", -- concatenated before stance name, ex: "In Battle Stance"
	["Mob Stats"] = "怪物属性",
	["Mob Level"] = "怪物等级",
	["Mob Damage"] = "怪物伤害",
	["Mob Crit"] = "怪物爆击",
	["Mob Miss"] = "怪物未击中",
	["Per StatValue"] = "每等值属性坦点",
	["Per Stat"] = "每点属性坦点",
        ["Click: show Per StatValue TankPoints"] = "点击：显示每等值属性坦点",
        ["Click: show Per Stat TankPoints"] = "点击：显示每点属性坦点",
	-- Melee Reduction Tooltip
	[" Damage Reduction"] = "物免", -- concatenated after a school name for Damage Reductions, ex: "Nature Damage Reduction"
	["Player Level"] = "玩家等级",
	["Combat Table"] = "战斗数据表",
	["Crit"] = "被爆",
	["Crushing"] = "被碾",
	["Hit"] = "被击中",
	-- Block Value Tooltip
	["Mob Damage before DR"] = "物免前伤害",
	["Mob Damage after DR"] = "物免后伤害",
	["Blocked Percentage"] = "格档单次免伤",
	["Equivalent Block Mitigation"] = "格档全程免伤",
	["Shield Block Up Time"] = "盾牌格挡有效时间",
	-- Spell TankPoints Tooltip
	["Melee/Spell Damage Ratio"] = "近战/法术伤害比",
	["Left click: Show next school"] = "左键: 显示下一个属性",
	["Right click: Show strongest school"] = "右键: 显示最强的属性",
	[" resist "] = "抗性",
	-- Spell Reduction Tooltip
	-- Toggle Calculator
	["Open Calculator"] = "开启计算器",
	["Close Calculator"] = "关闭计算器",
	-- talent names
	["imp. Shield Block"] = "强化盾挡", -- short for Improved Shield Block
	-- Effective Health stuff
	["Effective Health"] = "实命",
	["Effective Health vs %s %s"] = "实命：%s %s", -- Melee/Nature/Fire followed by EH
	["Effective Health (with Block) vs Melee "] = "实命(计格挡)：近战", -- followed by EHB
	["Effective Health with Block"] = "实命(计格档)",
	["Effective Health - All Schools"] = "实命：所有抗性", -- heading for the all schools of damage tooltip
	["Health"] = "生命值", -- player health
	["Armor Reduction"] = "护甲减免", -- how much armor reduces damage
	["Resistance Reduction"] = "抗性减免", -- reduction due to elemental resist (nature, etc)
	--["Talent/Buff/Stance Reductions"] = "其它减免", -- things like stances, talents
	["Your Reductions"] = "你的减免", -- section header
	["Guaranteed Reduction"] = "实际减免", -- how much damage you're guaranteed to mitigate
	["Mob attacks can critically hit"] = "怪物能爆击",
	["Mob attacks cannot critically hit"] = "怪物不能爆击",
	["Mob attacks will crush"] = "怪物能碾压",
	["Mob attacks should not crush"] = "怪物不能碾压",
	-- an array with lines to be put at the bottom of the Effective Health Tooltip
	-- saying what EH is
	["TP_EXPLANATION"] = {"坦点是计算几率属性的生命值。"},
	["EH_EXPLANATION"] = {"实命是不计未命中/格档/躲闪/招架", "时能承受的原始伤害。"},
	["EHB_EXPLANATION"] = {"计格挡的实命是不计未命中/躲闪/", "招架时能承受的原始伤害，取决于", "怪物类型并要求能格挡。"},
	["See /tp optionswin to turn on tooltip."] = "查看 /tp optionswin 打开提示",
        
	---------------------------
	-- Slash Command Options --
	---------------------------
	-- /tp optionswin
	["Options Window"] = "选项窗口",
	["Shows the Options Window"] = "显示选项窗口",
	-- /tp calc
	["TankPoints Calculator"] = "坦点计算器",
	["Shows the TankPoints Calculator"] = "显示坦点计算器",
	-- /tp tooltip
	["Tooltip Options"] = "提示框选项",
	["TankPoints tooltip options"] = "坦点提示框选项",
	-- /tp tooltip diff
	["Show TankPoints Difference"] = "显示坦点差值",
	["Show TankPoints difference in item tooltips"] = "在物品提示框中显示坦点差值",
	-- /tp tooltip total
	["Show TankPoints Total"] = "显示坦点总值",
	["Show TankPoints total in item tooltips"] = "在物品提示框中显示坦点总值",
	-- /tp tooltip drdiff
	["Show Melee DR Difference"] = "显示近战物免差值",
	["Show Melee Damage Reduction difference in item tooltips"] = "在物品提示框中显示近战物免差值",
	-- /tp tooltip drtotal
	["Show Melee DR Total"] = "显示近战物免总值",
	["Show Melee Damage Reduction total in item tooltips"] = "在物品提示框中显示近战物免总值",
	-- /tp tooltip ehdiff
	["Show Effective Health Difference"] = "显示实际生命差值",
	["Show Effective Health difference in item tooltips"] = "在物品提市框中显示实际生命差值",
	-- /tp tooltip ehtotal
	["Show Effective Health Total"] = "显示实际生命总值",
	["Show Effective Health total in item tooltips"] = "在物品提示框中显示实际生命总值",
	-- /tp tooltip ehbdiff
	["Show Effective Health (with Block) Difference"] = "显示计算格挡的实际生命差值",
	["Show Effective Health (with Block) difference in item tooltips"] = "在物品提示框中显示计算格挡的实际生命差值",
	-- /tp tooltip ehbtotal
	["Show Effective Health (with Block) Total"] = "显示计算格挡的实际生命总值",
	["Show Effective Health (with Block) total in item tooltips"] = "在物品提示框中显示计算格挡的实际生命总值",
	-- /tp player
	["Player Stats"] = "玩家属性",
	["Change default player stats"] = "改变玩家默认属性",
	-- /tp player sbfreq
	--["Shield Block Key Press Delay"] = "盾牌格挡按键频率",
	--["Sets the time in seconds after Shield Block finishes cooldown"] = "设定盾牌格挡技能按键的间隔时间",
	-- /tp mob
	["Mob Stats"] = "怪物属性",
	["Change default mob stats"] = "改变怪物默认属性",
	-- /tp mob level
	["Mob Level"] = "怪物等级",
	["Sets the level difference between the mob and you"] = "设定你和怪物的等级差距",
	-- /tp mob damage
	-- /tp mob drdamage
	["Mob Damage"] = "怪物伤害",
	["Sets mob's damage before damage reduction"] = "设定物免之前的怪物伤害",
	["Sets mob's damage after melee damage reduction"] = "设定怪物物免之后的怪物伤害",
	-- /tp mob speed
	["Mob Attack Speed"] = "怪物攻击速度",
	["Sets mob's attack speed"] = "设定怪物的攻击速度",
	-- /tp mob default
	["Restore Default"] = "还原为默认值",
	["Restores default mob stats"] = "还原默认怪物状态",
	["Restored Mob Stats Defaults"] = "怪物状态已经还原为默认值", -- command feedback
	-- /tp mob advanced
	["Mob Stats Advanced Settings"] = "怪物状态高级设定",
	["Change advanced mob stats"] = "更进一步更改怪物状态",
	-- /tp mob advanced crit
	["Mob Melee Crit"] = "怪物爆击",
	["Sets mob's melee crit chance"] = "设定怪物的爆击几率",
	-- /tp mob advanced critbonus
	["Mob Melee Crit Bonus"] = "怪物爆击伤害加成",
	["Sets mob's melee crit bonus"] = "设定怪物的爆击伤害加成",
	-- /tp mob advanced miss
	["Mob Melee Miss"] = "怪物未击中",
	["Sets mob's melee miss chance"] = "设定怪物的未击中几率",
	-- /tp mob advanced spellcrit
	["Mob Spell Crit"] = "怪物法爆",
	["Sets mob's spell crit chance"] = "设定怪物法术的爆击几率",
	-- /tp mob advanced spellcritbonus
	["Mob Spell Crit Bonus"] = "怪物法爆伤害奖励",
	["Sets mob's spell crit bonus"] = "设定怪物法术的爆击伤害奖励",
	-- /tp mob advanced spellmiss
	["Mob Spell Miss"] = "怪物法术未击中",
	["Sets mob's spell miss chance"] = "设定怪物的法术未击中率",
	----------------------
	-- GetDodgePerAgi() --
	----------------------
	["Cat Form"] = "猎豹形态",
	---------------------------
	-- GetTalantBuffEffect() --
	---------------------------
	["Soul Link"] = "灵魂联结",
	["Voidwalker"] = "虚空行者",
	["Righteous Fury"] = "正义之怒",
	["Pain Suppression"] = "痛苦镇压",
	["Shield Wall"] = "盾墙",
	["Death Wish"] = "死亡之愿",
	["Recklessness"] = "鲁莽",
	["Cloak of Shadows"] = "暗影步",
	----------------------
	-- AlterSourceData() --
	----------------------
	["Bear Form"] = "熊形态",
	["Dire Bear Form"] = "巨熊形态",
	["Moonkin Form"] = "枭兽形态",
	-----------------------
	-- PlayerHasShield() --
	-----------------------
	["Shields"] = "盾",
	---------------------
	-- GetBlockValue() --
	---------------------
	["^(%d+) Block$"] = "^(%d+)格挡$",
	------------------------
	-- Item Scan Patterns --
	------------------------
	["ItemScan"] = {
		[TP_BLOCKVALUE] = {
			{"使你的盾牌格挡值提高(%d+)点。"},
			{"%+(%d+) 格挡值"},
		}
	},
	---------------------------
	-- TankPoints Calculator --
	---------------------------
	-- Title
	["TankPoints Calculator"] = "坦点计算器",
	["Left click to drag\nRight click to reset position"] = "左键点击以拖曳\n右键点击以重置位置",
	-- Buttons
	["Reset"] = "重置",
	["Close"] = "关闭",
	-- Option frame box title
	["Results"] = "结果",
	["Player Stats"] = "玩家属性",
	["Total Reduction"] = "总物免",
	["(%)"] = "(%)",
	["Max Health"] = "生命值",
	["Items"] = "物品",
	-------------------------
	-- TankPoints Tooltips --
	-------------------------
	[" (Top/Bottom):"] = " (上/下):",
	[" (Main/Off):"] = " (主/副):",
	[" (Main+Off):"] = " (主+副):",
	["Gems"] = "珠宝",
	---------------
	-- Waterfall --
	---------------
	["TankPoints Options"] = "坦点选项",	
} end)