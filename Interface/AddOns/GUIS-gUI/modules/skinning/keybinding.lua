--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningKeyBinding")

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
		KeyBindingFrame:RemoveTextures()
	
		KeyBindingFrame:SetUITemplate("backdrop", nil, -4, 0, 0, 42)
		KeyBindingFrameCancelButton:SetUITemplate("button", true)
		KeyBindingFrameDefaultButton:SetUITemplate("button", true)
		KeyBindingFrameOkayButton:SetUITemplate("button", true)
		KeyBindingFrameUnbindButton:SetUITemplate("button", true)
		KeyBindingFrameCharacterButton:SetUITemplate("checkbutton")
		KeyBindingFrameScrollFrameScrollBar:SetUITemplate("scrollbar")
		
		for i = 1, KEY_BINDINGS_DISPLAYED  do
			_G["KeyBindingFrameBinding" .. i .. "Key1Button"]:SetUITemplate("button", true)
			_G["KeyBindingFrameBinding" .. i .. "Key2Button"]:SetUITemplate("button", true)
		end

		KeyBindingFrameHeaderText:ClearAllPoints()
		KeyBindingFrameHeaderText:SetPoint("TOP", KeyBindingFrame, "TOP", 0, 0)
	end
	F.SkinAddOn("Blizzard_BindingUI", SkinFunc)
end
