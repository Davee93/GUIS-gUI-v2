--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningPetition")

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
	
	PetitionFrame:RemoveTextures()
	
	PetitionFrameCancelButton:SetUITemplate("button", true)
	PetitionFrameRenameButton:SetUITemplate("button", true)
	PetitionFrameRequestButton:SetUITemplate("button", true)
	PetitionFrameSignButton:SetUITemplate("button", true)
	PetitionFrameCloseButton:SetUITemplate("closebutton", "TOPRIGHT", -28, -18)
	PetitionFrame:SetUITemplate("backdrop", nil, 12, 8, 64, 24)
	
	PetitionFrameCharterName:SetTextColor(unpack(C["index"]))
	PetitionFrameCharterTitle:SetTextColor(unpack(C["value"]))
	PetitionFrameInstructions:SetTextColor(unpack(C["index"]))
	PetitionFrameMasterName:SetTextColor(unpack(C["index"]))
	PetitionFrameMemberName1:SetTextColor(unpack(C["index"]))
	PetitionFrameMemberName2:SetTextColor(unpack(C["index"]))
	PetitionFrameMemberName3:SetTextColor(unpack(C["index"]))
	PetitionFrameMemberName4:SetTextColor(unpack(C["index"]))
	PetitionFrameMemberName5:SetTextColor(unpack(C["index"]))
	PetitionFrameMemberName6:SetTextColor(unpack(C["index"]))
	PetitionFrameMemberName7:SetTextColor(unpack(C["index"]))
	PetitionFrameMemberName8:SetTextColor(unpack(C["index"]))
	PetitionFrameMemberName9:SetTextColor(unpack(C["index"]))
	PetitionFrameMasterTitle:SetTextColor(unpack(C["value"]))
	PetitionFrameMemberTitle:SetTextColor(unpack(C["value"]))
end
