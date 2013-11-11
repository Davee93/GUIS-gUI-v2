--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local MAJOR, MINOR = "gTimerLib-1.0", 2
local gTimerLib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not(gTimerLib) then return end 

do
	local libList = { "gCore-3.0", "gFrameHandler-1.0", "gString-1.0", "gMedia-3.0", "gPanel-2.0" }

	for _,v in pairs(libList) do 
		assert(LibStub(v), MAJOR .. " couldn't find an instance of " .. v) 
	end

	libList = nil
end

-- Lua APIs
local _G = _G
local setmetatable = setmetatable
local pairs, unpack = pairs, unpack

local CreateFinishEffect

--
-- credits to Haste
--
-- ArgCheck(value, num[, nobreak], ...)
-- 	@param value <any> the argument to check
-- 	@param num <number> the number of the argument in your function 
-- 	@param nobreak <boolean> optional. if true, then a non-breaking error will fired instead
-- 	@param ... <string> list of argument types
local ArgCheck = function(value, num, ...)
	assert(type(num) == "number", "Bad argument #2 to 'ArgCheck' (number expected, got " .. type(num) .. ")")
	
	local nobreak
	for i = 1, select("#", ...) do
		if (i == 1) and (select(i, ...) == true) then
			nobreak = true
		else
			if (type(value) == select(i, ...)) then return end
		end
	end

	local types = strjoin(", ", ...)
	local name = strmatch(debugstack(2, 2, 0), ": in function [`<](.-)['>]")
	
	if (nobreak) then
		geterrorhandler()(("Bad argument #%d to '%s' (%s expected, got %s"):format(num, name, types, type(value)), 3)
	else
		error(("Bad argument #%d to '%s' (%s expected, got %s"):format(num, name, types, type(value)), 3)
	end
end


CreateFinishEffect = function(timer, effect)
end



gTimerLib.CreateTimerBar = function(self, max, min, current)
	ArgCheck(max, 1, "number")
	ArgCheck(max, 2, "number")
	ArgCheck(max, 3, "number")
end

gTimerLib.CreateTimerSpiral = function(self, max, min, current)
	ArgCheck(max, 1, "number")
	ArgCheck(max, 2, "number")
	ArgCheck(max, 3, "number")
end

