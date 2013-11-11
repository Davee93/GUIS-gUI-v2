--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningRaidFinder")

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

	-- feature added in WoW Client Patch 4.3
	if not(F.IsBuild(4,3,0)) then
		return
	end
	
	local panelAlpha, r, g, b = 1/5, unpack(C["overlay"])
	
	RaidFinderFrame:RemoveTextures()
	RaidParentFrame:RemoveTextures()
	RaidParentFrameInset:RemoveTextures()
	RaidFinderFrameRoleInset:RemoveTextures()
	RaidFinderQueueFrame:RemoveTextures()
	
	RaidFinderFrameFindRaidButton:SetUITemplate("button", true)
	RaidFinderFrameCancelButton:SetUITemplate("button", true)
	RaidFinderQueueFrameRoleButtonTank.checkButton:SetUITemplate("checkbutton")
	RaidFinderQueueFrameRoleButtonHealer.checkButton:SetUITemplate("checkbutton")
	RaidFinderQueueFrameRoleButtonDPS.checkButton:SetUITemplate("checkbutton")
	RaidFinderQueueFrameRoleButtonLeader.checkButton:SetUITemplate("checkbutton")
	RaidFinderQueueFrameSelectionDropDown:SetUITemplate("dropdown", true)

	RaidParentFrameCloseButton:SetUITemplate("closebutton", "TOPRIGHT", RaidFinderFrame, "TOPRIGHT", -4, -4)
	
	RaidParentFrame:SetUITemplate("simplebackdrop")
	
	RaidParentFrameTab1:SetUITemplate("tab", true)
	RaidParentFrameTab2:SetUITemplate("tab", true)
	RaidParentFrameTab3:SetUITemplate("tab", true)
	
	for i = 1, 2 do
		local button = _G["LFRParentFrameSideTab" .. i]
		local icon = button:GetNormalTexture()
		local iconTexture = icon:GetTexture()
		
		button:RemoveTextures()
		button:SetUITemplate("simplebackdrop")

		icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", 3, -3)
		icon:SetPoint("BOTTOMRIGHT", -3, 3)
		icon:SetTexture(iconTexture)
		
		button:CreateHighlight()
		button:CreateChecked()

		button:GetHighlightTexture():SetAllPoints(icon)
		button:GetCheckedTexture():SetAllPoints(icon)
	end

	LFRParentFrameSideTab1:ClearAllPoints()
	LFRParentFrameSideTab1:SetPoint("TOPLEFT", LFRParentFrame, "TOPRIGHT", 2, -66)
	LFRParentFrameSideTab1.SetPoint = noop
	
	LFRParentFrameSideTab2:ClearAllPoints()
	LFRParentFrameSideTab2:SetPoint("TOP", LFRParentFrameSideTab1, "BOTTOM", 0, -4)
	LFRParentFrameSideTab2.SetPoint = noop

	local updateQueueFrame = function()
		for i = 1, LFD_MAX_REWARDS do
			local button = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i]
			local icon = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."IconTexture"]
			local count = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."Count"]
			local role1 = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."RoleIcon1"]
			local role2 = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."RoleIcon2"]
			local role3 = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..i.."RoleIcon3"]
			
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
	
--	hooksecurefunc("RaidFinderQueueFrameRewards_UpdateFrame", updateQueueFrame)
	RaidFinderQueueFrame:HookScript("OnShow", updateQueueFrame)
	
end
