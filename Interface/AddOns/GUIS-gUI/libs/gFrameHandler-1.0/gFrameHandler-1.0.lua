--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local MAJOR, MINOR = "gFrameHandler-1.0", 60
local gFrameHandler, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

-- gFrameHandler already in place
if not gFrameHandler then return end 

-- Lua API
local type, tonumber = type, tonumber
local print, gsub = print, gsub
local floor = math.floor
local tinsert = table.insert
local pairs, unpack = pairs, unpack
local setmetatable = setmetatable

-- WoW API
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local IsLoggedIn = IsLoggedIn

local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("VARIABLES_LOADED")
eventHandler:RegisterEvent("PLAYER_LOGIN")
eventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
eventHandler:RegisterEvent("PLAYER_REGEN_DISABLED")
eventHandler:SetScript("OnEvent", function(self, event, ...) 
	gFrameHandler[event](gFrameHandler, event, ...)
end)

gFrameHandler.Objects = gFrameHandler.Objects or {}
gFrameHandler.Queue = gFrameHandler.Queue or {}
gFrameHandler.Positions = gFrameHandler.Positions or {}
gFrameHandler.Anchors = gFrameHandler.Anchors or {}
gFrameHandler.fontObject = gFrameHandler.fontObject or SystemFont_Outline

local print, round
local GetSmartName, GetPoint
local CreateAnchor, GetAnchor, Lock, Unlock, Reset, IsLocked, PlaceGameTooltip
local CenterHorizontally, CenterVertically, HasMoved
local SetSavedPosition, GetSavedPosition, DeleteSavedPosition, RestoreToSavedPosition
local RegisterForSave, UnregisterForSave, RestoreAllSavedPositions, ClearAllSavedPositions

local dragTexture = {0.8, 0.8, 1, 0.5}
local HITRECT = -15
local CLAMPRECT = -8

-- localization
local L = {}
L["<Left-Click and drag to move the frame>"] = true
L["<Left-Click+Shift to lock into position>"] = true
L["<Right-Click for options>"] = true
L["Lock"] = true
L["Center horizontally"] = true
L["Center vertically"] = true
L["Reset"] = true

-- can't be bothered with gLocale here, so we're faking it
-- the locales are most likely replaced by gUI™ anyway
for i,v in pairs(L) do
	if (v == true) then
		L[i] = i
	end
end

print = function(...)
	return _G.print((GetAddOnMetadata(addon, "Title") or addon) .. ":" , ...)
end

round = function(n)
	return floor(n * 1e5 + .5) / 1e5
end

PlaceGameTooltip = function(anchor, horTip)
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
-- 	Extended/Improved Frame- And Texture Handling
------------------------------------------------------------------------------------------------------------

--
-- this function will always return the position relative to UIParent
GetPoint = function(object)
	local UIcenterX, UIcenterY = UIParent:GetCenter()
	local objectX, objectY = object:GetCenter()

	if not objectX then return end

	local UIScale = UIParent:GetEffectiveScale()
	local objectScale = object:GetEffectiveScale()

	local UIWidth, UIHeight = UIParent:GetRight(), UIParent:GetTop()

	local LEFT = UIWidth / 3
	local RIGHT = UIWidth * 2 / 3
	local BOTTOM = UIHeight / 3
	local TOP = UIHeight * 2 / 3

	local point, x, y
	if objectX >= RIGHT then
		point = "RIGHT"
		x = object:GetRight() - UIWidth
	elseif objectX <= LEFT then
		point = "LEFT"
		x = object:GetLeft()
	else
		x = objectX - UIcenterX
	end

	if objectY >= TOP then
		point = "TOP" .. (point or "")
		y = object:GetTop() - UIHeight
	elseif objectY <= BOTTOM then
		point = "BOTTOM" .. (point or "")
		y = object:GetBottom()
	else
		if not point then point = "CENTER" end
		y = objectY - UIcenterY
	end

	return point, "UIParent", point, round(x * UIScale / objectScale),  round(y * UIScale / objectScale)
end

CenterHorizontally = function(object)
	local UIcenterX, UIcenterY = UIParent:GetCenter()
	local objectX, objectY = object:GetCenter()
	
	if not objectX then return end

	local scale = UIParent:GetEffectiveScale() / object:GetEffectiveScale()

	object:ClearAllPoints()
	object:SetPoint("CENTER", UIParent, "CENTER", 0,  round((objectY-UIcenterY) * scale))
end

CenterVertically = function(object)
	local UIcenterX, UIcenterY = UIParent:GetCenter()
	local objectX, objectY = object:GetCenter()
	
	if not objectX then return end

	local scale = UIParent:GetEffectiveScale() / object:GetEffectiveScale()

	object:ClearAllPoints()
	object:SetPoint("CENTER", UIParent, "CENTER", round((objectX-UIcenterX) * scale), 0)
end

------------------------------------------------------------------------------------------------------------
-- 	Saved position handlers
------------------------------------------------------------------------------------------------------------
SetSavedPosition = function(object)
	if (object:GetName()) then
		gFrameHandler.Positions[object:GetName()] = { GetPoint(object) }
		
		local anchor = gFrameHandler.Anchors[object:GetName()]
		if (anchor) and (anchor.anchor) then
			anchor.anchor:SetSize(object:GetSize())
			anchor.anchor:ClearAllPoints()
			anchor.anchor:SetPoint(GetPoint(object))
		end
	end
end

GetSavedPosition = function(object)
	if not(object:GetName()) or not(gFrameHandler.Positions[object:GetName()]) then return end

	local anchor = gFrameHandler.Anchors[object:GetName()]
				
	if not(anchor) or ((anchor.anchor) and (anchor.anchor.isActive)) then
		return unpack(gFrameHandler.Positions[object:GetName()])
	end
end

HasMoved = function(object)
	if (object) and (object:GetName()) and (gFrameHandler.Positions[object:GetName()]) then 
		return true
	end
end

DeleteSavedPosition = function(object)
	if not(object:GetName()) or not(gFrameHandler.Positions[object:GetName()]) then return end
	
	gFrameHandler.Positions[object:GetName()] = nil
end

RestoreToSavedPosition = function(object)
	if not(object:GetName()) or not(gFrameHandler.Positions[object:GetName()]) then return end
	
	if not(InCombatLockdown()) then
		local point, anchor, relpoint, x, y = GetSavedPosition(object)
		if point then
			object:ClearAllPoints()
			object:SetPoint(point, anchor, relpoint, x, y)
		end
	end
end

Lock = function(object)
	if not(gFrameHandler.Anchors[object:GetName()] and gFrameHandler.Anchors[object:GetName()].anchor) then return end

	gFrameHandler.Anchors[object:GetName()].anchor.isLocked = true
	gFrameHandler.Anchors[object:GetName()].anchor:Hide()
end

Unlock = function(object)
	if not(gFrameHandler.Anchors[object:GetName()] and gFrameHandler.Anchors[object:GetName()].anchor) then 
		CreateAnchor(object)
	end

	if not(InCombatLockdown()) then
		local anchor = gFrameHandler.Anchors[object:GetName()].anchor
				
		if (anchor.isActive) then
			anchor.isLocked = false
			anchor:SetSize(object:GetSize())
			anchor:ClearAllPoints()
			anchor:SetPoint(GetPoint(object))
			anchor:Show()
		end
	end
end

Reset = function(object)
	if not(object.GetName) or not(gFrameHandler.Anchors[object:GetName()]) or not(gFrameHandler.Anchors[object:GetName()].defaultPosition) then return end
	
	if not(InCombatLockdown()) then
		local anchor = gFrameHandler.Anchors[object:GetName()]
				
		if not(anchor) or ((anchor.anchor) and (anchor.anchor.isActive)) then
			object:ClearAllPoints()
			object:SetPoint(unpack(gFrameHandler.Anchors[object:GetName()].defaultPosition))
			DeleteSavedPosition(object)
		end
	end
end

IsLocked = function(object)
	return (not(gFrameHandler.Anchors[object:GetName()]) or (gFrameHandler.Anchors[object:GetName()] and (gFrameHandler.Anchors[object:GetName()].anchor.isLocked == true))) and true or false
end

--
-- Attempting to make the display names more readable
-- Will have to work a bit on this one
--
-- My search patterns suck, I really need to update my skills there a bit
local tchelper = function(first, rest)
	return first:upper() .. rest:lower()
end

GetSmartName = function(object)
	if not object.GetName or not object:GetName() or object:GetName() == "" then return "" end
	
	local name = object:GetName()
	
	-- remove clutter
	name = gsub(name, "(GUIS_ActionBar_%d+_)", "Action Bar ")
	name = gsub(name, "(oUF_)", "")
	name = gsub(name, "(oUF)", "")
	name = gsub(name, "(GUIS)", "")
	name = gsub(name, "(gUI)", "")
	name = gsub(name, "(: )", "")
	name = gsub(name, "(:)", "")
	name = gsub(name, "(-)", " ")
	name = gsub(name, "(_)", " ")
	
	-- shrink spaces
	while (name:find("  ")) do
		name = gsub(name, "  ", " ")
	end
	
	-- separate words
	name = gsub(name, "(%l)(%u)", function(l, u) return l .. " " .. u end)
	
	-- capitalize each word
	name = gsub(name, "(%a)([%w_']*)", tchelper)
	
	return name
end

CreateAnchor = function(object)
	if gFrameHandler.Anchors[object:GetName()] and gFrameHandler.Anchors[object:GetName()].anchor then 
		gFrameHandler.Anchors[object:GetName()].anchor.isActive = true

		if not gFrameHandler.Anchors[object:GetName()].defaultPosition then 
			gFrameHandler.Anchors[object:GetName()].defaultPosition = {GetPoint(object)}
		end

		return 
	end
	
	gFrameHandler.Anchors[object:GetName()] = gFrameHandler.Anchors[object:GetName()] or {}
	
	local anchor = CreateFrame("Frame", nil, UIParent)
	anchor:Hide()
	anchor:SetFrameStrata("DIALOG")
	anchor:SetSize(object:GetSize())
	anchor:SetPoint(GetPoint(object))
	anchor:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground" })
	anchor:SetBackdropColor(1, 1, 1, 1/3)
	anchor:SetHitRectInsets(HITRECT, HITRECT, HITRECT, HITRECT)
	anchor:SetClampRectInsets(CLAMPRECT, CLAMPRECT, CLAMPRECT, CLAMPRECT)
	anchor:SetClampedToScreen(false)
	anchor:EnableMouse(true)
	anchor:SetMovable(true)
	anchor:SetUserPlaced(true)
	anchor:RegisterForDrag("LeftButton")

	anchor.isLocked = true
	anchor.isActive = true
	anchor.frame = object

	if not gFrameHandler.Anchors[object:GetName()].defaultPosition then 
		gFrameHandler.Anchors[object:GetName()].defaultPosition = {GetPoint(object)}
	end
	
	local anchorTitle = anchor:CreateFontString(nil, "OVERLAY")
	anchorTitle:SetPoint("CENTER", anchor, "CENTER")
	anchorTitle:SetFontObject(gFrameHandler.fontObject)
	anchorTitle:SetText(GetSmartName(object))
	anchorTitle:SetTextColor(1, 1, 1, 1)
	anchor.anchorTitle = anchorTitle
	
	anchor:SetScript("OnEnter", function(self) 
		self:SetBackdropColor(1, 1, 0.5, 1)

		PlaceGameTooltip(self)

		GameTooltip:AddLine(self.anchorTitle:GetText(), 1, 1, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["<Left-Click and drag to move the frame>"])
		GameTooltip:AddLine(L["<Left-Click+Shift to lock into position>"])
		GameTooltip:AddLine(L["<Right-Click for options>"])
		
		GameTooltip:Show()
	end)

	anchor:SetScript("OnLeave", function(self) 
		self:SetBackdropColor(1, 1, 1, 1/3)

		GameTooltip:Hide()
	end)
	
	anchor.menuFrame = CreateFrame("Frame", anchor.frame:GetName() .. "DropDown", anchor, "UIDropDownMenuTemplate")
	anchor.menuList = {
		{
			text = L["Lock"];
			notCheckable = true;
			func = function()
				if (InCombatLockdown()) then
					return
				end
				
				Lock(anchor.frame)
			end
		};
		{
			text = L["Center horizontally"];
			notCheckable = true;
			func = function()
				if (InCombatLockdown()) then
					return
				end

				CenterHorizontally(anchor.frame)

				anchor:SetSize(anchor.frame:GetSize())
				anchor:ClearAllPoints()
				anchor:SetPoint(GetPoint(anchor.frame))

				SetSavedPosition(anchor.frame)
			end
		};
		{
			text = L["Center vertically"];
			notCheckable = true;
			func = function()
				if (InCombatLockdown()) then
					return
				end
				
				CenterVertically(anchor.frame)

				anchor:SetSize(anchor.frame:GetSize())
				anchor:ClearAllPoints()
				anchor:SetPoint(GetPoint(anchor.frame))

				SetSavedPosition(anchor.frame)
			end
		};
		{
			text = L["Reset"];
			notCheckable = true;
			func = function()
				if (InCombatLockdown()) then
					return
				end

				Reset(anchor.frame)

				anchor:SetSize(anchor.frame:GetSize())
				anchor:ClearAllPoints()
				anchor:SetPoint(GetPoint(anchor.frame))
			end
		};
	}
	
	anchor:SetScript("OnMouseDown", function(self, button) 
		if (button == "LeftButton") and (IsShiftKeyDown()) then
			Lock(self.frame)
			
		elseif (button == "RightButton") then
			EasyMenu(self.menuList, self.menuFrame, "cursor", 0, 0, "MENU", 2)
		end
	end)

	anchor:SetScript("OnDragStart", function(self)
		self:StartMoving()

		self.oldAlpha = self.frame:GetAlpha()

		self.frame:SetAlpha(0)
	end)

	anchor:SetScript("OnDragStop", function(self) 
		self:StopMovingOrSizing()

		self.frame:ClearAllPoints()
		self.frame:SetPoint(GetPoint(self))
		self.frame:SetAlpha(self.oldAlpha)

		self.oldAlpha = nil
		
		SetSavedPosition(self.frame)
	end)
	
	gFrameHandler.Anchors[object:GetName()].anchor = anchor
end

GetAnchor = function(object)
	return (object) and (object:GetName()) and (gFrameHandler.Anchors[object:GetName()]) and gFrameHandler.Anchors[object:GetName()].anchor
end

-- can also be used to update the default position of an already registered object
RegisterForSave = function(object, ...)
	if not(object:GetName()) or object:GetName() == "" then return end

	gFrameHandler.Anchors[object:GetName()] = gFrameHandler.Anchors[object:GetName()] or {}
	gFrameHandler.Objects[object:GetName()] = gFrameHandler.Objects[object:GetName()] or {}
	gFrameHandler.Objects[object:GetName()].object = object
	
	-- activate it if it exists already
	if (gFrameHandler.Anchors[object:GetName()].anchor) then
		gFrameHandler.Anchors[object:GetName()].anchor.isActive = true
	end
	
	if (...) then
		gFrameHandler.Anchors[object:GetName()].defaultPosition = {...}
	else
		if (IsLoggedIn()) then
			gFrameHandler.Anchors[object:GetName()].defaultPosition = {GetPoint(object)}
			
			-- we're already logged in, so move it to its default position if it exists
			RestoreToSavedPosition(object) 
		else
			gFrameHandler.Queue[object:GetName()] = true
		end
	end
end

-- this should only be called after PLAYER_LOGIN and VARIABLES_LOADED, 
-- as it disregards the queue for storing default position and restoring saved position
UnregisterForSave = function(object)
	if (InCombatLockdown()) then return end
	if not(object:GetName()) or (object:GetName() == "") then return end
	if not(gFrameHandler.Anchors[object:GetName()] and gFrameHandler.Anchors[object:GetName()].anchor) then return end

	Lock(object)
	Reset(object)
		
	DeleteSavedPosition(object)
	
	-- store new default position
	gFrameHandler.Anchors[object:GetName()].defaultPosition = {GetPoint(object)}
	
	-- make it inactive
	gFrameHandler.Anchors[object:GetName()].anchor.isActive = false

--	self.Objects[object:GetName()] = nil
--	self.Anchors[object:GetName()] = nil
end

RestoreAllSavedPositions = function()
	if not InCombatLockdown() then
		for object, position in pairs(gFrameHandler.Positions) do
			if (_G[object]) and (_G[object].SetPoint) then
				Lock(_G[object])
				
				-- queued objects that haven't got their defaults registered yet
				-- these can't be moved yet, as that would delete the original position
				if not(gFrameHandler.Queue[_G[object]:GetName()]) then
					local anchor = gFrameHandler.Anchors[_G[object]:GetName()]
					
					if not(anchor) or ((anchor.anchor) and (anchor.anchor.isActive)) then
						_G[object]:ClearAllPoints()
						_G[object]:SetPoint(unpack(position))
					end
				end
			end
		end
	else
		eventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
end

ClearAllSavedPositions = function()
	wipe(gFrameHandler.Positions)
end

------------------------------------------------------------------------------------------------------------
-- 	Extended WoW API
------------------------------------------------------------------------------------------------------------
local safeKill = CreateFrame("Frame")
safeKill:Hide()
Kill = function(self, killUpdate)
	if (self.UnregisterAllEvents) then
		self:UnregisterAllEvents()
	end
	
	if (killUpdate) then
		if (self.GetScript) and (self:GetScript("OnUpdate")) then
			self:SetScript("OnUpdate", nil)
		end
	end
	
	if (self:GetObjectType() == "Texture") then
		-- the usual but tainty way
		self.Show = self.Hide
		self:Hide()
	else
		-- the 'safe' way, to avoid the neverending :Show() taint for secure frames
		-- we use the same method in gActionBars
		self:SetParent(safeKill)
	end
end

SetVisibility = function(self, condition)
	if (condition) then
		if not(self:IsShown()) then
			return self:Show()
		end
	else
		if (self:IsShown()) then
			return self:Hide()
		end
	end
end

------------------------------------------------------------------------------------------------------------
-- 	Add the library API
------------------------------------------------------------------------------------------------------------
function gFrameHandler:GetPoint(object)
	return GetPoint(object)
end

function gFrameHandler:Register(object, ...)
	if not(object) or not(object.IsObjectType) or not(object:IsObjectType("Frame")) or not(object:GetName()) or (object:GetName() == "") then 
		return 
	end

	RegisterForSave(object, ...)
end

function gFrameHandler:Unregister(object)
	if not(object) or not(object.GetName) or not(object:GetName()) or (object:GetName() == "") then return end
	
	UnregisterForSave(object)
	
	-- we don't want to actually delete the information, 
	-- we keep it around in case the object will be re-registered again
--	self.Objects[object:GetName()] = nil
--	self.Anchors[object:GetName()] = nil

--	DeleteSavedPosition(object)
end

function gFrameHandler:SetFontObject(fontObject)
	self.fontObject = fontObject or SystemFont_Outline
end

local _UNLOCK
function gFrameHandler:Unlock()
	if not InCombatLockdown() then
		_UNLOCK = true
		for _,object in pairs(self.Objects) do
			Unlock(object.object)
		end
	end
end

function gFrameHandler:Lock()
	_UNLOCK = nil
	for _,object in pairs(self.Objects) do
		Lock(object.object)
	end
end

function gFrameHandler:Reset(bar)
	-- only lock everything if no single frame or table is specified
	if not(bar) then
		self:Lock()
	end
	
	if not(InCombatLockdown()) then
		if (bar) then
			if (bar.GetObjectType) and (bar:IsObjectType("Frame")) and (self.Anchors[bar:GetName()]) then
				Lock(bar)
				
				bar:ClearAllPoints()
				bar:SetPoint(unpack(self.Anchors[bar:GetName()].defaultPosition))			
				
				DeleteSavedPosition(bar)
				
			elseif (type(bar) == "table") then
				for name, object in pairs(bar) do
					if (object.GetObjectType) and (object:IsObjectType("Frame")) and (self.Anchors[object:GetName()]) then
						Lock(object)
						
						object:ClearAllPoints()
						object:SetPoint(unpack(self.Anchors[object:GetName()].defaultPosition))				
					
						DeleteSavedPosition(object)
					end
				end
			end
		else
			for name, object in pairs(self.Objects) do
				Lock(object.object)
				
				object.object:ClearAllPoints()
				object.object:SetPoint(unpack(self.Anchors[object.object:GetName()].defaultPosition))
			end
			
			ClearAllSavedPositions()
		end
	end
end

function gFrameHandler:ToggleLock()
	if _UNLOCK then
		self:Lock()
	else
		self:Unlock()
	end
end

function gFrameHandler:IsLocked()
	return not(_UNLOCK)
end

function gFrameHandler:SetSavedPositions(tbl)
	if type(tbl) ~= "table" then
		geterrorhandler()((MAJOR .. ": SetSavedPositions(tbl) 'tbl' - table expected, got %s"):format(type(tbl)), 2)
		return 
	end

	self.Positions = tbl
end

function gFrameHandler:GetSavedPositions()
	return self.Positions
end

function gFrameHandler:GetSavedPosition(object)
	return GetSavedPosition(object)
end

local PlaceAndSave = function(object, ...)
	local a, b, c, d, e = gFrameHandler:GetSavedPosition(object)
	local f, g, h, i, j = ...

	object:ClearAllPoints()
	if (a) then
		object:SetPoint(a, b, c, d, e)
	else
		if (...) then
			object:SetPoint(...)
		end
	end
	object:RegisterForSave(...)
end

-- use this function to corretly place an object in its initial position
-- will use the saved position if it exits, ... (default position) otherwise
-- this will also register it for save this session
function gFrameHandler:PlaceAndSave(object, ...)
	PlaceAndSave(object, ...)
end

function gFrameHandler:GetAnchor(object)
	return GetAnchor(object)
end

function gFrameHandler:PLAYER_LOGIN()
	for fName,_ in pairs(self.Queue) do
		if _G[fName] then
			self.Anchors[fName].defaultPosition = {GetPoint(_G[fName])} -- store the default position
			RestoreToSavedPosition(_G[fName]) -- update the position to its saved position if it exists
		end
	end
end

function gFrameHandler:PLAYER_ENTERING_WORLD()
	RestoreAllSavedPositions()
end

function gFrameHandler:VARIABLES_LOADED()
	RestoreAllSavedPositions()
end

function gFrameHandler:PLAYER_REGEN_DISABLED()
	if _UNLOCK then
		self:Lock()
	end
end

function gFrameHandler:PLAYER_REGEN_ENABLED()
	eventHandler:UnregisterEvent("PLAYER_REGEN_ENABLED")
	
	RestoreAllSavedPositions()
end

-- @param locale <table> the typical localization table to replace the internal one
function gFrameHandler:SetLocale(locale)
	L = locale
end

------------------------------------------------------------------------------------------------------------
-- 	API calls
------------------------------------------------------------------------------------------------------------
do
	local function setAPI(frame)
		local meta = getmetatable(frame).__index
		meta.RegisterForSave = RegisterForSave 
		meta.PlaceAndSave = PlaceAndSave
		meta.UnregisterForSave = UnregisterForSave 
		meta.Kill = Kill 
		meta.SetVisibility = SetVisibility 
		meta.GetRealPoint = GetPoint 
		meta.HasMoved = HasMoved 
	end

	local done = {}

	local frames = EnumerateFrames()
	while frames do
		if not done[frames:GetObjectType()] then
			setAPI(frames)
			done[frames:GetObjectType()] = true
		end

		frames = EnumerateFrames(frames)
	end

	-- textures
	local meta = getmetatable(CreateFrame("Frame"):CreateTexture()).__index
	meta.Kill = Kill
	meta.GetRealPoint = GetPoint 
	meta.SetVisibility = SetVisibility 

	-- fontstrings
	meta = getmetatable(CreateFrame("Frame"):CreateFontString()).__index
	meta.Kill = Kill
	
	done = nil
end
