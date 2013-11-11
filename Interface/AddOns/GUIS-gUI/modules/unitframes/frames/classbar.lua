--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local oUF = ns.oUF or oUF 

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UnitFramesClassBar")

-- Lua API
local gsub, strupper, tag = string.gsub, string.upper, string.tag
local pairs, select, unpack = pairs, select, unpack

local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) module:RegisterCallback(...) end

local class = (select(2, UnitClass("player")))

local _STATE
local GetState, SetState, OldState

local Shared

local settings = {
	["pos"] = { "BOTTOM", UIParent, "BOTTOM", 0, 300 };
	["size"] = { 210, 16 }; -- 260, 16 originally, but smaller looks better
}

local new = function(self)
	local frame = CreateFrame("Frame", nil, self)
	frame:SetSize(self:GetSize())
	frame:SetPoint("CENTER", self, "CENTER", 0, 0)
	
	return frame
end

local getSize = function(object, num)
	return (object:GetWidth() - (num - 1) * 1) / num, object:GetHeight()
end

Shared = function(self, unit)
	self.colors = C["oUF"]
	
	self:SetFrameStrata("LOW")
	self:SetFrameLevel(5)
	
	-- make sure this frame doesn't react to hover or clicks
	self:RegisterForClicks()
	self:EnableMouse(false)

	self:SetSize(unpack(settings.size))

	--------------------------------------------------------------------------------------------------
	--		ComboPoints
	--------------------------------------------------------------------------------------------------
	local CPoints = new(self)
	for i = 1, MAX_COMBO_POINTS do
		local CPoint = CreateFrame("Frame", nil, CPoints)
		CPoint:SetSize(getSize(CPoints, MAX_COMBO_POINTS))
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
			CPoint:SetPoint("TOPLEFT", CPoints, "TOPLEFT", 0, 0)
			
		elseif (i == MAX_COMBO_POINTS) then
			CPoint:SetPoint("LEFT", CPoints[i - 1], "RIGHT", 1, 0)
			CPoint:SetPoint("BOTTOMRIGHT", CPoints, "BOTTOMRIGHT", 0, 0)
			
		else
			CPoint:SetPoint("LEFT", CPoints[i - 1], "RIGHT", 1, 0)
		end

		F.GlossAndShade(CPoint)
		
		CPoints[i] = CPoint
	end
	self.CPoints = CPoints

	local overlay = F.Shine:New(CPoints)
	overlay:SetAllPoints(CPoints)
	CPoints[MAX_COMBO_POINTS].overlay = overlay

	CPoints[MAX_COMBO_POINTS]:SetScript("OnShow", function(self) self.overlay:Start() end)
	CPoints[MAX_COMBO_POINTS]:SetScript("OnHide", function(self) self.overlay:Hide() end)

	--------------------------------------------------------------------------------------------------
	--		RuneBar
	--------------------------------------------------------------------------------------------------
	if (class == "DEATHKNIGHT") then
		local Runes = new(self)
		
		for i = 1, 6 do
			Runes[i] = CreateFrame("StatusBar", nil, Runes)
			Runes[i]:SetSize(getSize(Runes, 6))
			Runes[i]:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
			Runes[i]:CreateUIShadow()
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

			local overlay = F.Shine:New(Runes[i])
			overlay:SetAllPoints(Runes[i])
			Runes[i].overlay = overlay
			
			-- hotfix for MoP oUF version
			Runes[i]:SetID(i)
			
			hooksecurefunc(Runes[i], "SetValue", function(self) 
				local start, duration, runeReady = GetRuneCooldown(self:GetID())

				if (self.oldValue) and (runeReady) then
					self.overlay:Start() 
					self.oldValue = nil
				end
				
				if not(runeReady) then
					self.oldValue = self:GetValue()
				end

			end)
			Runes[i]:SetScript("OnHide", function(self) self.overlay:Hide() end)
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
		local EclipseBar = new(self)
		EclipseBar:SetUITemplate("border")
		
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
		
		EclipseBar.SolarBar.overlay = F.Shine:New(EclipseBar)
		EclipseBar.SolarBar:SetScript("OnHide", function(self) self.overlay:Hide() end)
		hooksecurefunc(EclipseBar.SolarBar, "SetValue", function(self, value) 
			local min, max = self:GetMinMaxValues()
			
			if (value == min) or (value == max) then
				if not(self.oldValue) then
					self.overlay:Start() 
					self.oldValue = value
				end
			else
				self.oldValue = nil
				self.overlay:Hide()
			end
		end)

		EclipseBar.Text = EclipseBar.SolarBar:CreateFontString()
		EclipseBar.Text:SetFontObject(GUIS_NumberFontNormal)
		EclipseBar.Text:SetPoint("CENTER", self, "CENTER", 0, 0)
		EclipseBar.Text:SetTextColor(1, 1, 1, 1)
		
		self:Tag(EclipseBar.Text, "[pereclipse]%")
		
		self.EclipseBar = EclipseBar
	end

	--------------------------------------------------------------------------------------------------
	--		SoulShards
	--------------------------------------------------------------------------------------------------
	if (class == "WARLOCK") then
		local SoulShards = new(self)

		for i = 1, SHARD_BAR_NUM_SHARDS do
			SoulShards[i] = CreateFrame("StatusBar", nil, SoulShards)
			SoulShards[i]:SetSize(getSize(SoulShards, SHARD_BAR_NUM_SHARDS))
			SoulShards[i]:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
			SoulShards[i]:SetStatusBarColor(0.86 * 0.85, 0.44 * 0.85, 1 * 0.85, 1)
			SoulShards[i]:CreateUIShadow()
			
			SoulShards[i].overlay = F.Shine:New(SoulShards[i])
			SoulShards[i]:SetScript("OnShow", function(self) self.overlay:Start() end)
			SoulShards[i]:SetScript("OnHide", function(self) self.overlay:Hide() end)
			hooksecurefunc(SoulShards[i], "SetAlpha", function(self, alpha) 
				if (alpha == 1) then
					if not(self.oldalpha) then
						self.overlay:Start() 
						self.oldalpha = 1
					end
				else
					self.oldalpha = nil
					self.overlay:Hide()
				end
			end)
			
			F.GlossAndShade(SoulShards[i])

			SoulShards[i].bg = SoulShards[i]:CreateTexture(nil, "BORDER")
			SoulShards[i].bg:SetTexture(M["StatusBar"]["StatusBar"])
			SoulShards[i].bg:SetPoint("TOP", SoulShards[i], "TOP", 0, 1)
			SoulShards[i].bg:SetPoint("BOTTOM", SoulShards[i], "BOTTOM", 0, 0)
			SoulShards[i].bg:SetPoint("RIGHT", SoulShards[i], "RIGHT", 1, 0)
			SoulShards[i].bg:SetPoint("LEFT", SoulShards[i], "LEFT", -1, 0)
			SoulShards[i].bg:SetVertexColor(0, 0, 0, 1)

			if (i == 1) then
				SoulShards[i]:SetPoint("TOPLEFT", SoulShards, "TOPLEFT", 0, 0)
			elseif (i == SHARD_BAR_NUM_SHARDS) then
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
		local HolyPower = new(self)

		for i = 1, MAX_HOLY_POWER do
			HolyPower[i] = CreateFrame("StatusBar", nil, HolyPower)
			HolyPower[i]:SetSize(getSize(HolyPower, MAX_HOLY_POWER))
			HolyPower[i]:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
			HolyPower[i]:SetStatusBarColor(1.00 * 0.85, 0.95 * 0.85, 0.33 * 0.85, 1)
			HolyPower[i]:CreateUIShadow()

			HolyPower[i].overlay = F.Shine:New(HolyPower[i])
			HolyPower[i]:SetScript("OnShow", function(self) self.overlay:Start() end)
			HolyPower[i]:SetScript("OnHide", function(self) self.overlay:Hide() end)
			hooksecurefunc(HolyPower[i], "SetAlpha", function(self, alpha) 
				if (alpha == 1) then
					if not(self.oldalpha) then
						self.overlay:Start() 
						self.oldalpha = 1
					end
				else
					self.oldalpha = nil
					self.overlay:Hide()
				end
			end)

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
	--		Totem Bar
	--------------------------------------------------------------------------------------------------
	if (class == "SHAMAN") then
		local TotemTimers = {} 
		local multi, i, totem
		local padding = (F.kill("GUIS-gUI: ActionButtons")) and 0 or 3
		for i = 1, MAX_TOTEMS do
			multi = _G["MultiCastSlotButton" .. i]
			totem = CreateFrame("Cooldown", "GUIS_TotemTimers" .. i, multi)
			totem:SetPoint("TOPLEFT", multi, "TOPLEFT", padding, -padding)
			totem:SetPoint("BOTTOMRIGHT", multi, "BOTTOMRIGHT", -padding, padding)
			totem:SetFrameLevel(multi:GetFrameLevel() + 1)
			
			TotemTimers[i] = totem
		end
		
		local SetCooldown = function(totem, startTime, duration)
			local button = _G["MultiCastSlotButton" .. totem]
			if (button) then
				local id = button:GetID()
				if (id) and (TotemTimers[id]) then
					if not(duration) or not(startTime) or (duration == 0) then
						startTime = 0
						duration = 0
					end
					TotemTimers[id]:SetCooldown(startTime, duration)
				end
			end
		end
		
		local updateTotem = function(totem)
			if not(totem) then
				return
			end 
			
			local haveTotem, totemName, startTime, duration, icon = GetTotemInfo(totem)
       	if (duration == 0) or not(totemName) or (totemName == "") then
				SetCooldown(totem, 0, 0)
			else
				SetCooldown(totem, startTime, duration)
			end
		end
		
		local updateTotems = function(self, event, totem)
			if (event == "PLAYER_TOTEM_UPDATE") then
				updateTotem(totem)
			else
				for i = 1, MAX_TOTEMS do
					updateTotem(i)
				end
			end
		end
		
		RegisterCallback("PLAYER_ENTERING_WORLD", updateTotems)
		RegisterCallback("PLAYER_TOTEM_UPDATE", updateTotems)
--		RegisterCallback("UPDATE_MULTI_CAST_ACTIONBAR", updateTotems) -- ?
		
		self.TotemTimers = TotemTimers
	end
	
end

do
	local state = {
		[1] = "[combat] show; hide";
		[2] = "show";
		[3] = "hide";
	}
	GetState = function()
		if (GUIS_DB["unitframes"].showExtraClassBar) then
			if (GUIS_DB["unitframes"].showExtraClassBarAlways) then
				return state[2]
			else
				return state[1]
			end
		else
			return state[3]
		end
	end
	local setState = function()
		-- retrieve the new state from saved settings
		local NewState = GetState()
		
		-- just abort if no actual change occurred
		if (OldState == NewState) then
			return
		end
		
		OldState = NewState
	
		UnregisterStateDriver(_STATE, "visibility")
		RegisterStateDriver(_STATE, "visibility", NewState)
	end
	SetState = function()
		-- do a safecall to avoid combat taint
		F.SafeCall(setState)
	end
end

module.UpdateAll = function(self)
	SetState()
end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UnitFrames")) then 
		self:Kill()
		return 
	end
	
	-- create the statebar
	_STATE = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")

	-- save the initial state, and apply it
	OldState = GetState()
	RegisterStateDriver(_STATE, "visibility", OldState)

	oUF:RegisterStyle(addon .. "Classbar", Shared)
	oUF:Factory(function(self)
		self:SetActiveStyle(addon .. "Classbar")

		local cbar = self:Spawn("player")
		cbar:SetParent(_STATE)
		cbar:PlaceAndSave(unpack(settings.pos))
	end)

end


