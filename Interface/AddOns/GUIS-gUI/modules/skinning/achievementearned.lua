--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningAchievementPopup")

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

	local makeMySkin = function(frame, iconName)
		local icon, texture
		if (iconName) then
			icon = _G[frame:GetName() .. iconName]
			icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			icon:ClearAllPoints()
			icon:SetPoint("LEFT", frame, 8, 0)

			texture = icon:GetTexture()
		end	
		
		frame:RemoveTextures()
	
		frame:SetAlpha(1)
		frame.SetAlpha = noop

		if not(frame.backdrop) then
			frame.backdrop = frame:SetUITemplate("backdrop")
			frame.backdrop:SetPoint("TOPLEFT", -3, -6)
			frame.backdrop:SetPoint("BOTTOMRIGHT", 3, 6)
		end

		if (iconName) then
			if not(icon.backdrop) then
				icon.backdrop = CreateFrame("Frame", frame:GetName() .. iconName .. "Backdrop", frame)
				icon.backdrop:SetUITemplate("simplebackdrop")
				icon.backdrop:ClearAllPoints()
				icon.backdrop:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
				icon.backdrop:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
			end
			
			icon:SetParent(icon.backdrop)
			
			if (texture) then
				icon:SetTexture(texture)
			end
		end
		
	end
	
	local updateAchievementEarned = function()
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["AchievementAlertFrame" .. i]
			
			if (frame) then
				makeMySkin(frame, "IconTexture")
				
				if _G[frame:GetName() .. "Background"] then _G[frame:GetName() .. "Background"]:RemoveTextures() end
				if _G[frame:GetName() .. "IconOverlay"] then _G[frame:GetName() .. "IconOverlay"]:RemoveTextures() end

				_G[frame:GetName() .. "Unlocked"]:SetTextColor(unpack(C["value"]))
				_G[frame:GetName() .. "Name"]:SetTextColor(unpack(C["index"]))
			end
		end
	end

	local updateDungeonCompleted = function()
		for i = 1, DUNGEON_COMPLETION_MAX_REWARDS do
			local frame = _G["DungeonCompletionAlertFrame" .. i]

			if (frame) then
				makeMySkin(frame, "DungeonTexture")
				
				for i = 1, frame:GetNumRegions() do
					local region = select(i, frame:GetRegions())
					if (region:GetObjectType() == "Texture") then
						if (region:GetTexture() == "Interface\\LFGFrame\\UI-LFG-DUNGEONTOAST") then
							region:Kill()
						end
					end
				end
				
			end
		end				
	end

	hooksecurefunc("AchievementAlertFrame_FixAnchors", updateAchievementEarned)
	hooksecurefunc("DungeonCompletionAlertFrame_FixAnchors", updateDungeonCompleted)
end
