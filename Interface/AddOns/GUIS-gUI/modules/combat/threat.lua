--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: CombatThreat")

-- Lua API
local print = print

-- WoW API 
local GetNumPartyMembers = GetNumGroupMembers or GetNumPartyMembers
local GetNumRaidMembers = GetNumGroupMembers or GetNumRaidMembers
local InCombatLockdown = InCombatLockdown
local PlaySound = PlaySound
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local RaidNotice_AddMessage = RaidNotice_AddMessage

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local UnregisterCallback = function(...) return module:UnregisterCallback(...) end

local frame, show, combat, warning, inPvP, inGroup, oldStatus
local update, updateRole, updateVisibility, updateSizeAndPos, updatePvP, updateGroup, updateAll
local where = "BottomRight"

local _,playerClass = UnitClass("player")

warning = function(status)
	if not(GUIS_DB["combat"].threat) then return end
	if not(GUIS_DB["combat"].showWarnings) then return end
	if not(GUIS_DB["combat"].showSoloThreat) and not(inGroup) then return end
	if not(GUIS_DB["combat"].showPvPThreat) and (inPvP) then return end

	if (oldStatus == status) then return end
	
	local msg

	-- role based
	if (role == "TANK") then
		if (status == 3) then
			-- msg = L["You are tanking!"] -- the tank doesn't need to be told it's tanking, does it?
		elseif (status == 2) then
			msg = L["You are losing threat!"]
		elseif (status == 1) then 
			msg = L["You've lost the threat!"]
		elseif (status == 0) then
		end
	else 
		if (status == 3) then
			msg = L["You have aggro, stop attacking!"]
		elseif (status == 2) then
			msg = L["You have aggro, stop attacking!"]
		elseif (status == 1) then 
			msg = L["You are overnuking!"]
		elseif (status == 0) then
		end
	end

	if (msg) then
		RaidNotice_AddMessage(RaidBossEmoteFrame, "|cFFFF0000" .. msg .. "|r", ChatTypeInfo["RAID_BOSS_EMOTE"] )
		PlaySound("PVPTHROUGHQUEUE", "Master") -- "RaidWarning" could also work, but the queue sound stands more out
	end
	
	oldStatus = status
end

updateGroup = function()
	inGroup = (GetNumRaidMembers() > 0) or (GetNumPartyMembers() > 0)
end

updatePvP = function()
	inPvP = F.IsInPvPEvent()
end

updateRole = function()
	if (F.IsPlayerHealer()) then
		show = GUIS_DB["combat"].showHealerThreat
		role = "HEAL"
		
	elseif (F.IsPlayerTank()) then
		show = true
		role = "TANK"

		if (playerClass == "DRUID") and (GetShapeshiftForm() ~= 1) then
			role = "DPS"
		end
		
	else
		show = true
		role = "DPS"
	end
end

updateVisibility = function(self, event, ...)
	if (event == "PLAYER_REGEN_DISABLED") then
		combat = true
	end
		
	if (event == "PLAYER_REGEN_ENABLED") then
		combat = nil
		oldStatus = nil
		frame:Hide()
	end
end

update = function()
	local visible
	local toShow = (GUIS_DB["combat"].threat) and (combat) and (show)
	local blockPvP = not(GUIS_DB["combat"].showPvPThreat) and (inPvP)
	local blockSolo = not(GUIS_DB["combat"].showSoloThreat) and not(inGroup)
	
	if (toShow) and not(blockPvP or blockSolo) then
		local focus = (GUIS_DB["combat"].showFocusThreat) and (UnitExists("focus"))
		if (focus) or (UnitExists("target")) then
			local isTanking, status, scaledPercent, rawPercent, threatValue = UnitDetailedThreatSituation("player", focus and "focus" or "target")
			
			if (scaledPercent and scaledPercent > 0) then
				local r, g, b = unpack(C["THREAT_STATUS_COLORS"][status]) -- GetThreatStatusColor(status)
				frame.bar:SetStatusBarColor(r, g, b)
				frame.bar.bg:SetVertexColor(r * 1/3, g * 1/3, b * 1/3)
				frame.bar:SetValue(scaledPercent)
				frame.bar.value:SetFormattedText("%d%%", scaledPercent)
				
				-- check if we've lost/gained threat and warn accordingly
				warning(status)
				
				visible = true
			else
				frame.bar:SetValue(0)
				frame.bar.value:SetText("")
			end
		end
	end

	frame:SetVisibility(visible)
end

updateSizeAndPos = function()
	local panels = LibStub("gCore-3.0"):GetModule("GUIS-gUI: UIPanels")

	if (panels) then
		local panel = panels:GetPanel(where)
		
		if (panel) then
			frame:SetSize(panel:GetSize())
			frame:ClearAllPoints()
			frame:SetPoint(panel:GetPoint())
			
			frame.bar:SetSize(frame:GetWidth() - 6, frame:GetHeight() - 6)
			frame.bar:SetMinMaxValues(0, 100)
			frame.bar:SetValue(100)
			
			return
		end
	end
		
	local w, h = F.fixPanelWidth(), F.fixPanelHeight()
	frame:SetSize(w, h)
	frame:ClearAllPoints()
	frame:SetPoint(F.fixPanelPosition(where))
	
	frame.bar:SetSize(w - 6, h - 6)
	frame.bar:SetMinMaxValues(0, 100)
	frame.bar:SetValue(0)
end

updateAll = function()
	updateSizeAndPos()
	updatePvP()
	updateGroup()
	updateRole()
	updateVisibility()
	update()
end
module.UpdateAll = updateAll

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: Combat")) then 
		self:Kill() 
		return 
	end
	
	-- create a holder
	frame = CreateFrame("Frame", self:GetName() .. "Bar", UIParent)
	frame:SetSize(F.fixPanelWidth(), F.fixPanelHeight())
	frame:EnableMouse(true)
	frame:Hide()
	
	-- create and setup the bar itself
	local bar = F.ReverseBar(frame) 
	bar:SetSize(frame:GetWidth() - 6, frame:GetHeight() - 6)
	bar:SetPoint("BOTTOMRIGHT", -3, 3)
	bar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	F.GlossAndShade(bar)
	frame.bar = bar
	
	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(bar)
	bg:SetTexture(M["StatusBar"]["StatusBar"])
	bar.bg = bg

	local value = bar:CreateFontString()
	value:SetDrawLayer("OVERLAY", 5)
	value:SetFontObject(GUIS_NumberFontNormal)
	value:SetPoint("CENTER")
	bar.value = value

	-- initial updates
	updateAll()
	
	-- update pvp status
	RegisterCallback("PLAYER_ENTERING_WORLD", updatePvP)
	RegisterCallback("ZONE_CHANGED_NEW_AREA", updatePvP)
	
	-- update group status
	RegisterCallback("PARTY_MEMBERS_CHANGED", updateGroup)
	RegisterCallback("PLAYER_ENTERING_WORLD", updateGroup)

	-- update threat
	RegisterCallback("PLAYER_FOCUS_CHANGED", update)
	RegisterCallback("PLAYER_TARGET_CHANGED", update)
	RegisterCallback("UNIT_THREAT_LIST_UPDATE", update)
	RegisterCallback("UNIT_THREAT_SITUATION_UPDATE", update)
	
	-- update combat visibility
	RegisterCallback("PLAYER_REGEN_DISABLED", updateVisibility)
	RegisterCallback("PLAYER_REGEN_ENABLED", updateVisibility)
	
	-- update player role
	RegisterCallback("PLAYER_ALIVE", updateRole)
	RegisterCallback("ACTIVE_TALENT_GROUP_CHANGED", updateRole) 
	RegisterCallback("PLAYER_TALENT_UPDATE", updateRole) 
	RegisterCallback("TALENTS_INVOLUNTARILY_RESET", updateRole) 
	RegisterCallback("UPDATE_SHAPESHIFT_FORM", updateRole)
	
	-- update the size and position of the panels
	RegisterCallback("PLAYER_ENTERING_WORLD", updateSizeAndPos)
	RegisterCallback("DISPLAY_SIZE_CHANGED", updateSizeAndPos)
	RegisterCallback("UI_SCALE_CHANGED", updateSizeAndPos)
end

