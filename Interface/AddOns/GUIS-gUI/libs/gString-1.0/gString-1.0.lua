--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local MAJOR, MINOR = "gString-1.0", 3
local gString, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not(gString) then return end 

-- Lua API
local type = type
local tinsert = tinsert
local unpack = unpack
local min, max = math.min, math.max
local format, gsub, strfind, strsub = string.format, string.gsub, string.find, string.sub

gString.TAGPOOL = gString.TAGPOOL or {}

local Split, RGBToHex, rgb, abbreviate, tag

gString.RegisterTag = function(self, tag, func)
	if type(tag) ~= "string" or type(func) ~= "function" or gString.TAGPOOL[tag] then return end
	
	gString.TAGPOOL[tag] = func
end

gString.UnregisterTag = function(self, tag)
	if type(tag) ~= "string" or not(gString.TAGPOOL[tag]) then return end
	
	gString.TAGPOOL[tag] = nil
end

-- our split function supports patterns
-- we used it for our tag function
Split = function(separator, str)
	if type(str) ~= "string" or type(separator) ~= "string" then return end

	local t = {}
	
	local pattern = "(.-)" .. separator
	local last_end = 1
	local s, e, cap = strfind(str, pattern, 1)
	
	while s do
		if s ~= 1 or cap ~= "" then
			tinsert(t, cap)
		end
		
		last_end = e + 1
		s, e, cap = strfind(str, pattern, last_end)
	end
	
	if last_end <= #str then
		cap = strsub(str, last_end)
		tinsert(t, cap)
	end
	
	return unpack(t)
end

RGBToHex = function(r, g, b, a)
	local rgb = function(n)
		return max(0,min(1,(n or 0)))
	end
	if a then
		return format("%02x%02x%02x%02x", rgb(a) * 255, rgb(r) * 255, rgb(g) * 255, rgb(b) * 255)
	else
		return format("%02x%02x%02x", rgb(r) * 255, rgb(g) * 255, rgb(b) * 255)
	end
end

rgb = function(str,r,g,b)
	if type(str) ~= "string" or str == "" then return "" end
	
	return "|cFF" .. RGBToHex(r,g,b) .. str .. "|r"
end

abbreviate = function(str)
	if not str or type(str) ~= "string" or strlen(str) == 0 then return end
	
	return (gsub(str, "[%l]", ""))
end

tag = function(str)
	if not str or type(str) ~= "string" then return end

	return (str:gsub("%[([^%]:]+):?(.-)%]", function(a, b) return 
		gString.TAGPOOL[a](Split("[,]+",b)) 
	end))
end

------------------------------------------------------------------------------------------------------------
-- 	API calls
------------------------------------------------------------------------------------------------------------
_G.RGBToHex 		= RGBToHex

string.abbreviate 	= abbreviate
string.rgb 			= rgb
string.tag 			= tag

_G.strabbr 			= string.abbreviate
_G.strrgb 			= string.rgb
_G.strtag 			= string.tag

