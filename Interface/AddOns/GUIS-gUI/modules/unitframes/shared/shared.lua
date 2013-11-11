--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local oUF = ns.oUF or oUF 

-- Lua API
local _G = _G
local strfind, gsub, strupper = string.find, string.gsub, string.upper
local pairs, select, unpack = pairs, select, unpack
local tinsert, tremove = table.insert, table.remove

-- WoW API
local CreateFrame = CreateFrame
local ToggleDropDownMenu = ToggleDropDownMenu
local UnitAura = UnitAura
local UnitExists = UnitExists
local UnitIsConnected= UnitIsConnected
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsUnit = UnitIsUnit
local UnitIsVisible = UnitIsVisible
local UnitThreatSituation = UnitThreatSituation

-- GUIS API
local R = LibStub("gDB-1.0"):NewDataBase("GUIS-gUI: UnitFrameAuras")
local RaidGroups = LibStub("gDB-1.0"):NewDataBase("GUIS-gUI: UnitFrameRaidGroups")
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local EventHandler = LibStub("gCore-3.0"):GetModule("GUIS-gUI: EventHandler") -- created by core\functions.lua
local UnregisterCallback = function(...) EventHandler:UnregisterCallback(...) end
local RegisterCallback = function(...) EventHandler:RegisterCallback(...) end

local localizedClass, class = UnitClass("player")
local unitIsPlayer = { player = true, pet = true, vehicle = true }

--------------------------------------------------------------------------------------------------
--		Shared functions for most unitframes
--------------------------------------------------------------------------------------------------
-- don't mix stuff here, or you'll end up with multiple raid frames at once
local visibility = {
	-- never show
	hide = "custom hide";
	
	-- 2-5 player group frames
	party1to5 = "custom [@raid6,exists] hide; show";

	-- 10 player styled frames, vertical display, sorted from top to bottom
	raid2to10 = "custom [@raid11,exists] hide; [@raid2,exists][@party1,exists] show; hide";
	raid6to10 = "custom [@raid11,exists] hide; [@raid6,exists] show; hide";

	-- 15 player styled battleground frames, vertical display, sorted from top to bottom
	 raid2to15 = "custom [@raid16,exists] hide; [@raid2,exists][@party1,exists] show; hide";
	 raid6to15 = "custom [@raid16,exists] hide; [@raid6,exists] show; hide";
	
	--
	-- 40 player styled gridlike frames, sorted horizontally by player, vertically by group (if full groups), starts at the topleft
	--
	raid2to40 = "custom [@raid2,exists][@party1,exists] show; hide"; -- will display for all groups with 2 or more members
	raid6to40 = "custom [@raid6,exists] show; hide"; -- will display for raids with 6 or more players 
	raid11to40 = "custom [@raid11,exists] show; hide"; -- will display for raids with 11 or more players 
	raid16to40 = "custom [@raid16,exists] show; hide"; -- will display for raids with 16 or more players
}

-- returns the visibility macro conditionals for the given header type
-- this needs to fire on the following events to be accurate:
-- 	PLAYER_ALIVE, ACTIVE_TALENT_GROUP_CHANGED, PLAYER_TALENT_UPDATE, TALENTS_INVOLUNTARILY_RESET 
F.GetHeaderVisibility = function(type)
	if not(type) then
		return
	end
	
	local driver
	
	-- the v1.9 way
	--[[
	do
		local showRaidFramesInParty = GUIS_DB["unitframes"].showRaidFramesInParty
		local showGridFramesAlways = GUIS_DB["unitframes"].showGridFramesAlways

		if (type == "party") then 
			driver = (showRaidFramesInParty) and visibility.hide or visibility.party1to5
		end
		
		if (type == "raid10") then
			if (showRaidFramesInParty) then
				driver = (showGridFramesAlways) and visibility.hide or visibility.raid2to15
			else
				driver = (showGridFramesAlways) and visibility.hide or visibility.raid6to15
			end
		end
		
		if (type == "raid40") then
			if (showRaidFramesInParty) then
				driver = (showGridFramesAlways) and visibility.raid2to40 or visibility.raid16to40
			else
				driver = (showGridFramesAlways) and visibility.raid6to40 or visibility.raid16to40
			end
		end
	end
	]]--
	
	-- the v2.0 way
	do
		local isHealer = F.IsPlayerHealer()
		local alwaysRaid = GUIS_DB["unitframes"].showRaidFramesInParty
		local alwaysGrid = GUIS_DB["unitframes"].showGridFramesAlways
		local auto = GUIS_DB["unitframes"].autoSpec
		local grid = GUIS_DB["unitframes"].useGridFrames

		if (type == "party") then 
			driver = (alwaysRaid) and visibility.hide or visibility.party1to5
		end
		
		if (type == "raid10") then
			if (alwaysRaid) then
				driver = (alwaysGrid) and visibility.hide or visibility.raid2to15
			else
				driver = (alwaysGrid) and visibility.hide or visibility.raid6to15
			end
		end
		
		if (type == "raid40dps") then
			if ((auto) and not(isHealer)) or (not(auto) and not(grid)) then
				if (alwaysRaid) then
					driver = (alwaysGrid) and visibility.raid2to40 or visibility.raid16to40
				else
					driver = (alwaysGrid) and visibility.raid6to40 or visibility.raid16to40
				end
			else
				driver = visibility.hide
			end
		end
			
		if (type == "raid40grid") then
			if ((auto) and (isHealer)) or (not(auto) and (grid)) then
				if (alwaysRaid) then
					driver = (alwaysGrid) and visibility.raid2to40 or visibility.raid16to40
				else
					driver = (alwaysGrid) and visibility.raid6to40 or visibility.raid16to40
				end
			else
				driver = visibility.hide
			end
		end
		
	end
	
	return driver
end

-- update the visibility of all group (raid/party) frames according to stored settings
F.updateAllVisibility = function()
	local Raid10, Raid40DPS, Raid40GRID = RaidGroups["10"], RaidGroups["40DPS"], RaidGroups["40GRID"]
	if (F.combatAbort()) then 
		return 
	end
	
	if (GUIS_Party) then 
		F.changeVisibilityAttributeDriver(GUIS_Party, F.GetHeaderVisibility("party"))
	end
	
	if (Raid10) then
		F.changeVisibilityAttributeDriver(Raid10, F.GetHeaderVisibility("raid10"))
	end
	
	if (Raid40DPS) then
		F.changeVisibilityAttributeDriver(Raid40DPS, F.GetHeaderVisibility("raid40dps"))
	end
	
	if (Raid40GRID) then
		F.changeVisibilityAttributeDriver(Raid40GRID, F.GetHeaderVisibility("raid40grid"))
	end
end

-- returns true and prints out an error message if in combat
F.combatAbort = function()
	if (InCombatLockdown()) then
		print(L["UnitFrames cannot be configured while engaged in combat"])
		return true
	end
end

-- change the visibility conditionals of the given header
F.changeVisibilityAttributeDriver = function(header, visibility)
	if (F.combatAbort()) then return end
	
	local type, list = strsplit(" ", visibility, 2)
	if (list) and (type == "custom") then
		UnregisterAttributeDriver(header, "state-visibility")
		RegisterAttributeDriver(header, "state-visibility", list)
	end 
end

F.UpdateAuraFilter = function(self)
	local auras = self.Auras
	
	if (auras) and (auras.__owner) and (self == auras.__owner) and (auras.__owner.unit) then
		auras:ForceUpdate()
	end
end

-- decide the spacing between the Minimappanels and the group frames based on screen height
F.GetGroupSpacing = function()
	local h = GetScreenHeight() or 0
	
	return (h > 990) and 40 or (h > 890) and 20 or (h == 0) and 20 or 0
end

F.UnitFrameMenu = function(self)
	if (self.unit == "targettarget") or (self.unit == "focustarget") or (self.unit == "pettarget") then
		return
	end
	
	local unit = self.unit:gsub("(.)", strupper, 1)

	if _G[unit.."FrameDropDown"] then
		ToggleDropDownMenu(1, nil, _G[unit.."FrameDropDown"], "cursor")
		return
		
	elseif (self.unit:match("party")) then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor")
		return
		
	else
		FriendsDropDown.unit = self.unit
		FriendsDropDown.id = self.id
		FriendsDropDown.initialize = RaidFrameDropDown_Initialize
		ToggleDropDownMenu(1, nil, FriendsDropDown, "cursor")
	end
end

-- get rid of stuff we don't want from the dropdown menus
-- * this appears to be causing taint for elements other than set/clear focus
do 
	local UnWanted = {
		["SET_FOCUS"] = true;
		["CLEAR_FOCUS"] = true;
	}
	for id,menu in pairs(UnitPopupMenus) do
		for index, option in pairs(UnitPopupMenus[id]) do
			if (UnWanted[option]) then
				tremove(UnitPopupMenus[id], index)
			end
		end
	end
end

-- attempt to replace the default raid target icons from unitmenus
-- *will have to see if this taints them
do
	for i = 1,8 do
		UnitPopupButtons["RAID_TARGET_" .. i].icon = M["Icon"]["RaidTarget"]
	end
end

do
	local PostUpdateHealth = function(self, unit, min, max)
		if (UnitIsDeadOrGhost(unit)) then 
			self:SetValue(0) 
		end
	end

	local OnUpdate = function(Updater)
		Updater:Hide()
		local bar = Updater:GetParent()
		local min, max = bar:GetMinMaxValues()
		local value = bar:GetValue()
		local tex = bar:GetStatusBarTexture()
		
		-- 4.3 fix
		local size = ((max) and (max > 0)) and (max - value)/max or 1
		
		tex:ClearAllPoints()
		tex:SetPoint("BOTTOMRIGHT")
		tex:SetPoint("TOPLEFT", bar, "TOPLEFT", size * bar:GetWidth(), 0)
	end
	
	local OnChanged = function(bar)
		bar.Updater:Show()
	end

	F.ReverseBar = function(self)
		local bar = CreateFrame("StatusBar", nil, self)
		bar.Updater = CreateFrame("Frame", nil, bar)
		bar.Updater:Hide()
		bar.Updater:SetScript("OnUpdate", OnUpdate)
		bar:SetScript("OnSizeChanged", OnChanged)
		bar:SetScript("OnValueChanged", OnChanged)
		bar:SetScript("OnMinMaxChanged", OnChanged)
		
		bar.PostUpdate = PostUpdateHealth
		
		return bar
	end
end

F.PostCreateAura = function(element, button)
	button:SetUITemplate("simpleborder")

	button.icon:ClearAllPoints()
	button.icon:SetPoint("TOP", button, 0, -3)
	button.icon:SetPoint("RIGHT", button, -3, 0)
	button.icon:SetPoint("BOTTOM", button, 0, 3)
	button.icon:SetPoint("LEFT", button, 3, 0)
	button.icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
	button.icon:SetDrawLayer("ARTWORK")

	local layer, subLayer = button.icon:GetDrawLayer()
	
	button.shade = button:CreateTexture()
	button.shade:SetDrawLayer(layer or "BACKGROUND", subLayer and subLayer + 1 or 2)
	button.shade:SetTexture(M["Button"]["Shade"])
	button.shade:SetVertexColor(0, 0, 0, 1/2)
	button.shade:SetAllPoints(button.icon)

	button.gloss = button:CreateTexture()
	button.gloss:SetDrawLayer(layer or "BACKGROUND", subLayer and subLayer + 2 or 3)
	button.gloss:SetTexture(M["Button"]["Gloss"])
	button.gloss:SetVertexColor(1, 1, 1, 1/2)
	button.gloss:SetAllPoints(button.icon)
	
	button.cd:SetReverse()
	button.cd:SetAllPoints(button.icon)

	button.overlay:SetTexture("")
end

F.PostUpdateAura = function(element, unit, button, index)
	local name, _, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, value1, value2, value3 = UnitAura(unit, index, button.filter)

--	if (strfind(button.filter, "HARMFUL")) then

	if (unit == "target") then
		-- desaturate auras not cast by the player or a boss
		-- color borders by magic type if cast by the player or a boss
		if (unitIsPlayer[unitCaster]) or (isBossDebuff) then
			local color = DebuffTypeColor[debuffType] 
			
			if (color) and (color.r) and (color.g) and (color.b) then
				color.r = color.r and color.r * 0.85
				color.g = color.g and color.g * 0.85
				color.b = color.b and color.b * 0.85
			else
				color = { r = 0.7, g = 0, b = 0 }
			end
			
			button:SetBackdropBorderColor(color.r, color.g, color.b)
			button.icon:SetDesaturated(false)
		else
			if (unitCaster == "vehicle") then
				button:SetBackdropBorderColor(0, 3/4, 0, 1)
			else
				button:SetBackdropBorderColor(unpack(C["border"]))
			end
			
			if (GUIS_DB["unitframes"].desaturateNonPlayerAuras) then
				button.icon:SetDesaturated(true)
			end
		end
	else
		if (unitCaster == "vehicle") then
			button:SetBackdropBorderColor(0, 3/4, 0, 1)
		else
			if (isBossDebuff) then
				local color = DebuffTypeColor[debuffType] or { r = 0.7, g = 0, b = 0 }
				button:SetBackdropBorderColor(color.r, color.g, color.b)
			else
				button:SetBackdropBorderColor(unpack(C["border"]))
			end
		end
	end
end

F.SetAuraWatchSpell = function(auras, spellInfo, aurasize)
	local spellID, point, color, anyUnit = unpack(spellInfo)
	aurasize = aurasize or 2

	local icon = CreateFrame("Frame", nil, auras)
	icon.spellID = spellID
	icon.anyUnit = anyUnit
	icon:SetWidth(6 * aurasize)
	icon:SetHeight(6 * aurasize)
	icon:SetPoint(point, 0, 0)

	local tex = icon:CreateTexture(nil, "OVERLAY")
	tex:SetAllPoints(icon)
	tex:SetTexture(M["Background"]["Blank"])
	
	if (color) then
		tex:SetVertexColor(unpack(color))
	else
		tex:SetVertexColor(0.8, 0.8, 0.8)
	end

	local count = icon:CreateFontString(nil, "OVERLAY")
	count:SetFontObject(GUIS_UnitFrameNumberTiny)
	count:SetPoint("CENTER", unpack(R.AuraIndicatorOffsets[point]))
	icon.count = count

	auras.icons[spellID] = icon
end

F.CreateTargetBorder = function(self, unit)
	local parent = ((unit == "party") or (unit == "raid")) and self:GetParent() or self
	local TargetBorder = CreateFrame("Frame", nil, parent)
	TargetBorder:Hide()
	TargetBorder:SetPoint("TOPLEFT", self, -5, 5)
	TargetBorder:SetPoint("BOTTOMRIGHT", self, 5, -5)
	TargetBorder:SetUITemplate("targetborder")
	TargetBorder.parent = self
	
	TargetBorder:RegisterEvent("PLAYER_TARGET_CHANGED")
	TargetBorder:RegisterEvent("PARTY_MEMBERS_CHANGED")
	TargetBorder:RegisterEvent("RAID_ROSTER_UPDATE")
	TargetBorder:SetScript("OnEvent", function(self)
		F.PostUpdateTargetBorder(self.parent) 
	end) 

	F.PostUpdateTargetBorder(TargetBorder.parent)

	self.TargetBorder = TargetBorder
	
	return TargetBorder
end

F.PostUpdateTargetBorder = function(self, event, unit)
	if not(self.TargetBorder) then
		return 
	end

	if not(UnitExists(self.unit)) or not(self:IsVisible()) then
		self.TargetBorder:Hide()
		return
	end
	
	if (UnitIsUnit(self.unit, "target")) then
		self.TargetBorder:Show()
		return
	end
	
	self.TargetBorder:Hide()
end

F.ThreatOverride = function(self, event, unit)
	if (unit ~= self.unit) then return end

	unit = unit or self.unit
	local status = UnitThreatSituation(unit)

	if (status and status > 0) then
		local r, g, b = GetThreatStatusColor(status)
		self.FrameBorder:SetBackdropBorderColor(r * 5/5, g * 5/5, b * 5/5)
		self.FrameBorder:SetUIShadowColor(r * 1/3, g * 1/3, b * 1/3)
	else
		self.FrameBorder:SetBackdropBorderColor(unpack(C["border"]))
		self.FrameBorder:SetUIShadowColor(unpack(C["shadow"]))
	end
	
	if (not self.FrameBorder:IsShown()) then
		self.FrameBorder:Show()
	end
end

-- worgen faces. not worgen crotches.
F.PostPortraitUpdate = function(self, unit)
	if (self:GetModel()) and (self:GetModel().find) and (self:GetModel():lower():find("worgenmale")) then
		self:SetCamera(1)
	end
end
	
-- Hide portraits when not available, instead of having a big weird questionmark
F.HidePortrait = function(self, unit)
	if (self.unit == "target") then
		if (not UnitExists(self.unit)) or (not UnitIsConnected(self.unit)) or (not UnitIsVisible(self.unit)) then
			self.Portrait:SetAlpha(0)
		else
			F.PostUpdatePortrait(self.Portrait, unit)
		end
	end
end

-- Update the portrait alpha
F.PostUpdatePortrait = function(self, unit)
	self:SetAlpha(0)
	self:SetAlpha(1)
	
	F.PostPortraitUpdate(self, unit)
end

-- set focus shortcuts
do
	local focusModifier = { [1] = "shift-", [2] = "ctrl-", [3] = "alt-", [4] = "*" }
	
	F.GetFocusMacroKey = function()
		return focusModifier[GUIS_DB["unitframes"].focusKey] .. "type" .. GUIS_DB["unitframes"].focusButton
	end

	F.GetFocusMacroString = function()
		return ([[self:SetAttribute("%s", "macro")]]):format(F.GetFocusMacroKey())
	end
	
	F.ResetAllFocusMacros = function(self)
		if not(self) then return end
		
		for i = 1,#focusModifier do
			for mouse = 1, 31 do
				self:SetAttribute(focusModifier[i] .. "-type" .. mouse, nil)
			end
		end
	end
	
	F.PostUpdateFocusMacro = function(self, unit)
		if not(self) then return end

		F.ResetAllFocusMacros(self)
		
		if (GUIS_DB["unitframes"].shiftToFocus) then
			if (unit == "focus") then
				self:SetAttribute(F.GetFocusMacroKey(), "macro")
				self:SetAttribute("macrotext", "/clearfocus")
			else
				self:SetAttribute(F.GetFocusMacroKey(), "focus")
			end
		end
	end
end

-- apply the function 'func' with arguments ... to all registered unitframes
F.ApplyToAllUnits = function(func, ...)
	local UnitFrames = LibStub("gCore-3.0"):GetModule("GUIS-gUI: UnitFrames")
	
	if not(UnitFrames._UNITS) then
		return
	end
	
	for name, frame in pairs(UnitFrames._UNITS) do
		func(frame, ...)
	end
end

-- callback for option updates
F.PostUpdateOptions = function(self, unit)
	if (GUIS_DB["unitframes"].showHealth) then
		self.healthValue:Show()
	else
		self.healthValue:Hide()
	end
	
	if (GUIS_DB["unitframes"].showPower) and (self.powerValue) then
		self.powerValue:Show()
	elseif self.powerValue then
		self.powerValue:Hide()
	end
	
	if (class == "DRUID") then
		if (self.EclipseBar) then
			if (GUIS_DB["unitframes"].showPower) then
				self.EclipseBar.Text:Show()
			else
				self.EclipseBar.Text:Hide()
			end
		end
		if (self.DruidMana) then
			if (GUIS_DB["unitframes"].showDruid) then
				self.DruidMana:Show()
			else
				self.DruidMana:Hide()
			end
		end
	end
	
	if (self.GUISIndicators) then
		if (GUIS_DB["unitframes"].showGridIndicators) then
			self.GUISIndicators:Show()
		else
			self.GUISIndicators:Hide()
		end
	end
	
	if (self.Auras) and (self.AuraHolder) then
		local safecall = function(self, unit)
			if (self.unit == "player") then
				if (GUIS_DB["unitframes"].showPlayerAuras) then
					self.AuraHolder:Show()
				else
					self.AuraHolder:Hide()
				end
				
			elseif (self.unit == "target") then
				if (GUIS_DB["unitframes"].showTargetAuras) then
					self.AuraHolder:Show()
				else
					self.AuraHolder:Hide()
				end
				
			end
		end
		F.SafeCall(safecall, self, unit)
	end

	do
		local self, unit = self, unit
		F.SafeCall(F.PostUpdateFocusMacro, self, unit)
	end
end

F.AllFrames = function(self, unit)
	-- store our frames in a global table
	local UnitFrames = LibStub("gCore-3.0"):GetModule("GUIS-gUI: UnitFrames")
	UnitFrames._UNITS = UnitFrames._UNITS or {}
	UnitFrames._UNITS[self:GetName()] = self
	
	-- clicks and hoverscripts
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	
	-- set the focus macros
	-- party/raid do this in their secure headers
	if (not strfind(unit, "party")) and (not strfind(unit, "raid")) then
		F.PostUpdateFocusMacro(self, unit)
	end

	-- right-click menu
	self.menu = F.UnitFrameMenu
	
	-- colors
	self.colors = C["oUF"]

	--
	-- Frame borders and shadows
	self.FrameBorder = self:SetUITemplate("backdrop")

	--
	-- Threat
	-- Yeah, a little hackish. Deal with it.
	self.Threat = {
		Hide = noop;
		IsObjectType = noop;
		Override = F.ThreatOverride;
	}
end

