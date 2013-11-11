--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: CombatDPS")

-- Lua API
local print = print

-- WoW API 
local GetNumPartyMembers = GetNumGroupMembers or GetNumPartyMembers
local GetNumRaidMembers = GetNumGroupMembers or GetNumRaidMembers
local GetShapeshiftForm = GetShapeshiftForm
local UnitExists = UnitExists
local UnitThreatSituation = UnitThreatSituation

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local UnregisterCallback = function(...) return module:UnregisterCallback(...) end
local ScheduleTimer = function(...) module:ScheduleTimer(...) end

local printOut
local frame, combat, role, inPvP, inGroup
local updateRole, updateColor, updateGroup, updatePvP, updateAll
local updateDPS, updateDamage, updateVisibility, updateSizeAndPos
local where = "BottomLeft"
local dps, hps, totalDamage, totalHealing, damage, petDamage, otherDamage, startTime, totalTime = 0, 0, 0, 0, 0, 0, 0, 0, 0

local MINUTE = 60
local HOUR = MINUTE * 60
local DAY = HOUR * 24 -- like fights are gonna last days, lol
local stat = "|cFFFFD200%d|r|cFFFFFFFF%s|r"

local _,playerClass = UnitClass("player")

-- print last fights dps to the main chat frame
printOut = function()
	if not(GUIS_DB["combat"].showDPSVerboseReport) then return end
	
	-- gotta set some limits to avoid spam
	if (totalTime < GUIS_DB["combat"].minTime) or (dps < GUIS_DB["combat"].minDPS) then
		return
	end

	local time = ""
	local gotValue
	if (totalTime > DAY) then
		time = time .. stat:format(floor(totalTime/DAY), L["h"])
		gotValue = true
	end

	if (totalTime > HOUR) then
		if (gotValue) then 
			time = time .. " "
		end
		time = time .. stat:format(floor((totalTime%DAY)/HOUR), L["h"])
		gotValue = true
	end
	
	if (totalTime > MINUTE) then
		if (gotValue) then 
			time = time .. " "
		end
		time = time .. stat:format(floor((totalTime%HOUR)/MINUTE), L["m"])
		gotValue = true
	end
	
	if (gotValue) then
		time = time .. " "
	end
	
	time = time .. stat:format(totalTime%MINUTE, L["s"])

	if (role == "TANK") or (role == "DPS") and (floor(dps) > 0) then
		print(L["Last fight lasted %s"]:format(time))
		print(L["You did an average of %s%s"]:format(("[shortvaluecolored:%.1f]"):format(dps):tag(), " " .. L["dps"]))
	end
	
	if (role == "HEAL")  and (floor(hps) > 0) then
		print(L["Last fight lasted %s"]:format(time))
		print(L["You did an average of %s%s"]:format(("[shortvaluecolored:%.1f]"):format(hps):tag(), " " .. L["hps"]))
	end
end

-- change the color based on threat, to match the threatpanel on the other side
updateColor = function()
	local r, g, b, status
	local focus = (GUIS_DB["combat"].showFocusThreat) and (UnitExists("focus"))
	
	if (focus) or (UnitExists("target")) then
		status = UnitThreatSituation("player", focus and "focus" or "target")
		if (status) then
			r, g, b = unpack(C["THREAT_STATUS_COLORS"][status])
		else
			r, g, b = 1/10, 1/10, 1/10
		end
	else
		r, g, b = 1/10, 1/10, 1/10
	end
	
	frame.bar:SetStatusBarColor(r, g, b)
	frame.bar.bg:SetVertexColor(r * 1/3, g * 1/3, b * 1/3)
end

updateGroup = function()
	inGroup = (GetNumRaidMembers() > 0) or (GetNumPartyMembers() > 0)
end

updatePvP = function()
	inPvP = F.IsInPvPEvent()
end

updateRole = function()
	if (F.IsPlayerHealer()) then
		role = "HEAL"
		
	elseif (F.IsPlayerTank()) then
		role = "TANK"

		if (playerClass == "DRUID") and (GetShapeshiftForm() ~= 1) then
			role = "DPS"
		end
		
	else
		role = "DPS"
	end
end

updateVisibility = function(self, event, ...)
	local blockPvP = (inPvP) and not(GUIS_DB["combat"].showPvPDPS)
	local blockSolo = not(inGroup) and not(GUIS_DB["combat"].showSoloDPS)
	local toUpdate = GUIS_DB["combat"].dps
	local toShow = (toUpdate) and not(blockPvP) and not(blockSolo)

	if (toUpdate) then
		-- reset on combat start
		if (event == "PLAYER_REGEN_DISABLED") then
			dps, damage, petDamage, otherDamage, totalDamage = 0, 0, 0, 0, 0
			hps, totalHealing = 0, 0
			startTime, totalTime = GetTime(), 0
			combat = true
			
			updateColor()
		end
		
		if (event == "PLAYER_REGEN_ENABLED") then
			combat = nil
			
			if (toShow) then
				printOut()
			end
		end
	end
	
	
	-- keep hidden until you're doing actual damage
	frame:SetVisibility((toShow) and (combat) and (totalDamage > 0))
end

updateDPS = function()
	if not(combat) then
		return
	end
	
	totalTime = GetTime() - startTime

	if (role == "TANK") or (role == "DPS") then
		if (totalTime > 0) then
			dps = (totalDamage > 0) and totalDamage/totalTime or 0

			frame.bar.value:SetText(("[shortvalue:%.1f]"):format(dps):tag())
		end
	end
	
	if (role == "HEAL") then
		if (totalTime > 0) then
			hps = (totalHealing > 0) and totalHealing/totalTime or 0
			
			frame.bar.value:SetText(("[shortvalue:%.1f]"):format(hps):tag())
		end
	end
	
--	frame.bar:SetValue(dps)
end

local gflags = bit.bor(COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_TYPE_GUARDIAN)

-- this function should update both damage and healing
updateDamage = function(self, event, ...)
	local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags
	if (F.IsBuild(4,2)) then
		timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
	else
		timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = ...
	end
	
	local amount, healed, critical, spellId, spellSchool, missType 
	if (sourceGUID == UnitGUID("player")) then
		amount, healed, critical, spellId, spellSchool, missType = F.simpleParseLog(eventType, select(9, ...))
		damage = damage + amount
		totalHealing = totalHealing + healed
		
	elseif (sourceGUID == UnitGUID("pet")) then
		amount, healed, critical, spellId, spellSchool, missType = F.simpleParseLog(eventType, select(9, ...))
		petDamage = petDamage + amount
		totalHealing = totalHealing + healed
		
	elseif (sourceFlags == gflags) then
		amount, healed, critical, spellId, spellSchool, missType = F.simpleParseLog(eventType, select(9, ...))
		otherDamage = otherDamage + amount
		totalHealing = totalHealing + healed
	end

	totalDamage = damage + petDamage + otherDamage

	-- make it visible when we start doing damage
	if (totalDamage > 0) and not(frame:IsShown()) then
		updateVisibility()
	end
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
	frame.bar:SetValue(100)
end

updateAll = function()
	updateSizeAndPos()
	updatePvP()
	updateGroup()
	updateRole()
	updateVisibility()
	updateDPS()
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
	local bar = CreateFrame("StatusBar", nil, frame)
	bar:SetSize(frame:GetWidth() - 6, frame:GetHeight() - 6)
	bar:SetPoint("BOTTOMRIGHT", -3, 3)
	bar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	bar:SetStatusBarColor(1/3, 0, 0)
	F.GlossAndShade(bar)
	frame.bar = bar
	
	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(bar)
	bg:SetTexture(M["StatusBar"]["StatusBar"])
	bg:SetVertexColor(1/9, 0, 0)
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

	-- update visibility
	RegisterCallback("PLAYER_REGEN_DISABLED", updateVisibility)
	RegisterCallback("PLAYER_REGEN_ENABLED", updateVisibility)
	
	-- update role
	RegisterCallback("PLAYER_ALIVE", updateRole)
	RegisterCallback("ACTIVE_TALENT_GROUP_CHANGED", updateRole) 
	RegisterCallback("PLAYER_TALENT_UPDATE", updateRole) 
	RegisterCallback("TALENTS_INVOLUNTARILY_RESET", updateRole) 
	RegisterCallback("UPDATE_SHAPESHIFT_FORM", updateRole)

	-- update background color to match the threat panel. vanity rocks.
	RegisterCallback("PLAYER_FOCUS_CHANGED", updateColor)
	RegisterCallback("PLAYER_TARGET_CHANGED", updateColor)
	RegisterCallback("UNIT_THREAT_LIST_UPDATE", updateColor)
	RegisterCallback("UNIT_THREAT_SITUATION_UPDATE", updateColor)
	
	-- update damage
	RegisterCallback("COMBAT_LOG_EVENT_UNFILTERED", updateDamage)

	-- update the displayed DPS
	ScheduleTimer(updateDPS, 1/10, nil, nil)
	
	-- make sure the bar stays in place and is correctly sized
	RegisterCallback("PLAYER_ENTERING_WORLD", updateSizeAndPos)
	RegisterCallback("DISPLAY_SIZE_CHANGED", updateSizeAndPos)
	RegisterCallback("UI_SCALE_CHANGED", updateSizeAndPos)
end
