--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local MAJOR, MINOR = "gDB-1.0", 2
local gDB, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not gDB then return end 

gDB.db = gDB.db or {}

function gDB:NewDataBase(name)
	if type(name) ~= "string" then 
		geterrorhandler()((MAJOR .. ": NewDataBase(name) 'name' - string expected, got %s"):format(type(name)), 2)
		return 
	end
	
	if gDB.db[name] then
		geterrorhandler()((MAJOR .. ": NewDataBase(name): 'name' - a database named '%s' already exists"):format(name), 2)
		return
	end

	gDB.db[name] = {}
	
	return gDB.db[name]
end

function gDB:GetDataBase(name)
	if type(name) ~= "string" then 
		geterrorhandler()((MAJOR .. ": GetDataBase(name) 'name' - string expected, got %s"):format(type(name)), 2)
		return 
	end
	
	if not gDB.db[name] then
		geterrorhandler()((MAJOR .. ": GetDataBase(name): 'name' - cannot find a database named '%s'"):format(name), 2)
		return
	end
	
	return gDB.db[name]
end

function gDB:DeleteDataBase(name)
	if type(name) ~= "string" then 
		geterrorhandler()((MAJOR .. ": DeleteDataBase(name) 'name' - string expected, got %s"):format(type(name)), 2)
		return 
	end
	
	if not gDB.db[name] then
		geterrorhandler()((MAJOR .. ": DeleteDataBase(name): 'name' - cannot find a database named '%s'"):format(name), 2)
		return
	end
	
	gDB.db[name] = nil
end

function gDB:ClearDataBase(name)
	if type(name) ~= "string" then 
		geterrorhandler()((MAJOR .. ": ClearDataBase(name) 'name' - string expected, got %s"):format(type(name)), 2)
		return 
	end
	
	if not gDB.db[name] then
		geterrorhandler()((MAJOR .. ": ClearDataBase(name): 'name' - cannot find a database named '%s'"):format(name), 2)
		return
	end
	
	wipe(gDB.db[name])
end

--[[
local mixins = {
	"NewDataBase", "DeleteDataBase",
	"GetDataBase", "ClearDataBase"
} 

function gDB:Embed( target )
	for _, v in pairs( mixins ) do
		target[v] = self[v]
	end
	return target
end
]]--
