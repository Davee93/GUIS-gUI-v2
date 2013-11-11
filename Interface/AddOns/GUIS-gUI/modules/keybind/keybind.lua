--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: KeyBind")

-- Lua API
local pairs, select = pairs, select
local format = format

-- WoW API
local CreateFrame = CreateFrame
local GetBindingAction = GetBindingAction
local GetBindingKey = GetBindingKey
local GetBindingText = GetBindingText
local SetBinding = SetBinding

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local LKB = LibStub("LibKeyBound-1.0")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end

local buttons = {}
local populateBindingTable = function()
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		buttons["ActionButton" .. i] = "ACTIONBUTTON" .. i
		buttons["MultiBarBottomLeftButton" .. i] = "MULTIACTIONBAR1BUTTON" .. i
		buttons["MultiBarBottomRightButton" .. i] = "MULTIACTIONBAR2BUTTON" .. i
		buttons["MultiBarRightButton" .. i] = "MULTIACTIONBAR3BUTTON" .. i
		buttons["MultiBarLeftButton" .. i] = "MULTIACTIONBAR4BUTTON" .. i
	end
	buttons["ExtraActionButton1"] = "EXTRAACTIONBUTTON1"
	
	for i = 1, NUM_PET_ACTION_SLOTS do
		buttons["PetActionButton" .. i] = "BONUSACTIONBUTTON" .. i
	end

	for i = 1, NUM_SHAPESHIFT_SLOTS do
		buttons["ShapeshiftButton" .. i] = "SHAPESHIFTBUTTON" .. i
	end
	
	for i = 1, NUM_MULTI_CAST_PAGES * NUM_MULTI_CAST_BUTTONS_PER_PAGE do -- should match MAX_TOTEMS
		buttons["MultiCastSlotButton" .. i] = "MULTICASTACTIONBUTTON" .. i
	end
	buttons["MultiCastRecallSpellButton"] = "MULTICASTRECALLBUTTON1"
	buttons["MultiCastSummonSpellButton"] = "MULTICASTSUMMONBUTTON1"
end
module.buttons = buttons

module.GetOverlayFrame = function(self)
	if not(self.overlayFrame) then
		local overlayFrame = CreateFrame("Frame", self:GetName() .. "_OverlayFrame", UIParent)
		overlayFrame:SetFrameStrata("DIALOG")
		overlayFrame:EnableMouse(false)
		overlayFrame:Hide()
		
		self.overlayFrame = overlayFrame
	end
	
	return self.overlayFrame
end

module.Color = function(self)
	local overlayFrame = self:GetOverlayFrame()
	if (self.keyBoundMode) then
		overlayFrame:Show()
	else
		overlayFrame:Hide()
	end
end

module.LIBKEYBOUND_ENABLED = function(self)
	self.keyBoundMode = true
	self:Color()
end

module.LIBKEYBOUND_DISABLED = function(self)
	self.keyBoundMode = nil
	self:Color()
end

module.LIBKEYBOUND_MODE_COLOR_CHANGED = function(self)
	local overlayFrame = self:GetOverlayFrame()
	
	for i = 1, overlayFrame:GetNumRegions() do
		local region = select(i, overlayFrame:GetRegions())
		if (region:GetObjectType() == "Frame") and (region:GetBackdrop()) then
			region:SetBackdropColor(LKB:GetColorKeyBoundMode())
		end
	end
	
	self:Color()
end

--
-- setup a button to work with LibKeyBound
--	:Register(button[, bindingID])
-- 
-- 	@param button <frame> the button to handle
-- 	@param bindingID <string> optional bindingID/action. will use (CLICK %s:LeftButton"):format(button:GetName()) if omitted
-- 	@returns <boolean> 'true' if something went wrong, purely for debugging
module.Register = function(self, button, bindingID)
	if not(button) then
		return true
	end
	
	if (bindingID) then
		buttons[button:GetName()] = bindingID
	end
	
	local parentOverlay = self:GetOverlayFrame()
	local thisOverlay = button.KeyBindOverlayFrame or CreateFrame("Frame", button:GetName() .. "_KeyBindOverlayFrame", parentOverlay)
	thisOverlay:SetAllPoints(button)
	thisOverlay:SetBackdrop(M["Backdrop"]["Blank"])
	thisOverlay:SetBackdropColor(0, 0, 0, 0)
	thisOverlay:EnableMouse(false)
	
	local updateOverlay = function(self)
		local frame = LKB.frame
		if (button:IsVisible()) and (frame) then
			self:SetBackdropColor(LKB:GetColorKeyBoundMode())
			self:SetFrameStrata(frame:GetFrameStrata())
			self:SetFrameLevel(frame:GetFrameLevel())
		else
			self:SetBackdropColor(0, 0, 0, 0)
		end
	end
	
	thisOverlay:HookScript("OnShow", updateOverlay)
	thisOverlay:HookScript("OnHide", updateOverlay)

	-- returns the current action assigned to a button
	function button:ToBinding()
		return buttons[self:GetName()] or format("CLICK %s:LeftButton", self:GetName())
	end

	-- returns the current hotkey assigned to the given button
	function button:GetHotkey() 
		local key1, key2 = GetBindingKey(button:ToBinding())
	
		return F.ShortenHotKey(key1), F.ShortenHotKey(key2)
	end
	
	function button:SetKey(key)
		SetBinding(key, button:ToBinding())
	end
	
	-- returns the current buttons/actions bound to a key, unless it is bound to the current button
	function button:FreeKey(key)
		local action = GetBindingAction(key)
		if (action) and not((action == "") or (action == button:ToBinding())) then
			return action
		end
	end
	
	-- clear all binding keys from the current button
	function button:ClearBindings()
		local bindingID = self:ToBinding()
		while (GetBindingKey(bindingID)) do
			SetBinding(GetBindingKey(bindingID), nil)
		end
	end
	
	-- lists all bindings on a button, separated by commas
	function button:GetBindings()
		local keys
		local bindingID = self:ToBinding()
		for i = 1, select("#", GetBindingKey(bindingID)) do
			local hotKey = select(i, GetBindingKey(bindingID))
			if (keys) then
				keys = keys .. ", " .. GetBindingText(hotKey, "KEY_")
			else
				keys = GetBindingText(hotKey, "KEY_")
			end
		end

		return keys
	end
	
	function button:GetActionName()
		return button:GetName()
	end
	
	button:HookScript("OnEnter", function(self) 
		LKB:Set(self) 
	end)
end

module.Activate = function(self)
	LKB:Activate()
end

module.Deactivate = function(self)
	LKB:Deactivate()
end

module.Toggle = function(self)
	LKB:Toggle()
end

module.OnInit = function(self)
	if (F.kill(self:GetName())) then 
		self:Kill() 
		return 
	end
end

module.OnEnable = function(self)
	-- populate the binding table with the most common buttons
	populateBindingTable()
	
	-- any button added to the module.buttons table prior to PLAYER_LOGIN 
	-- will be automatically set up to work with the hoverbind system 
	do
		local button
		for buttonName, bindingID in pairs(buttons) do
			button = _G[buttonName]
			
			if (button) then
				self:Register(button, bindingID)
			end
		end
	end
	
	local styleKeyBindDialog, styleBindFrame
	do
		local once
		styleKeyBindDialog = function()
			if (once) then return end
			
			-- skin the keybinding dialog to match GUIS
			KeyboundDialog:RemoveTextures()
			KeyboundDialog:SetUITemplate("simplebackdrop")
			KeyboundDialogCheck:SetUITemplate("checkbutton")
			KeyboundDialogOkay:SetUITemplate("button")
			KeyboundDialogCancel:SetUITemplate("button")
			
			local point, anchor, relpoint, x, y, i, region
						
			for i = 1, KeyboundDialog:GetNumRegions() do
				region = select(i, KeyboundDialog:GetRegions())
				if (region:GetObjectType() == "FontString") then
					point, anchor, relpoint, x, y = region:GetPoint()
					
					if (point == "TOP") then
						region:SetFontObject(GUIS_SystemFontLarge)
						region:ClearAllPoints()
						region:SetPoint("TOP", KeyboundDialog, "TOP", 0, -8)
					else
						region:SetFontObject(GUIS_SystemFontNormalWhite)
					end
				end
			end
			
			once = true
		end
	end
		
	do
		local once
		styleBindFrame = function()
			if (once) then return end
			
			local frame = LKB.frame
			
			if (frame) then
				frame.text:SetFontObject(GUIS_SystemFontNormal)
				frame.text:SetTextColor(unpack(C["value"]))
				frame.text:SetJustifyH("CENTER")
				frame.text:SetJustifyV("MIDDLE")
				frame.text:ClearAllPoints()
				frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)
				
				frame.text.SetFontObject = noop
				frame.text.ClearAllPoints = noop
				frame.text.SetAllPoints = noop
				frame.text.SetPoint = noop
			
				once = true
			end
		end
	end

	-- only skin the binding frame if the skinner module is loaded
	if not(F.kill("GUIS-gUI: UISkinning")) then
		if (KeyboundDialog) then
			styleKeyBindDialog()
		else
			hooksecurefunc(LKB, "Initialize", styleKeyBindDialog)
		end
		
		if (LKB.frame) then
			styleBindFrame()
		else
			hooksecurefunc(LKB, "Activate", styleBindFrame)
		end
	end
	
	LKB.RegisterCallback(self, "LIBKEYBOUND_ENABLED")
	LKB.RegisterCallback(self, "LIBKEYBOUND_DISABLED")
	LKB.RegisterCallback(self, "LIBKEYBOUND_MODE_COLOR_CHANGED")
	
	LKB:SetColorKeyBoundMode(1, 1, 1, 1/5)
	
	CreateChatCommand(module.Toggle, { "keybind", "bindkey", "hoverbind", "bind" })
end
