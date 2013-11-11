--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningDungeonFinder")

-- Lua API
local pairs, select, unpack = pairs, select, unpack

-- GUIS API
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

	-- a simple fix for the 4.3 namechanges that is backwards compatible
	local LFGDungeonReadyDialog = LFGDungeonReadyDialog or LFDDungeonReadyDialog
	local LFGDungeonReadyPopup = LFGDungeonReadyPopup or LFDDungeonReadyPopup 
	local LFGDungeonReadyDialogBackground = LFGDungeonReadyDialogBackground or LFDDungeonReadyDialogBackground 
	local LFGDungeonReadyDialogCloseButton = LFGDungeonReadyDialogCloseButton or LFDDungeonReadyDialogCloseButton 
	local LFGDungeonReadyStatus = LFGDungeonReadyStatus or LFDDungeonReadyStatus 
	local LFGRoleCheckPopup = LFGRoleCheckPopup or LFDRoleCheckPopup 
	local LFGRoleCheckPopupAcceptButton = LFGRoleCheckPopupAcceptButton or LFDRoleCheckPopupAcceptButton 
	local LFGRoleCheckPopupDeclineButton = LFGRoleCheckPopupDeclineButton or LFDRoleCheckPopupDeclineButton 
	local LFGDungeonReadyDialogEnterDungeonButton = LFGDungeonReadyDialogEnterDungeonButton or LFDDungeonReadyDialogEnterDungeonButton 
	local LFGDungeonReadyDialogLeaveQueueButton = LFGDungeonReadyDialogLeaveQueueButton or LFDDungeonReadyDialogLeaveQueueButton 
	local LFGSearchStatus = LFGSearchStatus or LFDSearchStatus 

	-- items renamed in WoW Patch 4.3, moved here for easier future reference
	LFGDungeonReadyDialog:RemoveTextures()
	LFGDungeonReadyDialogBackground:RemoveTextures()
	LFGDungeonReadyDialogEnterDungeonButton:SetUITemplate("button", true)
	LFGDungeonReadyDialogLeaveQueueButton:SetUITemplate("button", true)
	LFGRoleCheckPopupAcceptButton:SetUITemplate("button", true)
	LFGRoleCheckPopupDeclineButton:SetUITemplate("button", true)
	LFGDungeonReadyDialogCloseButton:SetUITemplate("closebutton")
	LFGDungeonReadyDialog:SetUITemplate("simplebackdrop")
	LFGDungeonReadyStatus:SetUITemplate("simplebackdrop")
	LFGRoleCheckPopup:SetUITemplate("simplebackdrop")
	if (LFGDungeonReadyStatusCloseButton) then LFGDungeonReadyStatusCloseButton:SetUITemplate("closebutton", true) end
	LFGDungeonReadyDialog.SetBackdrop = noop
	LFGDungeonReadyStatus.SetBackdrop = noop
	
	-- some 4.3 specifics. I've lost track. so cross your fingers.
	if (F.IsBuild(4,3,0)) then
		LFGDungeonReadyDialogBottomArt:Kill()
		LFGDungeonReadyDialogFiligree:Kill()
		LFGDungeonReadyDialogBackground:Kill()
		
		-- the new waiting texture just doesn't suit anything at all
		-- so for now we're merely making it look like the default eye
		LFG_EYE_TEXTURES["unknown"] = LFG_EYE_TEXTURES["default"]
	end

	LFDParentFrame:RemoveTextures()
	LFDQueueFrame:RemoveTextures()
	LFDQueueFrameSpecific:RemoveTextures()
	LFDQueueFrameRandom:RemoveTextures()
	LFDQueueFrameRandomScrollFrame:RemoveTextures()
	if (LFDQueueFrameCapBar) then LFDQueueFrameCapBar:RemoveTextures() end
	LFDQueueFrameBackground:RemoveTextures()
	if (LFDParentFrameInset) then LFDParentFrameInset:RemoveTextures() end
	if (LFDParentFrameEyeFrame) then 
		LFDParentFrameEyeFrame:RemoveTextures() 
	elseif (LFDParentFramePortrait) then
		LFDParentFramePortrait:RemoveTextures() 
	end
	LFDQueueFrameRoleButtonTankBackground:RemoveTextures()
	LFDQueueFrameRoleButtonHealerBackground:RemoveTextures()
	LFDQueueFrameRoleButtonDPSBackground:RemoveTextures()
	LFDQueueFrameSpecificListScrollFrame:RemoveTextures()
	
--	LFDQueueFrameRandomScrollFrame:SetUITemplate("backdrop")

	LFDQueueFrameFindGroupButton:SetUITemplate("button", true)
	LFDQueueFrameCancelButton:SetUITemplate("button", true)
	LFDQueueFramePartyBackfillBackfillButton:SetUITemplate("button", true)
	LFDQueueFramePartyBackfillNoBackfillButton:SetUITemplate("button", true)
	
	LFDQueueFrameRoleButtonTank.checkButton:SetUITemplate("checkbutton")
	LFDQueueFrameRoleButtonHealer.checkButton:SetUITemplate("checkbutton")
	LFDQueueFrameRoleButtonDPS.checkButton:SetUITemplate("checkbutton")
	LFDQueueFrameRoleButtonLeader.checkButton:SetUITemplate("checkbutton")

	if (LFDParentFrameCloseButton) then
		LFDParentFrameCloseButton:SetUITemplate("closebutton")
	else
		local brat
		for i = 1, LFDParentFrame:GetNumChildren() do
			brat = select(i, LFDParentFrame:GetChildren())
			local theBratIs,_,clingingTo,_,_ = brat:GetPoint()
			if (theBratIs == clingingTo) and (clingingTo == "TOPRIGHT") then
				brat:SetUITemplate("closebutton")
			end
		end
	end
	
	LFDQueueFrameTypeDropDown:SetUITemplate("dropdown", true, 220)
	
	LFDParentFrame:SetUITemplate("backdrop", nil, -2, -2, -2, 0)
	
	LFDQueueFrameSpecificListScrollFrameScrollBar:SetUITemplate("scrollbar")
	
	if (LFDQueueFrameCapBar) then
		LFDQueueFrameCapBar:SetPoint("TOP", 0, -50)
		LFDQueueFrameCapBar:SetHeight(14)
		LFDQueueFrameCapBarProgress:SetTexture(M["StatusBar"]["StatusBar"])
		LFDQueueFrameCapBarCap1:SetTexture(M["StatusBar"]["StatusBar"])
		LFDQueueFrameCapBarCap2:SetTexture(M["StatusBar"]["StatusBar"])
		LFDQueueFrameCapBarLabel:SetPoint("BOTTOM", LFDQueueFrameCapBar, "TOP", 0, 4)
		LFDQueueFrameCapBarLabel:SetFontObject(GUIS_SystemFontNormal)
		LFDQueueFrameCapBarText:SetFontObject(GUIS_NumberFontNormal)
		LFDQueueFrameCapBarText:ClearAllPoints()
		LFDQueueFrameCapBarText:SetPoint("CENTER")
		LFDQueueFrameCapBarCap1Marker:RemoveTextures()
		LFDQueueFrameCapBarCap2Marker:RemoveTextures()
		LFDQueueFrameCapBar.backdrop = LFDQueueFrameCapBar:SetUITemplate("backdrop")
		LFDQueueFrameCapBar.eyeCandy = CreateFrame("Frame", nil, LFDQueueFrameCapBar.backdrop)
		LFDQueueFrameCapBar.eyeCandy:SetPoint("TOPLEFT", LFDQueueFrameCapBar.backdrop, 3, -3)
		LFDQueueFrameCapBar.eyeCandy:SetPoint("BOTTOMRIGHT", LFDQueueFrameCapBar.backdrop, -3, 3)
		F.GlossAndShade(LFDQueueFrameCapBar.eyeCandy)
	end
	
	LFDQueueFrameTitleText:ClearAllPoints()
	LFDQueueFrameTitleText:SetPoint("TOP", LFDQueueFrame, "TOP", 0, -8)

	for i = 1, NUM_LFD_CHOICE_BUTTONS do
		_G["LFDQueueFrameSpecificListButton" .. i].enableButton:SetUITemplate("checkbutton")
	end	

	for i = 1, 20 do
		local button = _G["LFDQueueFrameSpecificListButton" .. i .. "ExpandOrCollapseButton"]

		if (button) then
			button:SetUITemplate("arrow")
		end
	end
	
	LFGSearchStatus:ClearAllPoints()
	LFGSearchStatus:SetPoint("TOP", Minimap, "BOTTOM", 0, -12)
	LFGSearchStatus:SetClampedToScreen(true)
	LFGSearchStatus:SetFrameStrata("TOOLTIP")
	LFGSearchStatus:SetFrameLevel(100)
	LFGSearchStatus:SetUITemplate("simplebackdrop")
	LFGSearchStatus:HookScript("OnShow", function(self) 
		self:SetFrameStrata("TOOLTIP")
	end)
	
	local updateQueueFrame = function()
		for i = 1, LFD_MAX_REWARDS do
			local button = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i]
			local icon = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."IconTexture"]
			local count = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."Count"]
			local role1 = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."RoleIcon1"]
			local role2 = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."RoleIcon2"]
			local role3 = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."RoleIcon3"]
			
			if (button) then
				icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
				icon:SetDrawLayer("OVERLAY")
				count:SetDrawLayer("OVERLAY")

				if not(button.backdrop) then
					button:RemoveTextures()

					button.backdrop = button:SetUITemplate("backdrop")
					button.backdrop:SetPoint("TOPLEFT", icon, "TOPLEFT", -3, 3)
					button.backdrop:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 3, -3)

					icon:SetPoint("TOPLEFT", 3, -3)
					icon.SetPoint = noop
					icon:SetParent(button.backdrop)
					
					if (count) then
						count:SetParent(button.backdrop)
					end
					
					if (role1) then
						role1:SetParent(button.backdrop)
					end
					
					if (role2) then
						role2:SetParent(button.backdrop)
					end
					
					if (role3) then
						role3:SetParent(button.backdrop)
					end							
				end
			end
		end
	end
	
	LFDQueueFrameRandom:HookScript("OnShow", updateQueueFrame)
	
end
