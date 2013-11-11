--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningBlizzardOptionsMenu")

-- Lua API
local pairs, select, unpack = pairs, select, unpack

local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UISkinning")) or not(GUIS_DB["skinning"][self:GetName()]) then 
		self:Kill() 
		return 
	end
	
	local panelAlpha, r, g, b = 1/5, unpack(C["overlay"])

	LoopbackVUMeter:RemoveTextures()
--	LoopbackVUMeter:SetUITemplate("backdrop")

	-- frames
	do
		AudioOptionsFrame:RemoveTextures()
		AudioOptionsFramePanelContainer:RemoveTextures()
		AudioOptionsFrameCategoryFrame:RemoveTextures()
		AudioOptionsSoundPanelPlayback:RemoveTextures()
		AudioOptionsSoundPanelHardware:RemoveTextures()
		AudioOptionsSoundPanelVolume:RemoveTextures()
		AudioOptionsVoicePanelTalking:RemoveTextures()
		AudioOptionsVoicePanelBinding:RemoveTextures()
		AudioOptionsVoicePanelListening:RemoveTextures()
		InterfaceOptionsFrameAddOns:RemoveTextures()
		InterfaceOptionsFrame:RemoveTextures()
		InterfaceOptionsFramePanelContainer:RemoveTextures()
		InterfaceOptionsFrameCategories:RemoveTextures()
		VideoOptionsFrame:RemoveTextures()
		VideoOptionsFramePanelContainer:RemoveTextures()
		VideoOptionsFrameCategoryFrame:RemoveTextures()
		
		InterfaceOptionsFrame:SetUITemplate("simplebackdrop")
		VideoOptionsFrame:SetUITemplate("simplebackdrop")
		
		if (F.IsBuild(4,3)) then
			AudioOptionsFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		end
		
		AudioOptionsFrameCategoryFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		AudioOptionsFramePanelContainer:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		AudioOptionsFrameCategoryFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		AudioOptionsSoundPanelPlayback:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		AudioOptionsSoundPanelHardware:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		AudioOptionsSoundPanelVolume:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		AudioOptionsVoicePanelTalking:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		AudioOptionsVoicePanelBinding:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		AudioOptionsVoicePanelListening:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		InterfaceOptionsFrameAddOns:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		InterfaceOptionsFramePanelContainer:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		InterfaceOptionsFrameCategories:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		VideoOptionsFramePanelContainer:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		VideoOptionsFrameCategoryFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	end

	-- buttons
	do
		AudioOptionsFrameOkay:SetUITemplate("button")
		AudioOptionsFrameCancel:SetUITemplate("button")
		AudioOptionsFrameDefaults:SetUITemplate("button")
		AudioOptionsVoicePanelChatMode1KeyBindingButton:SetUITemplate("button")

		if (CompactUnitFrameProfilesSaveButton) then CompactUnitFrameProfilesSaveButton:SetUITemplate("button") end
		if (CompactUnitFrameProfilesDeleteButton) then CompactUnitFrameProfilesDeleteButton:SetUITemplate("button") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton) then CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton:SetUITemplate("button") end

	--	RecordLoopbackSoundButton:SetUITemplate("button")
	--	PlayLoopbackSoundButton:SetUITemplate("button")

		InterfaceOptionsFrameDefaults:SetUITemplate("button")
		InterfaceOptionsFrameOkay:SetUITemplate("button")
		InterfaceOptionsFrameCancel:SetUITemplate("button")
		InterfaceOptionsHelpPanelResetTutorials:SetUITemplate("button")

		VideoOptionsFrameOkay:SetUITemplate("button")
		VideoOptionsFrameCancel:SetUITemplate("button")
		VideoOptionsFrameDefaults:SetUITemplate("button")
		VideoOptionsFrameApply:SetUITemplate("button")
	end

	-- I laugh at the amount of checkboxes here...
	-- This skinning venture is really turning into a massive overkill
	do 
		Advanced_DesktopGamma:SetUITemplate("checkbutton")
		Advanced_UseUIScale:SetUITemplate("checkbutton")
		Advanced_MaxFPSCheckBox:SetUITemplate("checkbutton")
		Advanced_MaxFPSBKCheckBox:SetUITemplate("checkbutton")

		AudioOptionsSoundPanelEnableSound:SetUITemplate("checkbutton")
		AudioOptionsSoundPanelSoundEffects:SetUITemplate("checkbutton")
		AudioOptionsSoundPanelErrorSpeech:SetUITemplate("checkbutton")
		AudioOptionsSoundPanelEmoteSounds:SetUITemplate("checkbutton")
		AudioOptionsSoundPanelPetSounds:SetUITemplate("checkbutton")
		AudioOptionsSoundPanelMusic:SetUITemplate("checkbutton")
		AudioOptionsSoundPanelLoopMusic:SetUITemplate("checkbutton")
		AudioOptionsSoundPanelAmbientSounds:SetUITemplate("checkbutton")
		AudioOptionsSoundPanelSoundInBG:SetUITemplate("checkbutton")
		AudioOptionsSoundPanelReverb:SetUITemplate("checkbutton")
		AudioOptionsSoundPanelHRTF:SetUITemplate("checkbutton")
		AudioOptionsSoundPanelEnableDSPs:SetUITemplate("checkbutton")
		AudioOptionsSoundPanelUseHardware:SetUITemplate("checkbutton")

		AudioOptionsVoicePanelEnableVoice:SetUITemplate("checkbutton")
		AudioOptionsVoicePanelEnableMicrophone:SetUITemplate("checkbutton")
		AudioOptionsVoicePanelPushToTalkSound:SetUITemplate("checkbutton")

		if (CompactUnitFrameProfilesRaidStylePartyFrames) then CompactUnitFrameProfilesRaidStylePartyFrames:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameKeepGroupsTogether) then CompactUnitFrameProfilesGeneralOptionsFrameKeepGroupsTogether:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameDisplayIncomingHeals) then CompactUnitFrameProfilesGeneralOptionsFrameDisplayIncomingHeals:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameDisplayPowerBar) then CompactUnitFrameProfilesGeneralOptionsFrameDisplayPowerBar:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameDisplayAggroHighlight) then CompactUnitFrameProfilesGeneralOptionsFrameDisplayAggroHighlight:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameUseClassColors) then CompactUnitFrameProfilesGeneralOptionsFrameUseClassColors:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameDisplayPets) then CompactUnitFrameProfilesGeneralOptionsFrameDisplayPets:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameDisplayMainTankAndAssist) then CompactUnitFrameProfilesGeneralOptionsFrameDisplayMainTankAndAssist:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameDisplayBorder) then CompactUnitFrameProfilesGeneralOptionsFrameDisplayBorder:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameShowDebuffs) then CompactUnitFrameProfilesGeneralOptionsFrameShowDebuffs:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameDisplayOnlyDispellableDebuffs) then CompactUnitFrameProfilesGeneralOptionsFrameDisplayOnlyDispellableDebuffs:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate2Players) then CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate2Players:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate3Players) then CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate3Players:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate5Players) then CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate5Players:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate10Players) then CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate10Players:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate15Players) then CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate15Players:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate25Players) then CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate25Players:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate40Players) then CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate40Players:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec1) then CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec1:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec2) then CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec2:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvP) then CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvP:SetUITemplate("checkbutton") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvE) then CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvE:SetUITemplate("checkbutton") end

		InterfaceOptionsActionBarsPanelLockActionBars:SetUITemplate("checkbutton")
		InterfaceOptionsActionBarsPanelSecureAbilityToggle:SetUITemplate("checkbutton")
		InterfaceOptionsActionBarsPanelRight:SetUITemplate("checkbutton")
		InterfaceOptionsActionBarsPanelRightTwo:SetUITemplate("checkbutton")
		InterfaceOptionsActionBarsPanelBottomLeft:SetUITemplate("checkbutton")
		InterfaceOptionsActionBarsPanelBottomRight:SetUITemplate("checkbutton")
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetUITemplate("checkbutton")

		InterfaceOptionsBattlenetPanelOnlineFriends:SetUITemplate("checkbutton")
		InterfaceOptionsBattlenetPanelOfflineFriends:SetUITemplate("checkbutton")
		InterfaceOptionsBattlenetPanelBroadcasts:SetUITemplate("checkbutton")
		InterfaceOptionsBattlenetPanelFriendRequests:SetUITemplate("checkbutton")
		InterfaceOptionsBattlenetPanelConversations:SetUITemplate("checkbutton")
		InterfaceOptionsBattlenetPanelShowToastWindow:SetUITemplate("checkbutton")

		InterfaceOptionsBuffsPanelBuffDurations:SetUITemplate("checkbutton")
		InterfaceOptionsBuffsPanelDispellableDebuffs:SetUITemplate("checkbutton")
		InterfaceOptionsBuffsPanelCastableBuffs:SetUITemplate("checkbutton")
		InterfaceOptionsBuffsPanelConsolidateBuffs:SetUITemplate("checkbutton")
		
		if (InterfaceOptionsBuffsPanelShowCastableDebuffs) then InterfaceOptionsBuffsPanelShowCastableDebuffs:SetUITemplate("checkbutton") end
		if (InterfaceOptionsBuffsPanelShowAllEnemyDebuffs) then InterfaceOptionsBuffsPanelShowAllEnemyDebuffs:SetUITemplate("checkbutton") end
		if (InterfaceOptionsCombatPanelActionButtonUseKeyDown) then InterfaceOptionsCombatPanelActionButtonUseKeyDown:SetUITemplate("checkbutton") end
		if (InterfaceOptionsCombatPanelCastBarsOnPortrait) then InterfaceOptionsCombatPanelCastBarsOnPortrait:SetUITemplate("checkbutton") end
		if (InterfaceOptionsCombatPanelCastBarsOnNameplates) then InterfaceOptionsCombatPanelCastBarsOnNameplates:SetUITemplate("checkbutton") end

		InterfaceOptionsCameraPanelFollowTerrain:SetUITemplate("checkbutton")
		InterfaceOptionsCameraPanelHeadBob:SetUITemplate("checkbutton")
		InterfaceOptionsCameraPanelWaterCollision:SetUITemplate("checkbutton")
		InterfaceOptionsCameraPanelSmartPivot:SetUITemplate("checkbutton")
		InterfaceOptionsCombatPanelAttackOnAssist:SetUITemplate("checkbutton")
		InterfaceOptionsCombatPanelStopAutoAttack:SetUITemplate("checkbutton")
		InterfaceOptionsCombatPanelNameplateClassColors:SetUITemplate("checkbutton")
		InterfaceOptionsCombatPanelTargetOfTarget:SetUITemplate("checkbutton")
		InterfaceOptionsCombatPanelShowSpellAlerts:SetUITemplate("checkbutton")
		InterfaceOptionsCombatPanelReducedLagTolerance:SetUITemplate("checkbutton")
		InterfaceOptionsCombatPanelAutoSelfCast:SetUITemplate("checkbutton")

		InterfaceOptionsCombatTextPanelTargetDamage:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelPeriodicDamage:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelPetDamage:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelHealing:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelTargetEffects:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelOtherTargetEffects:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelEnableFCT:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelDodgeParryMiss:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelDamageReduction:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelRepChanges:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelReactiveAbilities:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelFriendlyHealerNames:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelCombatState:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelComboPoints:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelLowManaHealth:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelEnergyGains:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelPeriodicEnergyGains:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelHonorGains:SetUITemplate("checkbutton")
		InterfaceOptionsCombatTextPanelAuras:SetUITemplate("checkbutton")

		InterfaceOptionsControlsPanelStickyTargeting:SetUITemplate("checkbutton")
		InterfaceOptionsControlsPanelAutoDismount:SetUITemplate("checkbutton")
		InterfaceOptionsControlsPanelAutoClearAFK:SetUITemplate("checkbutton")
		InterfaceOptionsControlsPanelBlockTrades:SetUITemplate("checkbutton")
		InterfaceOptionsControlsPanelBlockGuildInvites:SetUITemplate("checkbutton")
		InterfaceOptionsControlsPanelLootAtMouse:SetUITemplate("checkbutton")
		InterfaceOptionsControlsPanelAutoLootCorpse:SetUITemplate("checkbutton")
		if (InterfaceOptionsControlsPanelInteractOnLeftClick) then InterfaceOptionsControlsPanelInteractOnLeftClick:SetUITemplate("checkbutton") end

		InterfaceOptionsDisplayPanelShowCloak:SetUITemplate("checkbutton")
		InterfaceOptionsDisplayPanelShowHelm:SetUITemplate("checkbutton")
		InterfaceOptionsDisplayPanelShowAggroPercentage:SetUITemplate("checkbutton")
		InterfaceOptionsDisplayPanelPlayAggroSounds:SetUITemplate("checkbutton")
		InterfaceOptionsDisplayPanelDetailedLootInfo:SetUITemplate("checkbutton")
		if (InterfaceOptionsDisplayPanelSpellPointsAvg) then InterfaceOptionsDisplayPanelSpellPointsAvg:SetUITemplate("checkbutton") end
		if (InterfaceOptionsDisplayPanelShowSpellPointsAvg) then InterfaceOptionsDisplayPanelShowSpellPointsAvg:SetUITemplate("checkbutton") end
		if (InterfaceOptionsDisplayPanelColorblindMode) then InterfaceOptionsDisplayPanelColorblindMode:SetUITemplate("checkbutton") end
		InterfaceOptionsDisplayPanelemphasizeMySpellEffects:SetUITemplate("checkbutton")
		InterfaceOptionsDisplayPanelCinematicSubtitles:SetUITemplate("checkbutton")
		InterfaceOptionsDisplayPanelRotateMinimap:SetUITemplate("checkbutton")
		InterfaceOptionsDisplayPanelScreenEdgeFlash:SetUITemplate("checkbutton")
		InterfaceOptionsDisplayPanelShowFreeBagSpace:SetUITemplate("checkbutton")

		InterfaceOptionsHelpPanelShowTutorials:SetUITemplate("checkbutton")
		InterfaceOptionsHelpPanelLoadingScreenTips:SetUITemplate("checkbutton")
		InterfaceOptionsHelpPanelEnhancedTooltips:SetUITemplate("checkbutton")
		InterfaceOptionsHelpPanelBeginnerTooltips:SetUITemplate("checkbutton")
		InterfaceOptionsHelpPanelShowLuaErrors:SetUITemplate("checkbutton")
		if (InterfaceOptionsHelpPanelColorblindMode) then InterfaceOptionsHelpPanelColorblindMode:SetUITemplate("checkbutton") end
		if (InterfaceOptionsHelpPanelMovePad) then InterfaceOptionsHelpPanelMovePad:SetUITemplate("checkbutton") end

		InterfaceOptionsMousePanelInvertMouse:SetUITemplate("checkbutton")
		InterfaceOptionsMousePanelClickToMove:SetUITemplate("checkbutton")
		InterfaceOptionsMousePanelWoWMouse:SetUITemplate("checkbutton")

		InterfaceOptionsNamesPanelMyName:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelFriendlyPlayerNames:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelFriendlyPets:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelFriendlyGuardians:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelFriendlyTotems:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelUnitNameplatesFriends:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelUnitNameplatesFriendlyPets:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelUnitNameplatesFriendlyGuardians:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelUnitNameplatesFriendlyTotems:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelGuilds:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelGuildTitles:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelTitles:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelNonCombatCreature:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelEnemyPlayerNames:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelEnemyPets:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelEnemyGuardians:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelEnemyTotems:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelUnitNameplatesEnemies:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelUnitNameplatesEnemyPets:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelUnitNameplatesEnemyGuardians:SetUITemplate("checkbutton")
		InterfaceOptionsNamesPanelUnitNameplatesEnemyTotems:SetUITemplate("checkbutton")

		InterfaceOptionsObjectivesPanelAutoQuestTracking:SetUITemplate("checkbutton")
		InterfaceOptionsObjectivesPanelAutoQuestProgress:SetUITemplate("checkbutton")
		InterfaceOptionsObjectivesPanelMapQuestDifficulty:SetUITemplate("checkbutton")
		
		if (InterfaceOptionsObjectivesPanelAdvancedWorldMap) then InterfaceOptionsObjectivesPanelAdvancedWorldMap:SetUITemplate("checkbutton") end
		
		InterfaceOptionsObjectivesPanelWatchFrameWidth:SetUITemplate("checkbutton")

		InterfaceOptionsSocialPanelProfanityFilter:SetUITemplate("checkbutton")
		InterfaceOptionsSocialPanelSpamFilter:SetUITemplate("checkbutton")
		InterfaceOptionsSocialPanelChatBubbles:SetUITemplate("checkbutton")
		InterfaceOptionsSocialPanelPartyChat:SetUITemplate("checkbutton")
		InterfaceOptionsSocialPanelChatHoverDelay:SetUITemplate("checkbutton")
		InterfaceOptionsSocialPanelGuildMemberAlert:SetUITemplate("checkbutton")
		InterfaceOptionsSocialPanelChatMouseScroll:SetUITemplate("checkbutton")
		
		if (InterfaceOptionsSocialPanelGuildRecruitment) then InterfaceOptionsSocialPanelGuildRecruitment:SetUITemplate("checkbutton") end
		
		if (InterfaceOptionsSocialPanelWholeChatWindowClickable) then InterfaceOptionsSocialPanelWholeChatWindowClickable:SetUITemplate("checkbutton") end

		InterfaceOptionsStatusTextPanelPlayer:SetUITemplate("checkbutton")
		InterfaceOptionsStatusTextPanelPet:SetUITemplate("checkbutton")
		InterfaceOptionsStatusTextPanelTarget:SetUITemplate("checkbutton")
		InterfaceOptionsStatusTextPanelXP:SetUITemplate("checkbutton")
		InterfaceOptionsStatusTextPanelAlternateResource:SetUITemplate("checkbutton")
		InterfaceOptionsStatusTextPanelParty:SetUITemplate("checkbutton")
		InterfaceOptionsStatusTextPanelPercentages:SetUITemplate("checkbutton")

		InterfaceOptionsUnitFramePanelPartyBackground:SetUITemplate("checkbutton")
		InterfaceOptionsUnitFramePanelPartyPets:SetUITemplate("checkbutton")
		InterfaceOptionsUnitFramePanelArenaEnemyFrames:SetUITemplate("checkbutton")
		InterfaceOptionsUnitFramePanelArenaEnemyCastBar:SetUITemplate("checkbutton")
		InterfaceOptionsUnitFramePanelArenaEnemyPets:SetUITemplate("checkbutton")
		InterfaceOptionsUnitFramePanelFullSizeFocusFrame:SetUITemplate("checkbutton")

		if (NetworkOptionsPanelOptimizeSpeed) then NetworkOptionsPanelOptimizeSpeed:SetUITemplate("checkbutton") end
		if (NetworkOptionsPanelUseIPv6) then NetworkOptionsPanelUseIPv6:SetUITemplate("checkbutton") end
	end
	
	-- dropdowns
	do
		Advanced_BufferingDropDown:SetUITemplate("dropdown", true)
		Advanced_LagDropDown:SetUITemplate("dropdown", true)
		Advanced_HardwareCursorDropDown:SetUITemplate("dropdown", true)
		if (Advanced_GraphicsAPIDropDown) then Advanced_GraphicsAPIDropDown:SetUITemplate("dropdown", true) end

		AudioOptionsVoicePanelInputDeviceDropDown:SetUITemplate("dropdown", true)
		AudioOptionsVoicePanelChatModeDropDown:SetUITemplate("dropdown", true)
		AudioOptionsVoicePanelOutputDeviceDropDown:SetUITemplate("dropdown", true)
		AudioOptionsSoundPanelHardwareDropDown:SetUITemplate("dropdown", true)
		AudioOptionsSoundPanelSoundChannelsDropDown:SetUITemplate("dropdown", true)

		if (CompactUnitFrameProfilesProfileSelector) then CompactUnitFrameProfilesProfileSelector:SetUITemplate("dropdown", true) end
		if (CompactUnitFrameProfilesGeneralOptionsFrameSortByDropdown) then CompactUnitFrameProfilesGeneralOptionsFrameSortByDropdown:SetUITemplate("dropdown", true) end
		if (CompactUnitFrameProfilesGeneralOptionsFrameHealthTextDropdown) then CompactUnitFrameProfilesGeneralOptionsFrameHealthTextDropdown:SetUITemplate("dropdown", true) end

		Graphics_DisplayModeDropDown:SetUITemplate("dropdown", true)
		Graphics_ResolutionDropDown:SetUITemplate("dropdown", true)
		Graphics_RefreshDropDown:SetUITemplate("dropdown", true)
		Graphics_PrimaryMonitorDropDown:SetUITemplate("dropdown", true)
		Graphics_MultiSampleDropDown:SetUITemplate("dropdown", true)
		Graphics_VerticalSyncDropDown:SetUITemplate("dropdown", true)
		Graphics_TextureResolutionDropDown:SetUITemplate("dropdown", true)
		Graphics_FilteringDropDown:SetUITemplate("dropdown", true)
		Graphics_ProjectedTexturesDropDown:SetUITemplate("dropdown", true)
		Graphics_ViewDistanceDropDown:SetUITemplate("dropdown", true)
		Graphics_EnvironmentalDetailDropDown:SetUITemplate("dropdown", true)
		Graphics_GroundClutterDropDown:SetUITemplate("dropdown", true)
		Graphics_ShadowsDropDown:SetUITemplate("dropdown", true)
		Graphics_LiquidDetailDropDown:SetUITemplate("dropdown", true)
		Graphics_SunshaftsDropDown:SetUITemplate("dropdown", true)
		Graphics_ParticleDensityDropDown:SetUITemplate("dropdown", true)

		InterfaceOptionsLanguagesPanelLocaleDropDown:SetUITemplate("dropdown", true)
		InterfaceOptionsControlsPanelAutoLootKeyDropDown:SetUITemplate("dropdown", true)
		InterfaceOptionsCombatPanelTOTDropDown:SetUITemplate("dropdown", true)
		InterfaceOptionsCombatPanelFocusCastKeyDropDown:SetUITemplate("dropdown", true)
		InterfaceOptionsCombatPanelSelfCastKeyDropDown:SetUITemplate("dropdown", true)
		InterfaceOptionsDisplayPanelAggroWarningDisplay:SetUITemplate("dropdown", true)
		InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay:SetUITemplate("dropdown", true)
		InterfaceOptionsSocialPanelChatStyle:SetUITemplate("dropdown", true)
		InterfaceOptionsSocialPanelTimestamps:SetUITemplate("dropdown", true)
		InterfaceOptionsSocialPanelWhisperMode:SetUITemplate("dropdown", true)
		InterfaceOptionsSocialPanelBnWhisperMode:SetUITemplate("dropdown", true)
		InterfaceOptionsSocialPanelConversationMode:SetUITemplate("dropdown", true)
		if (InterfaceOptionsActionBarsPanelPickupActionKeyDropDown) then InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetUITemplate("dropdown", true) end
		InterfaceOptionsNamesPanelNPCNamesDropDown:SetUITemplate("dropdown", true)
		if (InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown) then InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown:SetUITemplate("dropdown", true) end
		InterfaceOptionsCombatTextPanelFCTDropDown:SetUITemplate("dropdown", true)
		InterfaceOptionsCameraPanelStyleDropDown:SetUITemplate("dropdown", true)
		InterfaceOptionsMousePanelClickMoveStyleDropDown:SetUITemplate("dropdown", true)
	end

	-- sliders
	do
		Advanced_GammaSlider:SetUITemplate("slider")
		Advanced_MaxFPSSlider:SetUITemplate("slider")
		Advanced_MaxFPSBKSlider:SetUITemplate("slider")
		Advanced_UIScaleSlider:SetUITemplate("slider")
		AudioOptionsSoundPanelSoundQuality:SetUITemplate("slider")
		AudioOptionsSoundPanelMasterVolume:SetUITemplate("slider")
		AudioOptionsSoundPanelSoundVolume:SetUITemplate("slider")
		AudioOptionsSoundPanelMusicVolume:SetUITemplate("slider")
		AudioOptionsSoundPanelAmbienceVolume:SetUITemplate("slider")
		AudioOptionsVoicePanelMicrophoneVolume:SetUITemplate("slider")
		AudioOptionsVoicePanelSpeakerVolume:SetUITemplate("slider")
		AudioOptionsVoicePanelSoundFade:SetUITemplate("slider")
		AudioOptionsVoicePanelMusicFade:SetUITemplate("slider")
		AudioOptionsVoicePanelAmbienceFade:SetUITemplate("slider")
		if (CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider) then CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider:SetUITemplate("slider") end
		if (CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider) then CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider:SetUITemplate("slider") end
		Graphics_RightQuality:RemoveTextures()
		Graphics_Quality:SetUITemplate("slider")
		InterfaceOptionsCombatPanelSpellAlertOpacitySlider:SetUITemplate("slider")
		InterfaceOptionsCombatPanelMaxSpellStartRecoveryOffset:SetUITemplate("slider")
		InterfaceOptionsBattlenetPanelToastDurationSlider:SetUITemplate("slider")
		InterfaceOptionsCameraPanelMaxDistanceSlider:SetUITemplate("slider")
		InterfaceOptionsCameraPanelFollowSpeedSlider:SetUITemplate("slider")
		InterfaceOptionsMousePanelMouseSensitivitySlider:SetUITemplate("slider")
		InterfaceOptionsMousePanelMouseLookSpeedSlider:SetUITemplate("slider")
	end

	-- tabs
	do
		InterfaceOptionsFrameTab1:SetUITemplate("tab", true)
		InterfaceOptionsFrameTab2:SetUITemplate("tab", true)
	end
	
	-- headers
	-- perfection is not a sin
	do
		InterfaceOptionsFrameHeader:ClearAllPoints()
		InterfaceOptionsFrameHeader:SetPoint("TOP", InterfaceOptionsFrame, "TOP", 0, 8)
		InterfaceOptionsFrameHeaderText:SetFontObject(GUIS_SystemFontVeryLarge)

		AudioOptionsFrameHeader:ClearAllPoints()
		AudioOptionsFrameHeader:SetPoint("TOP", AudioOptionsFrame, "TOP", 0, 8)
		AudioOptionsFrameHeaderText:SetFontObject(GUIS_SystemFontVeryLarge)

		VideoOptionsFrameHeader:ClearAllPoints()
		VideoOptionsFrameHeader:SetPoint("TOP", VideoOptionsFrame, "TOP", 0, 8)
		VideoOptionsFrameHeaderText:SetFontObject(GUIS_SystemFontVeryLarge)
	end
	
	-- addons listing
	do
		local skins = {}
		local updateAddOnList = function()
			for i,button in pairs(InterfaceOptionsFrameAddOns.buttons) do
				local toggle = _G[button:GetName() .. "Toggle"]
				if (toggle) and not(skins[toggle]) then
					toggle:SetUITemplate("arrow")
					skins[toggle] = true
				end
			end
		end
		hooksecurefunc("InterfaceAddOnsList_Update", updateAddOnList)
		updateAddOnList()
	end

	-- mac clients
	-- I can't test this perfectly, so do not hesitate to give feedback. With screenshots.
	if (IsMacClient()) then
		-- Just some hackish ways of getting the frame to show properly on a Windows client
		--MovieRecording_IsSupported = noop
		--MacOptions_IsUniversalAccessEnabled = noop
	
		MacOptionsFrame:RemoveTextures()
		MacOptionsFrameHeader:RemoveTextures()
		MacOptionsButtonCompress:RemoveClutter()
		MacOptionsButtonKeybindings:RemoveClutter()
		MacOptionsFrameMovieRecording:RemoveTextures()
		MacOptionsITunesRemote:RemoveTextures()

		if (MacOptionsFrameMisc) then 
			MacOptionsFrameMisc:RemoveTextures()
			MacOptionsFrameMisc:SetUITemplate("simplebackdrop") 
		end
		
		MacOptionsFrame:SetUITemplate("simplebackdrop")
		MacOptionsFrameMovieRecording:SetUITemplate("simplebackdrop")
		MacOptionsITunesRemote:SetUITemplate("simplebackdrop")

		MacOptionsFrameCancel:SetUITemplate("button")
		MacOptionsFrameOkay:SetUITemplate("button")
		MacOptionsButtonKeybindings:SetUITemplate("button")
		MacOptionsFrameDefaults:SetUITemplate("button")
		MacOptionsButtonCompress:SetUITemplate("button")
		MacOptionsFrameResolutionDropDown:SetUITemplate("dropdown", true, 165)
		MacOptionsFrameFramerateDropDown:SetUITemplate("dropdown", true, 165)
		MacOptionsFrameCodecDropDown:SetUITemplate("dropdown", true, 165)
		MacOptionsFrameQualitySlider:SetUITemplate("slider")
		
		local i = 1
		while (i) do
			local button = _G["MacOptionsFrameCheckButton" .. i]
			if (button) then
				button:SetUITemplate("button")
				i = i + 1
			else
				i = nil
			end
		end

		MacOptionsFrameHeader:ClearAllPoints()
		MacOptionsFrameHeader:SetPoint("TOP", MacOptionsFrame, "TOP", 0, -8)
	end
end
