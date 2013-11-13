--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: Castbars")

-- Lua API
local select, unpack = select, unpack

-- WoW API
local CopyTable = CopyTable
local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitName = UnitName
local UIParent = UIParent

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local ScheduleTimer = function(...) module:ScheduleTimer(...) end

local skinBar
local styleTimer, stylebar
local styleAllBars, styleAllTimers

local New, OnUpdate, OnEvent, Enable, Disable
local AddElement
local UNIT_SPELLCAST_START
local UNIT_SPELLCAST_FAILED
local UNIT_SPELLCAST_INTERRUPTED
local UNIT_SPELLCAST_INTERRUPTIBLE
local UNIT_SPELLCAST_NOT_INTERRUPTIBLE
local UNIT_SPELLCAST_DELAYED
local UNIT_SPELLCAST_STOP
local UNIT_SPELLCAST_CHANNEL_START
local UNIT_SPELLCAST_CHANNEL_UPDATE
local UNIT_SPELLCAST_CHANNEL_STOP

local player, pet, target, focus

local _, playerClass = UnitClass("player")
local castBars = {}

-- our big golden, gaudy and gay timer numbers! WE LOVE THEM! :D
local bigNumbers = {	
	texture = M["Texture"]["BigTimerNumbers"]; 
	w = 256; 
	h = 170; 
	texW = 1024; 
	texH = 512;
	numberHalfWidths = {
		--0,   1,   2,   3,   4,   5,   6,   7,   8,   9,
		35/128, 14/128, 33/128, 32/128, 36/128, 32/128, 33/128, 29/128, 31/128, 31/128,
	};
}

local MAX_WIDTH, MIN_WIDTH = 220, 120
local MAX_HEIGHT, MIN_HEIGHT = 28, 16

local defaults = {
	showPlayerBar = true; -- show player castbar
	showTargetBar = false; -- show target castbar
	showFocusBar = false; -- show focus castbar
	showPetBar = true; -- show pet castbar
	showTradeSkill = true; -- use our castbars for tradeskills 

	player = { 
		size = { 180, 22 }; -- Match Target.
		pos = { "BOTTOM", UIParent, "BOTTOM", 19, 250 }; -- (19)px (28+4+6)/2 (iconW+padding+2xBorder)
	};
	
	pet = { 
		size = { 120, 16 };
		pos = { "TOPLEFT", UIParent, "BOTTOM", -(58 + 19), 242 }; -- -(58 + 19)px
	};
	
	target = { 
		size = { 180, 22 };
		pos = { "BOTTOMLEFT", UIParent, "CENTER", 60, 48 }; -- 80, 8
	};
	
	focus = { 
		size = { 120, 16 };
		pos = { "TOPLEFT", UIParent, "CENTER", 110, 40 }; -- 130, 0
	};
}

local menuTable = {
	{
		type = "group";
		name = module:GetName();
		order = 1;
		virtual = true;
		children = {
			{ -- menu title
				type = "widget";
				element = "Title";
				order = 1;
				msg = F.getName(module:GetName());
			};
			{ -- subtext
				type = "widget";
				element = "Text";
				order = 2;
				msg = L["Here you can change the size and visibility of the on-screen castbars. If you wish to change their position, you can unlock them for movement with |cFF4488FF/glock|r."];
			};
			{ -- enable player
				type = "widget";
				element = "CheckButton";
				name = "enablePlayer";
				order = 10;
				msg = L["Show the player castbar"];
				desc = nil;
				set = function(self) 
					GUIS_DB["castbars"].showPlayerBar = not(GUIS_DB["castbars"].showPlayerBar)
					self:onrefresh()
					module:UpdateAll()
				end;
				onrefresh = function(self) 
					if (self:get()) then
						self.parent.child.playerCastbar:Enable()
					else
						self.parent.child.playerCastbar:Disable()
					end
				end;
				get = function() return GUIS_DB["castbars"].showPlayerBar end;
				init = function(self) 
					if not(self:get()) then
						self.parent.child.playerCastbar:Disable()
					end
				end;
			};
			{ -- enable target
				type = "widget";
				element = "CheckButton";
				name = "enableTarget";
				order = 15;
				msg = L["Show the target castbar"];
				desc = nil;
				set = function(self) 
					GUIS_DB["castbars"].showTargetBar = not(GUIS_DB["castbars"].showTargetBar)
					self:onrefresh()
					module:UpdateAll()
				end;
				onrefresh = function(self) 
					if (self:get()) then
						self.parent.child.targetCastbar:Enable()
					else
						self.parent.child.targetCastbar:Disable()
					end
				end;
				get = function() return GUIS_DB["castbars"].showTargetBar end;
				init = function(self) 
					if not(self:get()) then
						self.parent.child.targetCastbar:Disable()
					end
				end;
			};
			{ -- enable pet
				type = "widget";
				element = "CheckButton";
				name = "enablePet";
				order = 20;
				msg = L["Show the pet castbar"];
				desc = nil;
				set = function(self) 
					GUIS_DB["castbars"].showPetBar = not(GUIS_DB["castbars"].showPetBar)
					self:onrefresh()
					module:UpdateAll()
				end;
				onrefresh = function(self) 
					if (self:get()) then
						self.parent.child.petCastbar:Enable()
					else
						self.parent.child.petCastbar:Disable()
					end
				end;
				get = function() return GUIS_DB["castbars"].showPetBar end;
				init = function(self) 
					if not(self:get()) then
						self.parent.child.petCastbar:Disable()
					end
				end;
			};
			{ -- enable focus
				type = "widget";
				element = "CheckButton";
				name = "enable";
				order = 25;
				msg = L["Show the focus target castbar"];
				desc = nil;
				set = function(self) 
					GUIS_DB["castbars"].showFocusBar = not(GUIS_DB["castbars"].showFocusBar)
					self:onrefresh()
					module:UpdateAll()
				end;
				onrefresh = function(self) 
					if (self:get()) then
						self.parent.child.focusCastbar:Enable()
					else
						self.parent.child.focusCastbar:Disable()
					end
				end;
				get = function() return GUIS_DB["castbars"].showFocusBar end;
				init = function(self) 
					if not(self:get()) then
						self.parent.child.focusCastbar:Disable()
					end
				end;
			};

			{ -- player castbar
				type = "group";
				order = 100;
				name = "playerCastbar";
				virtual = true;
				children = {
					{ -- title
						type = "widget";
						element = "Title";
						order = 1;
						msg = PLAYER; -- PLAYER PET TARGET FOCUS 
					};
					{ -- tradeskill
						type = "widget";
						element = "CheckButton";
						name = "tradeskill";
						order = 11;
						msg = L["Show for tradeskills"];
						desc = nil;
						set = function(self) 
							GUIS_DB["castbars"].showTradeSkill = not(GUIS_DB["castbars"].showTradeSkill)
							module:UpdateAll()
						end;
						get = function() return GUIS_DB["castbars"].showTradeSkill end;
						init = function(self) end;
					};
					{ -- width text
						type = "widget";
						element = "Header";
						order = 15;
						name = "widthText";
						width = "half";
						msg = L["Set Width"]; 
					};
					{ -- height text
						type = "widget";
						element = "Header";
						order = 16;
						name = "heightText";
						width = "half";
						msg = L["Set Height"]; 
					};
					{ -- width
						type = "widget";
						element = "Slider";
						name = "width";
						order = 20;
						width = "half";
						msg = nil;
						desc = L["Set the width of the bar"];
						set = function(self, value) 
							if (value) then
								self.text:SetText(("%d"):format(value))
								GUIS_DB["castbars"].player.size[1] = value
								
								module:UpdateAll()
							end
						end;
						get = function(self) return GUIS_DB["castbars"].player.size[1] end;
						ondisable = function(self)
							self:SetAlpha(3/4)
							self.low:SetTextColor(unpack(C["disabled"]))
							self.high:SetTextColor(unpack(C["disabled"]))
							self.text:SetTextColor(unpack(C["disabled"]))
							
							self:EnableMouse(false)
						end;
						onenable = function(self)
							self:SetAlpha(1)
							self.low:SetTextColor(unpack(C["value"]))
							self.high:SetTextColor(unpack(C["value"]))
							self.text:SetTextColor(unpack(C["index"]))
							
							self:EnableMouse(true)
						end;
						init = function(self)
							local min, max, value = MIN_WIDTH, MAX_WIDTH, self:get()
							self:SetMinMaxValues(min, max)
							self.low:SetText(min)
							self.high:SetText(max)

							self:SetValue(value)
							self:SetValueStep(1)
							self.text:SetText(("%d"):format(value))
							
							if (self:IsEnabled()) then
								self:onenable()
							else
								self:ondisable()
							end
						end;
					};
					{ -- height
						type = "widget";
						element = "Slider";
						name = "height";
						order = 21;
						width = "half";
						msg = nil;
						desc = L["Set the height of the bar"];
						set = function(self, value) 
							if (value) then
								self.text:SetText(("%d"):format(value))
								GUIS_DB["castbars"].player.size[2] = value
								
								module:UpdateAll()
							end
						end;
						get = function(self) return GUIS_DB["castbars"].player.size[2] end;
						ondisable = function(self)
							self:SetAlpha(3/4)
							self.low:SetTextColor(unpack(C["disabled"]))
							self.high:SetTextColor(unpack(C["disabled"]))
							self.text:SetTextColor(unpack(C["disabled"]))
							
							self:EnableMouse(false)
						end;
						onenable = function(self)
							self:SetAlpha(1)
							self.low:SetTextColor(unpack(C["value"]))
							self.high:SetTextColor(unpack(C["value"]))
							self.text:SetTextColor(unpack(C["index"]))
							
							self:EnableMouse(true)
						end;
						init = function(self)
							local min, max, value = MIN_HEIGHT, MAX_HEIGHT, self:get()
							self:SetMinMaxValues(min, max)
							self.low:SetText(min)
							self.high:SetText(max)

							self:SetValue(value)
							self:SetValueStep(1)
							self.text:SetText(("%d"):format(value))
							
							if (self:IsEnabled()) then
								self:onenable()
							else
								self:ondisable()
							end
						end;
					};
				};
			};

			{ -- pet castbar
				type = "group";
				order = 120;
				name = "petCastbar";
				virtual = true;
				children = {
					{ -- title
						type = "widget";
						element = "Title";
						order = 1;
						msg = PET; 
					};
					{ -- width text
						type = "widget";
						element = "Header";
						order = 15;
						name = "widthText";
						width = "half";
						msg = L["Set Width"]; 
					};
					{ -- height text
						type = "widget";
						element = "Header";
						order = 16;
						name = "heightText";
						width = "half";
						msg = L["Set Height"]; 
					};
					{ -- width
						type = "widget";
						element = "Slider";
						name = "width";
						order = 20;
						width = "half";
						msg = nil;
						desc = L["Set the width of the bar"];
						set = function(self, value) 
							if (value) then
								self.text:SetText(("%d"):format(value))
								GUIS_DB["castbars"].pet.size[1] = value
								
								module:UpdateAll()
							end
						end;
						get = function(self) return GUIS_DB["castbars"].pet.size[1] end;
						ondisable = function(self)
							self:SetAlpha(3/4)
							self.low:SetTextColor(unpack(C["disabled"]))
							self.high:SetTextColor(unpack(C["disabled"]))
							self.text:SetTextColor(unpack(C["disabled"]))
							
							self:EnableMouse(false)
						end;
						onenable = function(self)
							self:SetAlpha(1)
							self.low:SetTextColor(unpack(C["value"]))
							self.high:SetTextColor(unpack(C["value"]))
							self.text:SetTextColor(unpack(C["index"]))
							
							self:EnableMouse(true)
						end;
						init = function(self)
							local min, max, value = MIN_WIDTH, MAX_WIDTH, self:get()
							self:SetMinMaxValues(min, max)
							self.low:SetText(min)
							self.high:SetText(max)

							self:SetValue(value)
							self:SetValueStep(1)
							self.text:SetText(("%d"):format(value))
							
							if (self:IsEnabled()) then
								self:onenable()
							else
								self:ondisable()
							end
						end;
					};
					{ -- height
						type = "widget";
						element = "Slider";
						name = "height";
						order = 21;
						width = "half";
						msg = nil;
						desc = L["Set the height of the bar"];
						set = function(self, value) 
							if (value) then
								self.text:SetText(("%d"):format(value))
								GUIS_DB["castbars"].pet.size[2] = value
								
								module:UpdateAll()
							end
						end;
						get = function(self) return GUIS_DB["castbars"].pet.size[2] end;
						ondisable = function(self)
							self:SetAlpha(3/4)
							self.low:SetTextColor(unpack(C["disabled"]))
							self.high:SetTextColor(unpack(C["disabled"]))
							self.text:SetTextColor(unpack(C["disabled"]))
							
							self:EnableMouse(false)
						end;
						onenable = function(self)
							self:SetAlpha(1)
							self.low:SetTextColor(unpack(C["value"]))
							self.high:SetTextColor(unpack(C["value"]))
							self.text:SetTextColor(unpack(C["index"]))
							
							self:EnableMouse(true)
						end;
						init = function(self)
							local min, max, value = MIN_HEIGHT, MAX_HEIGHT, self:get()
							self:SetMinMaxValues(min, max)
							self.low:SetText(min)
							self.high:SetText(max)

							self:SetValue(value)
							self:SetValueStep(1)
							self.text:SetText(("%d"):format(value))
							
							if (self:IsEnabled()) then
								self:onenable()
							else
								self:ondisable()
							end
						end;
					};
				};
			};

			{ -- target castbar
				type = "group";
				order = 110;
				name = "targetCastbar";
				virtual = true;
				children = {
					{ -- title
						type = "widget";
						element = "Title";
						order = 1;
						msg = TARGET; 
					};
					{ -- width text
						type = "widget";
						element = "Header";
						order = 15;
						name = "widthText";
						width = "half";
						msg = L["Set Width"]; 
					};
					{ -- height text
						type = "widget";
						element = "Header";
						order = 16;
						name = "heightText";
						width = "half";
						msg = L["Set Height"]; 
					};
					{ -- width
						type = "widget";
						element = "Slider";
						name = "width";
						order = 20;
						width = "half";
						msg = nil;
						desc = L["Set the width of the bar"];
						set = function(self, value) 
							if (value) then
								self.text:SetText(("%d"):format(value))
								GUIS_DB["castbars"].target.size[1] = value
								
								module:UpdateAll()
							end
						end;
						get = function(self) return GUIS_DB["castbars"].target.size[1] end;
						ondisable = function(self)
							self:SetAlpha(3/4)
							self.low:SetTextColor(unpack(C["disabled"]))
							self.high:SetTextColor(unpack(C["disabled"]))
							self.text:SetTextColor(unpack(C["disabled"]))
							
							self:EnableMouse(false)
						end;
						onenable = function(self)
							self:SetAlpha(1)
							self.low:SetTextColor(unpack(C["value"]))
							self.high:SetTextColor(unpack(C["value"]))
							self.text:SetTextColor(unpack(C["index"]))
							
							self:EnableMouse(true)
						end;
						init = function(self)
							local min, max, value = MIN_WIDTH, MAX_WIDTH, self:get()
							self:SetMinMaxValues(min, max)
							self.low:SetText(min)
							self.high:SetText(max)

							self:SetValue(value)
							self:SetValueStep(1)
							self.text:SetText(("%d"):format(value))
							
							if (self:IsEnabled()) then
								self:onenable()
							else
								self:ondisable()
							end
						end;
					};
					{ -- height
						type = "widget";
						element = "Slider";
						name = "height";
						order = 21;
						width = "half";
						msg = nil;
						desc = L["Set the height of the bar"];
						set = function(self, value) 
							if (value) then
								self.text:SetText(("%d"):format(value))
								GUIS_DB["castbars"].target.size[2] = value
								
								module:UpdateAll()
							end
						end;
						get = function(self) return GUIS_DB["castbars"].target.size[2] end;
						ondisable = function(self)
							self:SetAlpha(3/4)
							self.low:SetTextColor(unpack(C["disabled"]))
							self.high:SetTextColor(unpack(C["disabled"]))
							self.text:SetTextColor(unpack(C["disabled"]))
							
							self:EnableMouse(false)
						end;
						onenable = function(self)
							self:SetAlpha(1)
							self.low:SetTextColor(unpack(C["value"]))
							self.high:SetTextColor(unpack(C["value"]))
							self.text:SetTextColor(unpack(C["index"]))
							
							self:EnableMouse(true)
						end;
						init = function(self)
							local min, max, value = MIN_HEIGHT, MAX_HEIGHT, self:get()
							self:SetMinMaxValues(min, max)
							self.low:SetText(min)
							self.high:SetText(max)

							self:SetValue(value)
							self:SetValueStep(1)
							self.text:SetText(("%d"):format(value))
							
							if (self:IsEnabled()) then
								self:onenable()
							else
								self:ondisable()
							end
						end;
					};
				};
			};

			{ -- focus target castbar
				type = "group";
				order = 130;
				name = "focusCastbar";
				virtual = true;
				children = {
					{ -- title
						type = "widget";
						element = "Title";
						order = 1;
						msg = FOCUS; 
					};
					{ -- width text
						type = "widget";
						element = "Header";
						order = 15;
						name = "widthText";
						width = "half";
						msg = L["Set Width"]; 
					};
					{ -- height text
						type = "widget";
						element = "Header";
						order = 16;
						name = "heightText";
						width = "half";
						msg = L["Set Height"]; 
					};
					{ -- width
						type = "widget";
						element = "Slider";
						name = "width";
						order = 20;
						width = "half";
						msg = nil;
						desc = L["Set the width of the bar"];
						set = function(self, value) 
							if (value) then
								self.text:SetText(("%d"):format(value))
								GUIS_DB["castbars"].focus.size[1] = value
								
								module:UpdateAll()
							end
						end;
						get = function(self) return GUIS_DB["castbars"].focus.size[1] end;
						ondisable = function(self)
							self:SetAlpha(3/4)
							self.low:SetTextColor(unpack(C["disabled"]))
							self.high:SetTextColor(unpack(C["disabled"]))
							self.text:SetTextColor(unpack(C["disabled"]))
							
							self:EnableMouse(false)
						end;
						onenable = function(self)
							self:SetAlpha(1)
							self.low:SetTextColor(unpack(C["value"]))
							self.high:SetTextColor(unpack(C["value"]))
							self.text:SetTextColor(unpack(C["index"]))
							
							self:EnableMouse(true)
						end;
						init = function(self)
							local min, max, value = MIN_WIDTH, MAX_WIDTH, self:get()
							self:SetMinMaxValues(min, max)
							self.low:SetText(min)
							self.high:SetText(max)

							self:SetValue(value)
							self:SetValueStep(1)
							self.text:SetText(("%d"):format(value))
							
							if (self:IsEnabled()) then
								self:onenable()
							else
								self:ondisable()
							end
						end;
					};
					{ -- height
						type = "widget";
						element = "Slider";
						name = "height";
						order = 21;
						width = "half";
						msg = nil;
						desc = L["Set the height of the bar"];
						set = function(self, value) 
							if (value) then
								self.text:SetText(("%d"):format(value))
								GUIS_DB["castbars"].focus.size[2] = value
								
								module:UpdateAll()
							end
						end;
						get = function(self) return GUIS_DB["castbars"].focus.size[2] end;
						ondisable = function(self)
							self:SetAlpha(3/4)
							self.low:SetTextColor(unpack(C["disabled"]))
							self.high:SetTextColor(unpack(C["disabled"]))
							self.text:SetTextColor(unpack(C["disabled"]))
							
							self:EnableMouse(false)
						end;
						onenable = function(self)
							self:SetAlpha(1)
							self.low:SetTextColor(unpack(C["value"]))
							self.high:SetTextColor(unpack(C["value"]))
							self.text:SetTextColor(unpack(C["index"]))
							
							self:EnableMouse(true)
						end;
						init = function(self)
							local min, max, value = MIN_HEIGHT, MAX_HEIGHT, self:get()
							self:SetMinMaxValues(min, max)
							self.low:SetText(min)
							self.high:SetText(max)

							self:SetValue(value)
							self:SetValueStep(1)
							self.text:SetText(("%d"):format(value))
							
							if (self:IsEnabled()) then
								self:onenable()
							else
								self:ondisable()
							end
						end;
					};
				};
			};
			
		};
	};
}

local faq = {
	{
		q = L["How can I toggle the castbars for myself and my pet?"];
		a = {
			{
				type = "text";
				msg = L["The UI features movable on-screen castbars for you, your target, your pet, and your focus target. These bars can be positioned manually by typing |cFF4488FF/glock|r followed by the Enter key. |n|nYou can change their settings, size and visibility in the options menu."];
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
		tags = { "castbars" }; 
	};
}

--------------------------------------------------------------------------------------------------
--		Restyle Blizzard Stuff (MirrorTimers and TimerTrackers)
--------------------------------------------------------------------------------------------------
skinBar = function(bar)
	local statusBar = _G[bar:GetName().."StatusBar"]
	if not(statusBar) then return end
	
	statusBar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	statusBar:SetSize(160, 12) -- 195, 13
	
	-- make it pretty
	statusBar.eyeCandy = CreateFrame("Frame", nil, statusBar)
	statusBar.eyeCandy:SetPoint("TOPLEFT", statusBar:GetStatusBarTexture(), "TOPLEFT", 0, 0)
	statusBar.eyeCandy:SetSize(statusBar:GetSize())
	statusBar.eyeCandy:SetUITemplate("border")
	F.GlossAndShade(statusBar.eyeCandy)
	
	-- hide everything except the big numbers
	for i = 1, bar:GetNumRegions() do
		local region = select(i, bar:GetRegions())
		if (region:GetObjectType() == "Texture") and not(region == statusBar:GetStatusBarTexture()) then
			if not(region == bar.digit1) 
			and not(region == bar.digit2) 
			and not(region == bar.glow1) 
			and not(region == bar.glow2) 
			and not(region == bar.faction) 
			and not(region == bar.factionGlow) then
	
				region:SetTexture("")
			end
		end
	end
	
	for i = 1, statusBar:GetNumRegions() do
		local region = select(i, statusBar:GetRegions())
		if (region:GetObjectType() == "Texture") and not(region == statusBar:GetStatusBarTexture()) then
			region:SetTexture("")
		end
	end

	local border = _G[bar:GetName().."StatusBarBorder"]
	if border then
		border:SetTexture("")
	end

	local text = _G[bar:GetName().."Text"]
	if text then
		text:SetFontObject(GUIS_SystemFontNormalWhite)
		text:ClearAllPoints()
		text:SetPoint("RIGHT", statusBar, "LEFT", -4, 0)
		text:SetJustifyH("RIGHT")
		text:SetJustifyV("MIDDLE")
	end

	local timeText = _G[bar:GetName().."StatusBarTimeText"]
	if timeText then
		timeText:SetFontObject(GUIS_NumberFontNormalYellow)
		timeText:ClearAllPoints()
		timeText:SetPoint("LEFT", statusBar, "RIGHT", 4, 0)
		timeText:SetJustifyH("LEFT")
		timeText:SetJustifyV("MIDDLE")
	end
	
	_G[bar:GetName().."Backdrop"] = CreateFrame("Frame", bar:GetName().."Backdrop", statusBar)
	_G[bar:GetName().."Backdrop"]:SetBackdrop(M["Backdrop"]["Border"])
	_G[bar:GetName().."Backdrop"]:SetPoint("TOP", statusBar, "TOP", 0, 1)
	_G[bar:GetName().."Backdrop"]:SetPoint("BOTTOM", statusBar, "BOTTOM", 0, -1)
	_G[bar:GetName().."Backdrop"]:SetPoint("LEFT", statusBar, "LEFT", -1, 0)
	_G[bar:GetName().."Backdrop"]:SetPoint("RIGHT", statusBar, "RIGHT", 1, 0)
	_G[bar:GetName().."Backdrop"]:SetBackdropColor(0, 0, 0, 0)
	_G[bar:GetName().."Backdrop"]:SetBackdropBorderColor(C["background"][1], C["background"][2], C["background"][3], 1)

	
	_G[bar:GetName().."Background"] = statusBar:CreateTexture(bar:GetName().."Background")
	_G[bar:GetName().."Background"]:SetDrawLayer("BACKGROUND", -7)
	_G[bar:GetName().."Background"]:SetAllPoints(statusBar)
	_G[bar:GetName().."Background"]:SetTexture(M["StatusBar"]["StatusBar"])
	_G[bar:GetName().."Background"]:SetVertexColor(C["background"][1], C["background"][2], C["background"][3], 0.75)
	
	_G[bar:GetName().."Glow"] = CreateFrame("Frame", bar:GetName().."Glow", statusBar)
	_G[bar:GetName().."Glow"]:SetBackdrop(M["Backdrop"]["Glow"])
	_G[bar:GetName().."Glow"]:SetBackdropBorderColor(unpack(C["shadow"]))
	_G[bar:GetName().."Glow"]:SetPoint("TOP", _G[bar:GetName().."Backdrop"], "TOP", 0, 3)
	_G[bar:GetName().."Glow"]:SetPoint("BOTTOM", _G[bar:GetName().."Backdrop"], "BOTTOM", 0, -3)
	_G[bar:GetName().."Glow"]:SetPoint("LEFT", _G[bar:GetName().."Backdrop"], "LEFT", -3, 0)
	_G[bar:GetName().."Glow"]:SetPoint("RIGHT", _G[bar:GetName().."Backdrop"], "RIGHT", 3, 0)	
	
end

styleTimer = function(bar)
	if (bar.styled) then return end
	bar.styled = true
	
	skinBar(bar)
	bar.bar:SetStatusBarColor(0.75, 0, 0)

	bar:SetFrameStrata("LOW")
	bar.SetFrameStrata = noop
end

stylebar = function(bar)
	if (bar.styled) then return end
	bar.styled = true
	
	bar:SetSize(200, 26)

	_G[bar:GetName().."StatusBar"]:ClearAllPoints()
	_G[bar:GetName().."StatusBar"]:SetPoint("BOTTOM", bar, "BOTTOM", 0, 6)
	_G[bar:GetName().."StatusBarTimeText"] = _G[bar:GetName().."StatusBar"]:CreateFontString()
	local function updateTime()
		_G[bar:GetName().."StatusBarTimeText"]:SetText(("[smarttime:%.1f]"):format(_G[bar:GetName().."StatusBar"]:GetValue()):tag())
	end
	ScheduleTimer(updateTime, 0.1, nil, nil)
	
	skinBar(bar)
end

styleAllBars = function()
	if (MirrorTimer1) then
		MirrorTimer1:ClearAllPoints()
		MirrorTimer1:SetPoint("TOP", UIParent, "TOP", 0, -140)
	end 

	if (MIRRORTIMER_NUMTIMERS) then
		for i = 1, MIRRORTIMER_NUMTIMERS do
			stylebar(_G[("MirrorTimer%d"):format(i)])
		end
	end
end

styleAllTimers = function()
	if (TimerTracker) and (TimerTracker.timerList) then
		for _, bar in pairs(TimerTracker.timerList) do
			styleTimer(bar)
		end
	end
end

--------------------------------------------------------------------------------------------------
--		Custom Cast Bars
--------------------------------------------------------------------------------------------------
local CastBar = CreateFrame("Frame", nil, UIParent)
local CastBarMeta = { __index = CastBar }

local RegisterEvent = CastBar.RegisterEvent
CastBar.RegisterEvent = function(self, event, callback)
	RegisterEvent(self, event)
	self.events[event] = callback
end

local UnregisterEvent = CastBar.UnregisterEvent
CastBar.UnregisterEvent = function(self, event)
	UnregisterEvent(self, event)
	self.events[event] = nil
end

CastBar.SetUnit = function(self, unit)
	self.unit = unit
end

local SetSize = CastBar.SetSize
CastBar.SetSize = function(self, w, h)
	SetSize(self, w + 6, h + 6)
	if (self.cast) then self.cast:SetSize(w, h) end
	if (self.icon) then self.icon:SetSize(h + 6, h + 6) end
end

local GetSize = CastBar.GetSize
CastBar.GetSize = function(self)
	local w, h = GetSize(self)
	return (w) and (w - 6), (h) and (h - 6)
end

local SetWidth = CastBar.SetWidth
CastBar.SetWidth = function(self, w)
	SetWidth(self, w + 6)
	if (self.cast) then self.cast:SetWidth(w) end
end

local GetWidth = CastBar.GetWidth
CastBar.GetWidth = function(self)
	local w = GetWidth(self)
	return (w) and (w - 6)
end

local SetHeight = CastBar.SetHeight
CastBar.SetHeight = function(self, h)
	SetHeight(self, h + 6)
	if (self.cast) then self.cast:SetHeight(h) end
	if (self.icon) then self.icon:SetWidth(w + 6, h + 6) end
end

local GetHeight = CastBar.GetHeight
CastBar.GetHeight = function(self)
	local h = GetHeight(self)
	return (h) and (h - 6)
end

CastBar.UNIT_SPELLCAST_START = function(self, event, unit, spell)
	if (self.unit ~= unit) then 
		return 
	end
	
	local cast = self.cast
	if not(cast) then
		return
	end
	
	local name, _, text, texture, startTime, endTime, isTradeSkill, castid, interrupt = UnitCastingInfo(unit)
	if not(name) or (not(GUIS_DB["castbars"].showTradeSkill) and (isTradeSkill)) then
		self:Hide()
		return
	end
	
	endTime = endTime / 1e3
	startTime = startTime / 1e3
	local max = endTime - startTime

	cast.castid = castid
	cast.duration = GetTime() - startTime
	cast.max = max
	cast.delay = 0
	cast.casting = true
	cast.interrupt = interrupt

	cast:SetMinMaxValues(0, max)
	cast:SetValue(0)
	
	if (cast.name) then cast.name:SetText(text) end
	if (cast.icon) then cast.icon:SetTexture(texture) end
	if (cast.time) then cast.time:SetText() end
	if (cast.ms) then cast.ms:SetText() end

	if (cast.latency) then
		cast.latency:ClearAllPoints()
		cast.latency:SetPoint("RIGHT")
		cast.latency:SetPoint("TOP")
		cast.latency:SetPoint("BOTTOM")
		cast.latency:Show()
	end

	self:Show()
end

CastBar.UNIT_SPELLCAST_FAILED = function(self, event, unit, spellname, _, castid)
	if (self.unit ~= unit) then 
		return 
	end

	local cast = self.cast
	if not(cast) then
		return
	end
	
	if(cast.castid ~= castid) then
		return
	end

	cast.casting = nil
	cast.interrupt = nil
	cast:SetValue(0)
	
	self:Hide()
end

CastBar.UNIT_SPELLCAST_INTERRUPTED = function(self, event, unit, spellname, _, castid)
	if (self.unit ~= unit) then 
		return 
	end

	local cast = self.cast
	if not(cast) then
		return
	end
	
	if(cast.castid ~= castid) then
		return
	end

	cast.casting = nil
	cast.channeling = nil
	cast:SetValue(0)
	
	self:Hide()
end

CastBar.UNIT_SPELLCAST_INTERRUPTIBLE = function(self, event, unit)
	if (self.unit ~= unit) then 
		return 
	end
end

CastBar.UNIT_SPELLCAST_NOT_INTERRUPTIBLE = function(self, event, unit)
	if (self.unit ~= unit) then 
		return 
	end
end

CastBar.UNIT_SPELLCAST_DELAYED = function(self, event, unit, spellname, _, castid)
	if (self.unit ~= unit) then 
		return 
	end

	local name, _, text, texture, startTime, endTime = UnitCastingInfo(unit)
	if not(startTime) then return end

	local cast = self.cast
	if not(cast) then
		return
	end
	
	local duration = GetTime() - (startTime / 1000)
	if(duration < 0) then duration = 0 end

	cast.delay = cast.delay + cast.duration - duration
	cast.duration = duration

	cast:SetValue(duration)
end

CastBar.UNIT_SPELLCAST_STOP = function(self, event, unit, spellname, _, castid)
	if (self.unit ~= unit) then 
		return 
	end

	local cast = self.cast
	if not(cast) then
		return
	end
	
	if(cast.castid ~= castid) then
		return
	end

	cast.casting = nil
	cast.interrupt = nil
	cast:SetValue(0)
	
	self:Hide()
end

CastBar.UNIT_SPELLCAST_CHANNEL_START = function(self, event, unit, spellname)
	if (self.unit ~= unit) then 
		return 
	end

	local cast = self.cast
	if not(cast) then
		return
	end
	
	local name, _, text, texture, startTime, endTime, isTradeSkill, interrupt = UnitChannelInfo(unit)
	if not(name) or (not(GUIS_DB["castbars"].showTradeSkill) and (isTradeSkill)) then
		return
	end

	endTime = endTime / 1e3
	startTime = startTime / 1e3
	local max = (endTime - startTime)
	local duration = endTime - GetTime()

	cast.duration = duration
	cast.max = max
	cast.delay = 0
	cast.channeling = true
	cast.interrupt = interrupt

	cast.casting = nil
	cast.castid = nil

	cast:SetMinMaxValues(0, max)
	cast:SetValue(duration)

	if (cast.name) then cast.name:SetText(text) end
	if (cast.icon) then cast.icon:SetTexture(texture) end
	if (cast.time) then cast.time:SetText() end
	if (cast.ms) then cast.ms:SetText() end

	if (cast.latency) then
		cast.latency:ClearAllPoints()
		cast.latency:SetPoint("LEFT")
		cast.latency:SetPoint("TOP")
		cast.latency:SetPoint("BOTTOM")
		cast.latency:Show()
	end

	self:Show()

end

CastBar.UNIT_SPELLCAST_CHANNEL_UPDATE = function(self, event, unit, spellname)
	if (self.unit ~= unit) then 
		return 
	end
	
	local name, _, text, texture, startTime, endTime, oldStart = UnitChannelInfo(unit)
	if not(name) then
		return
	end

	local cast = self.cast
	if not(cast) then
		return
	end
	
	local duration = (endTime / 1000) - GetTime()

	cast.delay = cast.delay + cast.duration - duration
	cast.duration = duration
	cast.max = (endTime - startTime) / 1000

	cast:SetMinMaxValues(0, cast.max)
	cast:SetValue(duration)

end

CastBar.UNIT_SPELLCAST_CHANNEL_STOP = function(self, event, unit, spellname)
	if (self.unit ~= unit) then 
		return 
	end

	local cast = self.cast
	if not(cast) then
		return
	end
	
	if (self:IsShown()) then
		cast.channeling = nil
		cast.interrupt = nil

		cast:SetValue(cast.max)
		self:Hide()
	end
end

CastBar.UNIT_TARGET = function(self, event, unit)
	if (self.unit ~= unit) then 
		return 
	end

	if (UnitCastingInfo(unit)) then
		self:UNIT_SPELLCAST_START("UNIT_SPELLCAST_START", unit)
		return
	end
	
	if (UnitChannelInfo(unit)) then
		self:UNIT_SPELLCAST_CHANNEL_START("UNIT_SPELLCAST_CHANNEL_START", unit)
		return
	end
	
end

OnUpdate = function(self, elapsed)
	local cast = self.cast
	if not(cast) then
		return
	end
	
	local unit = self.unit

	if not(UnitExists(unit)) then 
		cast.casting = nil
		cast.castid = nil
		cast.channeling = nil

		cast:SetValue(1)
		self:Hide()
		return 
	end

	-- fix the color of the cast bar to something smart
	do
		local r, g, b, t
		-- give your pet the same color as you
		if (unit == "player") or (unit == "pet") then
			t = C.RAID_CLASS_COLORS[playerClass]
		
		elseif (UnitIsPlayer(unit)) or (UnitPlayerControlled(unit) and not(UnitIsPlayer(unit))) then
			local _, class = UnitClass(unit)
			t = C.RAID_CLASS_COLORS[class]
			
		elseif (UnitReaction(unit, "player")) then
			t = C.FACTION_BAR_COLORS[UnitReaction(unit, "player")]
			
		elseif (cast.colorHealth) then
			r, g, b = unpack(C["health"])
			
		end

		if (t) then
			r, g, b = t.r, t.g, t.b
		end
		
		cast:SetStatusBarColor(r, g, b)
	end

	if (cast.casting) then
		local duration = cast.duration + elapsed
		if (duration >= cast.max) then
			cast.casting = nil
			self:Hide()
		end

		if (cast.latency) then
			local width = cast:GetWidth()
			local _, _, _, ms = GetNetStats()
			if(ms ~= 0) then
				local safeZonePercent = (width / cast.max) * (ms / 1e5)
				if (safeZonePercent > 1) then safeZonePercent = 1 end
				cast.latency:SetWidth(width * safeZonePercent)
				
				if (cast.ms) then
					cast.ms:SetFormattedText("%s", ms .. MILLISECONDS_ABBR)
				end
			else
				cast.latency:Hide()

				if (cast.ms) then
					cast.ms:SetText()
				end
			end
		end

		if (cast.time) then
			if (cast.delay ~= 0) then
				cast.time:SetFormattedText("%.1f|cffff0000-%.1f|r", cast.max - duration, cast.delay)
			else
				cast.time:SetFormattedText("%.1f", cast.max - duration)
			end
		end

		cast.duration = duration
		cast:SetValue(duration)

	elseif (cast.channeling) then
		local duration = cast.duration - elapsed

		if (duration <= 0) then
			cast.channeling = nil
			self:Hide()
		end

		if (cast.latency) then
			local width = cast:GetWidth()
			local _, _, _, ms = GetNetStats()
			if(ms ~= 0) then
				local safeZonePercent = (width / cast.max) * (ms / 1e5)
				if(safeZonePercent > 1) then safeZonePercent = 1 end
				cast.latency:SetWidth(width * safeZonePercent)

				if (cast.ms) then
					cast.ms:SetFormattedText("%s", ms .. MILLISECONDS_ABBR)
				end
			else
				cast.latency:Hide()

				if (cast.ms) then
					cast.ms:SetText()
				end
			end
		end

		if (cast.time) then
			if (cast.delay ~= 0) then
				cast.time:SetFormattedText("%.1f|cffff0000-%.1f|r", duration, cast.delay)
			else
				cast.time:SetFormattedText("%.1f", duration)
			end
		end

		cast.duration = duration
		cast:SetValue(duration)
		
	else
		cast.casting = nil
		cast.castid = nil
		cast.channeling = nil

		cast:SetValue(1)
		self:Hide()
	end
end

OnEvent = function(self, event, ...) 
	if (self[event]) then
		self[event](self, event, ...)
		
	elseif (self.events[event]) then
		self.events[event](self, event, ...)
	end
end

CastBar.Enable = function(self)
	if (self.enabled) or not(self.unit) then
		return
	end
	
	self.enabled = true

	self:RegisterEvent("UNIT_SPELLCAST_START")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED")
	self:RegisterEvent("UNIT_SPELLCAST_STOP")
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:RegisterEvent("UNIT_SPELLCAST_DELAYED")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
	self:RegisterEvent("UNIT_TARGET")

	if (self.unit ~= "player") then
		self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
		self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
	end
	
	self:SetScript("OnUpdate", OnUpdate)
	self:SetScript("OnEvent", OnEvent)
	
	castBars[self] = true
end

CastBar.Disable = function(self)
	if not(self.enabled) then
		return
	end

	self.enabled = nil

	self:UnregisterEvent("UNIT_SPELLCAST_START")
	self:UnregisterEvent("UNIT_SPELLCAST_FAILED")
	self:UnregisterEvent("UNIT_SPELLCAST_STOP")
	self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
	self:UnregisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
	self:UnregisterEvent("UNIT_SPELLCAST_DELAYED")
	self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
	self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
	self:UnregisterEvent("UNIT_TARGET")
	
	self:SetScript("OnUpdate", nil)

	self:Hide()

	castBars[self] = nil
end

CastBar.AddElement = function(self, ...)
	for i = 1, select("#", ...) do
		local element = select(i, ...)
		
		if (element == "cast") then
			-- castbar
			local cast = CreateFrame("StatusBar", nil, self)
			cast:SetPoint("TOPLEFT", 3, -3)
			cast:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
			cast:SetSize(self:GetSize())
			F.GlossAndShade(cast)
			self.cast = cast
		end
		
		if (element == "icon") then
			-- casticon
			local icon = CreateFrame("Frame", nil, self)
			icon:SetUITemplate("simplebackdrop")
			icon:SetSize(self:GetHeight() + 6, self:GetHeight() + 6)
			icon:SetPoint("RIGHT", self.cast, "LEFT", -4, 0)
			
			local texture = icon:CreateTexture()
			texture:SetDrawLayer("OVERLAY", 0)
			texture:SetPoint("TOPLEFT", 3, -3)
			texture:SetPoint("BOTTOMRIGHT", -3, 3)
			texture:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			F.GlossAndShade(icon, texture)

			icon.texture = texture

			icon.SetTexture = function(self, ...) texture:SetTexture(...) end
			icon.SetVertexColor = function(self, ...) texture:SetVertexColor(...) end

			self.cast.icon = icon
		end
		
		if (element == "time") then
			-- spell timer
			local time = self.cast:CreateFontString()
			time:SetFontObject(GUIS_NumberFontNormal)
			time:SetDrawLayer("OVERLAY", 5)
			time:SetPoint("RIGHT", self.cast, "RIGHT", -8, 0)
			self.cast.time = time
		end

		if (element == "name") then
			-- spell name
			local name = self.cast:CreateFontString()
			name:SetFontObject(GUIS_SystemFontNormalWhite)
			name:SetDrawLayer("OVERLAY", 4)
			name:SetPoint("LEFT", self.cast, "LEFT", 8, 0)
			name:SetPoint("RIGHT", self.cast, "RIGHT", -30, 0)
			self.cast.name = name
		end

		if (element == "latency") then
			-- latency bar/safezone
			local latency = self.cast:CreateTexture()
			latency:Hide()
			latency:SetDrawLayer("OVERLAY", 1)
			latency:SetTexture(1, 0, 0)
			latency:SetAlpha(1/4)
			self.cast.latency = latency
		end

		if (element == "delay") then
			-- latency text
			local ms = self.cast:CreateFontString()
			ms:SetFontObject(GUIS_SystemFontTiny)
			ms:SetDrawLayer("OVERLAY", 2)
			ms:SetTextColor(0.5, 0.5, 0.5, 1)
			ms:SetPoint("CENTER", self.cast.latency or self.cast, "BOTTOM", 0, 0)
			self.cast.ms = ms
		end
		
	end
end

-- create a new castbar
New = function(self, w, h, globalName, ...)
	local frame = setmetatable(CreateFrame("Frame", globalName, UIParent), CastBarMeta)
--	local frame = CreateFrame("Frame", globalName, UIParent)
	frame:Hide()
	frame:SetFrameStrata("MEDIUM")
	frame:SetFrameLevel(15) -- above the actionbars, below wow's ui panels and stuff
	frame:SetSize(w, h)
	frame:SetUITemplate("simplestatusbarbackdrop")
	frame:AddElement("cast")

	frame.events = {}
	
	if (...) then
		frame:AddElement(...)
	end

	return frame
end

-- making this available globally for other modules to use
module.New = New

module.UpdateAll = function(self)
	if (player) then
		if (GUIS_DB["castbars"].showPlayerBar) then
			player:Enable()
		else
			player:Disable()
		end
		
		local w, h = player:GetSize()
		if (GUIS_DB["castbars"].player.size[1] ~= w) or (GUIS_DB["castbars"].player.size[2] ~= h) then
			player:SetSize(unpack(GUIS_DB["castbars"].player.size))
		end
	end

	if (target) then
		if (GUIS_DB["castbars"].showTargetBar) then
			target:Enable()
		else
			target:Disable()
		end
		
		local w, h = target:GetSize()
		if (GUIS_DB["castbars"].target.size[1] ~= w) or (GUIS_DB["castbars"].target.size[2] ~= h) then
			target:SetSize(unpack(GUIS_DB["castbars"].target.size))
		end
	end

	if (focus) then
		if (GUIS_DB["castbars"].showFocusBar) then
			focus:Enable()
		else
			focus:Disable()
		end
		
		local w, h = focus:GetSize()
		if (GUIS_DB["castbars"].focus.size[1] ~= w) or (GUIS_DB["castbars"].focus.size[2] ~= h) then
			focus:SetSize(unpack(GUIS_DB["castbars"].focus.size))
		end
	end

	if (pet) then
		if (GUIS_DB["castbars"].showPetBar) then
			pet:Enable()
		else
			pet:Disable()
		end
		
		local w, h = pet:GetSize()
		if (GUIS_DB["castbars"].pet.size[1] ~= w) or (GUIS_DB["castbars"].pet.size[2] ~= h) then
			pet:SetSize(unpack(GUIS_DB["castbars"].pet.size))
		end
	end

	self:PostUpdateGUI()
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName(self:GetName()))
end

module.RestoreDefaults = function(self)
	GUIS_DB["castbars"] = DuplicateTable(defaults)
	
	if (player) then
		player:PlaceAndSave(unpack(defaults.player.pos))
	end

	if (target) then
		target:PlaceAndSave(unpack(defaults.target.pos))
	end

	if (focus) then
		focus:PlaceAndSave(unpack(defaults.focus.pos))
	end

	if (pet) then
		pet:PlaceAndSave(unpack(defaults.pet.pos))
	end
end

module.Init = function(self)
	GUIS_DB["castbars"] = GUIS_DB["castbars"] or {}
	GUIS_DB["castbars"] = ValidateTable(GUIS_DB["castbars"], defaults)
end

module.OnInit = function(self)
	if F.kill(self:GetName()) then
		self:Kill()
		return
	end

	-- replace WoWs default numbers with ours, as a wild experiment worthy of this UI
	if (TIMER_NUMBERS_SETS) then
		TIMER_NUMBERS_SETS["BigGold"] = CopyTable(bigNumbers)
	end

	-- WoW stuff
	styleAllBars()
	styleAllTimers()
	
	-- player cast bar
	player = self:New(
		GUIS_DB["castbars"].player.size[1], GUIS_DB["castbars"].player.size[2], 
		"GUIS_PlayerCastBar", 
		"icon", "time", "name", "latency", "delay"
		)
	player:SetUnit("player")
	player.cast.name:SetFontObject(GUIS_SystemFontSmallWhite)
	player:PlaceAndSave(unpack(defaults.player.pos))

	-- target cast bar
	target = self:New(
		GUIS_DB["castbars"].target.size[1], 
		GUIS_DB["castbars"].target.size[2], 
		"GUIS_TargetCastBar",
		"icon", "time", "name"
		)
	target:SetUnit("target")
	target.cast.name:SetFontObject(GUIS_SystemFontSmallWhite)
	target.cast.icon:ClearAllPoints()
	target.cast.icon:SetPoint("LEFT", target.cast, "RIGHT", 8, 0)
	target:PlaceAndSave(unpack(defaults.target.pos))

	-- focus cast bar
	focus = self:New(
		GUIS_DB["castbars"].focus.size[1], 
		GUIS_DB["castbars"].focus.size[2], 
		"GUIS_FocusCastBar",
		"icon", "time", "name"
	)
	focus:SetUnit("focus")
	focus.cast.name:SetFontObject(GUIS_SystemFontSmallWhite)
	focus.cast.time:SetFontObject(GUIS_NumberFontSmall)
	focus.cast.icon:ClearAllPoints()
	focus.cast.icon:SetPoint("LEFT", focus.cast, "RIGHT", 8, 0)
	focus:PlaceAndSave(unpack(defaults.focus.pos))

	-- pet cast bar
	pet = self:New(
		GUIS_DB["castbars"].pet.size[1], 
		GUIS_DB["castbars"].pet.size[2], 
		"GUIS_PetCastBar",
		"icon", "time", "name", "latency"
	)
	pet:SetUnit("pet")
	pet.cast.name:SetFontObject(GUIS_SystemFontSmallWhite)
	pet.cast.time:SetFontObject(GUIS_NumberFontSmall)
	pet:PlaceAndSave(unpack(defaults.pet.pos))
	
	self:UpdateAll()
	
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
	
	CreateChatCommand(function() 
		GUIS_DB["castbars"].showPlayerBar = true
		self:UpdateAll()
	end, "enableplayercastbar")
	
	CreateChatCommand(function() 
		GUIS_DB["castbars"].showPlayerBar = false
		self:UpdateAll()
	end, "disableplayercastbar")

	CreateChatCommand(function() 
		GUIS_DB["castbars"].showTargetBar = true
		self:UpdateAll()
	end, "enabletargetcastbar")
	
	CreateChatCommand(function() 
		GUIS_DB["castbars"].showTargetBar = false
		self:UpdateAll()
	end, "disabletargetcastbar")

	CreateChatCommand(function() 
		GUIS_DB["castbars"].showFocusBar = true
		self:UpdateAll()
	end, "enablefocuscastbar")
	
	CreateChatCommand(function() 
		GUIS_DB["castbars"].showFocusBar = false
		self:UpdateAll()
	end, "disablefocuscastbar")

	CreateChatCommand(function() 
		GUIS_DB["castbars"].showPetBar = true
		self:UpdateAll()
	end, "enablepetcastbar")
	
	CreateChatCommand(function() 
		GUIS_DB["castbars"].showPetBar = false
		self:UpdateAll()
	end, "disablepetcastbar")

	--	hooksecurefunc("TimerTracker_OnEvent", styleAllTimers)
	RegisterCallback("START_TIMER", styleAllTimers)
end


