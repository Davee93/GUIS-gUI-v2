--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local oUF = ns.oUF or oUF 

if not(oUF) then
	return
end

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UnitFramesPanel")

-- Lua API
local unpack, select, tinsert = unpack, select, table.insert

-- WoW API
local UnitClass = UnitClass

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local R = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: UnitFrameAuras")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) module:RegisterCallback(...) end
local RegisterBucketEvent = function(...) module:RegisterBucketEvent(...) end

local arrow, direction, panel
local fixPanelStrata, fixArrowTexture

local _, playerClass = UnitClass("player")

--
-- Pre-hooking the SetFrameStrata function to make sure they stay in place
fixPanelStrata = function()
	if not(panel.BlizzSetFrameStrata) then
		panel.BlizzSetFrameStrata = panel.SetFrameStrata
		panel.SetFrameStrata = function(self, strata) 
			self:BlizzSetFrameStrata("LOW")
		end

		panel:SetFrameStrata()
	end
	
	--[[
	for _,p in pairs(panel) do
		if not p.BlizzSetFrameStrata then
			p.BlizzSetFrameStrata = p.SetFrameStrata
			p.SetFrameStrata = function(self, strata) 
				self:BlizzSetFrameStrata("LOW")
			end

			p:SetFrameStrata()
		end
	end
	]]--
end

-- 
-- change the arrow texture based on its on-screen position:
-- R = right arrow, L = left arrow, D = down arrow, U = up arrow
-- RDL
-- RUL
-- 
fixArrowTexture = function()
	local a, b, c, d, e = arrow:GetPoint()
	local x = arrow:GetLeft() + arrow:GetWidth()/2
	local y = arrow:GetBottom() + arrow:GetHeight()/2
	
	local w, h = GetScreenWidth()/3, GetScreenHeight()/2
	
	-- center
	if (x > w) and (x < (w*2)) then
		-- top
		if (y > h) then
			direction = "Down"
			
		-- bottom
		else
			direction = "Up"
		end
		
	-- left
	elseif (x < w) then
		direction = "Right"
		
	-- right
	else 
		direction = "Left"
	end
	
	arrow:SetNormalTexture(M["Icon"][("Arrow%s"):format(direction)])
	arrow:SetHighlightTexture(M["Icon"][("Arrow%sHighlight"):format(direction)])
	arrow:SetPushedTexture(M["Icon"][("Arrow%sHighlight"):format(direction)])
end

module.GetPanel = function()
	return panel
end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UnitFrames")) then 
		self:Kill()
		return 
	end
	
	--[[
--	direction = "Down"

	-- clickable arrow only visible on mouseover
	arrow = CreateFrame("Button", self:GetName() .. "ArrowButton", UIParent)
	arrow:SetAlpha(0)
	arrow:SetPoint("TOP", -8, 0)
	arrow:SetSize(32, 32)
--	arrow:SetNormalTexture(M["Icon"]["Arrow%s64"]:format(direction))
--	arrow:SetHighlightTexture(M["Icon"]["Arrow%sHighlight64"]:format(direction))
--	arrow:SetPushedTexture(M["Icon"]["Arrow%sHighlight64"]:format(direction))
	arrow:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
	arrow:SetScript("OnLeave", function(self) 
		-- keep the arrow visible as long as the panel is visible, 
		-- we might need it to close the panel
		if not(panel:IsShown()) then
			self:SetAlpha(0) 
		end
	end)
	arrow:SetScript("OnClick", function() 
		if (panel:IsShown()) then
			panel:Hide()
		else
			panel:Show()
		end
	end)
	
	hooksecurefunc(arrow, "SetAlpha", fixArrowTexture)
--	arrow:SetScript("OnShow", function() fixArrowTexture() end)
	
	-- create our panel
	local w, h = 600, 40
	panel = CreateFrame("Frame", self:GetName() .. "UserPanel", arrow)
	panel:Hide()
	panel:SetUITemplate("simplebackdrop")
	panel:ClearAllPoints()
	panel:SetPoint("TOP", arrow, "BOTTOM", -8, 0)
	panel:SetScript("OnShow", function() 
		-- make the arrow visible if the panel was shown from an external source
		if not(arrow:GetAlpha() == 1) then
			arrow:SetAlpha(1)
		end
	end)
	panel:SetScript("OnHide", function() 
		-- hide the arrow if you're not hovering above it
		if not(arrow:IsMouseOver()) and (arrow:GetAlpha() == 1) then
			arrow:SetAlpha(0)
		end
	end)
	
	-- party options
	
	-- raid options
	
	-- general options
	
	
	-- move the world raid marker menu here
	
	-- raid icons
	
	
	panel:SetSize(w, h)
	
	
	-- make the panel closable with the Esc key
	tinsert(UISpecialFrames, panel:GetName())
	
	RegisterCallback("PLAYER_ENTERING_WORLD", fixPanelStrata)
	
	]]--
end
