--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local MAJOR, MINOR = "gActionButtons-2.0", 40
local gActionButtons, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not gActionButtons then return end 

assert(LibStub("gFrameHandler-1.0"), MAJOR .. " couldn't find an instance of gFrameHandler-1.0")

-- Lua API
local pairs, select = pairs, select
local strfind = string.find
local type = type

-- WoW API
local ActionHasRange = ActionHasRange
local GetActionCooldown = GetActionCooldown
local GetActionInfo = GetActionInfo
local GetItemInfo = GetItemInfo
local IsActionInRange = IsActionInRange
local IsEquippedAction = IsEquippedAction
local IsUsableAction = IsUsableAction

-- these might be changed, don't upvalue them
--local NUM_MULTI_CAST_BUTTONS_PER_PAGE = NUM_MULTI_CAST_BUTTONS_PER_PAGE
--local NUM_MULTI_CAST_PAGES = NUM_MULTI_CAST_PAGES
--local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS
--local NUM_SHAPESHIFT_SLOTS = NUM_SHAPESHIFT_SLOTS
--local MAX_TOTEMS = MAX_TOTEMS

local GetBinary, GetBoolean = GetBinary, GetBoolean

gActionButtons.BUTTONS = gActionButtons.BUTTONS or {}

local styleFunc = noop
local hotkeyFunc = noop
local postoverlayfunc = noop
local cooldownFunc = noop
local cooldownShineFunc = noop
local postglossfunc = noop
local postshadefunc = noop

local rangetimer = 0.1
local showhotkey = 1 
local showmacro = 1

local noop = function() return end

local playerClass = (select(2, UnitClass("player")))

local isSafe
local FixButtonGrid
local ButtonIsUsable, ButtonHasRange
local UpdateHotKey, UpdateCooldown
local StyleActionButton
local StylePetActionButtons, StyleShapeShiftButtons, StyleMultiCastButtons, StyleSummonSpellButton, StyleRecallSpellButton, StyleMultiCastSlotButtons
local UpdateAllHotkeys, UpdateAllNames, UpdateAllCooldowns, ApplyToAll

local isEnabled, hasEnteredWorld

local shiftClass = {
	["DRUID"] 			= true;
	["WARRIOR"] 		= true;
	["PALADIN"] 		= true;
	["DEATHKNIGHT"] 	= true;
	["ROGUE"] 			= true;
	["PRIEST"] 			= true;
	["HUNTER"] 			= true;
	["WARLOCK"] 		= true;
}

--
-- idea here is the have a safelist available, to decide which buttons should always have names/hotkeys
-- this is because the styling functions can potentially be used by all itembuttons, not just actionbuttons
-- we build a table instead of doing a manual check on each call
local safeList = {}
do
	local buttons = {
		["ActionButton"] = NUM_ACTIONBAR_BUTTONS; 
		["MultiBarBottomLeftButton"] = NUM_ACTIONBAR_BUTTONS; 
		["MultiBarBottomRightButton"] = NUM_ACTIONBAR_BUTTONS; 
		["MultiBarRightButton"] = NUM_ACTIONBAR_BUTTONS; 
		["MultiBarLeftButton"] = NUM_ACTIONBAR_BUTTONS;
		["PetActionButton"] = NUM_PET_ACTION_SLOTS;
		["ShapeshiftButton"] = NUM_SHAPESHIFT_SLOTS;
		["MultiCastSummonSpellButton"] = 1;
		["MultiCastSlotButton"] = MAX_TOTEMS;
		["MultiCastRecallSpellButton"] = 1; 
		["ExtraActionButton"] = 1; 
	}
	for key, numButtons in pairs(buttons) do
		for index = 1, numButtons do
			safeList[key .. index] = true
		end
	end
	buttons = nil
end

--
-- ..aaand here's the function that performs the actual checking
isSafe = function(button)
	return safeList[button:GetName()]
end

-- make sure the style functions get hooked
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:SetScript("OnEvent", function(self, event, ...) 
	local arg1 = ...
	if (event == "PLAYER_ENTERING_WORLD") then
		gActionButtons:OnEnter()
		
		-- we only need this once
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")

		hasEnteredWorld = true
		
	elseif (event == "ACTIONBAR_UPDATE_COOLDOWN") then
		UpdateAllCooldowns()
	
	elseif (event == "UPDATE_SHAPESHIFT_FORMS")
		or (event == "UPDATE_SHAPESHIFT_USABLE") 
		or (event == "UPDATE_SHAPESHIFT_COOLDOWN")
		or (event == "UPDATE_SHAPESHIFT_FORM")
		or (event == "ACTIONBAR_PAGE_CHANGED") then
	
		StyleShapeShiftButtons()
		
	elseif (event == "PET_BAR_UPDATE") 
		or (event == "PLAYER_CONTROL_GAINED") 
		or (event == "PLAYER_CONTROL_LOST") 
		or (event == "PLAYER_FARSIGHT_FOCUS_CHANGED") 
		or (event == "PET_BAR_HIDE")
		or (event == "PET_UI_UPDATE")
		or (event == "PET_BAR_UPDATE_USABLE")
		or (event == "PET_BAR_UPDATE_COOLDOWN")
		or (event == "UNIT_FLAGS")
		or ((event == "UNIT_PET") and (arg1 == "player")) 
		or ((event == "UNIT_AURA") and (arg1 == "pet")) then
		
		StylePetActionButtons()
	
	elseif (event == "SPELL_ACTIVATION_OVERLAY_SHOW") then

		--[[
		local actionType, id, subType = GetActionInfo(self.action);
		if ( actionType == "spell" and id == arg1 ) then
			ActionButton_ShowOverlayGlow(self);
		elseif ( actionType == "macro" ) then
			local _, _, spellId = GetMacroSpell(id);
			if ( spellId and spellId == arg1 ) then
				ActionButton_ShowOverlayGlow(self);
			end
		end
		]]--
		
	elseif (event == "SPELL_ACTIVATION_OVERLAY_HIDE") then
		--[[
		local actionType, id, subType = GetActionInfo(self.action)
		if ( actionType == "spell" and id == arg1 ) then
			ActionButton_HideOverlayGlow(self);
		elseif ( actionType == "macro" ) then
			local _, _, spellId = GetMacroSpell(id);
			if (spellId and spellId == arg1 ) then
				ActionButton_HideOverlayGlow(self);
			end
		end
		]]--
		
	elseif (event == "UPDATE_MULTI_CAST_ACTIONBAR") then
--		StyleMultiCastButtons()
--		StyleSummonSpellButton()
--		StyleRecallSpellButton()
		
	elseif (event == "PLAYER_TOTEM_UPDATE") then
--		StyleMultiCastButtons()
		
	end
end)


-- default colors
local C = {}
C["normal"] = { r = 0.15; g = 0.15; b = 0.15; } -- normal state, when nothing else applies
C["equipped"] = { r = 0.10; g = 0.85; b = 0.10; } -- equipped items
C["mana"] = { r = 0.10; g = 0.10; b = 0.85; } -- you haven't enough mana
C["range"] = { r = 0.85; g = 0.10; b = 0.10; } -- target is out of range
C["usable"] = { r = 1.00; g = 1.00; b = 1.00; } -- an item or ability is usable 
C["unusable"] = { r = 0.35; g = 0.35; b = 0.35; } -- an item or ability is not usable

FixButtonGrid = function(button)
	if not(self) then 
		return 
	end

	local nt = _G[button:GetName().."NormalTexture"]

	if (nt) and (IsEquippedAction(button.action)) then
		nt:SetVertexColor(C["equipped"].r, C["equipped"].g, C["equipped"].b, 1)
	else
		nt:SetVertexColor(C["normal"].r, C["normal"].g, C["normal"].b, 1)
	end  
end

ButtonIsUsable = function(self)
	if not(self) or not(self.action) then 
		return 
	end
	
	local name = self:GetName()
	local nt = _G[name.."NormalTexture"]
	local ic = _G[name.."Icon"]
	
	if (nt) then
		if (IsEquippedAction(self.action)) then
			nt:SetVertexColor(C["equipped"].r, C["equipped"].g, C["equipped"].b, 1)
		else
			nt:SetVertexColor(C["normal"].r, C["normal"].g, C["normal"].b, 1)
		end  
	end  
	
	local isUsable, notEnoughMana = IsUsableAction(self.action)
	
	if (ic) then
		if (ActionHasRange(self.action)) and (IsActionInRange(self.action) == 0) then
			ic:SetVertexColor(C["range"].r, C["range"].g, C["range"].b, 1)
		elseif notEnoughMana then
			ic:SetVertexColor(C["mana"].r, C["mana"].g, C["mana"].b, 1)
		elseif isUsable then
			ic:SetVertexColor(C["usable"].r, C["usable"].g, C["usable"].b, 1)
		else
			ic:SetVertexColor(C["unusable"].r, C["unusable"].g, C["unusable"].b, 1)
		end
	end
end

ButtonHasRange = function(self, elapsed)
	if not(self) then 
		return 
	end

	local t = self.rangetimer
	
	if not(t) then
		self.rangetimer = 0
		return
	end
	
	t = t + elapsed
	
	if (t < (rangetimer or 0.1)) then
		self.rangetimer = t
		return
	else
--		self.rangetimer = self.rangetimer - (rangetimer or 0.1)
		self.rangetimer = 0
	end
	
	ButtonIsUsable(self)
end

PostUpdateOverlay = function(self)
	if not(self) then 
		return 
	end

	if (self.overlay) then
		postoverlayfunc(self)
	end
end

UpdateHotKey = function(button, actionButtonType)
	if not(button) then 
		return 
	end
	
	local hotkey = _G[button:GetName().."HotKey"]
	if not(hotkey) then 
		return 
	end
	
	local text = hotkey:GetText()
	if (text) then
		hotkeyFunc(text, hotkey, button, actionButtonType)
	end
	
	if GetBoolean(showhotkey) then
		hotkey:Show()
	else
		hotkey:Hide()
	end
end 

UpdateCooldown = function(self)
	if not(self) or not(isEnabled) then
		return
	end

	local start, duration, enable = 0, 0, 0
	if (self.action) then
		start, duration, enable = GetActionCooldown(self.action)
	end
	
	cooldownFunc(self, start, duration, enable)
end

StyleActionButton = function(self)
	if not(self) then 
		return 
	end

	local name = self:GetName()
	
	if not(gActionButtons.BUTTONS[name]) then
		gActionButtons.BUTTONS[name] = self
	end
	
	local actionType, ID, subType
	if self.action then
		actionType, ID, subType = GetActionInfo(self.action)
	end
	
	self.Button = self
	self.ActionType = actionType
	self.ItemID = actionType == "item" and ID
	self.ItemRarity = actionType == "item" and (select(3,GetItemInfo(ID)))
	self.Name = name

	self.Autocast = self.Autocast or _G[name.."AutoCastable"]
	self.Background = self.Background or _G[name].background
	self.Border = self.Border or _G[name.."Border"]
	self.Cooldown = self.Cooldown or _G[name.."Cooldown"]
	self.Count = self.Count or _G[name.."Count"]
	self.Flash = self.Flash or _G[name.."Flash"]
	self.FloatingBG = self.FloatingBG or _G[name.."FloatingBG"]
	self.Frame = self.Frame or _G[name.."Frame"]
	self.Gloss = self.Gloss or _G[name.."Gloss"]
	self.Highlight = self.Highlight or _G[name.."Highlight"]
	self.Hotkey = self.Hotkey or _G[name.."HotKey"]
	self.Hover = self.Hover or _G[name.."HoverTex"]
	self.Icon = self.Icon or _G[name.."Icon"] or _G[name.."IconTexture"]
	self.Macro = self.Macro or _G[name.."Name"]
	self.NormalTexture = self.NormalTexture or _G[name.."NormalTexture"] or _G[name.."NormalTexture2"]
	self.Overlay = self.Overlay or _G[name].overlay
	self.Panel = self.Panel or _G[name.."Panel"]
	self.Pushed = self.Pushed or _G[name.."PushedTex"]
	self.Shade = self.Shade or _G[name.."Shade"]
	self.Shine = self.Shine or _G[name.."Shine"]
	
	if not(self.TotemBorder) then 
		if (name:find("MultiCastAction")) then 
			self.TotemBorder = self.overlayTex
			
		elseif (name:find("MultiCastSlot")) then
			local region
			for i = 1, self:GetNumRegions() do
				region = select(i, self:GetRegions())
				if (region) and (region.GetTexture) and (region:GetTexture() == [[Interface\Buttons\UI-TotemBar]]) then
					self.TotemBorder = region
				end
			end
		end
	end
	
	if (self.Macro) then
		if GetBoolean(showmacro) or (not isSafe(self)) then
			self.Macro:Show()
		else
			self.Macro:Hide()
		end
	end
	
	if (self.Hotkey) then
		if GetBoolean(showhotkey) then
			self.Hotkey:Show()
		else
			self.Hotkey:Hide()
		end
	end
	
	styleFunc(self)
	
	-- gloss and shade layers aren't currently created by gActionButtons, 
	-- so we need to run the user's style function prior to calling these
	if (self.Gloss) then
		postglossfunc(self)
	end

	if (self.Shade) then
		postshadefunc(self)
	end

	UpdateHotKey(self)
	UpdateCooldown(self)
end
gActionButtons.StyleActionButton = StyleActionButton

StylePetActionButtons = function()
	if not(isEnabled) then
		return
	end

	for i = 1, NUM_PET_ACTION_SLOTS, 1 do
		StyleActionButton(_G["PetActionButton"..i])
	end  
end

StyleShapeShiftButtons = function()
	if not(isEnabled) then
		return
	end

	for i = 1, NUM_SHAPESHIFT_SLOTS, 1 do
		StyleActionButton(_G["ShapeshiftButton"..i])
	end
end

StyleMultiCastSlotButtons = function()
	if not(isEnabled) then
		return
	end
	
	local button
	for i = 1, MAX_TOTEMS do
		button = _G["MultiCastSlotButton" .. i]
		
		StyleActionButton(button)
	end
end

StyleMultiCastButtons = function()
	if not(isEnabled) then
		return
	end
	
	StyleMultiCastSlotButtons()
	
	local button, slot
	for i = 1, NUM_MULTI_CAST_PAGES * NUM_MULTI_CAST_BUTTONS_PER_PAGE do
		button = _G["MultiCastActionButton"..i]
		StyleActionButton(button)
	end
end

StyleSummonSpellButton = function()
	if not(isEnabled) then
		return
	end

	StyleActionButton(MultiCastSummonSpellButton)

	if (MultiCastActionBarFrame.numActiveSlots == 0) then
		if not(InCombatLockdown()) then
			MultiCastSummonSpellButton:Hide()
		end
	end
end

StyleRecallSpellButton = function()
	if not(isEnabled) then
		return
	end

	StyleActionButton(MultiCastRecallSpellButton)
end

UpdateAllHotkeys = function()
	if not(isEnabled) then
		return
	end

	for name, button in pairs(gActionButtons.BUTTONS) do
		if _G[name.."HotKey"] then
			if GetBoolean(showhotkey) then
				_G[name.."HotKey"]:Show()
			else
				_G[name.."HotKey"]:Hide()
			end
		end
	end
end

UpdateAllNames = function()
	if not(isEnabled) then
		return
	end

	for name, button in pairs(gActionButtons.BUTTONS) do
		if _G[name.."Name"] then
			if GetBoolean(showmacro) or (not isSafe(button)) then
				_G[name.."Name"]:Show()
			else
				_G[name.."Name"]:Hide()
			end
		end
	end
end

UpdateAllCooldowns = function()
	if not(isEnabled) then
		return
	end

	for name, button in pairs(gActionButtons.BUTTONS) do
		UpdateCooldown(button)
	end
end

ApplyToAll = function(func, ...)
	if not(isEnabled) then
		return
	end

	for name, button in pairs(gActionButtons.BUTTONS) do
		func(button, ...)
	end
end

function gActionButtons:Enable()
	if (self.enabled) or (isEnabled) then 
		return 
	else
		self.enabled = true
		isEnabled = true
	end
	
	hooksecurefunc("ActionButton_Update", StyleActionButton)
	hooksecurefunc("ActionButton_UpdateUsable", ButtonIsUsable)
	hooksecurefunc("ActionButton_OnUpdate", ButtonHasRange)
	hooksecurefunc("ActionButton_ShowGrid", FixButtonGrid)
	hooksecurefunc("ActionButton_UpdateHotkeys", UpdateHotKey)
	hooksecurefunc("ActionButton_ShowOverlayGlow", PostUpdateOverlay)
	
	-- this doesn't work properly yet
	hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, "SetCooldown", function(self, start, duration) 
		cooldownFunc(self:GetParent(), start, duration) 
	end)
	
	if (playerClass == "SHAMAN") then
		hooksecurefunc("MultiCastActionBarFrame_Update", StyleMultiCastButtons)
		hooksecurefunc("MultiCastSlotButton_Update", StyleMultiCastSlotButtons)
		hooksecurefunc("MultiCastSummonSpellButton_Update", StyleSummonSpellButton)
		hooksecurefunc("MultiCastRecallSpellButton_Update", StyleRecallSpellButton)
		
		EventFrame:RegisterEvent("PLAYER_TOTEM_UPDATE")
		EventFrame:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
	end

	EventFrame:RegisterEvent("PET_UI_UPDATE")
	EventFrame:RegisterEvent("PET_BAR_HIDE")
	EventFrame:RegisterEvent("PET_BAR_UPDATE")
	EventFrame:RegisterEvent("PET_BAR_UPDATE_USABLE")
	EventFrame:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
	EventFrame:RegisterEvent("PLAYER_CONTROL_GAINED")
	EventFrame:RegisterEvent("PLAYER_CONTROL_LOST")
	EventFrame:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
	EventFrame:RegisterEvent("UNIT_FLAGS")
	EventFrame:RegisterEvent("UNIT_PET")
	EventFrame:RegisterEvent("UNIT_AURA")
	EventFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_SHOW")
	EventFrame:RegisterEvent("SPELL_ACTIVATION_OVERLAY_HIDE")
	
	if (shiftClass[playerClass]) then
		EventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
		EventFrame:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
		EventFrame:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
		EventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
		EventFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
	end

		hooksecurefunc("ShapeshiftBar_OnLoad", StyleShapeShiftButtons)
		hooksecurefunc("ShapeshiftBar_Update", StyleShapeShiftButtons)
		hooksecurefunc("ShapeshiftBar_UpdateState", StyleShapeShiftButtons)
		hooksecurefunc("PetActionBar_Update", StylePetActionButtons)
	
	if (hasEnteredWorld) then
		self:OnEnter()
	end
end

function gActionButtons:OnEnter()
	if not(isEnabled) then
		return
	end
	
	if (playerClass == "SHAMAN") then
		StyleMultiCastButtons()
		StyleSummonSpellButton()
		StyleRecallSpellButton()
	end
	
	if (shiftClass[playerClass]) then
		StyleShapeShiftButtons()
	end
	
	StylePetActionButtons()
end

------------------------------------------------------------------------------------------------------------
-- 	API Calls
------------------------------------------------------------------------------------------------------------
function gActionButtons:SetStyleFunction(func, cold)
	styleFunc = type(func) == "function" and func or noop

	if not(cold) then 
		self:Enable()
	end
end

function gActionButtons:SetHotkeyFunction(func, cold)
	hotkeyFunc = type(func) == "function" and func or noop

	if not(cold) then 
		self:Enable()
	end
end

function gActionButtons:SetGlossFunction(func, cold)
	postglossfunc = type(func) == "function" and func or noop

	if not(cold) then 
		self:Enable()
	end
end

function gActionButtons:SetShadeFunction(func, cold)
	postshadefunc = type(func) == "function" and func or noop

	if not(cold) then 
		self:Enable()
	end
end

function gActionButtons:SetOverlayFunction(func, cold)
	postoverlayfunc = type(func) == "function" and func or noop

	if not(cold) then 
		self:Enable()
	end
end

function gActionButtons:SetCooldownFunction(func, cold)
	cooldownFunc = type(func) == "function" and func or noop

	if not(cold) then 
		self:Enable()
	end
end

function gActionButtons:SetCooldownShineFunction(func, cold)
	cooldownShineFunc = type(func) == "function" and func or noop

	if not(cold) then 
		self:Enable()
	end
end

function gActionButtons:SetHotkeyState(state)
	showhotkey = GetBinary(state)

	UpdateAllHotkeys()
end

function gActionButtons:SetNameState(state)
	showmacro = GetBinary(state)
	
	UpdateAllNames()
end

function gActionButtons:UpdateAllCooldowns()
	UpdateAllCooldowns()
end

function gActionButtons:ApplyToAll(func, ...)
	ApplyToAll(func, ...)
end
