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

-- developer stuff
local _TESTMODE = false

-- Lua API
local _G = _G
local floor = math.floor
local strfind, format, strsub = string.find, string.format, string.sub
local setmetatable, unpack = setmetatable, unpack

-- WoW API
local GetNumRaidMembers = GetNumGroupMembers or GetNumRaidMembers
local GetLootMethod = GetLootMethod
local GetSpellInfo = GetSpellInfo
local GetThreatStatusColor = GetThreatStatusColor
local GetTime = GetTime 
local IsResting = IsResting
local UnitAlternatePowerInfo = UnitAlternatePowerInfo
local UnitAura = UnitAura 
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitFactionGroup = UnitFactionGroup
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitInParty = UnitInParty
local UnitInPhase = UnitInPhase
local UnitInRaid = UnitInRaid
local UnitIsAFK = UnitIsAFK
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsPartyLeader = UnitIsGroupLeader or UnitIsPartyLeader
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll
local UnitIsQuestBoss = UnitIsQuestBoss
local UnitIsRaidOfficer = UnitIsRaidOfficer
local UnitIsUnit = UnitIsUnit
local UnitLevel = UnitLevel
local UnitName = UnitName
local UnitPlayerControlled = UnitPlayerControlled
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitStat = UnitStat

local ALTERNATE_POWER_INDEX = ALTERNATE_POWER_INDEX

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) LibStub("gCore-3.0"):GetModule("GUIS-gUI: Core"):RegisterCallback(...) end
local RGBToHex = RGBToHex

local TagEvents = (oUF.Tags) and oUF.Tags.Events or oUF.TagEvents
local TagMethods = (oUF.Tags) and oUF.Tags.Methods or oUF.Tags

-- cache up spellnames so we only need one actual function call per spellID
local spellcache = setmetatable({}, {__index=function(t,v) local a = {GetSpellInfo(v)} if GetSpellInfo(v) then t[v] = a end return a end})
local GetSpellInfo = function(a)
    return unpack(spellcache[a])
end

local utf8sub = function(string, i, dots)
	if not string then return end
	local bytes = string:len()
	if (bytes <= i) then
		return string
	else
		local len, pos = 0, 1
		while(pos <= bytes) do
			len = len + 1
			local c = string:byte(pos)
			if (c > 0 and c <= 127) then
				pos = pos + 1
			elseif (c >= 192 and c <= 223) then
				pos = pos + 2
			elseif (c >= 224 and c <= 239) then
				pos = pos + 3
			elseif (c >= 240 and c <= 247) then
				pos = pos + 4
			end
			if (len == i) then break end
		end

		if (len == i and pos <= bytes) then
			return string:sub(1, pos - 1)..(dots and '...' or '')
		else
			return string
		end
	end
end

------------------------------------------------------------------------
--	Health/Power
------------------------------------------------------------------------
if not(TagMethods["guis:health"]) then
	TagMethods["guis:health"] = function(unit)
		local min, max = UnitHealth(unit), UnitHealthMax(unit)
		local status = (not UnitIsConnected(unit)) and PLAYER_OFFLINE 
			or UnitIsGhost(unit) and L["Ghost"] 
			or UnitIsDead(unit) and DEAD
			or (UnitIsAFK(unit) and ((strfind(unit, "raid")) or (strfind(unit, "party")))) and CHAT_FLAG_AFK

		if (status) then 
			return status

		elseif (min ~= max) then
			if (unit == "player") then 
				return format("|cffffffff%d%%|r |cffD7BEA5-|r |cffffffff%s|r", floor(min / max * 100), ("[shortvalue:%d]"):format(min):tag())
				
			elseif (unit == "target") then
				return format("|cffffffff%s|r |cffD7BEA5-|r |cffffffff%d%%|r", ("[shortvalue:%d]"):format(min):tag(), floor(min / max * 100))
				
			else
				return format("|cffffffff%d%%|r", floor(min / max * 100))
			end
		else
			return format("|cffffffff"..("[shortvalue:%d]"):format(max):tag().."|r")
		end
			
	end
end

if not(TagMethods["guis:healthshort"]) then
	TagMethods["guis:healthshort"] = function(unit)
		local min, max = UnitHealth(unit), UnitHealthMax(unit)
		local status = (not UnitIsConnected(unit)) and PLAYER_OFFLINE 
			or UnitIsGhost(unit) and L["Ghost"] 
			or UnitIsDead(unit) and DEAD
			or (UnitIsAFK(unit) and ((strfind(unit, "raid")) or (strfind(unit, "party")))) and CHAT_FLAG_AFK

		if (status) then 
			return status

		elseif (min ~= max) then
			return format("|cffffffff%d%%|r", floor(min / max * 100))
		else
			return format("|cffffffff"..("[shortvalue:%d]"):format(max):tag().."|r")
		end
			
	end
end

if not(TagMethods["guis:name"]) then
	TagEvents["guis:name"] = "UNIT_NAME_UPDATE UNIT_REACTION UNIT_FACTION"
	TagMethods["guis:name"] = function(unit)
		local name = UnitName(unit)
		return name
	end
end

if not(TagMethods["guis:nameshort"]) then
	TagEvents["guis:nameshort"] = "UNIT_NAME_UPDATE UNIT_REACTION UNIT_FACTION"
	TagMethods["guis:nameshort"] = function(unit)
		local name = UnitName(unit)
		return utf8sub(name, 7, false)
	end
end

if not(TagMethods["guis:namesmartsize"]) then
	TagEvents["guis:namesmartsize"] = "UNIT_NAME_UPDATE UNIT_REACTION UNIT_FACTION PARTY_MEMBERS_CHANGED RAID_ROSTER_UPDATE"
	TagMethods["guis:namesmartsize"] = function(unit)
		local name = UnitName(unit)
		return (GetNumRaidMembers() > 15) and utf8sub(name, 7, false) or name
	end
end

if not(TagMethods["guis:power"]) then
	TagMethods["guis:power"] = function(unit)
		if (unit ~= "player") and (unit ~= "target") then return end

		local power = UnitPower(unit)
		local pType, pToken = UnitPowerType(unit)
		local min, max = UnitPower(unit), UnitPowerMax(unit)

		if (min == 0) then
			return 
			
		elseif (not UnitIsPlayer(unit)) and (not UnitPlayerControlled(unit)) or (not UnitIsConnected(unit)) then
			return
			
		elseif (UnitIsDead(unit)) or (UnitIsGhost(unit)) then
			return
			
		elseif (min == max) and (pType == 2 or pType == 3 and pToken ~= "POWER_TYPE_PYRITE") then
			return
			
		else
			if (min ~= max) then
				local shortHealth = ("[shortvalue:%d]"):format((max - (max - min))):tag()
				if (pType == 0) then
					if (unit == "player") then
						return format("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), shortHealth)
						
					elseif (unit == "target") then
						return format("%s |cffD7BEA5-|r %d%%", shortHealth, floor(min / max * 100))
						
					elseif (unit == "player" and self:GetAttribute("normalUnit") == "pet") or (unit == "pet") then
						return format("%d%%", floor(min / max * 100))
						
					else
						return format("%d%% |cffD7BEA5-|r %s", floor(min / max * 100), shortHealth)
					end
				else
					return shortHealth
				end
			else
				if (unit == "pet") then
					return
					
				elseif (unit == "target") or (unit == "player") then
					return ("[shortvalue:%d]"):format(min):tag()
					
				else
					return ("[shortvalue:%d]"):format(min):tag()
				end
			end
		end
	end
end

if not(TagMethods["guis:altpower"]) then
	TagEvents["guis:altpower"] = "PLAYER_ENTERING_WORLD UNIT_POWER_BAR_HIDE UNIT_POWER_BAR_SHOW UNIT_POWER UNIT_MAXPOWER"
	TagMethods["guis:altpower"] = function(unit)
		local barType, min = UnitAlternatePowerInfo(unit)
		local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
		local max = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)
		
		if (cur < 0) or ( max < 100 ) then
			return
		else
			return ("%d%%"):format(cur / max * 100)
		end
	end
end

if not(TagMethods["guis:druid"]) then
	TagEvents["guis:druid"] = "UNIT_POWER UNIT_MAXPOWER UNIT_DISPLAYPOWER"
	TagMethods["guis:druid"] = function(unit)
		local min, max = UnitPower(unit, 0), UnitPowerMax(unit, 0)
		if (UnitPowerType(unit) ~= 0) and (min ~= max) then
			return ("%d%%"):format(min / max * 100)
		end
	end	
end

if not(TagMethods["guis:vengeance"]) then
	local _, currentVengeance, maxVengeance, stat, posBuff, maxHealth
	local apbase, apbuff, apdebuff = 0, 0, 0
	local spell = (GetSpellInfo(84839))

	TagEvents["guis:vengeance"] = "UNIT_ATTACK_POWER UNIT_MAXHEALTH ACTIVE_TALENT_GROUP_CHANGED PLAYER_TALENT_UPDATE"
	TagMethods["guis:vengeance"] = function(unit)
		-- check for unit and talent spec
		if (unit ~= "player") or not(F.IsPlayerTank()) then 
			return 
		end
		
		-- find the max health
		local currentMax = UnitHealthMax("player")
		if not(maxHealth) or (currentMax ~= maxHealth) then
			stat, _, posBuff, _ = UnitStat("player", 3)
			maxVengeance = (currentMax - (posBuff * UnitHPPerStamina("player")))/10 + stat
			maxHealth = currentMax
		end
		
		-- check for current value
		currentVengeance = nil
		_, _, _, _, _, _, _, _, _, _, _, _, _, currentVengeance = UnitBuff(unit, spell, nil)
		
		if not(currentVengeance) then
			return
		else
			return ("%d%%"):format(currentVengeance / maxVengeance * 100)
		end
	end
end

------------------------------------------------------------------------
--	Player Status
------------------------------------------------------------------------
if not(TagMethods["guis:afk"]) then
	TagEvents["guis:afk"] = "PLAYER_FLAGS_CHANGED"
	TagMethods["guis:afk"] = function(unit)
		if (UnitIsAFK(unit)) then
			return CHAT_FLAG_AFK
		end
	end
end

------------------------------------------------------------------------
--	Group/Raid
------------------------------------------------------------------------
if not(TagMethods["guis:leader"]) then
	TagEvents["guis:leader"] = "PARTY_LEADER_CHANGED PARTY_MEMBERS_CHANGED"
	TagMethods["guis:leader"] = function(unit)
		if (_TESTMODE) or ((UnitInParty(unit)) or (UnitInRaid(unit))) then
			if (UnitIsPartyLeader(unit)) then
				return [[|TInterface\GroupFrame\UI-Group-LeaderIcon:0:0:0:0:16:16:0:14:0:14|t]]
				
			elseif (UnitIsRaidOfficer(unit)) then
				return [[|TInterface\GroupFrame\UI-Group-AssistantIcon:0:0:0:0:16:16:0:14:0:14|t]]
				
			end
		end
	end
end

if not(TagMethods["guis:masterlooter"]) then
	TagEvents["guis:masterlooter"] = "PARTY_LOOT_METHOD_CHANGED PARTY_MEMBERS_CHANGED"
	TagMethods["guis:masterlooter"] = function(unit)
		local mlunit
		local method, pid, rid = GetLootMethod()
		if (_TESTMODE) or (method == "master") then
			if (pid) then
				if (pid == 0) then
					mlunit = "player"
				else
					mlunit = "party" .. pid
				end
			elseif (rid) then
				mlunit = "raid" .. rid
			else
				return
			end
			
			if (_TESTMODE) or (UnitIsUnit(mlunit, unit)) then
				return [[|TInterface\GroupFrame\UI-Group-MasterLooter:0:0:0:0:16:16:0:15:0:16|t]]
			end
		end
	end
end

if not(TagMethods["guis:grouprole"]) then
	TagEvents["guis:grouprole"] = "PLAYER_ROLES_ASSIGNED PARTY_MEMBERS_CHANGED"
	TagMethods["guis:grouprole"] = function(unit)
		local role = UnitGroupRolesAssigned(unit)
		if (_TESTMODE) or (role == "TANK") then
			return [[|TInterface\LFGFrame\UI-LFG-ICON-PORTRAITROLES:0:0:0:0:64:64:0:19:22:41|t]]
			
		elseif (role == "HEALER") then
			return [[|TInterface\LFGFrame\UI-LFG-ICON-PORTRAITROLES:0:0:0:0:64:64:20:39:1:20|t]]
			
		elseif (role == "DAMAGER") then
			return [[|TInterface\LFGFrame\UI-LFG-ICON-PORTRAITROLES:0:0:0:0:64:64:20:39:22:41|t]]
		end
	end
end
	
if not(TagMethods["guis:maintank"]) then
	TagEvents["guis:maintank"] = "PARTY_MEMBERS_CHANGED RAID_ROSTER_UPDATE"
	TagMethods["guis:maintank"] = function(unit)
		if (_TESTMODE) or ((UnitInRaid(unit)) and (GetPartyAssignment("MAINTANK", unit))) then
			return [[|TInterface\GroupFrame\UI-Group-MainTankIcon:0:0:0:0:16:16:0:14:0:15|t]]
		end
	end
end

if not(TagMethods["guis:mainassist"]) then
	TagEvents["guis:mainassist"] = "PARTY_MEMBERS_CHANGED RAID_ROSTER_UPDATE"
	TagMethods["guis:mainassist"] = function(unit)
		if (_TESTMODE) or ((UnitInRaid(unit)) and (GetPartyAssignment("MAINASSIST", unit))) then
			return [[|TInterface\GroupFrame\UI-Group-MainAssistIcon:0:0:0:0:16:16:0:15:0:16|t]]
		end
	end
end
	
------------------------------------------------------------------------
--	Combat
------------------------------------------------------------------------
if not(TagMethods["guis:threat"]) then
	TagEvents["guis:threat"] = "UNIT_THREAT_LIST_UPDATE UNIT_THREAT_SITUATION_UPDATE"
	TagMethods["guis:threat"] = function(unit)
		local isTanking, status, scaledPercent, rawPercent, threatValue = UnitDetailedThreatSituation("player", unit)
		--
		-- status:
		-- 3 = securely tanking (gray)
		-- 2 = insecurely tanking (yellow)
		-- 1 = not tanking but higher threat than tank (orange)
		-- 0 = not tanking and lower threat than tank (red)
		--
		if (scaledPercent and scaledPercent > 0) then
			return ("|cFF%s%d%%|r"):format(RGBToHex(GetThreatStatusColor(status)), scaledPercent)
		end
	end
end

------------------------------------------------------------------------
--	Questing
------------------------------------------------------------------------
if not(TagMethods["guis:quest"]) then
	TagEvents["guis:quest"] = "UNIT_CLASSIFICATION_CHANGED"
	TagMethods["guis:quest"] = function(unit)
		if (UnitIsQuestBoss(unit)) then
			return [[|TInterface\TargetingFrame\PortraitQuestBadge:0:0:0:0:32:32:0:27:0:31|t]]
		end
	end
end

if not(TagMethods["guis:phasing"]) then
	TagEvents["guis:phasing"] = "UNIT_PHASE"
	TagMethods["guis:phasing"] = function(unit)
		if (UnitInPhase(unit)) then
			return [[|TInterface\TargetingFrame\UI-PhasingIcon:0:0:0:0|t]]
		end
	end
end

if not(TagMethods["guis:resting"]) then
	TagEvents["guis:resting"] = "PLAYER_UPDATE_RESTING"
	TagMethods["guis:resting"] = function(unit)
		-- hotfix for the MoP account level bug in Cata July 25th 2012
		local accountLevel = GetAccountExpansionLevel()
		local MAX_PLAYER_LEVEL = accountLevel and MAX_PLAYER_LEVEL_TABLE[accountLevel] or UnitLevel("player") 

		if (unit == "player") and (IsResting()) and (UnitLevel("player") < MAX_PLAYER_LEVEL) then
			return [[|TInterface\CharacterFrame\UI-StateIcon:0:0:0:0:64:64:3:29:3:28|t]]
		end
	end
end

------------------------------------------------------------------------
--	PvP
------------------------------------------------------------------------
if not(TagMethods["guis:pvp"]) then
	TagEvents["guis:pvp"] = "UNIT_FACTION UNIT_REACTION PLAYER_ENTERING_WORLD ZONE_CHANGED_NEW_AREA"
	TagMethods["guis:pvp"] = function(unit)
		-- don't show the PvP icon on group frames when in a battleground or arena. It's just spam there.
		if (F.IsInPvPInstance()) and (unit ~= "player") and (unit ~= "target") then
			return
		end
		local factionGroup = UnitFactionGroup(unit)
		if (UnitIsPVPFreeForAll(unit)) then
			return [[|TInterface\TargetingFrame\UI-PVP-FFA:0:0:0:0:64:64:5:36:2:39|t]]
			
		elseif (factionGroup and UnitIsPVP(unit)) then
			if (factionGroup == "Horde") then
				return ([[|TInterface\TargetingFrame\UI-PVP-%s:0:0:0:0:64:64:1:40:1:38|t]]):format(factionGroup)
				
			elseif factionGroup == "Alliance" then
				return ([[|TInterface\TargetingFrame\UI-PVP-%s:0:0:0:0:64:64:5:36:2:39|t]]):format(factionGroup)
			end
		end
	end
end

if not(TagMethods["guis:warsongflag"]) then
	TagEvents["guis:warsongflag"] = "UNIT_AURA"
	TagMethods["guis:warsongflag"] = function(unit)
		-- Horde Flag
		if (UnitAura(unit, GetSpellInfo(23333))) then
			return ([[|TInterface\WorldStateFrame\AllianceFlag.blp:0:0:0:0:32:32:0:32:0:32]])
			
		-- Alliance Flag
		elseif (UnitAura(unit, GetSpellInfo(23335))) then
			return ([[|TInterface\WorldStateFrame\HordeFlag.blp:0:0:0:0:32:32:0:32:0:32]])
		end
	end
end

------------------------------------------------------------------------
--	Grid Indicators 
------------------------------------------------------------------------
-- shows missing buffs, and running HoTs/Shields

-- @param r, g, b [INTEGER] values from 0-255
-- @return [STRING] texture string with a colorized gridlike HoT indicator
local indicator = function(r, g, b, count, max)
	local i = "|T" .. M["Icon"]["GridIndicator"] .. ":0:0:0:0:16:16:0:16:0:16:" .. (r or 1) .. ":" .. (g or 1) .. ":" .. (b or 1) .. "|t"
	
	if (count) and (count > 0) then
		i = "|cFF" .. RGBToHex(unpack(C["value"])) .. count .. "|r" .. i
	end
	
	return i
end

-- @param debuffType [STRING] the type of debuff ("Magic", "Curse", "Poison", "Disease")
-- @return [STRING] texture string with a debuff colored grid indicator
local hasDebuffType = function(unit, debuffType)
	local name, dtype
	local index = 1
	while true do
		name, _, _, _, dtype = UnitAura(unit, index, "HARMFUL")
		if not(name) then break end

		if (dtype == debuffType) then
			return indicator(DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b)
		end
		index = index + 1
	end
end

local numberize = function(val)
    if (val >= 1e6) then
        return ("%.1fm"):format(val / 1e6)
    elseif (val >= 1e3) then
        return ("%.1fk"):format(val / 1e3)
    else
        return ("%d"):format(val)
    end
end

local getTime = function(expirationTime)
    local expire = (expirationTime - GetTime())
    local timeleft = numberize(expire)
    if (expire > 0.5) then
        return ("|cFF" .. RGBToHex(unpack(C["value"])) .. timeleft .. "|r")
    end
end

-- Mark of the Wild, Blessing of Kings
if not(TagMethods["guis:motw"]) then
	TagEvents["guis:motw"] = "UNIT_AURA"
	TagMethods["guis:motw"] = function(unit)
		if not(UnitAura(unit, GetSpellInfo(79060)) or UnitAura(unit, GetSpellInfo(79063))) then 
			return indicator(0, 161, 222) -- 00A1DE
		end
	end
end

-- Power Word: Fortitude, Blood Pact, Commanding Shout
if not(TagMethods["guis:fortitude"]) then
	TagEvents["guis:fortitude"] = "UNIT_AURA"
	TagMethods["guis:fortitude"] = function(unit)
		if not(UnitAura(unit, GetSpellInfo(79105)) or UnitAura(unit, GetSpellInfo(6307)) or UnitAura(unit, GetSpellInfo(469))) then 
			return indicator(0, 161, 222) -- 00A1DE
		end
	end
end

-- Arcane Brilliance
if not(TagMethods["guis:brilliance"]) then
	TagEvents["guis:brilliance"] = "UNIT_AURA"
	TagMethods["guis:brilliance"] = function(unit)
		if not(UnitAura(unit, GetSpellInfo(1459))) then 
			return indicator(0, 161, 222) -- 00A1DE
		end
	end
end

-- Shadow Protection
if not(TagMethods["guis:shadow"]) then
	TagEvents["guis:shadow"] = "UNIT_AURA"
	TagMethods["guis:shadow"] = function(unit)
		if not UnitAura(unit, GetSpellInfo(79107)) then 
			return indicator(153, 0, 255) -- 9900FF 
		end
	end
end

-- Blessing of Might, Abomination's Might
if not(TagMethods["guis:might"]) then
	TagEvents["guis:might"] = "UNIT_AURA"
	TagMethods["guis:might"] = function(unit)
		if not(UnitAura(unit, GetSpellInfo(53138)) or UnitAura(unit, GetSpellInfo(79102))) then 
			return indicator(255, 0, 0) -- FF0000
		end
	end
end

-- Horn of Winter, Battleshout, Strength of Earth Totem
if not(TagMethods["guis:winter"]) then
	TagEvents["guis:winter"] = "UNIT_AURA"
	TagMethods["guis:winter"] = function(unit)
		if not(UnitAura(unit, GetSpellInfo(6673)) or UnitAura(unit, GetSpellInfo(57330)) or UnitAura(unit, GetSpellInfo(8076))) then 
			return indicator(255, 0, 0) -- FF0000
		end
	end
end

-- Soulstone Ressurection
if not(TagMethods["guis:soulstone"]) then
	TagEvents["guis:soulstone"] = "UNIT_AURA"
	TagMethods["guis:soulstone"] = function(unit)
		local name, _,_,_,_,_,_, caster = UnitAura(unit, GetSpellInfo(20707)) 
		if (caster == "player") then
			return indicator(102, 0, 255) -- 6600FF
		elseif (name) then
			return indicator(204, 0, 255) -- CC00FF
		end
	end
end

-- Dark Intent
if not(TagMethods["guis:intent"]) then
	TagEvents["guis:intent"] = "UNIT_AURA"
	TagMethods["guis:intent"] = function(unit)
    local name, _,_,_,_,_,_, caster = UnitAura(unit, GetSpellInfo(85767)) 
		if (caster == "player") then
			return indicator(102, 0, 255) -- 6600FF
		elseif (name) then
			return indicator(204, 0, 255) -- CC00FF
		end
	end
end

-- Focus Magic
if not(TagMethods["guis:focusmagic"]) then
	TagEvents["guis:focusmagic"] = "UNIT_AURA"
	TagMethods["guis:focusmagic"] = function(unit)
		if UnitAura(unit, GetSpellInfo(54648)) then 
			return indicator(204, 0, 255) -- CC00FF
		end
	end
end

-- Forbearance
if not(TagMethods["guis:forbearance"]) then
	TagEvents["guis:forbearance"] = "UNIT_AURA"
	TagMethods["guis:forbearance"] = function(unit)
		if UnitDebuff(unit, GetSpellInfo(25771)) then 
			return indicator(255, 153, 0) -- FF9900
		end
	end
end

-- Weakened Soul
if not(TagMethods["guis:weakenedsoul"]) then
	TagEvents["guis:weakenedsoul"] = "UNIT_AURA"
	TagMethods["guis:weakenedsoul"] = function(unit)
		if UnitDebuff(unit, GetSpellInfo(6788)) then 
			return indicator(255, 153, 0) -- FF9900
		end
	end
end

-- Fear Ward
if not(TagMethods["guis:fearward"]) then
	TagEvents["guis:fearward"] = "UNIT_AURA"
	TagMethods["guis:fearward"] = function(unit)
		if UnitAura(unit, GetSpellInfo(6346)) then 
			return indicator(139, 69, 19) -- 8B4513 
		end
	end
end

-- Vigilance
if not(TagMethods["guis:vigilance"]) then
	TagEvents["guis:vigilance"] = "UNIT_AURA"
	TagMethods["guis:vigilance"] = function(unit)
		if UnitAura(unit, GetSpellInfo(50720)) then 
			return indicator(139, 69, 19) -- 8B4513 
		end
	end
end

-- Power Word: Barrier
if not(TagMethods["guis:pwb"]) then
	TagEvents["guis:pwb"] = "UNIT_AURA"
	TagMethods["guis:pwb"] = function(unit)
		if UnitAura(unit, GetSpellInfo(81782)) then 
			return indicator(238, 238, 0) -- EEEE00
		end
	end
end

-- Power Word: Shield
if not(TagMethods["guis:pws"]) then
	TagEvents["guis:pws"] = "UNIT_AURA"
	TagMethods["guis:pws"] = function(unit)
		if UnitAura(unit, GetSpellInfo(17)) then 
			return indicator(51, 255, 51) -- 33FF33
		end
	end
end

-- Renew
if not(TagMethods["guis:renew"]) then
	TagEvents["guis:renew"] = "UNIT_AURA"
	TagMethods["guis:renew"] = function(unit)
		local name, _,_,_,_,_, expirationTime, caster = UnitAura(unit, GetSpellInfo(139))
		if (caster == "player") then
			local spellTimer = GetTime() - expirationTime
			if (spellTimer > -2) then
				return indicator(255, 0, 0) -- FF0000
			elseif (spellTimer > -4) then
				return indicator(255, 153, 0) -- FF9900
			else
				return indicator(51, 255, 51) -- 33FF33
			end
		end	
	end
end

if not(TagMethods["guis:renewTime"]) then
	TagMethods["guis:renewTime"] = function(unit)
		local name, _,_,_,_,_, expirationTime, caster = UnitAura(unit, GetSpellInfo(139))
		if (caster == "player") then 
			return getTime(expirationTime)
		end 
	end
end

-- Rejuvenation
if not(TagMethods["guis:rejuv"]) then
	TagEvents["guis:rejuv"] = "UNIT_AURA"
	TagMethods["guis:rejuv"] = function(unit)
		local name, _,_,_,_,_, expirationTime, caster = UnitAura(unit, GetSpellInfo(774))
		if (caster == "player") then
			local spellTimer = GetTime() - expirationTime
			if (spellTimer > -2) then
				return indicator(255, 0, 0) -- FF0000
			elseif (spellTimer > -4) then
				return indicator(255, 153, 0) -- FF9900
			else
				return indicator(51, 255, 51) -- 33FF33
			end
		end	
	end
end

if not(TagMethods["guis:rejuvTime"]) then
	TagMethods["guis:rejuvTime"] = function(unit)
		local name, _,_,_,_,_, expirationTime, caster = UnitAura(unit, GetSpellInfo(774))
		if (caster == "player") then 
			return getTime(expirationTime)
		end 
	end
end

-- Regrowth
if not(TagMethods["guis:regrowth"]) then
	TagEvents["guis:regrowth"] = "UNIT_AURA"
	TagMethods["guis:regrowth"] = function(unit)
		if UnitAura(unit, GetSpellInfo(8936)) then 
			return indicator(0, 255, 16) -- 00FF10 
		end
	end
end

-- Wild Growth
if not(TagMethods["guis:wildgrowth"]) then
	TagEvents["guis:wildgrowth"] = "UNIT_AURA"
	TagMethods["guis:wildgrowth"] = function(unit)
		if UnitAura(unit, GetSpellInfo(48438)) then 
			return indicator(51, 255, 51) -- 33FF33
		end
	end
end

-- Riptide
if not(TagMethods["guis:riptide"]) then
	TagEvents["guis:riptide"] = "UNIT_AURA"
	TagMethods["guis:riptide"] = function(unit)
		local name, _,_,_,_,_,_, caster = UnitAura(unit, GetSpellInfo(61295))
		if (caster == 'player') then 
			return indicator(0, 254, 191) -- 00FEBF
		end
	end
end

if not(TagMethods["guis:riptideTime"]) then
	TagMethods["guis:riptideTime"] = function(unit)
		local name, _,_,_,_,_, expirationTime, caster = UnitAura(unit, GetSpellInfo(61295))
		if (caster == "player") then 
			return getTime(expirationTime)
		end 
	end
end

-- Beacon of Light 
if not(TagMethods["guis:beacon"]) then
	TagEvents["guis:beacon"] = "UNIT_AURA"
	TagMethods["guis:beacon"] = function(unit)
		local name, _,_,_,_,_, expirationTime, caster = UnitAura(unit, GetSpellInfo(53563))
		if not name then return end
		if (caster == "player") then
			local spellTimer = GetTime() - expirationTime
			if (spellTimer > -30) then
				return indicator(255, 0, 0) -- FF0000
			else
				return indicator(255, 204, 0) -- FFCC00
			end
		else
			return indicator(153, 102, 0) -- 996600 
		end
	end
end
	
-- Lifebloom
if not(TagMethods["guis:lifebloom"]) then
	TagEvents["guis:lifebloom"] = "UNIT_AURA"
	TagMethods["guis:lifebloom"] = function(unit)
		local name, _,_, count,_,_, expirationTime, caster = UnitAura(unit, GetSpellInfo(33763))
		if (caster == "player") then
			local spellTimer = GetTime() - expirationTime
			if (spellTimer > -2) then
				return indicator(255, 0, 0, count, 3) -- FF0000
			elseif (spellTimer > -4) then
				return indicator(255, 153, 0, count, 3) -- FF9900
			else
				return indicator(167, 253, 10, count, 3) -- A7FD0A
			end
		end	
	end
end

-- Prayer of Mending
if not(TagMethods["guis:mending"]) then
	TagEvents["guis:mending"] = "UNIT_AURA"
	TagMethods["guis:mending"] = function(unit)
    local name, _,_, count, _,_,_, caster = UnitAura(unit, GetSpellInfo(33076)) 
		if not(count) then return end
		if (caster == "player") then
			return indicator(102, 255, 255, count, 5) -- 66FFFF 
		else
			return indicator(255, 207, 127, count, 5) -- FFCF7F 
		end
	end
end

-- Earth Shield
if not(TagMethods["guis:earthshield"]) then
	TagEvents["guis:earthshield"] = "UNIT_AURA"
	TagMethods["guis:earthshield"] = function(unit)
		local count = select(4, UnitAura(unit, GetSpellInfo(974))) 
		if (count) then 
			return indicator(255, 207, 127, count, 9) -- FFCF7F 
		end 
	end
end

-- Curse Debuff
if not(TagMethods["guis:curse"]) then
	TagEvents["guis:curse"] = "UNIT_AURA"
	TagMethods["guis:curse"] = function(unit)
		return hasDebuffType(unit, "Curse")
	end
end

-- Disease Debuff
if not(TagMethods["guis:disease"]) then
	TagEvents["guis:disease"] = "UNIT_AURA"
	TagMethods["guis:disease"] = function(unit)
		return hasDebuffType(unit, "Disease")
	end
end

-- Magic Debuff
if not(TagMethods["guis:magic"]) then
	TagEvents["guis:magic"] = "UNIT_AURA"
	TagMethods["guis:magic"] = function(unit)
		return hasDebuffType(unit, "Magic")
	end
end

-- Poison Debuff
if not(TagMethods["guis:poison"]) then
	TagEvents["guis:poison"] = "UNIT_AURA"
	TagMethods["guis:poison"] = function(unit)
		return hasDebuffType(unit, "Poison")
	end
end
