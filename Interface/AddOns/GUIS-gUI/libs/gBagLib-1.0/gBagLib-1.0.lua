--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local MAJOR, MINOR = "gBagLib-1.0", 1
local gBagLib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not(gBagLib) then return end 

--assert(LibStub("gFrameHandler-1.0"), MAJOR .. " couldn't find an instance of gFrameHandler-1.0")

-