--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: Genocide")

-- Lua API
local print = print
local pairs, select = pairs, select
local strmatch = string.match
local tonumber = tonumber

-- WoW API
local CompactRaidFrameManager_GetSetting = CompactRaidFrameManager_GetSetting
local CompactRaidFrameManager_SetSetting = CompactRaidFrameManager_SetSetting
local InCombatLockdown = InCombatLockdown

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) module:RegisterCallback(...) end

-- change a cvar, but only if it's not already the value we want
-- we do this to avoid firing off hooks related to SetCVar when not needed
local SetCVar = function(cvar, value)
	local c
	if (type(value) == "number") then
		c = tonumber(GetCVar(cvar))
	else
		c = GetCVar(cvar)
	end
	
	if (c ~= value) then
		_G.SetCVar(cvar, value)
	end
end

-- remove an entire blizzard options panel, 
-- and disable its automatic cancel/okay functionality
local KillPanel = function(i, panel)
	if (i) then
		local cat = _G["InterfaceOptionsFrameCategoriesButton" .. i]
		if (cat) then
			cat:SetScale(0.00001)
			cat:SetAlpha(0)
		end
	end
	
	if (panel) then
		panel:Kill()
		panel.cancel = noop
		panel.okay = noop
		panel.refresh = noop
	end
end

-- remove a blizzard menu option, 
-- and disable its automatic cancel/okay functionality
local KillOption = function(shrink, option)
	if not(option) or not(option.IsObjectType) or not(option:IsObjectType("Frame")) then
		return
	end

	option:Kill()
	
	if (shrink) then
		option:SetHeight(0.00001)
	end
	
	option.cvar = ""
	option.uvar = ""
	option.value = nil
	option.oldValue = nil
	option.defaultValue = nil
	option.setFunc = noop
end


module.OnInit = function(self)
	-- general stuff covered by our (not optional) options menu
	KillOption(true, Advanced_UseUIScale)
	KillOption(true, Advanced_UIScaleSlider)
	
	-- actionbars
	-- only need to disable some external stuff here,
	-- as the original bars and art are disabled by the library
	if not(F.kill("GUIS-gUI: ActionBars")) then
		KillPanel(6, InterfaceOptionsActionBarsPanel)

		-- might find a better way for these later
		StreamingIcon:Kill()
		TutorialFrameAlertButton:Kill()
		
		if (GuildChallengeAlertFrame) then
			GuildChallengeAlertFrame:Kill()
		end
	end

	-- auras
	if not(F.kill("GUIS-gUI: Auras")) then
		KillPanel(12, InterfaceOptionsBuffsPanel)

		BuffFrame:Kill()
		ConsolidatedBuffs:Kill()
		TemporaryEnchantFrame:Kill()
	end
	
	if not(F.kill("GUIS-gUI: Bags")) then
		KillOption(true, InterfaceOptionsDisplayPanelShowFreeBagSpace)
	end

	-- chat
	if not(F.kill("GUIS-gUI: Chat")) then
		KillOption(true, InterfaceOptionsSocialPanelTimestamps)
		--InterfaceOptionsSocialPanelTimestamps:SetScale(0.00001)
		--InterfaceOptionsSocialPanelTimestamps:SetAlpha(0)
		ChatConfigFrameDefaultButton:Kill()
		
		local killButtons = function()
			ChatFrameMenuButton:Kill()
			FriendsMicroButton:Kill()
		end
		RegisterCallback("PLAYER_ENTERING_WORLD", killButtons)
	
		local postUpdateStamps = function()
			SetCVar("showTimestamps", "none")
			CHAT_TIMESTAMP_FORMAT = nil
		end
		RegisterCallback("VARIABLES_LOADED", postUpdateStamps)

		killButtons()
		postUpdateStamps()	
	end
	
	-- minimap
	if not(F.kill("GUIS-gUI: Minimap")) then
		--InterfaceOptionsDisplayPanel:UnregisterEvent("PLAYER_ENTERING_WORLD")
		KillOption(true, InterfaceOptionsDisplayPanelRotateMinimap)
	end

	-- nameplates
	if not(F.kill("GUIS-gUI: Nameplates")) then
		KillOption(true, InterfaceOptionsDisplayPanelAggroWarningDisplay)
		KillOption(true, InterfaceOptionsCombatPanelNameplateClassColors)
		KillOption(true, InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait)
		KillOption(true, InterfaceOptionsCombatPanelEnemyCastBars)
		
		-- the nameplates has everything here in its own options menu
		InterfaceOptionsNamesPanelUnitNameplates:Kill()
		KillOption(true, InterfaceOptionsNamesPanelUnitNameplatesFriends)
		KillOption(true, InterfaceOptionsNamesPanelUnitNameplatesFriendlyPets)
		KillOption(true, InterfaceOptionsNamesPanelUnitNameplatesFriendlyGuardians)
		KillOption(true, InterfaceOptionsNamesPanelUnitNameplatesFriendlyTotems)
		KillOption(true, InterfaceOptionsNamesPanelUnitNameplatesEnemies)
		KillOption(true, InterfaceOptionsNamesPanelUnitNameplatesEnemyPets)
		KillOption(true, InterfaceOptionsNamesPanelUnitNameplatesEnemyGuardians)
		KillOption(true, InterfaceOptionsNamesPanelUnitNameplatesEnemyTotems)
		KillOption(true, InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown)

		SetCVar("bloatthreat", 0)
		SetCVar("bloattest", 0)
		SetCVar("bloatnameplates", 0)
	end

	-- quest
	if not(F.kill("GUIS-gUI: Quest")) then
		KillPanel(4, InterfaceOptionsObjectivesPanel)
	end

	-- unitframes
	if not(F.kill("GUIS-gUI: UnitFrames")) then
		KillPanel(9, InterfaceOptionsStatusTextPanel)
		
		KillOption(true, InterfaceOptionsDisplayPanelShowAggroPercentage)
		KillOption(true, InterfaceOptionsCombatPanelTargetOfTarget)
		KillOption(true, InterfaceOptionsCombatPanelTOTDropDown)
		
		-- PlayerFrame:Kill()
		-- party frames
		if not(F.kill("GUIS-gUI: UnitFramesParty")) and (GUIS_DB["unitframes"]["loadpartyframes"]) then
			InterfaceOptionsUnitFramePanelPartyBackground:Kill()
			PartyMemberBackground:Kill()
			
			for i=1, MAX_PARTY_MEMBERS do
				local name = "PartyMemberFrame" .. i

				_G[name]:Kill()
				_G[name .. "HealthBar"]:UnregisterAllEvents()
				_G[name .. "ManaBar"]:UnregisterAllEvents()
			end
			
			local KillPartyFrame = function()
				CompactPartyFrame:Kill()

				for i=1, MEMBERS_PER_RAID_GROUP do
					_G["CompactPartyFrameMember" .. i]:UnregisterAllEvents()
				end			
			end
				
			if (CompactPartyFrame) then
				KillPartyFrame()
				
			-- changed in patch 4.1
			elseif (CompactPartyFrame_Generate) then
				hooksecurefunc("CompactPartyFrame_Generate", KillPartyFrame)
			end	
		end
		
		-- raid frames
		if (not(F.kill("GUIS-gUI: UnitFramesRaid")) and (GUIS_DB["unitframes"]["loadraidframes"])) then
			KillPanel(11, CompactUnitFrameProfiles)
			
			local gone = CreateFrame("Frame")
			gone:Hide()
			
			local once, callback
			local KillRaidFrame = function(self, event, addon)
				if (once) or ((callback) and (addon ~= "Blizzard_CompactRaidFrames")) then
					return
				end
				
				-- stop events, avoid calls
				CompactRaidFrameManager:UnregisterAllEvents()
				CompactRaidFrameContainer:UnregisterAllEvents()
				
				-- stop events in existing frames if any
				local i = 1
				local frame = _G["CompactRaidFrame"..i]
				while (frame) do
					frame:UnregisterAllEvents()
				
					i = i + 1
					frame = _G["CompactRaidFrame"..i]
				end
				
				-- kill the raid frame manager
				local safecall = function(gone)
--					CompactRaidFrameManager:Kill()
					CompactRaidFrameManager:SetParent(gone)
				end
				F.SafeCall(safecall, gone)

				-- set the manager to be hidden
				local shown = CompactRaidFrameManager_GetSetting("IsShown")
				if (shown) and (shown ~= "0") then
					CompactRaidFrameManager_SetSetting("IsShown", "0")
				end
				
				-- kill the callback if it exists
				if (callback) then
					UnregisterCallback(callback)
				end
				
				once = true
			end
--			hooksecurefunc("CompactRaidFrameManager_UpdateShown", KillRaidFrame)
			
			if (IsAddOnLoaded("Blizzard_CompactRaidFrames")) then
				KillRaidFrame()
			else
				callback = RegisterCallback("ADDON_LOADED", KillRaidFrame)
			end
			
		else
			-- fade the raidframe manager
			-- full credits to Zork for this one (http://www.wowinterface.com/forums/showthread.php?t=43068)
			local crfm = _G["CompactRaidFrameManager"]
			local crfb = _G["CompactRaidFrameManagerToggleButton"]

			local ag1, ag2, a1, a2

			--fade in anim
			ag1 = crfm:CreateAnimationGroup()
			a1 = ag1:CreateAnimation("Alpha")
			a1:SetDuration(0.4)
			a1:SetSmoothing("OUT")
			a1:SetChange(1)
			ag1.a1 = a1
			crfm.ag1 = ag1

			--fade out anim
			ag2 = crfm:CreateAnimationGroup()
			a2 = ag2:CreateAnimation("Alpha")
			a2:SetDuration(0.3)
			a2:SetSmoothing("IN")
			a2:SetChange(-1)
			ag2.a2 = a2
			crfm.ag2 = ag2

			crfm.ag1:SetScript("OnFinished", function(ag1)
			local self = ag1:GetParent()
				if not(self.ag2:IsPlaying()) then
					self:SetAlpha(1)
				end
			end)

			crfm.ag2:SetScript("OnFinished", function(ag2)
			local self = ag2:GetParent()
				if not(self.ag1:IsPlaying()) then
					self:SetAlpha(0)
				end
			end)

			crfm:SetAlpha(0)

			crfm:SetScript("OnEnter", function(m)
				if (m.collapsed) and not(m.ag1:IsPlaying()) then
					m.ag2:Stop()
					m:SetAlpha(0)
					m.ag1:Play()
				end
			end)
			
			crfm:SetScript("OnMouseUp", function(self)
				if (self.collapsed) and not(InCombatLockdown()) then
					CompactRaidFrameManager_Toggle(self)
				end
			end)
			
			crfb:SetScript("OnMouseUp", function(self)
				local m = self:GetParent()
				if not(m.collapsed) and not(m.ag2:IsPlaying()) then
					m.ag1:Stop()
					m:SetAlpha(1)
					m.ag2:Play()
				end
			end)
			
			crfm:SetScript("OnLeave", function(m)
				if (m.collapsed) and (GetMouseFocus():GetName() == "WorldFrame") and not(m.ag2:IsPlaying()) then
					m.ag1:Stop()
					m:SetAlpha(1)
					m.ag2:Play()
				end
			end)

		end
		
		-- arena frames
		if not(F.kill("GUIS-gUI: UnitFramesArena")) and (GUIS_DB["unitframes"]["loadarenaframes"]) then
			KillOption(true, InterfaceOptionsUnitFramePanelArenaEnemyFrames)
			KillOption(true, InterfaceOptionsUnitFramePanelArenaEnemyCastBar)
			KillOption(true, InterfaceOptionsUnitFramePanelArenaEnemyPets)
			
			SetCVar("showArenaEnemyFrames", 0)
		end
		
		-- hide the entire category if all of the above modules are activated
		if (not(F.kill("GUIS-gUI: UnitFramesParty")) and (GUIS_DB["unitframes"]["loadpartyframes"]))
		and (not(F.kill("GUIS-gUI: UnitFramesRaid")) and (GUIS_DB["unitframes"]["loadraidframes"]))
		and (not(F.kill("GUIS-gUI: UnitFramesArena")) and (GUIS_DB["unitframes"]["loadarenaframes"])) then
			KillPanel(10, InterfaceOptionsUnitFramePanel)
		end
	end
end

