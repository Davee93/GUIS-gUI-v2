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
local floor, min = math.floor, math.min
local ipairs, select, unpack = ipairs, select, unpack
local tinsert, tsort = table.insert, table.sort

-- WoW API
local BNGetFriendInfo = BNGetFriendInfo
local BNGetNumFriends = BNGetNumFriends
local BNGetToonInfo = BNGetToonInfo
local CanGuildInvite = CanGuildInvite
local CreateFrame = CreateFrame
local EasyMenu = EasyMenu
local ExpandAllFactionHeaders = ExpandAllFactionHeaders
local GetFactionInfo = GetFactionInfo
local GetFramerate = GetFramerate
local GetFriendInfo = GetFriendInfo
local GetInventoryItemDurability = GetInventoryItemDurability
local GetMoney = GetMoney
local GetNetStats = GetNetStats
local GetNumFactions = GetNumFactions
local GetNumFriends = GetNumFriends
local GetNumGuildMembers = GetNumGuildMembers
local GetRealmName = GetRealmName
local GetWatchedFactionInfo = GetWatchedFactionInfo
local GetXPExhaustion = GetXPExhaustion
local GuildRoster = GuildRoster
local HasNewMail = HasNewMail
local IsInGuild = IsInGuild
local LoadAddOn = LoadAddOn
--local OpenAllBags = OpenAllBags -- don't upvalue this, might conflict with cargBags
local ReputationFrame_Update = ReputationFrame_Update
local SetSelectedFaction = SetSelectedFaction
local StaticPopup_Show = StaticPopup_Show
local ToggleCharacter = ToggleCharacter
local UnitFactionGroup = UnitFactionGroup
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax

local DropDownList1 = DropDownList1
local GameTooltip = GameTooltip

-- GUIS API
local gPanel = LibStub("gPanel-2.0")
local RegisterPlugin = function(...) gPanel:RegisterPlugin(...) end
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local M = LibStub("gMedia-3.0")
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RAID_CLASS_COLORS = C["RAID_CLASS_COLORS"]
local FACTION_BAR_COLORS = C["FACTION_BAR_COLORS"]

local clientLocale = GetLocale(); if (clientLocale == "enGB") then clientLocale = "enUS" end -- for simplicity
local clientRealm = GetRealmName()
local playerFaction = UnitFactionGroup("player")

local loadModule = function(name)
	local module = LibStub("gCore-3.0"):GetModule(name)
	local dead = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions").kill(name)

	if ((module) and not(dead)) then
		return module
	end
end

local FixDropDown = function(self)
	DropDownList1:ClearAllPoints()
	DropDownList1:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, 8)

	GameTooltip:Hide()
end
------------------------------------------------------------------------------------------------------------
-- 	Plugins
------------------------------------------------------------------------------------------------------------
--[[
	RegisterPlugin("NAME_OF_PLUGIN" , {
		onclick = nil or function(self) end;
		onevent = nil or function(self, event) end;
		oninit = nil or function(self) end;

		interval = update_interval_in_secs;
		onupdate = nil or function(self) end;

		tooltip = nil or "Name_of_Tip";

		events = { ... };
		variables = { ... };
	})
]]--

do
	local friendsMenuFrame = CreateFrame("Frame", "GUIS-gUI_Panel_FriendsDropdown", self, "UIDropDownMenuTemplate")
	local friendsMenuList = function() 
		local L = LibStub("gLocale-1.0"):GetLocale(addon)
		return {
		{
			text = ADD_FRIEND;
			notCheckable = true;
			keepShownOnClick = false;
			func = function()
				FriendsFrameAddFriendButton:Click()
				-- StaticPopup_Show("ADD_FRIEND")
			end
		};
	} end
	local BFriends = {}
	RegisterPlugin("Friends" , {
		events = {
			"FRIENDLIST_UPDATE";
			"PLAYER_ENTERING_WORLD";
			"BN_FRIEND_ACCOUNT_ONLINE";
			"BN_FRIEND_ACCOUNT_OFFLINE";
		};
		onclick = function(self, button)
			if (button == "LeftButton") then
				ToggleFriendsFrame(1) 
			elseif (button == "RightButton") then
				if (DropDownList1:IsShown()) then
					DropDownList1:Hide()
				else
					EasyMenu(friendsMenuList(), friendsMenuFrame, "cursor", 0, 4, "MENU", 2)
					FixDropDown(self)
				end
			end
		end;
		onevent = function(self, event)
			local t = self.lib.text
			
			local BFriends = BFriends
			local friendTable = F.getFriendTable()
			local BNfriendTable = F.getBNFriendTable()
			local friendsOnline, totalFriends = 0, 0
			
			wipe(BFriends)
			
			for i = 1, #BNfriendTable do
				totalFriends = totalFriends + 1
				
				if (BNfriendTable[i].isOnline) then
					friendsOnline = friendsOnline + 1
					
					if (BNfriendTable[i].client == BNET_CLIENT_WOW) then
						-- temporarily store the character name if it is the same realm and faction as the player
						if (BNfriendTable[i].realmName == clientRealm) then -- (BNfriendTable[i].isFriend)
							if ((playerFaction == "Alliance") and (BNfriendTable[i].faction == 1)) or ((playerFaction == "Horde") and (BNfriendTable[i].faction == 0)) then
								BFriends[BNfriendTable[i].toonName] = true
							end
						end
					end
				end
			end
			
			for i = 1, #friendTable do
				if not(BFriends[friendTable[i].name]) then
					totalFriends = totalFriends + 1
					
					if (friendTable[i].connected) then 
						friendsOnline = friendsOnline + 1
					end
				end
			end
			
			local text = t(FRIENDS .. ": ")
			text = text .. t((friendsOnline), true)
			text = text .. t("/")
			text = text .. t((totalFriends), true)

			self.text:SetText(text)
		end;
		tooltip = "Friends";
	})
end

local guildMenuFrame = CreateFrame("Frame", "GUIS-gUI_Panel_GuildDropdown", self, "UIDropDownMenuTemplate")
local guildMenuList = function() 
	local L = LibStub("gLocale-1.0"):GetLocale(addon)
	return {
	{
		text = L["Invite a member to the Guild"];
		notCheckable = true;
		notClickable = not(CanGuildInvite());
		keepShownOnClick = false;
		func = function()
			StaticPopup_Show("ADD_GUILDMEMBER")
		end
	};
	{
		text = L["Change the Guild Message Of The Day"];
		notCheckable = true;
		notClickable = not(CanEditMOTD());
		keepShownOnClick = false;
		func = function()
			if not(GuildFrame) then 
				LoadAddOn("Blizzard_GuildUI") 
			end 
			if not(GuildFrame:IsShown()) then
				GuildFrame_Toggle() 
			end
			GuildTextEditFrame_Show("motd")
		end
	};
} end
RegisterPlugin("Guild" , {
	events = {
		"GUILD_ROSTER_UPDATE";
		"PLAYER_ENTERING_WORLD";
		"PLAYER_GUILD_UPDATE";
	};
	onclick = function(self, button)
		if (button == "LeftButton") then
			if (IsInGuild()) then 
				if not(GuildFrame) then 
					LoadAddOn("Blizzard_GuildUI") 
				end 
				GuildFrame_Toggle() 
			else 
				if not(LookingForGuildFrame) then 
					LoadAddOn("Blizzard_LookingForGuildUI") 
				end 
				LookingForGuildFrame_Toggle() 
			end
			
		elseif (button == "RightButton") then
			if (IsInGuild()) then 
				if (DropDownList1:IsShown()) then
					DropDownList1:Hide()
				else
					EasyMenu(guildMenuList(), guildMenuFrame, "cursor", 0, 4, "MENU", 2)
					FixDropDown(self)
				end
			end
		end
	end;
	oninit = function(self)
		GuildRoster()
		self.text:SetText(self.lib.text(self.GetGuildMembers(self)))
	end;
	--
	-- arg1 is nil if the event is triggered by GuildRoster()
	onevent = function(self, event, arg1) 
		if (event == "PLAYER_ENTERING_WORLD") then
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")

			if (IsInGuild()) and not(GuildFrame) then 
				LoadAddOn("Blizzard_GuildUI") 
			end
		end
		
		self.text:SetText(self.lib.text(self.GetGuildMembers(self)))
	end;
	onupdate = function(self)
		GuildRoster()
	end;
	interval = 15;
	variables = {
		-- we need to pass a pointer to "self" here
		-- to get access to the Plugins libraries
		GetGuildMembers = function(self)
			local t = self.lib.text
			if (IsInGuild()) then
				local total, online = GetNumGuildMembers(true), #F.getGuildTable()

--				for i = 1, total do
--					online = online + ((( select(9, GetGuildRosterInfo(i))) == 1) and 1 or 0)
--				end
				
				local text = t(GUILD .. ": ")
				text = text .. t(online, true)
				text = text .. t("/")
				text = text .. t(total, true)

				return text
			else
				return t(L["No Guild"])
			end
		end
	};
	tooltip = "Guild";
})

local msfpsMenuFrame = CreateFrame("Frame", "GUIS-gUI_Panel_GuildDropdown", self, "UIDropDownMenuTemplate")
local msfpsMenuList = function() 
	local L = LibStub("gLocale-1.0"):GetLocale(addon)
	return {
	{
		text = L["Display Home Latency %s"]:format(L["(Chat, Auction House, etc)"]);
		checked = GUIS_DB["panels"].showRealmLatency;
		keepShownOnClick = true;
		isNotRadio = true;
		func = function()
			GUIS_DB["panels"].showRealmLatency = not(GUIS_DB["panels"].showRealmLatency)
		end
	};
	{
		text = L["Display World Latency %s"]:format(L["(Combat, Casting, Professions, NPCs, etc)"]);
		checked = GUIS_DB["panels"].showWorldLatency;
		notCheckable = false;
		isNotRadio = true;
		keepShownOnClick = true;
		func = function()
			GUIS_DB["panels"].showWorldLatency = not(GUIS_DB["panels"].showWorldLatency)
		end
	};
	{
		text = L["Display Framerate"];
		checked = GUIS_DB["panels"].showFPS;
		notCheckable = false;
		isNotRadio = true;
		keepShownOnClick = true;
		func = function()
			GUIS_DB["panels"].showFPS = not(GUIS_DB["panels"].showFPS)
		end
	};
} end
RegisterPlugin("msfps" , {
	onclick = function(self, button)
		if (button == "RightButton") then
			if (DropDownList1:IsShown()) then
				DropDownList1:Hide()
			else
				EasyMenu(msfpsMenuList(), msfpsMenuFrame, "cursor", 0, 4, "MENU", 2)
				FixDropDown(self)
			end
		end
	end;
	onupdate = function(self)
		local down, up, home, world = GetNetStats()
		local t = self.lib.text
		local text = ""
		
		local gotContent
		if (GUIS_DB["panels"].showRealmLatency) then
			text = text .. t(home, true)
			text = text .. t(MILLISECONDS_ABBR)
			gotContent = true
		end
		
		if (GUIS_DB["panels"].showWorldLatency) then
			if (gotContent) then
				text = text .. t(" - ")
			end
			text = text .. t(world, true)
			text = text .. t(MILLISECONDS_ABBR)
			gotContent = true
		end
		
		if (GUIS_DB["panels"].showFPS) then
			if (gotContent) then
				text = text .. t(" - ")
			end
			text = text .. t(floor(GetFramerate()), true)
			text = text .. t(FPS_ABBR)
			gotContent = true
		end
		
		self.text:SetText(gotContent and text or NOT_APPLICABLE)
	end;
	variables = {
		interval = 1.0;
	};
	tooltip = "LeftClickForMoreRightClickForOptions";
	tooltiponclick = "Memory";
})

RegisterPlugin("Bags" , {
	events = {
		"PLAYER_LOGIN"; 
		"BAG_UPDATE";
	};
	onclick = function(self, button) 
		if (button == "LeftButton") then
			OpenAllBags()
			
		elseif (button == "RightButton") then
			if (loadModule("GUIS-gUI: Bags")) then
				F.OpenToOptionsCategory(F.getName("GUIS-gUI: Bags"))
			end
		end
	end;
	onevent = function(self, event) 
		local t = self.lib.text
		
		local text = t(L["Bags"]..": ")
		text = text .. t (("[free:backpack+bags]"):tag(), true)
		text = text .. t("/")
		text = text .. t(("[max:backpack+bags]"):tag(), true)
		
		self.text:SetText(text)
	end;
	tooltip = "Bags";
})

RegisterPlugin("Time" , {
	onupdate = function(self) 
		self.text:SetText(self.lib.text(("[time]"):tag(), false))
	end;
	variables = {
		interval = 1.0;
	};
	tooltip = "Time";
})

-- over the top, but keeps it automatic and auto-updating
local currencyTranslation = {}
-- on a second thought, screw this. The amount of deprecated spam-currencies was idiotic!
--[[
do
	local name
	for id = 1, 10000 do
		name = GetCurrencyInfo(id)
		if (name) and not(name == "") then
			currencyTranslation[id] = name
		end
	end
end
]]--

-- the currencies for the manual tracking list. 
-- 	the names are just for personal reference, 
-- 	as they are overwritten by the localized name anyway
--
-- http://www.wowhead.com/currencies
local currencyTranslation = {
	[61] = "Dalaran Jewelcrafter's Token";
	[81] = "Dalaran Cooking Award";
	[241] = "Champion's Seal";
	[361] = "Illustrious Jewelcrafter's Token";
	[384] = "Dwarf Archaeology Fragment";
	[385] = "Troll Archaeology Fragment";
	[390] = "Conquest Points";
	[391] = "Tol Barad Commendation";
	[392] = "Honor Points";
	[393] = "Fossil Archaeology Fragment";
	[394] = "Night Elf Archaeology Fragment";
	[395] = "Justice Points";
	[396] = "Valor Points";
	[397] = "Orc Archaeology Fragment";
	[398] = "Draenei Archaeology Fragment";
	[399] = "Vrykul Archaeology Fragment";
	[400] = "Nerubian Archaeology Fragment";
	[401] = "Tol'vir Archaeology Fragment";
	[402] = "Chef's Award";
	[416] = "Mark of the World Tree";
	[515] = "Darkmoon Prize Ticket";
	[614] = "Mote of Darkness";
	[615] = "Essence of Corrupted Deathwing";
}

-- localize our currency list
for id, name in pairs(currencyTranslation) do
	currencyTranslation[id] = (GetCurrencyInfo(id))
end

local verifyCurrencyTracking = function(id)
	if (GUIS_DB["panels"].trackedCurrencies[id]) then
		return true
	else
		for i = 1, GetNumWatchedTokens() do
			local name, count, icon = GetBackpackCurrencyInfo(i)
			if (currencyTranslation[id] == name) then
				return true
			end
		end
	end
end

-- we use the currency display name to translate it from its ID to its position in the currency UI list
local getCurrencyListID = function(realName)
	local name, isHeader, isExpanded, isUnused, isWatched, count, icon, maximum, hasWeeklyLimit, currentWeeklyAmount
	for i = 1, GetCurrencyListSize() do
		name, isHeader, isExpanded, isUnused, isWatched, count, icon, maximum, hasWeeklyLimit, currentWeeklyAmount,_ = GetCurrencyListInfo(i)
		if (name == realName) then
			return i
		end
	end
end

local currencyMenu = {}
local nameSort = function(a, b) return (a.text) and (b.text) and (a.text < b.text) end
local GetCurrencyMenuTable = function()
	wipe(currencyMenu)
	
	local name, currentAmount, texture, isDiscovered
	for id,name in pairs(currencyTranslation) do
		local id = id
		name, currentAmount, texture, _, _, _, isDiscovered = GetCurrencyInfo(id)
		
		-- only add discovered currencies to the list
		if (isDiscovered) then
			tinsert(currencyMenu, {
				text = name;
				icon = "Interface\\Icons\\" .. texture;
				
				checked = function() return verifyCurrencyTracking(id) end;
				keepShownOnClick = true;
				isNotRadio = true;
				func = function()
					local watched = GetNumWatchedTokens()
					
					-- check if we're tracking this one way or the other
					if (verifyCurrencyTracking(id)) then
						GUIS_DB["panels"].trackedCurrencies[id] = nil -- clear our own tracking, always
						
						-- check to see if this is a backpack currency
						for i = 1, watched do
							local name, count, icon = GetBackpackCurrencyInfo(i)
							if (currencyTranslation[id] == name) then
								local listID = getCurrencyListID(name)
								
								if (listID) then
									SetCurrencyBackpack(listID, 0) -- clear the blizzard tracking
									TokenFrame_Update()
									BackpackTokenFrame_Update()
								end
								
								return
							end
						end
					else
						GUIS_DB["panels"].trackedCurrencies[id] = true
						
						if (watched < MAX_WATCHED_TOKENS) then
							local listID = getCurrencyListID(name)
								
							if (listID) then
								SetCurrencyBackpack(listID, 1) -- track the currency using the backpack if possible
								TokenFrame_Update()
								BackpackTokenFrame_Update()
							end
						end
						
						return
					end
				end;
			})
		end
	end
--	tsort(currencyMenu, nameSort)

	return currencyMenu
end

local currencyProxyCrap = {}
local goldMenuFrame = CreateFrame("Frame", "GUIS-gUI_Panel_GoldDropdown", self, "UIDropDownMenuTemplate")
local goldMenuList = function() 
	local L = LibStub("gLocale-1.0"):GetLocale(addon)
	wipe(currencyProxyCrap)
	
	local currencyMenuTable = GetCurrencyMenuTable();
	
	-- currency tracking
	for i,v in pairs(currencyMenuTable) do
		tinsert(currencyProxyCrap, v)
	end
	
	-- sort the currencies
	tsort(currencyProxyCrap, nameSort)

	-- only display currency title and separator if we actually 
	-- have discovered anything to watch at all
	if (#currencyMenuTable > 0) then
		-- insert a title at the start
		tinsert(currencyProxyCrap, 1, {
			text = L["Select currencies to always watch:"];
			isTitle = true;
			notCheckable = true;
			notClickable = true;
		} )
		
		-- separator
		tinsert(currencyProxyCrap, {
			text = "";
			isTitle = true;
			notCheckable = true;
			notClickable = true;
		})
	end
	
	-- insert a title for the gold display options
	tinsert(currencyProxyCrap, {
		text = L["Select how your gold is displayed:"];
		isTitle = true;
		notCheckable = true;
		notClickable = true;
	} )
		
	-- gold display options
	tinsert(currencyProxyCrap, {
		text = L["Hide copper when you have at least %s"]:format(("[money:%s]"):format(GUIS_DB["panels"].copperThreshold)):tag();
		checked = GUIS_DB["panels"].hideCopper;
		keepShownOnClick = true;
		isNotRadio = true;
		func = function()
			GUIS_DB["panels"].hideCopper = not(GUIS_DB["panels"].hideCopper)
			gPanel:ForcePluginEvent("Gold", "PLAYER_MONEY")
		end
	})
	tinsert(currencyProxyCrap, {
		text = L["Hide silver and copper when you have at least %s"]:format(("[money:%s]"):format(GUIS_DB["panels"].silverThreshold)):tag();
		checked = GUIS_DB["panels"].hideSilver;
		keepShownOnClick = true;
		isNotRadio = true;
		func = function()
			GUIS_DB["panels"].hideSilver = not(GUIS_DB["panels"].hideSilver)
			gPanel:ForcePluginEvent("Gold", "PLAYER_MONEY")
		end
	})
	
	return currencyProxyCrap
end
RegisterPlugin("Gold" , {
	events = {
		"ADDON_LOADED";
		"PLAYER_MONEY";
		"PLAYER_ENTERING_WORLD";
		"PLAYER_LOGIN";
	};
	onclick = function(self, button)
		if (button == "LeftButton") then
			ToggleCharacter("TokenFrame")
		elseif (button == "RightButton") then
			if (DropDownList1:IsShown()) then
				DropDownList1:Hide()
			else
				EasyMenu(goldMenuList(), goldMenuFrame, "cursor", 0, 4, "MENU", 2)
				FixDropDown(self)
			end
		end
	end;
	onevent = function(self, event)
		local money = GetMoney()
		if (GUIS_DB["panels"].hideCopper) and (money >= GUIS_DB["panels"].copperThreshold) then
			money = floor(money/100) * 100
		end
		
		if (GUIS_DB["panels"].hideSilver) and (money >= GUIS_DB["panels"].silverThreshold) then
			money = floor(money/10000) * 10000
		end
				
		self.text:SetText(self.lib.text(("[money:%s]"):format(money):tag(), false))
	end;
	tooltip = "Currency";
})

RegisterPlugin("Mail" , {
	events = {
		"ADDON_LOADED";
		"PLAYER_ENTERING_WORLD";
		"UPDATE_PENDING_MAIL";
	};
	
	onevent = function(self, event)
		self.GetMail(self)
	end;
	
	oninit = function(self) 
		self.GetMail(self)
	end;

	variables = {
		GetMail = function(self) 
			local t = self.lib.text
			if (HasNewMail()) then
				self.text:SetText(t(L["New Mail!"], false))
			else
				self.text:SetText(t(L["No Mail"], false))
			end
		end
	};
--	tooltip = nil;
})

RegisterPlugin("MeleeAttackPower" , {
	onupdate = function(self) 
		local t = self.lib.text
		
		self.text:SetText(t(("[ap]"):tag(), true) .. t(" AP", false))
	end;
	variables = { 
		interval = 0.1;
	};
	tooltip = "MeleeStats";
})

RegisterPlugin("MeleeCritical" , {
	onupdate = function(self) 
		local t = self.lib.text
		
		self.text:SetText(t(("[mcrit]"):tag(), true) .. t("% " .. CRIT_ABBR, false))
	end;
	variables = { 
		interval = 0.1;
	};
	tooltip = "MeleeStats";
})

RegisterPlugin("MeleeHaste" , {
	onupdate = function(self) 
		local t = self.lib.text
		
		self.text:SetText(t(("[mhaste]"):tag(), true) .. t("% " .. SPELL_HASTE_ABBR, false))
	end;
	variables = { 
		interval = 0.1;
	};
	tooltip = "MeleeStats";
})

RegisterPlugin("RangedAttackPower" , {
	onupdate = function(self) 
		local t = self.lib.text
		
		self.text:SetText(t(("[rap]"):tag(), true) .. t(" RAP", false))
	end;
	variables = { 
		interval = 0.1;
	};
	tooltip = "RangedStats";
})

RegisterPlugin("RangedCritical" , {
	onupdate = function(self) 
		local t = self.lib.text
		
		self.text:SetText(t(("[rcrit]"):tag(), true) .. t("% " .. CRIT_ABBR, false))
	end;
	variables = { 
		interval = 0.1;
	};
	tooltip = "RangedStats";
})

RegisterPlugin("RangedHaste" , {
	onupdate = function(self) 
		local t = self.lib.text
		
		self.text:SetText(t(("[rhaste]"):tag(), true) .. t("% " .. SPELL_HASTE_ABBR, false))
	end;
	variables = { 
		interval = 0.1;
	};
	tooltip = "RangedStats";
})

RegisterPlugin("SpellPower" , {
	onupdate = function(self) 
		local t = self.lib.text
		
		self.text:SetText(t(("[sp]"):tag(), true) .. t(" SP", false))
	end;
	variables = {
		interval = 0.1;
	};
	tooltip = "CasterStats";
})

RegisterPlugin("SpellCritical" , {
	onupdate = function(self) 
		local t = self.lib.text
		
		self.text:SetText(t(("[scrit]"):tag(), true) .. t("% " .. CRIT_ABBR, false))
	end;
	variables = {
		interval = 0.1;
	};
	tooltip = "CasterStats";
})

RegisterPlugin("SpellHaste" , {
	onupdate = function(self) 
		local t = self.lib.text
		
		self.text:SetText(t(("[shaste]"):tag(), true) .. t("% " .. SPELL_HASTE_ABBR, false))
	end;
	variables = {
		interval = 0.1;
	};
	tooltip = "CasterStats";
})

RegisterPlugin("Experience" , {
	events = {
		"PLAYER_ALIVE";
		"PLAYER_ENTERING_WORLD";
		"PLAYER_LEVEL_UP";
		"PLAYER_LOGIN";
		"PLAYER_XP_UPDATE";
	};
	horizontalTooltip = true;
	onclick = nil;
	onevent = function(self, event, ...)
		if (event == "PLAYER_LEVEL_UP") then
			if (GetXPExhaustion() or 0) > 0 then 
				self.bar:SetStatusBarColor(unpack(self.XPRestedColor))
			else
				self.bar:SetStatusBarColor(unpack(self.XPColor))
			end

			self.bar:SetMinMaxValues(0, UnitXPMax("player"))
			self.bar:SetValue(UnitXP("player"))
			self.rested:SetMinMaxValues(0, UnitXPMax("player"))
			self.rested:SetValue(min(UnitXPMax("player"), UnitXP("player") + (GetXPExhaustion() or 0)))

			self.text:SetText(self.XPText())
		end
		
		if (event == "PLAYER_XP_UPDATE") or (event == "PLAYER_ALIVE") or (event == "PLAYER_ENTERING_WORLD") or (event == "PLAYER_LOGIN") then
			if (GetXPExhaustion() or 0) > 0 then 
				self.bar:SetStatusBarColor(unpack(self.XPRestedColor))
			else
				self.bar:SetStatusBarColor(unpack(self.XPColor))
			end
			
			self.bar:SetMinMaxValues(0, UnitXPMax("player"))
			self.bar:SetValue(UnitXP("player"))

			self.rested:SetMinMaxValues(0, UnitXPMax("player"))
			self.rested:SetValue(min(UnitXPMax("player"), UnitXP("player") + (GetXPExhaustion() or 0)))

			self.text:SetText(self.XPText())
		end
	end;
	oninit = function(self)
		self.background = self:CreateTexture(nil, "BACKGROUND")
		self.background:SetAllPoints(self:GetParent())
		self.background:SetTexture(M["StatusBar"]["StatusBar"])
		self.background:SetVertexColor(0.15, 0.15, 0.15, 1)
		
		self.rested = CreateFrame("StatusBar", nil, self)
		self.rested:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
		self.rested:SetStatusBarColor(unpack(self.XPRestedBonusColor))
		self.rested:SetMinMaxValues(0, UnitXPMax("player"))
		self.rested:SetValue(min(UnitXPMax("player"), UnitXP("player") + (GetXPExhaustion() or 0)))
		self.rested:SetAllPoints(self:GetParent())

		self.bar = CreateFrame("StatusBar", nil, self.rested)
		self.bar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
		self.bar:SetAllPoints(self:GetParent())
		
		F.GlossAndShade(self.bar)

		if (GetXPExhaustion() or 0) > 0 then 
			self.bar:SetStatusBarColor(unpack(self.XPRestedColor))
		else
			self.bar:SetStatusBarColor(unpack(self.XPColor))
		end

		self.bar:SetMinMaxValues(0, UnitXPMax("player"))
		self.bar:SetValue(UnitXP("player"));
		self.bar:EnableMouse(true)

		self.text:SetParent(self.bar)
		self.text:SetAllPoints(self.bar)
		self.text:SetDrawLayer("OVERLAY", 3)
		self.text:SetText(self.XPText())
		self.text:SetFontObject(GUIS_NumberFontSmall or NumberFontNormalSmallGray)
		self.text:SetTextColor(1, 1, 1, 1)
		
		self.overlay:SetParent(self.bar)
	end;
	onupdate = nil;
	variables = {
		XPColor = { 0.4, 0.0, 0.4, 1.0 };
		XPRestedColor = { 0.3, 0.3, 0.8, 1.0 };
		XPRestedBonusColor = { 0.1, 0.1, 0.4, 1.0 };
		
		XPText = function() 
		
			local min = UnitXP("player") or 0
			local max = UnitXPMax("player") or 0
			local exhaust = GetXPExhaustion() or 0
			
		
			local r, g, b = unpack(C["index"])
			local iCol = "|cFF" .. RGBToHex(r, g, b)
			local vCol = "|cFF" .. RGBToHex(unpack(C["value"]))
			
			local current = vCol .. ("[shortvalue:%d]"):format(min):tag() .. "|r"
			local total = vCol .. ("[shortvalue:%d]"):format(max):tag() .. "|r"
			
			local percent = vCol .. tostring(floor(min / max * 100)) .. "|r"
			local restpercent = vCol .. tostring(floor(exhaust / max *100)) .. "|r"

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
			local rested = (" (%s%%)"):format(restpercent)
		
--			if (exhaust > 0) then 
--				return iCol .. values .. rested .. "|r"
--			else
				return iCol .. values .. "|r"
--			end
		end;
	};
	tooltip = "Experience";
})

RegisterPlugin("Reputation" , {
	events = {
		"UPDATE_FACTION";
	};
	onevent = function(self, event, arg1, arg2)
		local RPName, RPStanding, RPMin, RPMax, RPValue = GetWatchedFactionInfo()

		self.bar:SetStatusBarColor(unpack(self.RPColor()))
		self.bar:SetMinMaxValues(RPMin, RPMax)
		self.bar:SetValue(RPValue)
		self.text:SetText(self.RPText())
	end;
	onclick = function(self, button)
		if (button == "LeftButton") then
			ToggleCharacter("ReputationFrame")
			
			local RPName, RPStanding, RPMin, RPMax, RPValue = GetWatchedFactionInfo()
			
			if (RPName) then
				local headersToClose = {}
				local headerID, headerName, headerToExpand, headerToExpandName, faction
				
				ExpandAllFactionHeaders()
				
				for i = 1, GetNumFactions() do
					local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(i)

					if (isHeader) then
						headerID = i
						headerName = name
					end
					
					if (RPName == name) then
						faction = i
						headerToExpand = headerID
						headerToExpandName = headerName
					end
				end
				
				SetSelectedFaction(faction)
				ReputationDetailFrame:Show()
				ReputationFrame_Update()
			end
		end
	end;
	oninit = function(self)
		self.background = self:CreateTexture(nil, "BACKGROUND")
		self.background:SetAllPoints(self:GetParent())
		self.background:SetTexture(M["StatusBar"]["StatusBar"])
		self.background:SetVertexColor(0.15, 0.15, 0.15, 1)

		local RPName, RPStanding, RPMin, RPMax, RPValue = GetWatchedFactionInfo()
		self.bar = CreateFrame("StatusBar", nil, self)
		self.bar:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
		self.bar:SetStatusBarColor(unpack(self.RPColor()))
		self.bar:SetAllPoints(self:GetParent())
		self.bar:SetMinMaxValues(RPMin, RPMax)
		self.bar:SetValue(RPValue);
		self.bar:EnableMouse(true)
		
		F.GlossAndShade(self.bar)

		self.text:SetParent(self.bar)
		self.text:SetDrawLayer("OVERLAY", 3)
		self.text:SetText(self.RPText())
		self.text:SetFontObject(GUIS_NumberFontSmall or NumberFontNormalSmallGray)
		self.text:SetTextColor(1, 1, 1, 1)
		
		hooksecurefunc("ReputationWatchBar_Update", function() 
			self:ForceEvent("UPDATE_FACTION") 
		end)
	end;
	onupdate = nil;
	horizontalTooltip = true;
	variables = {
		RPText = function() 
			local RPName, RPStanding, RPMin, RPMax, RPValue = GetWatchedFactionInfo()
			if (not RPName) then 
				return "" 
			end
			return (RPName and ("|cFFFFd100[shortvalue:%d]|r"):format(RPValue - RPMin):tag().." / "..("|cFFFFd100[shortvalue:%d]|r"):format(RPMax - RPMin):tag().." - |cFFFFd100"..floor((RPValue - RPMin) / (RPMax - RPMin) * 100)).."|r%" or ""
		end;
		RPColor = function() 
			local RPName, RPStanding, RPMin, RPMax, RPValue = GetWatchedFactionInfo()
			if not(RPName) then 
				return { 0, 0, 0, 1 }
			end
			return { FACTION_BAR_COLORS[RPStanding].r, FACTION_BAR_COLORS[RPStanding].g, FACTION_BAR_COLORS[RPStanding].b, 1 }
		end;
	};
	tooltip = "Reputation";
})

local durabilityMenuFrame = CreateFrame("Frame", "GUIS-gUI_Panel_MerchantOptionsDropdown", self, "UIDropDownMenuTemplate")
local durabilityMenuList = function() 
	local L = LibStub("gLocale-1.0"):GetLocale(addon)
	return {
	{
		text = L["Toggle autorepair of your armor"]; 
		checked = GUIS_DB["merchant"].autorepair;
		keepShownOnClick = true;
		isNotRadio = true;
		func = function()
			GUIS_DB["merchant"].autorepair = not(GUIS_DB["merchant"].autorepair)
		end
	};
	{
		text = L["Toggle Guild Bank repairs"]; 
		checked = GUIS_DB["merchant"].guildrepair;
		keepShownOnClick = true;
		isNotRadio = true;
		func = function()
			GUIS_DB["merchant"].guildrepair = not(GUIS_DB["merchant"].guildrepair)
		end
	};
	{
		text = L["Toggle autosell of Poor Quality items"]; 
		checked = GUIS_DB["merchant"].autosell;
		keepShownOnClick = true;
		isNotRadio = true;
		func = function()
			GUIS_DB["merchant"].autosell = not(GUIS_DB["merchant"].autosell)
		end
	};
	{
		text = L["Toggle display of detailed sales reports"]; 
		checked = GUIS_DB["merchant"].detailedreport;
		keepShownOnClick = true;
		isNotRadio = true;
		func = function()
			GUIS_DB["merchant"].detailedreport = not(GUIS_DB["merchant"].detailedreport)
		end
	};
} end

RegisterPlugin("Durability" , {
	events = {
		"UPDATE_INVENTORY_DURABILITY";
		"PLAYER_LOGIN";
		"PLAYER_ENTERING_WORLD";
	};
	onevent = function(self, event)
		if (event == "UPDATE_INVENTORY_DURABILITY") then
			local t = self.lib.text
		
			self.durability.current = 0
			self.durability.total = 0

			for _, slot in ipairs(self.slots) do
				local item = _G["Character" .. slot]
				local current, total = GetInventoryItemDurability(item:GetID())
				
				if current and total then
					self.durability.current = self.durability.current + current
					self.durability.total = self.durability.total + total
				end
			end
			
			local percent = 100
			if (self.durability.total > 0) then
				percent = max(0, self.durability.current / self.durability.total * 100)
			end
			
			local text = t(ARMOR .. ": ")
			text = text .. t("%d", true):format(percent)
			text = text .. t("%")
	
			self.text:SetText(text)
		end
	end;
	onclick = function(self, button)
		if (button == "RightButton") then
			if (loadModule("GUIS-gUI: Merchant")) then
				if (DropDownList1:IsShown()) then
					DropDownList1:Hide()
				else
					EasyMenu(durabilityMenuList(), durabilityMenuFrame, "cursor", 0, 4, "MENU", 2)
					FixDropDown(self)
				end
			end
		end
	end;
	variables = {
		slots = { "HeadSlot", "ShoulderSlot", "ChestSlot", "WaistSlot", "WristSlot", "HandsSlot", "LegsSlot", "FeetSlot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot" };		
		durability = { current = 0; total = 0; };
		tooltip = "Durability";
	};
})

