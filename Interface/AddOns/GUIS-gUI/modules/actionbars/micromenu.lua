--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local moduleName = "GUIS-gUI: ActionBarsMicroMenu"
local module = LibStub("gCore-3.0"):NewModule(moduleName)

-- Lua API
local _G = _G
local strfind, strmatch = string.find, string.match
local ipairs, select, unpack = ipairs, select, unpack
local print = print

-- WoW API
local CloseAllWindows = CloseAllWindows
local CloseMenus = CloseMenus
local CreateFrame = CreateFrame
local GetGuildLogoInfo = GetGuildLogoInfo
local GetScreenHeight = GetScreenHeight
local HideUIPanel, ShowUIPanel = HideUIPanel, ShowUIPanel
local InCombatLockdown = InCombatLockdown
local MicroButtonTooltipText = MicroButtonTooltipText
local SetPortraitTexture = SetPortraitTexture
local SetSmallGuildTabardTextures = SetSmallGuildTabardTextures

local GameTooltip = GameTooltip

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local gFH = LibStub("gFrameHandler-1.0")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterBucketEvent = function(...) return module:RegisterBucketEvent(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local FireCallback = function(...) return module:FireCallback(...) end
local ScheduleTimer = function(...) module:ScheduleTimer(...) end

local playerClass = (select(2, UnitClass("player")))
local playerLevel = UnitLevel("player")

-- we decided to NOT use WoW globals after all. 'we' as in 'me'.
local ACHIEVEMENT_BUTTON = L["Achievements"]
local CHARACTER_BUTTON = L["Character Info"]
local DUNGEONS_BUTTON = L["Dungeon Finder"]
local ENCOUNTER_JOURNAL = L["Dungeon Journal"]
local ERR_RESTRICTED_ACCOUNT = L["Starter Edition accounts cannot perform that action"]
local GUILD = L["Guild"]
local HELP_BUTTON = L["Customer Support"]
local LOOKINGFORGUILD = _G.LOOKINGFORGUILD and L["Guild Finder"] or L["You're not currently a member of a Guild"]
local MAINMENU_BUTTON = L["Game Menu"]
local PLAYER_V_PLAYER = L["Player vs Player"]
local QUESTLOG_BUTTON = L["Quest Log"]
local RAID = L["Raid"]
local SPELLBOOK_ABILITIES_BUTTON = L["Spellbook & Abilities"]
local TALENTS_BUTTON = L["Talents"]
local TALENTS_UNAVAILABLE_TOOLTIP = L["This feature becomes available once you earn a Talent Point."]
local SHOW_TALENT_LEVEL = SHOW_TALENT_LEVEL or 10

local MicroMenu

-- this is the actual order of the displayed buttons
local buttonList = { 
	"Character"; 
	"Spellbook"; 
	"Talents"; 
	"Achievement"; 
	"Quest"; 
	"Socials"; 
	"PVP"; 
	"LFG";
	EJMicroButton and "EJ" or nil;
	RaidMicroButton and "Raid" or nil;
	"MainMenu";
	HelpMicroButton and "Help" or nil;
}

local buttons = {}
local buttonSize = { 20, 24 }

local makeButton
local updatePosition, updateIcons
local updateGuild, updateTalents, updatePortrait
local placeTooltip, OnEnter, OnLeave

placeTooltip = function(self)
	local point, _, relpoint, x, y = (self:GetParent() or MicroMenu or self):GetPoint()

	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:ClearAllPoints()
	
	if (point == "RIGHT") then
		GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -2, -1)
		
	elseif (point == "LEFT") then
		GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", -2, -1)
		
	elseif strfind(point, "BOTTOM") then
		GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 2)
		
	elseif strfind(point, "TOP") then
		GameTooltip:SetPoint("TOP", self, "BOTTOM", 0, -2)
		
	else
		if (GetScreenHeight() - self:GetTop()) > self:GetBottom() then
			GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 2)
		else
			GameTooltip:SetPoint("TOP", self, "BOTTOM", 0, -2)
		end
	end
end

OnEnter = function(self)
	placeTooltip(self)
	
	local msg
	if (self.name == "Achievement") then
		msg = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT")
		
	elseif (self.name == "Character") then
		msg = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0")
		
	elseif (self.name == "EJ") and (EJMicroButton) then
		msg = MicroButtonTooltipText(ENCOUNTER_JOURNAL, "TOGGLEENCOUNTERJOURNAL")

	elseif (self.name == "Raid") then
		msg = MicroButtonTooltipText(RAID, "TOGGLERAIDTAB")
		
	elseif (self.name == "Socials") then
		if (IsTrialAccount) and (IsTrialAccount()) then
			msg = ERR_RESTRICTED_ACCOUNT
		else
			if IsInGuild() then 
				msg = MicroButtonTooltipText(GUILD, "TOGGLEGUILDTAB")
			else
				msg = MicroButtonTooltipText(LOOKINGFORGUILD, "TOGGLEGUILDTAB")
			end
		end
		
	elseif (self.name == "Help") and (HelpMicroButton) then
		msg = MicroButtonTooltipText(HELP_BUTTON, "GUISTOGGLECUSTOMERSUPPORT")
		
	elseif (self.name == "LFG") then
		msg = MicroButtonTooltipText(DUNGEONS_BUTTON, "TOGGLELFGPARENT")
		
	elseif (self.name == "MainMenu") then
		msg = MicroButtonTooltipText(MAINMENU_BUTTON, "TOGGLEGAMEMENU")
		
	elseif (self.name == "PVP") then
		msg = MicroButtonTooltipText(PLAYER_V_PLAYER, "TOGGLECHARACTER4")
		
	elseif (self.name == "Quest") then
		msg = MicroButtonTooltipText(QUESTLOG_BUTTON, "TOGGLEQUESTLOG")
		
	elseif (self.name == "Spellbook") then
		msg = MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK")
		
	elseif (self.name == "Talents") then
		if (playerLevel < SHOW_TALENT_LEVEL) then
			msg = MicroButtonTooltipText(TALENTS_UNAVAILABLE_TOOLTIP, "TOGGLETALENTS")
		else
			msg = MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS")
		end
	end
	
	GameTooltip:AddLine(msg, 1, 1, 1)
	GameTooltip:Show()
end

OnLeave = function(self)
	if (GameTooltip:IsShown()) then
		GameTooltip:Hide()
	end
end

makeButton = function(name)
	local button = CreateFrame("Button", moduleName .. name .. "Button", MicroMenu, "SecureActionButtonTemplate")
	button:SetAttribute("type", "click")
	button:SetScript("OnEnter", function(self) OnEnter(self) end)
	button:SetScript("OnLeave", function(self) OnLeave(self) end)	
	button.name = name

	button:SetUITemplate("itembutton")
	button.candyLayer = CreateFrame("Frame", nil, button)
	button.candyLayer:SetPoint("TOPLEFT", 3, -3)
	button.candyLayer:SetPoint("BOTTOMRIGHT", -3, 3)
	F.GlossAndShade(button.candyLayer)
	
	local texName = name
	button:SetNormalTexture("Interface\\Buttons\\UI-MicroButton-" .. texName .. "-Up")
	button:GetNormalTexture():SetTexCoord(6/32, 26/32, 32/64, 56/64)
	button:GetNormalTexture():ClearAllPoints()
	button:GetNormalTexture():SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
	button:GetNormalTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
	
	button:SetDisabledTexture("Interface\\Buttons\\UI-MicroButton-" .. texName .. "-Disabled")
	button:GetDisabledTexture():SetTexCoord(6/32, 26/32, 32/64, 56/64)
	button:GetDisabledTexture():ClearAllPoints()
	button:GetDisabledTexture():SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
	button:GetDisabledTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)

	local hover = button:CreateTexture(button:GetName() .. "HoverTex", nil, button)
	hover:SetTexture(C["hover"].r, C["hover"].g, C["hover"].b, 0.3)
	hover:ClearAllPoints()
	hover:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
	hover:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
	button:SetHighlightTexture(hover)
		
	return button
end

updateGuild = function()
	local button = _G[moduleName .. "SocialsButton"]
	local tabard = _G[moduleName .. "SocialsButton"].Tabard
	
	local bkgR, bkgG, bkgB, borderR, borderG, borderB, emblemR, emblemG, emblemB, emblemFilename = GetGuildLogoInfo("player")
	
	if (emblemFilename) and (IsInGuild()) then
		button:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up")
		button:SetDisabledTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Disabled")

		if (not tabard:IsShown()) then
			tabard:Show()
		end

		SetSmallGuildTabardTextures("player", tabard.emblem, tabard.background)
	else
		button:SetNormalTexture("Interface\\Buttons\\UI-MicroButton-Socials-Up")
		button:SetDisabledTexture("Interface\\Buttons\\UI-MicroButton-Socials-Disabled")

		if (tabard:IsShown()) then
			tabard:Hide()
		end
	end
end

updateTalents = function()
	if (playerLevel < SHOW_TALENT_LEVEL) then
		if (_G[moduleName .. "TalentsButton"]:IsEnabled()) then
			_G[moduleName .. "TalentsButton"]:Disable()
			return
		end
		
	elseif (playerLevel >= SHOW_TALENT_LEVEL) then
		if (not _G[moduleName .. "TalentsButton"]:IsEnabled()) then
			_G[moduleName .. "TalentsButton"]:Enable()
			return
		end
	end
end

updatePortrait = function()
	SetPortraitTexture(_G[moduleName .. "CharacterButton"].Portrait, "player")
end

updatePosition = function()
	if (MultiBarLeftButton1:IsVisible()) then
		MicroMenu:SetPoint("RIGHT", UIParent, "RIGHT", -(8 + UIParent:GetRight() - MultiBarLeftButton1:GetLeft()), 0)
		
	elseif (MultiBarRightButton1:IsVisible()) then
		MicroMenu:SetPoint("RIGHT", UIParent, "RIGHT", -(8 + UIParent:GetRight() - MultiBarRightButton1:GetLeft()), 0)
		
	else
		MicroMenu:SetPoint("RIGHT", UIParent, "RIGHT", -8, 0)
		
	end
end

updateIcons = function(self, event, ...)
	local arg1 = ...
	
	if (event == "PLAYER_ENTERING_WORLD") then
		if (IsTrialAccount) and (IsTrialAccount()) then
			_G[moduleName .. "SocialsButton"]:Enable()
		end

		updatePortrait()
		updateTalents()
		updateGuild()
		
	elseif (event == "PLAYER_GUILD_UPDATE") or (event == "GUILDTABARD_UPDATE") then
		updateGuild()
		
	elseif (event == "PLAYER_LEVEL_UP") then
		playerLevel = arg1
		updateTalents()
	
	elseif (event == "PLAYER_TALENT_UPDATE") then
		updateTalents()
		
	elseif (event == "UNIT_PORTRAIT_UPDATE") then
		if (arg1 == "player") then
			updatePortrait()
		end
		
	end
end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: ActionBars")) then 
		self:Kill() 
		return 
	end
	
	local vehicle = CreateFrame("Frame", moduleName .. "Wrapper", UIParent)
	RegisterStateDriver(vehicle, "visibility", "[novehicleui] show; hide")
	
	MicroMenu = CreateFrame("Frame", moduleName .. "Frame", vehicle)
	MicroMenu:SetFrameStrata("LOW")
	MicroMenu:SetSize(buttonSize[1], (buttonSize[2]) * #buttonList + (#buttonList - 1) * 2)
	MicroMenu:SetPoint("RIGHT", UIParent, "RIGHT", -8, 0)
	MicroMenu:SetScript("OnShow", function(self) FireCallback("GUIS_MICROMENU_SHOW", self) end)
	MicroMenu:SetScript("OnHide", function(self) FireCallback("GUIS_MICROMENU_HIDE", self) end)

	self.MicroMenu = MicroMenu

	if (GUIS_DB["actionbars"].showbar_micro == 0) then
		MicroMenu:Hide()
	else
		-- we need to manually fire the callback since the menu was already visible
		FireCallback("GUIS_MICROMENU_SHOW", MicroMenu)
	end

	CreateChatCommand(function() 
		if (InCombatLockdown()) then
			print(L["Can't toggle Action Bars while engaged in combat!"])
			return
		end
		GUIS_DB["actionbars"].showbar_micro = 0
		MicroMenu:Hide()
	end, {"hidemicromenu", "hidemicro", "hideminimenu", "hidemini"})

	CreateChatCommand(function() 
		if (InCombatLockdown()) then
			print(L["Can't toggle Action Bars while engaged in combat!"])
			return
		end
		GUIS_DB["actionbars"].showbar_micro = 1
		MicroMenu:Show()
	end, {"showmicromenu", "showmicro", "showminimenu", "showmini"})

	for index, name in ipairs(buttonList) do
		local button = makeButton(name)
		button:SetSize(unpack(buttonSize))
		button:SetPoint("TOPLEFT", MicroMenu, "TOPLEFT", 0, - ((index - 1) * (buttonSize[2] + 2)) )
		if (name ~= "MainMenu") then
			button:SetScript("PreClick", function(self) 
				if (GameMenuFrame:IsShown() ) then
					HideUIPanel(GameMenuFrame)
				end
			end)
		end
	end
	
	-- set up keybindfunctionality
	local binder = LibStub("gCore-3.0"):GetModule("GUIS-gUI: KeyBind")

	local factionGroup = UnitFactionGroup("player")
	if (factionGroup) then
		_G[moduleName.."PVPButton"]:SetNormalTexture("Interface\\TargetingFrame\\UI-PVP-" .. factionGroup)
	else
		_G[moduleName.."PVPButton"]:SetNormalTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
	end
	
	if (factionGroup == "Horde") then
		_G[moduleName.."PVPButton"]:GetNormalTexture():SetTexCoord(1/64, 40/64, 1/64, 38/64)
		
	elseif (factionGroup == "Alliance") then
		_G[moduleName.."PVPButton"]:GetNormalTexture():SetTexCoord(5/64, 36/64, 2/64, 39/64)
		
	else
		_G[moduleName.."PVPButton"]:GetNormalTexture():SetTexCoord(5/64, 36/64, 2/64, 39/64)
		
	end
	
	local tabard = CreateFrame("Frame", nil, _G[moduleName .. "SocialsButton"])
	tabard:SetPoint("TOPLEFT", 3, -3)
	tabard:SetPoint("BOTTOMRIGHT", -3, 3)
	tabard.background = tabard:CreateTexture(nil, "OVERLAY")
	tabard.background:SetAllPoints(tabard)
	tabard.emblem = tabard:CreateTexture(nil, "OVERLAY")
	tabard.emblem:SetAllPoints(tabard)
	_G[moduleName .. "SocialsButton"].Tabard = tabard
		
	local portrait = _G[moduleName .. "CharacterButton"]:CreateTexture(nil, "OVERLAY")
	portrait:SetPoint("TOPLEFT", 3, -3)
	portrait:SetPoint("BOTTOMRIGHT", -3, 3)
	_G[moduleName .. "CharacterButton"].Portrait = portrait

	_G[moduleName .. "AchievementButton"]:SetAttribute("clickbutton", AchievementMicroButton)
	_G[moduleName .. "CharacterButton"]:SetAttribute("type", "macro")	
	_G[moduleName .. "CharacterButton"]:SetAttribute("macrotext", "/run ToggleCharacter('PaperDollFrame')")
	_G[moduleName .. "SocialsButton"]:SetAttribute("clickbutton", GuildMicroButton)
	
	if (_G[moduleName .. "HelpButton"]) then
		_G[moduleName .. "HelpButton"]:SetAttribute("clickbutton", HelpMicroButton)
		binder:Register(_G[moduleName .. "HelpButton"], "GUISTOGGLECUSTOMERSUPPORT") 
	end
	
	_G[moduleName .. "LFGButton"]:SetAttribute("clickbutton", LFDMicroButton)
	_G[moduleName .. "PVPButton"]:SetAttribute("type", "macro")
	_G[moduleName .. "PVPButton"]:SetAttribute("macrotext", "/run TogglePVPFrame()")
	_G[moduleName .. "QuestButton"]:SetAttribute("clickbutton", QuestLogMicroButton)
	_G[moduleName .. "SpellbookButton"]:SetAttribute("clickbutton", SpellbookMicroButton)
	_G[moduleName .. "TalentsButton"]:SetAttribute("clickbutton", TalentMicroButton)
	
	if (_G[moduleName .. "EJButton"]) then
		_G[moduleName .. "EJButton"]:SetAttribute("clickbutton", EJMicroButton)
		binder:Register(_G[moduleName .. "EJButton"], "TOGGLEENCOUNTERJOURNAL")
	end
	
	if (_G[moduleName .. "RaidButton"]) then
		_G[moduleName .. "RaidButton"]:SetAttribute("clickbutton", RaidMicroButton)
		binder:Register(_G[moduleName .. "RaidButton"], "TOGGLERAIDTAB")
	end
	
	if (_G[moduleName .. "MainMenuButton"]) then
		_G[moduleName .. "MainMenuButton"]:SetScript("OnClick", function(self, button)
			if ( not GameMenuFrame:IsShown() ) then
				CloseMenus()
				CloseAllWindows()
				ShowUIPanel(GameMenuFrame)
			else
				HideUIPanel(GameMenuFrame)
			end
		end)
		binder:Register(_G[moduleName .. "MainMenuButton"], "TOGGLEGAMEMENU")
	end
	
	binder:Register(_G[moduleName .. "AchievementButton"], "TOGGLEACHIEVEMENT")
	binder:Register(_G[moduleName .. "CharacterButton"], "TOGGLECHARACTER0")
	binder:Register(_G[moduleName .. "SocialsButton"], "TOGGLESOCIAL")
	binder:Register(_G[moduleName .. "LFGButton"], "TOGGLELFGPARENT")
	binder:Register(_G[moduleName .. "PVPButton"], "TOGGLECHARACTER4")
	binder:Register(_G[moduleName .. "QuestButton"], "TOGGLEQUESTLOG")
	binder:Register(_G[moduleName .. "SpellbookButton"], "TOGGLESPELLBOOK")
	binder:Register(_G[moduleName .. "TalentsButton"], "TOGGLETALENTS")

	MultiBarLeftButton1:HookScript("OnShow", updatePosition)
	MultiBarLeftButton1:HookScript("OnHide", updatePosition)
	MultiBarRightButton1:HookScript("OnShow", updatePosition)
	MultiBarRightButton1:HookScript("OnHide", updatePosition)
	
	RegisterCallback("PLAYER_ENTERING_WORLD", updatePosition)
		
	RegisterBucketEvent({
		"GUILDTABARD_UPDATE",
		"PLAYER_ENTERING_WORLD",
		"PLAYER_GUILD_UPDATE",
		"PLAYER_LEVEL_UP",
		"PLAYER_TALENT_UPDATE",
		"UNIT_PORTRAIT_UPDATE"
	}, 2, updateIcons)
	
end
