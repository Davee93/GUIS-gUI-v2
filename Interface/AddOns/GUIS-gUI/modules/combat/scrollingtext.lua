--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: CombatScrollingText")

-- Lua API

-- WoW API 

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local UnregisterCallback = function(...) return module:UnregisterCallback(...) end

local updateAll

local settings = {
}

updateAll = function()
end
module.UpdateAll = updateAll

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: Combat")) then 
		self:Kill() 
		return 
	end
end

