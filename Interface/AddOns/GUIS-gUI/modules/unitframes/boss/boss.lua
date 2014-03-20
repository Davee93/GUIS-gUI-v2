--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local oUF = ns.oUF or oUF 

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UnitFramesBoss")

-- Lua API
local setmetatable, rawget = setmetatable, rawget
local unpack, select, tinsert = unpack, select, table.insert

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local gFH = LibStub:GetLibrary("gFrameHandler-1.0")

local Shared

local settings = {
	["frame"] = {
		pos = { "CENTER", "UIParent", "CENTER", 400, -120 };
		size = { 180, 16 };
		portraitsize = { 40, 40 };
		powerbarsize = 4;
		iconsize = 16;
	};

	["aura"] = {
		size = 20;
		gap = 4;
		height = 2;
		width = 6;
	};
}	

local iconList = {
	["default"] = "[guis:quest]";
}
setmetatable(iconList, { __index = function(t, i) return rawget(t, i) or rawget(t, "default") end })


--------------------------------------------------------------------------------------------------
--		Shared Frame Styles
--------------------------------------------------------------------------------------------------
Shared = function(self, unit)
	F.AllFrames(self, unit)
	F.CreateTargetBorder(self, unit)
	
	-- create a larger clickable area for healers
--	self:SetHitRectInsets(0, -(settings.frame.portraitsize[1] + 12), -(settings.frame.portraitsize[2] - settings.frame.size[2]), 0)
	
	--------------------------------------------------------------------------------------------------
	--		Health
	--------------------------------------------------------------------------------------------------
	local Health = F.ReverseBar(self)
	Health:SetPoint("TOP", 0, 0)
	Health:SetPoint("BOTTOM", 0, 0)
	Health:SetPoint("LEFT", 0, 0)
	Health:SetPoint("RIGHT", 0, 0)
	Health:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	F.GlossAndShade(Health)

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
	--		Texts and Values
	--------------------------------------------------------------------------------------------------
	local InfoFrame = CreateFrame("Frame", nil, self)
	InfoFrame:SetFrameLevel(30)
	
	self.InfoFrame = InfoFrame

	local Name = InfoFrame:CreateFontString()
	Name:SetFontObject(GUIS_UnitFrameNameNormal)
	Name:SetTextColor(1, 1, 1)
	Name:SetSize(settings.frame.size[1] - 40, (select(2, Name:GetFont())))
	Name:SetJustifyH("RIGHT")
	Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 8)

	self:Tag(Name, "[guis:name]")

	self.Name = Name
	
	local healthValue = InfoFrame:CreateFontString()
	healthValue:SetFontObject(GUIS_NumberFontNormal)
	healthValue:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 8)
	healthValue:SetJustifyH("LEFT")
	healthValue.frequentUpdates = 1/4

	self:Tag(healthValue, "[guis:health]")
	
	self.healthValue = healthValue
	
	--------------------------------------------------------------------------------------------------
	--		Power
	--------------------------------------------------------------------------------------------------
	local Power = F.ReverseBar(self)
	Power:SetHeight(settings.frame.powerbarsize)
	Power:SetPoint("BOTTOM", 0, 0)
	Power:SetPoint("LEFT", 0, 0)
	Power:SetPoint("RIGHT", 0, 0)
	Power:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	Power:SetFrameLevel(15)
	F.GlossAndShade(Power)

	Health:SetPoint("BOTTOM", Power, "TOP", 0, 1)

	local PowerBackground = Power:CreateTexture(nil, "BACKGROUND")
	PowerBackground:SetAllPoints(Power)
	PowerBackground:SetTexture(M["StatusBar"]["StatusBar"])

	local PowerTopLine = Power:CreateTexture(nil, "OVERLAY")
	PowerTopLine:SetPoint("LEFT", Power)
	PowerTopLine:SetPoint("RIGHT", Power)
	PowerTopLine:SetPoint("BOTTOM", Power, "TOP")
	PowerTopLine:SetHeight(1)
	PowerTopLine:SetTexture(unpack(C["background"]))

	Power.frequentUpdates = 1/4
	Power.colorTapping = true
	Power.colorDisconnected = true
	Power.colorPower = true
	Power.colorClass = true
	Power.colorReaction = true
	Power.Smooth = true

	PowerBackground.multiplier = 1/3

	self.Power = Power
	self.Power.bg = PowerBackground

	--------------------------------------------------------------------------------------------------
	--		Alternate Power
	--------------------------------------------------------------------------------------------------
	local AltPowerBar = CreateFrame("StatusBar", self:GetName() .. "AltPowerBar", self.Health)
	AltPowerBar:SetFrameStrata("LOW")
	AltPowerBar:SetFrameLevel(5)
	AltPowerBar:SetHeight(settings.frame.powerbarsize)
	AltPowerBar:SetPoint("LEFT", self.Health, "TOPLEFT", 5, 1)
	AltPowerBar:SetPoint("RIGHT", self.Health, "TOPRIGHT", -5, 1)
	AltPowerBar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	AltPowerBar:GetStatusBarTexture():SetHorizTile(false)
	AltPowerBar:SetStatusBarColor(163/255,  24/255,  24/255)
	AltPowerBar:EnableMouse(true)
	F.GlossAndShade(AltPowerBar)

	local AltPowerBackground = AltPowerBar:CreateTexture(nil, "BACKGROUND")
	AltPowerBackground:SetAllPoints(AltPowerBar)
	AltPowerBackground:SetTexture(M["StatusBar"]["StatusBar"])
	AltPowerBackground:SetVertexColor(163/255/3,  24/255/3,  24/255/3)

	local AltPowerTopLine = AltPowerBar:CreateTexture(nil, "OVERLAY")
	AltPowerTopLine:SetPoint("LEFT", AltPowerBar)
	AltPowerTopLine:SetPoint("RIGHT", AltPowerBar)
	AltPowerTopLine:SetPoint("BOTTOM", AltPowerBar, "TOP")
	AltPowerTopLine:SetHeight(1)
	AltPowerTopLine:SetTexture(unpack(C["background"]))

	local AltPowerValue = AltPowerBar:CreateFontString()
	AltPowerValue:SetFontObject(GUIS_NumberFontNormal)
	AltPowerValue:ClearAllPoints()
	AltPowerValue:SetPoint("CENTER", AltPowerBar, "CENTER", 0, 0)
	AltPowerValue:SetJustifyH("CENTER")
	AltPowerValue.frequentUpdates = 1/4

	self:Tag(AltPowerValue, "[guis:altpower]")

	self.AltPowerValue = AltPowerValue
	self.AltPowerBar = AltPowerBar
	
	--------------------------------------------------------------------------------------------------
	--		Portrait
	--------------------------------------------------------------------------------------------------
	local PortraitHolder = CreateFrame("Frame", nil, self)
	PortraitHolder:SetSize(unpack(settings.frame.portraitsize))
	PortraitHolder:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 12, 0)

	PortraitHolder.Border = PortraitHolder:SetUITemplate("backdrop")

	local Portrait = CreateFrame("PlayerModel", nil, PortraitHolder)
	Portrait:SetAllPoints(PortraitHolder)
	Portrait:SetAlpha(2/4)
	
	Portrait.Overlay = Portrait:CreateTexture(nil, "OVERLAY")
	Portrait.Overlay:SetTexture(M["Background"]["UnitShader"])
	Portrait.Overlay:SetVertexColor(0, 0, 0, 3/4)
	Portrait.Overlay:SetAllPoints(Portrait)

	self.Portrait = Portrait
	self.Portrait.PostUpdate = F.PostUpdatePortrait		
	
	tinsert(self.__elements, F.HidePortrait)
	
	--------------------------------------------------------------------------------------------------
	--		Icons
	--------------------------------------------------------------------------------------------------
	local IconFrame = CreateFrame("Frame", nil, self)
	IconFrame:SetFrameLevel(25)

	self.IconFrame = IconFrame

	local RaidIcon = IconFrame:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetSize(settings.frame.iconsize, settings.frame.iconsize)
	RaidIcon:SetPoint("CENTER", self.Health, "TOP", 0, 4)
	RaidIcon:SetTexture(M["Icon"]["RaidTarget"])

	self.RaidIcon = RaidIcon

	local IconStack = IconFrame:CreateFontString()
	IconStack:SetFontObject(GUIS_NumberFontSmall)
	IconStack:SetTextColor(1, 1, 1)
	IconStack:SetJustifyH("RIGHT")
	IconStack:SetJustifyV("TOP")
	IconStack:SetPoint("TOPRIGHT", self.Portrait, "TOPRIGHT", 0, (select(2, IconStack:GetFont())) - 2)
	
	self.IconStack = IconStack

	self:Tag(self.IconStack, iconList[unit])
	
	--------------------------------------------------------------------------------------------------
	--		CombatFeedback
	--------------------------------------------------------------------------------------------------
	local CombatFeedbackText = self.InfoFrame:CreateFontString()
	CombatFeedbackText:SetFontObject(GUIS_NumberFontHuge)
	CombatFeedbackText:SetPoint("CENTER", Health)
	CombatFeedbackText.colors = C["feedbackcolors"]
		
	self.CombatFeedbackText = CombatFeedbackText
	
	--------------------------------------------------------------------------------------------------
	--		Range
	--------------------------------------------------------------------------------------------------
	local Range = {
		insideAlpha = 1.0;
		outsideAlpha = 0.3;
	}
	self.Range = Range

	F.PostUpdateOptions(self, unit)
end

module.UpdateAll = function(self)
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName("GUIS-gUI: UnitFrames"))
end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UnitFrames")) or (not GUIS_DB["unitframes"]["loadbossframes"]) then 
		self:Kill()
		return 
	end
end

module.OnEnable = function(self)
	oUF:RegisterStyle(addon.."Boss", Shared)
	oUF:Factory(function(self)

		self:SetActiveStyle(addon .. "Boss")
		
		local boss = CreateFrame("Frame", "GUIS_Boss", UIParent)
		boss:SetSize((settings.frame.size[1] + settings.frame.portraitsize[1] + 12), settings.frame.portraitsize[2]*5 + 12*4)

		local f, g, h, i, j = gFH:GetSavedPosition(boss)
		boss:PlaceAndSave(unpack(settings.frame.pos))

		for i = 1, MAX_BOSS_FRAMES do
			boss[i] = oUF:Spawn("boss" .. i, "Boss" .. i)

			if (i == 1) then
				boss[i]:SetPoint("TOPLEFT", boss, "TOPLEFT", 0, -(settings.frame.portraitsize[2] - settings.frame.size[2]))
			else
				boss[i]:SetPoint("BOTTOM", boss[i - 1], "BOTTOM", 0, (12 + settings.frame.portraitsize[2])) 
			end

			boss[i]:SetSize(unpack(settings.frame.size))
		end
	end)
end
