--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: StatusScore")

-- lua API

-- WoW API
local CreateFrame = CreateFrame

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local RegisterBucketEvent = function(...) return module:RegisterBucketEvent(...) end

local Horde, Alliance
local PostUpdateWorldState
local position

Horde = {
	[ [[Interface\TargetingFrame\UI-PVP-Horde]] ] = true;
	[ M["Icon"]["WorldState Horde"] ] = true;
}

Alliance = {
	[ [[Interface\TargetingFrame\UI-PVP-Alliance]] ] = true;
	[ M["Icon"]["WorldState Alliance"] ] = true;
}

position = function(frame, default)
	local text = _G[frame:GetName() .. "Text"]
	local icon = _G[frame:GetName() .. "Icon"]
--	do return end
	
	local indent = 3
	local w, h = 24, 24
	local origW, origH = 42, 42

	if (default) then
		icon:SetSize(origW, origH)
		icon:ClearAllPoints()
		icon:SetPoint("LEFT", frame, "LEFT", -6, 0)
		text:ClearAllPoints()
		text:SetPoint("LEFT", icon, "RIGHT", -12, 10)
	else
		-- the weird coordinates are there because I wish the process to calculate them to be visible
		-- so that I can easily re-align them or change them in the future
		icon:SetSize(w, h) 
		icon:ClearAllPoints()
		icon:SetPoint("LEFT", frame, "LEFT", -6 + (indent), ((origH-h)/2))
		text:ClearAllPoints()
		text:SetPoint("LEFT", icon, "RIGHT", -12 + ((origW-w)-indent), 10 - (origH-h)/2)
	end

	-- don't think this is strictly needed, but we'll do it anyway
	frame:SetSize(45, 24)
end

PostUpdateWorldState = function()
	for i = 1, NUM_ALWAYS_UP_UI_FRAMES do
		local frame = _G["AlwaysUpFrame" .. i]
		local text = _G["AlwaysUpFrame" .. i .. "Text"]
		local icon = _G["AlwaysUpFrame" .. i .. "Icon"] -- Horde/Alliance icons
		local dynamicIcon = _G["AlwaysUpFrame" .. i .. "DynamicIconButtonIcon"] -- flag icons

		local texture = icon:GetTexture()
		if (texture) then
			if (Alliance[texture]) then
				icon:SetTexture(M["Icon"]["FactionAlliance32"])
				position(frame)
				
			elseif (Horde[texture]) then
				icon:SetTexture(M["Icon"]["FactionHorde32"])
				position(frame)
				
			else
				position(frame, true)
			end
		else
			position(frame, true)
		end
		
		if (text:GetFontObject() ~= GUIS_SystemFontSmall) then
			text:SetFontObject(GUIS_SystemFontSmall)
		end
	end
end

module.OnInit = function(self)
	if F.kill("GUIS-gUI: Status") then 
		self:Kill() 
		return 
	end
	
	hooksecurefunc("WorldStateAlwaysUpFrame_Update", PostUpdateWorldState)
	RegisterCallback("PLAYER_ENTERING_WORLD", PostUpdateWorldState)
end
