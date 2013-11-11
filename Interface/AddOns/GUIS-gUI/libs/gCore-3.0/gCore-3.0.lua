--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local MAJOR, MINOR = "gCore-3.0", 60
local gCore, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not(gCore) then return end 

-- Lua API
local _G = _G
local assert = assert
local pcall = pcall
local strjoin, strmatch = string.join, string.match
local tinsert, tremove = table.insert, table.remove
local ipairs, pairs, select = ipairs, pairs, select
local tostring = tostring
local type = type

-- WoW API
local CreateFrame = CreateFrame
local GetAddOnMetadata = GetAddOnMetadata
local SetCVar = SetCVar
local geterrorhandler = geterrorhandler

gCore._BUCKETFRAME = gCore._BUCKETFRAME or CreateFrame("Frame", "gCore30BucketFrame", UIParent)
gCore._CALLBACKFRAME = gCore._CALLBACKFRAME or CreateFrame("Frame", "gCore30CallbackFrame", UIParent)
gCore._FRAME = gCore._FRAME or CreateFrame("Frame", "gCore30EventFrame", UIParent)

--gCore._ADDON = gCore._ADDON or {}
gCore._ADDONLOADED = gCore._ADDONLOADED or nil
gCore._ADDONS = gCore._ADDONS or {}

gCore._MODULE = gCore._MODULE or {}
gCore._MODULES = gCore._MODULES or {}

gCore._BUCKETS = gCore._BUCKETS or {}
gCore._BUCKETSCHEDULE = gCore._BUCKETSCHEDULE or {}
gCore._BUCKETTIMER = gCore._BUCKETTIMER or {}
gCore._CALLBACKS = gCore._CALLBACKS or {}
gCore._EVENTS = gCore._EVENTS or {}
gCore._EVENTSTATUS = gCore._EVENTSTATUS or {}
gCore._TASKS = gCore._TASKS or {}

gCore._SLASH = gCore._SLASH or {}

--local _ADDON = gCore._ADDON
local _ADDONS = gCore._ADDONS
local _BUCKETFRAME = gCore._BUCKETFRAME
local _BUCKETS = gCore._BUCKETS
local _BUCKETSCHEDULE = gCore._BUCKETSCHEDULE
local _BUCKETTIMER = gCore._BUCKETTIMER
local _CALLBACKFRAME = gCore._CALLBACKFRAME
local _CALLBACKS = gCore._CALLBACKS
local _EVENTS = gCore._EVENTS
local _EVENTSTATUS = gCore._EVENTSTATUS
local _FRAME = gCore._FRAME
local _MODULE = gCore._MODULE
local _MODULES = gCore._MODULES
local _SLASH = gCore._SLASH
local _TASKS = gCore._TASKS

local RegisterEvent = UIParent.RegisterEvent
local UnregisterEvent = UIParent.UnregisterEvent
local IsEventRegistered = UIParent.IsEventRegistered

local OnEvent, OnUpdate
local OnBucketEvent, OnBucketUpdate
local OnCallbackEvent

local SetCVars
local GetBinary, GetBoolean
local ValidateTable, CleanTable, DuplicateTable, Embed

--
-- we allow for custom events in our callbackhandler, 
-- but need a way to separate wow events and custom ones
local _EVENTCHECKER = CreateFrame("Frame")
_EVENTCHECKER:RegisterAllEvents()

local isEvent = function(event)
	return (_EVENTCHECKER:IsEventRegistered(event))
end

local _RESERVEDEVENTS = { 
	["ADDON_LOADED"] = true; 
	["PLAYER_LOGIN"] = true; 
	["PLAYER_LOGOUT"] = true;
	["PLAYER_ENTERING_WORLD"] = true;
}

for i,v in pairs(_RESERVEDEVENTS) do
	_EVENTSTATUS[i] = _EVENTSTATUS[i] or {}
end

-- no operation; might as well make it a global
local noop = function() return end
gCore.noop = noop
_G.noop = noop

-- local print function
local print = function(...)
	_G.print((GetAddOnMetadata(addon, "Title") or addon) .. " encountered an error:")

	for i = 1, select("#", ...) do
		_G.print("|cffff4400" .. (select(i, ...)) .. "|r")
	end
end

--
-- A little internal error handling mainly to prevent the module
-- from breaking from errors during the startup process
--	
-- We mainly use this for functions connected to reserved events
--
local safecall
do
	safecall = function(func, ...)
		-- just a little fail-safe to avoid breaking the fail-safe...
		if type(func) == "function" then
			local ret = { pcall(func, ...) }
			
			if (ret[1]) then 
				if (#ret > 1) then
					return select(2, ret)
				end
			else
				-- fire a non-breaking error to the client, 
				-- but continue execution as otherwise normal
				geterrorhandler()(ret[2], 2)
				
				local module = ...
				if (module) and (module.GetName) then
					print(("The module '%s' has caused a problem."):format(module:GetName()))
				end
				
				-- also print the error massage to the chat,
				-- mainly because I want people to report these errors!
				print(ret[2])
				
				-- shouldn't be any return values here, but you never know
				if (#ret > 2) then
					return select(3, ret)
				end
			end
		end
	end
end

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

--
-- count the number of keys in a table, the secure way
local countKeys = function(t)
	local count = 0
	for i,v in pairs(t) do
		if not(v == nil) then
			count = count + 1
		end
	end
	return count
end

------------------------------------------------------------------------------------------------------------
-- 	Main Event Frame
------------------------------------------------------------------------------------------------------------
for event, isReserved in pairs(_RESERVEDEVENTS) do
	if (isReserved) then 
		_FRAME:RegisterEvent(event)
	end
end

OnUpdate = function(self, elapsed)
	-- task scheduler
	local run, kill
	for moduleName, tasks in pairs(_TASKS) do
		for reference, task in pairs(tasks) do
			
			task.elapsed = (task.elapsed or 0) + elapsed
			
			run, kill = true, nil

			-- is there a maximum duration, and has it been exceded?
			if (task.duration) then
				task.total = (task.total or 0) + elapsed
				
				-- its been exceded, so cancel the run, and kill off the timer
				if (task.total > task.duration) then
					kill = true
					run = nil
				end
			end

			-- is there a delay before the initial run?
			if (task.delay) then
				if (task.delay > task.elapsed) then
					run = nil
				else
					task.delay = nil
				end
			end

			-- is this a repeating timer?
			if (task.interval) then
				if (task.elapsed >= task.interval) then
					--task.elapsed = task.elapsed - task.interval
					task.elapsed = task.elapsed % task.interval
				else
					run = nil
				end
			end

			-- shall it run, or was it a reason not to?
			if (run) then
				task.func(_MODULES[moduleName])

				-- if this isn't a repeating timer, we terminate it after this initial run
				if (not task.interval) then 
					kill = true
				end
			end
			
			-- the timer will die!
			if (kill) then
				-- run the finish function if it exists
				if (task.endFunc) then
					task.endFunc(_MODULES[moduleName])
				end
				
				_TASKS[moduleName][reference] = nil
			end
		end
	end
end

OnEvent = function(self, event, ...)
	if (_RESERVEDEVENTS[event]) then
		_FRAME[event](self, event, ...)
		return
	end
	
	if (_EVENTS[event]) then
		for module, func in pairs(_EVENTS[event]) do
			if (type(func) == "string") then
				if (_MODULES[module][event]) then
					_MODULES[module][event](_MODULES[module], ...)
				end
				
			elseif (type(func) == "function") then
				func(_MODULES[module], event, ...)
			end
		end
	end
end

_FRAME.ADDON_LOADED = function(self, event, name, ...)
	if (_FRAME._initializing) then
		return
	end
	
	_FRAME._initializing = true
	
	if (name == addon) then
		gCore._ADDONLOADED = true
	end
	
	-- calling the pre-initialization for ALL modules first
	for name, module in pairs(_MODULES) do
		if not(_EVENTSTATUS[event][module:GetName()]) then
			safecall(module.Init, module, ...)
		end
	end

	-- calling the initialization functions 
	for name, module in pairs(_MODULES) do
		if not(_EVENTSTATUS[event][module:GetName()]) then
			safecall(module.OnInit, module, ...)
		end
	end

	-- make sure the init procedures aren't called again
	for name, module in pairs(_MODULES) do
		if not(_EVENTSTATUS[event][module:GetName()]) then
			_EVENTSTATUS[event][module:GetName()] = true
		end
	end
	
	_FRAME._initializing = nil
end

_FRAME.PLAYER_LOGIN = function(self, event, ...)
	if (gCore._ADDONLOADED) then
		_FRAME:ADDON_LOADED("ADDON_LOADED", addon)
	end

	if (_FRAME._enabling) then
		return
	end
	
	_FRAME._enabling = true
	
	for name, module in pairs(_MODULES) do
		if not(_EVENTSTATUS[event][module:GetName()]) then
			safecall(module.OnEnable, module, ...)
		
			_EVENTSTATUS[event][module:GetName()] = true
		end
	end

	_FRAME._enabling = nil
end

_FRAME.PLAYER_LOGOUT = function(self, event, ...)
	for name, module in pairs(_MODULES) do
		safecall(module.OnDisable, module, ...)
	end
end

_FRAME.PLAYER_ENTERING_WORLD = function(self, event, ...)
	for name, module in pairs(_MODULES) do
		safecall(module.OnEnter, module, ...)
	end
end

_FRAME:SetScript("OnUpdate", OnUpdate)
_FRAME:SetScript("OnEvent", OnEvent)

------------------------------------------------------------------------------------------------------------
-- 	Template module
-- 	*Serves as a template for both addons and modules 
------------------------------------------------------------------------------------------------------------
--
-- called on ADDON_LOADED
-- use this to initialize values and settings ALL modules need
-- only your "master" module should use this
_MODULE.Init = noop

--
-- called directly after all Init() functions has been called
-- use this to initialize individual modules
_MODULE.OnInit = noop

--
-- called on PLAYER_LOGIN
_MODULE.Enable = noop

--
-- called directly after all Enable() functions has been called
-- use this to create frames and graphics
_MODULE.OnEnable = noop

--
-- called on PLAYER_ENTERING_WORLD
_MODULE.OnEnter = noop

--
-- called on PLAYER_LOGOUT
_MODULE.OnDisable = noop

--
-- local reference to no operation
_MODULE.noop = noop

-- 
-- RegisterEvent(event[, func])
-- @param event <string>
-- @param func <function>
_MODULE.RegisterEvent = function(self, event, func)
	ArgCheck(event, 1, "string")
	ArgCheck(func, 2, "function", "nil")

	if (_RESERVEDEVENTS[event]) then return end

	if (not _EVENTS[event]) then
		_EVENTS[event] = {}
		_FRAME:RegisterEvent(event)
	end
	
	_EVENTS[event][self:GetName()] = func or event
end

--
-- RegisterEvents([func,] ...)
-- @param func <function>
-- @param ... <string>, <string>, <string>, ...
_MODULE.RegisterEvents = function(self, func, ...)
	ArgCheck(func, 1, "string", "function")

	if (type(func) == "string") then
		self:RegisterEvent(func)
		func = nil
	end

--	for _,event in pairs({...}) do
	for i = 1, select("#", ...) do
		ArgCheck(reference, (func) and i + 1 or i, "string")
		self:RegisterEvent(event, func)
	end
end

--
-- @param event <string>
_MODULE.UnregisterEvent = function(self, event)
	if (type(event) ~= "string") or (event == "") then return end
	if (_RESERVEDEVENTS[event]) and (not dying) then return end
	
	local e = _EVENTS[event]
	
	if (e[self]) then
		e[self] = nil
	end
	
	if (#e == 0) then
		e = nil
		_FRAME:UnregisterEvent(event)
	end
end

--
-- unregisters ALL events for the given module
_MODULE.UnregisterAllEvents = function(self)
	for event, status in pairs(_RESERVEDEVENTS) do
		self:UnregisterEvent(event)
	end
	
	for event, modules in pairs(_EVENTS) do
		if (modules[self:GetName()]) then
			modules[self:GetName()] = nil
			self:UnregisterEvent(event)
		end
	end
end

--
-- Schedule a timer for your module
--
-- ScheduleTimer(func[, interval[, delay[, duration[, endFunc]]]])
-- @param func <function> the function to be called, the module will be passed as arg #1
-- @param interval <number> interval in seconds. if omitted, the timer will run only once
-- @param delay <number> delay in seconds before the timer starts, optional
-- @param duration <number> indicates how long the function will run in seconds. if omitted, will run until :CancelTimer() is used
-- @param endFunc <function> a function that will be run at the end of the timer's duration
-- @return <number> reference to the timer
_MODULE.ScheduleTimer = function(self, func, interval, delay, duration, endFunc)
	ArgCheck(func, 1, "function")
	ArgCheck(interval, 2, "number", "nil")
	ArgCheck(delay, 3, "number", "nil")
	ArgCheck(duration, 4, "number", "nil")
	ArgCheck(endFunc, 5, "function", "nil")
	
	local name = self:GetName()
	
	_TASKS[name] = _TASKS[name] or {}
	
	local reference = #_TASKS[name] + 1

	_TASKS[name][reference] = {
		func = func;
		endFunc = endFunc;
		interval = interval;
		delay = delay;
		duration = duration;
	}
	
	return reference
end

--
-- @param reference <number> reference to a scheduled timer
_MODULE.CancelTimer = function(self, reference)
	ArgCheck(reference, 1, "number")

	if (_TASKS[reference]) then
		_TASKS[reference] = nil
	end
end

--
-- @return <string> unique module name
_MODULE.GetName = function(self)
	return tostring(self.NAME) or "nil"
end

--
-- kill a module, unregister its events, cancel its timers, free up its memory
-- does not handle any embeds or child frames or objects
_MODULE.Kill = function(self)
	self.dying = true
	
	self:UnregisterAllEvents()
	
	local name = self:GetName()

	_TASKS[name] = nil
	_MODULES[name] = nil
	
	for i, v in pairs(self) do
		v = nil
	end

	self = nil
end

--
-- CreateChatCommand(func, commands)
-- @param func <function> 
-- @param commands <table> or <string>
_MODULE.CreateChatCommand = function(self, ...)
	gCore.CreateChatCommand(self, ...)
end

--
-- Simple hooking of functions for both secure and unsecure variables
-- There is no checks for previous hooks, so use with caution
-- Main purpose of this function is to simplify the hooking process, 
--  and keeping it to a secure environment whenever possible
-- 
-- Hook(object[, method], func)
-- @param object <string, frame> -- for secure hooks, this MUST be a string or a named frame
-- @param method <string> 
-- @param func <function> 
--
-- Hook(object, func)
-- @param object <string> 
-- @param func <function> 
_MODULE.Hook = function(self, object, method, func)
	--
	-- check to see where the function is
	if (not func) then
		func = method
		method = nil
	end
	
	ArgCheck(func, method and 3 or 2, "function")
	
	local realObject, isFrame, hasHandler, isSecure

	--
	-- Hook(object, method, func) -- hooksecurefunc
	-- @param object <string,table,frame>
	-- @param method <string>
	if (method) then 
		 
		ArgCheck(method, 2, "string", "nil")
		ArgCheck(object, 1, "string", "table")
		
		--
		-- do we have an objectname, or an object...?
		if (type(object) == "string") then
			if not _G[object] then
				error((MAJOR .. ": Hook(object, method, func) 'object' - no global object named '%s'"):format(object), 2)
				return
			else
				realObject = _G[object]
			end
		elseif type(object) == "table" then
			--
			-- since this is a table, it is most likely the real object
			realObject = object
			
			--
			-- remove the old object, it is not a string, which our functions depend on
			object = nil
			
			if realObject.IsObjectType and realObject:IsObjectType("Frame") then
				isFrame = true
				
				--
				-- if there is a name, put it into the object
				object = realObject:GetName()
			end
		end
		
		--
		-- is the 'method' in fact a script handler?
		hasHandler = realObject.HasScript and realObject:HasScript(method)
	else
		--
		-- Hook(object, func) -- hooksecurefunc
		-- @param object <string> -- name of function to hook
		ArgCheck(object, 1, "string")

		if (not _G[object]) then
			error((MAJOR .. ": Hook(object, func) 'object' - no global function object named '%s'"):format(object), 2)
			return
		else 
			-- since this is to be securely hooked with no 'method', the realObject must be a string
			realObject = object
		end
	end

	--
	-- is it a secure function, table or frame?
	-- this only works on objects entered as strings, or as frames with names
	isSecure = (select(1,(issecurevariable((type(object) == "string") and object or "")))) and (not hasHandler)
	
	--
	-- method is not a script handler, and a secure hook can be used
	if (isSecure) then
		if method then
			if not(realObject[method]) then
				error((MAJOR .. ": Hook(object[, method], func) 'method' - no method named '%s'"):format(method), 2)
				return 
			end
			hooksecurefunc(realObject, method, func)
		else
			hooksecurefunc(realObject, func)
		end
	--
	-- method is a script handler, an unsecure hook must be used
	else
		if isFrame then
			realObject:HookScript(method, func)
		end
	end
end

-- :ArgCheck(value, num[, nobreak], ...)
-- 	@param value <any> the argument to check
-- 	@param num <number> the number of the argument in your function 
-- 	@param nobreak <boolean> optional. if true, then a non-breaking error will fired instead
-- 	@param ... <string> list of argument types
_MODULE.ArgCheck = function(self, value, num, ...)
	ArgCheck(value, num, ...)
end

------------------------------------------------------------------------------------------------------------
-- 	Callback Handler 
------------------------------------------------------------------------------------------------------------
_CALLBACKFRAME.RegisterEvent = function(self, event)
	if (isEvent(event)) then
		RegisterEvent(self, event)
	else
		if not(self.customEvents) then
			self.customEvents = {}
		end
		
		self.customEvents[event] = true
	end
end

_CALLBACKFRAME.UnregisterEvent = function(self, event)
	if (isEvent(event)) then
		UnregisterEvent(self, event)
	else
		if not(self.customEvents) then
			return
		end
		
		self.customEvents[event] = nil
	end
end

_CALLBACKFRAME.UnregisterEvent = function(self, event)
	if (isEvent(event)) then
		return (self:IsEventRegistered(event))
	else
		return (self.customEvents) and (self.customEvents[event])
	end
end

--
-- Register a callback connected to an event
-- if given, func(self, event, ...) will be called, otherwise module[event](self, event, ...) will be called
--
-- RegisterCallback(event[, func])
-- @param event <string> 
-- @param func <function>
-- @return <number> reference to the callback
local callbackID = 0
local callbackReference = {}
_MODULE.RegisterCallback = function(self, event, func)
	ArgCheck(event, 1, "string")
	ArgCheck(func, 2, "function", "nil")

	_CALLBACKS[event] = _CALLBACKS[event] or {}
	_CALLBACKS[event][self:GetName()] = _CALLBACKS[event][self:GetName()] or {}

	local id = countKeys(_CALLBACKS[event][self:GetName()]) + 1
	
	_CALLBACKS[event][self:GetName()][id] = func or true

	_CALLBACKFRAME:RegisterEvent(event)
	
	callbackID = callbackID + 1
	callbackReference[callbackID] = { event, self:GetName(), id }
	
	return callbackID
end

--
-- @param id <string> event
-- @param id <number> callback reference
_MODULE.UnregisterCallback = function(self, id)
	ArgCheck(id, 1, "number", "string")

	if (id == "") then
		geterrorhandler()((MAJOR .. ": UnregisterCallback(id) 'id' - string can not be empty"):format(type(event)), 2)
		return 
	end

	local event, name, subID

	if (type(id) == "string") then
		event, name = id, self:GetName()
	end

	if (type(id) == "number") then
		if (callbackReference[id]) then
			event, name, subID = unpack(callbackReference[id])
		end
	end
	
	-- silently return if the entry doesn't exist
	if not(event) or not(name) or not(_CALLBACKS[event]) or not(_CALLBACKS[event][name]) then 
		return
	end
	
	if (subID) then
		_CALLBACKS[event][name][subID] = nil
		callbackReference[id] = nil
	else
		_CALLBACKS[event][name] = nil
		
		-- clear all stored callbackreferences matching the specified addon and event
		for cID,v in pairs(callbackReference) do
			if (v[1] == event) and (v[2] == name) then
				callbackReference[cID] = nil
			end
		end
	end
				
	if (countKeys(_CALLBACKS[event][name]) == 0) then
		_CALLBACKS[event][name] = nil
	end

	if (countKeys(_CALLBACKS[event]) == 0) then
		_CALLBACKS[event] = nil
	end
end

--
-- Unregisters ALL callbacks registered with the given module
_MODULE.UnregisterAllCallbacks = function(self)
	for event, modules in pairs(_CALLBACKS) do
		if _CALLBACKS[event][self:GetName()] then
			self:UnregisterCallback(event)
		end
	end
end

--
-- fire a callbackevent
-- callbacks are local to each module, but the modules are globally accessible
-- all custom events are also treated as global events
OnCallbackEvent = function(self, event, ...)
	local method
	if (_CALLBACKS[event]) then
		for moduleName, callbacks in pairs(_CALLBACKS[event]) do
			for reference, call in pairs(callbacks) do
				if type(call) == "function" then
					call(_MODULES[moduleName], event, ...)
				else
					if (call == true) then
						method = _MODULES[moduleName][event]
						if (method) then
							if (type(method) == "function") then
								method(_MODULES[moduleName], event, ...)
							else
								geterrorhandler()(MAJOR .. (": Missing function '%s' in the module named '%s'"):format(event, moduleName))
							end
						else
							geterrorhandler()(MAJOR .. (": Missing function '%s' in the module named '%s'"):format(event, moduleName))
						end
					end
				end
			end
		end
	end
end
_CALLBACKFRAME:SetScript("OnEvent", OnCallbackEvent)

--
-- Manually fire off a callbackevent
-- This allows for the use of custom events
-- This function is compatible with registered bucket events
--
-- @param ... <vararg> whatever arguments you wish to pass on
-- @return <boolean> true if an invalid id (as number) is given
_MODULE.FireCallback = function(self, id, ...)
	ArgCheck(id, 1, "number", "string")

	if (id == "") then
		geterrorhandler()((MAJOR .. ": FireCallback(id, ...) 'id' - string can not be empty"):format(type(event)), 2)
		return 
	end

	if (type(id) == "string") then
		OnCallbackEvent(self, id, ...)
		
		-- for custom events we need to notify the bucket handler
		if not(isEvent(id)) then
			OnBucketEvent(self, id, ...)
		end
	end

	if (type(id) == "number") then
		if not(callbackReference[id]) then
			return true
		end
		
		local event, name, subID = unpack(callbackReference[id])
		local callback = _CALLBACKS[event][name][subID]
		
		if (type(callback) == "function") then
			callback(_MODULES[name], event, ...)
		else
			if (callback == true) then
				if _MODULES[name][event] then
					if (type(_MODULES[name][event]) == "function") then
						_MODULES[name][event](_MODULES[name], event, ...)
					else
						geterrorhandler()(MAJOR .. (": Missing function '%s' in the module named '%s'"):format(event, name))
					end
				else
					geterrorhandler()(MAJOR .. (": Missing function '%s' in the module named '%s'"):format(event, name))
				end
			end
		end
	end
end

------------------------------------------------------------------------------------------------------------
-- 	Bucket Handler 
------------------------------------------------------------------------------------------------------------
_BUCKETFRAME.RegisterEvent = function(self, event)
	if (isEvent(event)) then
		RegisterEvent(self, event)
	else
		if not(self.customEvents) then
			self.customEvents = {}
		end
		
		self.customEvents[event] = true
	end
end

_BUCKETFRAME.UnregisterEvent = function(self, event)
	if (isEvent(event)) then
		UnregisterEvent(self, event)
	else
		if not(self.customEvents) then
			return
		end
		
		self.customEvents[event] = nil
	end
end

_BUCKETFRAME.UnregisterEvent = function(self, event)
	if (isEvent(event)) then
		return (self:IsEventRegistered(event))
	else
		return (self.customEvents) and (self.customEvents[event])
	end
end

local numBuckets = 0
local bucketReference = {}

--[[
	_BUCKETTIMER = {
		[bucketID] = remaining; -- remaining time until the next bucket can be fired
	}
	
	_BUCKETSCHEDULE = {
		[bucketID] = true; -- true if it should be run once after its timer runs out
	}

	_BUCKETS = {
		MyModule = {
			[event] = {
				[bucketID] = { 	-- automatically generated internal(but global) id, also returned to the user when registering
					callback = nil; -- user supplied function to call, or nil (MyModule[event] will be used instead, the first that is found)
					interval = 1;  -- minimum firing interval for buckets
				};
			};
		};
	}
]]--
OnBucketUpdate = function(self, elapsed)
	for moduleName, bucketEvents in pairs(_BUCKETS) do
		for bucketEvent, bucketList in pairs(bucketEvents) do
			for bucketID, bucket in pairs(bucketList) do
				if (_BUCKETTIMER[bucketID]) and (_BUCKETTIMER[bucketID] > 0) then
					_BUCKETTIMER[bucketID] = max(0, _BUCKETTIMER[bucketID] - elapsed)
					
					if (_BUCKETSCHEDULE[bucketID]) and (_BUCKETTIMER[bucketID] == 0) then
						bucketReference[bucketID].parent:FireBucketEvent(unpack(_BUCKETSCHEDULE[bucketID]))
						_BUCKETSCHEDULE[bucketID] = nil
					end
				end
			end
		end
	end
end
_BUCKETFRAME:SetScript("OnUpdate", OnBucketUpdate)

OnBucketEvent = function(self, event, ...)
	for moduleName, bucketEvents in pairs(_BUCKETS) do
		for bucketEvent, bucketList in pairs(bucketEvents) do
			if (bucketEvent == event) then
				for bucketID, bucket in pairs(bucketList) do
					local remaining = _BUCKETTIMER[bucketID]
					if not(remaining) or (remaining <= 0) then
						-- fire the callback
						if (bucket.callback) then
							-- reset interval timer
							_BUCKETTIMER[bucketID] = bucket.interval

							bucket.callback(_MODULES[moduleName], event, ...)
						else
							if _MODULES[moduleName][event] then
								if (type(_MODULES[moduleName][event]) == "function") then
									-- reset interval timer
									_BUCKETTIMER[bucketID] = bucket.interval

									_MODULES[moduleName][event](_MODULES[moduleName], event, ...)
								else
									geterrorhandler()(MAJOR .. (": Missing function '%s' in the module named '%s'"):format(event, moduleName))
								end
							else
								geterrorhandler()(MAJOR .. (": Missing function '%s' in the module named '%s'"):format(event, moduleName))
							end
						end
					elseif (remaining > 0) then
						_BUCKETSCHEDULE[bucketID] = { event, ... }
					end
				end
			end
		end
	end
end
_BUCKETFRAME:SetScript("OnEvent", OnBucketEvent)

--
-- register a bucket event; several events to act as one, with a minimum firing interval between them
--
-- RegisterBucketEvent(events[, interval[, callback]])
-- @param events <table/string> table of events, or just a single event. compatible with custom callback events
-- @param interval <number> minimum firing interval in seconds, defaults to 1, minimum is 0.1
-- @param @callback <function> the optional function to call
_MODULE.RegisterBucketEvent = function(self, events, interval, callback)
	ArgCheck(events, 1, "table", "string")
	ArgCheck(interval, 2, "number", "function", "nil")
	ArgCheck(callback, 2, "function", "nil")
	
	-- fix the input data
	if (type(interval) == "function") then
		callback = interval
		interval = 1
	end
	interval = max(interval, 0.1)
	
	local eventList
	if (type(events) == "string") then
		eventList = {}
		tinsert(eventList, events)
	else 
		eventList = events
	end
	
	-- create a new unique bucketID
	numBuckets = numBuckets + 1
	local bucketID = numBuckets
	local moduleName = self:GetName()
	
	-- initiate the bucket timer
	_BUCKETTIMER[bucketID] = 0
	
	-- make shortcuts to the callback function/eventname and burst interval
	bucketReference[bucketID] = {
		callback = callback or (type(events) == "table") and table[1] or (type(events) == "string") and events;
		interval = interval;
		parent = self;
	}
	
	for _,event in ipairs(eventList) do
		-- set up the bucket object
		_BUCKETS[moduleName] = _BUCKETS[moduleName] or {}
		_BUCKETS[moduleName][event] = _BUCKETS[moduleName][event] or {}
		_BUCKETS[moduleName][event][bucketID] = {
			interval = interval;
			callback = callback;
		}

		-- register the events with the bucket handler
		if (type(event == "string")) then
			_BUCKETFRAME:RegisterEvent(event)
		else 
			for i,bucketEvent in pairs(event) do
				if (type(bucketEvent) ~= "string") then
					geterrorhandler()((MAJOR .. ": RegisterBucketEvent(event, interval[, callback]) 'event' - values in this table must be strings, got %s at event[%s]"):format(type(bucketEvent), tostring(i)), 2)
					return 
				end
				
				_BUCKETFRAME:RegisterEvent(bucketEvent)
			end
		end
	end
end

_MODULE.UnregisterBucket = function(self, eventOrID)
	ArgCheck(eventOrID, 1, "string", "number")
end

_MODULE.UnregisterBucketEvent = function(self, eventOrID, id)
	ArgCheck(eventOrID, 1, "string", "number")
	ArgCheck(id, 1, "number", "nil")
end

_MODULE.UnregisterAllBuckets = function(self)
end

--
-- Manualy fires off a bucketevent
--
-- FireBucketEvent(event, ...)
-- @param event <string> the event to be fired. works with custom events
-- @param ... <vararg> event arguments
_MODULE.FireBucketEvent = function(self, event, ...)
	ArgCheck(event, 1, "string")
	
	OnBucketEvent(self, event, ...)

	if not(isEvent(event)) then
		-- notify the callback handler for custom events
		OnCallbackEvent(self, event, ...)
	end
end

--
-- Manually fires the given bucket. will only work with bucket id's
--
-- FireBucket(bucketID[, ...])
-- @param bucketID <number> the unique bucketID
-- @param ... <vararg> event arguments 
_MODULE.FireBucket = function(self, bucketID, ...)
	ArgCheck(id, 1, "number")
	
	-- abort if the bucket doesn't exist anymore
	if not(bucketReference[bucketID]) then
		return
	end
	
	-- abort if the bucket is still on cooldown
	if (_BUCKETTIMER[bucketID]) and (_BUCKETTIMER[bucketID] > 0) then
		return
	end
	
	local callback = bucketReference[bucketID].callback
	
	if (type(callback) == "function") then
		-- reset interval timer
		_BUCKETTIMER[bucketID] = bucketReference[bucketID].interval

		callback(self, nil, ...)
	elseif (type(callback) == "string") then
		if (self[callback]) then
			if (type(self[callback]) == "function") then
				-- reset interval timer
				_BUCKETTIMER[bucketID] = bucketReference[bucketID].interval

				self[callback](self, callback, ...)
			else
				geterrorhandler()(MAJOR .. (": Missing function '%s' in the module named '%s'"):format(callback, self:GetName()))
			end
		else
			geterrorhandler()(MAJOR .. (": Missing function '%s' in the module named '%s'"):format(callback, self:GetName()))
		end
	else
		return
	end
end

------------------------------------------------------------------------------------------------------------
-- 	Embed libraries
------------------------------------------------------------------------------------------------------------
--
-- @param (...) <string>, <string>, <string> ...
_MODULE.EmbedLibraries = function(self, ...)
	for i= 1, select("#", ... ) do
		self:EmbedLibrary((select(i, ...)))
	end
end

--
-- @param libname <string>
_MODULE.EmbedLibrary = function(self, libname)
	local lib = LibStub:GetLibrary(libname)
	if (not lib) then
		geterrorhandler()((MAJOR .. ": EmbedLibrary(libname): 'libname' - cannot find a library instance of %q"):format(tostring(libname)), 2)
		
	elseif (lib) and (type(lib.Embed) == "function") then
		lib:Embed(self)
		return true
		
	elseif (lib) then
		error(("Usage: EmbedLibrary(addon, libname, silent, offset): 'libname' - library '%s' is not Embed capable"):format(libname), offset or 2)
	end
end

------------------------------------------------------------------------------------------------------------
-- 	API calls
------------------------------------------------------------------------------------------------------------
local CreateChatCommand = function(self, func, commands)
	ArgCheck(func, 1, "function")
	ArgCheck(commands, 1, "table", "string")

	local name = MAJOR .. "_ChatCommand" .. tostring(#_SLASH + 1)
	tinsert(_SLASH, name)
	
	_G["SlashCmdList"][name] = function(argString) 
		argString = gsub(argString, "[%s]+", " ")
		func(strsplit(" ", argString))
	end

	if (type(commands) == "table") then 
		for i,v in pairs(commands) do
			if (type(v) ~= "string") then
				geterrorhandler()((MAJOR .. ": CreateChatCommand(func, commands) 'commands' - values in this table must be strings, got %s at commands[%s]"):format(type(v), tostring(i)), 2)
				return 
			end

			_G["SLASH_" .. name .. i] = "/" .. v
		end
	elseif (type(commands) == "string") then 
		_G["SLASH_" .. name .. "1"] = "/".. commands
	end
end

--
-- @param oldClass <table>
-- @return <table> which inherits from oldClass
local NewClass = function(oldClass)
    local newClass = {
		New = function()
			return setmetatable({}, { __index = newClass })
		end
	}

    if (oldClass) then
        setmetatable(newClass, { __index = oldClass })
    end
	
    return newClass
end

--
-- @param name <string> 
-- @param parent <table> object to inherit from
-- @param (...) <string>, <string>, <string> ... list of libraries to embed
-- @return <table> 
local NewObject = function(name, parent, ...)
	local new = NewClass(parent)
	new._NAME = name

	if (select("#", ...) > 0) then
		new:EmbedLibraries(...)
	end
	
	return new
end

--
-- @param name <string> unique module name (not a global)
-- @param (...) <string>, <string>, <string> ... list of libraries to embed
-- @return <table> new module
local NewModule = function(self, name, ...)
	ArgCheck(name, 1, "string")

	if (self._MODULES[name]) then
		geterrorhandler()((MAJOR .. ": NewModule(name): 'name' - a module named '%s' already exists"):format(name), 2)
		return
	end

	self._MODULES[name] = NewObject(self)

	return self._MODULES[name]
end

--
-- @param name <string> unique module name
-- @return <table> module[name] or nil
local GetModule = function(self, name)
	ArgCheck(name, 1, "string")
	
	return self._MODULES[name]
end

--
-- @param name <string> unique addon name (not a global)
-- @param (...) <string>, <string>, <string> ... list of libraries to embed
-- @return <table> new module
gCore.NewAddon = function(self, name, ...)
	ArgCheck(name, 1, "string")

	if (_ADDONS[name]) then
		geterrorhandler()((MAJOR .. ": NewAddon(name): 'name' - a module named '%s' already exists"):format(name), 2)
		return
	end
	
	_ADDONS[name] = NewObject(name, _MODULE, ...)
	_ADDONS[name]._MODULES = {}
	_ADDONS[name]._CALLBACKS = {}
	_ADDONS[name].NewModule = NewModule
	_ADDONS[name].GetModule = GetModule

	return _ADDONS[name]
end

--
-- @param name <string> unique module name (not a global)
-- @param (...) <string>, <string>, <string> ... list of library names to embed
-- @return <table> new module
function gCore:NewModule(name, ...)
	ArgCheck(name, 1, "string")

	if (_MODULES[name]) then
		geterrorhandler()((MAJOR .. ": NewModule(name): 'name' - a module named '%s' already exists"):format(name), 2)
		return
	end
	
	_MODULES[name] = NewClass(_MODULE)
	_MODULES[name].NAME = name
	
	if (select("#", ...) > 0) then
		_MODULES[name]:EmbedLibraries(...)
	end
	
	return _MODULES[name]
end

--
-- @param name <string> unique module name
-- @return <table> module[name] or nil
function gCore:GetModule(name)
	ArgCheck(name, 1, "string")
	
	return _MODULES[name]
end

function gCore:GetAllModules()
	return _MODULES
end

--
-- @param func <function> 
-- @param commands <table> or <string>
function gCore:CreateChatCommand(func, commands)
	ArgCheck(func, 1, "function")
	ArgCheck(commands, 2, "table", "string")

	local name = MAJOR .. "_ChatCommand" .. tostring(countKeys(_SLASH) + 1)
	tinsert(_SLASH, name)
	
	_G["SlashCmdList"][name] = function(argString) 
		func(strsplit(" ", argString))
	end

	if (type(commands) == "table") then 
		for i,v in pairs(commands) do
			if (type(v) ~= "string") then
				geterrorhandler()((MAJOR .. ": CreateChatCommand(func, commands) 'commands' - values in this table must be strings, got %s at commands[%s]"):format(type(v), tostring(i)), 2)
				return 
			end

			_G["SLASH_" .. name .. i] = "/" .. v
		end
	elseif (type(commands) == "string") then 
		_G["SLASH_" .. name .. "1"] = "/".. commands
	end
end

------------------------------------------------------------------------------------------------------------
-- 	Debugging
------------------------------------------------------------------------------------------------------------
function gCore:list()
	print("|cffffffffModules:|r")
	for name, module in pairs(_MODULES) do
		print((" |cffffaa00%s|r"):format(name))
	end
end

------------------------------------------------------------------------------------------------------------
-- 	Global functions
------------------------------------------------------------------------------------------------------------
--
-- set multiple CVars at once
--
-- @param cvars <table> { [CVarName] = <string> value }
function SetCVars(cvars)
	for i,v in pairs(cvars) do
		safecall(SetCVar(i, v))
	end
end

--
-- returns 1 if 'choice' equals true or 1, and 0 for false, 0 or nil
function GetBinary (choice)
	return ((choice == 1 or choice == true) and 1) or (not choice or choice == 0) and 0 or 0
end

--
-- returns true if 'choice' equals true or 1, or false if it equals false, 0 or nil
--
function GetBoolean(choice)
	return ((choice == true or choice == 1) and true) or ((not choice or choice == 0) and false) or false
end

--
-- embeds every key from source into target
-- will overwrite existing keys in 'target'
--
-- @param target <table> target table
-- @param source <table> source table
-- @return <table> target table
function Embed(target, source)
	if not(target) or not(source) then return end
	if (type(source) ~= "table") or (type(target) ~= "table") then return end 

	for i,v in pairs(source) do
		target[i] = v
	end
	
	return target
end

--
-- deletes entries in the target table that aren't found in source
-- does NOT iterate through subtables! (which is intended)
--
-- @param target <table> target table
-- @param source <table> source table
-- @return <table> target table
CleanTable = function(target, source)
	if not(source) or (type(source) ~= "table") or not(target) or (type(target) ~= "table") then return end
	
	for i,v in pairs(target) do
		if (source[i] == nil) then
			v = nil
		end
	end
	
	return target
end

--
-- fills in the holes in the target table with values from source
-- will clean out unknown keys unless 'noClean' is set to 'true'
--
-- this function is mainly intended for validating saved settings, 
-- and killing off deprecated entries
--
-- ValidateTable(target[, source[, noClean]]) 
-- @param target <table> target table
-- @param source <table> source table
-- @param noClean <boolean>
-- @return <table> target table
ValidateTable = function(target, source, noClean) 
	if not(source) or (type(source) ~= "table") then return end

	if not(target) or (type(target) ~= "table") then 
		target = {}
	end

	for i,v in pairs(source) do
		if (target[i] == nil) or (type(target[i]) ~= type(v)) then
			if (type(v) == "table") then
				target[i] = CopyTable(v)
			else
				target[i] = v
			end
		elseif (type(target[i]) == "table") then
			target[i] = ValidateTable(target[i], v, noClean)
		end
	end
	
	if not(noClean) then
		CleanTable(target, source)
	end
	
	return target
end

--
-- duplicates the source table
-- differs from CopyTable() as this allows copying to existing tables,
-- it also removes entries from dest not found in source.
-- 
-- DuplicateTable(source[, dest])
-- @param source <table> table to be duplicated/copied
-- @param dest <table> optional table to duplicate/copy to. If omitted, CopyTable will be called instead
-- @return <table> dest or a new table
DuplicateTable = function(source, dest)
	if not(dest) then
		return CopyTable(source)
	end

	-- remove keys from dest that don't exist in source
	CleanTable(dest, source)

	-- set all the keys and values in dest to match source
	for key, val in pairs(source) do
		if (type(val) == "table") then
			if not(type(dest[key]) == "table") then
				dest[key] = {}
			end
			DuplicateTable(dest[key], val)
		else
			dest[key] = val
		end
	end
	
	return dest
end

--
-- Set up as global functions
--
_G.Embed = Embed
_G.GetBinary = GetBinary
_G.GetBoolean = GetBoolean
_G.SetCVars = SetCVars
_G.CleanTable = CleanTable
_G.DuplicateTable = DuplicateTable
_G.ValidateTable = ValidateTable
