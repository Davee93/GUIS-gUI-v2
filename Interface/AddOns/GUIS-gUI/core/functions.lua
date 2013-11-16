--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local EventHandler = LibStub("gCore-3.0"):NewModule("GUIS-gUI: EventHandler")

-- Lua API
local unpack = unpack
local tinsert, tsort = table.insert, table.sort
local tonumber = tonumber
local strsplit = string.split

-- WoW API
local BNGetFriendInfo = BNGetFriendInfo
local BNGetNumFriends = BNGetNumFriends
local BNGetToonInfo = BNGetToonInfo
local GetAddOnMetadata = GetAddOnMetadata
local GetBuildInfo = GetBuildInfo
local GetGuildRosterInfo = GetGuildRosterInfo
local GetNumFriends = GetNumFriends
local GetNumGuildMembers = GetNumGuildMembers
local GetNumPartyMembers = GetNumGroupMembers or GetNumPartyMembers
local GetNumRaidMembers = GetNumGroupMembers or GetNumRaidMembers
local GetNumTalentTabs = GetNumTalentTabs
local GetNumWorldPVPAreas = GetNumWorldPVPAreas
local GetRealZoneText = GetRealZoneText
local GetTalentTabInfo = GetTalentTabInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetWorldPVPAreaInfo = GetWorldPVPAreaInfo
local IsInInstance = IsInInstance
local UnitIsRaidOfficer = UnitIsRaidOfficer

-- GUIS API
local F = LibStub("gDB-1.0"):NewDataBase("GUIS-gUI: Functions")
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local M = LibStub("gMedia-3.0")
local RegisterBucketEvent = function(...) EventHandler:RegisterBucketEvent(...) end
local RegisterCallback = function(...) EventHandler:RegisterCallback(...) end
local RGBToHex = RGBToHex

local RAID_CLASS_COLORS = C.RAID_CLASS_COLORS

local BNfriendTable = {}
local friendTable = {}
local guildTable = {}
local localizedClass, class = UnitClass("player")
local friendSort, BNSort

--[[
	http://www.wowpedia.org/AddOn_loading_process
		ADDON_LOADED
			This event fires whenever an AddOn has finished loading and the SavedVariables for that AddOn have been loaded from their file.
		SPELLS_CHANGED
			This event fires shortly before the PLAYER_LOGIN event and signals that information on the user's spells has been loaded and is available to the UI.
		PLAYER_LOGIN
			This event fires immediately before PLAYER_ENTERING_WORLD.
			Most information about the game world should now be available to the UI.
			All Sizing and Positioning of frames is supposed to be completed before this event fires.
			AddOns that want to do one-time initialization procedures once the player has "entered the world" should use this event instead of PLAYER_ENTERING_WORLD.
		PLAYER_ENTERING_WORLD
			This event fires immediately after PLAYER_LOGIN
			Most information about the game world should now be available to the UI. If this is an interface reload rather than a fresh log in, talent information should also be available.
			All Sizing and Positioning of frames is supposed to be completed before this event fires.
			This event also fires whenever the player enters/leaves an instance and generally whenever the player sees a loading screen
		PLAYER_ALIVE
			This event fires after PLAYER_ENTERING_WORLD
			Quest and Talent information should now be available to the UI
]]--

--[[
	Events related to entering/leaving PvP instances or World PvP Events:
		PLAYER_ENTERING_WORLD
		ZONE_CHANGED -- when the player moves between subzones in an area
		ZONE_CHANGED_INDOORS -- when the player moves between subzones in a city
		ZONE_CHANGED_NEW_AREA -- when the player enters/leaves an instance, or enters a new area (Stormwind City, Feralas, etc)
		
	The relevant functions below should always be called after PLAYER_ENTERING_WORLD and ZONE_CHANGED_NEW_AREA,
	to properly update the player's status.
]]--

-- returns true if the player is in a PvP instance
F.IsInPvPInstance = function()
	local inInstance, instanceType = IsInInstance()
	return ((inInstance) and ((instanceType == "pvp") or (instanceType == "arena")))
end

-- return true if the player is in a World PvP event (Wintergrasp and Tol Barad, and any other they might add)
F.IsInWorldPvP = function()
	local realZoneName = GetRealZoneText()

	local localizedName, isActive, canQueue, startTime, canEnter
	for pvpID = 1, GetNumWorldPVPAreas() do
		_, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(pvpID)
		if (isActive) and (localizedName == realZoneName) then
			return true
		end
	end
end

-- returns true if the player is in a PvP event
-- this includes Battlegrounds, Arena, Wintergrasp and Tol Barad
F.IsInPvPEvent = function()
	return (F.IsInPvPInstance()) or (F.IsInWorldPvP())
end

-- returns true if the player is a raid officer/leader (can set raid marks etc)
F.IsLeader = function()
	-- UnitIsRaidOfficer("player")
	return ((GetNumRaidMembers() > 0) or (GetNumPartyMembers() > 0)) and (IsPartyLeader() or IsRaidLeader() or IsRaidOfficer())
end

-- returns true if the player is a raid officer/leader, and NOT in a PvP instance or World Event
F.IsLeaderInPvE = function()
	if (F.IsLeader()) and not(F.IsInPvPEvent()) then
		return true
	end
end

-- returns true if the player is a raid officer/leader in a PvP instance or Event
F.IsLeaderInPvP = function()
	if (F.IsLeader()) and (F.IsInPvPEvent()) then
		return true
	end
end

-- only works after the "PLAYER_ALIVE" event!
F.GetPlayerSpec = function()
	-- MoP beta fix
	if (GetSpecialization) then
		return GetSpecialization()
	else
		return GetPrimaryTalentTree()
	end
end

-- returns true of the player (or the optional class) is a healerclass
-- does not check for spec
F.IsHealerClass = function(classOrNil)
	local class = classOrNil or class
	
	if (class == "DRUID") or (class == "PALADIN") or (class == "PRIEST") or (class == "SHAMAN") then
		return true
	end
end

-- returns true if the player is currently specced as a healer
F.IsPlayerHealer = function()
	local spec = F.GetPlayerSpec()
	
	if (class == "DRUID") and (spec == 3) then
		return true
		
	elseif (class == "PALADIN") and (spec == 1) then
		return true
		
	elseif (class == "PRIEST") and ((spec == 1) or (spec == 2)) then
		return true
		
	elseif (class == "SHAMAN") and (spec == 3) then
		return true
	end
end

-- returns true if the player is currently specced as a tank
F.IsPlayerTank = function()
	local spec = F.GetPlayerSpec()
	if (class == "DRUID") and (spec == 2) then
		return true
		
	elseif (class == "DEATHKNIGHT") and (spec == 1) then
		return true
		
	elseif (class == "PALADIN") and (spec == 2) then
		return true
		
	elseif (class == "WARRIOR") and (spec == 3) then
		return true
		
	end
end

-- parse and return the info from "COMBAT_LOG_EVENT_UNFILTERED"
--
-- @param eventType <string> arg2 from COMBAT_LOG_EVENT_UNFILTERED
-- @param ... <vararg> arg9 and onwards from COMBAT_LOG_EVENT_UNFILTERED
F.simpleParseLog = function(eventType, ...)
	local amount, healed, critical, spellId, spellSchool, missType
	if (eventType == "SWING_DAMAGE") then
		if (F.IsBuild(4,2)) then
			_, _, _, amount, _, _, _, _, critical = ...
		else
			_, amount, _, _, _, _, critical = ...
		end
		
	elseif (eventType == "SPELL_DAMAGE") or (eventType == "SPELL_PERIODIC_DAMAGE") then
		if (F.IsBuild(4,2)) then
			_, _, _, spellId, _, spellSchool, amount, _, _, _, _, _, critical = ...
		else
			_, spellId, _, spellSchool, amount, _, _, _, _, _, critical = ...
		end

		if (eventType == "SPELL_PERIODIC_DAMAGE") then
		end
		
	elseif (eventType == "RANGE_DAMAGE") then
		if (F.IsBuild(4,2)) then
			_, _, _, spellId, _, _, amount, _, _, _, _, _, critical = ...
		else
			_, spellId, _, _, amount, _, _, _, _, _, critical = ...
		end
		
	elseif (eventType == "SWING_MISSED") then
		if (F.IsBuild(4,2)) then
			_, _, _, missType, _ = ...
		else
			_, missType, _ = ...
		end
		
	elseif (eventType == "SPELL_MISSED") or (eventType == "RANGE_MISSED") then
		if (F.IsBuild(4,2)) then
			_, _, _, spellId, _, _, missType, _ = ...
		else
			_, spellId, _, _, missType, _ = ...
		end
		
	elseif (eventType == "SPELL_HEAL") or (eventType== "SPELL_PERIODIC_HEAL") then
		if (F.IsBuild(4,2)) then
			_, _, _, _, _, _, healed, _, _, _ = ...
		else
			_, _, _, _, healed, _, _, _ = ...
		end
	end
	
	return amount or 0, healed or 0, critical, spellId, spellSchool, missType
end

-- 
-- Friend tables
-- Not using bucket events here, as each fired event is for a different change
--

-- friends sorted by online -> name
friendSort = function(a, b)
	if (a.connected == b.connected) then
		return ((a.name) and (b.name)) and (a.name < b.name) -- sometimes these are nil
	else
		return (a.connected)
	end
end

-- BN friends sorted by online ( game client -> toonname -> surname -> given name ) -> offline ( lastonline -> surname -> given name )
BNSort = function(a, b)
	if (a.isOnline == b.isOnline) then
		-- online
		if (a.isOnline) then
			if (a.client == b.client) then
				if (a.toonName == b.toonName) then
					if (a.surName == b.surName) then
						return (a.givenName < b.givenName)
					else
						return (a.surName < b.surName)
					end
				else
					return (a.toonName < b.toonName)
				end
			else
				return (a.client < b.client)
			end
		else
			-- offline
			if (a.lastOnline == b.lastOnline) then
				if (a.surName == b.surName) then
					return (a.givenName < b.givenName)
				else
					return (a.surName < b.surName)
				end
			else
				-- last online was the time() when the player was last online
				return (a.lastOnline > b.lastOnline)
			end
		end
	else
		return (a.isOnline)
	end
end

F.updateFriendTable = function(self, event, ...)
	local numberOfFriends = GetNumFriends()
	local update = (numberOfFriends == #friendTable)
	
	if not(update) then
		wipe(friendTable)
	end
	
	if (numberOfFriends > 0) then
		local name, level, class, area, connected, status, note
		for i = 1, numberOfFriends do
			name, level, class, area, connected, status, note = GetFriendInfo(i)
			
			if (update) then
				friendTable[i] = {
					index = i;
					name = name;
					level = level;
					class = class;
					area = area;
					connected = (connected == 1);
					status = status;
					note = note;
				}
			else
				tinsert(friendTable, {
					index = i;
					name = name;
					level = level;
					class = class;
					area = area;
					connected = (connected == 1);
					status = status;
					note = note;
				})
			end
		end
	end
	
	tsort(friendTable, friendSort)
	
	return friendTable
end
RegisterCallback("PLAYER_ENTERING_WORLD", F.updateFriendTable)
RegisterCallback("FRIENDLIST_UPDATE", F.updateFriendTable)

F.updateBNFriendTable = function()
	local numBNetTotal, numBNetOnline = BNGetNumFriends()
	local update = (numBNetTotal == #BNfriendTable) 

	local presenceID, givenName, surName, toonName, toonID, client, isOnline, lastOnline, AFK, DND, broadcastText, noteText, isFriend, broadcastTime
	local toonName, client, realmName, realmID, race, class, zoneName, level, gameText, faction

	if not(update) then
		wipe(BNfriendTable)
	end
	
	for i = 1, numBNetTotal do
		presenceID, givenName, surName, toonName, toonID, client, isOnline, lastOnline, AFK, DND, broadcastText, noteText, isFriend, broadcastTime = BNGetFriendInfo(i)
		_, _, _, realmName, realmID, faction, race, class, _, zoneName, level, gameText, _, _ = BNGetToonInfo(presenceID)
		
		if (update) then
			BNfriendTable[i] = {
				-- friend info
				presenceID = presenceID;
				givenName = givenName;
				surName = surName;
				toonName = toonName;
				toonID = toonID;
				client = client;
				isOnline = isOnline;
				lastOnline = lastOnline;
				AFK = AFK;
				DND = DND;
				broadcastText = broadcastText;
				noteText = noteText;
				isFriend = isFriend;
				broadcastTime = broadcastTime;

				-- toon info
				realmName = realmName;
				realmID = realmID;
				faction = faction;
				race = race;
				class = class;
				level = level;
				zoneName = zoneName;
				gameText = gameText;
			}
		else
			tinsert(BNfriendTable, {
				-- friend info
				presenceID = presenceID;
				givenName = givenName;
				surName = surName;
				toonName = toonName;
				toonID = toonID;
				client = client;
				isOnline = isOnline;
				lastOnline = lastOnline;
				AFK = AFK;
				DND = DND;
				broadcastText = broadcastText;
				noteText = noteText;
				isFriend = isFriend;
				broadcastTime = broadcastTime;

				-- toon info
				realmName = realmName;
				realmID = realmID;
				faction = faction;
				race = race;
				class = class;
				level = level;
				zoneName = zoneName;
				gameText = gameText;
			})
		end
	end
	
	tsort(BNfriendTable, BNSort)

	return BNfriendTable
end
RegisterCallback("BN_FRIEND_INFO_CHANGED", F.updateBNFriendTable)
RegisterCallback("BN_FRIEND_ACCOUNT_ONLINE", F.updateBNFriendTable)
RegisterCallback("BN_FRIEND_ACCOUNT_OFFLINE", F.updateBNFriendTable)
RegisterCallback("BN_TOON_NAME_UPDATED", F.updateBNFriendTable)
RegisterCallback("BN_FRIEND_TOON_ONLINE", F.updateBNFriendTable)
RegisterCallback("BN_FRIEND_TOON_OFFLINE", F.updateBNFriendTable)
RegisterCallback("PLAYER_ENTERING_WORLD", F.updateBNFriendTable)

F.getFriendTable = function()
	return friendTable
end

F.getBNFriendTable = function()
	return BNfriendTable
end

--
-- Guild table
local lvlcol = { r = C["index"][1], g = C["index"][2], b = C["index"][3] }
local zonecolor = { r = C["index"][1], g = C["index"][2], b = C["index"][3] }

local left = "|cFF%s%d|r|cFF" .. RGBToHex(unpack(C["value"])) .. ":|r%s %s"
local leftnote = left .. "|cFF" .. RGBToHex(unpack(C["index"])) .. " (|r|cFF" .. RGBToHex(unpack(C["value"])) .. "%s" .. "|r|cFF" .. RGBToHex(unpack(C["index"])) .. ") |r" 

-- TODO: simplify this, provide non-formatted information
F.updateGuildTable = function()
	local numberofguildies = GetNumGuildMembers(false)
	local onlineGuildies = 0
	
	if (numberofguildies) and (numberofguildies > 0) then
		wipe(guildTable)
	end
	
	local name, rank, rankIndex, level, class, zone, note, officernote, connected, status, classFileName
	
	for i = 1, numberofguildies do
		name, rank, rankIndex, level, class, zone, note, officernote, connected, status, classFileName = GetGuildRosterInfo(i)
		if (connected == 1) then
			onlineGuildies = onlineGuildies + 1
			lvlcol = GetQuestDifficultyColor(level)
			zonecolor.r = C["index"][1]
			zonecolor.g = C["index"][2]
			zonecolor.b = C["index"][3]

			if (GetRealZoneText() == zone) then 
				zonecolor.r = 0
				zonecolor.g = 1
				zonecolor.b = 0
			end
			
			-- patch 4.3.2 fix
			if F.IsBuild(4,3,2) then
				status = (status == 1 and CHAT_FLAG_AFK) or (status == 2 and CHAT_FLAG_DND) or ""
			end
			
			tinsert(guildTable, {
				(note == "") and left:format(RGBToHex(lvlcol.r, lvlcol.g, lvlcol.b), level, name, status)
					or leftnote:format(RGBToHex(lvlcol.r, lvlcol.g, lvlcol.b), level, name, status, note), 
				zone, 
				classFileName and C.RAID_CLASS_COLORS[classFileName].r or C.RAID_CLASS_COLORS.UNKNOWN, 
				classFileName and C.RAID_CLASS_COLORS[classFileName].g or C.RAID_CLASS_COLORS.UNKNOWN, 
				classFileName and C.RAID_CLASS_COLORS[classFileName].b or C.RAID_CLASS_COLORS.UNKNOWN, 
				zonecolor.r, 
				zonecolor.g, 
				zonecolor.b
			})
		end
	end
	
	return guildTable
end
hooksecurefunc("GuildRoster", F.updateGuildTable)

F.getGuildTable = function()
	return guildTable
end

F.GetDurabilityColor = function(current, maximum)
	local r, g, b = 1, 1, 1
	if ((maximum) and (maximum > 0)) then
		r, g, b = unpack(C["durability"][(current or 0)/maximum * 100])
	end
	
	return r, g, b
end

F.GetRarityText = function(rarity)
	local r, g, b, hex = GetItemQualityColor(rarity)
	return "|c" .. hex .. _G["ITEM_QUALITY" .. rarity .. "_DESC"] .. "|r"
end

-- Decide the width and height of our bottom panels. 
-- The height also applies to the editbox(es),
-- while the width functions only as a minimum width for chatframes/editboxes
--
-- These functions really aren't working before PLAYER_ENTERING_WORLD, 
-- which is why we'll register them as callbacks in the relevant modules
F.fixPanelWidth = function()
	local w = GetScreenWidth()

	-- experimental sizes. wild guesswork.
	-- everything assumes uiscaling turned off
	if (w >= 1600) then
		return 440
	elseif (w >= 1440) then
		return 380
	else
		return 320
	end
end

--
-- this should be modified by the global font size when and if I implement that
F.fixPanelHeight = function()
	return 24
end

-- return the panel positions for all modules to use
F.fixPanelPosition = function(panel)
	if (panel == "BottomLeft") then
		return "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 8, 8
		
	elseif (panel == "BottomRight") then
		return "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -8, 8
	end
end

-- will use this for more than just chatframes
F.GetDefaultChatFrameHeight = function()
	return 120
end

F.GetDefaultChatFrameWidth = function()
	return F.fixPanelWidth() - 3*2
end

--
-- function used to get the Blizzard build
-- going to be needing this with all that crap on the 4.3 PTR
-- @return true if the current WoW version is equal to or greater than the input values
F.IsBuild = function(version, subversion, tinyversion, build)
	local gameversion, gamebuild, gamedate, gametocversion = GetBuildInfo()
	local v, s, t = strsplit(".", gameversion)
		
	if (tonumber(v) >= tonumber(version) or 0) 
	and (tonumber(s) >= (tonumber(subversion) or 0)) 
	and (tonumber(t) >= (tonumber(tinyversion) or 0)) then
		return true
	end
end

--
-- returns version, subversion, and Curse build number of the addon if available
do
	local tbl = {}
	local clean = function(...)
		if not(...) then
			return 0
		end

		wipe(tbl)
		
		local n
		for i = 1, select("#", ...) do
			n = select(i, ...)
			n = tostring(n) -- make sure it's a string
			n = n:gsub("%D", "") -- remove anything not a number
			n = tonumber(n) -- transform it back to a number
			
			tinsert(tbl, n or 0) -- don't insert nil values, make them zeroes
		end
		
		return unpack(tbl)
	end

	local version = function(v)
		if not(v) then
			return 0
		else
			v = v:gsub("-", ".") -- consider a minus sign to be the same as a period/dot
			return clean(strsplit(".", v)) -- split it and get the numbers from it
		end
	end

	F.GetVersion = function(test)
		local curse = test or GetAddOnMetadata(addon, "X-Curse-Packaged-Version")
		local toc = GetAddOnMetadata(addon, "Version")

		-- returns curseversion if it exists AND is larger or equal to the toc version
		if ((version(curse)) >= (version(toc))) then
			return version(curse) 
		else
			return version(toc)
		end
	end
	_G.GetVersion = F.GetVersion
end

-- dummy fontstring for our right-align function
local dummy = UIParent:CreateFontString()
dummy:Hide()

-- 
-- Blizzard don't hide spaces at the end of a wrapped line
-- when aligned to the right. This is a problem.
F.properRightAlign = function(fontString, maxLineWidth, maxLineHeight)
	if (fontString) and (fontString.GetText) and (fontString:GetText()) then
		fontString:SetText(gsub(fontString:GetText(), "[%s]+", " "))
		fontString:SetText(gsub(fontString:GetText(), "[%s+]$", ""))
		fontString:SetText(gsub(fontString:GetText(), "[%.+]$", ""))
	end
end

-- create a menu button in the GameMenuFrame
------------------------------------------------------------------------------------------
do
	local menuButtons = {}
	local topButton 
	F.AddGameMenuButton = function(name, msg, onclick)
		-- create our menu button
		local button = CreateFrame("Button", "GameMenuButton" .. name or "", GameMenuFrame, "GameMenuButtonTemplate")
		button:SetText(msg)
		button:SetScript("OnClick", onclick)

		-- find the top blizzard button
		-- this should be both backwards and forward compatible, and quite possible work with other addons as well
		if not(topButton) then
			for i = 1, GameMenuFrame:GetNumChildren() do
				local child = select(i, GameMenuFrame:GetChildren())
				local _, b, c, _, _ = child:GetPoint()
				if (b == GameMenuFrame) and (c == "TOP") then
					topButton = child
					break
				end
			end
		end
		
		-- decide where exactly to put our new button
		if (#menuButtons == 0) then
			-- take blizzard's top button's place
			button:SetPoint(topButton:GetPoint())
		else
			-- but it below the last of our custom buttons
			button:SetPoint("TOP", menuButtons[#menuButtons], "BOTTOM", 0, 0)
		end
		
		-- move the rest of the menu buttons down
		-- they will always come 16 points under our last custom button
		topButton:ClearAllPoints()
		topButton:SetPoint("TOP", button, "BOTTOM", 0, -16)
		
		-- make a global reference to our button
		_G["GameMenuButton" .. name or ""] = button
		
		-- increase the size of the GameMenuFrame to make place for our new button
		GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + button:GetHeight() + ((#menuButtons == 0) and 16 or 0))

		-- add it to our list
		tinsert(menuButtons, button)
	end

	F.GetGameMenuButtons = function(self)
		return menuButtons
	end
end

--
-- make sure you don't cause taint
F.SafeCall = function(func, ...)
	if not(InCombatLockdown()) then
		func(...)
	else
		local args = { ... }
		local callback, safecall
		safecall = function()
			--func((args) and unpack(args)) -- wtf
			args = nil
			if (callback) then
				UnregisterCallback(callback)
				callback = nil
				safecall = nil
			end
		end
		callback = RegisterCallback("PLAYER_REGEN_ENABLED", safecall)
	end
end

