--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: WorldMap")

-- Lua API

-- WoW API
local CreateFrame = CreateFrame
local WorldMapButton = WorldMapButton

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local R = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: UnitFrameAuras")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) module:RegisterCallback(...) end
local RegisterBucketEvent = function(...) module:RegisterBucketEvent(...) end
local ScheduleTimer = function(...) module:ScheduleTimer(...) end

local frame, coords, size
local update, updateWorldMap, show

local faq = {
	{
		q = L["Why do the quest icons on the WorldMap disappear sometimes?"];
		a = {
			{
				type = "text";
				msg = L["Due to some problems with the default game interface, these icons must be hidden while being engaged in combat."];
			};
		};
		tags = { "worldmap", "quest tracker" };
	};
}

local defaults = {
	showCoords = true;
}

module.RestoreDefaults = function(self)
	GUIS_DB["worldmap"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["worldmap"] = GUIS_DB["worldmap"] or {}
	GUIS_DB["worldmap"] = ValidateTable(GUIS_DB["worldmap"], defaults)
end

module.OnInit = function(self)
	if (F.kill(self:GetName())) then 
		self:Kill()
		return 
	end
	
	-- we're parenting it to the WorldMapFrame to easily solve the scale issue with the WorldMapButton
	frame = CreateFrame("Frame", self:GetName() .. "CoordinatesFrame", WorldMapFrame)
	frame:SetAllPoints(WorldMapButton)
	frame:SetFrameLevel(WorldMapButton:GetFrameLevel() + 1)
	
	coords = frame:CreateFontString()
	coords:SetDrawLayer("OVERLAY")
	coords:SetFontObject(GUIS_NumberFontNormal)
	coords:SetPoint("BOTTOM", 0, 4)
	coords:SetJustifyH("CENTER")

	update = function()
		if not(WorldMapButton:IsVisible()) then
			return
		end
		
		if (MouseIsOver(WorldMapButton)) then
			local x, y = GetCursorPosition()
			local scale = WorldMapButton:GetEffectiveScale()
			x = x / scale
			y = y / scale

			local centerX, centerY = WorldMapButton:GetCenter()
			local width = WorldMapButton:GetWidth()
			local height = WorldMapButton:GetHeight()
			local adjustedY = (centerY + (height/2) - y) / height
			local adjustedX = (x - (centerX - (width/2))) / width
			
			coords:SetFormattedText("%.2f %.2f", adjustedX*100, adjustedY*100)
			coords:SetTextColor(unpack(C["index"]))
			coords:SetAlpha(1)
		
		else
			local x, y = GetPlayerMapPosition("player")
			if ((x == 0) and (y == 0)) or not(x) or not(y) then
				coords:SetAlpha(0)
			else
				coords:SetFormattedText("%.2f %.2f", x*100, y*100)
				coords:SetTextColor(unpack(C["value"]))
				coords:SetAlpha(1)
			end
		end
		
	end
	ScheduleTimer(update, 0.1, nil, nil)
	
	-- register the FAQ
	do
		local FAQ = LibStub("gCore-3.0"):GetModule("GUIS-gUI: FAQ")
		FAQ:NewGroup(faq)
	end
end

