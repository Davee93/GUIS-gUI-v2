--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local oUF = ns.oUF or oUF 

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UnitFramesRaid")

-- Lua API
local _G = _G
local setmetatable, rawget = setmetatable, rawget
local unpack, select, tinsert = unpack, select, table.insert
local tonumber = tonumber
local strsplit = string.split

-- WoW API
local CreateFrame = CreateFrame

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local R = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: UnitFrameAuras")
local raid = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: UnitFrameRaidGroups")
local gFH = LibStub:GetLibrary("gFrameHandler-1.0")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) module:RegisterCallback(...) end
local RegisterBucketEvent = function(...) module:RegisterBucketEvent(...) end

local Shared, HideBlizzard
local Raid10, Raid15, Raid25, Raid40, Raid40Small

local class = (select(2, UnitClass("player")))

local settings = {
	-- using this for 10-15. this is the slim narrow format
	["raid10"] = {
		pos 					= { "TOPLEFT", "UIParent", "TOPLEFT", 12, -250 }; -- default Y position modified by screenheight
		size 					= { 160, 16 };
		powerbarsize 		= 2;
		iconsize 			= 12;
		aura = { 
			size 				= 16;
			gap 				= 4;
			height 			= 1;
			width 			= 6;
		};
		maxColumns 			= 15;
		unitsPerColumn 	= 1;
		point 				= "LEFT";
		columnAnchorPoint = "TOP";
		groupBy 				= "GROUP";
		groupFilter 		= "1,2,3,4,5,6,7,8";
		groupingOrder 		= "1,2,3,4,5,6,7,8";
		showSolo 			= false;
	};

	-- this is 16-40 for healers
	["raid40"] = {
		pos 					= { "TOPLEFT", "UIParent", "TOPLEFT", 12, -250 }; -- default Y position modified by screenheight
		size 					= { 64, 36 };
		powerbarsize 		= 2;
		iconsize 			= 12;
		maxColumns 			= 8;
		unitsPerColumn 	= 5;
		point 				= "LEFT";
		columnAnchorPoint = "TOP";
		groupBy 				= "GROUP";
		groupFilter 		= "1,2,3,4,5,6,7,8";
		groupingOrder 		= "1,2,3,4,5,6,7,8";
		showSolo 			= false;
	};
	
	-- this is 16-40 tiny DPS layout
	["raid40small"] = {
		pos 					= { "TOPLEFT", "UIParent", "TOPLEFT", 12, -250 }; -- default Y position modified by screenheight
		size 					= { 64, 8 };
		powerbarsize 		= 1;
		iconsize 			= 12;
		maxColumns 			= 2; 
		unitsPerColumn 	= 20;
		columnSpacing 		= 56;
		point 				= "TOP";
		columnAnchorPoint = "LEFT";
		groupBy 				= "GROUP";
		groupFilter 		= "1,2,3,4,5,6,7,8";
		groupingOrder 		= "1,2,3,4,5,6,7,8";
		showSolo 			= false;
	};
}

local iconList = {
	["default"] = "[guis:leader][guis:masterlooter][guis:maintank][guis:mainassist]";
}
setmetatable(iconList, { __index = function(t, i) return rawget(t, i) or rawget(t, "default") end })

--------------------------------------------------------------------------------------------------
--		Shared Frame Styles
--------------------------------------------------------------------------------------------------
Shared = function(self, unit, db)
	F.AllFrames(self, unit)
	F.CreateTargetBorder(self, unit)
	
	--------------------------------------------------------------------------------------------------
	--		Power
	--------------------------------------------------------------------------------------------------
	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetHeight(db.powerbarsize)
	Power:SetPoint("BOTTOM", 0, 0)
	Power:SetPoint("LEFT", 0, 0)
	Power:SetPoint("RIGHT", 0, 0)
	Power:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	F.GlossAndShade(Power)

	local PowerBackground = Power:CreateTexture(nil, "BACKGROUND")
	PowerBackground:SetAllPoints(Power)
	PowerBackground:SetTexture(M["StatusBar"]["StatusBar"])

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
	--		Health
	--------------------------------------------------------------------------------------------------
	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetPoint("TOP", 0, 0)
	Health:SetPoint("BOTTOM", self.Power, "TOP", 0, 1)
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
	--		InfoFrame
	--------------------------------------------------------------------------------------------------
	local InfoFrame = CreateFrame("Frame", nil, self)
	InfoFrame:SetFrameLevel(30)
	
	self.InfoFrame = InfoFrame

	--------------------------------------------------------------------------------------------------
	--		IconFrame
	--------------------------------------------------------------------------------------------------
	local IconFrame = CreateFrame("Frame", nil, self)
	IconFrame:SetFrameLevel(60)

	self.IconFrame = IconFrame

	local RaidIcon = IconFrame:CreateTexture(nil, "OVERLAY")
	RaidIcon:SetSize(db.iconsize, db.iconsize)
	RaidIcon:SetPoint("CENTER", self, "TOP", 0, 0)
	RaidIcon:SetTexture(M["Icon"]["RaidTarget"])

	self.RaidIcon = RaidIcon

	local IconStack = IconFrame:CreateFontString()
	IconStack:SetFontObject(GUIS_NumberFontSmall)
	IconStack:SetTextColor(1, 1, 1)
	IconStack:SetJustifyH("LEFT")
	IconStack:SetJustifyV("TOP")
	IconStack:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0) 
	
	self.IconStack = IconStack

	self:Tag(self.IconStack, iconList[unit])
	
	local ReadyCheck = self.IconFrame:CreateTexture(nil, "OVERLAY")
	ReadyCheck:SetPoint("CENTER", self, "CENTER", 0, 0)
	ReadyCheck:SetSize(16, 16)

	self.ReadyCheck = ReadyCheck

	
	--------------------------------------------------------------------------------------------------
	--		Range
	--------------------------------------------------------------------------------------------------
	local Range = {
		insideAlpha = 1.0;
		outsideAlpha = 0.3;
	}
	self.Range = Range
end

--------------------------------------------------------------------------------------------------
--		Raid10
--------------------------------------------------------------------------------------------------
Raid10 = function(self, unit)
	
	Shared(self, unit, settings.raid10)

	--------------------------------------------------------------------------------------------------
	--		Texts and Values
	--------------------------------------------------------------------------------------------------
	local Name = self.InfoFrame:CreateFontString()
	Name:SetFontObject(GUIS_UnitFrameNameSmall) -- GUIS_UnitFrameNameNormal for old 10p frames
	Name:SetTextColor(1, 1, 1)
	Name:SetSize(self:GetWidth() - 40, (select(2, Name:GetFont())))
	Name:SetJustifyH("LEFT")
	Name:SetPoint("LEFT", self.Health, "LEFT", 3, 0)

	self:Tag(Name, "[guis:grouprole][guis:name]")

	self.Name = Name
	
	local healthValue = self.InfoFrame:CreateFontString()
	healthValue:SetFontObject(GUIS_NumberFontNormal)
	healthValue:SetPoint("RIGHT", self.Health, "RIGHT", -3, 0)
	healthValue:SetJustifyH("RIGHT")
	healthValue.frequentUpdates = 1/4

	self:Tag(healthValue, "[guis:health]")
	
	self.healthValue = healthValue
	
	--------------------------------------------------------------------------------------------------
	--		Auras
	--------------------------------------------------------------------------------------------------
	local AuraHolder = CreateFrame("Frame", nil, self)
	self.AuraHolder = AuraHolder
	
	local Auras = CreateFrame("Frame", nil, self.AuraHolder)
	Auras:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 8, 0)
	Auras:SetSize(settings.raid10.aura.width * settings.raid10.aura.size + (settings.raid10.aura.width - 1) * settings.raid10.aura.gap, settings.raid10.aura.height * settings.raid10.aura.size + (settings.raid10.aura.height - 1) * settings.raid10.aura.gap)
	Auras.size = settings.raid10.aura.size
	Auras.spacing = settings.raid10.aura.gap
	Auras.numDebuffs = settings.raid10.aura.width * settings.raid10.aura.height
	Auras.numBuffs = settings.raid10.aura.width * settings.raid10.aura.height

	Auras.initialAnchor = "BOTTOMLEFT"
	Auras["growth-y"] = "UP"
	Auras["growth-x"] = "RIGHT"
	Auras.onlyShowPlayer = false
	
	Auras.buffFilter = "HELPFUL RAID PLAYER"
	Auras.debuffFilter = "HARMFUL"

	Auras.PostUpdateIcon = F.PostUpdateAura
	Auras.PostCreateIcon = F.PostCreateAura

	self.Auras = Auras

	--------------------------------------------------------------------------------------------------
	--		Raid Debuffs
	--------------------------------------------------------------------------------------------------
	local RaidDebuffs = CreateFrame("Frame", nil, self.InfoFrame)
	local debuffSize = min(unpack(settings.raid10.size)) + 4
	
	RaidDebuffs:SetSize(debuffSize, debuffSize)
	RaidDebuffs:SetPoint("CENTER", self)
	RaidDebuffs:SetUITemplate("simplebackdrop")
	
	RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, "OVERLAY")
	RaidDebuffs.icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
	RaidDebuffs.icon:SetPoint("TOP", RaidDebuffs, 0, -3)
	RaidDebuffs.icon:SetPoint("RIGHT", RaidDebuffs, -3, 0)
	RaidDebuffs.icon:SetPoint("BOTTOM", RaidDebuffs, 0, 3)
	RaidDebuffs.icon:SetPoint("LEFT", RaidDebuffs, 3, 0)
	RaidDebuffs.icon:SetDrawLayer("ARTWORK")

	F.GlossAndShade(RaidDebuffs)
	RaidDebuffs.Gloss:SetAllPoints(RaidDebuffs.icon)
	RaidDebuffs.Shade:SetAllPoints(RaidDebuffs.icon)

	RaidDebuffs.cd = CreateFrame("Cooldown", nil, RaidDebuffs)
	RaidDebuffs.cd:SetAllPoints(RaidDebuffs.icon)

	RaidDebuffs.count = RaidDebuffs:CreateFontString(nil, "OVERLAY")
	RaidDebuffs.count:SetFontObject(GUIS_UnitFrameNumberSmall)
	RaidDebuffs.count:SetPoint("BOTTOMRIGHT", RaidDebuffs, "BOTTOMRIGHT", 2, 0)
	RaidDebuffs.count:SetTextColor(unpack(C["value"]))
	
	-- get debuff coloring by redirecting the original backdrop function to our own
	RaidDebuffs.SetBackdropBorderColor = RaidDebuffs.SetBackdropBorderColor
	
	local PostUpdateRaidDebuffs = function(self, event)
		local button = self.RaidDebuffs
		
		-- we don't want those "1"'s cluttering up the display
		if (button.count) then
			local count = tonumber(button.count:GetText())
			if (count) and (count > 1) then
				f.count:SetText(count)
				f.count:Show()
			else
				f.count:Hide()
			end
		end
	end
	
	self.RaidDebuffs = RaidDebuffs
	self.RaidDebuffs.PostUpdate = PostUpdateRaidDebuffs
	
	--------------------------------------------------------------------------------------------------
	--		Grid Indicators
	--------------------------------------------------------------------------------------------------
	local GUISIndicators = CreateFrame("Frame", nil, self.InfoFrame) -- using the InfoFrame to get them top level
	GUISIndicators:SetPoint("TOPLEFT", self, "TOPLEFT", -4, 4)
	GUISIndicators:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4, -4)

	GUISIndicators.fontObject = GUIS_UnitFrameNumberSmall
	GUISIndicators.width = settings.raid10.size[2]
	GUISIndicators.indicatorSize = 6
	GUISIndicators.symbolSize = 8
	GUISIndicators.frequentUpdates = 1/4
	
	self.GUISIndicators = GUISIndicators

	F.PostUpdateOptions(self, unit)
end

--------------------------------------------------------------------------------------------------
--		Raid40
--------------------------------------------------------------------------------------------------
Raid40 = function(self, unit)
	
	Shared(self, unit, settings.raid40)

	--------------------------------------------------------------------------------------------------
	--		Texts and Values
	--------------------------------------------------------------------------------------------------
	local Name = self.InfoFrame:CreateFontString()
	Name:SetFontObject(GUIS_UnitFrameNameSmall)
	Name:SetTextColor(1, 1, 1)
	Name:SetSize(self:GetWidth() - 16, (select(2, Name:GetFont())))
	Name:SetJustifyH("CENTER")
	Name:SetPoint("TOP", self.Health, "TOP", 0, -5)

	self:Tag(Name, "[guis:nameshort]")

	self.Name = Name
	
	local healthValue = self.InfoFrame:CreateFontString()
	healthValue:SetFontObject(GUIS_NumberFontSmall)
	healthValue:SetPoint("BOTTOM", self.Health, "BOTTOM", 0, 3)
	healthValue.frequentUpdates = 1/4

	self:Tag(healthValue, "[guis:grouprole][guis:healthshort]")
	
	self.healthValue = healthValue

	--------------------------------------------------------------------------------------------------
	--		Raid Debuffs
	--------------------------------------------------------------------------------------------------
	local RaidDebuffs = CreateFrame("Frame", nil, self.InfoFrame)
	local debuffSize = min(unpack(settings.raid40.size)) - 6
	
	RaidDebuffs:SetSize(debuffSize, debuffSize)
	RaidDebuffs:SetPoint("CENTER", self)
	RaidDebuffs:SetUITemplate("simplebackdrop")

	RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, "OVERLAY")
	RaidDebuffs.icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
	RaidDebuffs.icon:SetPoint("TOP", RaidDebuffs, 0, -3)
	RaidDebuffs.icon:SetPoint("RIGHT", RaidDebuffs, -3, 0)
	RaidDebuffs.icon:SetPoint("BOTTOM", RaidDebuffs, 0, 3)
	RaidDebuffs.icon:SetPoint("LEFT", RaidDebuffs, 3, 0)
	RaidDebuffs.icon:SetDrawLayer("ARTWORK")

	F.GlossAndShade(RaidDebuffs)
	RaidDebuffs.Gloss:SetAllPoints(RaidDebuffs.icon)
	RaidDebuffs.Shade:SetAllPoints(RaidDebuffs.icon)

	RaidDebuffs.cd = CreateFrame("Cooldown", nil, RaidDebuffs)
	RaidDebuffs.cd:SetAllPoints(RaidDebuffs.icon)

	RaidDebuffs.count = RaidDebuffs:CreateFontString(nil, "OVERLAY")
	RaidDebuffs.count:SetFontObject(GUIS_UnitFrameNumberSmall)
	RaidDebuffs.count:SetPoint("BOTTOMRIGHT", RaidDebuffs, "BOTTOMRIGHT", 2, 0)
	RaidDebuffs.count:SetTextColor(unpack(C["value"]))
	
	-- get debuff coloring by redirecting the original backdrop function to our own
	RaidDebuffs.SetBackdropBorderColor = RaidDebuffs.SetBackdropBorderColor
	
	local PostUpdateRaidDebuffs = function(self, event)
		local button = self.RaidDebuffs
		
		-- we don't want those "1"'s cluttering up the display
		if (button.count) then
			local count = tonumber(button.count:GetText())
			if (count) and (count > 1) then
				f.count:SetText(count)
				f.count:Show()
			else
				f.count:Hide()
			end
		end
	end
	
	self.RaidDebuffs = RaidDebuffs
	self.RaidDebuffs.PostUpdate = PostUpdateRaidDebuffs

	--------------------------------------------------------------------------------------------------
	--		Grid Indicators
	--------------------------------------------------------------------------------------------------
	local GUISIndicators = CreateFrame("Frame", nil, self.Health)
	GUISIndicators:SetAllPoints(self.Health)

	GUISIndicators.fontObject = GUIS_UnitFrameNumberSmall
	GUISIndicators.width = settings.raid40.size[2]
	GUISIndicators.indicatorSize = 6
	GUISIndicators.symbolSize = 8
	GUISIndicators.frequentUpdates = 1/4
	
	self.GUISIndicators = GUISIndicators
	
	F.PostUpdateOptions(self, unit)
end

Raid40Small = function(self, unit)
	
	Shared(self, unit, settings.raid40small)

	--------------------------------------------------------------------------------------------------
	--		Texts and Values
	--------------------------------------------------------------------------------------------------
	local Name = self.InfoFrame:CreateFontString()
	Name:SetFontObject(GUIS_UnitFrameNameSmall)
	Name:SetTextColor(1, 1, 1)
--	Name:SetSize(self:GetWidth() - 16, (select(2, Name:GetFont())))
	Name:SetJustifyH("LEFT")
	Name:SetPoint("LEFT", self, "RIGHT", 6, 0)

	self:Tag(Name, "[guis:namesmartsize]")

	self.Name = Name
	
	local healthValue = self.InfoFrame:CreateFontString()
	healthValue:SetFontObject(GUIS_NumberFontTiny)
	healthValue:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	healthValue.frequentUpdates = 1/4

	self:Tag(healthValue, "[guis:healthshort]")
	
	self.healthValue = healthValue
	
	-- I don't like this, but it has to be somewhere
	local groupRoleIcon = self.InfoFrame:CreateFontString()
	groupRoleIcon:SetFontObject(GUIS_NumberFontTiny)
	groupRoleIcon:SetPoint("LEFT", self.Health, "LEFT", 2, 0)
	groupRoleIcon.frequentUpdates = 1/4
		
	self:Tag(groupRoleIcon, "[guis:grouprole]")
	
	self.groupRoleIcon = groupRoleIcon

	--------------------------------------------------------------------------------------------------
	--		Raid Debuffs
	--------------------------------------------------------------------------------------------------
	--[[
	local RaidDebuffs = CreateFrame("Frame", nil, self.InfoFrame)
	local debuffSize = min(unpack(settings.raid40.size)) - 6
	
	RaidDebuffs:SetSize(debuffSize, debuffSize)
	RaidDebuffs:SetPoint("CENTER", self)
	RaidDebuffs:SetUITemplate("simplebackdrop")

	RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, "OVERLAY")
	RaidDebuffs.icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
	RaidDebuffs.icon:SetPoint("TOP", RaidDebuffs, 0, -3)
	RaidDebuffs.icon:SetPoint("RIGHT", RaidDebuffs, -3, 0)
	RaidDebuffs.icon:SetPoint("BOTTOM", RaidDebuffs, 0, 3)
	RaidDebuffs.icon:SetPoint("LEFT", RaidDebuffs, 3, 0)
	RaidDebuffs.icon:SetDrawLayer("ARTWORK")

	F.GlossAndShade(RaidDebuffs)
	RaidDebuffs.Gloss:SetAllPoints(RaidDebuffs.icon)
	RaidDebuffs.Shade:SetAllPoints(RaidDebuffs.icon)

	RaidDebuffs.cd = CreateFrame("Cooldown", nil, RaidDebuffs)
	RaidDebuffs.cd:SetAllPoints(RaidDebuffs.icon)

	RaidDebuffs.count = RaidDebuffs:CreateFontString(nil, "OVERLAY")
	RaidDebuffs.count:SetFontObject(GUIS_UnitFrameNumberSmall)
	RaidDebuffs.count:SetPoint("BOTTOMRIGHT", RaidDebuffs, "BOTTOMRIGHT", 2, 0)
	RaidDebuffs.count:SetTextColor(unpack(C["value"]))
	
	-- get debuff coloring by redirecting the original backdrop function to our own
	RaidDebuffs.SetBackdropBorderColor = RaidDebuffs.SetBackdropBorderColor
	
	local PostUpdateRaidDebuffs = function(self, event)
		local button = self.RaidDebuffs
		
		-- we don't want those "1"'s cluttering up the display
		if (button.count) then
			local count = tonumber(button.count:GetText())
			if (count) and (count > 1) then
				f.count:SetText(count)
				f.count:Show()
			else
				f.count:Hide()
			end
		end
	end
	
	self.RaidDebuffs = RaidDebuffs
	self.RaidDebuffs.PostUpdate = PostUpdateRaidDebuffs
	]]--

	--------------------------------------------------------------------------------------------------
	--		Grid Indicators
	--------------------------------------------------------------------------------------------------
	local GUISIndicators = CreateFrame("Frame", nil, self.Health)
	GUISIndicators:SetAllPoints(self.Health)

	GUISIndicators.fontObject = GUIS_UnitFrameNumberSmall
	GUISIndicators.width = settings.raid40small.size[2]
	GUISIndicators.indicatorSize = 6
	GUISIndicators.symbolSize = 8
	GUISIndicators.onlyBuffs = true
	GUISIndicators.frequentUpdates = 1/4
	
	self.GUISIndicators = GUISIndicators
	
	F.PostUpdateOptions(self, unit)
end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName("GUIS-gUI: UnitFrames"))
end

module.UpdateAll = function(self)
	local safecall = function()
		F.updateAllVisibility()
	end
	F.SafeCall(safecall)
end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UnitFrames")) or (F.kill(self:GetName())) or (not GUIS_DB["unitframes"]["loadraidframes"]) then 
		self:Kill()
		return 
	end

	--------------------------------------------------------------------------------------------------
	--		Register our styles with oUF, and spawn the frames
	--------------------------------------------------------------------------------------------------
	local headerData = {}
	local initialConfigFunction = [[
		self:SetWidth(%d)
		self:SetHeight(%d)
		self:SetFrameStrata("LOW")
		%s
	]]
	
	local getHeaderSize = function(i)
		local w, h = unpack(i.size)
		local x, y
		
		if (i.columnAnchorPoint == "TOP") or (i.columnAnchorPoint == "BOTTOM") then
			x = w*i.unitsPerColumn + ( (i.unitsPerColumn-1) * (10) )

			if (i.columnSpacing) then
				y = h*i.maxColumns + (i.maxColumns * i.columnSpacing)
			else
				y = h*i.maxColumns + ((i.maxColumns-1) * 10)
			end
			
		elseif (i.columnAnchorPoint == "LEFT") or (i.columnAnchorPoint == "RIGHT") then
			y = h*i.unitsPerColumn + ((i.unitsPerColumn-1) * 10)
			
			if (i.columnSpacing) then
				x = w*i.maxColumns + (i.maxColumns * i.columnSpacing)
			else
				x = w*i.maxColumns + ((i.maxColumns-1) * 10)
			end
		end

		return x, y
	end

	local getHeaderData = function(db, visibility)
		wipe(headerData)
		
		headerData = {
			db.showSolo and "solo" or F.GetHeaderVisibility(visibility), 
			"oUF-initialConfigFunction", initialConfigFunction:format(db.size[1], db.size[2], F.GetFocusMacroString()), 
			"showRaid", true,
			"showParty", true, 
			"showPlayer", true,	
			"showSolo", db.showSolo, 
			"yOffset", -10, 
			"xoffset", 10, 
			"point", db.point, 
			"groupFilter", db.groupFilter, 
			"groupingOrder", db.groupingOrder, 
			"groupBy", db.groupBy, 
			"maxColumns", db.maxColumns, 
			"unitsPerColumn", db.unitsPerColumn, 
			"columnSpacing", db.columnSpacing or 10, 
			"columnAnchorPoint", db.columnAnchorPoint
		}
		
		return unpack(headerData)
	end
	
	-- 2-15 layout
	oUF:RegisterStyle(addon.."10", Raid10)
	oUF:Factory(function(self)
		self:SetActiveStyle(addon.."10")
		
		raid["10"] = self:SpawnHeader("GUIS_Raid10", nil, getHeaderData(settings.raid10, "raid10"))
		
		local a, b, c, d, e = unpack(settings.raid10.pos)
		raid["10"]:SetSize(getHeaderSize(settings.raid10))
		raid["10"]:PlaceAndSave(a, b, c, d, e - F.GetGroupSpacing())
	end)

	-- 16-40 healer layout
	oUF:RegisterStyle(addon.."40_GRID", Raid40)
	oUF:Factory(function(self)
		self:SetActiveStyle(addon.."40_GRID")
		
		raid["40GRID"] = self:SpawnHeader("GUIS_Raid40", nil, getHeaderData(settings.raid40, "raid40grid"))

		local a, b, c, d, e = unpack(settings.raid40.pos)
		raid["40GRID"]:SetSize(getHeaderSize(settings.raid40))
		raid["40GRID"]:PlaceAndSave(a, b, c, d, e - F.GetGroupSpacing())
	end)
	
	-- 16-40 dps layout
	oUF:RegisterStyle(addon.."40_DPS", Raid40Small)
	oUF:Factory(function(self)
		self:SetActiveStyle(addon.."40_DPS")
		
		raid["40DPS"] = self:SpawnHeader("GUIS_Raid40Small", nil, getHeaderData(settings.raid40small, "raid40dps"))

		local a, b, c, d, e = unpack(settings.raid40small.pos)
		raid["40DPS"]:SetSize(getHeaderSize(settings.raid40small))
		raid["40DPS"]:PlaceAndSave(a, b, c, d, e - F.GetGroupSpacing())
	end)
	
	-- visibility callbacks for groups, 
	-- to automatically select the "right" group based on your spec and settings
	RegisterCallback("PLAYER_ALIVE", function() module:UpdateAll() end)
	RegisterCallback("ACTIVE_TALENT_GROUP_CHANGED", function() module:UpdateAll() end)
	RegisterCallback("PLAYER_TALENT_UPDATE", function() module:UpdateAll() end)
	RegisterCallback("TALENTS_INVOLUNTARILY_RESET", function() module:UpdateAll() end)
	
	--[[
	-- this is just for testing purposes, will use a better system later
	if (F.IsPlayerHealer()) then
		oUF:RegisterStyle(addon.."40", Raid40)
		oUF:Factory(function(self)
			self:SetActiveStyle(addon.."40")
			
			raid[40] = self:SpawnHeader("GUIS_Raid40", nil, getHeaderData(settings.raid40, "raid40"))

			local a, b, c, d, e = unpack(settings.raid40.pos)
			raid[40]:SetSize(getHeaderSize(settings.raid40))
			raid[40]:PlaceAndSave(a, b, c, d, e - F.GetGroupSpacing())
		end)
	else
		oUF:RegisterStyle(addon.."40", Raid40Small)
		oUF:Factory(function(self)
			self:SetActiveStyle(addon.."40")
			
			raid[40] = self:SpawnHeader("GUIS_Raid40Small", nil, getHeaderData(settings.raid40small, "raid40"))

			local a, b, c, d, e = unpack(settings.raid40small.pos)
			raid[40]:SetSize(getHeaderSize(settings.raid40small))
			raid[40]:PlaceAndSave(a, b, c, d, e - F.GetGroupSpacing())
		end)
	end
	]]--
	
	CreateChatCommand(function() 
		if (F.combatAbort()) then return end

		GUIS_DB["unitframes"].showRaidFramesInParty = true
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "enableraidforallgroups")

	CreateChatCommand(function() 
		if (F.combatAbort()) then return end

		GUIS_DB["unitframes"].showRaidFramesInParty = false
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "disableraidforallgroups")
	
	CreateChatCommand(function() 
		if (F.combatAbort()) then return end

		GUIS_DB["unitframes"].showGridFramesAlways = true
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "enablegridforallraidgroups")

	CreateChatCommand(function() 
		if (F.combatAbort()) then return end

		GUIS_DB["unitframes"].showGridFramesAlways = false
		module:UpdateAll()
		module:PostUpdateGUI()
	end, "disablegridforallraidgroups")
end

