--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningStaticPopUps")

-- Lua API
local _G = _G
local pairs = pairs

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
	
	for i = 1,4 do
		_G["StaticPopup" .. i]:SetUITemplate("simplebackdrop")
		_G["StaticPopup" .. i .. "CloseButton"]:SetUITemplate("closebutton", true)

		_G["StaticPopup" .. i .. "EditBox"]:SetUITemplate("editbox", -3, 0, 3, 0):SetBackdropColor(r, g, b, panelAlpha)
		_G["StaticPopup" .. i .. "MoneyInputFrameGold"]:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		_G["StaticPopup" .. i .. "MoneyInputFrameSilver"]:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		_G["StaticPopup" .. i .. "MoneyInputFrameCopper"]:SetUITemplate("editbox"):SetBackdropColor(r, g, b, panelAlpha)
		
		F.StyleActionButton(_G["StaticPopup" .. i .. "ItemFrame"])
		_G["StaticPopup" .. i .. "ItemFrameNameFrame"]:SetSize(1/1e4, 1/1e4)

		for j = 1,3 do
			_G["StaticPopup" .. i .. "Button" .. j]:SetUITemplate("button")
		end
	end
	
end
