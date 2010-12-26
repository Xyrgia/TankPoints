local addon = TankPoints
local L = AceLibrary("AceLocale-2.2"):new("TankPoints") --Create a localization lookup for our addon using AceLibrary --20101017
local Waterfall = AceLibrary("Waterfall-1.0")


local profileDB --TankPoints.db.profile, set during :SetupOptions()

--console/config options
local options = nil; --initialize to nil, so we can populate on demand in getOptions()


local function getOptions()

	--[[
		Slash Command Options
		Setup a description of our slash commands. This is a format defined by WowAce.
		The Waterfall library is also able to turn a set of slash commands into a configuration screen
		TODO: Make waterfall put the configuration pane in the proper addon place
	--]]

	if not options then
		options = { 
				type = "group",
				args = {
					optionswin = {
						type = "execute",
						name = L["Options Window"],
						desc = L["Shows the Options Window"],
						func = function()
							Waterfall:Open("TankPoints")
						end,
					}, --optionswin
					calc = {
						type = "execute",
						name = L["TankPoints Calculator"],
						desc = L["Shows the TankPoints Calculator"],
						func = function()
							if(TankPointsCalculatorFrame:IsVisible()) then
								TankPointsCalculatorFrame:Hide()
							else
								TankPointsCalculatorFrame:Show()
							end
							TankPoints:UpdateStats()
						end,
					}, --calc
					dumptable = {
						type = "execute",
						name = "Dump TankPoints table",
						desc = "Print the TankPoints calculations table to the console",
						func = function()
								TankPoints:DumpTable(TankPoints.resultsTable);
							end;
					},
					tip = {
						type = "group",
						name = L["Tooltip Options"],
						desc = L["TankPoints tooltip options"],
						args = {
							diff = {
								type = 'toggle',
								name = L["Show TankPoints Difference"],
								desc = L["Show TankPoints difference in item tooltips"],
								get = function() return profileDB.showTooltipDiff end,
								set = function(v)
									profileDB.showTooltipDiff = v
									TankPointsTooltips.ClearCache()
								end,
							},
							total = {
								type = 'toggle',
								name = L["Show TankPoints Total"],
								desc = L["Show TankPoints total in item tooltips"],
								get = function() return profileDB.showTooltipTotal end,
								set = function(v)
									profileDB.showTooltipTotal = v
									TankPointsTooltips.ClearCache()
								end,
							},
							drdiff = {
								type = 'toggle',
								name = L["Show Melee DR Difference"],
								desc = L["Show Melee Damage Reduction difference in item tooltips"],
								get = function() return profileDB.showTooltipDRDiff end,
								set = function(v)
									profileDB.showTooltipDRDiff = v
									TankPointsTooltips.ClearCache()
								end,
							},
							drtotal = {
								type = 'toggle',
								name = L["Show Melee DR Total"],
								desc = L["Show Melee Damage Reduction total in item tooltips"],
								get = function() return profileDB.showTooltipDRTotal end,
								set = function(v)
									profileDB.showTooltipDRTotal = v
									TankPointsTooltips.ClearCache()
								end,
							},
							ehdiff = {
								type = 'toggle',
								name = L["Show Effective Health Difference"],
								desc = L["Show Effective Health difference in item tooltips"],
								get = function() return profileDB.showTooltipEHDiff end,
								set = function(v)
									profileDB.showTooltipEHDiff = v
									TankPointsTooltips.ClearCache()
								end,
							},
							ehtotal = {
								type = 'toggle',
								name = L["Show Effective Health Total"],
								desc = L["Show Effective Health total in item tooltips"],
								get = function() return profileDB.showTooltipEHTotal end,
								set = function(v)
									profileDB.showTooltipEHTotal = v
									TankPointsTooltips.ClearCache()
								end,
							},
							ehbdiff = {
								type = 'toggle',
								name = L["Show Effective Health (with Block) Difference"],
								desc = L["Show Effective Health (with Block) difference in item tooltips"],
								get = function() return profileDB.showTooltipEHBDiff end,
								set = function(v)
									profileDB.showTooltipEHBDiff = v
									TankPointsTooltips.ClearCache()
								end,
							},
							ehbtotal = {
								type = 'toggle',
								name = L["Show Effective Health (with Block) Total"],
								desc = L["Show Effective Health (with Block) total in item tooltips"],
								get = function() return profileDB.showTooltipEHBTotal end,
								set = function(v)
									profileDB.showTooltipEHBTotal = v
									TankPointsTooltips.ClearCache()
								end,
							},
						},
					}, --tip
					player = {
						type = "group",
						name = L["Player Stats"],
						desc = L["Change default player stats"],
						args = {
							sbfreq = {
								type = "range",
								name = L["Shield Block Key Press Delay"],
								desc = L["Sets the time in seconds after Shield Block finishes cooldown"],
								get = function() return profileDB.shieldBlockDelay end,
								set = function(v)
									profileDB.shieldBlockDelay = v
									TankPoints:UpdateStats()
									-- Update Calculator
									if TankPointsCalculatorFrame:IsVisible() then
										TPCalc:UpdateResults()
									end
								end,
								min = 0,
								max = 1000,
							},
						},
					}, --player
					mob = {
						type = "group",
						name = L["Mob Stats"],
						desc = L["Change default mob stats"],
						args = {
							level = {
								type = "range",
								name = L["Mob Level"],
								desc = L["Sets the level difference between the mob and you"],
								get = function() return profileDB.mobLevelDiff end,
								set = function(v)
									profileDB.mobLevelDiff = v
									TankPoints:UpdateStats()
									-- Update Calculator
									if TankPointsCalculatorFrame:IsVisible() then
										TPCalc:UpdateResults()
									end
								end,
								min = -20,
								max = 20,
								step = 1,
							},
							default = {
								type = "execute",
								name = L["Restore Default"],
								desc = L["Restores default mob stats"],
								func = "SetDefaultMobStats",
							},
							advanced = {
								type = "group",
								name = L["Mob Stats Advanced Settings"],
								desc = L["Change advanced mob stats"],
								args = {
									crit = {
										type = "range",
										name = L["Mob Melee Crit"],
										desc = L["Sets mob's melee crit chance"],
										get = function() return profileDB.mobCritChance end,
										set = function(v)
											profileDB.mobCritChance = v
											TankPoints:UpdateStats()
											-- Update Calculator
											if TankPointsCalculatorFrame:IsVisible() then
												TPCalc:UpdateResults()
											end
										end,
										min = 0,
										max = 1,
										isPercent = true,
									},
									critbonus = {
										type = "range",
										name = L["Mob Melee Crit Bonus"],
										desc = L["Sets mob's melee crit bonus"],
										get = function() return profileDB.mobCritBonus end,
										set = function(v)
											profileDB.mobCritBonus = v
											TankPoints:UpdateStats()
											-- Update Calculator
											if TankPointsCalculatorFrame:IsVisible() then
												TPCalc:UpdateResults()
											end
										end,
										min = 0,
										max = 2,
									},
									miss = {
										type = "range",
										name = L["Mob Melee Miss"],
										desc = L["Sets mob's melee miss chance"],
										get = function() return profileDB.mobMissChance end,
										set = function(v)
											profileDB.mobMissChance = v
											TankPoints:UpdateStats()
											-- Update Calculator
											if TankPointsCalculatorFrame:IsVisible() then
												TPCalc:UpdateResults()
											end
										end,
										min = 0,
										max = 1,
										isPercent = true,
									},
									spellcrit = {
										type = "range",
										name = L["Mob Spell Crit"],
										desc = L["Sets mob's spell crit chance"],
										get = function() return profileDB.mobSpellCritChance end,
										set = function(v)
											profileDB.mobSpellCritChance = v
											TankPoints:UpdateStats()
											-- Update Calculator
											if TankPointsCalculatorFrame:IsVisible() then
												TPCalc:UpdateResults()
											end
										end,
										min = 0,
										max = 1,
										isPercent = true,
									},
									spellcritbonus = {
										type = "range",
										name = L["Mob Spell Crit Bonus"],
										desc = L["Sets mob's spell crit bonus"],
										get = function() return profileDB.mobSpellCritBonus end,
										set = function(v)
											profileDB.mobSpellCritBonus = v
											TankPoints:UpdateStats()
											-- Update Calculator
											if TankPointsCalculatorFrame:IsVisible() then
												TPCalc:UpdateResults()
											end
										end,
										min = 0,
										max = 2,
									},
									spellmiss = {
										type = "range",
										name = L["Mob Spell Miss"],
										desc = L["Sets mob's spell miss chance"],
										get = function() return profileDB.mobSpellMissChance end,
										set = function(v)
											profileDB.mobSpellMissChance = v
											TankPoints:UpdateStats()
											-- Update Calculator
											if TankPointsCalculatorFrame:IsVisible() then
												TPCalc:UpdateResults()
											end
										end,
										min = 0,
										max = 1,
										isPercent = true,
									},
								},
							},
						},
					}, --mob
				},
		} --options
	end;

	return options;
end;

function addon:SetupOptions()
	addon:RegisterChatCommand({"/tp", "/tankpoints"}, getOptions() );
	
	--[[
		Register our configuration screen with Waterfall, 
		which can automatically build a configuration screen around a WowAce consoleOptions object
	--]]
	Waterfall:Register("TankPoints", 
			"aceOptions", getOptions(), 
			"title", L["TankPoints Options"])
			
	profileDB = TankPoints.db.profile;
end

-- Set Default Mob Stats
function addon:SetDefaultMobStats()
	profileDB.mobLevelDiff = 3
	profileDB.mobDamage = 0
	profileDB.mobCritChance = 0.05
	profileDB.mobCritBonus = 1
	profileDB.mobMissChance = 0.05
	profileDB.mobSpellCritChance = 0
	profileDB.mobSpellCritBonus = 0.5
	profileDB.mobSpellMissChance = 0
	self:UpdateStats()
	-- Update Calculator
	if TankPointsCalculatorFrame:IsVisible() then
		TPCalc:UpdateResults()
	end
	TankPoints:Print(L["Restored Mob Stats Defaults"])
end