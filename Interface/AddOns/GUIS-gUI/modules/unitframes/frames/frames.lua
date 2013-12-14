--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local oUF = ns.oUF or oUF 

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UnitFrames")

-- Lua API
local _G = _G
local gsub, strupper, tag = string.gsub, string.upper, string.tag
local pairs, select, unpack = pairs, select, unpack
local tinsert = table.insert
local setmetatable = setmetatable
local rawget = rawget

-- WoW API
local CreateFrame = CreateFrame
local GetNetStats = GetNetStats
local GetNumPartyMembers = GetNumGroupMembers or GetNumPartyMembers
local GetNumRaidMembers = GetNumGroupMembers or GetNumRaidMembers
local GetRaidTargetIndex = GetRaidTargetIndex
local IsControlKeyDown = IsControlKeyDown
local IsRaidLeader = IsRaidLeader
local IsRaidOfficer = IsRaidOfficer
local IsShiftKeyDown = IsShiftKeyDown
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local SetRaidTarget = SetRaidTarget

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local gAB = LibStub("gActionBars-2.0")
local gFH = LibStub:GetLibrary("gFrameHandler-1.0")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) module:RegisterCallback(...) end

local class = (select(2, UnitClass("player")))

local PostUpdateVisibility, PostUpdateDruidMana
local Shared, UnitSpecific

local settings = {
	-- global GUIS_UNITFRAME_OFFSET added to Y coordinate of all movable frames
	-- GUIS_UNITFRAME_OFFSET = 86 with 2 bars, 55 with 1 bar
	["player"] = {
		movable = true;
		pos = { "BOTTOMRIGHT", "UIParent", "BOTTOM", -78, 0 };
		size = { 210, 62 };
		powerbarsize = 7;
		classbarsize = 5;
		iconsize = 16;
		altpower = {
			["pos"] = { "BOTTOM", UIParent, "BOTTOM", 0, 260 };
			["size"] = { 180, 14 };
		};
	};

	["target"] = {
		movable = true;
		pos = { "BOTTOMLEFT", "UIParent", "BOTTOM", 78, 0 };
		size = { 210, 62 };
		powerbarsize = 7;
		iconsize = 16;
	};

	["pet"] = {
		movable = true;
		pos = { "BOTTOM", "UIParent", "BOTTOM", 0, 40 };
		size = { 126, 28 };
		powerbarsize = 4;
		iconsize = 12;

		["aura"] = {
			size = 23;
			gap = 0;
			height = 1;
			width = 6;
		};
	};

	["targettarget"] = {
		movable = true;
		pos = { "BOTTOM", "UIParent", "BOTTOM", 0, 0 };
		size = { 126, 28 };
		powerbarsize = 4;
		iconsize = 12;
	};

	["focus"] = {
		movable = true;
		pos = { "CENTER", "UIParent", "CENTER", -400, -155 };
		size = { 174, 22 };
		portraitsize = { 40, 40 };
		powerbarsize = 2;
		iconsize = 14;
		aura = {
			size = 20;
			gap = 0;
			height = 2;
			width = 9;
		};
	};

	["focustarget"] = {
		size = { 120, 22 };
		portraitsize = { 40, 40 };
		powerbarsize = 2;
		iconsize = 14;
	};

	["aura"] = {
		size = 27;
		gap = 0;
		height = 3;
		width = 8;
	};
}

local iconList = {
	["default"] = "[guis:quest][guis:leader][guis:masterlooter][guis:maintank][guis:mainassist]";
	["target"] = "[guis:mainassist][guis:maintank][guis:masterlooter][guis:leader][guis:quest]";
}
setmetatable(iconList, { __index = function(t, i) return rawget(t, i) or rawget(t, "default") end })

local defaults = {
	-- module selection
	loadarenaframes = true; 
	loadbossframes = true;
	loadclassbar = true;
	loadpartyframes = true;
	loadpartypetframes = false;
	loadmaintankframes = true;
	loadraidframes = true;
	loadraidpetframes = false;

	-- common stuff
	showHealth = true; -- show health text
	showPlayer = true; -- show player frame as part of the party frames while in a party
	showPower = true; -- show power text (player/target only)
	showDruid = true; -- show druid mana in forms (player only)
	showGridIndicators = true; -- show grid indicators for selected classes

	-- set focus
	shiftToFocus = true; -- shift+click a unit frame to make it your focus target
	focusKey = 1; -- 1 = shift, 2 = ctrl, 3 = alt, 4 = none
	focusButton = 1; -- mouse button
	
	-- party frames
	showPartyPortraits = true; 

	-- raid frames
	autoSpec = true; -- automatically decide what frames to show based on spec
	useGridFrames = true; -- use grid frames instead of the dps/tank layout for 16-40p frames
	showRaidFramesInParty = false; -- show your chosen raid frames when you're in a party, instead of the party frames
	showGridFramesAlways = true; -- use the 16-40 layout for all raids, including party if the above option is 'true' 
	show10pAuras = true; -- show auras in the large 10-15p frames
	
	-- player settings
	showClassBar = true; -- integrated class resource bar
	showExtraClassBar = true; -- external movable class bar
	showExtraClassBarAlways = false; -- false; only in combat, true; always
	showPlayerPortrait = true;
	showPlayerAuras = true;
	
	-- target settings
	showTargetPortrait = true;
	showTargetAuras = true;
	desaturateNonPlayerAuras = true; -- desaturate auras on the target frame not cast by the player
	useTargetAuraFilter = true; -- use the smart aura filter on the target frame
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
			{ -- description
				type = "widget";
				element = "Text";
				order = 2;
				msg = L["These options can be used to change the display and behavior of unit frames within the UI. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."];
			};
			{ -- general
				type = "group";
				order = 10;
				name = "general";
				virtual = true;
				children = { 
					{ -- party
						type = "widget";
						element = "CheckButton";
						name = "loadpartyframes";
						order = 10;
						width = "half"; 
						msg = L["Enable Party Frames"];
						desc = nil;
						set = function(self) 
							GUIS_DB["unitframes"].loadpartyframes = not(GUIS_DB["unitframes"].loadpartyframes)
						end;
						get = function() return GUIS_DB["unitframes"].loadpartyframes end;
					};
					{ -- raid
						type = "widget";
						element = "CheckButton";
						name = "loadraidframes";
						order = 15;
						width = "half"; 
						msg = L["Enable Raid Frames"];
						desc = nil;
						set = function(self) 
							GUIS_DB["unitframes"].loadraidframes = not(GUIS_DB["unitframes"].loadraidframes)
						end;
						get = function() return GUIS_DB["unitframes"].loadraidframes end;
					};
					{ -- boss
						type = "widget";
						element = "CheckButton";
						name = "loadbossframes";
						order = 20;
						width = "half"; 
						msg = L["Enable Boss Frames"];
						desc = nil;
						set = function(self) 
							GUIS_DB["unitframes"].loadbossframes = not(GUIS_DB["unitframes"].loadbossframes)
						end;
						get = function() return GUIS_DB["unitframes"].loadbossframes end;
					};
					{ -- arena
						type = "widget";
						element = "CheckButton";
						name = "loadarenaframes";
						order = 25;
						width = "half"; 
						msg = L["Enable Arena Frames"];
						desc = nil;
						set = function(self) 
							GUIS_DB["unitframes"].loadarenaframes = not(GUIS_DB["unitframes"].loadarenaframes)
						end;
						get = function() return GUIS_DB["unitframes"].loadarenaframes end;
					};
					{ -- focus key title
						type = "widget";
						element = "Title";
						order = 30;
						msg = L["Set Focus"];
					};
					{ -- focus key description
						type = "widget";
						element = "Text";
						order = 31;
						msg = L["Here you can enable and define a mousebutton and optional modifier key to directly set a focus target from clicking on a frame."];
					};
					{ -- enable set focus
						type = "widget";
						element = "CheckButton";
						name = "shiftToFocus";
						order = 32;
						width = "full"; 
						msg = L["Enable Set Focus"];
						desc = L["Enabling this will allow you to quickly set your focus target by clicking the key combination below while holding the mouse pointer over the selected frame."];
						set = function(self) 
							GUIS_DB["unitframes"].shiftToFocus = not(GUIS_DB["unitframes"].shiftToFocus)
						end;
						get = function() return GUIS_DB["unitframes"].shiftToFocus end;
					};
					{ -- set focus modifier key
						type = "widget";
						element = "Dropdown";
						order = 33;
						width = "half";
						msg = L["Modifier Key"];
						desc = nil;
						args = { L["Shift"], L["Ctrl"], L["Alt"], NONE };
						set = function(self, option)
							GUIS_DB["unitframes"].focusKey = UIDropDownMenu_GetSelectedID(self)
							module:UpdateAll()
						end;
						get = function(self) return GUIS_DB["unitframes"].focusKey end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					{ -- set focus modifier mouse button
						type = "widget";
						element = "Dropdown";
						order = 34;
						width = "half";
						msg = L["Mouse Button"];
						desc = nil;
						args = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 };
						set = function(self, option)
							GUIS_DB["unitframes"].focusButton = UIDropDownMenu_GetSelectedID(self)
							module:UpdateAll()
						end;
						get = function(self) return GUIS_DB["unitframes"].focusButton end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					
				};
			};
			{ -- auras
				type = "group";
				order = 25;
				name = "auras";
				virtual = true;
				children = {
					{
						type = "widget";
						element = "Title";
						order = 1;
						msg = L["Auras"];
					};
					{
						type = "widget";
						element = "Text";
						order = 2;
						msg = L["Here you can change the settings for the auras displayed on the player- and target frames."];
					};
					{ -- aura desaturation
						type = "widget";
						element = "CheckButton";
						name = "desaturateNonPlayerAuras";
						order = 10;
						width = "full"; 
						msg = L["Desature target auras not cast by the player"];
						desc = L["This will desaturate auras on the target frame not cast by you, to make it easier to track your own debuffs."];
						set = function(self) 
							GUIS_DB["unitframes"].desaturateNonPlayerAuras = not(GUIS_DB["unitframes"].desaturateNonPlayerAuras)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["unitframes"].desaturateNonPlayerAuras end;
					};			
					{ -- target aura filter
						type = "widget";
						element = "CheckButton";
						name = "useTargetAuraFilter";
						order = 15;
						width = "full"; 
						msg = L["Filter the target auras in combat"];
						desc = L["This will filter out auras not relevant to your role from the target frame while engaged in combat, to make it easier to track your own debuffs."];
						set = function(self) 
							GUIS_DB["unitframes"].useTargetAuraFilter = not(GUIS_DB["unitframes"].useTargetAuraFilter)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["unitframes"].useTargetAuraFilter end;
					};	
					{ -- hot/dot indicators
						type = "widget";
						element = "CheckButton";
						name = "showGridIndicators";
						order = 20;
						width = "full"; 
						msg = L["Enable indicators for HoTs, DoTs and missing buffs."];
						desc = L["This will display small squares on the party- and raidframes to indicate your active HoTs and missing buffs."];
						set = function(self) 
							GUIS_DB["unitframes"].showGridIndicators = not(GUIS_DB["unitframes"].showGridIndicators)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["unitframes"].showGridIndicators end;
					};			
				};
			};
			{ -- groups
				type = "group";
				order = 20;
				name = "groups";
				virtual = true;
				children = {
					{ -- title
						type = "widget";
						element = "Title";
						order = 1;
						msg = L["Groups"];
					};
					{ -- description
						type = "widget";
						element = "Text";
						order = 2;
						msg = L["Here you can change what kind of group frames are used for groups of different sizes."];
					};
					{ -- 5p party
						type = "widget";
						element = "Header";
						order = 100;
						msg = L["5 Player Party"];
					};
					{ -- always raid frames
						type = "widget";
						element = "CheckButton";
						name = "showRaidFramesInParty";
						order = 110;
						width = "full"; 
						msg = L["Use the same frames for parties as for raid groups."];
						desc = L["Enabling this will show the same types of unitframes for 5 player parties as you currently have chosen for 10 player raids."];
						set = function(self) 
							GUIS_DB["unitframes"].showRaidFramesInParty = not(GUIS_DB["unitframes"].showRaidFramesInParty)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["unitframes"].showRaidFramesInParty end;
					};	
					{ -- 10p raid
						type = "widget";
						element = "Header";
						order = 200;
						msg = L["10 Player Raid"];
					};
					{ -- always max size group frames
						type = "widget";
						element = "CheckButton";
						name = "showGridFramesAlways";
						order = 210;
						width = "full"; 
						msg = L["Use same raid frames as for 25 player raids."];
						desc = L["Enabling this will show the same types of unitframes for 10 player raids as you currently have chosen for 25 player raids."];
						set = function(self) 
							GUIS_DB["unitframes"].showGridFramesAlways = not(GUIS_DB["unitframes"].showGridFramesAlways)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["unitframes"].showGridFramesAlways end;
					};	
					{ -- 25p raid
						type = "widget";
						element = "Header";
						order = 300;
						msg = L["25 Player Raid"];
					};
					{ -- decide what frames to use based on spec
						type = "widget";
						element = "CheckButton";
						name = "autoSpec";
						order = 310;
						width = "full"; 
						msg = L["Automatically decide what frames to show based on your current specialization."];
						desc = L["Enabling this will display the Grid layout when you are a Healer, and the smaller DPS layout when you are a Tank or DPSer."];
						set = function(self) 
							GUIS_DB["unitframes"].autoSpec = not(GUIS_DB["unitframes"].autoSpec)
							self:onrefresh()
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["unitframes"].autoSpec end;
						onrefresh = function(self) 
							if (GUIS_DB["unitframes"].autoSpec) then
								self.parent.child.useGridFrames:Disable()
							else
								self.parent.child.useGridFrames:Enable()
							end
						end;
						init = function(self) self:onrefresh() end;
					};	
					{ -- use grid frames (manual)
						type = "widget";
						element = "CheckButton";
						name = "useGridFrames";
						order = 320;
						width = "full"; 
						msg = L["Use Healer/Grid layout."];
						desc = L["Enabling this will use the Grid layout instead of the smaller DPS layout for raid groups."];
						set = function(self) 
							GUIS_DB["unitframes"].useGridFrames = not(GUIS_DB["unitframes"].useGridFrames)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["unitframes"].useGridFrames end;
					};	
					
				};			
			};			
			
			{ -- player
				type = "group";
				order = 30;
				name = "groups";
				virtual = true;
				children = {
					{ -- title
						type = "widget";
						element = "Title";
						order = 1;
						msg = L["Player"];
					};
					{ -- description
						type = "widget";
						element = "Text";
						order = 510;
						msg = { L["The ClassBar is a larger display of class related information like Holy Power, Runes, Eclipse and Combo Points. It is displayed close to the on-screen CastBar and is designed to more easily track your most important resources."] };
					};
					--[[
					{ -- integrated class bar
						type = "widget";
						element = "CheckButton";
						name = "showClassBar";
						order = 550;
						width = "full"; 
						indented = true;
						msg = L["Disable integrated classbar"];
						desc = L["This will disable the integrated classbar in the player unitframe"];
						set = function(self) 
							GUIS_DB["unitframes"].showClassBar = not(GUIS_DB["unitframes"].showClassBar)
						end;
						get = function() return not(GUIS_DB["unitframes"].showClassBar) end;
					};
					]]--
					{ -- external class bar
						type = "widget";
						element = "CheckButton";
						name = "showExtraClassBar";
						order = 545;
						width = "half"; 
						msg = L["Enable large movable classbar"];
						desc = L["This will enable the large on-screen classbar"];
						set = function(self) 
							GUIS_DB["unitframes"].showExtraClassBar = not(GUIS_DB["unitframes"].showExtraClassBar)
							self:onrefresh()
						end;
						get = function() return GUIS_DB["unitframes"].showExtraClassBar end;
						onrefresh = function(self)
							if (GUIS_DB["unitframes"].showExtraClassBar) then
--								self.parent.child.showClassBar:Enable()
								self.parent.child.showExtraClassBarAlways:Enable()
							else
--								self.parent.child.showClassBar:Disable()
								self.parent.child.showExtraClassBarAlways:Disable()
							end
						end;
						init = function(self) 
							self:onrefresh()
						end;
					}; 
					
					{ -- external class bar only in combat or always
						type = "widget";
						element = "Dropdown";
						name = "showExtraClassBarAlways";
						order = 546;
						width = "half";
						msg = nil;
						desc = nil;
						args = { L["Always"], L["Only in Combat"] };
						set = function(self, option)
							GUIS_DB["unitframes"].showExtraClassBarAlways = (UIDropDownMenu_GetSelectedID(self) == 1)
							module:UpdateAll()
						end;
						get = function(self) return (GUIS_DB["unitframes"].showExtraClassBarAlways) and 1 or 2 end;
						init = function(self) UIDropDownMenu_SetSelectedID(self, self:get()) end;
					};
					
					{ -- auras
						type = "widget";
						element = "CheckButton";
						name = "showPlayerAuras";
						order = 20;
						width = "full"; 
						msg = L["Show player auras"];
						desc = L["This decides whether or not to show the auras next to the player frame"];
						set = function(self) 
							GUIS_DB["unitframes"].showPlayerAuras = not(GUIS_DB["unitframes"].showPlayerAuras)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["unitframes"].showPlayerAuras end;
					};						
				};
			}; 
			
			{ -- target
				type = "group";
				order = 40;
				name = "groups";
				virtual = true;
				children = {
					{ -- title
						type = "widget";
						element = "Title";
						order = 1;
						msg = L["Target"];
					};
					{ -- auras
						type = "widget";
						element = "CheckButton";
						name = "showTargetAuras";
						order = 20;
						width = "full"; 
						msg = L["Show target auras"];
						desc = L["This decides whether or not to show the auras next to the target frame"];
						set = function(self) 
							GUIS_DB["unitframes"].showTargetAuras = not(GUIS_DB["unitframes"].showTargetAuras)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["unitframes"].showTargetAuras end;
					};						
				};
			}; 
			
			{ -- pet
			}; 
			
			{ -- focus
			}; 
		};
	};
}

local faq = {
	{
		q = L["My party frames aren't showing!"];
		a = {
			{ 
				type = "text";  
				msg = L["You can set a lot of options for the party- and raidframes from within the options menu."];
			};
			{
				type = "button";
				msg = L["Go to the options menu"];
				click = function(self) 
					PlaySound("igMainMenuOption")
					securecall("CloseAllWindows")
					
					F.OpenToOptionsCategory(F.getName(module:GetName()))
				end;
			};
		};
		tags = { "party", "unitframes" };
	};
	{
		q = L["My raid frames aren't showing!"];
		a = {
			{ 
				type = "text";  
				msg = L["You can set a lot of options for the party- and raidframes from within the options menu."];
			};
			{
				type = "button";
				msg = L["Go to the options menu"];
				click = function(self) 
					PlaySound("igMainMenuOption")
					securecall("CloseAllWindows")
					
					F.OpenToOptionsCategory(F.getName(module:GetName()))
				end;
			};
		};
		tags = { "raid", "unitframes" };
	};
}

-- fix the EclipseBar at login
-- deprecated...?
PostUpdateVisibility = function(self, unit)
	if (self.unit ~= unit) or (powerType ~= "ECLIPSE") then return end

	local power = UnitPower(unit, SPELL_POWER_ECLIPSE)
	local maxPower = UnitPowerMax(unit, SPELL_POWER_ECLIPSE)

	if (self.EclipseBar.LunarBar) then
		self.EclipseBar.LunarBar:SetMinMaxValues(-maxPower, maxPower)
		self.EclipseBar.LunarBar:SetValue(power)
	end

	if (self.EclipseBar.SolarBar) then
		self.EclipseBar.SolarBar:SetMinMaxValues(-maxPower, maxPower)
		self.EclipseBar.SolarBar:SetValue(power * -1)
	end

	if (self.EclipseBar.PostUpdatePower) then
		return self.EclipseBar:PostUpdatePower(unit)
	end
end

PostUpdateDruidMana = function(self, event, unit, powertype)
	--only the player frame will have this unit enabled
	--i mainly place this check for UNIT_DISPLAYPOWER and entering a vehicle
	if(unit ~= "player" or (powertype and powertype ~= "MANA")) then return end

	local druidmana = self.DruidMana
	if(druidmana.PreUpdate) then druidmana:PreUpdate(unit) end

	local min, max = UnitPower("player", SPELL_POWER_MANA), UnitPowerMax("player", SPELL_POWER_MANA)
	druidmana:SetMinMaxValues(0, max)
	druidmana:SetValue(min)

	--check form
	if(UnitPowerType("player") == SPELL_POWER_MANA) or (min == max) then
		return druidmana:Hide()
	else
		druidmana:Show()
	end
end

--------------------------------------------------------------------------------------------------
--		Unit Specific Frame Styles
--------------------------------------------------------------------------------------------------
UnitSpecific = {
	player = function(self, unit)
		self.Power:SetHeight(settings.player.powerbarsize + 2)
		self.Power:SetPoint("BOTTOM", 0, 0)

		self.Health:SetPoint("TOP", self.Power, "TOP", 0, settings.player.powerbarsize + 4)

		local powerValue = self.InfoFrame:CreateFontString()
		powerValue:SetFontObject(GUIS_NumberFontNormal)
		powerValue:SetPoint("TOPRIGHT", self.Power, -2, 0)
		powerValue:SetJustifyH("RIGHT")
		powerValue.frequentUpdates = 1/4

		self:Tag(powerValue, "[guis:power]")

		self.powerValue = powerValue

		local AltPowerBar = CreateFrame("StatusBar", self:GetName() .. "AltPowerBar", self.Health)
		AltPowerBar:SetFrameStrata("LOW")
		AltPowerBar:SetFrameLevel(5)
		AltPowerBar:SetSize(unpack(settings.player.altpower.size))
		AltPowerBar:SetPoint(unpack(settings.player.altpower.pos))
		AltPowerBar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
		AltPowerBar:GetStatusBarTexture():SetHorizTile(false)
		AltPowerBar:SetStatusBarColor(163/255,  24/255,  24/255)
		AltPowerBar:EnableMouse(true)

		local AltPowerBackground = AltPowerBar:CreateTexture(nil, "BACKGROUND")
		AltPowerBackground:SetAllPoints(AltPowerBar)
		AltPowerBackground:SetTexture(M["StatusBar"]["StatusBar"])
		AltPowerBackground:SetVertexColor(163/255/3,  24/255/3,  24/255/3)
		
		F.GlossAndShade(AltPowerBar)
		AltPowerBar:SetUITemplate("backdrop")

		local AltPowerValue = AltPowerBar:CreateFontString()
		AltPowerValue:SetFontObject(GUIS_NumberFontNormal)
		AltPowerValue:ClearAllPoints()
		AltPowerValue:SetPoint("CENTER", AltPowerBar, "CENTER", 0, 0)
		AltPowerValue:SetJustifyH("CENTER")
		AltPowerValue.frequentUpdates = 1/4

		self:Tag(AltPowerValue, "[guis:altpower]")

		self.AltPowerValue = AltPowerValue
		self.AltPowerBar = AltPowerBar

		local Portrait = CreateFrame("PlayerModel", nil, self)
		Portrait:SetPoint("TOP", 0, 0)
		Portrait:SetPoint("LEFT", 0, 0)
		Portrait:SetPoint("RIGHT", 0, 0)
		Portrait:SetPoint("BOTTOM", self.Health, "TOP", 0, 1)
		Portrait:SetAlpha(1)

		Portrait.Shade = Portrait:CreateTexture(nil, "OVERLAY")
		Portrait.Shade:SetTexture(0, 0, 0, 1/2)
		Portrait.Shade:SetPoint("TOPLEFT", -1, 1)
		Portrait.Shade:SetPoint("BOTTOMRIGHT", 1, -1)

		Portrait.Overlay = Portrait:CreateTexture(nil, "OVERLAY")
		Portrait.Overlay:SetTexture(M["Background"]["UnitShader"])
		Portrait.Overlay:SetVertexColor(0, 0, 0, 1)
		Portrait.Overlay:SetAllPoints(Portrait.Shade)
		
		self.Portrait = Portrait
		self.Portrait.PostUpdate = F.PostUpdatePortrait		

		tinsert(self.__elements, F.HidePortrait)
		
		self.Name:ClearAllPoints()
		self.Name:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", 3, -3)

		local NameInfo = self.InfoFrame:CreateFontString()
		NameInfo:SetFontObject(GUIS_UnitFrameNameSmall)
		NameInfo:SetTextColor(1, 1, 1)
		NameInfo:SetPoint("TOPLEFT", self.Name, "BOTTOMLEFT", 0, 1)
		
		self:Tag(NameInfo, "[guis:pvp][level] [race] [raidcolor][smartclass]|r")

		self.NameInfo = NameInfo
		
		self.Castbar:SetAllPoints(Portrait)
		self.Castbar:SetFrameLevel(Portrait:GetFrameLevel() + 1)

		local Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetPoint("TOPRIGHT", self.Castbar, "TOPLEFT", -8, 0)
		Icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		Icon:SetSize(settings.player.iconsize, settings.player.iconsize)
		
		local IconBackdrop = self.Castbar:CreateUIPanel()
		IconBackdrop:SetUITemplate("border")
		IconBackdrop:SetAllPoints(Icon)
		F.GlossAndShade(IconBackdrop)

		local Time = self.Castbar:CreateFontString()
		Time:SetFontObject(GUIS_NumberFontNormal)
		Time:SetJustifyH("RIGHT")
		Time:SetTextColor(1, 1, 1, 1)
		Time:SetPoint("TOPRIGHT", IconBackdrop, "BOTTOMRIGHT", 3, -4)
		
		local SafeZone = self.Castbar:CreateTexture(nil, "OVERLAY")
		SafeZone:SetAllPoints(self.Castbar)
		SafeZone:SetAlpha(1/4)
		
		local Delay = self.Castbar:CreateFontString()
		Delay:SetDrawLayer("OVERLAY")
		Delay:SetFontObject(GUIS_NumberFontSmall)
		Delay:SetJustifyH("RIGHT")
		Delay:SetTextColor(0.5, 0.5, 0.5, 1)
		Delay:SetPoint("TOPRIGHT", self.Castbar, "TOPRIGHT", -3, -3)
		
		SafeZone.Delay = Delay

		local CustomTimeText = function(self, duration)
			if (self.SafeZone) then
				self.SafeZone.Delay:SetFormattedText("|r|cFF888888%d" .. MILLISECONDS_ABBR .. "|r", (select(4, GetNetStats())))
			end

			if (self.casting) then
				self.Time:SetFormattedText("%.1f", self.max - duration)
			elseif (self.channeling) then
				self.Time:SetFormattedText("%.1f", duration)
			end
		end
		
		self.Castbar.SafeZone = SafeZone
		self.Castbar.CustomTimeText = CustomTimeText
		self.Castbar.Time = Time
		self.Castbar.Icon = Icon
		
		--------------------------------------------------------------------------------------------------
		--		Vengeance (for tanks)
		--------------------------------------------------------------------------------------------------
		local vengeanceValue = self.InfoFrame:CreateFontString()
		vengeanceValue:SetFontObject(GUIS_NumberFontNormal)
		vengeanceValue:SetPoint("TOPLEFT", self.Power, 2, 0)
		vengeanceValue:SetJustifyH("LEFT")
		
		self:Tag(vengeanceValue, "[guis:vengeance]")
		
		self.vengeanceValue = vengeanceValue
		
		--------------------------------------------------------------------------------------------------
		--		Swing Timer
		--------------------------------------------------------------------------------------------------
		local Swing = CreateFrame("StatusBar", nil, self)
		Swing:SetPoint("BOTTOM", self.Power, "BOTTOM", 0, 0)
		Swing:SetPoint("LEFT", self.Power, "LEFT", 0, 0)
		Swing:SetPoint("RIGHT", self.Power, "RIGHT", 0, 0)
		Swing:SetHeight(1)
		Swing:SetStatusBarTexture(M["StatusBar"]["StatusBar"])

		Swing.texture = M["StatusBar"]["StatusBar"]
		Swing.color = { 1, 1, 1, 0.9 }
		Swing.colorBG = { 0, 0, 0, 0 }
		Swing.disableMelee = true
		Swing.hideOoc = true

		self.Swing = Swing

		-- druid mana in forms
		if (class == "DRUID") then
			local DruidMana = CreateFrame("StatusBar", self:GetName() .. "DruidMana", self)
			DruidMana:SetFrameLevel(self.Power:GetFrameLevel())
			DruidMana:SetHeight(settings.player.powerbarsize)
			DruidMana:SetPoint("LEFT", self, "LEFT", 0, 0)
			DruidMana:SetPoint("RIGHT", self, "RIGHT", 0, 0)
			DruidMana:SetPoint("BOTTOM", self, "BOTTOM", 0, 21)
			DruidMana:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
			DruidMana:GetStatusBarTexture():SetHorizTile(false)
			DruidMana:SetStatusBarColor(C["PowerBarColor"]["MANA"].r, C["PowerBarColor"]["MANA"].g, C["PowerBarColor"]["MANA"].b)
			F.GlossAndShade(DruidMana)

			local DruidManaTopLine = DruidMana:CreateTexture(nil, "OVERLAY")
			DruidManaTopLine:SetPoint("LEFT", DruidMana)
			DruidManaTopLine:SetPoint("RIGHT", DruidMana)
			DruidManaTopLine:SetPoint("BOTTOM", DruidMana, "TOP")
			DruidManaTopLine:SetHeight(1)
			DruidManaTopLine:SetTexture(unpack(C["background"]))

			local DruidManaBackground = DruidMana:CreateTexture(nil, "BACKGROUND")
			DruidManaBackground:SetAllPoints(DruidMana)
			DruidManaBackground:SetTexture(M["StatusBar"]["StatusBar"])
			DruidManaBackground:SetVertexColor(C["PowerBarColor"]["MANA"].r/3, C["PowerBarColor"]["MANA"].g/3, C["PowerBarColor"]["MANA"].b/3)
			
			local DruidManaValue = self.Power:CreateFontString()
			DruidManaValue:SetFontObject(GUIS_NumberFontNormal)
			DruidManaValue:ClearAllPoints()
			DruidManaValue:SetPoint("BOTTOMLEFT", self.Health, 2, 1)
			DruidManaValue:SetJustifyH("LEFT")
			DruidManaValue.frequentUpdates = 1/4

			self:Tag(DruidManaValue, "[guis:druid]")
			
			DruidMana.Override = PostUpdateDruidMana

			self.DruidManaValue = DruidManaValue
			self.DruidMana = DruidMana
		end
		
		--------------------------------------------------------------------------------------------------
		--		TotemBar
		--------------------------------------------------------------------------------------------------
		if (class == "SHAMAN") then
			local TotemBar = CreateFrame("Frame", nil, self)
			TotemBar:SetFrameLevel(self.Power:GetFrameLevel())

			TotemBar:SetHeight(settings.player.powerbarsize)
			TotemBar:SetPoint("LEFT", self, "LEFT", 0, 0)
			TotemBar:SetPoint("RIGHT", self, "RIGHT", 0, 0)
			TotemBar:SetPoint("BOTTOM", self, "BOTTOM", 0, 21)

			TotemBar.UpdateColors = true

			for i = 1, 4 do
				TotemBar[i] = CreateFrame("Frame", nil, TotemBar)
				TotemBar[i]:SetSize((self:GetWidth() - 3) / 4, settings.player.powerbarsize)
				
				TotemBar[i].StatusBar = CreateFrame("StatusBar", nil, TotemBar[i])
				TotemBar[i].StatusBar:SetSize((self:GetWidth() - 3) / 4, settings.player.powerbarsize)
				TotemBar[i].StatusBar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
				TotemBar[i].StatusBar:SetAllPoints(TotemBar[i])
				F.GlossAndShade(TotemBar[i].StatusBar)

				TotemBar[i].Background = TotemBar[i]:CreateTexture(nil, "BORDER")
				TotemBar[i].Background:SetTexture(M["StatusBar"]["StatusBar"])
				TotemBar[i].Background:SetPoint("TOP", TotemBar[i], "TOP", 0, 1)
				TotemBar[i].Background:SetPoint("BOTTOM", TotemBar[i], "BOTTOM", 0, -1)
				TotemBar[i].Background:SetPoint("RIGHT", TotemBar[i], "RIGHT", 1, 0)
				TotemBar[i].Background:SetPoint("LEFT", TotemBar[i], "LEFT", -1, 0)
				TotemBar[i].Background:SetVertexColor(0, 0, 0, 1)

				TotemBar[i].bg = TotemBar[i]:CreateTexture(nil, "BORDER")
				TotemBar[i].bg:SetAllPoints(TotemBar[i].StatusBar)
				TotemBar[i].bg:SetTexture(M["StatusBar"]["StatusBar"])
				TotemBar[i].bg.multiplier = 1/3
			end
			
			TotemBar[1]:SetPoint("TOPLEFT", TotemBar, "TOPLEFT", 0, 0)
			TotemBar[2]:SetPoint("TOPLEFT", TotemBar[1], "TOPRIGHT", 1, 0)
			TotemBar[3]:SetPoint("TOPLEFT", TotemBar[2], "TOPRIGHT", 1, 0)
			TotemBar[4]:SetPoint("TOPLEFT", TotemBar[3], "TOPRIGHT", 1, 0)
			TotemBar[4]:SetPoint("BOTTOMRIGHT", TotemBar, "BOTTOMRIGHT", 0, 0)
			
			self.TotemBar = TotemBar
		end
	
		--------------------------------------------------------------------------------------------------
		--		RuneBar
		--------------------------------------------------------------------------------------------------
		if (class == "DEATHKNIGHT") then
			local Runes = CreateFrame("Frame", nil, self)
			Runes:SetFrameLevel(self.Power:GetFrameLevel())
			Runes:SetHeight(settings.player.powerbarsize)
			Runes:SetPoint("LEFT", self, "LEFT", 0, 0)
			Runes:SetPoint("RIGHT", self, "RIGHT", 0, 0)
			Runes:SetPoint("BOTTOM", self, "BOTTOM", 0, 21)
			
			for i = 1, 6 do
				Runes[i] = CreateFrame("StatusBar", nil, Runes)
				Runes[i]:SetSize((self:GetWidth() - 5) / 6, settings.player.powerbarsize)
				Runes[i]:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
				F.GlossAndShade(Runes[i])

				Runes[i].Background = Runes[i]:CreateTexture(nil, "BORDER")
				Runes[i].Background:SetTexture(M["StatusBar"]["StatusBar"])
				Runes[i].Background:SetPoint("TOP", Runes[i], "TOP", 0, 1)
				Runes[i].Background:SetPoint("BOTTOM", Runes[i], "BOTTOM", 0, -1)
				Runes[i].Background:SetPoint("RIGHT", Runes[i], "RIGHT", 1, 0)
				Runes[i].Background:SetPoint("LEFT", Runes[i], "LEFT", -1, 0)
				Runes[i].Background:SetVertexColor(0, 0, 0, 1)

				Runes[i].bg = Runes[i]:CreateTexture(nil, "BORDER")
				Runes[i].bg:SetAllPoints(Runes[i])
				Runes[i].bg:SetTexture(M["StatusBar"]["StatusBar"])
				Runes[i].bg.multiplier = 1/3
			end
			
			Runes[1]:SetPoint("TOPLEFT", Runes, "TOPLEFT", 0, 0)
			Runes[2]:SetPoint("TOPLEFT", Runes[1], "TOPRIGHT", 1, 0)
			Runes[3]:SetPoint("TOPLEFT", Runes[2], "TOPRIGHT", 1, 0)
			Runes[4]:SetPoint("TOPLEFT", Runes[3], "TOPRIGHT", 1, 0)
			Runes[5]:SetPoint("TOPLEFT", Runes[4], "TOPRIGHT", 1, 0)
			Runes[6]:SetPoint("TOPLEFT", Runes[5], "TOPRIGHT", 1, 0)
			Runes[6]:SetPoint("BOTTOMRIGHT", Runes, "BOTTOMRIGHT", 0, 0)

			self.Runes = Runes
		end
	
		--------------------------------------------------------------------------------------------------
		--		EclipseBar
		--------------------------------------------------------------------------------------------------
		if (class == "DRUID") then
			local EclipseBar = CreateFrame("Frame", nil, self)
			EclipseBar:SetFrameLevel(self.Power:GetFrameLevel())
			EclipseBar:SetPoint("LEFT", self, "LEFT", 0, 0)
			EclipseBar:SetPoint("RIGHT", self, "RIGHT", 0, 0)
			EclipseBar:SetPoint("BOTTOM", self, "BOTTOM", 0, 21)
			EclipseBar:SetSize(self:GetWidth(), settings.player.powerbarsize + 1)
			
			EclipseBar.bg = EclipseBar:CreateTexture(nil, "BORDER")
			EclipseBar.bg:SetTexture(M["StatusBar"]["StatusBar"])
			EclipseBar.bg:SetAllPoints(EclipseBar)
			EclipseBar.bg:SetVertexColor(0, 0, 0, 1)
			
			EclipseBar.LunarBar = CreateFrame("StatusBar", nil, EclipseBar)
			EclipseBar.LunarBar:SetPoint("LEFT", EclipseBar, "LEFT", 0, 0)
			EclipseBar.LunarBar:SetPoint("TOP", EclipseBar, "TOP", 0, -1)
			EclipseBar.LunarBar:SetPoint("BOTTOM", EclipseBar, "BOTTOM", 0, 0)
			EclipseBar.LunarBar:SetWidth(EclipseBar:GetWidth())
			EclipseBar.LunarBar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
			EclipseBar.LunarBar:SetStatusBarColor(C["PowerBarColor"]["ECLIPSE"].negative.r, C["PowerBarColor"]["ECLIPSE"].negative.g, C["PowerBarColor"]["ECLIPSE"].negative.b, 1)
			
			EclipseBar.SolarBar = CreateFrame("StatusBar", nil, EclipseBar)
			EclipseBar.SolarBar:SetPoint("LEFT", EclipseBar.LunarBar:GetStatusBarTexture(), "RIGHT", 0, 0)
			EclipseBar.SolarBar:SetPoint("TOP", EclipseBar, "TOP", 0, -1)
			EclipseBar.SolarBar:SetPoint("BOTTOM", EclipseBar, "BOTTOM", 0, 0)
			EclipseBar.SolarBar:SetWidth(EclipseBar:GetWidth())
			EclipseBar.SolarBar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
			EclipseBar.SolarBar:SetStatusBarColor(C["PowerBarColor"]["ECLIPSE"].positive.r, C["PowerBarColor"]["ECLIPSE"].positive.g, C["PowerBarColor"]["ECLIPSE"].positive.b, 1)		

			local power = UnitPower(unit, SPELL_POWER_ECLIPSE)
			local maxPower = UnitPowerMax(unit, SPELL_POWER_ECLIPSE)
			EclipseBar.LunarBar:SetMinMaxValues(-maxPower, maxPower)
			EclipseBar.LunarBar:SetValue(power);
			EclipseBar.SolarBar:SetMinMaxValues(-maxPower, maxPower)
			EclipseBar.SolarBar:SetValue(power * -1)

			F.GlossAndShade(EclipseBar.SolarBar, EclipseBar)

			EclipseBar.Text = EclipseBar.SolarBar:CreateFontString()
			EclipseBar.Text:SetFontObject(GUIS_NumberFontNormal)
			EclipseBar.Text:SetPoint("BOTTOMLEFT", self.Health, 2, 1)
			EclipseBar.Text:SetTextColor(1, 1, 1, 1)
			
			self:Tag(EclipseBar.Text, "[pereclipse]%")
			
			self.EclipseBar = EclipseBar
		end

		--------------------------------------------------------------------------------------------------
		--		SoulShards
		--------------------------------------------------------------------------------------------------
		if (class == "WARLOCK") then
			local SoulShards = CreateFrame("Frame", nil, self)
			SoulShards:SetFrameLevel(self.Power:GetFrameLevel())
			SoulShards:SetHeight(settings.player.powerbarsize)
			SoulShards:SetPoint("LEFT", self, "LEFT", 0, 0)
			SoulShards:SetPoint("RIGHT", self, "RIGHT", 0, 0)
			SoulShards:SetPoint("BOTTOM", self, "BOTTOM", 0, 21)

			for i = 1, SHARD_BAR_NUM_SHARDS do
				SoulShards[i] = CreateFrame("StatusBar", nil, SoulShards)
				SoulShards[i]:SetSize((self:GetWidth() - (SHARD_BAR_NUM_SHARDS - 1)) / SHARD_BAR_NUM_SHARDS, settings.player.powerbarsize)
				SoulShards[i]:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
				SoulShards[i]:SetStatusBarColor(0.86 * 0.85, 0.44 * 0.85, 1 * 0.85, 1)
				F.GlossAndShade(SoulShards[i])

				SoulShards[i].bg = SoulShards[i]:CreateTexture(nil, "BORDER")
				SoulShards[i].bg:SetTexture(M["StatusBar"]["StatusBar"])
				SoulShards[i].bg:SetPoint("TOP", SoulShards[i], "TOP", 0, 1)
				SoulShards[i].bg:SetPoint("BOTTOM", SoulShards[i], "BOTTOM", 0, 0)
				SoulShards[i].bg:SetPoint("RIGHT", SoulShards[i], "RIGHT", 1, 0)
				SoulShards[i].bg:SetPoint("LEFT", SoulShards[i], "LEFT", -1, 0)
				SoulShards[i].bg:SetVertexColor(0, 0, 0, 1)

				if i == 1 then
					SoulShards[i]:SetPoint("TOPLEFT", SoulShards, "TOPLEFT", 0, 0)
				elseif i == SHARD_BAR_NUM_SHARDS then
					SoulShards[i]:SetPoint("BOTTOMRIGHT", SoulShards, "BOTTOMRIGHT", 0, 0)
				else
					SoulShards[i]:SetPoint("LEFT", SoulShards[i - 1], "RIGHT", 1, 0)
				end
			end
			self.SoulShards = SoulShards
		end
		
		--------------------------------------------------------------------------------------------------
		--		Holy Power
		--------------------------------------------------------------------------------------------------
		if (class == "PALADIN") then
			local HolyPower = CreateFrame("Frame", nil, self)
			HolyPower:SetHeight(settings.player.powerbarsize)
			HolyPower:SetPoint("LEFT", self, "LEFT", 0, 0)
			HolyPower:SetPoint("RIGHT", self, "RIGHT", 0, 0)
			HolyPower:SetPoint("BOTTOM", self, "BOTTOM", 0, 21)
			HolyPower:SetFrameLevel(self.Power:GetFrameLevel())

			for i = 1, MAX_HOLY_POWER do
				HolyPower[i] = CreateFrame("StatusBar", nil, HolyPower)
				HolyPower[i]:SetSize((self:GetWidth() - (MAX_HOLY_POWER - 1)) / MAX_HOLY_POWER, settings.player.powerbarsize)
				HolyPower[i]:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
				HolyPower[i]:SetStatusBarColor(1.00 * 0.85, 0.95 * 0.85, 0.33 * 0.85, 1)
				F.GlossAndShade(HolyPower[i])

				HolyPower[i].bg = HolyPower[i]:CreateTexture(nil, "BORDER")
				HolyPower[i].bg:SetTexture(M["StatusBar"]["StatusBar"])
				HolyPower[i].bg:SetPoint("TOP", HolyPower[i], "TOP", 0, 1)
				HolyPower[i].bg:SetPoint("BOTTOM", HolyPower[i], "BOTTOM", 0, 0)
				HolyPower[i].bg:SetPoint("RIGHT", HolyPower[i], "RIGHT", 1, 0)
				HolyPower[i].bg:SetPoint("LEFT", HolyPower[i], "LEFT", -1, 0)
				HolyPower[i].bg:SetVertexColor(0, 0, 0, 1)

				if i == 1 then
					HolyPower[i]:SetPoint("TOPLEFT", HolyPower, "TOPLEFT", 0, 0)
				elseif i == MAX_HOLY_POWER then
					HolyPower[i]:SetPoint("BOTTOMRIGHT", HolyPower, "BOTTOMRIGHT", 0, 0)
				else
					HolyPower[i]:SetPoint("LEFT", HolyPower[i - 1], "RIGHT", 1, 0)
				end
			end
			self.HolyPower = HolyPower
		end
	
		--------------------------------------------------------------------------------------------------
		--		CombatFeedback
		--------------------------------------------------------------------------------------------------
		local CombatFeedbackText = self.InfoFrame:CreateFontString()
		CombatFeedbackText:SetFontObject(GUIS_NumberFontHuge)
		CombatFeedbackText:SetPoint("CENTER", Portrait)
		CombatFeedbackText.colors = C["feedbackcolors"]
		
		self.CombatFeedbackText = CombatFeedbackText

		--------------------------------------------------------------------------------------------------
		--		Icons
		--------------------------------------------------------------------------------------------------
		-- Combat Icon
		local Combat = self.IconFrame:CreateTexture(nil, "OVERLAY")
		Combat:SetSize(settings.player.iconsize * 2, settings.player.iconsize * 2)
		Combat:SetPoint("CENTER", self.Health)

		self.Combat = Combat
		
		--------------------------------------------------------------------------------------------------
		--		Auras
		--------------------------------------------------------------------------------------------------
		local AuraHolder = CreateFrame("Frame", nil, self)
		self.AuraHolder = AuraHolder
		
		local Auras = CreateFrame("Frame", nil, self.AuraHolder)
		Auras:SetFrameStrata(self:GetFrameStrata())
		Auras:SetFrameLevel(self:GetFrameLevel() - 1)
		Auras:ClearAllPoints()
		Auras:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 3, 4)
		Auras:SetSize(settings.aura.width * settings.aura.size + (settings.aura.width - 1) * settings.aura.gap, settings.aura.height * settings.aura.size + (settings.aura.height - 1) * settings.aura.gap)

		Auras.size = settings.aura.size
		Auras.spacing = settings.aura.gap

		Auras.initialAnchor = "BOTTOMRIGHT"
		Auras["growth-y"] = "UP"
		Auras["growth-x"] = "LEFT"

		Auras.CustomFilter = F.CustomAuraFilter
		Auras.PostUpdateIcon = F.PostUpdateAura
		Auras.PostCreateIcon = F.PostCreateAura

		self.Auras = Auras

	end;
	
	target = function(self, unit)
		self.Power:SetPoint("BOTTOM", 0, 0)
		self.Power:SetPoint("LEFT", 0, 0)
		self.Power:SetPoint("RIGHT", 0, 0)

		self.Health:SetPoint("TOP", self.Power, "TOP", 0, settings.target.powerbarsize + 4)

		self.healthValue:ClearAllPoints()
		self.healthValue:SetPoint("BOTTOMLEFT", self.Health, 2, 1)
		self.healthValue:SetJustifyH("LEFT")
	
		local powerValue = self.InfoFrame:CreateFontString()
		powerValue:SetFontObject(GUIS_NumberFontNormal)
		powerValue:SetPoint("TOPLEFT", self.Power, 2, 0)
		powerValue:SetJustifyH("LEFT")
		powerValue.frequentUpdates = 1/4
		
		self:Tag(powerValue, "[guis:power]")

		self.powerValue = powerValue

		local Portrait = CreateFrame("PlayerModel", nil, self)
		Portrait:SetPoint("TOP", 0, 0)
		Portrait:SetPoint("LEFT", 0, 0)
		Portrait:SetPoint("RIGHT", 0, 0)
		Portrait:SetPoint("BOTTOM", self.Health, "TOP", 0, 1)
		Portrait:SetAlpha(1)

		Portrait.Shade = Portrait:CreateTexture(nil, "OVERLAY")
		Portrait.Shade:SetTexture(0, 0, 0, 1/2)
		Portrait.Shade:SetPoint("TOPLEFT", -1, 1)
		Portrait.Shade:SetPoint("BOTTOMRIGHT", 1, -1)

		Portrait.Overlay = Portrait:CreateTexture(nil, "OVERLAY")
		Portrait.Overlay:SetTexture(M["Background"]["UnitShader"])
		Portrait.Overlay:SetVertexColor(0, 0, 0, 1)
		Portrait.Overlay:SetAllPoints(Portrait.Shade)
		
		self.Portrait = Portrait
		self.Portrait.PostUpdate = F.PostUpdatePortrait

		tinsert(self.__elements, F.HidePortrait)
		
		self.Castbar:SetAllPoints(Portrait)
		self.Castbar:SetFrameLevel(Portrait:GetFrameLevel() + 1)

		local Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetPoint("TOPLEFT", self.Castbar, "TOPRIGHT", 8, 0)
		Icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		Icon:SetSize(settings.target.iconsize, settings.target.iconsize)
		
		local IconBackdrop = self.Castbar:CreateUIPanel()
		IconBackdrop:SetUITemplate("border")
		IconBackdrop:SetAllPoints(Icon)
		F.GlossAndShade(IconBackdrop)
		
		local Time = self.Castbar:CreateFontString()
		Time:SetFontObject(GUIS_NumberFontNormal)
		Time:SetJustifyH("LEFT")
		Time:SetTextColor(1, 1, 1, 1)
		Time:SetPoint("TOPLEFT", IconBackdrop, "BOTTOMLEFT", -3, -4)

		local CustomTimeText = function(self, duration)
			if self.casting then
				self.Time:SetFormattedText("%.1f", self.max - duration)
			elseif self.channeling then
				self.Time:SetFormattedText("%.1f", duration)
			end
		end

		self.Castbar.CustomTimeText = CustomTimeText
		self.Castbar.Time = Time
		self.Castbar.Icon = Icon
		
		self.Name:ClearAllPoints()
		self.Name:SetPoint("TOPRIGHT", self.Portrait, "TOPRIGHT", -3, -3)
		self.Name:SetJustifyH("RIGHT")

		local NameInfo = self.InfoFrame:CreateFontString()
		NameInfo:SetFontObject(GUIS_UnitFrameNameSmall)
		NameInfo:SetTextColor(1, 1, 1)
		NameInfo:SetPoint("TOPRIGHT", self.Name, "BOTTOMRIGHT", 0, 1)
		NameInfo:SetJustifyH("RIGHT")
		self:Tag(NameInfo, "[race] [raidcolor][smartclass]|r [difficulty][smartlevel][guis:pvp]|r")

		self.NameInfo = NameInfo
		
		self.IconFrame:ClearAllPoints()
		self.IconFrame:SetSize(settings[unit].iconsize, self:GetHeight())
		self.IconFrame:SetPoint("TOPLEFT", self, "TOPRIGHT", 8, 0)
		
		--------------------------------------------------------------------------------------------------
		--		Threat
		--------------------------------------------------------------------------------------------------
		local threatValue = self.InfoFrame:CreateFontString()
		threatValue:SetFontObject(GUIS_NumberFontNormal)
		threatValue:SetPoint("TOPRIGHT", self.Power, -2, 0)
		threatValue:SetJustifyH("RIGHT")
		
		self:Tag(threatValue, "[guis:threat]")
		
		self.threatValue = threatValue
		
		--------------------------------------------------------------------------------------------------
		--		CombatFeedback
		--------------------------------------------------------------------------------------------------
		local CombatFeedbackText = self.InfoFrame:CreateFontString()
		CombatFeedbackText:SetFontObject(GUIS_NumberFontHuge)
		CombatFeedbackText:SetPoint("CENTER", Portrait)
		CombatFeedbackText.colors = C["feedbackcolors"]
		
		self.CombatFeedbackText = CombatFeedbackText

		--------------------------------------------------------------------------------------------------
		--		Combo Points
		--------------------------------------------------------------------------------------------------
		--[[
		local CPoints = {}
		for index = 1, MAX_COMBO_POINTS do
			local CPoint = self.IconFrame:CreateTexture(nil, "BACKGROUND")

			CPoint:SetSize(12, 12)
			CPoint:SetPoint("BOTTOMLEFT", self.Power, "BOTTOMLEFT", (index - 1) * (CPoint:GetWidth()) + 4, 0)
			CPoint:SetTexture(settings.texture.bubble)
			CPoint:SetVertexColor(unpack(C["combopointcolors"][index]))

			CPoints[index] = CPoint
		end

		for i = 1,5,1 do
		end

		self.CPoints = CPoints
		]]--
		
		--------------------------------------------------------------------------------------------------
		--		Auras
		--------------------------------------------------------------------------------------------------
		local AuraHolder = CreateFrame("Frame", nil, self)
		self.AuraHolder = AuraHolder
		
		local Auras = CreateFrame("Frame", nil, self.AuraHolder)
		Auras:SetFrameStrata(self:GetFrameStrata())
		Auras:SetFrameLevel(self:GetFrameLevel() - 1)
		Auras:ClearAllPoints()
		Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -3, 4)
		Auras:SetSize(settings.aura.width * settings.aura.size + (settings.aura.width - 1) * settings.aura.gap, settings.aura.height * settings.aura.size + (settings.aura.height - 1) * settings.aura.gap)

		Auras.size = settings.aura.size
		Auras.spacing = settings.aura.gap

		Auras.initialAnchor = "BOTTOMLEFT"
		Auras["growth-y"] = "UP"
		Auras["growth-x"] = "RIGHT"

		Auras.CustomFilter = F.CustomAuraFilter
		Auras.PostUpdateIcon = F.PostUpdateAura
		Auras.PostCreateIcon = F.PostCreateAura

		self.Auras = Auras
	end;
	
	targettarget = function(self, unit)
		self.Name:ClearAllPoints()
		self.Name:SetPoint("LEFT", self.Health, "LEFT", 3, 0)
		
		self.healthValue:ClearAllPoints()
		self.healthValue:SetPoint("RIGHT", self.Health, -3, 0)
	end;

	pet = function(self, unit)
		self.Name:ClearAllPoints()
		self.Name:SetPoint("LEFT", self.Health, "LEFT", 3, 0)
		
		self.healthValue:ClearAllPoints()
		self.healthValue:SetPoint("RIGHT", self.Health, -3, 0)

		--------------------------------------------------------------------------------------------------
		--		Auras
		--------------------------------------------------------------------------------------------------
		local AuraHolder = CreateFrame("Frame", nil, self)
		self.AuraHolder = AuraHolder
		
		local Auras = CreateFrame("Frame", nil, self.AuraHolder)
		Auras:SetFrameStrata(self:GetFrameStrata())
		Auras:SetFrameLevel(self:GetFrameLevel() - 1)
		Auras:ClearAllPoints()
		Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -3, 3)
		Auras:SetSize(settings.pet.aura.width * settings.pet.aura.size + (settings.pet.aura.width - 1) * settings.pet.aura.gap, settings.pet.aura.height * settings.pet.aura.size + (settings.pet.aura.height - 1) * settings.pet.aura.gap)

		Auras.size = settings.pet.aura.size
		Auras.spacing = settings.pet.aura.gap

		Auras.initialAnchor = "BOTTOMLEFT"
		Auras["growth-y"] = "UP"
		Auras["growth-x"] = "RIGHT"

		Auras.CustomFilter = F.CustomPetAuraFilter
		Auras.PostUpdateIcon = F.PostUpdateAura
		Auras.PostCreateIcon = F.PostCreateAura

		self.Auras = Auras
	end;
	
	focus = function(self, unit)
		self.Name:ClearAllPoints()
		self.Name:SetPoint("LEFT", self.Health, "LEFT", 2, 0)
		
		self.healthValue:ClearAllPoints()
		self.healthValue:SetPoint("RIGHT", self.Health, "RIGHT", -2, 0)

		--------------------------------------------------------------------------------------------------
		--		Auras
		--------------------------------------------------------------------------------------------------
		local adb = settings.focus.aura

		local AuraHolder = CreateFrame("Frame", nil, self)
		self.AuraHolder = AuraHolder
		
		local Auras = CreateFrame("Frame", nil, self.AuraHolder)
		
		Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -3, 3)
		Auras:SetSize(adb.width * adb.size + (adb.width - 1) * adb.gap, adb.height * adb.size + (adb.height - 1) * adb.gap)

		Auras.size = adb.size
		Auras.spacing = adb.gap

		Auras.initialAnchor = "BOTTOMLEFT"
		Auras["growth-y"] = "UP"
		Auras["growth-x"] = "RIGHT"

--			Auras.buffFilter = "HELPFUL RAID PLAYER"
--			Auras.debuffFilter = "HARMFUL"
--			Auras.CustomFilter = F.CustomAuraFilter

		Auras.PostUpdateIcon = F.PostUpdateAura
		Auras.PostCreateIcon = F.PostCreateAura

		self.Auras = Auras

		--------------------------------------------------------------------------------------------------
		--		Cast Icon
		--------------------------------------------------------------------------------------------------
		local Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
		Icon:SetPoint("TOPRIGHT", self, "TOPLEFT", -8, 0)
		Icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		Icon:SetSize(self:GetHeight(), self:GetHeight())
		
		local IconBackdrop = self.Castbar:CreateUIPanel()
		IconBackdrop:SetUITemplate("border")
		IconBackdrop:SetAllPoints(Icon)
		F.GlossAndShade(IconBackdrop)

		self.Castbar.Icon = Icon
	end;
	
	focustarget = function(self, unit)
		self.Name:ClearAllPoints()
		self.Name:SetPoint("RIGHT", self.Health, "RIGHT", -2, 0)
		self.Name:SetJustifyH("RIGHT")
		
		self.healthValue:ClearAllPoints()
		self.healthValue:SetPoint("LEFT", self.Health, "LEFT", 2, 0)
	end;
}

--------------------------------------------------------------------------------------------------
--		Shared Frame Styles
--------------------------------------------------------------------------------------------------
Shared = function(self, unit)
	F.AllFrames(self, unit)

	self:SetSize(unpack(settings[unit].size))

	--------------------------------------------------------------------------------------------------
	--		Power
	--------------------------------------------------------------------------------------------------
	local Power = (unit == "target") and F.ReverseBar(self) or CreateFrame("StatusBar", nil, self)
	
	Power:SetHeight(settings[unit].powerbarsize + 2)
	Power:SetPoint("BOTTOM", 0, 0)
	Power:SetPoint("LEFT", 0, 0)
	Power:SetPoint("RIGHT", 0, 0)
	Power:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	Power:SetFrameLevel(15)
	F.GlossAndShade(Power)
	
	local PowerTopLine = Power:CreateTexture(nil, "OVERLAY")
	PowerTopLine:SetPoint("LEFT", Power)
	PowerTopLine:SetPoint("RIGHT", Power)
	PowerTopLine:SetPoint("BOTTOM", Power, "TOP")
	PowerTopLine:SetHeight(1)
	PowerTopLine:SetTexture(unpack(C["background"]))

	local PowerBackground = Power:CreateTexture(nil, "BACKGROUND")
	PowerBackground:SetAllPoints(Power)
	PowerBackground:SetTexture(M["StatusBar"]["StatusBar"])

	Power.frequentUpdates = 1/4
	Power.colorTapping = true
	Power.colorDisconnected = true
	Power.colorPower = true
	Power.Smooth = true

	PowerBackground.multiplier = 1/3

	self.Power = Power
	self.Power.bg = PowerBackground
	
	--------------------------------------------------------------------------------------------------
	--		Health
	--------------------------------------------------------------------------------------------------
	local Health = (unit == "target") and F.ReverseBar(self) or CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOP", 0, 0)
	Health:SetPoint("BOTTOM", Power, "TOP", 0, 1)
	Health:SetPoint("LEFT", 0, 0)
	Health:SetPoint("RIGHT", 0, 0)
	Health:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	F.GlossAndShade(Health)

	local HealthTopLine = Health:CreateTexture(nil, "OVERLAY")
	HealthTopLine:SetPoint("LEFT", Health)
	HealthTopLine:SetPoint("RIGHT", Health)
	HealthTopLine:SetPoint("BOTTOM", Health, "TOP")
	HealthTopLine:SetHeight(1)
	HealthTopLine:SetTexture(unpack(C["background"]))

	local HealthBackground = Health:CreateTexture(nil, "BACKGROUND")
	HealthBackground:SetAllPoints(Health)
	HealthBackground:SetTexture(M["StatusBar"]["StatusBar"])

	Health.frequentUpdates = 1/4
	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.colorClass = true
	Health.colorSmooth = true
	Health.Smooth = true

	HealthBackground.multiplier = 1/3

	self.Health = Health
	self.Health.bg = HealthBackground

	--------------------------------------------------------------------------------------------------
	--		Heal Prediction
	--------------------------------------------------------------------------------------------------
	local myBar = (unit == "target") and F.ReverseBar(self.Health) or CreateFrame("StatusBar", nil, self.Health)
	if (unit == "target") then
		myBar:SetPoint("TOPRIGHT", self.Health:GetStatusBarTexture(), "TOPLEFT", 0, 0)
		myBar:SetPoint("BOTTOMRIGHT", self.Health:GetStatusBarTexture(), "BOTTOMLEFT", 0, 0)
	else
		myBar:SetPoint("TOPLEFT", self.Health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		myBar:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	end
	myBar:SetWidth(self:GetWidth())
	myBar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	myBar:SetStatusBarColor(0, 1, 0.5, 0.25)

	local otherBar = (unit == "target") and F.ReverseBar(self.Health) or CreateFrame("StatusBar", nil, self.Health)
	if (unit == "target") then
		otherBar:SetPoint("TOPRIGHT", myBar:GetStatusBarTexture(), "TOPLEFT", 0, 0)
		otherBar:SetPoint("BOTTOMRIGHT", myBar:GetStatusBarTexture(), "BOTTOMLEFT", 0, 0)
	else
		otherBar:SetPoint("TOPLEFT", myBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		otherBar:SetPoint("BOTTOMLEFT", myBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	end
	otherBar:SetWidth(self:GetWidth())
	otherBar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	otherBar:SetStatusBarColor(0, 1, 0, 0.25)

	self.HealPrediction = {
		myBar = myBar;
		otherBar = otherBar;
		maxOverflow = 1;
	}
	
	--------------------------------------------------------------------------------------------------
	--		Castbar
	--------------------------------------------------------------------------------------------------
	local Castbar = (unit == "target") and F.ReverseBar(self) or CreateFrame("StatusBar", nil, self)
	Castbar:SetAllPoints(Health)
	Castbar:SetFrameLevel(Health:GetFrameLevel() + 1)
	Castbar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	Castbar:SetStatusBarColor(1.0, 1.0, 1.0, 0.33)

	self.Castbar = Castbar

	--------------------------------------------------------------------------------------------------
	--		Texts and Values
	--------------------------------------------------------------------------------------------------
	local InfoFrame = CreateFrame("Frame", nil, self)
	InfoFrame:SetFrameLevel(30)
	
	self.InfoFrame = InfoFrame

	local healthValue = self.InfoFrame:CreateFontString()
	healthValue:SetFontObject(((unit == "focus" or unit == "focustarget") and GUIS_NumberFontSmall) or GUIS_NumberFontNormal)
	healthValue:SetPoint("BOTTOMRIGHT", Health, -2, 1)
	healthValue:SetJustifyH("RIGHT")
	healthValue.frequentUpdates = 1/4

	self:Tag(healthValue, "[guis:health]")
	
	self.healthValue = healthValue

	local Name = self.InfoFrame:CreateFontString()
	Name:SetFontObject((unit == "player" or unit == "target") and GUIS_UnitFrameNameHuge or (unit == "focus" or unit == "focustarget") and GUIS_UnitFrameNameSmall or GUIS_UnitFrameNameNormal)
	Name:SetTextColor(1, 1, 1)
	Name:SetJustifyH("LEFT")
	Name:SetSize(self:GetWidth() - 40, (select(2, Name:GetFont())))
	Name:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 3, -3)

	self:Tag(Name, "[guis:name]" .. ((unit == "player") and "[guis:resting]" or ""))
	
	self.Name = Name

	--------------------------------------------------------------------------------------------------
	--		Icons
	--------------------------------------------------------------------------------------------------
	local IconFrame = CreateFrame("Frame", nil, self)
	IconFrame:SetFrameLevel(60)

	self.IconFrame = IconFrame
	
	local RaidIcon = IconFrame:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetSize(settings[unit].iconsize * 0.75, settings[unit].iconsize * 0.75)
	RaidIcon:SetPoint("CENTER", self, "TOP")
	RaidIcon:SetTexture(M["Icon"]["RaidTarget"])

	self.RaidIcon = RaidIcon
	
	local IconStack = IconFrame:CreateFontString()
	IconStack:SetFontObject((unit == "player" or unit == "target") and GUIS_NumberFontNormal or GUIS_NumberFontSmall)
	IconStack:SetTextColor(1, 1, 1)
	IconStack:SetJustifyH((unit == "target") and "RIGHT" or "LEFT")
	IconStack:SetJustifyV("TOP")
	IconStack:SetPoint((unit == "target") and "TOPRIGHT" or "TOPLEFT", self, (unit == "target") and "TOPRIGHT" or "TOPLEFT", 0, (select(2, IconStack:GetFont())) - 2)
	
	self.IconStack = IconStack
	
	self:Tag(self.IconStack, iconList[unit])
	
	--------------------------------------------------------------------------------------------------
	--		Spell Range
	--------------------------------------------------------------------------------------------------
	if (unit ~= "player") then
		if UnitInParty(unit) or UnitInRaid(unit) then
			local Range = {
				insideAlpha = 1.0;
				outsideAlpha = 0.33;
			}
			self.Range = Range
		else	
			local SpellRange = {
				insideAlpha = 1.0; 
				outsideAlpha = 0.33; 
			}
			self.SpellRange = SpellRange
		end
	end
	
	if UnitSpecific[unit] then
		UnitSpecific[unit](self, unit)
	end
	
	F.PostUpdateOptions(self, unit)
end

--module.Install = function(self, frame, option)
--end

module.UpdateAll = function(self)
	F.ApplyToAllUnits(F.PostUpdateOptions)
	
	local raid = LibStub("gCore-3.0"):GetModule("GUIS-gUI: UnitFramesRaid")
	if (raid) then
		raid:UpdateAll()
	end
	
	local party = LibStub("gCore-3.0"):GetModule("GUIS-gUI: UnitFramesParty")
	if (party) then
		party:UpdateAll()
	end
	
	local arena = LibStub("gCore-3.0"):GetModule("GUIS-gUI: UnitFramesArena")
	if (arena) then
		arena:UpdateAll()
	end
	
	local boss = LibStub("gCore-3.0"):GetModule("GUIS-gUI: UnitFramesBoss")
	if (boss) then
		boss:UpdateAll()
	end
	
	local classbar = LibStub("gCore-3.0"):GetModule("GUIS-gUI: UnitFramesClassBar")
	if (classbar) then
		classbar:UpdateAll()
	end
	
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName(self:GetName()))
end

module.RestoreDefaults = function(self)
	GUIS_DB["unitframes"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["unitframes"] = GUIS_DB["unitframes"] or {}
	GUIS_DB["unitframes"] = ValidateTable(GUIS_DB["unitframes"], defaults)
end

module.OnInit = function(self)
	if (F.kill(self:GetName())) then 
		self:Kill() 
		return 
	end

	-- this stuff is causing all sorts of errors
	PetFrame_Update = noop

	--[[
	PetFrame:UnregisterAllEvents()
	PetFrame:Hide()
	PetFrame.Show = noop
	]]--

	-- raid target menu for all units on Shift + Ctrl + LeftMouseButton
	local menuFrame = CreateFrame("Frame", "GUIS_RaidTargetDropDown", UIParent, "UIDropDownMenuTemplate")
	local menuList = function() return {
		{
			text = RAID_TARGET_NONE,
			func = function() SetRaidTarget("target", 0) end
		},
		
		{
			text = "|T" .. M["Icon"]["RaidTarget"] .. ":0:0:0:0:256:256:196:256:64:128|t " .. "|cff" .. RGBToHex(0.98, 0.98, 0.98) .. RAID_TARGET_8 .. "|r",
			checked = (GetRaidTargetIndex("mouseover") == 8),
			func = function() SetRaidTarget("target", 8) end
		},
		
		{
			text = "|T" .. M["Icon"]["RaidTarget"] .. ":0:0:0:0:256:256:128:196:64:128|t " .. "|cff" .. RGBToHex(1.0, 0.24, 0.168) .. RAID_TARGET_7 .. "|r",
			checked = (GetRaidTargetIndex("mouseover") == 7),
			func = function() SetRaidTarget("target", 7) end
		},
		
		{
			text = "|T" .. M["Icon"]["RaidTarget"] .. ":0:0:0:0:256:256:64:128:64:128|t " .. "|cff" .. RGBToHex(0, 0.71, 1) .. RAID_TARGET_6 .. "|r",
			checked = (GetRaidTargetIndex("mouseover") == 6),
			func = function() SetRaidTarget("target", 6) end
		},
		
		{
			text = "|T" .. M["Icon"]["RaidTarget"] .. ":0:0:0:0:256:256:0:64:64:128|t " .. "|cff" .. RGBToHex(0.7, 0.82, 0.875) .. RAID_TARGET_5 .. "|r",
			checked = (GetRaidTargetIndex("mouseover") == 5),
			func = function() SetRaidTarget("target", 5) end
		},
		
		{
			text = "|T" .. M["Icon"]["RaidTarget"] .. ":0:0:0:0:256:256:196:256:0:64|t " .. "|cff" .. RGBToHex(0.04, 0.95, 0) .. RAID_TARGET_4 .. "|r",
			checked = (GetRaidTargetIndex("mouseover") == 4),
			func = function() SetRaidTarget("target", 4) end
		},
		
		{
			text = "|T" .. M["Icon"]["RaidTarget"] .. ":0:0:0:0:256:256:128:196:0:64|t " .. "|cff" .. RGBToHex(0.83, 0.22, 0.9) .. RAID_TARGET_3 .. "|r",
			checked = (GetRaidTargetIndex("mouseover") == 4),
			func = function() SetRaidTarget("target", 3) end
		},
		
		{
			text = "|T" .. M["Icon"]["RaidTarget"] .. ":0:0:0:0:256:256:64:128:0:64|t " .. "|cff" .. RGBToHex(0.98, 0.57, 0) .. RAID_TARGET_2 .. "|r",
			checked = (GetRaidTargetIndex("mouseover") == 2),
			func = function() SetRaidTarget("target", 2) end
		},
		
		{
			text = "|T" .. M["Icon"]["RaidTarget"] .. ":0:0:0:0:256:256:0:64:0:64|t " .. "|cff" .. RGBToHex(1.0, 0.92, 0) .. RAID_TARGET_1 .. "|r",
			checked = (GetRaidTargetIndex("mouseover") == 1),
			func = function() SetRaidTarget("target", 1) end
		},
	} end

	WorldFrame:HookScript("OnMouseDown", function(self, button)
		if (button == "LeftButton") and IsShiftKeyDown() and IsControlKeyDown() and UnitExists("mouseover") then 
			local inParty = (GetNumPartyMembers() > 0)
			local inRaid = (GetNumRaidMembers() > 0)
			
			if (inRaid and (IsRaidLeader() or IsRaidOfficer()) or (inParty and not inRaid)) or ((not inParty) and (not inRaid)) then
				if (DropDownList1:IsShown()) then
					DropDownList1:Hide()
				else
					EasyMenu(menuList(), menuFrame, "cursor", 0, 0, "MENU", 1)
				end
			end
		end
	end)

	local frames = {}
	local actionbarDependantFrame = {
		player = true;
		target = true;
		pet = true;
		targettarget = true;
	}
	
	-- this shouldn't happen in combat, but better safe than sorry
	local postUpdatePositions = function(self, event, barName, show)
		if (InCombatLockdown()) then
			print(L["Due to entering combat at the worst possible time the UnitFrames were unable to complete the layout change.|nPlease reload the user interface with |cFF4488FF/rl|r to complete the operation!"])
			return
		end
		
		if (barName ~= 2) and (barName ~= 3) then
			return
		end

		for unit, _ in pairs(UnitSpecific) do
			if (actionbarDependantFrame[unit]) and not(frames[unit]:HasMoved()) then
				local f, g, h, i, j = unpack(settings[unit].pos)
				frames[unit]:PlaceAndSave(f, g, h, i, j + (GUIS_UNITFRAME_OFFSET or 0))
			end
		end
	end
	
	oUF:RegisterStyle(addon.."Frames", Shared)
	oUF:Factory(function(self)

		self:SetActiveStyle(addon.."Frames")

		for unit, _ in pairs(UnitSpecific) do
			frames[unit] = self:Spawn(unit)
		end

		for unit, _ in pairs(UnitSpecific) do
			frames[unit]:ClearAllPoints()

			if (unit == "focustarget") then
				-- always glue the focustarget to the right side of the focus frame
				frames[unit]:SetPoint("LEFT", frames.focus, "RIGHT", 12, 0)
			else
				if (settings[unit].movable) then
					local f, g, h, i, j = unpack(settings[unit].pos)
					frames[unit]:PlaceAndSave(f, g, h, i, j + (GUIS_UNITFRAME_OFFSET or 0))
				else
					frames[unit]:SetPoint(unpack(settings[unit].pos))
				end
			end
		end
		
		RegisterCallback("GUIS_ACTIONBAR_BUTTON_UPDATE", postUpdatePositions) -- updated when actionbuttons are toggled/resized
		RegisterCallback("GUIS_ACTIONBAR_POSITION_UPDATE", postUpdatePositions) -- update when actionbars are moved
		RegisterCallback("GUIS_ACTIONBAR_VISIBILITY_UPDATE", postUpdatePositions) -- update when actionbars are toggled
	end)
	
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
	end

	-- register the FAQ
	do
		local FAQ = LibStub("gCore-3.0"):GetModule("GUIS-gUI: FAQ")
		FAQ:NewGroup(faq)
	end	
	
	-- enable target frame aura filter in combat
	CreateChatCommand(function() 
		GUIS_DB["unitframes"].useTargetAuraFilter = true 
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "enabletargetaurafilter")
	
	-- disable target frame aura filter 
	CreateChatCommand(function() 
		GUIS_DB["unitframes"].useTargetAuraFilter = false 
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "disabletargetaurafilter")

	-- enable desaturation of auras on the target frame not cast by the player
	CreateChatCommand(function()
		GUIS_DB["unitframes"].desaturateNonPlayerAuras = true
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "enableauradesaturation")

	-- disable desaturation of auras on the target frame not cast by the player
	CreateChatCommand(function()
		GUIS_DB["unitframes"].desaturateNonPlayerAuras = false
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "disableauradesaturation")

	-- show health values on the health bars
	CreateChatCommand(function() 
		GUIS_DB["unitframes"].showHealth = true
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "enableunitframehealth")

	-- hide health values 
	CreateChatCommand(function() 
		GUIS_DB["unitframes"].showHealth = false
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "disableunitframehealth")
	
	-- show power values on the power bars
	CreateChatCommand(function() 
		GUIS_DB["unitframes"].showPower = true
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "enableunitframepower")

	-- hide power values
	CreateChatCommand(function() 
		GUIS_DB["unitframes"].showPower = false
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "disableunitframepower")

	-- enable druid mana text
	CreateChatCommand(function() 
		GUIS_DB["unitframes"].showDruid = true
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "enableunitframedruidmana")

	-- disable druid mana text
	CreateChatCommand(function() 
		GUIS_DB["unitframes"].showDruid = false
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "disableunitframedruidmana")
	
	CreateChatCommand(function()
		GUIS_DB["unitframes"].loadraidframes = true
		F.ScheduleRestart()
		F.RestartIfScheduled()
	end, "enableraidframes")

	CreateChatCommand(function()
		GUIS_DB["unitframes"].loadraidframes = false
		F.ScheduleRestart()
		F.RestartIfScheduled()
	end, "disableraidframes")

	CreateChatCommand(function()
		GUIS_DB["unitframes"].loadpartyframes = true
		F.ScheduleRestart()
		F.RestartIfScheduled()
	end, "enablepartyframes")

	CreateChatCommand(function()
		GUIS_DB["unitframes"].loadpartyframes = false
		F.ScheduleRestart()
		F.RestartIfScheduled()
	end, "disablepartyframes")

	CreateChatCommand(function()
		GUIS_DB["unitframes"].loadarenaframes = true
		F.ScheduleRestart()
		F.RestartIfScheduled()
	end, "enablearenaframes")

	CreateChatCommand(function()
		GUIS_DB["unitframes"].loadarenaframes = false
		F.ScheduleRestart()
		F.RestartIfScheduled()
	end, "disablearenaframes")

	CreateChatCommand(function()
		GUIS_DB["unitframes"].loadbossframes = true
		F.ScheduleRestart()
		F.RestartIfScheduled()
	end, "enablebossframes")

	CreateChatCommand(function()
		GUIS_DB["unitframes"].loadbossframes = false
		F.ScheduleRestart()
		F.RestartIfScheduled()
	end, "disablebossframes")

	CreateChatCommand(function()
		GUIS_DB["unitframes"].loadclassbar = true
		F.ScheduleRestart()
		F.RestartIfScheduled()
	end, "enableclassbar")

	CreateChatCommand(function()
		GUIS_DB["unitframes"].loadclassbar = false
		F.ScheduleRestart()
		F.RestartIfScheduled()
	end, "disableclassbar")
	
		CreateChatCommand(function()
		GUIS_DB["unitframes"].showGridIndicators = true
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "enablegridindicators")

	CreateChatCommand(function()
		GUIS_DB["unitframes"].showGridIndicators = false
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "disablegridindicators")
end
