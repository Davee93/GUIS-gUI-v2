--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: ChatEasy")

-- Lua API
local pairs, ipairs, unpack = pairs, ipairs, unpack

-- WoW API
local ChangeChatColor = ChangeChatColor
local ChatFrame_AddChannel = ChatFrame_AddChannel
local ChatFrame_AddMessageGroup = ChatFrame_AddMessageGroup
local ChatFrame_ReceiveAllBNConversations = ChatFrame_ReceiveAllBNConversations
local ChatFrame_ReceiveAllPrivateMessages = ChatFrame_ReceiveAllPrivateMessages
local ChatFrame_RemoveChannel = ChatFrame_RemoveChannel
local ChatFrame_RemoveMessageGroup = ChatFrame_RemoveMessageGroup
local GetChatWindowInfo = GetChatWindowInfo
local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth
local FCF_DockFrame = FCF_DockFrame
local FCF_OpenNewWindow = FCF_OpenNewWindow
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
local FCF_SetLocked = FCF_SetLocked
local FCF_SetWindowAlpha = FCF_SetWindowAlpha
local FCF_SetWindowColor = FCF_SetWindowColor
local FCF_SetWindowName = FCF_SetWindowName
local FCF_UnDockFrame = FCF_UnDockFrame
local SetChatWindowSavedDimensions = SetChatWindowSavedDimensions
local ToggleChatColorNamesByClassGroup = ToggleChatColorNamesByClassGroup

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local UnregisterCallback = function(...) module:UnregisterCallback(...) end

local SetPosition, GetPosition, SetSize
local SetUpMainChat, SetUpCombatLog, SetUpLoot, SetUpPublic, SetUpColors
local usePublic, useLoot

-- channels to activate class colors in
local classColors = {
	"ACHIEVEMENT"; "BATTLEGROUND"; "BATTLEGROUND_LEADER"; "CHANNEL1"; "CHANNEL2"; "CHANNEL3"; "CHANNEL4"; "CHANNEL5"; "CHANNEL6"; "CHANNEL7"; "CHANNEL8"; "CHANNEL9"; "CHANNEL10"; "EMOTE"; "GUILD"; "GUILD_ACHIEVEMENT"; "OFFICER"; "PARTY"; "PARTY_LEADER"; "RAID"; "RAID_LEADER"; "RAID_WARNING"; "SAY"; "WHISPER"; "YELL";
}

-- public channels are localized
local locale = GetLocale()
local publicChannels = ((locale == "enUS") or (locale == "enGB")) and {
	"General";
	"Trade";
	"LocalDefense";
	"GuildRecruitment";
	"LookingForGroup";
	
} or (locale == "frFR") and {
	"Général";
	"Commerce";
	"DéfenseLocale";
	"RecrutementDeGuilde";
	"RechercheDeGroupe";

} or (locale == "deDE") and {
	"Allgemein";
	"Handel";
	"LokaleVerteidigung";
	"Gildenrekrutierung";
	"SucheNachGruppe";

} or (locale == "koKR") and {
	"일반";
	"거래";
	"수비";
	"길드모집";
	"파티찾기";

} or ((locale == "ptBR") or (locale == "ptPT")) and {
	"General";
	"Trade";
	"LocalDefense";
	"GuildRecruitment";
	"LookingForGroup";

} or (locale == "ruRU") and {
	"Общий";
	"Торговля";
	"ОборонаЛокальный";
	"Гильдии";
	"ПоискСпутников";

} or ((locale == "esES") or (locale == "esMX")) and {
	"General";
	"Comercio";
	"DefensaLocal";
	"ReclutamientoHermandad";
	"BuscandoGrupo";

} or (locale == "zhTW") and {
	"綜合";
	"交易";
	"本地防務";
	"公會招募";
	"尋求組隊";

} or (locale == "zhCN") and {
	"综合";
	"交易";
	"本地防务";
	"公会招募";
	"寻求组队";
}

-- groups for the loot window
local lootGroups = {
	"COMBAT_XP_GAIN";
	"COMBAT_GUILD_XP_GAIN";
	"COMBAT_HONOR_GAIN";
	"COMBAT_FACTION_CHANGE";
	"LOOT";
	"MONEY";
	"SKILL";
}

-- groups for the main window
local mainGroups = {
	"SAY";
	"EMOTE";
	"YELL";
	"GUILD";
	"OFFICER";
	"WHISPER";

	"MONSTER_SAY";
	"MONSTER_EMOTE";
	"MONSTER_YELL";
	"MONSTER_WHISPER";
	"MONSTER_BOSS_EMOTE";
	"MONSTER_BOSS_WHISPER";

	"PARTY";
	"PARTY_LEADER";
	"RAID";
	"RAID_LEADER";
	"RAID_WARNING";

	"BATTLEGROUND";
	"BATTLEGROUND_LEADER";
	"BG_HORDE";
	"BG_ALLIANCE";
	"BG_NEUTRAL";

	"SYSTEM";
	"AFK";
	"DND";
	"IGNORED";
	"ERRORS";

	"ACHIEVEMENT";
	"GUILD_ACHIEVEMENT";

	"BN_ALERT"; 
	"BN_BROADCAST"; 
	"BN_BROADCAST_INFORM"; 
	"BN_CONVERSATION";
	"BN_CONVERSATION_LIST"; 
	"BN_CONVERSATION_NOTICE"; 
	"BN_INLINE_TOAST_ALERT"; 
	"BN_INLINE_TOAST_BROADCAST"; 
	"BN_INLINE_TOAST_BROADCAST_INFORM"; 
	"BN_INLINE_TOAST_CONVERSATION";
	"BN_WHISPER";
	"BN_WHISPER_INFORM"; 
}

SetSize = function(frame)
	if not(frame) then
		return
	end

	local w, h = F.GetDefaultChatFrameWidth(), F.GetDefaultChatFrameHeight()
	frame:SetSize(w, h)
	
	SetChatWindowSavedDimensions(frame:GetID(), w, h)

--	FCF_SavePositionAndDimensions(frame)
end

-- retrieve the position a chatframe should be positioned in to align with the matching ui panel
GetPosition = function(name)
	local pos, anchor, rpos, x, y
	
	local uiPanel = LibStub("gCore-3.0"):GetModule("GUIS-gUI: UIPanels")
	if (uiPanel) then
		local panel = uiPanel:GetPanel(name)
		if (panel) then
			pos, anchor, rpos, x, y = panel:GetPoint()
		end
	end
	
	if not(pos) then
		pos, anchor, rpos, x, y = F.fixPanelPosition(name)
	end
	
	y = y + (((y > 0) and 1 or -1)*(F.fixPanelHeight() + 3*2 + 1))
	x = x + (((x > 0) and 1 or -1)*(3))
	
	return pos, anchor, rpos, x, y
end

-- completely position a chatframe
SetPosition = function(frame, name)
	if not(frame) then
		return
	end

	local pos, anchor, rpos, x, y = GetPosition(name)
	frame:SetUserPlaced(true)
	frame:ClearAllPoints()
	frame:SetPoint(pos, x, y)
--	frame:SetPoint((pos == "BOTTOMLEFT") and "BOTTOMRIGHT" or "BOTTOMLEFT", anchor, rpos, x + (((x > 0) and 1 or -1)*(F.fixPanelWidth() - 6)), y)
	
	do 
		local centerX = frame:GetLeft() + frame:GetWidth() / 2
		local centerY = frame:GetBottom() + frame:GetHeight() / 2
		
		local horizPoint, vertPoint
		local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
		local xOffset, yOffset
		if ( centerX > screenWidth / 2 ) then
			horizPoint = "RIGHT"
			xOffset = (frame:GetRight() - screenWidth)/screenWidth
		else
			horizPoint = "LEFT"
			xOffset = frame:GetLeft()/screenWidth
		end
		
		if ( centerY > screenHeight / 2 ) then
			vertPoint = "TOP"
			yOffset = (frame:GetTop() - screenHeight)/screenHeight
		else
			vertPoint = "BOTTOM";
			yOffset = frame:GetBottom()/screenHeight
		end

		SetChatWindowSavedPosition(frame:GetID(), vertPoint .. horizPoint, xOffset, yOffset)
	end

--	FCF_SavePositionAndDimensions(frame)
end

GetFrameByName = function(displayName)
	if not(displayName) then
		return
	end
	
	local frame, frameName
	local cName, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable
	
	for _,frameName in ipairs(CHAT_FRAMES) do 
		frame = _G[frameName]
		if (frame) then
			cName, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(frame:GetID())
			
			if (cName == displayName) then 
				return frame
			end
		end
	end
end

SetUpMainChat = function()
	local public = (usePublic) or (GetFrameByName(L["Public"]))
	local loot = (useLoot) or (GetFrameByName(L["Loot"]))
	
	-- remove public spam and loot groups
	if (public) then
		for _,v in ipairs(publicChannels) do
			ChatFrame_RemoveChannel(ChatFrame1, v)
		end
	end
		
	if (loot) then
		for _,v in ipairs(lootGroups) do
			ChatFrame_RemoveMessageGroup(ChatFrame1, v)
		end
	end
	
	ChatFrame_ReceiveAllPrivateMessages(ChatFrame1)
	ChatFrame_ReceiveAllBNConversations(ChatFrame1)

	-- make sure the relevant groups exist
	for _,v in ipairs(mainGroups) do
		ChatFrame_AddMessageGroup(ChatFrame1, v)
	end
	
end

SetUpCombatLog = function()
	ChatFrame_RemoveMessageGroup(ChatFrame2, "COMBAT_MISC_INFO")
	ChatFrame_RemoveMessageGroup(ChatFrame2, "OPENING")
	ChatFrame_RemoveMessageGroup(ChatFrame2, "PET_INFO")
	ChatFrame_RemoveMessageGroup(ChatFrame2, "TRADESKILLS")

	for _,v in ipairs(lootGroups) do
		ChatFrame_RemoveMessageGroup(ChatFrame2, v)
	end
end

SetUpPublic = function()
	local frame = GetFrameByName(L["Public"])
	if not(frame) then
		return
	end
	
	usePublic = true

	FCF_DockFrame(frame)
	FCF_SetWindowColor(frame, 0, 0, 0)
	FCF_SetWindowAlpha(frame, 0)

	SetSize(frame)

	--	frame:Show()

	ChatFrame_RemoveAllMessageGroups(frame)
	ChatFrame_RemoveAllChannels(frame)
	
	for i = 1, #publicChannels do
		ChatFrame_AddChannel(frame, publicChannels[i])
		ChatFrame_RemoveChannel(ChatFrame1, publicChannels[i])
	end

	ChangeChatColor(publicChannels[1], unpack(C["GeneralChat"]))
	ChangeChatColor(publicChannels[2], unpack(C["TradeChat"]))

	FCF_SavePositionAndDimensions(frame)

	-- post update relevant frames
	SetUpMainChat()
	SetUpCombatLog()
end

SetUpLoot = function()
	local frame = GetFrameByName(L["Loot"])
	if not(frame) then
		return
	end
	
	useLoot = true

	FCF_UnDockFrame(frame)
	FCF_SetLocked(frame, 1) 
--	FCF_DockUpdate()

	SetSize(frame)
	SetPosition(frame, "BottomRight")

	frame:SetJustifyH("RIGHT")
	frame:Show()
	
	-- this just refuses to update before /rl
	local tab = _G[frame:GetName() .. "Tab"]
	tab:ClearAllPoints()
	tab:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 6)

	FCF_SetWindowColor(frame, 0, 0, 0)
	FCF_SetWindowAlpha(frame, 0)

	ChatFrame_RemoveAllMessageGroups(frame)
	ChatFrame_RemoveAllChannels(frame)
	
	for _,v in ipairs(lootGroups) do
		ChatFrame_AddMessageGroup(frame, v)
	end
	
	FCF_SavePositionAndDimensions(frame)

	-- post update relevant frames
	SetUpMainChat()
	SetUpCombatLog()
end

SetUpColors = function()
	-- change colors to something better
	-- point is that too many things looks like the druid class color
	ChangeChatColor("RAID", unpack(C["RaidChat"]))
	ChangeChatColor("RAID_LEADER", unpack(C["RaidLeader"]))
	ChangeChatColor("BATTLEGROUND", unpack(C["RaidChat"]))
	ChangeChatColor("BATTLEGROUND_LEADER", unpack(C["RaidLeader"]))
	
	-- enable class coloring
	for _,v in ipairs(classColors) do
		ToggleChatColorNamesByClassGroup(true, v)
	end
	
	-- change background colors and alpha of all frames
	local frame
	for _,name in ipairs(CHAT_FRAMES) do
		frame = _G[name]
		if (frame) then
			FCF_SetWindowColor(frame, 0, 0, 0)
			FCF_SetWindowAlpha(frame, 0)
		end
	end
end

module.DockFloaters = function(self)
	local loot = GetFrameByName(L["Loot"])

	local frame
	for _, name in ipairs(CHAT_FRAMES) do
		frame = _G[name]
		
		if (frame) and (frame ~= ChatFrame1) and (frame ~= loot) then
			if (frame:IsShown()) then
				FCF_DockFrame(frame)
			end
		end
	end
end

module.SetColor = function(self)
	SetUpColors()
end

module.Create = function(self, what)
	if (what == "public") then
		local frame = GetFrameByName(L["Public"])
		if not(frame) then
			FCF_SetWindowName(FCF_OpenNewWindow(L["Public"]), L["Public"])
		end
		
		SetUpPublic()

	elseif (what == "loot") then
		local frame = GetFrameByName(L["Loot"])
		if not(frame) then
			FCF_SetWindowName(FCF_OpenNewWindow(L["Loot"]), L["Loot"])
		end
		
		SetUpLoot()
	end
end

module.SetPoint = function(self, what)
	if (what == "main") then
		SetPosition(ChatFrame1, "BottomLeft")
		FCF_SavePositionAndDimensions(ChatFrame1)
		
	elseif (what == "loot") then
		local frame = GetFrameByName(L["Loot"])
		if (frame) then
			SetPosition(frame, "BottomRight")
			frame:SetJustifyH("RIGHT")
			FCF_SavePositionAndDimensions(frame)
		end
	end
end

module.SetSize = function(self, what)
	SetSize((what == "main") and ChatFrame1 or (what == "loot") and GetFrameByName(L["Loot"]))
end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: Chat")) then 
		self:Kill() 
		return 
	end
	
	-- our own little trick to get the names right, always
	local setNames = function() 
		FCF_SetWindowName(ChatFrame1, L["Main"])
		FCF_SetWindowName(ChatFrame2, L["Log"])
	end
	hooksecurefunc("FCF_ResetChatWindows", setNames)
	RegisterCallback("PLAYER_ALIVE", setNames)
	RegisterCallback("PLAYER_LOGIN", setNames)
end
