--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: Nameplates")

-- Lua API
local _G = _G
local unpack, select = unpack, select
local tinsert = table.insert
local tonumber = tonumber
local strfind, gsub = string.find, string.gsub

-- WoW API
local CreateFrame = CreateFrame
local GetComboPoints = GetComboPoints
local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestWorldMapAreaID = GetQuestWorldMapAreaID
local IsUnitOnQuest = IsUnitOnQuest
local SetMapToCurrentZone = SetMapToCurrentZone
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitName = UnitName
local WorldFrame = WorldFrame

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterBucketEvent = function(...) module:RegisterBucketEvent(...) end
local RegisterCallback = function(...) module:RegisterCallback(...) end
local ScheduleTimer = function(...) module:ScheduleTimer(...) end
local RGBToHex = RGBToHex
local FACTION_BAR_COLORS = C["FACTION_BAR_COLORS"]
local RARE = ITEM_QUALITY3_DESC
local BlizzardTexture = [[Interface\Tooltips\Nameplate-Border]]

-- these sizes assume an object scale that is pixel perfect
local plateWidth, plateHeight, castHeight = 140, 10, 7
local nameplates = {}
local scalefixes = {}

local enemyVisible, friendlyVisible
local ParseQuestLog
local ToggleFriendly, ToggleEnemy
local DecideSpecVisibility, UpdateAllVisibility

local Strip
local IsPlate, PlateIsTarget, ScanForPlates, UpdatePlates, UpdateScales
local ForEachPlate
local GetColor, OnHide, Style
local CreateOrUpdateComboPointFrame, GiveComboPoints
local PostUpdate, PostUpdateNameLevel, PostUpdateThreat, PostUpdateDrunk
local PostUpdateComboPoints, PostUpdateCastText, PostUpdateColor
local PostUpdateCastBar, CastBar_OnValueChanged, CastBar_OnSizeChanged, CastBar_OnShow, CastBar_OnHide
local HealthBar_OnValueChanged, HealthBar_OnMinMaxChanged, HealthBar_OnShow, HealthBar_OnHide

local hasTarget = false
local currentTarget = nil

-- I retrieved these from Wowhead.com
-- they need to be exact, as they are used to identify nameplates
do
	local locale = GetLocale()
	if (locale == "deDE") then
		L["Army of the Dead Ghoul"] = "Ghul aus der Armee der Toten"
		L["Earth Elemental Totem"] = "Totem des Erdelementars"
		L["Elemental Resistance Totem"] = "Totem des Elementarwiderstands"
		L["Fire Elemental Totem"] = "Totem des Feuerelementars"
		L["Flametongue Totem"] = "Totem der Flammenzunge"
		L["Healing Stream Totem"] = "Totem des heilenden Flusses"
		L["Magma Totem"] = "Totem des glühenden Magmas"
		L["Mana Spring Totem"] = "Totem der Manaquelle"
		L["Searing Totem"] = "Totem der Verbrennung"
		L["Stoneclaw Totem"] = "Totem der Steinklaue"
		L["Stoneskin Totem"] = "Totem der Steinhaut"
		L["Strength of Earth Totem"] = "Totem der Erdstärke"
		L["Windfury Totem"] = "Totem des Windzorns"
		L["Wrath of Air Totem"] = "Totem des stürmischen Zorns"
		
	elseif (locale == "frFR") then
		L["Army of the Dead Ghoul"] = "Goule de l'armée des morts"
		L["Earth Elemental Totem"] = "Totem d'élémentaire de terre"
		L["Elemental Resistance Totem"] = "Totem de résistance élémentaire"
		L["Fire Elemental Totem"] = "Totem d'élémentaire de feu"
		L["Flametongue Totem"] = "Totem Langue de feu"
		L["Healing Stream Totem"] = "Totem guérisseur"
		L["Magma Totem"] = "Totem de magma"
		L["Mana Spring Totem"] = "Totem Fontaine de mana"
		L["Searing Totem"] = "Totem incendiaire"
		L["Stoneclaw Totem"] = "Totem de griffes de pierre"
		L["Stoneskin Totem"] = "Totem de peau de pierre"
		L["Strength of Earth Totem"] = "Totem de force de la terre"
		L["Windfury Totem"] = "Totem Furie-des-vents"
		L["Wrath of Air Totem"] = "Totem de courroux de l'air"
		
	elseif (locale == "esES") or (locale == "esMX") then
		L["Army of the Dead Ghoul"] = "Necrófago del Ejército de muertos"
		L["Earth Elemental Totem"] = "Tótem Elemental de Tierra"
		L["Elemental Resistance Totem"] = "Tótem de resistencia elemental"
		L["Fire Elemental Totem"] = "Tótem Elemental de Fuego"
		L["Flametongue Totem"] = "Tótem Lengua de Fuego"
		L["Healing Stream Totem"] = "Tótem Corriente de sanación"
		L["Magma Totem"] = "Tótem de Magma"
		L["Mana Spring Totem"] = "Tótem Fuente de maná"
		L["Searing Totem"] = "Tótem abrasador"
		L["Stoneclaw Totem"] = "Tótem Garra de piedra"
		L["Stoneskin Totem"] = "Tótem Piel de piedra"
		L["Strength of Earth Totem"] = "Tótem Fuerza de la tierra"
		L["Windfury Totem"] = "Tótem Viento Furioso"
		L["Wrath of Air Totem"] = "Tótem cólera de aire"
		
	elseif (locale == "ruRU") then
		L["Army of the Dead Ghoul"] = "Вурдалак из войска мертвых"
		L["Earth Elemental Totem"] = "Тотем элементаля земли"
		L["Elemental Resistance Totem"] = "Тотем сопротивления силам стихий"
		L["Fire Elemental Totem"] = "Тотем элементаля огня"
		L["Flametongue Totem"] = "Тотем языка пламени"
		L["Healing Stream Totem"] = "Тотем исцеляющего потока"
		L["Magma Totem"] = "Тотем магмы"
		L["Mana Spring Totem"] = "Тотем источника маны"
		L["Searing Totem"] = "Опаляющий тотем"
		L["Stoneclaw Totem"] = "Тотем каменного когтя"
		L["Stoneskin Totem"] = "Тотем каменной кожи"
		L["Strength of Earth Totem"] = "Тотем силы земли"
		L["Windfury Totem"] = "Тотем неистовства ветра"
		L["Wrath of Air Totem"] = "Тотем гнева воздуха"
		
	elseif (locale == "ptPT") or (locale == "ptBR") then
		L["Army of the Dead Ghoul"] = "Carniçal do Exército dos Mortos"
		L["Earth Elemental Totem"] = "Totem de Elemental da Terra"
		L["Elemental Resistance Totem"] = "Totem de Resistência Elemental"
		L["Fire Elemental Totem"] = "Totem de Elemental do Fogo"
		L["Flametongue Totem"] = "Totem de Labaredas"
		L["Healing Stream Totem"] = "Totem de Torrente Curativa"
		L["Magma Totem"] = "Totem de Magma"
		L["Mana Spring Totem"] = "Totem de Fonte de Mana"
		L["Searing Totem"] = "Totem Calcinante"
		L["Stoneclaw Totem"] = "Totem da Garra de Pedra"
		L["Stoneskin Totem"] = "Totem Litopele"
		L["Strength of Earth Totem"] = "Totem da Força da Terra"
		L["Windfury Totem"] = "Totem de Fúria dos Ventos"
		L["Wrath of Air Totem"] = "Totem de Cólera dos Ares"
		
	else
		-- koKR, jaJP
		-- zhTW, zhCN
		-- enGB, enUS, enTW etc 
		L["Army of the Dead Ghoul"] = true
		L["Earth Elemental Totem"] = true
		L["Elemental Resistance Totem"] = true
		L["Fire Elemental Totem"] = true
		L["Flametongue Totem"] = true
		L["Healing Stream Totem"] = true
		L["Magma Totem"] = true
		L["Mana Spring Totem"] = true
		L["Searing Totem"] = true
		L["Stoneclaw Totem"] = true
		L["Stoneskin Totem"] = true
		L["Strength of Earth Totem"] = true
		L["Windfury Totem"] = true
		L["Wrath of Air Totem"] = true
	end
end

local questCounter
local questList = {
	[29512] = true; -- Putting the Carnies Back Together Again (Darkmoon Faire)
	[29138] = true; -- Burn Victims (Molten Front)
}

-- list of nameplates to ignore
-- using localized names from Wowhead.com to support other locales
local blackList = {
	[L["Army of the Dead Ghoul"]] = true;
	[L["Earth Elemental Totem"]] = true;
	[L["Elemental Resistance Totem"]] = true;
	[L["Fire Elemental Totem"]] = true;
	[L["Stoneclaw Totem"]] = true;
	[L["Stoneskin Totem"]] = true;
	[L["Strength of Earth Totem"]] = true;
	[L["Windfury Totem"]] = true;
	[L["Wrath of Air Totem"]] = true;
	[L["Flametongue Totem"]] = true;
	[L["Magma Totem"]] = true;
	[L["Searing Totem"]] = true;

	-- I need to see these
--	[L["Healing Stream Totem"]] = true;
--	[L["Mana Spring Totem"]] = true;

--	["Frostbrood Whelp"] = true; -- just for testing (Icecrown, close to the tournament)
}

local defaults = {
	showFriendly = false;
	showEnemy = true;

	showLevel = 1;
	showMaxLevel = 0;
	showNames = 1;
	showComboPoints = 1;
	
	autoSelect = true; -- automatically enable/disable plates based on player spec
	autoQuest = true; -- automatically activate friendly plates for listed quests
	friendlyOnlyInCombat = true; -- only show friendly plates when engaged in combat
	enemyOnlyInCombat = false; -- only show friendly plates when engaged in combat
	
	useBlackList = true; -- use the nameplate blacklist
}

-- list of CVars to monitor for the menu updater
local cvarList = {
	["nameplateShowFriends"] = true;
	["nameplateShowFriendlyPets"] = true;
	["nameplateShowFriendlyGuardians"] = true;
	["nameplateShowFriendlyTotems"] = true;
	["nameplateShowEnemies"] = true;
	["nameplateShowEnemyPets"] = true;
	["nameplateShowEnemyGuardians"] = true;
	["nameplateShowEnemyTotems"] = true;
	["nameplateMotion"] = (SetNamePlateMotionType) and true;
}

-- list of global strings related to the CVars above
-- we try to keep this automatic as far as possible
local globalCVarString = {
	[NamePanelOptions.nameplateShowFriends.text] = true;
	[NamePanelOptions.nameplateShowFriendlyPets.text] = true;
	[NamePanelOptions.nameplateShowFriendlyGuardians.text] = true;
	[NamePanelOptions.nameplateShowFriendlyTotems.text] = true;
	[NamePanelOptions.nameplateShowEnemies.text] = true;
	[NamePanelOptions.nameplateShowEnemyPets.text] = true;
	[NamePanelOptions.nameplateShowEnemyGuardians.text] = true;
	[NamePanelOptions.nameplateShowEnemyTotems.text] = true;
	["UNIT_NAMEPLATES_TYPES"] = (SetNamePlateMotionType) and true;
}

local menuTable = {
	{
		type = "group";
		name = module:GetName();
		order = 1;
		virtual = true;
		children = {
			{ -- title
				type = "widget";
				element = "Title";
				order = 1;
				msg = F.getName(module:GetName());
			};
			{ -- subtext
				type = "widget";
				element = "Text";
				order = 2;
				msg = L["Nameplates are small health- and castbars visible over a character or NPC's head. These options allow you to control which Nameplates are visible within the game field while you play."];
			};
			{ -- visibility
				type = "widget";
				element = "Header";
				order = 4;
				msg = L["Visibility"];
			};
			{ -- auto by spec
				type = "widget";
				element = "CheckButton";
				name = "autoSelect";
				order = 5;
				msg = L["Automatically enable nameplates based on your current specialization"];
				desc = nil;
				set = function(self) 
					GUIS_DB["nameplates"].autoSelect = not(GUIS_DB["nameplates"].autoSelect)
					module:UpdateAll()
				end;
				get = function() return GUIS_DB["nameplates"].autoSelect end;
				onrefresh = function(self) 
					if (GUIS_DB["nameplates"].autoSelect) then
						self.parent.child.blizzard.child.nameplateShowFriends:Disable()
						self.parent.child.blizzard.child.nameplateShowEnemies:Disable()
					else
						self.parent.child.blizzard.child.nameplateShowFriends:Enable()
						self.parent.child.blizzard.child.nameplateShowEnemies:Enable()
					end
				end;
				init = function(self) self:onrefresh() end;
			};
			{ -- auto by quest
				type = "widget";
				element = "CheckButton";
				name = "autoQuest";
				order = 6;
				msg = L["Automatically enable friendly nameplates for repeatable quests that require them"];
				desc = nil;
				set = function(self) 
					GUIS_DB["nameplates"].autoQuest = not(GUIS_DB["nameplates"].autoQuest)
					module:UpdateAll()
				end;
				get = function() return GUIS_DB["nameplates"].autoQuest end;
			};
			{ -- friendly in combat
				type = "widget";
				element = "CheckButton";
				name = "friendlyOnlyInCombat";
				order = 7;
				msg = L["Only show friendly nameplates when engaged in combat"];
				desc = nil;
				set = function(self) 
					GUIS_DB["nameplates"].friendlyOnlyInCombat = not(GUIS_DB["nameplates"].friendlyOnlyInCombat)
					module:UpdateAll()
				end;
				get = function() return GUIS_DB["nameplates"].friendlyOnlyInCombat end;
			};
			{ -- enemy in combat
				type = "widget";
				element = "CheckButton";
				name = "enemyOnlyInCombat";
				order = 8;
				msg = L["Only show enemy nameplates when engaged in combat"];
				desc = nil;
				set = function(self) 
					GUIS_DB["nameplates"].enemyOnlyInCombat = not(GUIS_DB["nameplates"].enemyOnlyInCombat)
					module:UpdateAll()
				end;
				get = function() return GUIS_DB["nameplates"].enemyOnlyInCombat end;
			};
			{ -- blacklist spam
				type = "widget";
				element = "CheckButton";
				name = "useBlackList";
				order = 9;
				msg = L["Use a blacklist to filter out certain nameplates"];
				desc = nil;
				set = function(self) 
					GUIS_DB["nameplates"].useBlackList = not(GUIS_DB["nameplates"].useBlackList)
					module:UpdateAll()
				end;
				get = function() return GUIS_DB["nameplates"].useBlackList end;
			};
			
			{ -- blizzard options
				type = "group";
				order = 50;
				name = "blizzard";
				virtual = true;
				children = {
					(SetNamePlateMotionType) and {
						type = "widget";
						element = "Header";
						order = 1;
						msg = L["Nameplate Motion Type"];
					} or nil;
					(SetNamePlateMotionType) and { -- motion dropdown
						type = "widget";
						element = "Dropdown";
						name = "nameplateMotion";
						order = 2;
						width = "full";
						msg = nil;
						desc = {
							L["Nameplate Motion Type"];
							" ";
							("|cFFFFFFFF%s:|r"):format(L["Overlapping Nameplates"]);
							("|cFFFFD100%s|r"):format(L["This method will allow nameplates to overlap."]);
							" ";
							("|cFFFFFFFF%s:|r"):format(L["Stacking Nameplates"]);
							("|cFFFFD100%s|r"):format(L["This method avoids overlapping nameplates by stacking them vertically."]);
							" ";
							("|cFFFFFFFF%s:|r"):format(L["Spreading Nameplates"]);
							("|cFFFFD100%s|r"):format(L["This method avoids overlapping nameplates by spreading them out horizontally and vertically."]);
						};
						args = { L["Overlapping Nameplates"], L["Stacking Nameplates"], L["Spreading Nameplates"] };
						set = function(self) 
							SetCVar("nameplateMotion", UIDropDownMenu_GetSelectedID(self) - 1)
						end;
						get = function(self) return tonumber(GetCVar("nameplateMotion")) or 0 + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					} or nil;
					{ -- friendly
						type = "widget";
						element = "Header";
						order = 10;
						width = "half";
						msg = L["Friendly Units"]; 
					};
					{ -- friendly players
						type = "widget";
						element = "CheckButton";
						name = "nameplateShowFriends";
						order = 15;
						width = "half";
						msg = L["Friendly Players"];
						desc = L["Turn this on to display Unit Nameplates for friendly units."];
						set = function(self) 
							GUIS_DB["nameplates"].showFriendly = not(GUIS_DB["nameplates"].showFriendly)
							module:UpdateAll()
							self:onrefresh()
						end;
						get = function() return GUIS_DB["nameplates"].showFriendly end;
						onrefresh = function(self) 
							if (self:get()) then
--								self.parent.child.nameplateShowFriendlyPets:Enable()
--								self.parent.child.nameplateShowFriendlyGuardians:Enable()
--								self.parent.child.nameplateShowFriendlyTotems:Enable()
							else
--								self.parent.child.nameplateShowFriendlyPets:Disable()
--								self.parent.child.nameplateShowFriendlyGuardians:Disable()
--								self.parent.child.nameplateShowFriendlyTotems:Disable()
							end
						end;
						init = function(self) self:onrefresh() end;
					};
					{ -- pets
						type = "widget";
						element = "CheckButton";
						name = "nameplateShowFriendlyPets";
						order = 20;
						indented = true;
						width = "half";
						msg = L["Pets"];
						desc = L["Turn this on to display Unit Nameplates for friendly pets."];
						set = function(self) 
							SetCVar("nameplateShowFriendlyPets", self:get() and 0 or 1) 
							module:UpdateAll()
						end;
						get = function() return tonumber(GetCVar("nameplateShowFriendlyPets")) == 1 end;
					};
					{ -- guardians
						type = "widget";
						element = "CheckButton";
						name = "nameplateShowFriendlyGuardians";
						order = 25;
						indented = true;
						width = "half";
						msg = L["Guardians"];
						desc = L["Turn this on to display Unit Nameplates for friendly guardians."];
						set = function(self) 
							SetCVar("nameplateShowFriendlyGuardians", self:get() and 0 or 1) 
							module:UpdateAll()
						end;
						get = function() return tonumber(GetCVar("nameplateShowFriendlyGuardians")) == 1 end;
					};
					{ -- totems
						type = "widget";
						element = "CheckButton";
						name = "nameplateShowFriendlyTotems";
						order = 30;
						indented = true;
						width = "half";
						msg = L["Totems"];
						desc = L["Turn this on to display Unit Nameplates for friendly totems."];
						set = function(self) 
							SetCVar("nameplateShowFriendlyTotems", self:get() and 0 or 1) 
							module:UpdateAll()
						end;
						get = function() return tonumber(GetCVar("nameplateShowFriendlyTotems")) == 1 end;
					};
					{ -- enemy
						type = "widget";
						element = "Header";
						order = 11;
						width = "half";
						msg = L["Enemy Units"]; 
					};
					{ -- enemy players
						type = "widget";
						element = "CheckButton";
						name = "nameplateShowEnemies";
						order = 16;
						width = "half";
						msg = L["Enemy Players"];
						desc = L["Turn this on to display Unit Nameplates for enemies."];
						set = function(self) 
							GUIS_DB["nameplates"].showEnemy = not(GUIS_DB["nameplates"].showEnemy)
							module:UpdateAll()
							self:onrefresh()
						end;
						get = function() return GUIS_DB["nameplates"].showEnemy end;
						onrefresh = function(self) 
							if (self:get()) then
--								self.parent.child.nameplateShowEnemyPets:Enable()
--								self.parent.child.nameplateShowEnemyGuardians:Enable()
--								self.parent.child.nameplateShowEnemyTotems:Enable()
							else
--								self.parent.child.nameplateShowEnemyPets:Disable()
--								self.parent.child.nameplateShowEnemyGuardians:Disable()
--								self.parent.child.nameplateShowEnemyTotems:Disable()
							end
						end;
						init = function(self) self:onrefresh() end;
					};
					{ -- pets
						type = "widget";
						element = "CheckButton";
						name = "nameplateShowEnemyPets";
						order = 21;
						indented = true;
						width = "half";
						msg = L["Pets"];
						desc = L["Turn this on to display Unit Nameplates for enemy pets."];
						set = function(self) 
							SetCVar("nameplateShowEnemyPets", self:get() and 0 or 1) 
							module:UpdateAll()
						end;
						get = function() return tonumber(GetCVar("nameplateShowEnemyPets")) == 1 end;
					};
					{ -- guardians
						type = "widget";
						element = "CheckButton";
						name = "nameplateShowEnemyGuardians";
						order = 26;
						indented = true;
						width = "half";
						msg = L["Guardians"];
						desc = L["Turn this on to display Unit Nameplates for enemy guardians."];
						set = function(self) 
							SetCVar("nameplateShowEnemyGuardians", self:get() and 0 or 1) 
							module:UpdateAll()
						end;
						get = function() return tonumber(GetCVar("nameplateShowEnemyGuardians")) == 1 end;
					};
					{ -- totems
						type = "widget";
						element = "CheckButton";
						name = "nameplateShowEnemyTotems";
						order = 31;
						indented = true;
						width = "half";
						msg = L["Totems"];
						desc = L["Turn this on to display Unit Nameplates for enemy totems."];
						set = function(self) 
							SetCVar("nameplateShowEnemyTotems", self:get() and 0 or 1) 
							module:UpdateAll()
						end;
						get = function() return tonumber(GetCVar("nameplateShowEnemyTotems")) == 1 end;
					};
				};
			};
			
			{ -- Elements
				type = "widget";
				element = "Header";
				order = 20;
				msg = L["Elements"];
			};
			{ -- level
				type = "widget";
				element = "CheckButton";
				name = "showLevel";
				order = 21;
				msg = L["Display character level"];
				desc = nil;
				set = function(self) 
					GUIS_DB["nameplates"].showLevel = GetBinary(not(GetBoolean(GUIS_DB["nameplates"].showLevel)))
					module:UpdateAll()
					self:onrefresh()
				end;
				get = function() return GetBoolean(GUIS_DB["nameplates"].showLevel) end;
				onrefresh = function(self) 
					if (GetBoolean(GUIS_DB["nameplates"].showLevel)) then
						self.parent.child.showMaxLevel:Enable()
					else
						self.parent.child.showMaxLevel:Disable()
					end
				end;
				init = function(self) self:onrefresh() end;
			};
			{ -- level at max
				type = "widget";
				element = "CheckButton";
				name = "showMaxLevel";
				order = 22;
				indented = true;
				msg = L["Hide for max level characters when you too are max level"];
				desc = nil;
				set = function(self) 
					GUIS_DB["nameplates"].showMaxLevel = GetBinary(not(GetBoolean(GUIS_DB["nameplates"].showMaxLevel)))
					module:UpdateAll()
				end;
				get = function() return not(GetBoolean(GUIS_DB["nameplates"].showMaxLevel)) end;
			};
			{ -- names
				type = "widget";
				element = "CheckButton";
				name = "showNames";
				order = 23;
				msg = L["Display character names"];
				desc = nil;
				set = function(self) 
					GUIS_DB["nameplates"].showNames = GetBinary(not(GetBoolean(GUIS_DB["nameplates"].showNames)))
					module:UpdateAll()
				end;
				get = function() return GetBoolean(GUIS_DB["nameplates"].showNames) end;
			};
			{ -- combopoints
				type = "widget";
				element = "CheckButton";
				name = "showComboPoints";
				order = 24;
				msg = L["Display combo points on your target"];
				desc = nil;
				set = function(self) 
					GUIS_DB["nameplates"].showComboPoints = GetBinary(not(GetBoolean(GUIS_DB["nameplates"].showComboPoints)))
					module:UpdateAll()
				end;
				get = function() return GetBoolean(GUIS_DB["nameplates"].showComboPoints) end;
			};
			
		};
	};
}

-- @return <boolean> true when the player has active (not finished/failed) quests that require plates
-- 						* also checks if the player is in the correct area
ParseQuestLog = function()
	local areaID, mapId, floorNumber
	local questLogTitleText, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID, startEvent
	for i = 1, (GetNumQuestLogEntries()) do
		questLogTitleText, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID, startEvent = GetQuestLogTitle(i)
		if (questList[questID]) then
			if (isComplete) then
				return
			else
				SetMapToCurrentZone() 
				return ((GetQuestWorldMapAreaID(questID)) == (GetCurrentMapAreaID()))
			end
		end
	end
end

-- updates all plate visibility based on settings
-- @param forced <boolean> force friendly plates on without any checks if true
UpdateAllVisibility = function(self, event, ...)
	local arg1, arg2 = ...
	
--	print(event, InCombatLockdown(), GUIS_DB["nameplates"].showFriendly)

	local InCombat = (event == "PLAYER_REGEN_DISABLED") or InCombatLockdown()
	
	-- decide on friendly plates
	if (GUIS_DB["nameplates"].autoQuest) then
		if (event == "QUEST_ACCEPTED") then 
			-- don't need to check for the correct area when a quest is accepted, because we know we're in it
			if ((arg2) and (questList[arg2])) or ((arg1) and (questList[(select(9, GetQuestLogTitle(arg1)))])) then
				SetCVar("nameplateShowFriends", 1)
				module:PostUpdateGUI()
			else
				SetCVar("nameplateShowFriends", (GUIS_DB["nameplates"].showFriendly) and 1 or 0)
				module:PostUpdateGUI()
			end
		elseif (ParseQuestLog()) then 
			SetCVar("nameplateShowFriends", 1)
			module:PostUpdateGUI()
		else
			if (InCombat) then
				if (GUIS_DB["nameplates"].autoSelect) then
					SetCVar("nameplateShowFriends", (friendlyVisible) and 1 or 0)
					module:PostUpdateGUI()
				else
					SetCVar("nameplateShowFriends", (GUIS_DB["nameplates"].showFriendly) and 1 or 0)
					module:PostUpdateGUI()
				end
			else
				if (GUIS_DB["nameplates"].autoSelect) then
					SetCVar("nameplateShowFriends", (GUIS_DB["nameplates"].friendlyOnlyInCombat) and 0 or (friendlyVisible) and 1 or 0)
					module:PostUpdateGUI()
				else
					if (GUIS_DB["nameplates"].friendlyOnlyInCombat) then
						SetCVar("nameplateShowFriends", 0)
						module:PostUpdateGUI()
					else
						SetCVar("nameplateShowFriends", (GUIS_DB["nameplates"].showFriendly) and 1 or 0)
						module:PostUpdateGUI()
					end
				end
			end
		end
	else
		if (InCombat) then
			if (GUIS_DB["nameplates"].autoSelect) then
				SetCVar("nameplateShowFriends", (friendlyVisible) and 1 or 0)
				module:PostUpdateGUI()
			else
				SetCVar("nameplateShowFriends", (GUIS_DB["nameplates"].showFriendly) and 1 or 0)
				module:PostUpdateGUI()
			end
		else
			if (GUIS_DB["nameplates"].autoSelect) then
				SetCVar("nameplateShowFriends", (GUIS_DB["nameplates"].friendlyOnlyInCombat) and 0 or (friendlyVisible) and 1 or 0)
				module:PostUpdateGUI()
			else
				if (GUIS_DB["nameplates"].friendlyOnlyInCombat) then
					SetCVar("nameplateShowFriends", 0)
					module:PostUpdateGUI()
				else
					SetCVar("nameplateShowFriends", (GUIS_DB["nameplates"].showFriendly) and 1 or 0)
					module:PostUpdateGUI()
				end
			end
		end
	end

	-- decide on enemy plates
	if (InCombat) then
		if (GUIS_DB["nameplates"].autoSelect) then
			SetCVar("nameplateShowEnemies", (enemyVisible) and 1 or 0)
			module:PostUpdateGUI()
		else
			SetCVar("nameplateShowEnemies", GUIS_DB["nameplates"].showEnemy and 1 or 0)
			module:PostUpdateGUI()
		end
	else
		if (GUIS_DB["nameplates"].autoSelect) then
			SetCVar("nameplateShowEnemies", (GUIS_DB["nameplates"].enemyOnlyInCombat) and 0 or (enemyVisible) and 1 or 0)
			module:PostUpdateGUI()
		else
			if (GUIS_DB["nameplates"].enemyOnlyInCombat) then
				SetCVar("nameplateShowEnemies", 0)
				module:PostUpdateGUI()
			else
				SetCVar("nameplateShowEnemies", GUIS_DB["nameplates"].showEnemy and 1 or 0)
				module:PostUpdateGUI()
			end
		end
	end
end

DecideSpecVisibility = function()
	if (F.IsPlayerHealer()) then
		friendlyVisible = true
		enemyVisible = true
	else
		friendlyVisible = false
		enemyVisible = true
	end
end

Strip = function(...)
	local object
	for i = 1, select("#", ...) do
		object = select(i, ...)
		if(object:GetObjectType() == "Texture") then
			object:SetTexture("")
			object.SetTexture = noop
			
		elseif (object:GetObjectType() == "FontString") then
			object.ClearAllPoints = noop
			object.SetFont = noop
			object.SetPoint = noop
			object:Hide()
			object.Show = noop
			object.SetText = noop
			object.SetShadowOffset = noop
		else -- let's try to skip this, as it messes up our inherited updates
--			object:Hide()
--			object.Show = noop
		end
	end
end

-- for some reason wow returns weird colors sometimes, like 0.99999997657567567 instead of 1. Even though you set it to 1.
GetColor = function(r, g, b)
	return floor(r*100 + 0.5)/100, floor(g*100 + 0.5)/100, floor(b*100 + 0.5)/100
end

-- check to see if the frame is a nameplate. 
IsPlate = function(frame)
	if (F.IsBuild(4,3)) then
		return (frame:GetName()) and (strfind(frame:GetName(), "NamePlate"))
	else
		local threatRegion, borderRegion = frame:GetRegions()
		return (borderRegion) and (borderRegion:GetObjectType() == "Texture") and (borderRegion:GetTexture() == BlizzardTexture)
	end
end 

-- returns true of the given nameplate is your current target
PlateIsTarget = function(frame)
	return (frame) and (frame.name) and (UnitName("target") == frame.name:GetText()) and (frame:GetAlpha() == 1)
end

-- returns the number of combopoints what the player controls has on its target
GiveComboPoints = function()
	return GetComboPoints(UnitHasVehicleUI("player") and "vehicle" or "player", "target") or 0
end

local ComboPointFrame
CreateOrUpdateComboPointFrame = function(self)
	local C, M = C, M
	
	-- create the frame if it doesn't exists
	if not(ComboPointFrame) then
		ComboPointFrame = CreateFrame("Frame", nil, self.health) 
		ComboPointFrame:Hide()
		ComboPointFrame:SetSize(self.health:GetWidth() * 9/10, self.health:GetHeight() * 3/4)

		for i = 1,MAX_COMBO_POINTS do
			local CPoint = CreateFrame("Frame", nil, ComboPointFrame)
			CPoint:Hide()
			CPoint:SetSize((ComboPointFrame:GetWidth() - (MAX_COMBO_POINTS - 1) * 1) / MAX_COMBO_POINTS, ComboPointFrame:GetHeight())
			CPoint:SetBackdrop({ bgFile = M["StatusBar"]["StatusBar"] })
			CPoint:SetBackdropColor(0, 0, 0, 3/4)
			CPoint:CreateUIShadow()
		
			CPoint.tex = CPoint:CreateTexture()
			CPoint.tex:SetDrawLayer("OVERLAY", -1)
			CPoint.tex:SetTexture(M["StatusBar"]["StatusBar"])
			CPoint.tex:SetVertexColor(unpack(C["combopointcolors"][i]))
			CPoint.tex:SetPoint("TOP", CPoint, "TOP", 0, -1)
			CPoint.tex:SetPoint("BOTTOM", CPoint, "BOTTOM", 0, 1)
			CPoint.tex:SetPoint("LEFT", CPoint, "LEFT", 1, 0)
			CPoint.tex:SetPoint("RIGHT", CPoint, "RIGHT", -1, 0)

			if (i == 1) then
				CPoint:SetPoint("TOPLEFT", ComboPointFrame, "TOPLEFT", 0, 0)
				
			elseif (i == MAX_COMBO_POINTS) then
				CPoint:SetPoint("LEFT", ComboPointFrame[i - 1], "RIGHT", 1, 0)
				CPoint:SetPoint("BOTTOMRIGHT", ComboPointFrame, "BOTTOMRIGHT", 0, 0)
				
			else
				CPoint:SetPoint("LEFT", ComboPointFrame[i - 1], "RIGHT", 1, 0)
			end
			
			F.GlossAndShade(CPoint)
			
			ComboPointFrame[i] = CPoint
		end
		
		ComboPointFrame:SetScript("OnHide", function(self) 
			for i = 1, MAX_COMBO_POINTS do
				ComboPointFrame[i]:Hide()
			end
		end)
	end

	-- move the frame to the current targeted nameplate
	if not(ComboPointFrame:GetParent() == self) then
		ComboPointFrame:SetParent(self.health)
		ComboPointFrame:ClearAllPoints()
		ComboPointFrame:SetPoint("CENTER", self.health, "BOTTOM", 0, 0)
	end
	
end

PostUpdateComboPoints = function(self, points)
	local isTarget = PlateIsTarget(self)
	local hide
	
	if (GUIS_DB["nameplates"].showComboPoints == 1) then
		if (isTarget) then
			-- the current plate is our target, and it has points, then show them
			if (points > 0) then
				CreateOrUpdateComboPointFrame(self)
				
				ComboPointFrame:Show()
				
				for i = 1,MAX_COMBO_POINTS do
					if (points >= i) then
						ComboPointFrame[i]:Show()
					else
						ComboPointFrame[i]:Hide()
					end
				end
				
			-- the plate is our target, and has no points, so schedule a complete hide
			else
				hide = true
			end
			
		else
			-- the plate is NOT our target, and the player has no points on its target,
			-- or has not target at all, meaning no points should be shown
			if (points == 0) then
				hide = true
			end
		end
	else
		hide = true
	end

	-- all points should be hidden, so let's do it
	if (hide) and (ComboPointFrame) then
		ComboPointFrame:Hide()
	end
end

PostUpdateCastText = function(self, current)
	local min, max = self:GetMinMaxValues()
	
	if (UnitChannelInfo("target")) then
		self.time:SetFormattedText("%.1f ", current)
		self.name:SetText(select(1, (UnitChannelInfo("target"))))
	end
	
	if (UnitCastingInfo("target")) then
		self.time:SetFormattedText("%.1f ", max - current)
		self.name:SetText(select(1, (UnitCastingInfo("target"))))
	end
end

PostUpdateNameLevel = function(self, ...)
	if PlateIsTarget(self) then
		self.name:SetDrawLayer("OVERLAY")
	else
		self.name:SetDrawLayer("BORDER")
	end
end

PostUpdateThreat = function(self, event, ...)
	local C = C
	
	if not(self.threat:IsVisible()) then
			self.health:SetUIShadowColor(C["shadow"][1], C["shadow"][2], C["shadow"][3], 1)
			self.health:SetBackdropColor(0, 0, 0, 3/4)
	else
		local r, g, b = self.threat:GetVertexColor()
		if (g == 0) and (b == 0) then 
				self.health:SetUIShadowColor(C["threat"][1], C["threat"][2], C["threat"][3], 1)
				self.health:SetBackdropColor(C["threat"][1] * 1/3, C["threat"][2] * 1/3, C["threat"][3] * 1/3)
		else
			self.health:SetUIShadowColor(C["lessthreat"][1], C["lessthreat"][2], C["lessthreat"][3], 1)
			self.health:SetBackdropColor(C["lessthreat"][1] * 1/3, C["lessthreat"][2] * 1/3, C["lessthreat"][3] * 1/3)
		end
	end
end

-- the original level text pops back up when drunk.
-- This function isn't being used atm, as we've hidden the old level text
-- by parenting it to an invisible dummy frame. We are smart. Yay us.
PostUpdateDrunk = function(self)
	if (self.oldlevel) and (self.oldlevel:IsShown()) then
		self.oldlevel:Hide()
	end
end

PostUpdateCastBar = function(self)
	local C = C
--	self.castborder:Hide()

	if (self.shield:IsShown()) then
		self:SetUIShadowColor(C["shield"][1], C["shield"][2], C["shield"][3], 1)
		self:SetBackdropBorderColor(C["shield"][1] * 0.33, C["shield"][2] * 0.33, C["shield"][3] * 0.33, 1.00)
	else
		self:SetUIShadowColor(C["shadow"][1], C["shadow"][2], C["shadow"][3], 1)
		self:SetBackdropBorderColor(unpack(C["background"], 1.00))
	end

	self:ClearAllPoints()
	self:SetPoint("TOP", self.health, "BOTTOM", 0, -8)
	self:SetPoint("BOTTOM", self.health, "BOTTOM", 0, -(8 + self.health:GetHeight()))
	self:SetPoint("LEFT", self.health, "LEFT", 0, 0)
	self:SetPoint("RIGHT", self.health, "RIGHT", 0, 0)
end

CastBar_OnValueChanged = function(self, current)
	PostUpdateCastText(self, current)

	if (self.SizeChanged) then
		PostUpdateCastBar(self)
		self.SizeChanged = nil
	end
end

CastBar_OnSizeChanged = function(self)
	self.SizeChanged = true
end

CastBar_OnShow = function(self)
	PostUpdateCastBar(self)
end

CastBar_OnHide = function(self)
	
end

HealthBar_OnValueChanged = function(self)
	self:SetValue(self.oldhealth:GetValue() or 0)
end

HealthBar_OnMinMaxChanged = function(self)
	self:SetMinMaxValues(0, (select(2, self.oldhealth:GetMinMaxValues())) or 0)
end

HealthBar_OnShow = function(self)
	HealthBar_OnMinMaxChanged(self)
	HealthBar_OnValueChanged(self)
end

HealthBar_OnHide = function(self)
--	self:SetUIShadowColor(C["shadow"][1], C["shadow"][2], C["shadow"][3], 1)
--	self:SetBackdropColor(0, 0, 0, 3/4)
--	self.highlight:Hide()
end

PostUpdateColor = function(self)
	if (self.updating) then
		return
	end
	
	local C, FACTION_BAR_COLORS = C, FACTION_BAR_COLORS
	local r, g, b = GetColor(self.oldhealth:GetStatusBarColor())

	for class, color in pairs(RAID_CLASS_COLORS) do
		if (RAID_CLASS_COLORS[class].r == r) and (RAID_CLASS_COLORS[class].g == g) and (RAID_CLASS_COLORS[class].b == b) then
			self.hasClass = true
			self.isFriendly = false
			
			r, g, b = C.RAID_CLASS_COLORS[class].r, C.RAID_CLASS_COLORS[class].g, C.RAID_CLASS_COLORS[class].b
			break
		end
	end
	
	-- hated/hostile npc unit
	if (g + b == 0) then
		r, g, b = FACTION_BAR_COLORS[1].r, FACTION_BAR_COLORS[1].g, FACTION_BAR_COLORS[1].b
		self.isFriendly = false
		self.hasClass = false

	-- neutral (unfriendly...?) npc unit
	elseif (r + g > 1.95) then
		r, g, b = FACTION_BAR_COLORS[4].r, FACTION_BAR_COLORS[4].g, FACTION_BAR_COLORS[4].b
		self.isFriendly = false
		self.hasClass = false
	
	-- friendly npc unit
	elseif (r + b == 0) then
		r, g, b = FACTION_BAR_COLORS[5].r, FACTION_BAR_COLORS[5].g, FACTION_BAR_COLORS[5].b
		self.isFriendly = true
		self.hasClass = false
		
	-- friendly player
	elseif (r + g == 0) then
		r, g, b = FACTION_BAR_COLORS[5].r * 2/3, FACTION_BAR_COLORS[5].g * 2/3, FACTION_BAR_COLORS[5].b * 2/3
		self.isFriendly = true
		self.hasClass = false
		
	-- enemy player
	else
--		self.isFriendly = false
	end

	self.health:SetStatusBarColor(r, g, b)
	self.health:SetBackdropColor(r * 1/3, g * 1/3, b * 1/3, 3/4)
end

PostUpdateBlacklist = function(self)
	if (self:IsShown()) and (GUIS_DB["nameplates"].useBlackList) then
		if (blackList[self.oldname:GetText()]) then
			self:SetScript("OnUpdate", noop)
			self.health:Hide()
			self.cast:Hide()
		end
	end
end

PostUpdate = function(self)
	local C, RARE = C, RARE
	local level, elite, mylevel = tonumber(self.oldlevel:GetText()), self.dragon:IsShown(), UnitLevel("player")
	local classy, color, r, g, b
	
	PostUpdateBlacklist(self)
	PostUpdateColor(self)
	
	self.highlight:ClearAllPoints()
	self.highlight:SetAllPoints(self.health)
	
	self.cast:SetSize(plateWidth, castHeight)
	self.cast:ClearAllPoints()
	self.cast:SetPoint("TOPLEFT", self.health, "BOTTOMLEFT", 0, -8)
	
	if (GUIS_DB["nameplates"].showNames == 0) then
		self.name:Hide()
	else
		self.name:Show()
		self.name:SetText(self.oldname:GetText())
	end
	
	if (self.boss:IsShown()) or not(level) then
		return
	else

		if (GUIS_DB["nameplates"].showLevel == 0) then
			if (self.level:IsShown()) then
				self.level:Hide()
			end
			
			return
		
		-- don't show the nameplates if they are the same level as you
		else
			-- hide it at max level, if you are max level too
			-- hotfix for the MoP account level bug in Cata July 25th 2012
			local accountLevel = GetAccountExpansionLevel()
			local MAX_PLAYER_LEVEL = accountLevel and MAX_PLAYER_LEVEL_TABLE[accountLevel] or UnitLevel("player") 

			local hide = (GUIS_DB["nameplates"].showMaxLevel == 0) and (level >= MAX_PLAYER_LEVEL) and (mylevel >= MAX_PLAYER_LEVEL)
			
			if (hide) then
				if (self.level:IsShown()) then
					self.level:Hide()
				end
			else
				if not(self.level:IsShown()) then
					self.level:Show()
				end
			end
		end
		
		-- if possible we color the level text, 
		-- since WoW doesn't appear to do this at the initial display of a nameplate
		if (level > 0) then
			color = GetQuestDifficultyColor(level)
		end
		
		if (elite) then
			-- We're gambling on rares being identified by the vertexcolor of the elite dragon texture
			-- The WoW texture is gold, a white vertex means it remains gold, and thus is a "normal" elite
			r, g, b = GetColor(self.dragon:GetVertexColor())
		end
		
		if (color) then
			if (classy) then
				if (r + g + b == 3) then
					self.level:SetFormattedText("|cFF%s%d|r|cFF%s+|r", RGBToHex(color.r, color.g, color.b), level, RGBToHex(C["boss"].r, C["boss"].g, C["boss"].b))
				else
					self.level:SetFormattedText("|cFF%s%d|r|cFF%s+ %s|r", RGBToHex(color.r, color.g, color.b), level, RGBToHex(C["boss"].r, C["boss"].g, C["boss"].b), RARE)
				end
			else
				self.level:SetFormattedText("|cFF%s%d|r", RGBToHex(color.r, color.g, color.b), level)
			end
		else
			self.level:SetText("")
		end
	end
end

OnHide = function(self)
	self:SetScript("OnUpdate", nil)
	
	self.health:Show()
	self.cast:Hide()
end

local dummy = CreateFrame("Frame")
dummy:Hide()

Style = function(f)
	if (nameplates[f]) then
		return 
	end
	
	local C, M = C, M
	local castbar, castborder, shield, casticon
	local threat, border, highlight, name, level, boss, raid, dragon
	
	local health, cast = f:GetChildren()

	-- the structure of the nameplates changed in 4.1.0
	if (F.IsBuild(4,1)) then
		castbar, castborder, shield, casticon = cast:GetRegions()
		threat, border, highlight, name, level, boss, raid, dragon = f:GetRegions()
	else
		threat, border, castborder, shield, casticon, highlight, name, level, boss, raid, dragon = f:GetRegions()
	end
	
	-- fix the scaling issue with WorldFrame
	-- anything parented to 'f' needs to apply this scale, 
	-- but not 'f' itself, as that will change its position as well as scale
	f.scale = WorldFrame:GetHeight()/UIParent:GetHeight()
	
	-- strip away all the Blizzard stuff we don't want
	Strip(name, level, threat, border, castborder, shield, boss, dragon, health)

	-- these objects don't update the way we like, 
	-- so we're hiding them and making our own instead
	level:SetParent(dummy)
	health:SetParent(dummy)
	name:SetParent(dummy)

	-- references to the original objects
	f.oldhealth = health
	f.oldname = name
	f.oldlevel = level

	f.cast = cast
	f.casticon = casticon
--	f.castborder = castborder
	f.shield = shield
	f.boss = boss
	f.dragon = dragon
	f.raid = raid
	f.threat = threat
	f.highlight = highlight
	
	--------------------------------------------------------------------------------------------------
	--		HealthBar
	--------------------------------------------------------------------------------------------------
	f.health = CreateFrame("StatusBar", nil, f)
	f.health:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 4, 4)
	f.health:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	f.health:SetSize(plateWidth, plateHeight)
	f.health:SetBackdrop({ bgFile = M["StatusBar"]["StatusBar"] })
	f.health:SetBackdropColor(0, 0, 0, 3/4)
	f.health:CreateUIShadow(5)
	f.health:SetUIShadowColor(C["shadow"][1], C["shadow"][2], C["shadow"][3], 1)
	f.health:SetScale(f.scale)

	f.health.Shade = f.health:CreateTexture()
	f.health.Shade:SetDrawLayer("OVERLAY", 1)
	f.health.Shade:SetTexture(M["Button"]["Shade"])
	f.health.Shade:SetVertexColor(0, 0, 0, 1/5)
	f.health.Shade:SetAllPoints(f.health)

	f.health.Gloss = f.health:CreateTexture()
	f.health.Gloss:SetDrawLayer("OVERLAY", 2)
	f.health.Gloss:SetTexture(M["Button"]["Gloss"])
	f.health.Gloss:SetVertexColor(1, 1, 1, 1/5)
	f.health.Gloss:SetAllPoints(f.health)

	f.health.oldhealth = f.oldhealth
	
	tinsert(scalefixes, f.health)

	--------------------------------------------------------------------------------------------------
	--		Texts (their parent objects are scaled, so no need to add that here)
	--------------------------------------------------------------------------------------------------
	f.name = f.health:CreateFontString(nil, "OVERLAY")
	f.name:ClearAllPoints()
	f.name:SetPoint("BOTTOM", f.health, "TOP", 0, 4)
	f.name:SetFontObject(GUIS_SystemFontNormalWhite)

	f.level = f.health:CreateFontString(nil, "OVERLAY")
	f.level:ClearAllPoints()
	f.level:SetPoint("LEFT", f.health, "RIGHT", 4, 0)
	f.level:SetFontObject(GUIS_SystemFontNormalWhite)
	
	f.cast.name = f.cast:CreateFontString(nil, "OVERLAY")
	f.cast.name:ClearAllPoints()
	f.cast.name:SetPoint("TOP", f.cast, "BOTTOM", 0, -4)
	f.cast.name:SetFontObject(GUIS_SystemFontSmallWhite)

	f.cast.time = f.cast:CreateFontString(nil, "OVERLAY")
	f.cast.time:SetFontObject(GUIS_NumberFontNormal)
	f.cast.time:SetPoint("TOPRIGHT", f.casticon, "TOPLEFT", -4, 0)
	
	--------------------------------------------------------------------------------------------------
	--		CastBar
	--------------------------------------------------------------------------------------------------
	f.cast:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	f.cast:SetSize(plateWidth, castHeight)
	f.cast:ClearAllPoints()
	f.cast:SetPoint("TOP", f.health, "BOTTOM", 0, -6)
	f.cast:SetPoint("BOTTOM", f.health, "BOTTOM", 0, -(6 + f.health:GetHeight()))
	f.cast:SetPoint("LEFT", f.health, "LEFT", 0, 0)
	f.cast:SetPoint("RIGHT", f.health, "RIGHT", 0, 0)
	f.cast:SetBackdrop({ bgFile = M["StatusBar"]["StatusBar"] })
	f.cast:SetBackdropColor(0, 0, 0, 3/4)
	f.cast:SetBackdropBorderColor(unpack(C["background"], 1.00))
	f.cast:CreateUIShadow(5)
	f.cast:SetUIShadowColor(C["shadow"][1], C["shadow"][2], C["shadow"][3], 1)
	f.cast:SetScale(f.scale)

	f.cast.Shade = f.cast:CreateTexture()
	f.cast.Shade:SetDrawLayer("OVERLAY", 1)
	f.cast.Shade:SetTexture(M["Button"]["Shade"])
	f.cast.Shade:SetVertexColor(0, 0, 0, 1/5)
	f.cast.Shade:SetAllPoints(f.cast)

	f.cast.Gloss = f.cast:CreateTexture()
	f.cast.Gloss:SetDrawLayer("OVERLAY", 2)
	f.cast.Gloss:SetTexture(M["Button"]["Gloss"])
	f.cast.Gloss:SetVertexColor(1, 1, 1, 1/3)
	f.cast.Gloss:SetAllPoints(f.cast)

	tinsert(scalefixes, f.cast)

	f.cast.health = f.health
--	f.cast.castborder = f.castborder
	f.cast.shield = f.shield
	
	--------------------------------------------------------------------------------------------------
	--		Highlight
	--------------------------------------------------------------------------------------------------
	f.highlight:ClearAllPoints()
	f.highlight:SetAllPoints(f.health)
	f.highlight:SetParent(f.health)
	f.highlight:SetTexture(M["StatusBar"]["StatusBar"])
	f.highlight:SetDrawLayer("OVERLAY")

	--------------------------------------------------------------------------------------------------
	--		Icons 
	--------------------------------------------------------------------------------------------------
	f.raid:ClearAllPoints()
	f.raid:SetPoint("BOTTOM", f.name, "TOP", 0, 4)
	f.raid:SetSize(24, 24)
	f.raid:SetParent(f.health)
	f.raid:SetTexture(M["Icon"]["RaidTarget"])
	
	f.boss:ClearAllPoints()
	f.boss:SetPoint("LEFT", f.health, "RIGHT", 4, 0)
	f.boss:SetSize(16, 16)
	f.boss:SetParent(f.health)
	
	local size = f.health:GetHeight() + f.cast:GetHeight() + 8
	f.casticon:SetParent(f.cast)
	f.casticon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
	f.casticon:ClearAllPoints()
	f.casticon:SetPoint("BOTTOMRIGHT", f.cast, "BOTTOMLEFT", -6, 0)
	f.casticon:SetSize(size, size)

	f.cast.iconcandyLayer = CreateFrame("Frame", nil, f.cast)
	f.cast.iconcandyLayer:SetAllPoints(f.casticon)
	F.GlossAndShade(f.cast.iconcandyLayer)
	
	f.casticon.Backdrop = f.cast:CreateUIPanel()
	f.casticon.Backdrop:SetBackdrop(M["Backdrop"]["Border"])
	f.casticon.Backdrop:SetBackdropColor(0, 0, 0, 0)
	f.casticon.Backdrop:SetBackdropBorderColor(unpack(C["background"], 1.00))
	f.casticon.Backdrop:CreateUIShadow(5)
	f.casticon.Backdrop:SetUIShadowColor(C["shadow"][1], C["shadow"][2], C["shadow"][3], 1)
	f.casticon.Backdrop:ClearAllPoints()
	f.casticon.Backdrop:SetPoint("LEFT", f.casticon, 0, -1)
	f.casticon.Backdrop:SetPoint("RIGHT", f.casticon, 0, 1)
	f.casticon.Backdrop:SetPoint("TOP", f.casticon, 0, 1)
	f.casticon.Backdrop:SetPoint("BOTTOM", f.casticon, 0, -1)

	--------------------------------------------------------------------------------------------------
	--		Stuff
	--------------------------------------------------------------------------------------------------
	nameplates[f] = true
	
	-- make sure the name of our target is in front of other nameplates,
	-- and that the min/max/current values are actually correct
	RegisterCallback("PLAYER_TARGET_CHANGED", function() 
		HealthBar_OnShow(f.health)
		PostUpdateNameLevel(f) 
	end)
	
	RegisterCallback("UNIT_TARGET", function(self, event, arg) 
		if (arg == "player") then
			HealthBar_OnShow(f.health)
			PostUpdateNameLevel(f) 
		end
	end)

	RegisterCallback("PLAYER_ENTERING_WORLD", function() 
		HealthBar_OnShow(f.health)
		PostUpdateNameLevel(f) 
		PostUpdate(f)
	end)

	f.health:SetScript("OnShow", function()
		HealthBar_OnShow(f.health)
		PostUpdateNameLevel(f) 
		PostUpdate(f)
	end)
	
	f.health:SetScript("OnHide", HealthBar_OnHide)
	f.health:SetScript("OnValueChanged", HealthBar_OnValueChanged)

--	f.oldhealth:SetScript("OnUpdate", nil) 
	f.oldhealth:HookScript("OnShow", function() f.health:Show() end)
	f.oldhealth:HookScript("OnHide", function() f.health:Hide() end)
	f.oldhealth:HookScript("OnValueChanged", function(self, ...) HealthBar_OnValueChanged(f.health, ...) end) 
	f.oldhealth:HookScript("OnMinMaxChanged", function(self, ...) HealthBar_OnMinMaxChanged(f.health, ...) end) 
		
	f.cast:HookScript("OnShow", CastBar_OnShow)
	f.cast:HookScript("OnHide", CastBar_OnHide)
	f.cast:HookScript("OnSizeChanged", CastBar_OnSizeChanged)
	f.cast:HookScript("OnValueChanged", CastBar_OnValueChanged)

	f:HookScript("OnHide", OnHide)
	
	-- initial updates
	HealthBar_OnShow(f.health)
	PostUpdate(f)
	CastBar_OnShow(f.cast)
end

-- the lengths we go to for pixel perfection...
UpdateScales = function(self, event, ...)
	local scale = WorldFrame:GetHeight()/UIParent:GetHeight()
	for _,object in pairs(scalefixes) do
		object:SetScale(scale)
	end
end

ForEachPlate = function(func, ...)
	for plate,_ in pairs(nameplates) do
		if (plate:IsShown()) then
			func(plate, ...)
		end
	end
end

module.plates = 0
ScanForPlates = function(self)
	local nameplates = nameplates
	local i, f, kids
	kids = select("#", WorldFrame:GetChildren())
	
	if (kids ~= self.plates) then
		for i = 1, kids do
			f = select(i, WorldFrame:GetChildren())

			if (IsPlate(f)) and not(nameplates[f]) then
				Style(f)
			end
		end
		self.plates = kids
	end
end

UpdatePlates = function(self)
	ForEachPlate(PostUpdateThreat)
	ForEachPlate(PostUpdateComboPoints, GiveComboPoints() or 0)
--	ForEachPlate(UpdateAllVisibility) -- too resource demanding?
--	ForEachPlate(PostUpdateBlacklist)
end

module.UpdateAll = function(self)
	-- visibility
	DecideSpecVisibility()
	UpdateAllVisibility()
	
	-- elements
	ForEachPlate(PostUpdate)
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName(self:GetName()))
end

module.RestoreDefaults = function(self)
	GUIS_DB["nameplates"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["nameplates"] = GUIS_DB["nameplates"] or {}
	GUIS_DB["nameplates"] = ValidateTable(GUIS_DB["nameplates"], defaults)
end

module.OnInit = function(self)
	if (F.kill(self:GetName())) then 
		self:Kill()
		return 
	end
	
	-- the scan timer. we want to discover new plates fairly fast
	-- to avoid seeing the original blizzard ones
	ScheduleTimer(ScanForPlates, 1/20, nil, nil)
	
	-- other updates that doesn't need to occur as often
	ScheduleTimer(UpdatePlates, 1/5, nil, nil)
	
	-- visibility update, only called once a second
	-- we need this, because sometimes nameplates aren't 
	-- properly displayed after your initial login
	ScheduleTimer(UpdateAllVisibility, 1, nil, nil)

	-- make sure the scales are updated properly on resolution changes
	RegisterCallback("DISPLAY_SIZE_CHANGED", UpdateScales)
	RegisterCallback("PLAYER_ENTERING_WORLD", UpdateScales)
	RegisterCallback("UI_SCALE_CHANGED", UpdateScales)

	-- initial visibility setup
	DecideSpecVisibility()
	UpdateAllVisibility()

	-- update on talentchange
	local updateOnTalents = function(...)
		DecideSpecVisibility(...)
		UpdateAllVisibility(...)
	end
	RegisterCallback("PLAYER_ALIVE", updateOnTalents) -- needed to ensure nameplate display on login
	RegisterCallback("ACTIVE_TALENT_GROUP_CHANGED", updateOnTalents) 
	RegisterCallback("PLAYER_TALENT_UPDATE", updateOnTalents) 
	RegisterCallback("TALENTS_INVOLUNTARILY_RESET", updateOnTalents) 

	-- update on zone change and quest log updates
	RegisterCallback("PLAYER_REGEN_ENABLED", UpdateAllVisibility)
	RegisterCallback("PLAYER_REGEN_DISABLED", UpdateAllVisibility)
	RegisterCallback("PLAYER_ENTERING_WORLD", UpdateAllVisibility)
	RegisterCallback("ZONE_CHANGED_NEW_AREA", UpdateAllVisibility)
	RegisterCallback("QUEST_ACCEPTED", UpdateAllVisibility)
	
	-- throttling this one, it is spammy
	RegisterBucketEvent({"QUEST_LOG_UPDATE"}, 1, UpdateAllVisibility)
	
	-- create the options menu
	do
		local restoreDefaults = function()
			if (InCombatLockdown()) then 
				print(L["Can not apply default settings while engaged in combat."])
				return
			end
			
			-- restore all frame positions
			self:RestoreDefaults()
			
			-- request a restart if needed
			F.RestartIfScheduled()
		end
		
		local cancelChanges = function()
		end
		
		local applySettings = function()
		end
		
		local applyChanges = function()
		end
		
		local gOM = LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu")
		gOM:RegisterWithBlizzard(gOM:New(menuTable, true), F.getName(self:GetName()), 
 			"default", restoreDefaults, 
			"cancel", cancelChanges, 
			"okay", applyChanges)
			
		RegisterCallback("PLAYER_ENTERING_WORLD", function() module:PostUpdateGUI() end)
		RegisterCallback("VARIABLES_LOADED", function() module:PostUpdateGUI() end)
		RegisterCallback("CVAR_UPDATE", function(self, event, global, value) 
			if (globalCVarString[global]) then
--				module:UpdateAll()
				module:PostUpdateGUI() 
			end
		end)
		
		if (SetNamePlateMotionType) then
			hooksecurefunc("SetNamePlateMotionType", function() module:PostUpdateGUI() end)
		end
		
		hooksecurefunc("SetCVar", function(cvar, value) 
			if (cvarList[cvar]) then
--				module:UpdateAll()
				module:PostUpdateGUI() 
			end
		end)
	end
end
