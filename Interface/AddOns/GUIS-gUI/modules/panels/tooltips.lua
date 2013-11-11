--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

assert(LibStub("gFrameHandler-1.0"), "Couldn't find an instance of gFrameHandler-1.0")
assert(LibStub("gString-1.0"), "Couldn't find an instance of gString-1.0")
assert(LibStub("gPanel-2.0"), "Couldn't find an instance of gPanel-2.0")

-- Lua API
local format, gsub = string.format, string.gsub
local ipairs, pairs, select = ipairs, pairs, select
local abs, ceil, floor, log, max = math.abs, math.ceil, math.floor, math.log, math.max
local collectgarbage = collectgarbage
local unpack = unpack
local tinsert, tsort = table.insert, table.sort

-- WoW API
local ContainerIDToInventoryID = ContainerIDToInventoryID
local CreateFrame = CreateFrame
local GetAddOnInfo = GetAddOnInfo
local GetAddOnMemoryUsage = GetAddOnMemoryUsage
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local GetBagName = GetBagName
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetContainerItemDurability = GetContainerItemDurability
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerNumSlots = GetContainerNumSlots
local GetExpertise = GetExpertise
local GetExpertisePercent = GetExpertisePercent
local GetFriendInfo = GetFriendInfo
local GetGuildFactionInfo = GetGuildFactionInfo
local GetGuildInfo = GetGuildInfo
local GetGuildLevel = GetGuildLevel
local GetGuildRosterMOTD = GetGuildRosterMOTD
local GetInventoryItemDurability = GetInventoryItemDurability
local GetNetStats = GetNetStats
local GetNumAddOns = GetNumAddOns
local GetNumFriends = GetNumFriends
local GetNumWatchedTokens = GetNumWatchedTokens
local GetRealmName = GetRealmName
local GetRealZoneText = GetRealZoneText
local GetSpellBonusDamage = GetSpellBonusDamage
local GetSpellBonusHealing = GetSpellBonusHealing
local GetSpellCritChance = GetSpellCritChance
local GetSpellPenetration = GetSpellPenetration
local GetText = GetText
local GetWatchedFactionInfo = GetWatchedFactionInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetXPExhaustion = GetXPExhaustion
local IsAddOnLoaded = IsAddOnLoaded
local BNGetFriendInfo = BNGetFriendInfo
local BNGetNumFriends = BNGetNumFriends
local BNGetToonInfo = BNGetToonInfo
local UnitFactionGroup = UnitFactionGroup
local UnitGetGuildXP = UnitGetGuildXP
local UnitSex = UnitSex
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage

local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE

-- GUIS API
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterTooltip = function(...) LibStub("gPanel-2.0"):RegisterTooltip(...) end
local RAID_CLASS_COLORS = C["RAID_CLASS_COLORS"]
local RGBToHex = RGBToHex

local clientLocale = GetLocale(); if (clientLocale == "enGB") then clientLocale = "enUS" end -- for simplicity
local clientRealm = GetRealmName()
local playerFaction = UnitFactionGroup("player")

local loadModule = function(name)
	local module = LibStub("gCore-3.0"):GetModule(name)
	local dead = F.kill(name)

	if ((module) and not(dead)) then
		return module
	end
end

------------------------------------------------------------------------------------------------------------
-- 	Tooltips
------------------------------------------------------------------------------------------------------------
--[[
	RegisterTooltip("Name_of_Tip", function(self)
		-- set up tooltip, positioning is optional as this will be done by library
		
		-- show the tip. not done by library
		GameTooltip:Show()
	end)
]]--

-- generic all-purpose tooltips
RegisterTooltip("LeftClickForMore", function(self)
	GameTooltip:AddLine("")
	GameTooltip:AddLine(L["<Left-Click for more>"], unpack(C["value"]))
	GameTooltip:Show()
end)

RegisterTooltip("RightClickForOptions", function(self)
	GameTooltip:AddLine("")
	GameTooltip:AddLine(L["<Right-Click for options>"], unpack(C["value"]))
	GameTooltip:Show()
end)

RegisterTooltip("LeftClickForMoreRightClickForOptions", function(self)
	GameTooltip:AddLine("")
	GameTooltip:AddLine(L["<Left-Click for more>"], unpack(C["value"]))
	GameTooltip:AddLine(L["<Right-Click for options>"], unpack(C["value"]))
	GameTooltip:Show()
end)

RegisterTooltip("Bags", function(self)
	GameTooltip:AddLine(L["Bags"], unpack(C["index"]))
	GameTooltip:AddLine(" ")

	local name, link, invID
	local min, max, free, total, used = 0, 0, 0, 0, 0
	local space = "%d|cFF" .. RGBToHex(unpack(C["index"])) .. "/|r%d"
	
	for i = 0, NUM_BAG_SLOTS do
		invID = not(i == 0) and ContainerIDToInventoryID(i) 
		link = GetBagName(i)
		free = GetContainerNumFreeSlots(i)
		total = GetContainerNumSlots(i)
		
		local r, g, b = unpack(C["index"])
		local r2, g2, b2 = unpack(C["value"])
		
		if (total) and (total > 0) then
			GameTooltip:AddDoubleLine(link, space:format(free, total), r, g, b, r2, g2, b2)
		else
			GameTooltip:AddLine(L["No container equipped in slot %d"]:format(i), 1, 0, 0)
		end
	end
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["<Left-Click to open all bags>"], unpack(C["value"]))

	if (loadModule("GUIS-gUI: Bags")) then
		GameTooltip:AddLine(L["<Right-Click for options>"], unpack(C["value"]))
	end
	
	GameTooltip:Show()
end)

local BFriends = {}
local green = { r = 0.35, g = 0.75, b = 1 }
local red = { r = 0, g = 1, b = 0 }
local white = { r = 1, g = 1, b = 1 }
RegisterTooltip("Friends", function(self)
	-- update the list. really needed?
	ShowFriends()
	
	local BFriends = BFriends
	local friendTable = F.getFriendTable()
	local BNfriendTable = F.getBNFriendTable()
	local localClass, classc, lvlcol, zonecol, left, right
	local friendsOnline = 0
	local t = self.lib.text
	
	wipe(BFriends)
	
	GameTooltip:AddLine(FRIENDS, unpack(C["index"]))
	GameTooltip:AddLine(" ")
	
	-- create bnet list
	for i = 1, #BNfriendTable do
		if (BNfriendTable[i].isOnline) then
			friendsOnline = friendsOnline + 1
			
			if (BNfriendTable[i].client == BNET_CLIENT_WOW) then
				-- temporarily store the character name if it is the same realm and faction as the player
				if (BNfriendTable[i].realmName == clientRealm) then -- (BNfriendTable[i].isFriend)
					if ((playerFaction == "Alliance") and (BNfriendTable[i].faction == 1)) or ((playerFaction == "Horde") and (BNfriendTable[i].faction == 0)) then
						BFriends[BNfriendTable[i].toonName] = true
					end
				end
				
				for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do 
					if (BNfriendTable[i].class == v) then 
						localClass = k 
					end 
				end

				-- feminine class localization
				if (clientLocale ~= "enUS") then 
					for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do 
						if (BNfriendTable[i].class == v) then 
							localClass = k 
						end 
					end
				end
				
				classc = RAID_CLASS_COLORS[localClass] or green
				lvlcol = (BNfriendTable[i].level) and (tonumber(BNfriendTable[i].level)) and GetQuestDifficultyColor(tonumber(BNfriendTable[i].level)) or white
				zonecol = (GetRealZoneText() == BNfriendTable[i].zoneName) and green or white
				
				left = "|cFF" .. RGBToHex(lvlcol.r, lvlcol.g, lvlcol.b) .. BNfriendTable[i].level .. "|r|cFFFFFFFF:|r "
				left = left .. "|cFF" .. RGBToHex(classc.r, classc.g, classc.b)
				left = left .. BNfriendTable[i].toonName .. " " .. (BNfriendTable[i].AFK and CHAT_FLAG_AFK or "") .. (BNfriendTable[i].DND and CHAT_FLAG_DND or "") .. "|r"
				left = left .. t("(" .. BNfriendTable[i].givenName .. " " .. BNfriendTable[i].surName .. ")", true)

				if (BNfriendTable[i].noteText) and (BNfriendTable[i].noteText ~= "") then 
					left = left.. t("(" .. BNfriendTable[i].noteText .. ")", true) 
				end

				if (BNfriendTable[i].realmName == clientRealm) then
					right = "|cFF" .. RGBToHex(zonecol.r, zonecol.g, zonecol.b) .. BNfriendTable[i].zoneName .. "|r"
				else
					right = BNfriendTable[i].gameText
				end
				GameTooltip:AddDoubleLine(left, right)
			else
				left = ""
				
				if (BNfriendTable[i].givenName) then
					left = left .. "|cFFFFFFFF" .. BNfriendTable[i].givenName .. "|r"
				end

				if (BNfriendTable[i].surName) then
					left = left .. " |cFFFFFFFF" .. BNfriendTable[i].surName .. "|r"
				end

				if (BNfriendTable[i].toonName) then
					left = left .. " |cFFFFFFFF(|r"..BNfriendTable[i].toonName.."|cFFFFFFFF)|r" or ""
				end

				if (BNfriendTable[i].noteText) then
					left = left ..  "|cFF00FF00 "..BNfriendTable[i].noteText.." |r"
				end
				
				right = ""
				
				if (BNfriendTable[i].client) then
					right = right .. " " .. BNfriendTable[i].client
				end
				
				if (BNfriendTable[i].gameText) then
					right = right .. "|cFFFF7D0A ("..BNfriendTable[i].gameText..") |r"
				end
				
				if (left ~= "") then
					GameTooltip:AddDoubleLine(left, right)
				end
			end
		end
	end
	
	-- create friends list
	for i = 1, #friendTable do
		if (friendTable[i].connected) and not(BFriends[friendTable[i].name]) then 
			friendsOnline = friendsOnline + 1

			for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do 
				if (friendTable[i].class == v) then 
					localClass = k 
				end 
			end

			-- feminine class localization
			if (clientLocale ~= "enUS") then 
				for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do 
					if (friendTable[i].class == v) then 
						localClass = k 
					end 
				end
			end

			classc = RAID_CLASS_COLORS[localClass] or green
			lvlcol = GetQuestDifficultyColor(friendTable[i].level)
			zonecol = (GetRealZoneText() == friendTable[i].area) and green or white

			left = "|cFF" .. RGBToHex(lvlcol.r, lvlcol.g, lvlcol.b) .. friendTable[i].level .. "|r"
			left = left .. "|cFFFFFFFF:|r |cFF" .. RGBToHex(classc.r, classc.g, classc.b) .. friendTable[i].name .. " " .. friendTable[i].status .. "|r"

			if (friendTable[i].note) then 
				left = left .. "|cFFFFFFFF (" .. friendTable[i].note .. ") |r" 
			end

			right = "|cFF" .. RGBToHex(zonecol.r, zonecol.g, zonecol.b) .. friendTable[i].area .. "|r"

			GameTooltip:AddDoubleLine(left, right)
		end
	end
	
	if (friendsOnline == 0) then
		GameTooltip:AddLine(NOT_APPLICABLE, unpack(C["index"]))
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["<Left-Click to toggle Friends pane>"], unpack(C["value"]))
	GameTooltip:AddLine(L["<Right-Click for options>"], unpack(C["value"]))
	GameTooltip:Show()
end)

RegisterTooltip("Guild", function(self) 
	local numberofguildies = GetNumGuildMembers(false)
	if not(numberofguildies) or (numberofguildies < 1) then
		return
	end

	local guildTable = F.updateGuildTable()
	
	local maxDisplayedGuildies = 30
	local displayedGuildies = min(maxDisplayedGuildies, #guildTable)
	local gmotd = GetGuildRosterMOTD()
	local level = GetGuildLevel()
	local gender = UnitSex("player")
	local name, description, standingID, barMin, barMax, barValue, _, _, _, _, _, _, _, repToCap, weeklyCap = GetGuildFactionInfo()
	local r, g, b = unpack(C["index"])
	local r2, g2, b2 = unpack(C["value"])
	local col = "|cFF" .. RGBToHex(r2, g2, b2)
	
	if not(standingID == 8) then 
		local r = C["FACTION_BAR_COLORS"][standingID].r 
		local g = C["FACTION_BAR_COLORS"][standingID].g 
		local b = C["FACTION_BAR_COLORS"][standingID].b 
		
		name = name .. " (|cFF" .. RGBToHex(r, g, b) .. GetText("FACTION_STANDING_LABEL" .. standingID, gender) .. "|r)"
	end
	
	local nameString = ((level == 25) and "%s" or "%s [" .. col .. level .. "|r]"):format(name or GetGuildInfo("player") or NOT_APPLICABLE)
	local onlineString = ("%d".. "|cFFFFFFFF/|r" .. "%d"):format(#guildTable, numberofguildies)
	
	GameTooltip:AddDoubleLine(nameString, onlineString, r, g, b, r2, g2, b2)

	if (gmotd) and not(gmotd == "") then
		GameTooltip:AddLine(gmotd, ChatTypeInfo["GUILD"].r, ChatTypeInfo["GUILD"].g, ChatTypeInfo["GUILD"].b)
	end
	
	GameTooltip:AddLine(" ")

	if (level ~= 25) then
		local current, remaining, daily, dailymax = UnitGetGuildXP("player")
		local nextlevel = current + remaining
		
		if (nextlevel) and (dailymax) and not((nextlevel == 0) or (dailymax == 0)) then 
			local totalpercent = col .. tostring(ceil((current / nextlevel) * 100)) .. "|r"
			local dailypercent = col .. tostring(ceil((daily / dailymax) * 100)) .. "|r"
			local current = col .. ("[shortvalue:%d]"):format(current):tag() .. "|r"
			local nextlevel = col .. ("[shortvalue:%d]"):format(nextlevel):tag() .. "|r"
			local daily = col .. ("[shortvalue:%d]"):format(daily):tag() .. "|r"
			local dailymax = col .. ("[shortvalue:%d]"):format(dailymax):tag() .. "|r"
			
			GameTooltip:AddLine(("%s:"):format(GUILD_EXPERIENCE), unpack(C["index"]))
			GameTooltip:AddLine(GUILD_EXPERIENCE_CURRENT:format(current, nextlevel, totalpercent), r, g, b)
			GameTooltip:AddLine(GUILD_EXPERIENCE_DAILY:format(daily, dailymax, dailypercent), r, g, b)
			GameTooltip:AddLine(" ")
		end
	end
	
	if not(standingID == 8) then 
		local percent = col .. tostring(floor(((barValue - barMin) / (barMax - barMin)) * 100)) .. "|r"
		barValue = col .. ("[shortvalue:%d]"):format(barValue - barMin):tag() .. "|r"
		barMax = col .. ("[shortvalue:%d]"):format(barMax - barMin):tag() .. "|r"
		
		GameTooltip:AddLine(("%s:"):format(GUILD_REPUTATION), r, g, b)
		GameTooltip:AddLine(GUILD_EXPERIENCE_CURRENT:format(barValue, barMax, percent), r, g, b)
		
		if (repToCap) and (weeklyCap) and not(weeklyCap == 0) then
			percent = col .. tostring(floor(((weeklyCap - repToCap) / weeklyCap) * 100)) .. "|r"
			repToCap = col .. ("[shortvalue:%d]"):format(weeklyCap - repToCap):tag() .. "|r"
			weeklyCap = col .. ("[shortvalue:%d]"):format(weeklyCap):tag() .. "|r"

			GameTooltip:AddLine(GUILD_REPUTATION_WEEKLY:format(repToCap, weeklyCap, percent), r, g, b)
		end
		
		GameTooltip:AddLine(" ")
	end
	
	for i = 1, displayedGuildies do
		GameTooltip:AddDoubleLine(guildTable[i][1], guildTable[i][2], guildTable[i][3], guildTable[i][4], guildTable[i][5], guildTable[i][6], guildTable[i][7], guildTable[i][8])
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["<Left-Click to toggle Guild pane>"], r2, g2, b2)
	GameTooltip:AddLine(L["<Right-Click for options>"], r2, g2, b2)
	GameTooltip:Show()
end)

RegisterTooltip("NetStats", function(self)
	local down, up, home, world = GetNetStats()
	local t = self.lib.text
	local stat = "|cFFFFD200%d|r|cFFFFFFFF%s|r"

	local r, g, b = unpack(C["index"])
	local r2, g2, b2 = unpack(C["value"])

	GameTooltip:AddLine(L["Network Stats"], r, g, b)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["World latency %s:"]:format(L["(Combat, Casting, Professions, NPCs, etc)"]), stat:format(world, MILLISECONDS_ABBR), r, g, b, r2, g2, b2)
	GameTooltip:AddDoubleLine(L["Realm latency %s:"]:format(L["(Chat, Auction House, etc)"]), stat:format(home, MILLISECONDS_ABBR), r, g, b, r2, g2, b2)
--	GameTooltip:AddLine(" ")
--	GameTooltip:AddLine(L["<Right-Click for options>"], r2, g2, b2)
	GameTooltip:Show()
end)

RegisterTooltip("Memory", function(self) 
	collectgarbage("collect")
	UpdateAddOnMemoryUsage()
	
	local memory = {}
	local total = 0
	local numAddOns = GetNumAddOns()

	local formatMemory = function(bytes)
		bytes = bytes * 1024
		local s, e = {"B", "KB", "MB", "GB", "TB"}, floor(abs(log(bytes+1)/log(1024)))
		
--		ADDON_MEM_KB_ABBR = "(%.0f KB) %s"
--		ADDON_MEM_MB_ABBR = "(%.2f MB) %s"
		
		return format("%.1f "..s[e+1], (bytes/1024^e))
	end
	
	if (numAddOns) and (numAddOns >0) then
		for i = 1, GetNumAddOns() do
			local mem = GetAddOnMemoryUsage(i)
			memory[i] = { select(2, GetAddOnInfo(i)), mem, IsAddOnLoaded(i) }
			total = total + mem
		end
		
		sort(memory, function(a, b)
			if a and b then
				return a[2] > b[2]
			end
		end)
		
		local r, g, b = unpack(C["index"])
		local r2, g2, b2 = unpack(C["value"])

		GameTooltip:AddDoubleLine(L["Total Usage"], formatMemory(total), r, g, b, r2, g2, b2)
		GameTooltip:AddLine(" ")
		
		local maxShown = 30
		local Shown = 0
		local leftOvers = total
		
		for i = 1, #memory do
			if memory[i][3] then 
				if (Shown < maxShown) then
					local red = memory[i][2] / total * 2
					local green = 1 - red
					GameTooltip:AddDoubleLine(memory[i][1], formatMemory(memory[i][2]), r, g, b, red, green+1, 0)
					
					leftOvers = leftOvers - memory[i][2]
				end
				Shown = Shown + 1
			end
		end
		
		if (Shown > maxShown) then
			local red = leftOvers / total * 2
			local green = 1 - red
	--		GameTooltip:AddLine("+" .. (Shown - maxShown) .. " " .. ADDONS)
			GameTooltip:AddDoubleLine("...", formatMemory(leftOvers), r, g, b, red, green + 1, 0)
		end

		GameTooltip:AddLine(" ")
	end
	
	do 
		local down, up, home, world = GetNetStats()
		local t = self.lib.text
		local stat = "|cFFFFD200%d|r|cFFFFFFFF%s|r"

		local r, g, b = unpack(C["index"])
		local r2, g2, b2 = unpack(C["value"])

		GameTooltip:AddDoubleLine(L["World latency %s:"]:format(L["(Combat, Casting, Professions, NPCs, etc)"]), stat:format(world, MILLISECONDS_ABBR), r, g, b, r2, g2, b2)
		GameTooltip:AddDoubleLine(L["Realm latency %s:"]:format(L["(Chat, Auction House, etc)"]), stat:format(home, MILLISECONDS_ABBR), r, g, b, r2, g2, b2)
	end

	GameTooltip:Show()
end)

RegisterTooltip("Time", function(self) 
	GameTooltip:AddLine(TIMEMANAGER_TOOLTIP_TITLE, unpack(C["index"]))
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_LOCALTIME, ("[time:local]"):tag())
	GameTooltip:AddDoubleLine(TIMEMANAGER_TOOLTIP_REALMTIME, ("[time:game]"):tag())
	GameTooltip:Show()
end)

local currencyBag, currencyList = {}, {}
local nameSort = function(a,b) return a.name < b.name end
RegisterTooltip("Currency", function(self) 
	GameTooltip:AddLine(L["Tracked Currencies"], unpack(C["index"]))
	GameTooltip:AddLine(" ")

	local watchedTokens = GetNumWatchedTokens()
	local displayedTokens = 0
	
	wipe(currencyBag)
	wipe(currencyList)
	
	local r, g, b
	local name, count, icon
	
	-- update the backpack currency list
	for i = 1, watchedTokens  do
		name, count, icon = GetBackpackCurrencyInfo(i)
		if (count) then
			currencyBag[name] = true
			tinsert(currencyList, { name = name, count = count, icon = icon })
			
			displayedTokens = displayedTokens + 1
		end
	end

	-- iterate and update our custom tracked currency list
	local name, currentAmount, texture, earnedThisWeek, weeklyMax, totalMax, isDiscovered
	for id,_ in pairs(GUIS_DB["panels"].trackedCurrencies) do
		name, currentAmount, texture, earnedThisWeek, weeklyMax, totalMax, isDiscovered = GetCurrencyInfo(id)
		
		-- avoid duplicate entries
		if not(currencyBag[name]) then
			tinsert(currencyList, { name = name, count = currentAmount, icon = "Interface\\Icons\\" .. texture })
		end
	end
	
	tsort(currencyList, nameSort)
	
	-- list the currencies
	for i = 1, #currencyList do
		r, g, b = (currencyList[i].count > 0) and unpack(C["index"]) or unpack({ 0.4, 0.4, 0.4 })
		
		GameTooltip:AddDoubleLine(("|cFFFFFFFF%s|r"):format(currencyList[i].name), ("|cFFFFFFFF%d|r |T%s:0:0:0:0|t"):format(currencyList[i].count, currencyList[i].icon), r, g, b, unpack(C["value"]) )
	end

	if (#currencyList == 0) then
		GameTooltip:AddLine(NOT_APPLICABLE, unpack(C["index"]))
	end
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["<Left-Click to toggle Currency frame>"], unpack(C["value"]))
	GameTooltip:AddLine(L["<Right-Click for options>"], unpack(C["value"]))
	GameTooltip:Show()
end)

local dummy = CreateFrame("GameTooltip")
RegisterTooltip("Durability", function(self)

	local slots = { "HeadSlot", "ShoulderSlot", "ChestSlot", "WaistSlot", "WristSlot", "HandsSlot", "LegsSlot", "FeetSlot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot" }		

	GameTooltip:AddLine(DURABILITY, unpack(C["index"]))
	GameTooltip:AddLine(" ")
	
	local eqcurrent, eqtotal, eqcost = 0, 0, 0
	for _, slot in ipairs(slots) do
		local item = _G["Character" .. slot]
		local exist, _, cost = dummy:SetInventoryItem("player", item:GetID())
		local current, total = GetInventoryItemDurability(item:GetID())

		if exist and cost and cost > 0 then
			eqcost = eqcost + cost
		end

		if current and total then
			eqcurrent = eqcurrent + current
			eqtotal = eqtotal + total
		end
	end

	local bgcurrent, bgtotal, bgcost = 0, 0, 0
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local cooldown, cost = dummy:SetBagItem(bag, slot)
			local current, total = GetContainerItemDurability(bag, slot)

			if cost and cost > 0 then
				bgcost = bgcost + cost
			end

			if current and total and current > 0 and total > 0 then
				bgcurrent = bgcurrent + current
				bgtotal = bgtotal + total
			end
		end
	end
	bgcost = max(bgcost, 0)
	
	-- division by zero cause funny funny results
	-- if total durabilities are 0, there are no items to show
	bgcurrent 	= bgtotal == 0 and 1 or bgcurrent
	bgtotal 	= bgtotal == 0 and 1 or bgtotal
	eqcurrent 	= eqtotal == 0 and 1 or eqcurrent
	eqtotal 	= eqtotal == 0 and 1 or eqtotal

	GameTooltip:AddDoubleLine("|cFFFFFFFF"..CURRENTLY_EQUIPPED..": (|r" .. ("%d"):format(eqcurrent / eqtotal * 100) .. "|cFFFFFFFF%)|r", ("|cFFFFFFFF[money:" .. eqcost .. "]|r"):tag())
	GameTooltip:AddDoubleLine("|cFFFFFFFF"..L["Bags"]..": (|r" .. ("%d"):format(bgcurrent / bgtotal * 100) .. "|cFFFFFFFF%)|r", ("|cFFFFFFFF[money:" .. bgcost .. "]|r"):tag())
	GameTooltip:AddDoubleLine("|cFFFFFFFF"..L["Total"]..": (|r" .. ("%d"):format((bgcurrent + eqcurrent) / (bgtotal + eqtotal) * 100) .. "|cFFFFFFFF%)|r", ("|cFFFFFFFF[money:" .. (eqcost + bgcost) .. "]|r"):tag())
	
	if (loadModule("GUIS-gUI: Merchant")) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["<Right-Click for options>"], unpack(C["value"]))
	end

	GameTooltip:Show()
end)

RegisterTooltip("MeleeStats", function(self) 
	mep, oep = GetExpertisePercent()
	me, oe = GetExpertise()
	
	GameTooltip:AddDoubleLine(ITEM_MOD_MELEE_ATTACK_POWER_SHORT..":", ("[ap]"):tag().." ("..("[mcrit]"):tag().."% "..CRIT_ABBR..")", 1,1,1, 1,1,1)
	GameTooltip:AddDoubleLine(ITEM_MOD_HASTE_MELEE_RATING_SHORT..":", GetCombatRating(18).." ("..("[mhaste]"):tag().."%)")
	GameTooltip:AddDoubleLine(ITEM_MOD_EXPERTISE_RATING_SHORT..":", GetCombatRating(24).." ("..format("%.2f", mep).."% / "..format("%.2f", oep).."%)")
	GameTooltip:AddDoubleLine(ITEM_MOD_HIT_MELEE_RATING_SHORT..":", GetCombatRating(6).." ("..format("%.2f", GetCombatRatingBonus(6)).."%)")

	GameTooltip:Show()
end)

RegisterTooltip("TankStats", function(self) 
end)

RegisterTooltip("CasterStats", function(self) 
	local sp, spcrit = {}, {}
	local currentsp, currentspcrit = GetSpellBonusHealing(), 0
	local iconpath = " |TInterface\\PaperDollInfoFrame\\SpellSchoolIcon"
	local iconpath2 = " |TInterface\\Icons\\Spell_Nature_HealingTouch"
	local iconcrop = ":16:16:0:0|t"

	sp[0] = GetSpellBonusHealing()
	for spid = 2,7 do 
		sp[spid] = GetSpellBonusDamage(spid)
		spcrit[spid] = GetSpellCritChance(spid)
		currentsp = max(currentsp, sp[spid])
		currentspcrit = max(currentspcrit, spcrit[spid])
	end
	
	-- ITEM_MOD_HIT_SPELL_RATING_SHORT -- spell hit

	GameTooltip:AddDoubleLine(ITEM_MOD_SPELL_POWER_SHORT..":", currentsp.." ("..format("%.2f", currentspcrit).."% "..CRIT_ABBR..")", 1,1,1, 1,1,1)
	GameTooltip:AddDoubleLine(ITEM_MOD_HASTE_SPELL_RATING_SHORT..":", format("%.2f", GetCombatRatingBonus(20)).."%")
	GameTooltip:AddDoubleLine(ITEM_MOD_SPELL_PENETRATION_SHORT..":", GetSpellPenetration())
	GameTooltip:AddDoubleLine(iconpath2..iconcrop.." "..BONUS_HEALING..": ", sp[0])
	GameTooltip:AddDoubleLine(iconpath.."2"..iconcrop.." "..SPELL_SCHOOL1_CAP..": ", sp[2])
	GameTooltip:AddDoubleLine(iconpath.."3"..iconcrop.." "..SPELL_SCHOOL2_CAP..": ", sp[3])
	GameTooltip:AddDoubleLine(iconpath.."4"..iconcrop.." "..SPELL_SCHOOL3_CAP..": ", sp[4])
	GameTooltip:AddDoubleLine(iconpath.."5"..iconcrop.." "..SPELL_SCHOOL4_CAP..": ", sp[5])
	GameTooltip:AddDoubleLine(iconpath.."6"..iconcrop.." "..SPELL_SCHOOL5_CAP..": ", sp[6])
	GameTooltip:AddDoubleLine(iconpath.."7"..iconcrop.." "..SPELL_SCHOOL6_CAP..": ", sp[7])

	GameTooltip:Show()
end)

RegisterTooltip("RangedStats", function(self) 
	GameTooltip:AddDoubleLine(ITEM_MOD_RANGED_ATTACK_POWER_SHORT..":", ("[rap]"):tag().." ("..("[rcrit]"):tag().."% "..CRIT_ABBR..")", 1,1,1, 1,1,1)
	GameTooltip:AddDoubleLine(ITEM_MOD_HASTE_RANGED_RATING_SHORT..":", GetCombatRating(19).." ("..("[rhaste]"):tag().."%)")
	GameTooltip:AddDoubleLine(ITEM_MOD_HIT_RANGED_RATING_SHORT..":", GetCombatRating(13).." ("..format("%.2f", GetCombatRatingBonus(13)).."%)")

	GameTooltip:Show()
end)

RegisterTooltip("Experience", function(self)
	local min = UnitXP("player") or 0
	local max = UnitXPMax("player") or 0
	local exhaust = GetXPExhaustion() or 0
	
	local xpgain = 100
	local r, g, b = unpack(C["index"])
	local iCol = "|cFF" .. RGBToHex(r, g, b)
	local vCol = "|cFF" .. RGBToHex(unpack(C["value"]))
	
	local current = vCol .. ("[shortvalue:%d]"):format(min):tag() .. "|r"
	local total = vCol .. ("[shortvalue:%d]"):format(max):tag() .. "|r"

	-- avoiding division by zero
	local percent, restpercent
	if (max == 0) then 
		percent = vCol .. "0|r"
		restpercent = vCol .. "0|r"
	else
		percent = vCol .. tostring(floor(min / max * 100)) .. "|r"
		restpercent = vCol .. tostring(floor(exhaust / max *100)) .. "|r"
	end


	local values = ("%s/%s - %s%%"):format(current, total, percent)
	local rested = (" (%s%% %s)"):format(restpercent, L["Rested"])
	
	if (exhaust > 0) then 
		xpgain = 200
		
		GameTooltip:AddLine(values .. rested, r, g, b)
		GameTooltip:AddLine("|cFF00FF00" .. L["%d%% of normal experience gained from monsters."]:format(xpgain) .. "|r")
	else
		GameTooltip:AddLine(values, r, g, b)
		GameTooltip:AddLine("|cFFFFFFFF" .. L["%d%% of normal experience gained from monsters."]:format(xpgain) .. "|r")
		GameTooltip:AddLine("|cFFFF0000" .. L["You should rest at an Inn."] .. "|r")
	end

	GameTooltip:Show()
end)

RegisterTooltip("Reputation", function(self)
	local RPName, RPStanding, RPMin, RPMax, RPValue = GetWatchedFactionInfo()
	if (RPName) then
		local gender = UnitSex("player")
		local r, g, b = unpack(C["index"])
		local r2, g2, b2 = unpack(C["value"])
		local r3, g3, b3 = C["FACTION_BAR_COLORS"][RPStanding].r, C["FACTION_BAR_COLORS"][RPStanding].g, C["FACTION_BAR_COLORS"][RPStanding].b 
		local vCol = "|cFF" .. RGBToHex(r2, g2, b2)
		local standing = "|cFF" .. RGBToHex(r3, g3, b3) .. GetText("FACTION_STANDING_LABEL" .. RPStanding, gender) .. "|r"
		local label = RPName .. " (" .. standing .. ")"
		local current = vCol .. ("[shortvalue:%d]"):format(RPValue - RPMin):tag() .. "|r"
		local total = vCol .. ("[shortvalue:%d]"):format(RPMax - RPMin):tag() .. "|r"
		local percent = vCol .. tostring(floor((RPValue - RPMin) / (RPMax - RPMin) * 100)) .. "|r"
		local values = ("%s/%s - (%s%%)"):format(current, total, percent)

		GameTooltip:AddLine(label, r, g, b)
		GameTooltip:AddLine(values, r, g, b)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["<Left-Click to toggle Reputation pane>"], r2, g2, b2)
		GameTooltip:Show()
	end
end)
