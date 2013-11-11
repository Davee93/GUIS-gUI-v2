--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningRaidBrowser")

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
	
	local panelAlpha, r, g, b = 1/5, unpack(C["overlay"])

	LFRBrowseFrame:RemoveTextures()
	LFRParentFrame:RemoveTextures()
	LFRQueueFrame:RemoveTextures()
	LFRQueueFrameRoleButtonTankBackground:RemoveTextures()
	LFRQueueFrameRoleButtonHealerBackground:RemoveTextures()
	LFRQueueFrameRoleButtonDPSBackground:RemoveTextures()
	
	if (F.IsBuild(4,3,0)) then
		LFRQueueFrameRoleInset:RemoveTextures()
		LFRQueueFrameListInset:RemoveTextures()
		LFRQueueFrameCommentInset:RemoveTextures()
	end
	
	LFRBrowseFrameColumnHeader1:RemoveClutter()
	LFRBrowseFrameColumnHeader2:RemoveClutter()
	LFRBrowseFrameColumnHeader3:RemoveClutter()
	LFRBrowseFrameColumnHeader4:RemoveClutter()
	LFRBrowseFrameColumnHeader5:RemoveClutter()
	LFRBrowseFrameColumnHeader6:RemoveClutter()
	LFRBrowseFrameColumnHeader7:RemoveClutter()

	LFRQueueFrameAcceptCommentButton:SetUITemplate("button", true)
	LFRQueueFrameFindGroupButton:SetUITemplate("button", true)
	LFRBrowseFrameInviteButton:SetUITemplate("button", true)
	LFRBrowseFrameRefreshButton:SetUITemplate("button", true)
	LFRBrowseFrameSendMessageButton:SetUITemplate("button", true)
	
	LFRQueueFrameRoleButtonTank.checkButton:SetUITemplate("checkbutton")
	LFRQueueFrameRoleButtonHealer.checkButton:SetUITemplate("checkbutton")
	LFRQueueFrameRoleButtonDPS.checkButton:SetUITemplate("checkbutton")

	LFRBrowseFrameRaidDropDown:SetUITemplate("dropdown", true)
	
	if not(F.IsBuild(4,3,0)) then
		LFRParentFrame:SetUITemplate("backdrop", nil, 8, 10, 4, 0)
		LFRParentFrameTab1:SetUITemplate("tab")
		LFRParentFrameTab2:SetUITemplate("tab")
	end
	
	LFRQueueFrameCommentTextButton:SetUITemplate("backdrop", nil, -4, -8, 4, -2):SetBackdropColor(r, g, b, panelAlpha)

	for i = 1, LFRParentFrame:GetNumChildren() do
		local child = select(i, LFRParentFrame:GetChildren())
		if (child.GetPushedTexture) and (child:GetPushedTexture()) and not(child:GetName()) then
			child:SetUITemplate("closebutton")
		end
	end

	for i = 1, NUM_LFR_CHOICE_BUTTONS do
		_G["LFRQueueFrameSpecificListButton" .. i]:RemoveTextures()
		_G["LFRQueueFrameSpecificListButton" .. i].enableButton:SetUITemplate("checkbutton")
	end	

	for i = 1, 20 do
		local button = _G["LFRQueueFrameSpecificListButton" .. i .. "ExpandOrCollapseButton"]

		if (button) then
			button:SetUITemplate("arrow")
		end
	end
	
end
