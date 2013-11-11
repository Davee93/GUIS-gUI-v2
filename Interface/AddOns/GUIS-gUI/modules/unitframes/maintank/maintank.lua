--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local oUF = ns.oUF or oUF 

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UnitFramesMainTank")

-- Lua API
local setmetatable, rawget = setmetatable, rawget
local unpack, select, tinsert = unpack, select, table.insert

local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")

local Shared

local settings = {
	["frame"] = {
		pos 				= { "CENTER", "UIParent", "CENTER", 400, -120 };
		size 				= { 180, 16 };
		portraitsize 		= { 40, 40 };
		powerbarsize 		= 4;
		iconsize 			= 16;
	};

	["aura"] = {
		size 				= 20;
		gap 				= 4;
		height 				= 2;
		width 				= 6;
	};
}	

local iconList = {
	["default"] = "[guis:quest]";
}
setmetatable(iconList, { __index = function(t, i) return rawget(t, i) or rawget(t, "default") end })

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UnitFrames")) or (not GUIS_DB["unitframes"]["loadmaintankframes"]) then 
		self:Kill()
		return 
	end
end

module.OnEnable = function(self)
end
