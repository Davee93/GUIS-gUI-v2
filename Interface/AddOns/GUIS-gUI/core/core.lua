--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local oUF = ns.oUF or oUF

local gCore = LibStub("gCore-3.0")
local GUIS = LibStub("gCore-3.0"):NewModule("GUIS-gUI: Core")
GUIS.AddOn = addon

-- Lua API
local tonumber, type = tonumber, type
local gsub = gsub
local unpack = unpack

-- WoW API
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local ReloadUI = ReloadUI
local StaticPopup_Show = StaticPopup_Show

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local gFH = LibStub("gFrameHandler-1.0")
local CreateChatCommand = function(...) GUIS:CreateChatCommand(...) end
local RegisterCallback = function(...) GUIS:RegisterCallback(...) end
local UnregisterCallback = function(...) GUIS:UnregisterCallback(...) end
local FireCallback = function(...) GUIS:FireCallback(...) end
local ScheduleTimer = function(...) GUIS:ScheduleTimer(...) end

local ADDON_NAME = GetAddOnMetadata(addon, "Title") -- .. "|cFFFFFFFF™|r"
GUIS.ADDON_NAME = ADDON_NAME

_G.GUIS = GUIS
_G.GUIS_DB = _G.GUIS_DB or {}
_G.GUIS_VERSION = _G.GUIS_VERSION or {}
_G.GUIS_SAVED_FRAME_POSITIONS = _G.GUIS_SAVED_FRAME_POSITIONS or {}

local load, disable, moduleToName
local warned, scheduledRestart
local saveFramePositions
local applyToAllModules, forAllModules

-- general interface options
local defaults = {
	useFullScreenLogo = false;
	useFullScreenFade = true;
}

local defaultVersion = {
	version 		= -1;
	subversion 	= -1;
	build 		= -1;
	Initialized = false;
}

local NEVER = "|cFFFF0000" .. L["Never"] .. "|r"
local DEFAULT = "|cFFFFD100" .. L["Default"] .. "|r"
local ALWAYS = "|cFF00FF00" .. L["Always"] .. "|r"
local MODULE_TOOLTIP = { 
	L["Load Module"], " ", 
	NEVER, "|cFFFFFFFF" .. L["Never load this module"] .. "|r", " ", 
	DEFAULT, "|cFFFFFFFF" .. L["Load this module unless an addon with similar functionality is detected"] .. "|r", " ", 
	ALWAYS, "|cFFFFFFFF" .. L["Always load this module, regardles of what other addons are loaded"] .. "|r", " ", 
	F.warning(L["Requires the UI to be reloaded!"]) 
}

local menuTable = {
	{
		type = "group";
		name = GUIS:GetName();
		order = 1;
		virtual = true;
		children = {
			{
				type = "widget";
				element = "Title";
				order = 1;
				msg = L["General"];
			};
			{
				type = "group";
				order = 10;
				virtual = true;
				children = {
					{
						type = "widget";
						element = "Header";
						order = 1;
						msg = L["UI Scale"];
					};
					{
						type = "widget";
						element = "CheckButton";
						order = 5;
						msg = L["Use UI Scale"];
						desc = { L["UI Scale"], L["Check to use the UI Scale Slider, uncheck to use the system default scale."], " ", F.warning(L["Using custom UI scaling is not recommended. It will produce fuzzy borders and incorrectly sized objects."]) };
						set = function(self) 
							if not(self:GetChecked()) then
								SetCVar("useUiScale", 0)
								self.parent.child.uiSlider:Disable()
								
							else
								SetCVar("useUiScale", 1)
								self.parent.child.uiSlider:Enable()
							end
						end;
						get = function() return (tonumber(GetCVar("useUiScale")) == 1) end;
						init = function(self) 
							RegisterCallback("PLAYER_ENTERING_WORLD", function() 
								self:SetChecked(tonumber(GetCVar("useUiScale")) == 1)
							end)
						end;
					};
					{
						type = "widget";
						element = "Slider";
						name = "uiSlider";
						order = 10;
						width = "minimum";
						msg = nil;
						desc = { L["UI Scale"], L["Changes the size of the game’s user interface."], " ", F.warning(L["Using custom UI scaling is not recommended. It will produce fuzzy borders and incorrectly sized objects."]) };
						set = function(self, value) 
							if not(self.parent.child.applyButton:IsEnabled()) then
								self.parent.child.applyButton:Enable()
							end
							
							self.text:SetText(("%.2f"):format(value))
						end;
						get = function(self)
							return tonumber(GetCVar("uiScale"))
						end;
						ondisable = function(self)
							self:SetAlpha(3/4)
							self.low:SetTextColor(unpack(C["disabled"]))
							self.high:SetTextColor(unpack(C["disabled"]))
							self.text:SetTextColor(unpack(C["disabled"]))
							
							self:EnableMouse(false)

							if (self.parent.child.applyButton:IsEnabled()) then
								self.parent.child.applyButton:Disable()
							end
						end;
						onenable = function(self)
							self:SetAlpha(1)
							self.low:SetTextColor(unpack(C["value"]))
							self.high:SetTextColor(unpack(C["value"]))
							self.text:SetTextColor(unpack(C["index"]))
							
							self:EnableMouse(true)

							if (self:GetValue() ~= tonumber(GetCVar("useUiScale"))) then
								if not(self.parent.child.applyButton:IsEnabled()) then
									self.parent.child.applyButton:Enable()
								end
							end
						end;
						init = function(self)
							if (tonumber(GetCVar("useUiScale")) ~= 1) then
								self:Disable()
							end
							
							local min, max, value = 0.64, 1, self:get()
							self:SetMinMaxValues(min, max)
							self.low:SetText(min)
							self.high:SetText(max)

							if (value) then
								self:SetValue(value)
								self.text:SetText(("%.2f"):format(value))
								if (self:IsEnabled()) then
									self:onenable()
								else
									self:ondisable()
								end
							else
								local callback
								callback = RegisterCallback("PLAYER_ENTERING_WORLD", function() 
									local min, max, value = 0.64, 1, self:get()
									self:SetMinMaxValues(min, max)
									self:SetValue(value) 
									self.text:SetText(("%.2f"):format(value))
									if (self:IsEnabled()) then
										self:onenable()
									else
										self:ondisable()
									end
	
									if (callback) then
										UnregisterCallback(callback)
										callback = nil
									end
								end)
							end
						end;
					};
					{
						type = "widget";
						element = "Button";
						name = "applyButton";
						width = "minimum";
						order = 100;
						msg = L["Apply"];
						desc = { L["Apply the new UI scale."], " ", F.warning(L["Using custom UI scaling is not recommended. It will produce fuzzy borders and incorrectly sized objects."]) };
						set = function(self)
							SetCVar("uiScale", self.parent.child.uiSlider:GetValue())
							--RestartGx()
						end;
						get = noop;
						init = function(self)
							if (tonumber(GetCVar("useUiScale")) ~= 1) then
								self:Disable()
							end
						end;
					};
				};
			};
			{
				type = "group";
				order = 20;
				virtual = true;
				children = {
					{
						type = "widget";
						element = "Title";
						order = 1;
						msg = L["Module Selection"]; -- ENABLE DISABLE ALL NONE DEFAULT ALWAYS NEVER
					};
					{
						type = "widget";
						element = "Text";
						order = 5;
						msg = L["Choose which modules should be loaded, and when."];
					};
					{ -- actionbars
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["ActionBars"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: ActionBars"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: ActionBars"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- actionbuttons
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["ActionButtons"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: ActionButtons"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: ActionButtons"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- auras
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["Auras"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: Auras"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: Auras"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- bags
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["Bags"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: Bags"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: Bags"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- castbars
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["Castbars"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: Castbars"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: Castbars"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- chat
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["Chat"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: Chat"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: Chat"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- combat dps/heal/threat
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["Combat"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: Combat"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: Combat"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- combatlog
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["CombatLog"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: CombatLog"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: CombatLog"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- minimap
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["Minimap"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: Minimap"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: Minimap"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- nameplates
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["Nameplates"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: Nameplates"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: Nameplates"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- status
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["World Status"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: Status"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: Status"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- tooltips
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["Tooltips"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: Tooltip"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: Tooltip"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- errors
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["Errors"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: UIError"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: UIError"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- ui panels
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["UI Panels"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: UIPanels"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: UIPanels"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- ui skinning
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["UI Skinning"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: UISkinning"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: UISkinning"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- unitframes
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["UnitFrames"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: UnitFrames"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: UnitFrames"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- Quest
						type = "widget";
						element = "Dropdown";
						order = 100;
						width = "half";
						msg = L["Quests"];
						desc = MODULE_TOOLTIP;
						args = { NEVER, DEFAULT, ALWAYS };
						set = function(self, option)
							GUIS_DB.load["GUIS-gUI: Quest"] = UIDropDownMenu_GetSelectedID(self) - 1
							F.ScheduleRestart()
						end;
						get = function(self) return GUIS_DB.load["GUIS-gUI: Quest"] + 1 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
				};
			};
		};
	};
}

local faq = {
	{
		q = L["I wish to move something! How can I change frame positions?"];
		a = {
			{
				type = "text";
				msg = L["A lot of frames can be moved to custom positions. You can unlock them all for movement by typing |cFF4488FF/glock|r followed by the Enter key, and lock them with the same command. There are also multiple options available when right-clicking on the overlay of the movable frame."];
			};
			{
				type = "image";
				w = 512; h = 256;
				path = M["Texture"]["Core-FrameLock"]
			};
		};
		tags = { "positioning", "actionbars", "castbars", "reputation", "experience", "auras", "minimap", "quest tracker", "buffs", "debuffs", "panels", "unitframes", "party", "raid", "arena", "boss", "focus target" };
	};
	{
		q = L["I can't close the Talent Frame when pressing 'N'"];
		a = {
			{
				type = "text";
				msg = L["But you can still close it!|n|nYou can close it with the Escacpe key, or the closebutton located in he upper right corner of the Talent Frame.|n|nWhen closing the Talent Frame with the original keybind to toggle it, it becomes 'tainted'. This means that the game considers it to be 'insecure', and you won't be allowed to do actions like for example changing your glyphs. This only happens when closed with the hotkey, not when it's closed by the Escape key or the closebutton.|n|nBy reassigning your Talent Frame keybind to a function that only opens the frame, not toggles it, we have made sure that it gets closed the proper way, and you can continue to change your glyphs as intended."];
			};
		};
		tags = { "talents", "keybinds" }; 
	};
}

-- GUIS_DB.load["GUIS-gUI: UISkinning"]
-- default load status of all the modules
-- modules not included in this list will ALWAYS be loaded
-- 	0 = never, 1 = load unless autodisabled, 2 = load always
load = {
	["GUIS-gUI: ActionBars"] 				= 1; -- actionbars
	["GUIS-gUI: ActionButtons"] 			= 1; -- action button styling
	["GUIS-gUI: Auras"] 						= 1; -- buffs/debuffs/weapon enchants
	["GUIS-gUI: Bags"] 						= 1; -- bags
	["GUIS-gUI: Castbars"] 					= 1; -- mirror bars, timer bars, etc (more to come)
	["GUIS-gUI: Chat"] 						= 1; -- chatframes, chat abbreviations, telltarget, etc
	["GUIS-gUI: Combat"] 					= 1; -- dps/heal/threat meters, scrolling combat text, etc 
	["GUIS-gUI: CombatLog"] 				= 1; -- combat log filter
	["GUIS-gUI: GroupTools"] 				= 1; -- party-, raid- and groupleadertools
	["GUIS-gUI: Loot"] 						= 1; -- loot and group roll 
	["GUIS-gUI: Minimap"] 					= 1; -- the minimap
	["GUIS-gUI: Nameplates"] 				= 1; -- unit nameplates
	["GUIS-gUI: Status"] 					= 1; -- various floating stuff like rep, xp, watchframe, vehicleseat, durability, world score
	["GUIS-gUI: Tooltip"] 					= 1; -- tooltips and dropdown menus
	["GUIS-gUI: UIError"] 					= 1; -- red error text
	["GUIS-gUI: UIPanels"] 					= 1; -- all the "free" ui panels
	["GUIS-gUI: UISkinning"] 				= 1; -- visual skinning and upgrades to the rest of the blizzard UI
	["GUIS-gUI: UnitFrames"] 				= 1; -- unitframes
	["GUIS-gUI: UnitFramesParty"] 		= 1; -- partyframes
	["GUIS-gUI: UnitFramesArena"] 		= 1; -- arenaframes
	["GUIS-gUI: UnitFramesBoss"] 			= 1; -- bossframes
	["GUIS-gUI: UnitFramesRaid"] 			= 1; -- raidframes
	["GUIS-gUI: UnitFramesMainTank"] 	= 1; -- maintank/mainassist
	["GUIS-gUI: Quest"] 						= 1; -- quest- and achievement tracker
}

-- 
-- localized module display names
moduleToName = {
	["GUIS-gUI: ActionBars"] 				= L["ActionBars"];
	["GUIS-gUI: ActionButtons"] 			= L["ActionButtons"];
	["GUIS-gUI: Auras"] 						= L["Auras"];
	["GUIS-gUI: Bags"] 						= L["Bags"];
	["GUIS-gUI: Castbars"] 					= L["Castbars"];
	["GUIS-gUI: Core"] 						= L["Core"];
	["GUIS-gUI: Chat"] 						= L["Chat"];
	["GUIS-gUI: Combat"] 					= L["Combat"];
	["GUIS-gUI: CombatLog"] 				= L["CombatLog"];
	["GUIS-gUI: FAQ"] 						= L["FAQ"];
--	["GUIS-gUI: GroupTools"] 				= L["XXXX"];
	["GUIS-gUI: Loot"] 						= L["Loot"];
	["GUIS-gUI: Merchant"] 					= L["Merchants"];
	["GUIS-gUI: Minimap"] 					= L["Minimap"];
	["GUIS-gUI: Nameplates"] 				= L["Nameplates"];
	["GUIS-gUI: Status"] 					= L["World Status"];
	["GUIS-gUI: Tooltip"] 					= L["Tooltips"];
	["GUIS-gUI: UIError"] 					= L["Errors"];
	["GUIS-gUI: UIPanels"] 					= L["UI Panels"];
	["GUIS-gUI: UISkinning"] 				= L["UI Skinning"];
	["GUIS-gUI: UnitFrames"] 				= L["UnitFrames"];
	["GUIS-gUI: UnitFramesParty"] 		= L["PartyFrames"];
	["GUIS-gUI: UnitFramesArena"] 		= L["ArenaFrames"];
	["GUIS-gUI: UnitFramesBoss"] 			= L["BossFrames"];
	["GUIS-gUI: UnitFramesRaid"] 			= L["RaidFrames"];
--	["GUIS-gUI: UnitFramesMainTank"] 	= L["MainTankFrames"];
	["GUIS-gUI: Quest"] 						= L["Quests"];
}

--
-- autodisable list for modules that have their load status set to '1'
disable = {
	["GUIS-gUI: ActionBars"] = {
		["Bartender4"] = true;
		["Dominos"] = true;
		["Macaroon"] = true;
		["RazerNaga"] = true;
	};
	
	["GUIS-gUI: ActionButtons"] = {
		["Bartender4"] = true;
		["ButtonFacade"] = true;
		["Dominos"] = true;
		["Macaroon"] = true;
		["RazerNaga"] = true;
	};
	
	["GUIS-gUI: Auras"] = {
		["ElkBuffBars"] = true;  
		["SatrinaBuffFrame"] = true;  
	};

	["GUIS-gUI: Bags"] = {
		["AdiBags"] = true;
		["ArkInventory"] = true;
		["Bagnon"] = true;
		["Baggins"] = true;
		["BaudBag"] = true;
		["cargBags_Nivaya"] = true;
		["cargBags_Simplicity"] = true;
		["Combuctor"] = true;
		["famBags"] = true;
		["gBags"] = true;
		["OneBag3"] = true;
		["OneBank3"] = true;
		["TBag"] = true;
	};
	
	["GUIS-gUI: Castbars"] = {
		["Quartz"] = true;
	};
	
	["GUIS-gUI: Chat"] = {
		["Chatter"] = true;
		["Prat-3.0"] = true;
	};
	
	["GUIS-gUI: Loot"] = {
		["gLoot"] = true;
	};
	
	["GUIS-gUI: Minimap"] = {
--		["Carbonite"] = true;
		["SexyMap"] = true;
	};
	
	["GUIS-gUI: Nameplates"] = {
		["Aloft"] = true;
		["DocsUI_Nameplates"] = true;
		["Headline"] = true;
		["knameplates"] = true;
		["mNameplates"] = true;
		["TidyPlates"] = true;
	};
	
	["GUIS-gUI: Tooltip"] = {
		["StarTip"] = true;
		["TinyTip"] = true;
		["TipTac"] = true;
	};
	
	["GUIS-gUI: UnitFrames"] = {
		["ag_UnitFrames"] = true;
		["PitBull4"] = true;
		["ShadowedUnitFrames"] = true;
		["XPerl"] = true;
	};
	
	["GUIS-gUI: UnitFramesParty"] = {
		["ag_UnitFrames"] = true;
--		["Grid"] = true;
--		["Grid2"] = true;
--		["Healbot"] = true;
--		["Healium"] = true;
		["PitBull4"] = true;
		["ShadowedUnitFrames"] = true;
		["XPerl"] = true;
	};
	
	["GUIS-gUI: UnitFramesRaid"] = {
		["ag_UnitFrames"] = true;
		["CompactRaid"] = true;
--		["Grid"] = true;
--		["Grid2"] = true;
--		["Healium"] = true;
		["PitBull4"] = true;
		["ShadowedUnitFrames"] = true;
		["VuhDo"] = true;
		["XPerl"] = true;
	};
	
	["GUIS-gUI: UnitFramesArena"] = {
		["ArenaUnitFrames"] = true;
		["Gladius"] = true;
	};
}

StaticPopupDialogs["GUIS_RESTART_REQUIRED_FOR_CHANGES"] = {
	text = L["The user interface needs to be reloaded for the changes to take effect. Do you wish to reload it now?"],
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function() 
		ReloadUI()
	end,
	OnCancel = function() 
		scheduledRestart = nil
		print(L["You can reload the user interface at any time with |cFF4488FF/rl|r or |cFF4488FF/reload|r"])
	end,
	exclusive = 1,
	hideOnEscape = 0,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs["GUIS_RESTART_REQUIRED_TO_FIX_MISSING_ACTIONBARS"] = {
	text = L["There is a problem with your ActionBars.|nThe user interface needs to be reloaded in order to fix it.|nReload now?"],
	button1 = YES,
	button2 = NO,
	OnAccept = function() 
		ReloadUI()
	end,
	OnCancel = function() 
		scheduledRestart = nil
		print(L["You can reload the user interface at any time with |cFF4488FF/rl|r or |cFF4488FF/reload|r"])
	end,
	exclusive = 1,
	hideOnEscape = 0,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs["GUI_QUERY_INSTALL"] = {
	text = L["This is the first time you're running %s on this character. Would you like to run the install tutorial now?"]:format(ADDON_NAME),
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function() 
		GUIS_VERSION.Initialized = true

		PlaySound("igMainMenuOption")
		securecall("CloseAllWindows")
		
		F.FullScreenFadeIn()
		
		GUIS:InstallAll()
	end,
	OnCancel = function() 
		GUIS_VERSION.Initialized = true

		PlaySound("igMainMenuOption")
		HideUIPanel(_G["GameMenuFrame"])

		F.FullScreenFadeIn()

		print(L["Setup aborted. Type |cFF4488FF/install|r to restart the tutorial."])
	end,
	exclusive = 1,
	hideOnEscape = 0,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
}

--
-- decide whether or not the module is to be auto-disabled
F.disable = function(module) 
	if not disable[module] then return end
	for addon, shutdown in pairs(disable[module]) do
		if (IsAddOnLoaded(addon)) and (shutdown == true) then
			return true
		end
	end
	return false
end

--
-- returns the localized display name of a given module
F.getName = function(module)
	return "|cFF4488FFGUIS|r|cFFFFFFFF:|r " .. (moduleToName[module] or gCore:GetModule(module) and gCore:GetModule(module):GetName())
end

--
-- a combined check to decide whether a module should NOT be loaded!
F.kill = function(module)
	local load, disable = GUIS_DB.load[module], F.disable(module)
	
	if (load == 0) then
		return true
		
	elseif (load == 1) then
		if (disable == true) then
			return true
		else
			return false
		end
		
	elseif (load == 2) then
		return false
	else
		return false
	end
end

-- schedule a restart, without actually doing anything
F.ScheduleRestart = function()
	scheduledRestart = true
end

-- popup a restart request if one has been scheduled previously
F.RestartIfScheduled = function()
	if (scheduledRestart) and not(warned) and(GUIS_VERSION.Initialized) then
		StaticPopup_Show("GUIS_RESTART_REQUIRED_FOR_CHANGES")
		warned = true
	end
end

local fullscreenfader = CreateFrame("Frame", nil, UIParent)
fullscreenfader:Hide()
fullscreenfader:SetAlpha(0)
fullscreenfader:SetAllPoints(UIParent)
fullscreenfader:SetFrameStrata("HIGH")
fullscreenfader:SetFrameLevel(129)
fullscreenfader.texture = fullscreenfader:CreateTexture(nil, "BACKGROUND")
fullscreenfader.texture:SetTexture(0, 0, 0)
fullscreenfader.texture:SetAlpha(3/4)
fullscreenfader.texture:SetAllPoints(fullscreenfader)

F.FullScreenFadeOut = function(force)
	local startAlpha
	if (UIFrameIsFading(fullscreenfader)) then 
		UIFrameFadeRemoveFrame(fullscreenfader)
	end
	
	if (force) then
		fullscreenfader.texture:SetAlpha(1)
		fullscreenfader:SetAlpha(1)
		fullscreenfader:Show()
	else
		fullscreenfader.texture:SetAlpha(3/4)
		UIFrameFadeIn(fullscreenfader, 3.5, fullscreenfader:GetAlpha() or 0, 1)
	end
end
_G.FADEOUT = F.FullScreenFadeOut

F.FullScreenFadeIn = function()
	local startAlpha
	if (UIFrameIsFading(fullscreenfader)) then 
		UIFrameFadeRemoveFrame(fullscreenfader)
	end
	
	UIFrameFadeOut(fullscreenfader, 1.5, fullscreenfader:GetAlpha() or 1, 0)
end
_G.FADEIN = F.FullScreenFadeIn

local logo
F.ShowFullScreenLogo = function(force, customDelay)
	if not(logo) then
		logo = CreateFrame("Frame", nil, UIParent)
		logo:Hide()
		logo:SetAlpha(0)
		logo:SetSize(600, 300)
		logo:SetPoint("CENTER")
		logo:SetFrameStrata("DIALOG")
		logo:SetFrameLevel(120)

		logo.texture = logo:CreateTexture(nil, "ARTWORK")
		logo.texture:SetSize(512, 256)
		logo.texture:SetPoint("CENTER", 0, 50)
		logo.texture:SetTexture(M["Texture"]["gUILogo"])
		
		logo.fadeOut = function()
			local startAlpha
			if (UIFrameIsFading(logo)) then 
				UIFrameFadeRemoveFrame(logo)
			end
			
			UIFrameFadeOut(logo, 1.5, logo:GetAlpha() or 1, 0)
--			F.FullScreenFadeIn()

			ScheduleTimer(function() 
				FireCallback("GUIS_LOGO_HIDE")
			end, nil, 2)
		end
	end
	
--	F.FullScreenFadeOut(force)

	if (force) then
		UIFrameFadeIn(logo, 3.5, 0, 1)
		ScheduleTimer(logo.fadeOut, nil, customDelay or 9.5)
	else
		UIFrameFadeIn(logo, 1.5, 0, 1)
		ScheduleTimer(logo.fadeOut, nil, customDelay or 5)
	end
end
_G.SHOWLOGO = F.ShowFullScreenLogo

saveFramePositions = function()
	GUIS_SAVED_FRAME_POSITIONS = gFH:GetSavedPositions()
end

--
-- applies the function 'func' to all modules
-- 	moduleName, module is passed as the two first parameters to 'func'
applyToAllModules = function(func, ...)
	for name, module in pairs(gCore:GetAllModules()) do
		if not(module == GUIS) then
			func(name, module, ...)
		end
	end
end

-- 
-- use the method 'method' in all gCore modules
forAllModules = function(method, ...)
	for name, module in pairs(gCore:GetAllModules()) do
		if not(module == GUIS) and (module[method]) then
			module[method](module, ...)
		end
	end
end

do
	local frame
	local parts = 2
	GUIS.Install = function(self, option, index)
		if (option == "frame") then
			if not(index) or (index == 1) then
				if not(frame) then
					frame = CreateFrame("Frame", nil, UIParent)
					frame:Hide()
					frame:SetWidth(600)

					-- our awesome logo
					frame.logo = frame:CreateTexture(nil, "ARTWORK")
					frame.logo:SetSize(512, 256)
					frame.logo:SetPoint("TOP", 0, 38)
					frame.logo:SetTexture(M["Texture"]["gUILogo"])

					local description = ""
					description = description .. L["_ui_description_"]:format(GUIS.ADDON_NAME, L["Goldpaw"]) .. " " .. L["_install_guide_"] .. "|n"

					description = description .. "|n"
					description = description .. "|cFFFFD100" .. L["Credits to: "] .. "|r" .. L["_ui_credited_"] .. "|n"

					description = description .. "|n"
					description = description .. L["Web: "] .. "|cFFFFD100" .. L["_ui_web_"] .. "|r" .. "|n"
					description = description .. L["Download: "] .. "|cFFFFD100" .. L["_ui_download_"] .. "|r" .. "|n"
					description = description .. L["Twitter: "] .. "|cFFFFD100" .. L["_ui_facebook_"] .. "|r" .. "|n"
					description = description .. L["Facebook: "] .. "|cFFFFD100" .. L["_ui_twitter_"] .. "|r" .. "|n"
					description = description .. L["YouTube: "] .. "|cFFFFD100" .. L["_ui_youtube_"] .. "|r" .. "|n"
					description = description .. L["Contact: "] .. "|cFFFFD100" .. L["_ui_contact_"] .. "|r" .. "|n"
					
					description = description .. "|n"
					description = description .. L["_ui_copyright_"]:format(L["Goldpaw"]) .. "|n"
					
					frame.welcome = frame:CreateFontString(nil, "BACKGROUND")
					frame.welcome:SetFontObject(GUIS_SystemFontNormalWhite)
					frame.welcome:SetPoint("TOP", frame.logo, "BOTTOM", 0, 0)
					frame.welcome:SetSize(550, 1000)
					frame.welcome:SetFontObject(GUIS_SystemFontSmallWhite)
					frame.welcome:SetTextColor(unpack(C["index"]))
					frame.welcome:SetWordWrap(true)
					frame.welcome:SetNonSpaceWrap(true)
					frame.welcome:SetJustifyH("CENTER")
					frame.welcome:SetJustifyV("TOP")
					frame.welcome:SetText(description) 
					frame.welcome:SetHeight(frame.welcome:GetStringHeight() + 16)
					
					frame:SetHeight(frame.logo:GetHeight() + frame.welcome:GetHeight() - 38) --  + frame.title:GetHeight() + 8
				end
				
				return frame, parts
			end
			
			return nil, parts
			
		elseif (option == "title") then
			if not(index) or (index == 1) then
				return ""
			
			elseif (index == 2) then
				return L["UI Scale"]

			end
		
		elseif (option == "description") then
			if not(index) or (index == 1) then
				return ""
				
			elseif (index == 2) then
				local usingscaling = (tonumber(GetCVar("useUiScale")) == 1)
				if (usingscaling) then
					return L["Using custom UI scaling will distort graphics, create fuzzy borders, and otherwise ruin frame proportions and positions. It is adviced to always leave this off, as it will seriously affect the entire layout of the UI in unpredictable ways."] .. "|n|n" .. L["UI scaling is currently activated. Do you wish to disable this?"].. "|n" .. F.warning(L["This is recommended!"])
				else
					return L["Using custom UI scaling will distort graphics, create fuzzy borders, and otherwise ruin frame proportions and positions. It is adviced to always leave this off, as it will seriously affect the entire layout of the UI in unpredictable ways."] .. "|n|n" .. L["|cFFFF0000UI scaling is currently deactivated, which is the recommended setting, so we are skipping this step.|r"]
				end
			
			end
		
		elseif (option == "execute") then
			if not(index) or (index == 1) then
				return noop
				
			elseif (index == 2) then
				return function()
					local usingscaling = (tonumber(GetCVar("useUiScale")) == 1)
					if (usingscaling) then
						SetCVar("useUiScale", 0)
						GUIS:PostUpdateGUI()
					end
				end
			end
			
		elseif (option == "cancel") then
			return noop
			
		elseif (option == "post") then
			if not(index) or (index == 1) then
				return function(self, index)
					self.skip:Disable()
					self:SetApplyButtonText(L["Continue"])
				end
				
			elseif (index == 2) then
				return function(self, index)
					local usingscaling = (tonumber(GetCVar("useUiScale")) == 1)
					if not(usingscaling) then
						self:SetApplyButtonText(L["Continue"])
						self:SetText(L["Using custom UI scaling will distort graphics, create fuzzy borders, and otherwise ruin frame proportions and positions. It is adviced to always leave this off, as it will seriously affect the entire layout of the UI in unpredictable ways."] .. "|n|n" .. L["|cFFFF0000UI scaling is currently deactivated, which is the recommended setting, so we are skipping this step.|r"])
					else
						self:SetText(L["Using custom UI scaling will distort graphics, create fuzzy borders, and otherwise ruin frame proportions and positions. It is adviced to always leave this off, as it will seriously affect the entire layout of the UI in unpredictable ways."] .. "|n|n" .. L["UI scaling is currently activated. Do you wish to disable this?"].. "|n" .. F.warning(L["This is recommended!"]))
					end
				end
			end
		end
	end
end

-- :Install() handler
do
	-- indexed priority list of modules to :Install() before any others
	local priority = {
		"GUIS-gUI: Core";
		"GUIS-gUI: Chat";
		"GUIS-gUI: ActionBars";
	}
	
	local FRAME

	local SetTooltipScripts = function(self, hook)
		local SetScript = hook and "HookScript" or "SetScript"
		
		self[SetScript](self, "OnEnter", function(self)
			if (self.tooltipText) then
				GameTooltip:SetOwner(self, self.tooltipOwnerPoint or "ANCHOR_RIGHT")

				if (type(self.tooltipText) == "string") then
					GameTooltip:SetText(self.tooltipText, 1.0, .82, .0, 1.0, 1)
					
				elseif (type(self.tooltipText) == "table") then
					for i = 1, #self.tooltipText do
						if (i == 1) then
							GameTooltip:SetText(self.tooltipText[i], 1.0, 1.0, 1.0, 1.0, 1)
						else
							GameTooltip:AddLine(self.tooltipText[i], 1.0, .82, .0, 1.0)
						end
					end
				end
				
				if (self.tooltipRequirement) then
					GameTooltip:AddLine(self.tooltipRequirement, 1.0, .0, .0, 1.0)
				end

				GameTooltip:Show()
			end
		end)
		
		self[SetScript](self, "OnLeave", function(self)
			GameTooltip:Hide()
		end)
	end
	
	GUIS.InstallAll = function(self)
		
		-- create the dialog frame if it doesn't exist already
		if not(FRAME) then
			FRAME = CreateFrame("Frame", GUIS:GetName() .. "InstallTutorial", UIParent)
			FRAME:Hide()
			FRAME:SetFrameStrata("DIALOG")
			FRAME:SetFrameLevel(50)
			FRAME.minDescriptionHeight = 70
			FRAME.hPadding = 25*2 -- outer padding for visual reasons
			FRAME.minWidth = 600 -- minimum width to have room for progressbar and buttons
			FRAME.minHeight = 50+10 + 10+48+22+10 -- title, padding + padding, progressbar, buttons, padding
			FRAME:SetSize(FRAME.minWidth + FRAME.hPadding, FRAME.minHeight) 
			FRAME:SetPoint("BOTTOM", 0, 160 + ((GetScreenHeight() - 800)/2))
			FRAME:SetUITemplate("simplebackdrop")
			
			FRAME.abacus = {} -- temporary stuff when creating the sequence 
			FRAME.sequence = {} -- sequence of module names in priority order first, then alphabetical
			FRAME.children = {} -- link table to titles, descriptions, install frames and install functions

			FRAME.Resize = function(self)
				local index = self.progress:GetValue()
				
				-- find the current frame, if one exists
				local frame
				if (index) and (self.children[index]) then
					frame = self.children[index].frame
				end
				
				-- decide its height
				local h = 0
				if (frame) then
					h = frame:GetHeight() or 0
				end
				
				-- find the height of the description element
				local description = self.description:GetHeight() or 0
				
				-- size our tutorial frame accordingly, and make room for the description
				self:SetHeight(self.minHeight + h + description)
			end

			
			-- title element
			do
				local title = FRAME:CreateFontString(nil, "BACKGROUND")
				title:SetFontObject(GUIS_SystemFontLarge)
				title:SetPoint("TOP", 0, -12)
				title:SetTextColor(unpack(C["value"]))

				FRAME.title = title
				FRAME.SetTitle = function(self, msg) self.title:SetText(msg) end
			end
			
			-- description element
			do
				local description = FRAME:CreateFontString(nil, "BACKGROUND")
--				description:SetFontObject(GUIS_SystemFontNormalWhite)
				description:SetPoint("TOP", 0, -50)
				description:SetSize(FRAME.minWidth - 150, FRAME.minDescriptionHeight)
				description:SetFontObject(GUIS_SystemFontSmallWhite)
				description:SetTextColor(unpack(C["index"]))
				description:SetWordWrap(true)
				description:SetNonSpaceWrap(true)
				description:SetJustifyH("CENTER")
				description:SetJustifyV("TOP")
				
				FRAME.description = description
				FRAME.SetText = function(self, msg) 
					self.description:SetHeight(1000) -- wild number, just to ensure enough room for the calculation
					self.description:SetText(msg) 
					self.description:SetHeight(self.description:GetStringHeight() or 0)

					self:Resize()
				end
				
				FRAME.GetText = function(self)
					return self.description:GetText()
				end
			end
			
			-- progressbar
			do
				local progress = CreateFrame("StatusBar", FRAME:GetName() .. "ProgressStatusBar", FRAME)
				progress:SetSize(480, 22)
				progress:SetPoint("BOTTOM", 0, 48)
				progress:SetUITemplate("statusbar", true)
				progress:SetStatusBarColor(C.FACTION_BAR_COLORS[5].r, C.FACTION_BAR_COLORS[5].g, C.FACTION_BAR_COLORS[5].b)

				progress.text = progress:CreateFontString(nil, "OVERLAY")
				progress.text:SetFontObject(GUIS_NumberFontNormalYellow)
				progress.text:SetPoint("CENTER")
				
				progress.update = function(self)
					-- update progressbar text
					local min, max = self:GetMinMaxValues()
					local step = self:GetValue()
					self.text:SetFormattedText("%d|cFFFFFFFF/|r%d", step, max)
					
					-- update frame title
					FRAME:SetTitle(FRAME.children[step].title)
					
					-- reset frame content 
					FRAME:SetText(FRAME.children[step].description)
				end
				
				-- SetValue sometimes is called twice with the same value, and we need to hook our sizing functions into both calls
				-- this means a script handler for 'OnValueChanged' isn't sufficient
				hooksecurefunc(progress, "SetValue", function(self) self:update() end)
				
				FRAME.progress = progress
			end
			
			-- 'previous' button
			do
				local previous = CreateFrame("Button", FRAME:GetName() .. "PreviousButton", FRAME)
				previous:SetSize(28, 28)
				previous:SetPoint("RIGHT", FRAME.progress, "LEFT", -8, 0)
				previous:SetUITemplate("arrow", "left")
				previous.tooltipText = { L["Previous"], L["Go backwards to the previous step in the tutorial."] }
				SetTooltipScripts(previous, true)
				
				previous.func = function(self, event, ...)
					local min, max = FRAME.progress:GetMinMaxValues()
					local step = FRAME.progress:GetValue()

					-- show the previous module's intro message
					step = step - 1
					if (step >= min + 1) then
						FRAME:Select(step)
					end
				end
				previous:SetScript("OnClick", function(self) self:func() end)

				FRAME.previous = previous
			end
			
			-- 'next' button
			do
				local next = CreateFrame("Button", FRAME:GetName() .. "NextButton", FRAME)
				next:SetSize(28, 28)
				next:SetPoint("LEFT", FRAME.progress, "RIGHT", 8, 0)
				next:SetUITemplate("arrow", "right")
				next.tooltipText = { L["Next"], L["Skip forward to the next step in the tutorial."] }
				SetTooltipScripts(next, true)
				
				next.func = function(self, event, ...)
					local min, max = FRAME.progress:GetMinMaxValues()
					local step = FRAME.progress:GetValue()

					-- show the next module's intro message, or finish
					step = step + 1
					if (step <= max) then
						FRAME:Select(step)
					else
						FRAME:Hide()
					end
				end
				next:SetScript("OnClick", function(self) self:func() end)

				FRAME.next = next
			end
			
			-- 'apply' button
			do
				local continue = CreateFrame("Button", FRAME:GetName() .. "ContinueButton", FRAME, "UIPanelButtonTemplate")
				continue:SetSize(160, 22)
				continue:SetUITemplate("button", true)
				continue:SetText(L["Apply"])
				continue:SetPoint("BOTTOM", 0, 12)
				continue.tooltipText = nil -- { L["Continue"], L["Procede with this step of the install tutorial."] }
				SetTooltipScripts(continue, true)

				-- what happens when the user clicks "Continue"
				continue.func = function(self, event, ...)
					local min, max = FRAME.progress:GetMinMaxValues()
					local step = FRAME.progress:GetValue()

					-- run the current module's install routine
					FRAME.children[step].execute()

					-- show the next module's intro message, or finish
					step = step + 1
					if (step <= max) then
						FRAME:Select(step)
					else
						FRAME:Hide()
					end
				end
				continue:SetScript("OnClick", function(self) self:func() end)
				
				FRAME.continue = continue
				FRAME.SetApplyButtonText = function(self, msg)
					self.continue:SetText(msg or L["Apply"])
				end
			end
			
			-- 'skip' button
			do
				local skip = CreateFrame("Button", FRAME:GetName() .. "SkipButton", FRAME, "UIPanelButtonTemplate")
				skip:SetSize(160, 22)
				skip:SetUITemplate("button", true)
				skip:SetText(L["Skip"])
				skip:SetPoint("RIGHT", FRAME.continue, "LEFT", -12, 0)
				skip.tooltipText = { L["Skip"], L["Skip this step"] }
				SetTooltipScripts(skip, true)
				
				-- what happens when the user clicks "Skip"
				skip.func = function(self, event, ...)
					local min, max = FRAME.progress:GetMinMaxValues()
					local step = FRAME.progress:GetValue()

					-- show the next module's intro message, or finish
					step = step + 1
					if (step <= max) then
						FRAME:Select(step)
					else
						FRAME:Hide()
					end
				end
				skip:SetScript("OnClick", function(self) self:func() end)
				
				FRAME.skip = skip
			end

			-- 'cancel' button
			do
				local cancel = CreateFrame("Button", FRAME:GetName() .. "CancelButton", FRAME, "UIPanelButtonTemplate")
				cancel:SetSize(160, 22)
				cancel:SetUITemplate("button", true)
				cancel:SetText(L["Cancel"])
				cancel:SetPoint("LEFT", FRAME.continue, "RIGHT", 12, 0)
				cancel:SetScript("OnClick", function(self) 
					FRAME.wasCancelled = true
					FRAME:Hide()
				end)
				cancel.tooltipText = { L["Cancel"], L["Cancel the install tutorial."] }
				SetTooltipScripts(cancel, true)
				
				FRAME.cancel = cancel
			end

			-- select the given index in our tutorial sequence
			-- this will fire off a progressbar- and title/description update as well
			FRAME.Select = function(self, index)
				-- if no index is given, we attempt to grab it from the progress bar
				if not(index) then
					index = self.progress:GetValue()
				end
				
				-- find the current frame, if one exists
				local frame
				if (index) and (self.children[index]) then
					frame = self.children[index].frame
				end

				-- hide all the frames, and parent them to the tutorial frame
				for i = 1, #self.children do
					if (self.children[i].frame) then
						self.children[i].frame:Hide()
						self.children[i].frame:SetParent(FRAME)
					end
				end
					
				-- show the install frame, if it exists
				local w, h = 0, 0
				if (frame) then
					w, h = frame:GetWidth() or 0, frame:GetHeight() or 0
					
					frame:ClearAllPoints()
					frame:SetPoint("TOP", self.description, "BOTTOM", 0, -10)
					frame:Show()
				end
				
				-- size our tutorial frame accordingly
				self:SetSize(max(self.minWidth, w) + self.hPadding, self.minHeight + h)

				-- set up the progress bar
				self.progress:SetMinMaxValues(0, #self.children)
				self.progress:SetValue(index or 0)
				
				-- enable/disable navigation and control buttons
				if (index == 1) then
					self.skip:Enable()
					self.continue:Enable()
					self.cancel:Enable()
					self.next:Enable()
					self.previous:Disable()
					
				elseif (index > 1) and (index < #self.children) then
					self.skip:Enable()
					self.continue:Enable()
					self.cancel:Enable()
					self.next:Enable()
					self.previous:Enable()
					
				elseif (index == #self.children) then
					self.skip:Disable()
					self.continue:Enable()
					self.cancel:Enable()
					self.next:Disable()
					self.previous:Enable()
					
				else
					self.skip:Enable()
					self.continue:Enable()
					self.cancel:Enable()
					self.next:Enable()
					self.previous:Enable()
				end
				
				-- reset the apply button text
				self:SetApplyButtonText()
				
				-- run the post update function
				local post = self.children[index] and self.children[index].post
				if (post) then
					post(self, index)
				end
			end
			
			FRAME.Reposition = function(self)
				-- reposition if needed
				self:ClearAllPoints()
				self:SetPoint("BOTTOM", 0, 160 + ((GetScreenHeight() - 800)/2))
			end
			RegisterCallback("PLAYER_ENTERING_WORLD", function() FRAME:Reposition() end)
			RegisterCallback("DISPLAY_SIZE_CHANGED", function() FRAME:Reposition() end)
			RegisterCallback("UI_SCALE_CHANGED", function() FRAME:Reposition() end)
			
			-- OnShow script. this is where the sequence is created and visual content updated
			FRAME:SetScript("OnShow", function(self) 
				FireCallback("GUIS_INSTALL_SHOW")
			
--				F.FullScreenFadeOut()
				self:Reposition()
				
				local module
				
				-- reset previous values
				self.wasCancelled = nil

				-- wipe the sequence, we're always restarting when showing this frame
				wipe(self.sequence)
				wipe(self.abacus)
				
				-- hide and wipe the table of children, we will rebuild it in a moment
				for i,v in pairs(self.children) do
					if (self.children[i].frame) then
						self.children[i].frame:Hide()
					end
				end
				wipe(self.children)
				
				-- first insert the priority modules into our abacus
				for i = 1, #priority  do
					self.abacus[priority[i]] = true
				end
				
				-- then insert all modules with the "Install" method into our sequence and our abacus
				for _, module in pairs(gCore:GetAllModules()) do
					if (module.Install) and not(self.abacus[module:GetName()]) then
						tinsert(self.sequence, module:GetName())
						self.abacus[module:GetName()] = true
					end
				end
				
				-- sort the sequence alphabetically
				sort(self.sequence)
			
				-- insert our priority list at the start of the sequence
				-- iterate backwards through it and insert each new element at the top
				for i = #priority, 1, -1  do
					module = gCore:GetModule(priority[i])
					if (module) and (module.Install) then
						tinsert(self.sequence, 1, priority[i])
					end
				end
				
				-- populate our tutorial table again
				--
				-- this table can be larger than the sequence table,
				-- as each module can have multiple install steps
				local i, part, frame, parts, execute, cancel
				local step = 1
				for i = 1, #self.sequence do
					module = gCore:GetModule(self.sequence[i])
					frame, parts = module:Install("frame")
					
					if (parts) then
						for part = 1, parts do
							frame = module:Install("frame", part)
							execute = module:Install("execute", part)
							cancel = module:Install("cancel", part)
							post = module:Install("post", part)
							
							self.children[step] = {
								frame = ((frame) and (frame.Show and frame.Hide)) and frame or nil;
								title = module:Install("title", part) or F.getName(module:GetName()) or module:GetName() or "";
								description = module:Install("description", part) or "";
								execute = (type(execute) == "function") and execute or noop;
								cancel = (type(cancel) == "function") and cancel or noop;
								post = (type(post) == "function") and post or noop;
							}
							step = step + 1
						end
					else
						execute = module:Install("execute")
						cancel = module:Install("cancel")
						post = module:Install("post")

						self.children[step] = {
							frame = ((frame) and (frame.Show and frame.Hide)) and frame or nil;
							title = module:Install("title") or F.getName(module:GetName()) or module:GetName() or "";
							description = module:Install("description") or "";
							execute = (type(execute) == "function") and execute or noop;
							cancel = (type(cancel) == "function") and cancel or noop;
							post = (type(post) == "function") and post or noop;
						}
						step = step + 1
					end
				end
				
				-- show the first module's intro message
				FRAME:Select(1)
			end)			

			-- OnHide script. will show a simple message if it was manually cancelled prior to completion
			FRAME:SetScript("OnHide", function(self) 
--				F.FullScreenFadeIn()
				if (self.wasCancelled) then
					print(L["Setup aborted. Type |cFF4488FF/install|r to restart the tutorial."])
				end
				
				-- even if setup was cancelled, we still might need a restart due to changes made
				F.RestartIfScheduled()
			end)
			
			local safe = function() 
				if (FRAME:IsShown()) then
					FRAME:Hide() 
					print(L["Setup aborted because of combat. Type |cFF4488FF/install|r to restart the tutorial."])
				end
			end
			RegisterCallback("PLAYER_REGEN_DISABLED", safe)
		end
		
		-- shazam!
		FRAME:Show()
	end
end

-- update menu options
GUIS.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(ADDON_NAME)
end

GUIS.RestoreDefaults = function(self)
	GUIS_DB["core"] = DuplicateTable(GUIS_DB["core"])
end

GUIS.Init = function(self)
	-- uncomment to reset module selection
	--GUIS_DB.load = DuplicateTable(load)

	-- validate saved settings
	GUIS_DB.load = ValidateTable(GUIS_DB.load, load)
	GUIS_VERSION = ValidateTable(GUIS_VERSION, defaultVersion)
	GUIS_DB["core"] = ValidateTable(GUIS_DB["core"], defaults)

	-- set up gFrameHandler's font and locale, 
	-- prior to any module's initialization procedure
	gFH:SetFontObject(GUIS_SystemFontSmallWhite)
	gFH:SetLocale(L)
		
	-- we need to feed our saved frame positions to gFrameHandler before PLAYER_LOGIN
	gFH:SetSavedPositions(GUIS_SAVED_FRAME_POSITIONS)

	do
		------------------------------------------------------------------------------------------
		-- create the root options menu
		------------------------------------------------------------------------------------------
		-- we need to iterate through the modules here
		local restoreDefaults = function()
			if (InCombatLockdown()) then 
				print(L["Can not apply default settings while engaged in combat."])
				return
			end
			
			-- restore all frame positions
			gFH:Reset()
			
			-- reset core UI settings
			GUIS:RestoreDefaults()
			GUIS:PostUpdateGUI()
			
			-- reset module selection
			GUIS_DB.load = DuplicateTable(load)
			
			-- reset module settings
			forAllModules("RestoreDefaults")
			
			-- request a restart if one of the modules need it
			F.RestartIfScheduled()
		end
		
		local cancelChanges = function()
		end
		
		local applySettings = function()
		end
		
		local applyChanges = function()
		end
		
		local gOM = LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu")
		ns.GUIS_MENU = gOM:New(menuTable)
		
		gOM:RegisterWithBlizzard(ns.GUIS_MENU, ADDON_NAME, 
 			"default", restoreDefaults, 
			"cancel", cancelChanges, 
			"okay", applyChanges)
			
		F.AddGameMenuButton("GUISOptions", ADDON_NAME, function() 
			PlaySound("igMainMenuOption")
			HideUIPanel(_G["GameMenuFrame"])
			
			if (ns.GUIS_MENU) then
				InterfaceOptionsFrame_OpenToCategory(ns.GUIS_MENU.name)
			end
		end)
	end
	
	-- register the FAQ
	do
		local FAQ = LibStub("gCore-3.0"):GetModule("GUIS-gUI: FAQ")
		FAQ:NewGroup(faq)
	end
end

GUIS.DeclareWarOnTaint = function(self)
	-- the damn SearchLFGLeave() taint
	-- I got this idea on February 16th, 2012. 
	do
		LFRParentFrame:SetScript("OnHide", nil)
	end

	-- Fix known tainted popups that easily can be fixed. pop. fix. snap. crackle?
	--
	-- This is basically any addon that fails to add the "preferredIndex = 3" setting to their popups, 
	-- yet defines their popups before calling them so it is possible to remedy the situation for us.
	-- "gUI™ - cleaning up other people's mess since 2010"
	--
	-- Known unfixable/too clunky to bother addons: 
	--		TradeSkillMaster
	--
	do
		local popsinners = {
			Postal = {
				["POSTAL_NEW_PROFILE"] = true;
				["POSTAL_DELETE_MAIL"] = true;
				["POSTAL_DELETE_MONEY"] = true;
			};
			
			AuctionLite = {
				["AL_FAST_SCAN"] = true;
				["AL_CANCEL_NOTE"] = true;
				["AL_CANCEL_CONFIRM"] = true;
				["AL_NEW_FAVORITES_LIST"] = true;
				["AL_CLEAR_DATA"] = true;
				["AL_VENDOR_WARNING"] = true;
			};
		}
		local popfix = function(self, event, addon)
			if (event) and (addon) and not(popsinners[addon]) then
				return
			end
			
			for sinner,_ in pairs(popsinners) do
				if (IsAddOnLoaded(sinner)) then
					for pop,_ in pairs(popsinners[sinner]) do
						if (StaticPopupDialogs[pop]) then
							StaticPopupDialogs[pop].preferredIndex = 3
						end					
					end
					
					popsinners[sinner] = nil
				end
			end
			
			-- this one has no specific addon, so we keep checking
			if (StaticPopupDialogs["ACECONFIGDIALOG30_CONFIRM_DIALOG"])
			and not(StaticPopupDialogs["ACECONFIGDIALOG30_CONFIRM_DIALOG"].preferredIndex == 3) then
				StaticPopupDialogs["ACECONFIGDIALOG30_CONFIRM_DIALOG"].preferredIndex = 3
			end
		end
		
		-- initial call
		popfix()
		
		-- make a callback for other addons
		RegisterCallback("ADDON_LOADED", popfix)
	end
	
	-- TalentFrame taint
	--
	-- the frame will become tainted if closed by clicking the keybind to toggle it.
	-- the problem with this is that it also affects glyphs, making it impossible to change them.
	--
	-- opening the window again, then closing it with Esc, will magically remove the taint. Weird.
	--
	-- so our fix, is to take the keybind used to toggle the talentframe, and move it to a custom keybind
	-- that only opens the frame, not toggles it. This will force the user to use Esc or the closebutton 
	-- to close the frame, and thus prevents the taint from happening.
	do
		local fixTalents = function()
			local talentKey
			local firstSet = GetCurrentBindingSet()
			local talentAction, openTalentsAction = "TOGGLETALENTS", "GUISSHOWTALENTS"
			
			-- set 1 = account, 2 = character
			for bindingSet = 1, 2 do
				LoadBindings(bindingSet)

				-- get the key bound to the talent frame
				talentKey = GetBindingKey(talentAction)
				if (talentKey) then
					SetBinding(talentKey, openTalentsAction)
					SaveBindings(bindingSet)
				end
			end
			
			-- load the original binding set
			if (firstSet == 1) or (firstSet == 2) then
				LoadBindings(firstSet)
			end
		end
		
		RegisterCallback("PLAYER_ENTERING_WORLD", fixTalents)
		RegisterCallback("VARIABLES_LOADED", fixTalents)
	end
end

GUIS.OnInit = function(self)
	GUIS:DeclareWarOnTaint()
	
	-- some positional fixes (I wonder if they use that phrase in the Kama Sutra too)
	do
		-- don't need space for the right side actionbars
		UIParent:SetAttribute("RIGHT_OFFSET_BUFFER", 0)
		
		-- keep the menus on-screen, simple positioning hack
		DropDownList1:SetClampedToScreen(true)
		DropDownList2:SetClampedToScreen(true)
	end

	-- /glock
	do
		local _UNLOCK
		
		-- reset the lock status upon entering combat
		RegisterCallback("PLAYER_REGEN_DISABLED", function() _UNLOCK = nil end)

		CreateChatCommand(function(opt) 
			if (InCombatLockdown()) then
				print(L["Frames cannot be moved while engaged in combat"])
			else
				-- force a lock/unlock to happen 
				if (opt == "unlock") then
					_UNLOCK = nil
				elseif (opt == "lock") then
					_UNLOCK = true
				end
			
				if (_UNLOCK) then
					_UNLOCK = nil

					gFH:Lock()

					saveFramePositions()
				else
					_UNLOCK = true

					gFH:Unlock()
				end
			end 
		end, "glock")

		CreateChatCommand(function() 
			if (InCombatLockdown()) then
				print(L["Frames cannot be moved while engaged in combat"])
			else
				gFH:Reset()

				if (_UNLOCK) then
					_UNLOCK = nil
				end
				
				saveFramePositions()
			end
		end, "greset")
	end
	
	-- module load status
	do
		local setAllTo = function(v)
			for i,_ in pairs(GUIS_DB.load) do
				GUIS_DB.load[i] = v
			end
		end
		
		CreateChatCommand(function() 
			setAllTo(0)
			F.ScheduleRestart()
			F.RestartIfScheduled()
		end, { "disableall", "disableallmodules" })

		CreateChatCommand(function() 
			setAllTo(1)
			F.ScheduleRestart()
			F.RestartIfScheduled()
		end, { "enableall", "enableallmodules" })
		
		CreateChatCommand(function() 
			setAllTo(2)
			F.ScheduleRestart()
			F.RestartIfScheduled()
		end, { "forceall", "forceallmodules" })
	end

	-- /ghelp
	do
		local gHelp
		if (L["chatcommandlist"]) then
			gHelp = { strsplit(L["chatcommandlist-separator"], L["chatcommandlist"]) }
		end

		CreateChatCommand(function()
			if not(gHelp) then
				return
			end
			
			for i = 1, #gHelp do
				if (gHelp[i] ~= "") then
					print(gHelp[i])
				end
			end
		end, "ghelp")
	end
	
	-- /gui options menu command
	CreateChatCommand(function() 
		PlaySound("igMainMenuOption")
		HideUIPanel(_G["GameMenuFrame"])
		
		if (ns.GUIS_MENU) then
			InterfaceOptionsFrame_OpenToCategory(ns.GUIS_MENU.name)
		end
	end, "gui")

	-- /install tutorial command
	CreateChatCommand(function() 
		PlaySound("igMainMenuOption")
		securecall("CloseAllWindows")
		
		GUIS:InstallAll()
	end, "install")
	
	-- reset the tutorial requests on this character
	CreateChatCommand(function() 
		GUIS_VERSION.Initialized = nil
		ReloadUI()
	end, "resettutorial")
	
end

local logoShown
GUIS.OnEnable = function(self)
	RegisterCallback("GUIS_LOGO_HIDE", function() logoShown = true end)
	
	if (InCinematic()) then
		RegisterCallback("CINEMATIC_STOP", function() 
			if (GUIS_DB["core"].useFullScreenLogo) then
				F.ShowFullScreenLogo(nil, 3)
			else
				ScheduleTimer(function() FireCallback("GUIS_LOGO_HIDE") end, nil, 3)
			end
		end)
	else
		if (GUIS_DB["core"].useFullScreenLogo) then
			F.ShowFullScreenLogo(true)
		else
			ScheduleTimer(function() FireCallback("GUIS_LOGO_HIDE") end, nil, 12)
		end
	end
end

local once
GUIS.OnEnter = function(self)
	if not(once) then
		local v, s, b = F.GetVersion()
		if not(GUIS_VERSION.Initialized) or (v > GUIS_VERSION.version) or ((v == GUIS_VERSION.version) and (s > GUIS_VERSION.subversion)) then
			GUIS_VERSION.version = v
			GUIS_VERSION.subversion = s
			GUIS_VERSION.build = b
			
			-- move this to the setup tutorial?
			do
				local a1, a2, a3, a4 = GetActionBarToggles()
				if not(a1) or not(a2) or not(a3) or not(a4) then
					SetActionBarToggles(1, 1, 1, 1)
					F.ScheduleRestart()
				end
				SetCVar("alwaysShowActionBars", 0)
			end
		
			if (logoShown) and not(InCinematic()) then
				if (GUIS_DB["core"].useFullScreenFade) then 
					F.FullScreenFadeOut()
				end
				StaticPopup_Show("GUI_QUERY_INSTALL")
			else
				local callback
				callback = RegisterCallback("GUIS_LOGO_HIDE", function() 
					if (GUIS_DB["core"].useFullScreenFade) then 
						F.FullScreenFadeOut()
					end
					StaticPopup_Show("GUI_QUERY_INSTALL")

					if (callback) then
						UnregisterCallback(callback)
						callback = nil
					end
				end)
			end
			
			-- fire off a restart request if a restart is needed
			F.RestartIfScheduled()
		end
		
		once = true
	end
end

GUIS.OnDisable = function(self)
	saveFramePositions()
end
