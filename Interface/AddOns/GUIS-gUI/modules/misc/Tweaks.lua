local cfg = CreateFrame('Frame')
local GUIS = LibStub("gCore-3.0"):GetModule("GUIS-gUI: Core")
local M = LibStub("gMedia-3.0")
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end

-- True or False for current tweaks ----------------------------------------------------

cfg.AutoAcceptInvite = true -- accept invites
cfg.autorelease = true
cfg.Autodeclineduels = true -- automaticly decline duels
cfg.Auto_greed_on_green_items = true -- automatic 'greed'  
cfg.confirm_disenchant_roll = true -- auctomatic disenchant confirmation 
cfg.lagtolerance = true -- Custom Lag Tolerance(by Elv22)
cfg.hidebgspam = true
cfg.interruptannounce = true

-- End of config // Start of code for tweaks --------------------------------------------

print (' |cFFFF7D0Ag|r|cFFFFBB00UI|r|cFFFFFFFF™|r |cFFFFFFFF2.0|r |cFF4488FFfor Cata|r')

if cfg.Auto_greed_on_green_items then
    local agog = CreateFrame('Frame', nil, UIParent)
	agog:RegisterEvent('START_LOOT_ROLL')
	agog:SetScript('OnEvent', function(_, _, id)
	if not id then return end 
	    local _, _, _, quality, bop, _, _, canDE = GetLootRollItemInfo(id)
	    if quality == 2 and not bop then RollOnLoot(id, canDE and 3 or 2) end
	end)
end

-----------------------------------------------------------------------------------------

if cfg.confirm_disenchant_roll then	
    local acd = CreateFrame('Frame')
    acd:RegisterEvent('CONFIRM_DISENCHANT_ROLL')
    acd:SetScript('OnEvent', function(self, event, id, rollType)
    for i=1,STATICPOPUP_NUMDIALOGS do
	    local frame = _G['StaticPopup'..i]
	    if frame.which == 'CONFIRM_LOOT_ROLL' and frame.data == id and frame.data2 == rollType and frame:IsVisible() then StaticPopup_OnClick(frame, 1) end
	    end
    end)

	
    StaticPopupDialogs['LOOT_BIND'].OnCancel = function(self, slot)
        if GetNumGroupMembers() == 0 then ConfirmLootSlot(slot) end
    end

end

-----------------------------------------------------------------------------------------
	
if cfg.Autodeclineduels	then -- You will really need this for those Molten kids who spam duels all day long.
	local duels = CreateFrame('Frame')
    duels:RegisterEvent('DUEL_REQUESTED')
    duels:SetScript('OnEvent', function(self, event, name)
		HideUIPanel(StaticPopup1)
		CancelDuel()
    end)
end

-----------------------------------------------------------------------------------------

if cfg.autorelease then
	local WINTERGRASP = L_ZONE_WINTERGRASP
	local BARAD = L_ZONE_TOLBARAD

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_DEAD")
	frame:SetScript("OnEvent", function(self, event)
		local inBattlefield = false
		for i = 1, GetMaxBattlefieldID() do
			local status = GetBattlefieldStatus(i)
			if status == "active" then inBattlefield = true end
		end
		if (class ~= "SHAMAN") and not (HasSoulstone() and CanUseSoulstone()) then
			if (tostring(GetZoneText()) == WINTERGRASP) or (tostring(GetZoneText()) == BARAD) or inBattlefield == true then
				RepopMe()
			end
		end
	end)
end

----------------------------------------------------------------------------------------
--	Custom Lag Tolerance(by Elv22)
----------------------------------------------------------------------------------------
if cfg.lagtolerance then
	InterfaceOptionsCombatPanelMaxSpellStartRecoveryOffset:Hide()
	InterfaceOptionsCombatPanelReducedLagTolerance:Hide()

	local customlag = CreateFrame("Frame")
	local int = 5
	local _, _, _, lag = GetNetStats()
	local LatencyUpdate = function(self, elapsed)
		int = int - elapsed
		if int < 0 then
			if GetCVar("reducedLagTolerance") ~= tostring(1) then SetCVar("reducedLagTolerance", tostring(1)) end
			if lag ~= 0 and lag <= 400 then
				SetCVar("maxSpellStartRecoveryOffset", tostring(lag))
			end
			int = 5
		end
	end
	customlag:SetScript("OnUpdate", LatencyUpdate)
	LatencyUpdate(customlag, 10)
end

----------------------------------------------------------------------------------------
--	Remove Boss Emote spam during BG(ArathiBasin SpamFix by Partha)
----------------------------------------------------------------------------------------
if cfg.hidebgspam then
	local Fixer = CreateFrame("Frame")
	local RaidBossEmoteFrame, spamDisabled = RaidBossEmoteFrame

	local function DisableSpam()
		if GetZoneText() == L_ZONE_ARATHIBASIN or GetZoneText() == L_ZONE_GILNEAS then
			RaidBossEmoteFrame:UnregisterEvent("RAID_BOSS_EMOTE")
			spamDisabled = true
		elseif spamDisabled then
			RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_EMOTE")
			spamDisabled = false
		end
	end

	Fixer:RegisterEvent("PLAYER_ENTERING_WORLD")
	Fixer:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	Fixer:SetScript("OnEvent", DisableSpam)
end

----------------------------------------------------------------------------------------
--	Interrupt Announce
----------------------------------------------------------------------------------------

if cfg.interruptannounce then
	local interrupt_announce = CreateFrame("Frame")
		interrupt_announce:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		interrupt_announce:SetScript("OnEvent", function(self, _, ...)
		local _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID = ...
		if not (event == "SPELL_INTERRUPT" and sourceGUID == UnitGUID("player")) then return end

		if GetRealNumRaidMembers() > 0 then
			SendChatMessage(INTERRUPTED.." "..destName..": "..GetSpellLink(spellID), "RAID")
		elseif GetRealNumPartyMembers() > 0 and not UnitInRaid("player") then
			SendChatMessage(INTERRUPTED.." "..destName..": "..GetSpellLink(spellID), "PARTY")
		else
			SendChatMessage(INTERRUPTED.." "..destName..": "..GetSpellLink(spellID), "SAY")
		end
	end)
end

----------------------------------------------------------------------------------------
--	Collect garbage
----------------------------------------------------------------------------------------
local eventcount = 0
local Garbage = CreateFrame("Frame")
Garbage:RegisterAllEvents()
Garbage:SetScript("OnEvent", function(self, event)
	eventcount = eventcount + 1

	if (InCombatLockdown() and eventcount > 25000) or (not InCombatLockdown() and eventcount > 10000) or event == "PLAYER_ENTERING_WORLD" then
		collectgarbage("collect")
		eventcount = 0
	end
end)
