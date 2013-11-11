--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningTransmogrification")

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
	
	-- feature added in WoW Client Patch 4.3
	if not(F.IsBuild(4,3,0)) then
		return
	end
	
	local slots = {
		"Head";
		"Shoulder";
		"Back";
		"Chest";
		"Wrist";
		"Hands";
		"Waist";
		"Legs";
		"Feet";
		"MainHand";
		"SecondaryHand";
	}
	
	local SkinFunc = function()
		TransmogrifyFrame:RemoveTextures()
		TransmogrifyArtFrame:RemoveTextures()
		TransmogrifyFrameButtonFrame:RemoveTextures()
		TransmogrifyMoneyFrame:RemoveTextures()
	
		TransmogrifyApplyButton:SetUITemplate("button", true)
		TransmogrifyArtFrameCloseButton:SetUITemplate("closebutton", "TOPRIGHT", -4, -4)

		TransmogrifyFrame:SetUITemplate("backdrop", nil, 0, 0, 0, 0)
		TransmogrifyModelFrame:SetUITemplate("backdrop", nil, 0, 0, 0, 0)
		
		for i,v in pairs(slots) do
			local button = _G["TransmogrifyFrame" .. v .. "Slot"]
			local grabber =  _G[button:GetName() .. "Grabber"]
			
			grabber:RemoveTextures()
			F.StyleActionButton(button)
		end
		
	end
	F.SkinAddOn("Blizzard_ItemAlterationUI", SkinFunc)
end
