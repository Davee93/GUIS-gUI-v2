--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local oUF = ns.oUF or oUF 

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UnitFramesParty")

-- Lua API
local setmetatable, rawget = setmetatable, rawget
local unpack, select, tinsert = unpack, select, table.insert

local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local gFH = LibStub:GetLibrary("gFrameHandler-1.0")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end

local party
local Shared
local TargetUpdate, LFDRoleOverride

local settings = {
	-- only for testing
	["showSolo"] = false;
	["frame"] = {
		pos = { "TOPLEFT", "UIParent", "TOPLEFT", 12, -250 };
		size = { 120 + 12 + 40, 16 };
		portraitsize = { 30, 30 };
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
	["default"] = "[guis:leader][guis:masterlooter][guis:maintank][guis:mainassist]";
}
setmetatable(iconList, { __index = function(t, i) return rawget(t, i) or rawget(t, "default") end })

-- color portrait borders according to LFDRole
LFDRoleOverride = function(self, event)
	if (not self.LFDRole) then return end

	local role = UnitGroupRolesAssigned(self.unit)
	if (not role) then return end

	if (role == "TANK") then
		self.LFDRole:SetBackdropBorderColor(unpack(C["role"]["tank"]))
		
	elseif (role == "HEALER") then
		self.LFDRole:SetBackdropBorderColor(unpack(C["role"]["heal"]))
		
--	elseif (role == "DAMAGER") then
--		self.LFDRole:SetBackdropBorderColor(unpack(C["role"]["dps"]))
		
	else
		self.LFDRole:SetBackdropBorderColor(unpack(C["border"]))
		
	end
end

--------------------------------------------------------------------------------------------------
--		Shared Frame Styles
--------------------------------------------------------------------------------------------------
Shared = function(self, unit)
	F.AllFrames(self, unit)
	F.CreateTargetBorder(self, unit)
	
	local hBuffer = settings.frame.portraitsize[1] + 12
	local vBuffer = settings.frame.portraitsize[2] - settings.frame.size[2]
	
	F.SafeCall(self.SetHitRectInsets, self, 0, 0, 0, -vBuffer)
	
	-- create a larger clickable area for healers
--	self:SetHitRectInsets(- (settings.frame.portraitsize[1] + 12), 0, - (settings.frame.portraitsize[2] - settings.frame.size[2]), 0)
--	self:SetHitRectInsets(0, 0, 0, -vBuffer)
	
	--------------------------------------------------------------------------------------------------
	--		Health
	--------------------------------------------------------------------------------------------------
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOP", self, "TOP", 0, -vBuffer)
	Health:SetPoint("BOTTOM", self, "BOTTOM", 0, -vBuffer)
	Health:SetPoint("LEFT", self, "LEFT", hBuffer, 0)
	Health:SetPoint("RIGHT", self, "RIGHT", 0, 0)
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
	
	self.FrameBorder:ClearAllPoints()
	self.FrameBorder:SetPoint("TOPLEFT", Health, "TOPLEFT", -3, 3)
	self.FrameBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 3, -(3 + vBuffer))
	
	self.TargetBorder:ClearAllPoints()
	self.TargetBorder:SetPoint("TOPLEFT", Health, "TOPLEFT", -5, 5)
	self.TargetBorder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 5, -(5 + vBuffer))

	HealthBackground.multiplier = 1/3

	self.Health = Health
	self.Health.bg = HealthBackground

	--------------------------------------------------------------------------------------------------
	--		Heal Prediction
	--------------------------------------------------------------------------------------------------
	local myBar = CreateFrame("StatusBar", nil, self.Health)
	myBar:SetPoint("TOPLEFT", self.Health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	myBar:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	myBar:SetWidth(self:GetWidth())
	myBar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	myBar:SetStatusBarColor(0, 1, 0.5, 0.25)

	local otherBar = CreateFrame("StatusBar", nil, self.Health)
	otherBar:SetPoint("TOPLEFT", myBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	otherBar:SetPoint("BOTTOMLEFT", myBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	otherBar:SetWidth(self:GetWidth())
	otherBar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	otherBar:SetStatusBarColor(0, 1, 0, 0.25)

	self.HealPrediction = {
		myBar = myBar;
		otherBar = otherBar;
		maxOverflow = 1;
	}

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
	Name:SetJustifyH("LEFT")
	Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", -5, 5)

	self:Tag(Name, "[guis:grouprole][guis:name]")

	self.Name = Name
	
	local healthValue = InfoFrame:CreateFontString()
	healthValue:SetFontObject(GUIS_NumberFontNormal)
	healthValue:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 5, 5)
	healthValue:SetJustifyH("RIGHT")
	healthValue.frequentUpdates = 1/4

	self:Tag(healthValue, "[guis:health]")
	
	self.healthValue = healthValue
	
	--------------------------------------------------------------------------------------------------
	--		Power
	--------------------------------------------------------------------------------------------------
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetHeight(settings.frame.powerbarsize)
	Power:SetPoint("BOTTOM", self, "BOTTOM", 0, -vBuffer)
	Power:SetPoint("LEFT", self, "LEFT", hBuffer, 0)
	Power:SetPoint("RIGHT", self, "RIGHT", 0, 0)
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
	--		Portrait
	--------------------------------------------------------------------------------------------------
	local PortraitHolder = CreateFrame("Frame", nil, self)
	PortraitHolder:SetSize(unpack(settings.frame.portraitsize))
	PortraitHolder:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)

	-- we color the bordor of the portraits to indicate role
	self.LFDRole = PortraitHolder:SetUITemplate("backdrop")
	self.LFDRole.Override = LFDRoleOverride

	local Portrait = CreateFrame("PlayerModel", nil, PortraitHolder)
	Portrait:SetAllPoints(PortraitHolder)
	Portrait:SetAlpha(1)
	
	Portrait.Shade = Portrait:CreateTexture(nil, "OVERLAY")
	Portrait.Shade:SetTexture(0, 0, 0, 1/2)
	Portrait.Shade:SetAllPoints(Portrait)
	
	Portrait.Overlay = Portrait:CreateTexture(nil, "OVERLAY")
	Portrait.Overlay:SetTexture(M["Background"]["UnitShader"])
	Portrait.Overlay:SetVertexColor(0, 0, 0, 1)
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
	IconStack:SetJustifyH("LEFT")
	IconStack:SetJustifyV("TOP")
	IconStack:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", 0, (select(2, IconStack:GetFont())) - 2)
	
	self.IconStack = IconStack

	self:Tag(self.IconStack, iconList[unit])
	
	--------------------------------------------------------------------------------------------------
	--		CombatFeedback
	--------------------------------------------------------------------------------------------------
	local CombatFeedbackText = self.InfoFrame:CreateFontString()
	CombatFeedbackText:SetFontObject(GUIS_NumberFontHuge)
	CombatFeedbackText:SetPoint("CENTER", self.Health)
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
	
	--------------------------------------------------------------------------------------------------
	--		Grid Indicators
	--------------------------------------------------------------------------------------------------
	local GUISIndicators = CreateFrame("Frame", nil, self.InfoFrame) -- using the InfoFrame to get them top level
	GUISIndicators:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 0, 0)
	GUISIndicators:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)

	GUISIndicators.fontObject = GUIS_UnitFrameNumberSmall
	GUISIndicators.width = settings.frame.size[2]
	GUISIndicators.indicatorSize = 6
	GUISIndicators.symbolSize = 8
	GUISIndicators.frequentUpdates = 1/4
	
	self.GUISIndicators = GUISIndicators

	--------------------------------------------------------------------------------------------------
	--		Auras
	--------------------------------------------------------------------------------------------------
	local Auras = CreateFrame("Frame", nil, self)
	Auras:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 8, -(3 + vBuffer))
	Auras:SetSize(settings.aura.width * settings.aura.size + (settings.aura.width - 1) * settings.aura.gap, settings.aura.height * settings.aura.size + (settings.aura.height - 1) * settings.aura.gap)
	Auras.size = settings.aura.size
	Auras.spacing = settings.aura.gap

	Auras.initialAnchor = "BOTTOMLEFT"
	Auras["growth-y"] = "UP"
	Auras["growth-x"] = "RIGHT"
	Auras.onlyShowPlayer = false
	
	Auras.buffFilter = "HELPFUL RAID PLAYER"
	Auras.debuffFilter = "HARMFUL"

	Auras.PostUpdateIcon = F.PostUpdateAura
	Auras.PostCreateIcon = F.PostCreateAura

	self.Auras = Auras

	F.PostUpdateOptions(self, unit)
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName("GUIS-gUI: UnitFrames"))
end

module.UpdateAll = function(self)
	local safecall = function()
		if (GUIS_DB["unitframes"].showPlayer) then
			party:SetAttribute("showPlayer", true)
		else
			party:SetAttribute("showPlayer", nil)
		end

		F.updateAllVisibility()
	end
	F.SafeCall(safecall)
end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UnitFrames")) or (F.kill(self:GetName())) or (not GUIS_DB["unitframes"]["loadpartyframes"]) then 
		self:Kill()
		return 
	end

	oUF:RegisterStyle(addon.."Party", Shared)
	oUF:Factory(function(self)
		self:SetActiveStyle(addon.."Party")

		party = self:SpawnHeader("GUIS_Party", nil, 
			settings.showSolo and "solo" or F.GetHeaderVisibility("party"), 
			"oUF-initialConfigFunction", ([[
				self:SetWidth(%d)
				self:SetHeight(%d)
				self:SetFrameStrata("LOW")
				%s
			]]):format(settings.frame.size[1], settings.frame.size[2], 
			F.GetFocusMacroString()), 
			"showPlayer", GUIS_DB["unitframes"].showPlayer, 
			"showSolo", settings.showSolo, 
			"showRaid", true, 
			"showParty", true, 
			"yOffset", -(12 + settings.frame.portraitsize[2])
		)
		party:SetSize(settings.frame.size[1], settings.frame.portraitsize[2]*5 + 12*4)

		local a, b, c, d, e = unpack(settings.frame.pos)
		party:PlaceAndSave(a, b, c, d, e - F.GetGroupSpacing())
	end)
	
	CreateChatCommand(function() 
		if not(InCombatLockdown()) then
			GUIS_DB["unitframes"].showPlayer = true 
			module:UpdateAll()
			module:PostUpdateGUI()
		else
			print(L["UnitFrames cannot be configured while engaged in combat"])
		end
	end, "enableplayerinparty")

	CreateChatCommand(function() 
		if not(InCombatLockdown()) then
			GUIS_DB["unitframes"].showPlayer = false 
			module:UpdateAll()
			module:PostUpdateGUI()
		else
			print(L["UnitFrames cannot be configured while engaged in combat"])
		end
	end, "disableplayerinparty")
	
end