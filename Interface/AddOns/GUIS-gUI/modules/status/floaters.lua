--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: StatusFloaters")

-- Lua API
local _G = _G

-- WoW API
local CreateFrame = CreateFrame

-- GUIS-gUI environment
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local RegisterBucketEvent = function(...) return module:RegisterBucketEvent(...) end

local fixAchievementAnchor, fixDungeonAnchor, fixTicketStrata
local Glue, CreateHolder

Glue = function(frame, target, ...)
	if (...) then
		frame:ClearAllPoints()
		frame:SetPoint(...)
	else
		frame:ClearAllPoints()
		frame:SetAllPoints(target)
	end

	frame.ClearAllPoints = noop
	frame.SetAllPoints = noop
	frame.SetPoint = noop

--	frame:SetClampedToScreen(true)
	
	return frame
end

CreateHolder = function(name, w, h, ...)
	local frame = CreateFrame("Frame", name, UIParent)
	frame:SetSize(w, h)
	frame:PlaceAndSave(...)

	_G[name] = frame
	
	return frame
end

fixAchievementAnchor = function()
	local previous, frame
	for i = 1, MAX_ACHIEVEMENT_ALERTS do
		frame = _G[("AchievementAlertFrame%d"):format(i)]

		if (frame) then
			frame:SetPoint("BOTTOM", (previous and (previous:IsShown())) and previous or _G["GUIS_AchievementAlertFrame"], previous and "TOP" or "BOTTOM", 0, previous and 10 or 0)
			previous = frame
		end		
	end
end

fixDungeonAnchor = function()
	local frame
	for i = MAX_ACHIEVEMENT_ALERTS, 1, -1 do
		frame = _G[("AchievementAlertFrame%d"):format(i)]

		if (frame) and (frame:IsShown()) then
			DungeonCompletionAlertFrame1:ClearAllPoints()
			DungeonCompletionAlertFrame1:SetPoint("BOTTOM", frame, "TOP", 0, 10)
			return
		end
		
		DungeonCompletionAlertFrame1:ClearAllPoints()
		DungeonCompletionAlertFrame1:SetPoint("BOTTOM", _G["GUIS_AchievementAlertFrame"], "TOP", 0, 10) -- our custom frame
	end
end

fixTicketStrata = function(self)
	if (self:IsShown()) then
		self:SetFrameStrata("DIALOG")
	else
		self:SetFrameStrata("BACKGROUND")
	end
end

module.OnInit = function(self)
	if F.kill("GUIS-gUI: Status") then 
		self:Kill() 
		return 
	end
	
	-- world scores (battleground scores, dungeon/raid waves etc)
	local GUIS_WorldStateScore = CreateHolder("GUIS_WorldStateScore", 48, 48, "TOP", "UIParent", "TOP", 0, -12)
	Glue(WorldStateAlwaysUpFrame, nil, "TOP", GUIS_WorldStateScore, "TOP", 0, 0):SetFrameStrata("BACKGROUND")

	-- vehicle seat indicator
	Glue(VehicleSeatIndicator, CreateHolder("GUIS_VehicleSeat", 128, 128, "BOTTOM", "UIParent", "BOTTOM", -200, 400))

	-- return to graveyard
	Glue(GhostFrame, CreateHolder("GUIS_GhostFrame", 130, 46, "CENTER", "UIParent", "CENTER", 0, 100))

	-- durability indicator
	Glue(DurabilityFrame, CreateHolder("GUIS_Durability", 60, 64, "BOTTOM", "UIParent", "BOTTOM", -200, 310))

	-- achievement and dungeon completion alerts
	CreateHolder("GUIS_AchievementAlertFrame", 300, 88, "BOTTOM", "UIParent", "BOTTOM", 0, 250)

	-- GM ticket status frame
	Glue(TicketStatusFrame, CreateHolder("GUIS_TicketStatus", 208, 75, "TOPLEFT", "UIParent", "TOPLEFT", 250, -250))
	
	fixTicketStrata(TicketStatusFrame)

	TicketStatusFrame:HookScript("OnShow", fixTicketStrata)
	TicketStatusFrame:HookScript("OnHide", fixTicketStrata)

	RegisterCallback("ACHIEVEMENT_EARNED", fixAchievementAnchor)

	-- MoP beta edits
	if (AchievementAlertFrame_FixAnchors) then
		hooksecurefunc("AchievementAlertFrame_FixAnchors", fixAchievementAnchor)
	end

	if (DungeonCompletionAlertFrame_FixAnchors) then
		hooksecurefunc("DungeonCompletionAlertFrame_FixAnchors", fixDungeonAnchor)
	end
end
