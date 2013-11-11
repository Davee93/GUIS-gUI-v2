--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local MAJOR, MINOR = "gPanel-2.0", 120
local gPanel, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if (not gPanel) then return end 

assert(LibStub("gFrameHandler-1.0"), MAJOR .. " couldn't find an instance of gFrameHandler-1.0")
assert(LibStub("gString-1.0"), MAJOR .. " couldn't find an instance of gString-1.0")
assert(LibStub("gMedia-3.0"), MAJOR .. " couldn't find an instance of gMedia-3.0")

-- Lua API
local type = type
local strmatch = string.match
local floor, min, max = math.floor, math.min, math.max
local tonumber, tostring = tonumber, tostring
local pairs, unpack = pairs, unpack
local getmetatable, setmetatable = getmetatable, setmetatable

-- WoW API
local CreateFrame = CreateFrame

local GameTooltip = GameTooltip
local UIParent = UIParent

-- GUIS API
local M = LibStub("gMedia-3.0")
local RGBToHex = RGBToHex

-- frames used for panels and plugins templates, and event handlers
gPanel.PANEL = gPanel.PANEL or CreateFrame("Frame", "gPanel20PanelFrame", UIParent)
gPanel.PLUGIN = gPanel.PLUGIN or CreateFrame("Frame", "gPanel20PluginFrame", UIParent)

gPanel.db = gPanel.db or {}
gPanel.Lib = gPanel.Lib or {}
gPanel.Panels = gPanel.Panels or {}
gPanel.Plugins = gPanel.Plugins or {}
gPanel.PluginPool = gPanel.PluginPool or {}
gPanel.Templates = gPanel.Templates or {}
gPanel.Tooltips = gPanel.Tooltips or {}

local PANEL = gPanel.PANEL
local PLUGIN = gPanel.PLUGIN

-- this is kind of silly, we can surely find a better way
local ALLOWEDJUSTIFICATION = { 
	TOP 	= true; 
	BOTTOM 	= true; 
	RIGHT 	= true; 
	LEFT 	= true; 
	CENTER 	= true; 
	FULL 	= true; 
}

-- our local color table
local C = {}

C["index"] 			= { 1.00; 1.00; 1.00; 1.00 }
C["value"] 			= { 1.00; 0.82; 0.00; 1.00 }
C["background"] 	= { 0.00; 0.00; 0.00; 1.00 }
C["border"] 		= { 0.15; 0.15; 0.15; 1.00 }
C["overlay"] 		= { 0.25; 0.25; 0.25; 1.00 }
C["shadow"] 		= { 0.00; 0.00; 0.00; 3/4 }

-- grabbing WoWs default colors here
C["RAID_CLASS_COLORS"] = setmetatable({}, { __index = RAID_CLASS_COLORS })
C["FACTION_BAR_COLORS"] = setmetatable({}, { __index = FACTION_BAR_COLORS })

-- textures and colors used by the panels
gPanel.db.texture = M["Background"]["Blank"]
gPanel.db.vertexcolor = C["overlay"]
gPanel.db.backdropcolor = C["background"]
gPanel.db.backdropbordercolor = C["border"]
gPanel.db.backdrop = M["Backdrop"]["Blank-Inset"]
gPanel.db.fontobject = Tooltip_Small

local noop = function() return end

------------------------------------------------------------------------------------------------------------
-- 	Local functions
------------------------------------------------------------------------------------------------------------
--
-- embeds every key from source into target
--
local Embed = function(target, source)
	if not target or not source then return end
	if type(source) ~= "table" or type(target) ~= "table" then return end 

	for i,v in pairs(source) do
		target[i] = v
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
	assert(type(num) == "number", "Bad argument #2 to 'argcheck' (number expected, got " .. type(num) .. ")")
	
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
		_G.error(("Bad argument #%d to '%s' (%s expected, got %s"):format(num, name, types, type(value)), 3)
	end
end

------------------------------------------------------------------------------------------------------------
-- 	Functions available to all gPanel.Plugins
------------------------------------------------------------------------------------------------------------
gPanel.Lib["text"] = function(text, isValue)
	if type(text) == "number" then
		text = tostring(text)
	elseif type(text) ~= "string" then 
		text = ""
	end

	local color
	if isValue then
		color = RGBToHex(C["value"][1], C["value"][2], C["value"][3])
	else
		color = RGBToHex(C["index"][1], C["index"][2], C["index"][3])
	end
	
	return "|cFF" .. color .. text .. "|r"
end

------------------------------------------------------------------------------------------------------------
-- 	Backdrops
------------------------------------------------------------------------------------------------------------
local CreateUIShadow = function(object, size)
	ArgCheck(size, 1, "number", "nil")

	if not(M and M["Backdrop"]["Glow"]) then 
		return
	end
	
	local edgeSize = size or 3
	
	-- create the shadow frame if it doesn't already exist
	if not(object._SHADOW) then
		local s = CreateFrame("Frame", nil, object)
		s:SetFrameStrata(object:GetFrameStrata())
		s:SetFrameLevel(max(0, object:GetFrameLevel() - 2))
		object._SHADOW = s
	end

	object._SHADOW:SetPoint("TOPLEFT", object, "TOPLEFT", -edgeSize, edgeSize)
	object._SHADOW:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", edgeSize, -edgeSize)
	object._SHADOW:SetBackdrop({ edgeFile = M["Border"]["Glow"]; edgeSize = edgeSize; })
	object._SHADOW:SetBackdropBorderColor(unpack(C["shadow"]))
	
	return object._SHADOW
end

local SetUIShadowColor = function(object, r, g, b, a)
	if not(object._SHADOW) then 
		return 
	end
	
	object._SHADOW:SetBackdropBorderColor(r, g, b, a)
end

local GetUIShadowFrame = function(object)
	return object._SHADOW
end

--
-- 	Hook/Unhook a tooltip to the plugin
-- 	Will replace any other existing tooltip
--
local PlaceGameTooltip = function(anchor, horTip)
	GameTooltip:SetOwner(anchor, "ANCHOR_NONE")
	GameTooltip:ClearAllPoints()
	
	if (horTip) then
		if (GetScreenWidth() - anchor:GetRight()) > anchor:GetLeft() then
			GameTooltip:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 8, 0)
		else
			GameTooltip:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -8, 0)
		end
	else
		if (GetScreenHeight() - anchor:GetTop()) > anchor:GetBottom() then
			GameTooltip:SetPoint("BOTTOM", anchor, "TOP", 0, 8)
		else
			GameTooltip:SetPoint("TOP", anchor, "BOTTOM", 0, -8)
		end
	end
end

------------------------------------------------------------------------------------------------------------
-- 	Panel template
------------------------------------------------------------------------------------------------------------
--
-- A plugin can only be shown once in a panel
-- Spawning another with the same name will only return
-- a pointer to the first one
--
-- SpawnPlugin(name[, justify])
-- @param name <string> name of the plugin from the library
-- @param justify <string> 
-- @param <table> pointer to the plugin
PANEL.SpawnPlugin = function(self, name, justify)
	self.Plugins = self.Plugins or {}
	
	local f
	
	if (not self.Plugins[name]) then
		f = setmetatable(CreateFrame("Frame", nil, self), { __index = gPanel.PLUGIN })

		f.overlay = CreateFrame("Frame", nil, f)
		f.overlay:SetAllPoints(f)

		f.lib = gPanel.Lib
		
		f.queuedEvents = {}
		
		f:SetScript("OnShow", function(self) 
			for event,args in pairs(self.queuedEvents) do
				self.onevent(self, event, unpack(args))
				self.queuedEvents[event] = nil
			end
		end)

		Embed(f, gPanel.Plugins[name])
	else
		f = self.Plugins[name]
		f:SetJustify(justify)
	end

	if (not f.active) then
		local object = f.overlay and f.overlay or f
	
		f.justify = ALLOWEDJUSTIFICATION[justify] and justify or "CENTER"

		if not f.text then
			f.text = f:CreateFontString(nil, "OVERLAY")
		end

		f.text:SetFontObject(gPanel.db.fontobject)
		f.text:ClearAllPoints()
		f.text:SetPoint((f.justify == "FULL") and "CENTER" or f.justify, self)
		
		if (f.justify == "RIGHT") or (f.justify == "LEFT") then
			f.text:SetJustifyH(f.justify)
		elseif (f.justify == "BOTTOM") or (f.justify == "TOP") then
			f.text:SetJustifyV(f.justify)
		elseif (f.justify == "FULL") then
			f.text:SetJustifyH("CENTER")
			f.text:SetJustifyV("MIDDLE")
		else
			f.text:SetJustifyH(f.justify)
			f.text:SetJustifyV(f.justify == "CENTER" and "MIDDLE" or f.justify)
		end

		f:SetAllPoints(f.text)
		
		object:EnableMouse(true)

		if (f.variables) then
			for i,v in pairs(f.variables) do
				f[i] = v
			end
		end

		f:UnregisterAllEvents()
		if (f.events) then
			for i,v in pairs(f.events) do
				f:RegisterEvent(v)
			end
		end
		
		-- wipe queued events if any
		wipe(f.queuedEvents)
		
		f:SetScript("OnEvent", nil)
		if (f.onevent) then
			f.ForceEvent = function(self, event, ...)
				f.onevent(self, event, ...)
			end
			
			f:SetScript("OnEvent", function(self, event, ...) 
				if (not self:IsVisible()) then 
					-- insert the event into a queue of actions to be taken when the plugin is next shown
					-- only one instance of each event will occur, and only the latest
					if (event) then
						self.queuedEvents[event] = { ... }
					end
					
					return 
				end
				
				f.onevent(self, event, ...)
			end)
		end
		
		f:SetScript("OnMouseDown", nil)
		if (f.onclick) or (f.tooltiponclick) then
			object:SetScript("OnMouseDown", function(self, button) 
				if (not self:IsVisible()) then 
					return 
				end
				
				if (f.tooltiponclick) then
					if (button == "LeftButton") then
						if (f.tooltiponclick) then
							PlaceGameTooltip(f, f.horizontalTooltip)
							gPanel.Tooltips[f.tooltiponclick](f)
						else
							f.onclick(self, button)
						end
					elseif (f.onclick) then
						f.onclick(self, button)
					end
				else
					if (f.onclick) then
						f.onclick(self, button)
					end
				end
			end)

			if (f.tooltiponclick) and not(f.tooltip) then
				object:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
			end
				
		end
				
		f:SetScript("OnUpdate", nil)
		if (f.onupdate) then
			f.interval = max(0.2, tonumber(f.interval or 1))
			f:SetScript("OnUpdate", function(self, elapsed) 
				if not(self:IsVisible()) then 
					return 
				end
				
				self.elapsed = (self.elapsed or 0) + elapsed
				
				if (self.elapsed >= self.interval) then
					f.onupdate(self)
					self.elapsed = self.elapsed % self.interval
				end
			end)
		end
		
		if (f.tooltip) then
			f:HookTooltip(f.tooltip, f.horizontalTooltip)
		end
		
		if (f.oninit) then
			f.oninit (f)
		end
		
		self.Plugins[name] = f
	end

	self.Plugins[name].type = name
	self.Plugins[name].active = true
	self.Plugins[name]:Refresh()
	
	-- store it in our pluginpool
	gPanel.PluginPool[self.Plugins[name]] = true
	
	return self.Plugins[name]
end

--
-- 	Killing a plugin doesn't really remove it, it only hides it and halts its updating
-- 	The frame will remain in memory until reload or logout
--
-- @param name <string> 
PANEL.KillPlugin = function(self, name)
	if (not self.Plugins) or (not self.Plugins[name]) then 
		return 
	end

	self.Plugins[name].active = false
	self.Plugins[name]:Refresh()
	
	-- remove it form our pluginpool
	gPanel.PluginPool[self.Plugins[name]] = nil
end

--
-- set the font object of your panel
PANEL.SetFontObject = function(self, fontObject)
	if (not self.text) then 
		return 
	end
	
	self.text:SetFontObject(fontObject)
end

--
-- 	Refresh the panel and it's contents
--	Call this to update positions, fonts, etc
--
PANEL.Refresh = function(self)
	for i,v in pairs(self.Plugins) do
		v:Refresh()
	end
end

------------------------------------------------------------------------------------------------------------
-- 	Plugin template
------------------------------------------------------------------------------------------------------------
--
-- 	Sets which part of the panel the plugin should be aligned to
-- 		justify 	= "TOP", "BOTTOM", "RIGHT", "LEFT" or "CENTER" 
--
PLUGIN.SetJustify = function(self, justify)
	self.justify = ALLOWEDJUSTIFICATION[justify] and justify or "CENTER"
end

--
-- 	Refresh the plugin
--	Call this to update positions, fonts, etc
--
PLUGIN.Refresh = function(self)
	if (self.active) and (not self:IsVisible()) then
		self:Show()
	elseif (not self.active) and (self:IsVisible()) then
		self:Hide()
	end
	
	if (self.active) then
		if (self.justify == "FULL") then
			self.text:SetAllPoints(self:GetParent())
		else
			local padding = 12

			local x = (self.justify == "RIGHT") and -padding or (self.justify == "LEFT") and padding or 0
			local y = (self.justify == "TOP") and -padding or (self.justify == "BOTTOM") and padding or 0
			
			self.text:ClearAllPoints()
			self.text:SetPoint(self.justify, self:GetParent(), self.justify, x, y)
		end
	end
end

PLUGIN.HookTooltip = function(self, name, horTip)
	local object = self.overlay and self.overlay or self
	local parent = self;
	
	object:SetScript("OnEnter", function(self) 
		PlaceGameTooltip(self, horTip)
		gPanel.Tooltips[name](parent)
	end)
	
	object:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
end

PLUGIN.UnhookTooltip = function(self)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
end



------------------------------------------------------------------------------------------------------------
-- 	Panels
------------------------------------------------------------------------------------------------------------
--
-- 	Register a new plugin with library, which will be available for all panel objects to use
-- 	Will overwrite any exisiting plugin with the same name
--
gPanel.RegisterPlugin = function(self, name, plugin)
	ArgCheck(name, 1, "string")
	ArgCheck(plugin, 2, "table")

	gPanel.Plugins[name] = plugin
end

--
-- force an event to happen to all plugins of the specified name/type
gPanel.ForcePluginEvent = function(self, name, event, ...)
	for plugin, active in pairs(gPanel.PluginPool) do
		if (active) and (plugin.type == name) then
			plugin:ForceEvent(event, ...)
		end
	end
end

--
-- force an event to happen to all plugins
gPanel.ForceEvent = function(self, event, ...)
	for plugin, active in pairs(gPanel.PluginPool) do
		if (active) then
			plugin:ForceEvent(event, ...)
		end
	end
end

--
-- 	Register a new tooltip
--
gPanel.RegisterTooltip = function(self, name, func)
	ArgCheck(name, 1, "string")
	ArgCheck(func, 2, "function", "nil")

	gPanel.Tooltips[name] = type(func) == "function" and func or noop
end

--
-- Sets the font object of all panels
--
gPanel.SetFontObject = function(self, fontObject)
	gPanel.db.fontobject = fontObject
	for name,p in pairs(gPanel.Panels) do
		p.text:SetFontObject(fontObject)
	end
end


--
-- 	Get a pointer to an existing panel based on it's name
--
gPanel.GetPanel = function(self, name)
	return gPanel.Panels[name]
end

--
-- Set one of the stored default colors for the panel
--
gPanel.SetColor = function(self, key, r, g, b, a)
	ArgCheck(key, 1, "string")
	
	if (not C[key]) then
		geterrorhandler()((MAJOR .. ": SetColor(key, r[, g, b[, a]]) 'key' - cannot find any colors named '%s'"):format(type(key)), 2)
		return 
	end
	
	ArgCheck(r, 2, "number", "table")

	if (type(r) == "number") then
		ArgCheck(g, 3, "number")
		ArgCheck(b, 4, "number")
		ArgCheck(a, 5, "number", "nil")
		
		C[key][1] = r
		C[key][2] = g
		C[key][3] = b
		
		if a then
			C[key][4] = a
		end
	elseif (type(r) == "table") then
		C[key] = r
	end
end

gPanel.GetColor = function(self, key)
	ArgCheck(key, 1, "string")
	
	if (not C[key]) then
		geterrorhandler()((MAJOR .. ": SetColor(key, r[, g, b[, a]]) 'key' - cannot find any colors named '%s'"):format(type(key)), 2)
		return 
	end

	return C[key]
end

--
-- 	Create a new panel object, or refresh it if object exists
--	 *anchor is both the parent and anchor, if given
--
local panelcount = 0
local CreateUIPanel = function(anchor, name)
	if (gPanel.Panels[name]) then
		gPanel.Panels[name]:Refresh()
	else

		panelcount = max(#gPanel.Panels + 1, panelcount + 1)

		if (not name) then
			name = "gPanel20_UserPanel_" .. panelcount
		end
		
		local parent
		if (type(anchor) == "string") then
			if (_G[anchor]) and (_G[anchor].IsObjectType) and (_G[anchor]:IsObjectType("Frame")) then
				parent = _G[anchor]
			end
		elseif (anchor) and (anchor.IsObjectType) and (anchor:IsObjectType("Frame")) then
			parent = anchor
		else
			parent = UIParent
		end

		local panel = setmetatable(CreateFrame("Frame", name, parent), { __index = PANEL })
		panel:SetAllPoints(parent)
		panel:SetFrameStrata(parent:GetFrameStrata())
		panel:SetFrameLevel(parent:GetFrameLevel())
		
		if (parent == UIParent) then
			panel:SetFrameLevel(20)
			panel:SetFrameStrata("LOW")
		end
		
		panel.Plugins = panel.Plugins or {}
		
		if (parent ~= UIParent) then
			parent.panel = panel
		end
		
		-- update all plugins when a panel becomes visible
		panel:SetScript("OnShow", function(self) 
			self:Refresh()
		end)

		gPanel.Panels[name] = panel
	end
	
	return gPanel.Panels[name]
end

local SetUITemplate = function(object, name, ...)
	if (not gPanel.Templates[name]) then 
		return 
	end

	return gPanel.Templates[name](object, ...)
end

gPanel.CreateUIPanel = function(self, ...)
	return CreateUIPanel(...)
end

gPanel.RegisterUITemplate = function(self, name, data)
	gPanel.Templates[name] = data 
end

------------------------------------------------------------------------------------------------------------
-- 	API calls
------------------------------------------------------------------------------------------------------------
do
	local setAPI = function(frame)
		local meta = getmetatable(frame).__index

		if not meta.CreateUIPanel then meta.CreateUIPanel = CreateUIPanel end
		if not meta.CreateUIShadow then meta.CreateUIShadow = CreateUIShadow end
		if not meta.SetUIShadowColor then meta.SetUIShadowColor = SetUIShadowColor end
		if not meta.GetUIShadowColor then meta.GetUIShadowColor = GetUIShadowColor end
		if not meta.GetUIShadowFrame then meta.GetUIShadowFrame = GetUIShadowFrame end
		if not meta.SetUITemplate then meta.SetUITemplate = SetUITemplate end

	end

	local done = {}

	local frames = EnumerateFrames()
	while frames do
		if (not done[frames:GetObjectType()]) then
			setAPI(frames)
			done[frames:GetObjectType()] = true
		end

		frames = EnumerateFrames(frames)
	end
	
	done = nil
end

