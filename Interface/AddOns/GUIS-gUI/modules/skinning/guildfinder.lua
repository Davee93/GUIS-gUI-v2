--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningGuildFinder")

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

	local SkinFunc = function()
		local panelAlpha, r, g, b = 1/5, unpack(C["overlay"])
		
		LookingForGuildFrame:RemoveTextures()
		LookingForGuildFrameInset:RemoveTextures()
		LookingForGuildBrowseButton_LeftSeparator:RemoveTextures()
		LookingForGuildRequestButton_RightSeparator:RemoveTextures()
		GuildFinderRequestMembershipFrameInputFrame:RemoveTextures()
		GuildFinderRequestMembershipFrame:RemoveTextures()

		LookingForGuildFrameTab1:RemoveTextures()
		LookingForGuildFrameTab2:RemoveTextures()
		LookingForGuildFrameTab3:RemoveTextures()
		
		LookingForGuildBrowseButton:SetUITemplate("button")
		LookingForGuildRequestButton:SetUITemplate("button")
		GuildFinderRequestMembershipFrameAcceptButton:SetUITemplate("button")
		GuildFinderRequestMembershipFrameCancelButton:SetUITemplate("button")
		
		LookingForGuildQuestButton:SetUITemplate("checkbutton")
		LookingForGuildDungeonButton:SetUITemplate("checkbutton")
		LookingForGuildRaidButton:SetUITemplate("checkbutton")
		LookingForGuildRPButton:SetUITemplate("checkbutton")
		LookingForGuildPvPButton:SetUITemplate("checkbutton")
		LookingForGuildWeekdaysButton:SetUITemplate("checkbutton")
		LookingForGuildWeekendsButton:SetUITemplate("checkbutton")
		LookingForGuildTankButton.checkButton:SetUITemplate("checkbutton")
		LookingForGuildHealerButton.checkButton:SetUITemplate("checkbutton")
		LookingForGuildDamagerButton.checkButton:SetUITemplate("checkbutton")
		
		LookingForGuildFrameCloseButton:SetUITemplate("closebutton")
		
		LookingForGuildFrame:SetUITemplate("backdrop", nil, -3, 0, 0, 0)
		LookingForGuildAvailabilityFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		LookingForGuildInterestFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		LookingForGuildRolesFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		LookingForGuildCommentFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		LookingForGuildAppsFrame:SetUITemplate("backdrop", nil, 4, 4, 2, 23):SetBackdropColor(r, g, b, panelAlpha)
		LookingForGuildBrowseFrame:SetUITemplate("backdrop", nil, 4, 4, 2, 23):SetBackdropColor(r, g, b, panelAlpha)
		LookingForGuildCommentInputFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		GuildFinderRequestMembershipFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		GuildFinderRequestMembershipFrameInputFrame:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
		
		LookingForGuildAppsFrameContainerScrollBar:SetUITemplate("scrollbar")
		LookingForGuildBrowseFrameContainerScrollBar:SetUITemplate("scrollbar")
		
		local makeHighlight = function(name, i, addSelectTexture)
			local button = _G[name .. i]
			
			button:SetBackdrop(nil)
			button.SetBackdrop = noop
			
			button:CreateHighlight()
			button:CreatePushed()

			-- can it get any worse?
			local selected = button:GetRegions()
			if (addSelectTexture) and  (selected) and (selected.GetObjectType) and (selected:GetObjectType() == "Texture") then
				selected:SetTexture(C["value"][1], C["value"][2], C["value"][3], 1/4)
			end
			
		end
		
		for i = 1, 5 do
			makeHighlight("LookingForGuildBrowseFrameContainerButton", i, true)
			makeHighlight("LookingForGuildAppsFrameContainerButton", i)
		end
		
	end
	F.SkinAddOn("Blizzard_LookingForGuildUI", SkinFunc)

end
