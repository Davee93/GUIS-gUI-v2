--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningWatchFrame")

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

	WatchFrameCollapseExpandButton:SetUITemplate("arrow", "down")
	
	do
		local normal = WatchFrameCollapseExpandButton:GetNormalTexture()
		local pushed = WatchFrameCollapseExpandButton:GetPushedTexture()
		
		normal:SetTexCoord(0, 1, 0, 1)
		pushed:SetTexCoord(0, 1, 0, 1)
		
		normal.SetTexCoord = noop
		pushed.SetTexCoord = noop
	end
	
	local numItems = 0
	local styleWatchFrameItems = function(lineFrame, nextAnchor, maxHeight, frameWidth)
		for i = 1, WATCHFRAME_NUM_ITEMS do
			local item = _G["WatchFrameItem" .. i]
	
			if (item) then
				F.StyleActionButton(item)
			end
		end
		
		numItems = WATCHFRAME_NUM_ITEMS
	end
	styleWatchFrameItems()

	hooksecurefunc("WatchFrame_DisplayTrackedQuests", styleWatchFrameItems)
	hooksecurefunc("WatchFrameItem_OnShow", styleWatchFrameItems)

	RegisterCallback("QUEST_LOG_UPDATE", styleWatchFrameItems)
end
