--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningPvP")

-- Lua API
local pairs, select, unpack = pairs, select, unpack

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UISkinning")) or not(GUIS_DB["skinning"][self:GetName()]) then 
		self:Kill() 
		return 
	end
	
	local panelAlpha, r, g, b = 1/5, unpack(C["overlay"])
	
	PVPHonorFrameBGTex:RemoveTextures()
	PVPHonorFrameInfoScrollFrameScrollBar:RemoveTextures()
	PVPConquestFrameInfoButtonInfoBG:RemoveTextures()
	PVPConquestFrameInfoButtonInfoBGOff:RemoveTextures()
	PVPTeamManagementFrameFlag2GlowBG:RemoveTextures()
	PVPTeamManagementFrameFlag3GlowBG:RemoveTextures()
	PVPTeamManagementFrameFlag5GlowBG:RemoveTextures()
	PVPTeamManagementFrameFlag2HeaderSelected:RemoveTextures()
	PVPTeamManagementFrameFlag3HeaderSelected:RemoveTextures()
	PVPTeamManagementFrameFlag5HeaderSelected:RemoveTextures()
	PVPTeamManagementFrameFlag2Header:RemoveTextures()
	PVPTeamManagementFrameFlag3Header:RemoveTextures()
	PVPTeamManagementFrameFlag5Header:RemoveTextures()
	PVPTeamManagementFrameWeeklyDisplayLeft:RemoveTextures()
	PVPTeamManagementFrameWeeklyDisplayRight:RemoveTextures()
	PVPTeamManagementFrameWeeklyDisplayMiddle:RemoveTextures()
	PVPBannerFramePortrait:RemoveTextures()
	PVPBannerFramePortraitFrame:RemoveTextures()
	PVPBannerFrameInset:RemoveTextures()
	PVPBannerFrameEditBoxLeft:RemoveTextures()
	PVPBannerFrameEditBoxRight:RemoveTextures()
	PVPBannerFrameEditBoxMiddle:RemoveTextures()
	PVPBannerFrameCancelButton_LeftSeparator:RemoveTextures()
	PVPFrame:RemoveTextures()
	PVPFrameInset:RemoveTextures()
	PVPHonorFrame:RemoveTextures(true)
	PVPConquestFrame:RemoveTextures()
	PVPTeamManagementFrame:RemoveTextures()
	PVPHonorFrameTypeScrollFrame:RemoveTextures()
	PVPFrameTopInset:RemoveTextures()
	PVPTeamManagementFrameInvalidTeamFrame:RemoveTextures()
	PVPBannerFrame:RemoveTextures()
	PVPBannerFrameCustomization1:RemoveTextures()
	PVPBannerFrameCustomization2:RemoveTextures()
	PVPBannerFrameCustomizationFrame:RemoveTextures()
	PVPTeamManagementFrameHeader1:RemoveTextures()
	PVPTeamManagementFrameHeader2:RemoveTextures()
	PVPTeamManagementFrameHeader3:RemoveTextures()
	PVPTeamManagementFrameHeader4:RemoveTextures()
	if (PVPFrameConquestBarShadow) then PVPFrameConquestBarShadow:RemoveTextures() end
	PVPFrameConquestBarBG:RemoveTextures()
	if (PVPFrameConquestBarLeft) then PVPFrameConquestBarLeft:RemoveTextures() end
	if (PVPFrameConquestBarMiddle) then PVPFrameConquestBarMiddle:RemoveTextures() end
	if (PVPFrameConquestBarRight) then PVPFrameConquestBarRight:RemoveTextures() end
	if (PVPFrameConquestBarDivider1) then PVPFrameConquestBarDivider1:RemoveTextures() end 
	if (PVPFrameConquestBarDivider2) then PVPFrameConquestBarDivider2:RemoveTextures() end 
	if (PVPFrameConquestBarDivider3) then PVPFrameConquestBarDivider3:RemoveTextures() end
	if (PVPFrameConquestBarDivider4) then PVPFrameConquestBarDivider4:RemoveTextures() end 
	if (WarGamesFrame) then WarGamesFrame:RemoveTextures() end
	if (WarGamesFrameInfoScrollFrameScrollBar) then WarGamesFrameInfoScrollFrameScrollBar:RemoveTextures() end

	PVPBannerFrameCustomization1LeftButton:SetUITemplate("arrow", "left")
	PVPBannerFrameCustomization1RightButton:SetUITemplate("arrow", "right")
	PVPBannerFrameCustomization2LeftButton:SetUITemplate("arrow", "left")
	PVPBannerFrameCustomization2RightButton:SetUITemplate("arrow", "right")
	PVPTeamManagementFrameWeeklyToggleLeft:SetUITemplate("arrow", "left")
	PVPTeamManagementFrameWeeklyToggleRight:SetUITemplate("arrow", "right")

	if (WarGameStartButton) then WarGameStartButton:SetUITemplate("button", true) end
	PVPFrameLeftButton:SetUITemplate("button", true)
	PVPFrameRightButton:SetUITemplate("button", true)
	PVPColorPickerButton1:SetUITemplate("button", true)
	PVPColorPickerButton2:SetUITemplate("button", true)
	PVPColorPickerButton3:SetUITemplate("button", true)
	PVPBannerFrameAcceptButton:SetUITemplate("button", true)

	PVPFrameCloseButton:SetUITemplate("closebutton")
	PVPBannerFrameCloseButton:SetUITemplate("closebutton")
	
	PVPBannerFrameEditBox:SetUITemplate("editbox")
	
	PVPTeamManagementFrameInvalidTeamFrame:SetUITemplate("simplebackdrop")
	PVPBannerFrame:SetUITemplate("simplebackdrop") -- :SetBackdropColor(r, g, b, panelAlpha)
	PVPBannerFrameCustomization1:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	PVPBannerFrameCustomization2:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)
	PVPFrame:SetUITemplate("simplebackdrop")
	
	PVPConquestFrame:SetUITemplate("backdrop", nil, 0, 0, 3, -2):SetBackdropColor(r, g, b, panelAlpha)
	--PVPFrameConquestBar:SetUITemplate("backdrop", nil, 0, 0, 0, 0)
	
	PVPHonorFrameInfoScrollFrame:SetUITemplate("backdrop", nil, 0, 0, 3, 0):SetBackdropColor(r, g, b, panelAlpha)
	if (WarGamesFrameScrollFrame) then WarGamesFrameScrollFrame:SetUITemplate("backdrop", nil, 0, 2, -2, 3):SetBackdropColor(r, g, b, panelAlpha) end
	if (WarGamesFrameInfoScrollFrame) then WarGamesFrameInfoScrollFrame:SetUITemplate("backdrop", nil, 3, 0, 3, 0):SetBackdropColor(r, g, b, panelAlpha) end
	if (WarGamesFrameScrollFrameScrollBar) then WarGamesFrameScrollFrameScrollBar:SetUITemplate("scrollbar") end
	if (WarGamesFrameInfoScrollFrameScrollBar) then WarGamesFrameInfoScrollFrameScrollBar:SetUITemplate("scrollbar") end

	PVPHonorFrameInfoScrollFrameScrollBar:SetUITemplate("scrollbar")
	PVPHonorFrameTypeScrollFrameScrollBar:SetUITemplate("scrollbar")
		
	PVPFrameTab1:SetUITemplate("tab")
	PVPFrameTab2:SetUITemplate("tab")
	PVPFrameTab3:SetUITemplate("tab")
	if (PVPFrameTab4) then PVPFrameTab4:SetUITemplate("tab") end

	PVPFrameConquestBar:SetPoint("TOP", 0, -40)
	PVPFrameConquestBar:SetHeight(14)

	if (PVPFrameConquestBar) and (PVPFrameConquestBar.progress) then PVPFrameConquestBar.progress:SetTexture(M["StatusBar"]["StatusBar"]) end
	if (PVPFrameConquestBarCap1) then PVPFrameConquestBarCap1:SetTexture(M["StatusBar"]["StatusBar"]) end
	if (PVPFrameConquestBarCap2) then PVPFrameConquestBarCap2:SetTexture(M["StatusBar"]["StatusBar"]) end
	if (PVPFrameConquestBarLabel) then PVPFrameConquestBarLabel:SetPoint("BOTTOM", PVPFrameConquestBar, "TOP", 0, 4) end
	if (PVPFrameConquestBarLabel) then PVPFrameConquestBarLabel:SetFontObject(GUIS_SystemFontNormal) end
	if (PVPFrameConquestBarText) then PVPFrameConquestBarText:SetFontObject(GUIS_NumberFontNormal) end
	if (PVPFrameConquestBarText) then PVPFrameConquestBarText:ClearAllPoints() end
	if (PVPFrameConquestBarText) then PVPFrameConquestBarText:SetPoint("CENTER") end
	if (PVPFrameConquestBarCap1Marker) then PVPFrameConquestBarCap1Marker:RemoveTextures() end
	if (PVPFrameConquestBarCap2Marker) then PVPFrameConquestBarCap2Marker:RemoveTextures() end
	
	PVPFrameConquestBar.backdrop = PVPFrameConquestBar:SetUITemplate("backdrop")
	PVPFrameConquestBar.eyeCandy = CreateFrame("Frame", nil, PVPFrameConquestBar.backdrop)
	PVPFrameConquestBar.eyeCandy:SetPoint("TOPLEFT", PVPFrameConquestBar.backdrop, 3, -3)
	PVPFrameConquestBar.eyeCandy:SetPoint("BOTTOMRIGHT", PVPFrameConquestBar.backdrop, -3, 3)
	F.GlossAndShade(PVPFrameConquestBar.eyeCandy)
	
	PVPHonorFrameInfoScrollFrameChildFrameDescription:SetTextColor(unpack(C["index"]))
	PVPHonorFrameInfoScrollFrameChildFrameRewardsInfo.description:SetTextColor(unpack(C["index"]))
	if (WarGamesFrameDescription) then WarGamesFrameDescription:SetTextColor(unpack(C["index"])) end
end
