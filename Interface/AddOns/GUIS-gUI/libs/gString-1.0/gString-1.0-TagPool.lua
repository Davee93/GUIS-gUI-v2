--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

assert(LibStub("gString-1.0"), "Couldn't find an instance of gString-1.0")

-- Lua API
local floor, max = math.floor, math.max
local type, tonumber = type, tonumber
local pairs, select = pairs, select
local format, gsub = string.format, string.gsub
local tconcat = table.concat

-- WoW API
local GetCombatRatingBonus = GetCombatRatingBonus
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerNumSlots = GetContainerNumSlots
local GetCritChance = GetCritChance
local GetGameTime = GetGameTime
local GetMoney = GetMoney
local GetRangedCritChance = GetRangedCritChance
local GetSpellBonusDamage = GetSpellBonusDamage
local GetSpellBonusHealing = GetSpellBonusHealing
local GetSpellCritChance = GetSpellCritChance
local GetWintergraspWaitTime = GetWintergraspWaitTime
local UnitAttackPower = UnitAttackPower
local UnitRangedAttackPower = UnitRangedAttackPower

local RegisterTag = function(...) LibStub("gString-1.0"):RegisterTag(...) end

local GetContainerSpace
local CreateIcon

local BAGSTRINGS = {
	["backpack"] = { 0 };
	["bags"] = { 1, 2, 3, 4 };
	["backpack+bags"] = { 0, 1, 2, 3, 4, };
	["bank"] = { 5, 6, 7, 8, 9, 10, 11 };
	["bankframe"] = { -1 };
	["bankframe+bank"] = { -1, 5, 6, 7, 8, 9, 10, 11 };
	["keyring"] = { -2 };
}

function GetContainerSpace(bags)
	if not bags or type(bags) ~= "string" or not BAGSTRINGS[bags] then return end

	local free, total, used = 0, 0, 0
	for _,i in pairs(BAGSTRINGS[bags]) do
		free, total, used = free + GetContainerNumFreeSlots(i), total + GetContainerNumSlots(i), total - free
	end
	
	return free, total, used, floor(free / total * 100)
end

function CreateIcon(iconPath, iconValues)
	if not iconPath or type(iconPath) ~= "string" then return end
	iconValues = type(iconValues) == "string" and iconValues or "0:0:0:0"

	if type(iconValues) == "table" then
		iconValues = tconcat(iconValues, ":")
	end
	
	return ("|T%s:%s|t"):format(iconPath, iconValues)
end

------------------------------------------------------------------------------------------------------------
-- 	Tag Library
------------------------------------------------------------------------------------------------------------
local goldIcon = CreateIcon("Interface\\MoneyFrame\\UI-GoldIcon", "0:0:0:0")
local silverIcon = CreateIcon("Interface\\MoneyFrame\\UI-SilverIcon", "0:0:0:0")
local copperIcon = CreateIcon("Interface\\MoneyFrame\\UI-CopperIcon", "0:0:0:0")
RegisterTag("money", function(money, full)
	money = money and tonumber(money) or (GetMoney())

	local str
	local g,s,c = floor(money/1e4), floor(money/100) % 100, money % 100

	if full then
		if g > 0 then str = (str and str.."" or "") .. g .. goldIcon end
		if s > 0 or g > 0 then str = (str and str.."" or "") .. s .. silverIcon end
		str = (str and str.."" or "") .. c .. copperIcon
		return str
	else
		if g > 0 then str = (str and str.."" or "") .. g .. goldIcon end
		if s > 0 then str = (str and str.."" or "") .. s .. silverIcon end
		if c > 0 or g + s + c == 0 then str = (str and str.."" or "") .. c .. copperIcon end
		return str
	end
end)

RegisterTag("free", function(bags)
	if not BAGSTRINGS[bags] then return end
	return (select(1, GetContainerSpace(bags)))
end)

RegisterTag("max", function(bags)
	if not BAGSTRINGS[bags] then return end
	return (select(2, GetContainerSpace(bags))) 
end)

RegisterTag("used", function(bags)
	if not BAGSTRINGS[bags] then return end
	return (select(3, GetContainerSpace(bags)))
end)

RegisterTag("freepercent", function(bags)
	if not BAGSTRINGS[bags] then return end
	return (select(4, GetContainerSpace(bags))).."%"
end)

RegisterTag("usedpercent", function(bags)
	if not BAGSTRINGS[bags] then return end
	return (100 - (select(4, GetContainerSpace(bags)))).."%"
end)

RegisterTag("shortvalue", function(value)
	value = tonumber(value)

	if not(value) then return "0.0" end
	
	if (value >= 1e6) then
		return ("%.1fM"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif (value >= 1e3) or (value <= -1e3) then
		return ("%.1fK"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return value
	end	
end)

-- colored version of the above tag
RegisterTag("shortvaluecolored", function(value)
	value = tonumber(value)

	if not(value) then return "0.0" end
	
	if (value >= 1e6) then
		return ("|cFFFFD200%.1f|r|cFFFFFFFFM|r"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif (value >= 1e3) or (value <= -1e3) then
		return ("|cFFFFD200%.1f|r|cFFFFFFFFK|r"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return ("|cFFFFD200%.1f|r"):format(value)
	end	
end)

RegisterTag("smarttime", function(seconds)
	if not(seconds) then return "0.0" end
	
	seconds = tonumber(seconds)
	
	local day, hour, minute = 86400, 3600, 60
	if (seconds >= day) then
		return format("%dd", floor(seconds / day + 0.5)), seconds % day
	elseif (seconds >= hour) then
		return format("%dh", floor(seconds / hour + 0.5)), seconds % hour
	elseif (seconds >= minute) then
		if (seconds <= (minute * 5)) then
			return format("%d:%02d", floor(seconds / 60), seconds % minute), seconds - floor(seconds)
		end
		return format("%dm", floor(seconds / minute + 0.5)), seconds % minute
	elseif (seconds >= minute / 12) then
		return floor(seconds + 0.5), (seconds * 100 - floor(seconds * 100)) / 100
	end
	return format("%.1f", seconds), (seconds * 100 - floor(seconds * 100)) / 100
end)

RegisterTag("time", function(timezone)
	timezone = timezone and timezone:lower() or "game"

	if timezone == "local" or timezone == "local24" then
		return date("%H:%M")

	elseif timezone == "local12" then
		return date("%I:%M %p")

	elseif timezone == "game" or timezone == "game24" then
		local hours, minutes = GetGameTime()
		return (format("%02d", hours)..":"..format("%02d", minutes))

	elseif timezone == "game12" then
		local hours, minutes = GetGameTime()
		return (format("%02d", ((hours > 12) or (hours < 1)) and (hours - 12) or hours)..":"..format("%02d", minutes)..((hours > 12) and " PM" or " AM"))

	elseif timezone == "pvp" then
		local sec = GetPVPTimer()
		if (sec >= 0) and (sec <= 301000) then
			seconds = floor(seconds / 1000)
			return (format("%d", floor(seconds / 60) % 60)..":"..format("%02d", seconds % 60))
		else
			return "--:--"
		end

	elseif timezone == "wintergrasp" then
		local seconds = GetWintergraspWaitTime()
		if seconds then
			return (format("%d", floor(seconds / 3600))..":"..format("%02d", floor(seconds / 60) % 60)..":"..format("%02d", seconds % 60))
		else
			return ("--:--")
		end
	end
end)

RegisterTag("ap", function(unit)
	local base, posBuff, negBuff = UnitAttackPower(unit or "player")
	return base + posBuff + negBuff
end)

RegisterTag("rap", function(unit)
	local base, posBuff, negBuff = UnitRangedAttackPower(unit or "player")
	return base + posBuff + negBuff
end)

--
-- Following ratings are for the unit "player" only
--
RegisterTag("sp", function()
	return max(GetSpellBonusDamage(2), GetSpellBonusDamage(3), GetSpellBonusDamage(4), GetSpellBonusDamage(5), GetSpellBonusDamage(6), GetSpellBonusDamage(7), GetSpellBonusHealing())
end)

RegisterTag("mcrit", function() return format("%.1f",GetCritChance()) end)

RegisterTag("rcrit", function() return format("%.1f", GetRangedCritChance()) end)

RegisterTag("scrit", function()
	return format("%.1f",(max(GetSpellCritChance(2), GetSpellCritChance(3), GetSpellCritChance(4), GetSpellCritChance(5), GetSpellCritChance(6), GetSpellCritChance(7))))
end)

RegisterTag("mhaste", function() return format("%.1f", GetCombatRatingBonus(18)) end)

RegisterTag("rhaste", function() return format("%.1f", GetCombatRatingBonus(19)) end)

RegisterTag("shaste", function() return format("%.1f", GetCombatRatingBonus(20)) end)
