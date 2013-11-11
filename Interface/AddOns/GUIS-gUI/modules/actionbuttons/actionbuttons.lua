--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: ActionButtons")

-- Lua API 
local select = select
local gsub = string.gsub

-- WoW API
local StaticPopup_Show = StaticPopup_Show

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local gAB = LibStub("gActionButtons-2.0")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local GetBoolean, GetBinary = GetBoolean, GetBinary

local SetGloss, SetShade
local UpdateFlyout, SetupFlyout

local defaults = {
	shownames = 0;
	showhotkeys = 0; 
	showgloss = 1;
	showshade = 1;
	glossalpha = 1/3;
	shadealpha = 1/2;
}

local menuTable = {
	{
		type = "group";
		name = module:GetName();
		order = 1;
		virtual = true;
		children = {
			{
				type = "widget";
				element = "Title";
				order = 1;
				msg = F.getName(module:GetName());
			};
			{
				type = "widget";
				element = "Text";
				order = 2;
				msg = L["ActionButtons are buttons allowing you to use items, cast spells or run a macro with a single keypress or mouseclick. Here you can decide upon the styling and visible elements of your ActionButtons."];
			};
			{
				type = "group";
				order = 5;
				virtual = true;
				children = {
					{
						type = "widget";
						element = "Header";
						order = 10;
						width = "half";
						msg = L["Button Styling"];
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "showGloss";
						order = 100;
						width = "half"; 
						msg = L["Show gloss layer on ActionButtons"];
						desc = { L["Show Gloss"], L["This will display the gloss overlay on the ActionButtons"] };
						set = function(self) 
							GUIS_DB.actionbuttons.showgloss = GetBinary(not(GetBoolean(GUIS_DB.actionbuttons.showgloss)))
							module:UpdateAll()
						end;
						get = function() return GetBoolean(GUIS_DB.actionbuttons.showgloss) end;
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "showShade";
						order = 105;
						width = "half"; 
						msg = L["Show shade layer on ActionButtons"];
						desc = { L["Show Shade"], L["This will display the shade overlay on the ActionButtons"] };
						set = function(self) 
							GUIS_DB.actionbuttons.showshade = GetBinary(not(GetBoolean(GUIS_DB.actionbuttons.showshade)))
							module:UpdateAll()
						end;
						get = function() return GetBoolean(GUIS_DB.actionbuttons.showshade) end;
					};
					{
						type = "widget";
						element = "Header";
						order = 11;
						width = "half";
						msg = L["Button Text"];
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "showHotkeys";
						order = 101;
						width = "half"; 
						msg = L["Show hotkeys on the ActionButtons"];
						desc = { L["Show Keybinds"], L["This will display your currently assigned hotkeys on the ActionButtons"] };
						set = function(self) 
							GUIS_DB.actionbuttons.showhotkeys = GetBinary(not(GetBoolean(GUIS_DB.actionbuttons.showhotkeys)))
							gAB:SetHotkeyState(GUIS_DB["actionbuttons"].showhotkeys)
						end;
						get = function() return GetBoolean(GUIS_DB.actionbuttons.showhotkeys) end;
					};
					{
						type = "widget";
						element = "CheckButton";
						name = "showMacroNames";
						order = 106;
						width = "half"; 
						msg = L["Show macro names on the ActionButtons"];
						desc = { L["Show Names"], L["This will display the names of your macros on the ActionButtons"] };
						set = function(self) 
							GUIS_DB.actionbuttons.shownames = GetBinary(not(GetBoolean(GUIS_DB.actionbuttons.shownames)))
							gAB:SetNameState(GUIS_DB["actionbuttons"].shownames)
						end;
						get = function() return GetBoolean(GUIS_DB.actionbuttons.shownames) end;
					};
				};
			};
		};
	};
}

local faq = {
	{
		q = L["How can I toggle keybinds and macro names on the buttons?"];
		a = {
			{
				type = "text";
				msg = L["You can enable keybind display on the actionbuttons by typing |cFF4488FF/showhotkeys|r followed by the Enter key, and disable it with |cFF4488FF/hidehotkeys|r. Macro names can be toggled with the |cFF4488FF/shownames|r and |cFF4488FF/hidenames|r commands. All settings can also be changed in the options menu."];
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
		tags = { "actionbars", "actionbuttons", "keybinds" };
	};
}

local buttons = 0
SetupFlyout = function()
	for i = 1, buttons do
		if (_G["SpellFlyoutButton"..i]) then
			F.StyleActionButton(_G["SpellFlyoutButton" .. i])
			
			if (_G["SpellFlyoutButton" .. i]:GetChecked()) then
				_G["SpellFlyoutButton" .. i]:SetChecked(nil)
			end
		end
	end
end
 
UpdateFlyout = function(self)
	if not(self.FlyoutArrow) then 
		return 
	end
	
	self.FlyoutBorder:SetAlpha(0)
	self.FlyoutBorderShadow:SetAlpha(0)
	
	SpellFlyoutHorizontalBackground:SetAlpha(0)
	SpellFlyoutVerticalBackground:SetAlpha(0)
	SpellFlyoutBackgroundEnd:SetAlpha(0)
	
	for i = 1, GetNumFlyouts() do
		local _, _, numSlots, isKnown = GetFlyoutInfo(GetFlyoutID(i))
		if (isKnown) then
			buttons = numSlots
			break
		end
	end
	
	local arrowDistance
	if ((SpellFlyout and SpellFlyout:IsShown() and (SpellFlyout:GetParent() == self)) or (GetMouseFocus() == self)) then
		arrowDistance = 5
	else
		arrowDistance = 2
	end
	
	if (self:GetParent():GetParent():GetName() == "SpellBookSpellIconsFrame") then 
		return 
	end
	
	if (self:GetAttribute("flyoutDirection") ~= nil) then
		local point = self:GetParent():GetParent():GetPoint()
		
		if (point) then
			if (strfind(point, "BOTTOM")) then
				self.FlyoutArrow:ClearAllPoints()
				self.FlyoutArrow:SetPoint("TOP", self, "TOP", 0, arrowDistance)
				SetClampedTextureRotation(self.FlyoutArrow, 0)
				
				if not(InCombatLockdown()) then 
					self:SetAttribute("flyoutDirection", "UP") 
				end
			else
				self.FlyoutArrow:ClearAllPoints()
				self.FlyoutArrow:SetPoint("LEFT", self, "LEFT", -arrowDistance, 0)
				SetClampedTextureRotation(self.FlyoutArrow, 270)
				
				if not(InCombatLockdown()) then 
					self:SetAttribute("flyoutDirection", "LEFT") 
				end
			end
		end
	end
end

SetGloss = function(button)
	if not(button.Gloss) then
		F.StyleActionButton(button)
	end
	
	button.Gloss:SetAlpha(GUIS_DB["actionbuttons"].glossalpha)
	
	if (GetBoolean(GUIS_DB["actionbuttons"].showgloss)) then
		if not(button.Gloss:IsShown()) then
			button.Gloss:Show()
		end
	else
		if (button.Gloss:IsShown()) then
			button.Gloss:Hide()
		end
	end
end

SetShade = function(button)
	if not(button.Shade) then
		F.StyleActionButton(button)
	end
	
	button.Shade:SetAlpha(GUIS_DB["actionbuttons"].shadealpha)

	if (GetBoolean(GUIS_DB["actionbuttons"].showshade)) then
		if not(button.Shade:IsShown()) then
			button.Shade:Show()
		end
	else
		if (button.Shade:IsShown()) then
			button.Shade:Hide()
		end
	end
end

module.SetGloss = function(gloss)
	GUIS_DB["actionbuttons"].glossalpha = max(0, min(1, tonumber(gloss) or defaults.glossalpha)) 
	gAB:ApplyToAll(SetGloss)
end

module.SetShade = function(shade)
	GUIS_DB["actionbuttons"].shadealpha = max(0, min(1, tonumber(shade) or defaults.shadealpha)) 
	gAB:ApplyToAll(SetShade)
end

module.UpdateAll = function()
	gAB:ApplyToAll(SetGloss)
	gAB:ApplyToAll(SetShade)
end

module.RestoreDefaults = function(self)
	GUIS_DB["actionbuttons"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["actionbuttons"] = GUIS_DB["actionbuttons"] or {}
	GUIS_DB["actionbuttons"] = ValidateTable(GUIS_DB["actionbuttons"], defaults)
end

module.OnInit = function(self)
	if (F.kill(self:GetName())) then 
		self:Kill() 
		return 
	end

	gAB:SetHotkeyFunction(F.StyleHotKey, true)
	gAB:SetGlossFunction(SetGloss, true)
	gAB:SetShadeFunction(SetShade, true)
	gAB:SetStyleFunction(F.StyleActionButton)
	gAB:SetHotkeyState(GUIS_DB["actionbuttons"].showhotkeys)
	gAB:SetNameState(GUIS_DB["actionbuttons"].shownames)
	
	-- fix the spell flyout once and for all
	SpellFlyout:HookScript("OnShow", SetupFlyout)
	hooksecurefunc("ActionButton_UpdateFlyout", UpdateFlyout)
	
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
		gOM:RegisterWithBlizzard(gOM:New(menuTable), F.getName(self:GetName()), 
			"refresh", applySettings, 
			"default", restoreDefaults, 
			"cancel", cancelChanges, 
			"okay", applyChanges)
	end

	-- register the FAQ
	do
		local FAQ = LibStub("gCore-3.0"):GetModule("GUIS-gUI: FAQ")
		FAQ:NewGroup(faq)
	end

	local enable = function(state, key)
		GUIS_DB["actionbuttons"][key] = GetBinary(state)
		
		if (key == "showhotkeys") then
			gAB:SetHotkeyState(GUIS_DB["actionbuttons"].showhotkeys)
			
		elseif (key == "shownames") then
			gAB:SetNameState(GUIS_DB["actionbuttons"].shownames)
			
		end
	end
	
	CreateChatCommand(function() enable(true, "showhotkeys") end, "showhotkeys")
	CreateChatCommand(function() enable(false, "showhotkeys") end, "hidehotkeys")
	CreateChatCommand(function() enable(true, "shownames") end, "shownames")
	CreateChatCommand(function() enable(false, "shownames") end, "hidenames")
end
