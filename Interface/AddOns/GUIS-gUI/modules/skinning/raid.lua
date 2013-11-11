--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningRaid")

-- Lua API
local pairs, select, unpack = pairs, select, unpack

-- WoW API
local GetNumRaidMembers = GetNumGroupMembers or GetNumRaidMembers

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
	
	RaidInfoFrame:RemoveTextures()
	RaidInfoIDLabel:RemoveTextures()
	RaidInfoInstanceLabel:RemoveTextures()
	RaidInfoScrollFrame:RemoveTextures()

	RaidFrameConvertToRaidButton:SetUITemplate("button", true)
	
	if (RaidFrameNotInRaidRaidBrowserButton) then RaidFrameNotInRaidRaidBrowserButton:SetUITemplate("button", true) end
	if (RaidFrameRaidBrowserButton) then RaidFrameRaidBrowserButton:SetUITemplate("button", true) end
	
	RaidFrameRaidInfoButton:SetUITemplate("button", true)
	RaidInfoCancelButton:SetUITemplate("button", true)
	RaidInfoExtendButton:SetUITemplate("button", true)
	RaidInfoCloseButton:SetUITemplate("closebutton")
	RaidInfoFrame:SetUITemplate("backdrop")
	RaidInfoScrollFrameScrollBar:SetUITemplate("scrollbar")

	local SkinFunc = function()
		if (F.IsBuild(4,3,0)) then
			RaidFrameAllAssistCheckButton:SetUITemplate("checkbutton")
		end

		RaidGroup1:RemoveTextures()
		RaidGroup2:RemoveTextures()
		RaidGroup3:RemoveTextures()
		RaidGroup4:RemoveTextures()
		RaidGroup5:RemoveTextures()
		RaidGroup6:RemoveTextures()
		RaidGroup7:RemoveTextures()
		RaidGroup8:RemoveTextures()
	
		RaidFrameRaidInfoButton:SetUITemplate("button", true)
		RaidFrameReadyCheckButton:SetUITemplate("button", true)
		
		for group = 1,8 do
			for member = 1,5 do
				_G["RaidGroup" .. group .."Slot" .. member]:RemoveTextures()
				_G["RaidGroup" .. group .."Slot" .. member]:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
			end
		end

		local raid = {}
		local UpdateRaid = function()
			for member = 1, GetNumRaidMembers() do
				local button = _G["RaidGroupButton" .. member]
				if not(raid[button]) then
					button:RemoveTextures()
					button:SetUITemplate("simplebackdrop")
					button:CreateHighlight()
					raid[button] = true
				end
			end
		end

		UpdateRaid()
		
		RaidFrame:HookScript("OnShow", UpdateRaid)
		hooksecurefunc("RaidGroupFrame_OnEvent", UpdateRaid)
		
		RegisterCallback("PARTY_MEMBERS_CHANGED", UpdateRaid)
		RegisterCallback("RAID_ROSTER_UPDATE", UpdateRaid)

	end
	F.SkinAddOn("Blizzard_RaidUI", SkinFunc)
end
