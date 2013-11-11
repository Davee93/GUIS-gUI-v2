--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local oUF = ns.oUF or oUF 

if not(oUF) then
	return
end

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local R = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: UnitFrameAuras")

local localizedClass, class = UnitClass("player")

------------------------------------------------------------------------
--	Grid Indicators 
------------------------------------------------------------------------
--[[
 Simple rules:
	TOPLEFT = HoTs, shields, shield cooldowns, defensive stuff
	TOPRIGHT = Buffs, missing long term buffs, active short term buffs
	BOTTOMLEFT = Most HoTs
	BOTTOMRIGHT = stuff with charges/stacks
	CENTER = timers for riptide, renew, rejuv etc
]]--
R.AurasByClass = {
	-- healer classes
    ["DRUID"] = {
        ["TOPLEFT"] = "[guis:rejuv]";
        ["TOPRIGHT"] = "[guis:motw]";
        ["BOTTOMLEFT"] = "[guis:regrowth][guis:wildgrowth]";
        ["BOTTOMRIGHT"] = "[guis:lifebloom]";
        ["CENTER"] = "[guis:rejuvTime]";
    };
    ["PALADIN"] = {
        ["TOPLEFT"] = "[guis:forbearance]";
        ["TOPRIGHT"] = "[guis:might][guis:motw]";
        ["BOTTOMLEFT"] = "";
        ["BOTTOMRIGHT"] = "[guis:beacon]"; 
        ["CENTER"] = "";
    };
    ["PRIEST"] = {
        ["TOPLEFT"] = "[guis:pws][guis:weakenedsoul]";
        ["TOPRIGHT"] = "[guis:fearward][guis:shadow][guis:fortitude]";
        ["BOTTOMLEFT"] = "[guis:renew][guis:pwb]";
        ["BOTTOMRIGHT"] = "[guis:mending]";
        ["CENTER"] = "[guis:renewTime]";
    };
    ["SHAMAN"] = {
        ["TOPLEFT"] = "[guis:riptide]";
        ["TOPRIGHT"] = ""; 
        ["BOTTOMLEFT"] = "";
        ["BOTTOMRIGHT"] = "[guis:earthshield]";
        ["CENTER"] = "[guis:riptideTime]";
    };
	
	-- other buffers
    ["MAGE"] = {
        ["TOPLEFT"] = "";
        ["TOPRIGHT"] = "[guis:brilliance]"; 
        ["BOTTOMLEFT"] = "";
        ["BOTTOMRIGHT"] = "";
        ["CENTER"] = "";
    };
    ["WARLOCK"] = {
        ["TOPLEFT"] = "";
        ["TOPRIGHT"] = "[guis:intent]";
        ["BOTTOMLEFT"] = "";
        ["BOTTOMRIGHT"] = "[guis:soulstone]";
        ["CENTER"] = "";
    };
    ["WARRIOR"] = {
        ["TOPLEFT"] = "[guis:vigilance]";
        ["TOPRIGHT"] = "[guis:winter][guis:fortitude]"; 
        ["BOTTOMLEFT"] = "";
        ["BOTTOMRIGHT"] = "";
        ["CENTER"] = "";
    };
	
	-- placeholders
    ["DEATHKNIGHT"] = {
        ["TOPLEFT"] = "";
        ["TOPRIGHT"] = "";
        ["BOTTOMLEFT"] = "";
        ["BOTTOMRIGHT"] = "";
        ["CENTER"] = "";
    };
    ["HUNTER"] = {
        ["TOPLEFT"] = "";
        ["TOPRIGHT"] = "";
        ["BOTTOMLEFT"] = "";
        ["BOTTOMRIGHT"] = "";
        ["CENTER"] = "";
    };
    ["ROGUE"] = {
        ["TOPLEFT"] = "";
        ["TOPRIGHT"] = "";
        ["BOTTOMLEFT"] = "";
        ["BOTTOMRIGHT"] = "";
        ["CENTER"] = "";
    };
}

local Enable = function(self)
	if (self.GUISIndicators) then
		local frame = self.GUISIndicators
		local font = frame.fontObject:GetFont()

		-- topright is usually buffs, interesting to all
		frame.TOPRIGHT = frame:CreateFontString(nil, "OVERLAY")
		frame.TOPRIGHT:ClearAllPoints()
		frame.TOPRIGHT:SetPoint("TOPRIGHT", frame, 1, -1)
		frame.TOPRIGHT:SetFont(font, frame.indicatorSize, "THINOUTLINE")
		frame.TOPRIGHT:SetJustifyH("RIGHT")
		self:Tag(frame.TOPRIGHT, R.AurasByClass[class]["TOPRIGHT"])
		
		-- stuff not visible in the tiny DPS layout
		if not(frame.onlyBuffs) then
			frame.TOPLEFT = frame:CreateFontString(nil, "OVERLAY")
			frame.TOPLEFT:ClearAllPoints()
			frame.TOPLEFT:SetPoint("TOPLEFT", frame, 1, -1)
			frame.TOPLEFT:SetFont(font, frame.indicatorSize, "THINOUTLINE")
			self:Tag(frame.TOPLEFT, R.AurasByClass[class]["TOPLEFT"])

			frame.BOTTOMLEFT = frame:CreateFontString(nil, "OVERLAY")
			frame.BOTTOMLEFT:ClearAllPoints()
			frame.BOTTOMLEFT:SetPoint("BOTTOMLEFT", frame, 1, 1)
			frame.BOTTOMLEFT:SetFont(font, frame.indicatorSize, "THINOUTLINE")
			self:Tag(frame.BOTTOMLEFT, R.AurasByClass[class]["BOTTOMLEFT"])

			frame.BOTTOMRIGHT = frame:CreateFontString(nil, "OVERLAY")
			frame.BOTTOMRIGHT:ClearAllPoints()
			frame.BOTTOMRIGHT:SetPoint("BOTTOMRIGHT", frame, 0, 1)
			frame.BOTTOMRIGHT:SetFont(font, frame.symbolSize, "THINOUTLINE")
			frame.BOTTOMRIGHT:SetJustifyH("RIGHT")
			self:Tag(frame.BOTTOMRIGHT, R.AurasByClass[class]["BOTTOMRIGHT"])

			frame.CENTER = frame:CreateFontString(nil, "OVERLAY")
			frame.CENTER:SetPoint("CENTER", frame, "TOP", 0, 0)
			frame.CENTER:SetWidth(frame.width)
			frame.CENTER:SetFontObject(frame.fontObject)
			frame.CENTER:SetJustifyH("CENTER")
			frame.CENTER:SetJustifyV("MIDDLE")
			frame.CENTER.frequentUpdates = frame.frequentUpdates
			self:Tag(frame.CENTER, R.AurasByClass[class]["CENTER"])
		end
	end
end

oUF:AddElement("GUISIndicators", nil, Enable, nil)

