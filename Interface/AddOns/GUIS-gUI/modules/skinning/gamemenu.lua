--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningGameMenu")

-- Lua API
local _G = _G
local select, ipairs = select, ipairs

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end

local skinned = {}

-- skin a menu button
local Skin = function(button)
	if (skinned[button]) then
		return
	end

	button:SetHeight(button:GetHeight() + 4)
	button:SetUITemplate("button-indented", true)
	
	-- add the extra size of the button to the GameMenuFrame
	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 4)
	
	local text = button.text or button:GetName() and _G[button:GetName() .. "Text"]
	if (text) then
		text:SetFontObject(GUIS_SystemFontSmallWhite)
		button:SetNormalFontObject(GUIS_SystemFontSmallWhite)
	end
	
	skinned[button] = true
end

-- skin custom buttons
local skinExtra = function()
	local extraButtons = F.GetGameMenuButtons()
	for _,v in ipairs(extraButtons) do
		if (v) and not(skinned[v]) then
			Skin(v)
		end
	end
end

local skinAll = function()
	-- let's do this the smart way
	for i = 1, GameMenuFrame:GetNumChildren() do
		local child = select(i, GameMenuFrame:GetChildren())
		if (child.GetObjectType) and (child:GetObjectType() == "Button") and not(skinned[child]) then
			Skin(child)
		end
	end
end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UISkinning")) or not(GUIS_DB["skinning"][self:GetName()]) then 
		self:Kill() 
		return 
	end
end

-- putting the actual skinning this far down in the loading process 
-- to allow other addons to add their buttons, if any
local once
module.OnEnter = function(self)	
	if not(GameMenuFrame) then
		return
	end
	
	if (once) then
		return
	end
	
	-- make the frame pretty
	GameMenuFrame:RemoveTextures()
	GameMenuFrame:SetUITemplate("simplebackdrop")

	-- resize the frame, it's kind of big without it's default backdrop
	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() - 12) 
	
	-- move the header to where we want it, as the title is hooked to it
	GameMenuFrameHeader:SetPoint("TOP", GameMenuFrame, "TOP", 0, 8)
	
	-- find the title and style it
	for i = 1, GameMenuFrame:GetNumRegions() do
		r = select(i, GameMenuFrame:GetRegions())
		if (r:GetObjectType() == "FontString") and (r:GetText() == MAINMENU_BUTTON) then
			r:SetFontObject(GUIS_SystemFontLarge)
			break
		end
	end
	
	skinAll() -- skin all existing buttons
	
	hooksecurefunc(F, "AddGameMenuButton", skinExtra) -- hook the creation of new custom menu buttons
	
	once = true
end
