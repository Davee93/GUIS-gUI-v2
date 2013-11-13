--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: Font")

local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) return module:RegisterCallback(...) end

local SetFont, SetGUISFonts, SetBlizzFonts

-- for developing purposes only
local gameLocale = GAME_LOCALE or GetLocale()

local localizedFonts = {
	["ruRU"] = {
		text 	= M["Font"]["Arial Narrow"];
		number 	= M["Font"]["Matthan Sans NC"]; --M["Font"]["Arial Narrow"];
		damage 	= M["Font"]["Arial Narrow"];	
	};
	["koKR"] = {
		text 	= M["Font"]["Number"];
		number 	= M["Font"]["Number"];	
		damage 	= M["Font"]["Number"];	
	};
	["zhCN"] = {
		text 	= M["Font"]["Text"];	
		number 	= M["Font"]["Text"];	
		damage 	= M["Font"]["Text"];
	};
	["zhTW"] = {
		text 	= M["Font"]["Text"];	
		number 	= M["Font"]["Text"];	
		damage 	= M["Font"]["Text"];	
	};
}

--
-- custom fontobjects to be changed
--
-- in time these will replace all the Blizzard font objects, 
-- thus allowing us to implement a font changer that only affects our own fonts,
-- leaving other addons free to use the Blizzard fonts as they please
-- without our changes affecting them. On my TODO list.
local GUISFonts = {
	text = {
		GUIS_PanelFont;
		GUIS_SystemFontNormal;
		GUIS_SystemFontDisabled;
		GUIS_SystemFontHighlight;
		GUIS_SystemFontNormalWhite;
		GUIS_SystemFontSmall;
		GUIS_SystemFontSmallDisabled;
		GUIS_SystemFontSmallHighlight;
		GUIS_SystemFontTiny;
		GUIS_SystemFontTinyWhite;
		GUIS_SystemFontLarge;
		GUIS_SystemFontVeryLarge;
		GUIS_TooltipFontNormal;
		GUIS_TooltipFontTitle;
		GUIS_TooltipFontSmall;
		GUIS_TooltipFontSmallWhite;
		GUIS_ChatFontNormal;
		GUIS_ChatFontNormalSmall;
	};
	number = {
		GUIS_ItemButtonHotKeyFont;
		GUIS_ItemButtonNameFont;
		GUIS_ItemButtonNameFontMedium;
		GUIS_NumberFontNormal;
		GUIS_NumberFontNormalRight;
		GUIS_NumberFontNormalYellow;
		GUIS_NumberFontSmall;
		GUIS_NumberFontSmallYellow;
		GUIS_NumberFontTiny;
		GUIS_NumberFontLarge;
		GUIS_NumberFontHuge;
	};
	damage = {
		GUIS_CombatTextFont;
	};
	unitframes = {
		GUIS_UnitFrameNameNormal;
		GUIS_UnitFrameNameTiny;
		GUIS_UnitFrameNameSmall;
		GUIS_UnitFrameNameHuge;
		GUIS_UnitFrameNumberNormal;
		GUIS_UnitFrameNumberTiny;
		GUIS_UnitFrameNumberSmall;
		GUIS_UnitFrameNumberHuge;
	};
}

SetFont = function(fontObject, font, size, style, shadowX, shadowY)
	if (not fontObject) then return end
	
	local oldFont, oldSize, oldStyle = fontObject:GetFont()
	local oldShadowX, oldShadowY = fontObject:GetShadowOffset()

	-- no update needed
	if (oldFont == font) and (oldSize == size) and (oldStyle == style) then
		return
	end

	fontObject:SetFont(font or oldFont, size or oldSize, style or oldStyle)
	fontObject:SetShadowOffset(shadowX or oldShadowX or 0, shadowY or oldShadowY or 0)
	fontObject:SetShadowColor(0, 0, 0, 1)
end

-- change the custom gUI fonts if a non-latin locale is used
SetGUISFonts = function()
	if not(localizedFonts[gameLocale]) then
		return
	end
	
	for _,fontObject in pairs(GUISFonts.text) do
		SetFont(fontObject, localizedFonts[gameLocale].text)
	end

	for _,fontObject in pairs(GUISFonts.number) do
		SetFont(fontObject, localizedFonts[gameLocale].number)
	end

	for _,fontObject in pairs(GUISFonts.damage) do
		SetFont(fontObject, localizedFonts[gameLocale].damage)
	end

	for _,fontObject in pairs(GUISFonts.unitframes) do
		SetFont(fontObject, localizedFonts[gameLocale].number)
	end
end

-- just a few Blizzard fonts we want to change
SetBlizzFonts = function(self)
	local text, number, damage
	
	if (localizedFonts[gameLocale]) then
		text = localizedFonts[gameLocale].text
		number = localizedFonts[gameLocale].number
		damage = localizedFonts[gameLocale].damage

		SetFont(CombatTextFont, damage, nil, "THINOUTLINE", 1.25, -1.25)
		SetFont(SubZoneTextFont, number, nil, "THINOUTLINE", 2.25, -2.25)
		SetFont(PVPInfoTextFont, number, nil, "THINOUTLINE", 2.25, -2.25)
		SetFont(ZoneTextFont, number, nil, "THINOUTLINE", 2.25, -2.25)
		
	else
		text = M["Font"]["PT Sans Narrow Bold"] -- Waukegan LDO
		number = M["Font"]["Big Noodle Titling"]
		damage = M["Font"]["TrashHand"] -- Righteous Kill Condensed

		UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
		CHAT_FONT_HEIGHTS = { 12, 13, 14, 15, 16, 17, 18, 19, 20 }

		-- on-screen combat font, make it huge for clarity, if that even works (max is 32, isn't it...?)
		SetFont(CombatTextFont, damage, 100, "OUTLINE", 1.25, -1.25)
		
		-- on-screen zone and subzone names
		SetFont(SubZoneTextFont, number, 28, "OUTLINE", 2.25, -2.25) 
		SetFont(PVPInfoTextFont, number, 18, "OUTLINE", 2.25, -2.25) 
		SetFont(ZoneTextFont, number, 32, "OUTLINE", 2.25, -2.25)
		SetFont(PVPArenaTextString, number, 22, "OUTLINE", 2.25, -2.25) 

		-- on-screen stuff that bugs me. using the number/unitframe font for consistency
		SetFont(RaidWarningFrameSlot1, number, nil, "THINOUTLINE", 2.25, -2.25)
		SetFont(RaidWarningFrameSlot2, number, nil, "THINOUTLINE", 2.25, -2.25)
		SetFont(RaidBossEmoteFrameSlot1, number, nil, "THINOUTLINE", 2.25, -2.25)
		SetFont(RaidBossEmoteFrameSlot2, number, nil, "THINOUTLINE", 2.25, -2.25)
		
		-- system fonts
		SetFont(FriendsFont_Normal, text, 12)
		SetFont(FriendsFont_Large, text, 14)
		SetFont(FriendsFont_Small, text, 11)
		SetFont(FriendsFont_UserText, text, 11)
		SetFont(GameFontNormal, text)
		SetFont(GameFontDisable, text)
		SetFont(GameFontHighlight, text)
		SetFont(NumberFont_Shadow_Med, text, 12)
		SetFont(NumberFont_Shadow_Small, text, 12)
		SetFont(SystemFont_Large, text, 13) -- Testing #1
		SetFont(SystemFont_Med1, text, 12)
		SetFont(SystemFont_Med3, text, 12) -- Testing #2
		SetFont(SystemFont_OutlineThick_Huge2, text, 20, "THICKOUTLINE")
		SetFont(SystemFont_Outline_Small, NUMBER, 12, "OUTLINE")
		SetFont(SystemFont_Shadow_Huge1, text, 20, "THINOUTLINE")
		SetFont(SystemFont_Shadow_Large, text, 15)
		SetFont(SystemFont_Shadow_Med1, text, 12)
		SetFont(SystemFont_Shadow_Med3, text, 13)
		SetFont(SystemFont_Shadow_Outline_Huge2, text, 20, "OUTLINE")
		SetFont(SystemFont_Shadow_Small, text, 11)
		SetFont(SystemFont_Small, text, 12)
		SetFont(SystemFont_Tiny, text, 12)
		
		-- tooltips
		SetFont(GameTooltipHeader, text, 12) -- original size is 14
		SetFont(Tooltip_Med, text, 12)
		SetFont(Tooltip_Small, text, 12)
		
		-- make most numbers use our numberfont
		SetFont(NumberFontNormal, number)
		SetFont(NumberFontNormalLarge, number)
		SetFont(NumberFontNormalSmallGray, number)
		SetFont(NumberFont_OutlineThick_Mono_Small, number, 12, "OUTLINE")
		SetFont(NumberFont_Outline_Huge, number, 28, "THICKOUTLINE")
		SetFont(NumberFont_Outline_Large, number, 15, "OUTLINE")
		SetFont(NumberFont_Outline_Med, number, 13, "OUTLINE")
		
		-- get rid of the weird and unreadable quest/mail font
		SetFont(MailFont_Large, text)
		SetFont(MailTextFontNormal, text)
		SetFont(QuestFont, text)
		SetFont(QuestFontHighlight, text)
		SetFont(QuestFontNormalSmall, text)
		SetFont(QuestFontLeft, text)
		SetFont(QuestFont_Large, text)
		SetFont(QuestFont_Shadow_Huge, text)
		SetFont(QuestFont_Shadow_Small, text)
		SetFont(QuestFont_Super_Huge, text)
		
	end
	
	UNIT_NAME_FONT = text
	NAMEPLATE_FONT = text
	DAMAGE_TEXT_FONT = damage
	STANDARD_TEXT_FONT = text

end

-- 
-- we're using Init() to make sure fonts are set before other modules are loaded
module.Init = function(self)
	SetBlizzFonts()
	SetGUISFonts()
end