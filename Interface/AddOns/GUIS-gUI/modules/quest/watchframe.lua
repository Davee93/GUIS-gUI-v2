--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: QuestWatchFrame")

-- Lua API
local format = string.format
local pairs, unpack = pairs, unpack

local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local gFH = LibStub("gFrameHandler-1.0")
local StyleActionButton = function(...) LibStub("gActionButtons-2.0").StyleActionButton(...) end

local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local ScheduleTimer = function(...) module:ScheduleTimer(...) end

-- taint forever
local queue = {}

local currentAlign = "RIGHT"
local doAlign = function(self, ...)
	self = self or _G["ObjectivesTracker"]
	
	-- avoid stack overflow
	if (self.aligning) then 
		return 
	else
		self.aligning = true
	end
	
	if (GUIS_DB["quest"].autoAlignWatchFrame) then
		local w, r, l = GetScreenWidth(), self:GetRight() or 0, self:GetLeft() or 0
		if ((w - r) < l) then
			currentAlign = "RIGHT"
		else
			currentAlign = "LEFT"
		end
	else
		if (GUIS_DB["quest"].rightAlignWatchFrame) then
			currentAlign = "RIGHT"
		else
			currentAlign = "LEFT"
		end
	end
	
	if (currentAlign == "RIGHT") then
		WatchFrameTitle:SetJustifyH(currentAlign)
		WatchFrameTitle:ClearAllPoints()
		WatchFrameTitle:SetPoint(currentAlign, WatchFrameHeader, currentAlign, 0, 0)

		WatchFrameHeader:ClearAllPoints()
		WatchFrameHeader:SetPoint("BOTTOMRIGHT", WatchFrameLines, "TOPRIGHT", -16, 8)

		WatchFrameCollapseExpandButton:ClearAllPoints()
		WatchFrameCollapseExpandButton:SetPoint("LEFT", WatchFrameHeader, "RIGHT", 8, 0)
		
	elseif (currentAlign == "LEFT") then
		WatchFrameTitle:SetJustifyH(currentAlign)
		WatchFrameTitle:ClearAllPoints()
		WatchFrameTitle:SetPoint(currentAlign, WatchFrameHeader, currentAlign, 0, 0)

		WatchFrameHeader:ClearAllPoints()
		WatchFrameHeader:SetPoint("BOTTOMLEFT", WatchFrameLines, "TOPLEFT", 0, 8)
		
		WatchFrameCollapseExpandButton:ClearAllPoints()
		WatchFrameCollapseExpandButton:SetPoint("RIGHT", WatchFrameHeader, "LEFT", -8, 0)
	end
	
	WatchFrame_Update(WatchFrame)
	
	self.aligning = nil
end

local AlignMe = function(self, ...) 
	if not(InCombatLockdown()) then
		doAlign(self, ...)
	else
		tinsert(queue, { doAlign, self, ... })
	end
end

local bossExists = function()
	for i = 1, MAX_BOSS_FRAMES do
		if (UnitExists("boss" .. i)) then
			return true
		end
	end
end

local updateWatchFrameCollapseExpand = function()
	if not(GUIS_DB["quest"].autoCollapseWatchFrame) then return end
	
--	if (GUIS_DB["quest"].autoCollapseOnBoss) then
		if (bossExists()) then
			if not(WatchFrame.collapsed) then
				WatchFrame.expandLater = true
				WatchFrame_CollapseExpandButton_OnClick(WatchFrame_CollapseExpandButton)
				
				return
			end
			
		elseif (WatchFrame.collapsed) and (WatchFrame.expandLater) then
			WatchFrame.expandLater = nil
			WatchFrame_CollapseExpandButton_OnClick(WatchFrame_CollapseExpandButton)
			
			return
		end
--	end
end

local expanded, normal = 350, 250
local doWatchWidth = function(self, event, cvar)
	local update = nil
	if (event == "PLAYER_ENTERING_WORLD") then
		update = true
	elseif (event == "CVAR_UPDATE") then
		if (cvar == "WATCH_FRAME_WIDTH_TEXT") then
			if not(WatchFrame.userCollapsed) then
				update = true
			end
		end
	elseif not(event) then
		if not(WatchFrame.userCollapsed) then
			update = true
		end
	end
	
	if (update) then
		local width = tonumber(GetCVar("watchFrameWidth"))
		
		if (width == 0) then
			_G["ObjectivesTracker"]:SetSize(normal, GetScreenHeight() - 470)
			
		elseif (width == 1) then
			_G["ObjectivesTracker"]:SetSize(expanded, GetScreenHeight() - 470)
		end
	end
end

local updateWatchFrameWidth = function(self, ...)
	if not(InCombatLockdown()) then
		doWatchWidth(self, ...)
	else
		tinsert(queue, { doWatchWidth, self, ... })
	end

end

local doLinkButton = function()
	for i = 1, #WATCHFRAME_LINKBUTTONS do
		local button = WATCHFRAME_LINKBUTTONS[i]
		if (button) then
			local _, parent = button:GetPoint()
			button:SetAllPoints(parent)
		end
	end
end

local styleLinkButtons = function()
	if not(InCombatLockdown()) then
		doLinkButton()
	else
		tinsert(queue, { doLinkButton })
	end
end

local doWatchFrameLine = function(self, anchor, verticalOffset, isHeader, text, dash, hasItem, isComplete, eligible)
	-- this object might have been queued multiple times, and no longer existing
	if not(self) then
		return
	end

	local icon = _G[self:GetName() .. "Icon"]
	
	self.dash:SetSize(1/1e4, 1/1e4)
	
	self.text:SetJustifyV("TOP")
	self.text:SetJustifyH(currentAlign)
	self.text:SetIndentedWordWrap(false)
	self.text:SetNonSpaceWrap(false)
	self.text:SetWordWrap(true)
	self.text:ClearAllPoints()
	self.text:SetPoint("TOP", self, "TOP", 0, 0)
	self.text:SetPoint("RIGHT", self, "RIGHT", -16, 0)
	self.text:SetPoint("LEFT", self, "LEFT", 0, 0)
	self.text:SetFontObject(GUIS_SystemFontNormal)
	self.text:SetWidth(WatchFrame:GetRight() - WatchFrame:GetLeft())

	if (self.text:GetHeight() > WATCHFRAME_LINEHEIGHT) then
		if (isComplete) then
			self:SetHeight(self.text:GetHeight() + 4)
		else
			self:SetHeight(WATCHFRAME_MULTIPLE_LINEHEIGHT)
			self.text:SetHeight(WATCHFRAME_MULTIPLE_LINEHEIGHT)
		end
	end

	if (currentAlign == "RIGHT") then
		F.properRightAlign(self.text, WatchFrame:GetRight() - WatchFrame:GetLeft(), self:GetHeight())
	end

	self:ClearAllPoints()
	self:SetPoint("RIGHT", WatchFrameLines, "RIGHT", 0, 0)
	self:SetPoint("LEFT", WatchFrameLines, "LEFT", 0, 0)

	if (anchor) then
		self:SetPoint("RIGHT", anchor, "RIGHT", 0, 0);
		self:SetPoint("LEFT", anchor, "LEFT", 0, 0);
		self:SetPoint("TOP", anchor, "BOTTOM", 0, verticalOffset);
	end

	if (self.text:GetHeight() > WATCHFRAME_LINEHEIGHT) then
		if (isComplete) then
			self:SetHeight(self.text:GetHeight() + 4)
		else
			self:SetHeight(self.text:GetHeight())
		end
	end
end

local styleWatchFrameLine = function(self, ...)
	if not(InCombatLockdown()) then
		doWatchFrameLine(self, ...)
	else
		tinsert(queue, { doWatchFrameLine, self, ... })
	end
end

local getX = function()
	local MicroMenu = _G["GUIS-gUI: ActionBarsMicroMenuFrame"]
	
	return (((MicroMenu) and (MicroMenu:IsVisible())) and 28 or 0) + ((MultiBarLeftButton1:IsVisible() and (GUIS_DB["actionbars"].buttonSize + 2) or 0) + (MultiBarRightButton1:IsVisible() and (GUIS_DB["actionbars"].buttonSize * 2 + 4) or 0))
end

local doPosition = function()
	-- move it, it is not userplaced yet
	if not(_G["ObjectivesTracker"]:HasMoved()) then
		-- position it
		_G["ObjectivesTracker"]:ClearAllPoints()
		_G["ObjectivesTracker"]:SetPoint("TOPRIGHT", "UIParent", "TOPRIGHT", -(8 + getX()), -290)
	end

	-- update the default position
	_G["ObjectivesTracker"]:RegisterForSave("TOPRIGHT", "UIParent", "TOPRIGHT", -(8 + getX()), -290)
end

local updatePosition = function(self, event, bar, show)
	if not(_G["ObjectivesTracker"]) 
	or ((event == "GUIS_ACTIONBAR_VISIBILITY_UPDATE") and ((bar ~= 4) and (bar ~= 5))) 
	or ((event == "GUIS_ACTIONBAR_BUTTON_UPDATE") and ((bar ~= 4) and (bar ~= 5))) 
	or ((event == "GUIS_ACTIONBAR_POSITION_UPDATE") and ((bar ~= 4) and (bar ~= 5))) then
		return
	end
	
	if not(InCombatLockdown()) then
		doPosition()
	else
		tinsert(queue, { doPosition })
	end
end

-- parse through functions that couldn't be called while in combat
local parseQueue = function()
	for i,v in pairs(queue) do
		if (InCombatLockdown()) then
			return
		end
		queue[i][1](select(2, queue[i]))
		queue[i] = nil
	end
end

module.UpdateAll = function(self)
	AlignMe(_G["ObjectivesTracker"])
	updateWatchFrameWidth()
	updateWatchFrameCollapseExpand()
end

module.OnInit = function(self)
	if F.kill("GUIS-gUI: Quest") then
		self:Kill()
		return
	end

	_G["ObjectivesTracker"] = CreateFrame("Frame", "ObjectivesTracker", UIParent)
	_G["ObjectivesTracker"]:SetSize(250, 400)
	_G["ObjectivesTracker"]:SetClampedToScreen(true)
	_G["ObjectivesTracker"]:PlaceAndSave("TOPRIGHT", "UIParent", "TOPRIGHT", -(8 + getX()), -290)
	
	-- initial position and size updates, just in case
	updatePosition()
	updateWatchFrameWidth()

	-- historical moment; our first use of custom gUI events! yay!
	-- (and it actually worked on the first try, which is... unusual for me)
	RegisterCallback("GUIS_ACTIONBAR_VISIBILITY_UPDATE", updatePosition)
	RegisterCallback("GUIS_ACTIONBAR_BUTTON_UPDATE", updatePosition)
	RegisterCallback("GUIS_ACTIONBAR_POSITION_UPDATE", updatePosition)
	RegisterCallback("GUIS_MICROMENU_SHOW", updatePosition)
	RegisterCallback("GUIS_MICROMENU_HIDE", updatePosition)
	RegisterCallback("PLAYER_ENTERING_WORLD", updatePosition)

	WatchFrame:SetParent(_G["ObjectivesTracker"]) 
	WatchFrame:SetClampedToScreen(true)
	WatchFrame:SetFrameStrata("BACKGROUND")
	WatchFrame:ClearAllPoints()
	WatchFrame:SetPoint("TOPLEFT", _G["ObjectivesTracker"], 32, -2.5)
	WatchFrame:SetPoint("BOTTOMRIGHT", _G["ObjectivesTracker"], 4,0)
	WatchFrame.ClearAllPoints = noop
	WatchFrame.SetAllPoints = noop
	WatchFrame.SetPoint = noop

	WatchFrameTitle:SetFontObject(GUIS_SystemFontSmall)
	WatchFrameTitle:SetJustifyH("RIGHT")

	WatchFrameTitle:ClearAllPoints()
	WatchFrameTitle:SetPoint("RIGHT", WatchFrameHeader, "RIGHT", 0, 0)

	WatchFrameHeader:ClearAllPoints()
	WatchFrameHeader:SetPoint("RIGHT", WatchFrameCollapseExpandButton, "LEFT", -8, 0)
	
	hooksecurefunc(_G["ObjectivesTracker"], "SetPoint", AlignMe)
	hooksecurefunc(_G["ObjectivesTracker"], "SetAllPoints", AlignMe)
	hooksecurefunc(_G["ObjectivesTracker"], "ClearAllPoints", AlignMe)

--	WatchFrameTitle.BlizzardShow = WatchFrameTitle.Show
--	WatchFrameTitle.Show = noop
--	WatchFrameTitle:Hide()
	
	hooksecurefunc("WatchFrame_SetLine", styleWatchFrameLine)

	hooksecurefunc("WatchFrame_DisplayTrackedAchievements", styleLinkButtons)
	hooksecurefunc("WatchFrame_DisplayTrackedQuests", styleLinkButtons)

	RegisterCallback("PLAYER_ENTERING_WORLD", function(self, event, ...) AlignMe(_G["ObjectivesTracker"], event, ...) end)
	RegisterCallback("QUEST_LOG_UPDATE", function(self, event, ...) AlignMe(_G["ObjectivesTracker"], event, ...) end)

	RegisterCallback("INSTANCE_ENCOUNTER_ENGAGE_UNIT", updateWatchFrameCollapseExpand)
	RegisterCallback("PLAYER_ENTERING_WORLD", updateWatchFrameCollapseExpand)
	RegisterCallback("PLAYER_REGEN_ENABLED", updateWatchFrameCollapseExpand)
	RegisterCallback("UNIT_TARGETABLE_CHANGED", updateWatchFrameCollapseExpand)

	RegisterCallback("CVAR_UPDATE", updateWatchFrameWidth)
	RegisterCallback("PLAYER_ENTERING_WORLD", updateWatchFrameWidth)
	
	-- neverending war against the taint
	RegisterCallback("PLAYER_REGEN_ENABLED", parseQueue)

end
