--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: StatusBars")

-- Lua API
local ipairs, pairs, unpack = ipairs, pairs, unpack

-- WoW API
local CreateFrame = CreateFrame
local GetNumWorldStateUI = GetNumWorldStateUI
local GetWatchedFactionInfo = GetWatchedFactionInfo
local GetWorldStateUIInfo = GetWorldStateUIInfo
local IsSubZonePVPPOI = IsSubZonePVPPOI
local IsXPUserDisabled = IsXPUserDisabled
local UnitLevel = UnitLevel

-- GUIS-gUI environment
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local CreateUIPanel = function(...) return LibStub("gPanel-2.0"):CreateUIPanel(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local RegisterBucketEvent = function(...) return module:RegisterBucketEvent(...) end
local ScheduleTimer = function(...) module:ScheduleTimer(...) end
local gFH = LibStub("gFrameHandler-1.0")

local SetPosition 
local UpdatePanels, UpdateDock
local CreateCaptureBar, UpdateCaptureBar
local PostUpdateWorldState

-- panels
local MAX_DOCKS = 3
local DOCK_WIDTH = 160 -- actual visible width is 6px more, due to outside borders
local dockParent = Minimap -- will make this movable sooner or later
local xpbar, repbar, capturebar = 1, 2, 3 -- position in the dock
local padding, statheight, barheight = 3, 20, 12
local panel, point, CaptureBar = {}, {}, {}

SetPosition = function(frame, position)
	frame:ClearAllPoints()
	for _,p in pairs(point[position]) do
		frame:SetPoint(unpack(p))
	end
end

UpdateDock = function()
	local slot = 1
	for i,p in ipairs(panel) do
		if (p:IsShown()) then
			SetPosition(p, slot)
			slot = slot + 1
		end
	end
end

UpdatePanels = function()
	local RPName, RPStanding, RPMin, RPMax, RPValue = GetWatchedFactionInfo()
	if not(GUIS_DB["status"].showRepBar) or not(RPName) then
		panel[repbar]:Hide()
	else
		panel[repbar]:Show()
	end
	
	-- hotfix for the MoP account level bug in Cata July 25th 2012
	local accountLevel = GetAccountExpansionLevel()
	local maxLevel = accountLevel and MAX_PLAYER_LEVEL_TABLE[accountLevel] or UnitLevel("player") 
	
	if not(GUIS_DB["status"].showXPBar) or (((UnitLevel("player") >= maxLevel) or (IsXPUserDisabled())) and (not GUIS_DB["status"].showXPBarAtMax)) then
		panel[xpbar]:Hide()
	else
		panel[xpbar]:Show()
	end

	UpdateDock()
end

CreateCaptureBar = function(id)
	if (CaptureBar[id]) then 
		return 
	end
	
	local newBar = CreateFrame("Frame", module:GetName() .. "CaptureBar" .. id, panel[capturebar])
	newBar:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	newBar:SetSize(DOCK_WIDTH + 6, barheight + 6) -- room for our 3px border
	newBar:Hide()
	
	-- make it pretty
	newBar:SetUITemplate("simpleblackbackdrop") -- border inside, thus we had to make the frame 6px larger
	newBar.candyLayer = CreateFrame("Frame", nil, newBar)
	newBar.candyLayer:SetPoint("TOPLEFT", 3, -3)
	newBar.candyLayer:SetPoint("BOTTOMRIGHT", -3, 3)
	F.GlossAndShade(newBar.candyLayer)
	
	-- shine effect
	newBar.shine = F.Shine:New(newBar.candyLayer)
	newBar:SetScript("OnShow", function(self) self.shine:Start() end)
	newBar:SetScript("OnHide", function(self) self.shine:Hide() end)
	
	newBar.leftIcon = newBar:CreateTexture(nil, "OVERLAY")
	newBar.leftIcon:SetPoint("RIGHT", newBar, "LEFT", -5, 0)
	newBar.leftIcon:SetTexture(M["Icon"]["WorldState Alliance"])
	newBar.leftIcon:SetSize(24, 24)

	newBar.rightIcon = newBar:CreateTexture(nil, "OVERLAY")
	newBar.rightIcon:SetPoint("LEFT", newBar, "RIGHT", 5, 0)
	newBar.rightIcon:SetTexture(M["Icon"]["WorldState Horde"])
	newBar.rightIcon:SetSize(26, 26)
			
	newBar.middle = newBar:CreateTexture(nil, "OVERLAY")
	newBar.middle:SetDrawLayer("OVERLAY", 0)
	newBar.middle:SetPoint("TOP", newBar, "TOP", 0, -3)
	newBar.middle:SetPoint("BOTTOM", newBar, "BOTTOM", 0, 3)
	newBar.middle:SetTexture(M["StatusBar"]["StatusBar"])
	newBar.middle:SetWidth(0.0001)
	newBar.middle:SetVertexColor(0.9, 0.9, 0.6, 1)

	newBar.left = newBar:CreateTexture(nil, "OVERLAY")
	newBar.left:SetDrawLayer("OVERLAY", 0)
	newBar.left:SetPoint("LEFT", newBar, "LEFT", 3, 0)
	newBar.left:SetPoint("TOP", newBar, "TOP", 0, -3)
	newBar.left:SetPoint("BOTTOM", newBar, "BOTTOM", 0, 3)
	newBar.left:SetPoint("RIGHT", newBar.middle, "LEFT", 0, 0)
	newBar.left:SetTexture(M["StatusBar"]["StatusBar"])
	newBar.left:SetVertexColor(0.0, 0.5, 0.9, 1)
	
	newBar.right = newBar:CreateTexture(nil, "OVERLAY")
	newBar.right:SetDrawLayer("OVERLAY", 0)
	newBar.right:SetPoint("LEFT", newBar.middle, "RIGHT", 0, 0)
	newBar.right:SetPoint("TOP", newBar, "TOP", 0, -3)
	newBar.right:SetPoint("BOTTOM", newBar, "BOTTOM", 0, 3)
	newBar.right:SetPoint("RIGHT", newBar, "RIGHT", -3, 0)
	newBar.right:SetTexture(M["StatusBar"]["StatusBar"])
	newBar.right:SetVertexColor(0.9, 0.1, 0.0, 1)
	
	newBar.indicator = newBar:CreateTexture()
	newBar.indicator:SetDrawLayer("OVERLAY", 7)
	newBar.indicator:SetSize(5, 18)
	newBar.indicator:SetTexture([[Interface\WorldStateFrame\WorldState-CaptureBar]])
	newBar.indicator:SetTexCoord(199/256, 203/256, 0/64, 17/64)
	newBar.indicator:SetPoint("CENTER", newBar, "LEFT", 0, 0)

	newBar.indicatorLeft = newBar:CreateTexture()
	newBar.indicatorLeft:SetDrawLayer("OVERLAY", 6)
	newBar.indicatorLeft:SetSize(8, 15)
	newBar.indicatorLeft:SetTexture([[Interface\WorldStateFrame\WorldState-CaptureBar]])
	newBar.indicatorLeft:SetTexCoord(186/256, 193/256, 9/64, 23/64)
	newBar.indicatorLeft:SetPoint("RIGHT", newBar.indicator, "LEFT", 1, 0)
	
	newBar.indicatorRight = newBar:CreateTexture()
	newBar.indicatorRight:SetDrawLayer("OVERLAY", 6)
	newBar.indicatorRight:SetSize(8, 15)
	newBar.indicatorRight:SetTexture([[Interface\WorldStateFrame\WorldState-CaptureBar]])
	newBar.indicatorRight:SetTexCoord(193/256, 186/256, 9/64, 23/64)
	newBar.indicatorRight:SetPoint("LEFT", newBar.indicator, "RIGHT", -1, 0)
	
	CaptureBar[id] = newBar
	
	return newBar
end

UpdateCaptureBar = function(id, value, neutralPercent)
	if (not CaptureBar[id]) then 
		CaptureBar[id] = CreateCaptureBar(id) 
	end

	local position = CaptureBar[id]:GetWidth()/100 * (100 - value)
	
	if not(CaptureBar[id]:IsShown()) then 
		CaptureBar[id]:Show() 
	end
	
	if not(CaptureBar[id].oldValue) then
		CaptureBar[id].oldValue = position
	end
	
	-- indicator visibility
	if (value < 0.5) or (value > 99.5) then
		CaptureBar[id].indicatorLeft:Hide()
		CaptureBar[id].indicatorRight:Hide()
	
	elseif (position < CaptureBar[id].oldValue) then
		CaptureBar[id].indicatorLeft:Show()
		CaptureBar[id].indicatorRight:Hide()
		
	elseif( position > CaptureBar[id].oldValue) then
		CaptureBar[id].indicatorLeft:Hide()
		CaptureBar[id].indicatorRight:Show()
		
	else
		CaptureBar[id].indicatorLeft:Hide()
		CaptureBar[id].indicatorRight:Hide()
	end
	
	-- color the border according to control
	if ( value > (50 + neutralPercent/2) ) then
		if (CaptureBar[id].status ~= "Alliance") then
			CaptureBar[id]:SetBackdropColor(0.0, 0.5 * 2/5, 0.9* 2/5, 1) -- Alliance
			CaptureBar[id]:SetBackdropBorderColor(0.0, 0.5 * 3/5, 0.9* 3/5, 1) 
			CaptureBar[id].status = "Alliance"
			CaptureBar[id].shine:Start()
		end
		
	elseif ( value < (50 - neutralPercent/2) ) then
		if (CaptureBar[id].status ~= "Horde") then
			CaptureBar[id]:SetBackdropColor(0.9 * 2/5, 0.1 * 2/5, 0.0, 1) -- Horde
			CaptureBar[id]:SetBackdropBorderColor(0.9 * 3/5, 0.1 * 3/5, 0.0, 1) 
			CaptureBar[id].status = "Horde"
			CaptureBar[id].shine:Start()
		end
		
	else
		if (CaptureBar[id].status ~= "Neutral") then
			CaptureBar[id]:SetBackdropColor(unpack(C["background"])) -- Neutral
			CaptureBar[id]:SetBackdropBorderColor(unpack(C["border"])) 
			CaptureBar[id].status = "Neutral"
			CaptureBar[id].shine:Start()
		end
	end
	
	CaptureBar[id].middle:SetWidth(CaptureBar[id]:GetWidth()/100 * (neutralPercent == 0 and 0.0001 or neutralPercent))
	CaptureBar[id].oldvalue = position
	CaptureBar[id].indicator:ClearAllPoints()
	CaptureBar[id].indicator:SetPoint("CENTER", CaptureBar[id], "LEFT", position, 0)
end

PostUpdateWorldState = function()
	local extendedUIShown = 1
	for i = 1, GetNumWorldStateUI() do
		local uiType, state, hidden, text, icon, dynamicIcon, tooltip, dynamicTooltip, extendedUI, extendedUIState1, extendedUIState2, extendedUIState3 = GetWorldStateUIInfo(i)

		if ( (not hidden) and ((uiType ~= 1) or ((WORLD_PVP_OBJECTIVES_DISPLAY == "1") or (WORLD_PVP_OBJECTIVES_DISPLAY == "2" and IsSubZonePVPPOI()) or (instanceType == "pvp"))) ) and ( state > 0 ) and ( extendedUI == "CAPTUREPOINT" ) then

			UpdateCaptureBar(extendedUIShown, extendedUIState1, extendedUIState2, extendedUIState3)
			extendedUIShown = extendedUIShown + 1
		end
	end

	local f
	for i = 1, NUM_EXTENDED_UI_FRAMES do
		f = _G[("WorldStateCaptureBar%d"):format(i)]

		if (f) then 
			if f:IsShown() then
				f:SetScale(0.0001)

				if (not CaptureBar[i]) then 
					CaptureBar[i] = CreateCaptureBar(i) 
				end
				
				CaptureBar[i]:ClearAllPoints()
				
				if (i == 1) then
					CaptureBar[i]:SetPoint("TOP", panel[capturebar], "TOP", 0, 0)
				else
					CaptureBar[i]:SetPoint("TOP", CaptureBar[i], "BOTTOM", 0, -4)
				end
			else
				if CaptureBar[i] then
					CaptureBar[i]:Hide()
				end
			end
		end
	end

	if #CaptureBar > NUM_EXTENDED_UI_FRAMES then
		for i = NUM_EXTENDED_UI_FRAMES + 1, #CaptureBar do
			if (CaptureBar[i]) then
				CaptureBar[i]:Hide()
			end
		end
	end
end

module.UpdateAll = function(self)
	PostUpdateWorldState()
	UpdatePanels()
end

module.OnInit = function(self)
	if F.kill("GUIS-gUI: Status") then 
		self:Kill() 
		return 
	end
	
	local padding, border = 4, 3
	
	local Dock = CreateFrame("Frame", self:GetName() .. "_Dock", dockParent)
	Dock:SetSize(DOCK_WIDTH + border*2, (barheight + border*2)*MAX_DOCKS + padding*(MAX_DOCKS-1))
	Dock:PlaceAndSave("TOP", dockParent, "BOTTOM", 0, -(border + padding))

	-- our docking positions
	for i = 1, MAX_DOCKS do
		point[i] = {
			{ "LEFT", Dock, "LEFT", border, 0 };
			{ "RIGHT", Dock, "RIGHT", -border, 0 };
			{ "TOP", Dock, "TOP", 0, -(border + ((i-1)*(padding + barheight + border*2))) };
		}
	end

	-- add panels
	panel[xpbar] = CreateUIPanel()
	panel[xpbar]:SetUITemplate("blackbackdrop")
	panel[xpbar]:ClearAllPoints()
	panel[xpbar]:SetHeight(barheight)
	panel[xpbar]:SpawnPlugin("Experience", "FULL")

	panel[repbar] = CreateUIPanel()
	panel[repbar]:SetUITemplate("blackbackdrop")
	panel[repbar]:ClearAllPoints()
	panel[repbar]:SetHeight(barheight)
	panel[repbar]:SpawnPlugin("Reputation", "FULL")

	-- we're not adding the backdrop directly here, 
	-- since there can be more than one capturebar. In theory.
	panel[capturebar] = CreateUIPanel()
	panel[capturebar]:ClearAllPoints()
	panel[capturebar]:SetHeight(barheight)

	hooksecurefunc("WorldStateAlwaysUpFrame_Update", PostUpdateWorldState)

	RegisterCallback("PLAYER_ENTERING_WORLD", PostUpdateWorldState)
	RegisterBucketEvent({
		"PLAYER_ALIVE";
		"PLAYER_ENTERING_WORLD";
		"PLAYER_LEVEL_UP";
		"PLAYER_XP_UPDATE";
		"PLAYER_FLAGS_CHANGED";
		"DISABLE_XP_GAIN";
		"ENABLE_XP_GAIN";
		"UPDATE_FACTION";
	}, 0.1, UpdatePanels)

end
