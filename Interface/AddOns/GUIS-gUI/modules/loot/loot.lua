--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: Loot")

-- Lua API
local unpack = unpack

-- WoW API
local CreateFrame = CreateFrame
local GetLootRollItemInfo = GetLootRollItemInfo
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local LootFrame = LootFrame
local UIParent = UIParent

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end

local defaults = {}

local MakeBackdrop = function(frame)
	if (frame == LootFrame) then
		frame:SetBackdrop(M["Backdrop"]["Blank-Inset"])
		frame:SetBackdropColor(C["background"][1], C["background"][2], C["background"][3], 0.75)
		frame:SetBackdropBorderColor(C["border"][1], C["border"][2], C["border"][3], 1)
		frame:CreateUIShadow()
		frame:SetUIShadowColor(unpack(C["shadow"]))
	else
		frame:SetBackdrop(M["Backdrop"]["Blank"])
		frame:SetBackdropColor(C["background"][1], C["background"][2], C["background"][3], 0.75)

		frame.Backdrop = frame:CreateUIPanel()
		frame.Backdrop:SetBackdrop(M["Backdrop"]["Border"])
		frame.Backdrop:SetBackdropColor(0, 0, 0, 0)
		frame.Backdrop:SetBackdropBorderColor(unpack(C["background"]))
		frame.Backdrop:CreateUIShadow()
		frame.Backdrop:SetUIShadowColor(unpack(C["shadow"]))
		frame.Backdrop:ClearAllPoints()
		frame.Backdrop:SetPoint("TOP", frame, "TOP", 0, 1)
		frame.Backdrop:SetPoint("BOTTOM", frame, "BOTTOM", 0, -1)
		frame.Backdrop:SetPoint("LEFT", frame, "LEFT", -1, 0)
		frame.Backdrop:SetPoint("RIGHT", frame, "RIGHT", 1, 0)
	end
end

--[[
	Original roll strings are from teksLoot, extracted/edited from GlobalStrings.lua by tekkub
	- esES, esMX and ptBR extracted and added by Lars Norberg (untested, need feedback)
	
	tekkub: http://www.tekkub.net/
	teksLoot: http://www.wowinterface.com/downloads/info8198-teksLoot.html
]]--
local locale = GetLocale()
local rollpairs = (locale == "deDE") and {
	["(.*) passt automatisch bei (.+), weil [ersi]+ den Gegenstand nicht benutzen kann.$"]  = "pass",
	["(.*) würfelt nicht für: (.+|r)$"] = "pass",
	["(.*) hat für (.+) 'Gier' ausgewählt"] = "greed",
	["(.*) hat für (.+) 'Bedarf' ausgewählt"] = "need",
	["(.*) hat für '(.+)' Entzauberung gewählt."]  = "disenchant",
} or (locale == "frFR") and {
	["(.*) a passé pour : (.+) parce qu'((il)|(elle)) ne peut pas ramasser cette objet.$"]  = "pass",
	["(.*) a passé pour : (.+)"]  = "pass",
	["(.*) a choisi Cupidité pour : (.+)"] = "greed",
	["(.*) a choisi Besoin pour : (.+)"]  = "need",
	["(.*) a choisi Désenchantement pour : (.+)"]  = "disenchant",
} or (locale == "zhTW") and {
	["(.*)自動放棄:(.+)，因為"]  = "pass",
	["(.*)放棄了:(.+)"] = "pass",
	["(.*)選擇了貪婪優先:(.+)"] = "greed",
	["(.*)選擇了需求優先:(.+)"] = "need",
	["(.*)選擇分解:(.+)"] = "disenchant",
} or (locale == "zhCN") and { 
	["(.*)自动放弃了(.+)，因为他无法拾取该物品。$"]  = "pass",
	["(.*)放弃了：(.+)"] = "pass", 
	["(.*)选择了贪婪取向：(.+)"] = "greed", 
	["(.*)选择了需求取向：(.+)"] = "need", 
	["(.*)选择了分解取向：(.+)"] = "disenchant",
} or (locale == "ruRU") and {
	["(.*) автоматически передает предмет (.+), поскольку не может его забрать"] = "pass",
	["(.*) пропускает розыгрыш предмета \"(.+)\", поскольку не может его забрать"] = "pass",
	["(.*) отказывается от предмета (.+)%."]  = "pass",
	["Разыгрывается: (.+)%. (.*): \"Не откажусь\""] = "greed",
	["Разыгрывается: (.+)%. (.*): \"Мне это нужно\""] = "need",
	["Разыгрывается: (.+)%. (.*): \"Распылить\""] = "disenchant",
} or (locale == "koKR") and {
	["(.+)님이 획득할 수 없는 아이템이어서 자동으로 주사위 굴리기를 포기했습니다: (.+)"] = "pass",
	["(.+)님이 주사위 굴리기를 포기했습니다: (.+)"] = "pass",
	["(.+)님이 차비를 선택했습니다: (.+)"] = "greed",
	["(.+)님이 입찰을 선택했습니다: (.+)"] = "need",
	["(.+)님이 마력 추출을 선택했습니다: (.+)"] = "disenchant",
} or (locale == "esES") and {
	["(.*) ha pasado automáticamente de: (.+) ya que él no puede despojar ese objeto."] = "pass",
	["(.*) ha pasado automáticamente de: (.+) ya que ella no puede despojar ese objeto."] = "pass",
	["(.*) ha pasado de: (.+)"] = "pass",
	["(.*) ha seleccionado codicia para: (.+)"] = "greed",
	["(.*) ha seleccionado necesidad para: (.+)"] = "need",
	["(.*) ha seleccionado desencantar para: (.+)"] = "disenchant",
} or (locale == "esMX") and {
	["(.*) ha pasado automáticamente de: (.+) ya que él no puede despojar ese objeto."] = "pass",
	["(.*) ha pasado automáticamente de: (.+) ya que ella no puede despojar ese objeto."] = "pass",
	["(.*) ha pasado de: (.+)"] = "pass",
	["(.*) ha seleccionado codicia para: (.+)"] = "greed",
	["(.*) ha seleccionado necesidad para: (.+)"] = "need",
	["(.*) ha seleccionado desencantar para: (.+)"] = "disenchant",
} or (locale == "ptBR") and {
	["(.*) abdicou de (.+) automaticamente porque não pode saquear o item."] = "pass",
	["(.*) abdicou de (.+) automaticamente porque não pode saquear o item."] = "pass",
	["(.*) dispensou: (.+)"] = "pass",
	["(.*) selecionou Ganância para: (.+)"] = "greed",
	["(.*) escolheu Necessidade para: (.+)"] = "need",
	["(.*) selecionou Desencantar para: (.+)"] = "disenchant",
} or {
	["^(.*) automatically passed on: (.+) because s?he cannot loot that item.$"] = "pass", -- LOOT_ROLL_PASSED_AUTO, LOOT_ROLL_PASSED_AUTO_FEMALE
	["^(.*) passed on: (.+|r)$"]  = "pass", -- LOOT_ROLL_PASSED
	["(.*) has selected Greed for: (.+)"] = "greed", -- LOOT_ROLL_GREED
	["(.*) has selected Need for: (.+)"]  = "need", -- LOOT_ROLL_NEED
	["(.*) has selected Disenchant for: (.+)"]  = "disenchant", --LOOT_ROLL_DISENCHANT
}

local ParseRollChoice = function(msg)
	if not(msg) then
		return
	end

	for i,v in pairs(rollpairs) do
		local _, _, playername, itemname = string.find(msg, i)
		if (locale == "ruRU") and ((v == "greed") or (v == "need") or (v == "disenchant"))  then 
			local temp = playername
			playername = itemname
			itemname = temp
		end 
		
		-- ok (for now) to leave 'Everyone' unlocalized, 
		-- as the LOOT_ROLL_ALL_PASSED string is only the same as
		-- the LOOT_ROLL_PASSED string in enUS/enGB.
		if (playername) and (itemname) and (playername ~= "Everyone") then 
			return playername, itemname, v 
		end
	end
end

local PostUpdateRollChoices = function(self, event, msg)
	local playername, itemname, rolltype
	if (event == "CHAT_MSG_LOOT") then
		playername, itemname, rolltype = ParseRollChoice(msg)
	end
	
	if (playername) and (itemname) and (rolltype) then
		local i, frame
		for i = 1, NUM_GROUP_LOOT_FRAMES do
			frame = _G["GroupLootFrame" .. i]

			if not(frame.rolls) then
				frame.rolls = {}
			end
			
			if (frame.rollID) and (frame.link == itemname) and not(frame.rolls[playername]) then
				frame.rolls[playername] = rolltype
				frame[rolltype]:SetText(tonumber(frame[rolltype]:GetText()) + 1)
				
				return
			end
		end
	end
end

local SetUpRollFrame = function(fName)
	-- start making sizes dynamic, for future customizability
	-- current problems:
	-- 	* blizzard icons are small, only 32x32
	local m = 1.0 -- multiplier for the size. padding/spacing remains unaffected
	local buttonPadding, edgePadding, framePadding = 16, 12, 8
	local borderPadding = 3
	local buttonSize = 32 * m
	local itemSize = 48 * m
	local rollWidth, rollHeight = (buttonSize * 4) + (buttonPadding * 3) + (edgePadding * 2) + (200  * m), 16 * m
	local iconSize = itemSize - borderPadding * 2
	local frameWidth, frameHeight = rollWidth + itemSize + edgePadding, itemSize + (edgePadding * 2) 

--	F.CreateFadeHooks(_G[fName])
	
	_G[fName]:SetSize(frameWidth, frameHeight)
	_G[fName]:SetBackdrop(nil)
	_G[fName]:SetParent(UIParent)

	_G[fName .. "Timer"]:SetSize(rollWidth, rollHeight)
	_G[fName .. "Timer"]:ClearAllPoints()
	_G[fName .. "Timer"]:SetPoint("BOTTOMRIGHT", _G[fName], "BOTTOMRIGHT", 0, edgePadding)
	_G[fName .. "Timer"]:DisableDrawLayer("OVERLAY")
	_G[fName .. "Timer"]:SetStatusBarTexture(M["StatusBar"]["StatusBar"])
	
	_G[fName .. "IconFrame"]:SetSize(itemSize, itemSize)
	_G[fName .. "IconFrame"]:ClearAllPoints()
	_G[fName .. "IconFrame"]:SetPoint("BOTTOMRIGHT", _G[fName .. "Timer"], "BOTTOMLEFT", -framePadding, -framePadding)

	_G[fName .. "IconFrameIcon"]:SetSize(iconSize, iconSize)
	_G[fName .. "IconFrameIcon"]:ClearAllPoints()
	_G[fName .. "IconFrameIcon"]:SetPoint("BOTTOMLEFT", _G[fName .. "IconFrame"], "BOTTOMLEFT", borderPadding, borderPadding)
	_G[fName .. "IconFrameIcon"]:SetTexCoord(5/64, 59/64, 5/64, 59/64)

	local layer, subLayer = _G[fName .. "IconFrameIcon"]:GetDrawLayer()

	if not(_G[fName .. "IconShade"]) then
		_G[fName .. "IconShade"] = _G[fName]:CreateTexture()
		_G[fName .. "IconShade"]:SetDrawLayer(layer or "BACKGROUND", subLayer and subLayer + 1 or 2)
		_G[fName .. "IconShade"]:SetTexture(M["Button"]["Shade"])
		_G[fName .. "IconShade"]:SetVertexColor(0, 0, 0, 1/3)
		_G[fName .. "IconShade"]:ClearAllPoints()
		_G[fName .. "IconShade"]:SetAllPoints(_G[fName .. "IconFrameIcon"])
	end

	if not(_G[fName .. "IconGloss"]) then
		_G[fName .. "IconGloss"] = _G[fName]:CreateTexture()
		_G[fName .. "IconGloss"]:SetDrawLayer(layer or "BACKGROUND", subLayer and subLayer + 2 or 3)
		_G[fName .. "IconGloss"]:SetTexture(M["Button"]["Gloss"])
		_G[fName .. "IconGloss"]:SetVertexColor(1, 1, 1, 1/3)
		_G[fName .. "IconGloss"]:ClearAllPoints()
		_G[fName .. "IconGloss"]:SetAllPoints(_G[fName .. "IconFrameIcon"])
	end

	_G[fName .. "IconFrameCount"]:SetSize(itemSize, itemSize)
	_G[fName .. "IconFrameCount"]:ClearAllPoints()
	_G[fName .. "IconFrameCount"]:SetPoint("BOTTOMRIGHT", _G[fName .. "IconFrameIcon"], "BOTTOMRIGHT", -borderPadding, borderPadding)
	_G[fName .. "IconFrameCount"]:SetFontObject(GUIS_NumberFontNormal)
		
	_G[fName .. "Name"]:SetSize(_G[fName]:GetWidth(), 16)
	_G[fName .. "Name"]:ClearAllPoints()
	_G[fName .. "Name"]:SetPoint("BOTTOMLEFT", _G[fName .. "Timer"], "TOPLEFT", 0, (buttonSize - rollHeight)/2 + edgePadding/2)
	_G[fName .. "Name"]:SetFontObject(GUIS_SystemFontNormal)
	
	_G[fName .. "RollButton"]:SetSize(buttonSize, buttonSize)
	_G[fName .. "RollButton"]:ClearAllPoints()
	_G[fName .. "RollButton"]:SetPoint("LEFT", _G[fName .. "Timer"], "LEFT", edgePadding, 0)
	_G[fName .. "RollButton"]:SetHitRectInsets(-8, -8, -8, -8)
	
	_G[fName .. "GreedButton"]:SetSize(buttonSize, buttonSize)
	_G[fName .. "GreedButton"]:ClearAllPoints()
	_G[fName .. "GreedButton"]:SetPoint("LEFT", _G[fName .. "RollButton"], "RIGHT", buttonPadding, 0)
	_G[fName .. "GreedButton"]:SetHitRectInsets(-8, -8, -8, -8)

	_G[fName .. "DisenchantButton"]:SetSize(buttonSize, buttonSize)
	_G[fName .. "DisenchantButton"]:ClearAllPoints()
	_G[fName .. "DisenchantButton"]:SetPoint("LEFT", _G[fName .. "GreedButton"], "RIGHT", buttonPadding, 0)
	_G[fName .. "DisenchantButton"]:SetHitRectInsets(-8, -8, -8, -8)

	_G[fName .. "PassButton"]:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
	_G[fName .. "PassButton"]:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
	_G[fName .. "PassButton"]:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
	_G[fName .. "PassButton"]:SetSize(buttonSize, buttonSize)
	_G[fName .. "PassButton"]:ClearAllPoints()
	_G[fName .. "PassButton"]:SetPoint("RIGHT", _G[fName .. "Timer"], "RIGHT", -edgePadding, 0)
	_G[fName .. "PassButton"]:SetHitRectInsets(-8, -8, -8, -8)

	_G[fName .. "SlotTexture"]:SetTexture("")
	_G[fName .. "Decoration"]:SetTexture("")
	_G[fName .. "Corner"]:SetTexture("")
	_G[fName .. "NameFrame"]:SetTexture("")
	
	-- texts
	if not(_G[fName].isbind) then
		_G[fName].isbind = _G[fName .. "IconFrame"]:CreateFontString(nil, "OVERLAY")
		_G[fName].isbind:SetFontObject(GUIS_SystemFontNormalWhite)
		_G[fName].isbind:SetPoint("BOTTOM", 0, -3)
	end
	_G[fName].isbind:SetText("")

	if not(_G[fName].need) then
		_G[fName].need = _G[fName .. "RollButton"]:CreateFontString(nil, "OVERLAY")
		_G[fName].need:SetFontObject(GUIS_NumberFontNormalYellow)
		_G[fName].need:SetPoint("BOTTOMRIGHT", 8, -8)
	end
	_G[fName].need:SetText(0)

	if not(_G[fName].greed) then
		_G[fName].greed = _G[fName .. "GreedButton"]:CreateFontString(nil, "OVERLAY")
		_G[fName].greed:SetFontObject(GUIS_NumberFontNormalYellow)
		_G[fName].greed:SetPoint("BOTTOMRIGHT", 8, -8)
	end
	_G[fName].greed:SetText(0)

	if not(_G[fName].disenchant) then
		_G[fName].disenchant = _G[fName .. "DisenchantButton"]:CreateFontString(nil, "OVERLAY")
		_G[fName].disenchant:SetFontObject(GUIS_NumberFontNormalYellow)
		_G[fName].disenchant:SetPoint("BOTTOMRIGHT", 8, -8)
	end
	_G[fName].disenchant:SetText(0)

	if not(_G[fName].pass) then
		_G[fName].pass = _G[fName .. "PassButton"]:CreateFontString(nil, "OVERLAY")
		_G[fName].pass:SetFontObject(GUIS_NumberFontNormalYellow)
		_G[fName].pass:SetPoint("BOTTOMRIGHT", 8, -8)
	end
	_G[fName].pass:SetText(0)
	
	if not(_G[fName].rolls) then
		_G[fName].rolls = {}
	else
		wipe(_G[fName].rolls)
	end
	
	_G[fName].initialized = true
end

local PostUpdateRollFrames = function()
	for index = 1, NUM_GROUP_LOOT_FRAMES do
		local fName = "GroupLootFrame" .. index
		local rollID = _G[fName].rollID

		if (rollID) then
			SetUpRollFrame(fName)
			
			local texture, name, count, quality, bop, canneed, cangreed, canshard, whyneed, whygreed, whyshard, deskill = GetLootRollItemInfo(rollID)

			_G[fName].link = GetLootRollItemLink(rollID)

			if (name) then
				local color = ITEM_QUALITY_COLORS[quality] or {}
			
				color.r = color.r or 0.6
				color.g = color.g or 0.6
				color.b = color.b or 0.6

				_G[fName .. "Timer"]:SetStatusBarColor(color.r, color.g, color.b, 1)
				_G[fName .. "Timer"]:SetBackdropColor(color.r * 1/5, color.g * 1/5, color.b * 1/5, 3/4)

				_G[fName .. "IconFrame"]:SetBackdropBorderColor(color.r, color.g, color.b, 1)
				_G[fName .. "IconFrame"]:SetUIShadowColor(color.r * 2/3, color.g * 2/3, color.b * 2/3, 3/4)
				
				if (canneed) then
					_G[fName .. "RollButton"]:Show()
					_G[fName .. "RollButton"]:SetAlpha(1)
					_G[fName .. "GreedButton"]:ClearAllPoints()
					_G[fName .. "GreedButton"]:SetPoint("LEFT", _G[fName.."RollButton"], "RIGHT", 16, 0)
				else
					_G[fName .. "RollButton"]:SetAlpha(0)
					_G[fName .. "RollButton"]:Hide()
					_G[fName .. "GreedButton"]:ClearAllPoints()
					_G[fName .. "GreedButton"]:SetPoint("LEFT", _G[fName.."Timer"], "LEFT", 12, 0)
				end
				
				if (canshard) then
					_G[fName .. "DisenchantButton"]:Show()
					_G[fName .. "DisenchantButton"]:SetAlpha(1)
				else
					_G[fName .. "DisenchantButton"]:SetAlpha(0)
					_G[fName .. "DisenchantButton"]:Hide()
				end
				
				if (bop) then
					_G[fName].isbind:SetText(L["BoP"])
					_G[fName].isbind:SetVertexColor(unpack(C["value"]))
				else
					_G[fName].isbind:SetText(L["BoE"])
					_G[fName].isbind:SetVertexColor(unpack(C["disabled"]))
				end

			end
		end
	end
	
	PostUpdateRollChoices()
	
	GroupLootFrame1:ClearAllPoints()
	GroupLootFrame1:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 220)
end

local PostUpdateLootFrame = function()
	if (GetCVar("lootUnderMouse") ~= "1") then
		LootFrame:ClearAllPoints()
		LootFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 250, -250)
	end

	local numshown, lastshown = 0, 0
	for index = 1, LOOTFRAME_NUMBUTTONS do
		local bName = "LootButton" .. index

		if _G[bName]:IsShown() then
			local color = ITEM_QUALITY_COLORS[_G[bName].quality] or {}

			numshown = numshown + 1
			
			if (numshown == 1) then
				_G[bName]:ClearAllPoints()
				_G[bName]:SetPoint("TOPLEFT", LootFrame, "TOPLEFT", 6, -(6 + 18))
			else
				_G[bName]:ClearAllPoints()
				_G[bName]:SetPoint("TOP", _G["LootButton" .. lastshown], "BOTTOM", 0, -8)
			end

			lastshown = index
		
			color.r = color.r or 0.6
			color.g = color.g or 0.6
			color.b = color.b or 0.6

			_G[bName].r = color.r
			_G[bName].g = color.g
			_G[bName].b = color.b

			_G[bName]:SetNormalTexture("")
			_G[bName]:SetHighlightTexture("")
			_G[bName]:SetPushedTexture("")
			_G[bName]:SetDisabledTexture("")

			_G[bName .. "NameFrame"]:SetTexture("")

			_G[bName]:SetBackdropBorderColor(color.r * 3/4, color.g * 3/4, color.b * 3/4)
			_G[bName .. "Background"]:SetVertexColor(color.r, color.g, color.b, 1/3)
			_G[bName .. "Background"]:Show()

			_G[bName]:SetHitRectInsets(0, -148, 0, 0)
		else
			_G[bName .. "Background"]:Hide()
		end
	end
	
	LootFrame:SetHeight(numshown * (32 + 8) + 18 + 4 + ((LootFrameUpButton:IsShown() or LootFrameDownButton:IsShown()) and 32 or 0))
end

local InitLootFrame = function()
	LootFrame:SetSize(190, 32)
	LootFrame:SetHitRectInsets(0, 0, 0, 0)

	MakeBackdrop(LootFrame)
--	F.CreateFadeHooks(LootFrame)
	
	local portrait, bg, title, prevtext, nextext
	portrait, bg, title, prevtext, nextext = LootFrame:GetRegions()
	
	portrait:Hide()
	bg:Hide()
	prevtext:SetSize(1/1e4, 1/1e4)
	nextext:SetSize(1/1e4, 1/1e4)

	title:ClearAllPoints()
	title:SetPoint("TOPLEFT", LootFrame, "TOPLEFT", 4, -2)
	title:SetFontObject(GUIS_SystemFontNormal)

	if (LootCloseButton) then
		LootCloseButton:ClearAllPoints()
		LootCloseButton:SetPoint("TOPRIGHT", LootFrame, "TOPRIGHT", -3, -3)
		LootCloseButton:SetNormalTexture(M["Button"]["UICloseButton"])
		LootCloseButton:SetPushedTexture(M["Button"]["UICloseButtonDown"])
		LootCloseButton:SetHighlightTexture(M["Button"]["UICloseButtonHighlight"])
		LootCloseButton:SetDisabledTexture(M["Button"]["UICloseButtonDisabled"])
		LootCloseButton:SetSize(16, 16)
	end

	LootFrameUpButton:ClearAllPoints()
	LootFrameUpButton:SetPoint("BOTTOMLEFT", LootFrame, "BOTTOMLEFT", 0, 0)
	LootFrameUpButton:SetNormalTexture(M["Icon"]["ArrowUp"])
	LootFrameUpButton:SetPushedTexture(M["Icon"]["ArrowUp"])
	LootFrameUpButton:SetHighlightTexture(M["Icon"]["ArrowUpHighlight"])
	LootFrameUpButton:SetDisabledTexture(M["Icon"]["ArrowUpDisabled"])
	
	LootFrameDownButton:ClearAllPoints()
	LootFrameDownButton:SetPoint("BOTTOMRIGHT", LootFrame, "BOTTOMRIGHT", 0, 0)
	LootFrameDownButton:SetNormalTexture(M["Icon"]["ArrowDown"])
	LootFrameDownButton:SetPushedTexture(M["Icon"]["ArrowDown"])
	LootFrameDownButton:SetHighlightTexture(M["Icon"]["ArrowDownHighlight"])
	LootFrameDownButton:SetDisabledTexture(M["Icon"]["ArrowDownDisabled"])
	
	for index = 1, LOOTFRAME_NUMBUTTONS do
		local bName = "LootButton" .. index

		if (index == 1) then
			_G[bName]:ClearAllPoints()
			_G[bName]:SetPoint("TOPLEFT", LootFrame, "TOPLEFT", 6, -(6 + 18))
		else
			_G[bName]:ClearAllPoints()
			_G[bName]:SetPoint("TOP", _G["LootButton" .. (index - 1)], "BOTTOM", 0, -8)
		end

		_G[bName]:SetSize(32, 32)
		_G[bName]:SetHitRectInsets(0, -146, 0, 0)
		_G[bName]:SetUITemplate("itembutton")

		_G[bName].r = 0.0
		_G[bName].g = 0.0
		_G[bName].b = 0.0

		_G[bName .. "Text"]:ClearAllPoints()
		_G[bName .. "Text"]:SetPoint("LEFT", _G[bName], "RIGHT", 6, 0)
		_G[bName .. "Text"]:SetFontObject(GUIS_SystemFontSmall)
		_G[bName .. "Text"]:SetJustifyH("LEFT")
		_G[bName .. "Text"]:SetJustifyV("MIDDLE")
		
		_G[bName .. "Background"] = _G[bName]:CreateTexture(nil, "ARTWORK")
		_G[bName .. "Background"]:SetPoint("TOP", _G[bName], "TOP", 0, -1)
		_G[bName .. "Background"]:SetPoint("BOTTOM", _G[bName], "BOTTOM", 0, 1)
		_G[bName .. "Background"]:SetPoint("LEFT", _G[bName], "RIGHT", 1, 0)
		_G[bName .. "Background"]:SetPoint("RIGHT", _G[bName], "RIGHT", 146, 0)
		_G[bName .. "Background"]:SetTexture(M["StatusBar"]["StatusBar"])

		_G[bName .. "Count"]:SetSize(32, 32)
		_G[bName .. "Count"]:ClearAllPoints()
		_G[bName .. "Count"]:SetPoint("BOTTOMRIGHT", _G[bName.."IconTexture"], "BOTTOMRIGHT", 1, 2)
		_G[bName .. "Count"]:SetJustifyV("BOTTOM")
		_G[bName .. "Count"]:SetJustifyH("RIGHT")
		_G[bName .. "Count"]:SetFontObject(GUIS_NumberFontSmall)
		
		_G[bName .. "IconTexture"]:SetParent(_G[bName])
		_G[bName .. "IconTexture"]:ClearAllPoints()
		_G[bName .. "IconTexture"]:SetPoint("TOPLEFT", _G[bName], "TOPLEFT", 3, -3)
		_G[bName .. "IconTexture"]:SetPoint("BOTTOMRIGHT", _G[bName], "BOTTOMRIGHT", -3, 3)
		_G[bName .. "IconTexture"]:SetTexCoord(5/64, 59/64, 5/64, 59/64)

		_G[bName .. "IconQuestTexture"]:SetParent(_G[bName])
		_G[bName .. "IconQuestTexture"]:ClearAllPoints()
		_G[bName .. "IconQuestTexture"]:SetPoint("TOPLEFT", _G[bName], "TOPLEFT", 3, -3)
		_G[bName .. "IconQuestTexture"]:SetPoint("BOTTOMRIGHT", _G[bName], "BOTTOMRIGHT", -3, 3)
		_G[bName .. "IconQuestTexture"]:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		
		local layer, subLayer = _G[bName .. "IconTexture"]:GetDrawLayer()

		_G[bName .. "IconShade"] = _G[bName]:CreateTexture()
		_G[bName .. "IconShade"]:SetDrawLayer(layer or "BACKGROUND", subLayer and subLayer + 1 or 2)
		_G[bName .. "IconShade"]:SetTexture(M["Button"]["Shade"])
		_G[bName .. "IconShade"]:SetVertexColor(0, 0, 0, 1/3)
		_G[bName .. "IconShade"]:ClearAllPoints()
		_G[bName .. "IconShade"]:SetPoint("TOPLEFT", _G[bName], "TOPLEFT", 3, -3)
		_G[bName .. "IconShade"]:SetPoint("BOTTOMRIGHT", _G[bName], "BOTTOMRIGHT", -3, 3)

		_G[bName .. "IconGloss"] = _G[bName]:CreateTexture()
		_G[bName .. "IconGloss"]:SetDrawLayer(layer or "BACKGROUND", subLayer and subLayer + 2 or 3)
		_G[bName .. "IconGloss"]:SetTexture(M["Button"]["Gloss"])
		_G[bName .. "IconGloss"]:SetVertexColor(1, 1, 1, 1/3)
		_G[bName .. "IconGloss"]:ClearAllPoints()
		_G[bName .. "IconGloss"]:SetPoint("TOPLEFT", _G[bName], "TOPLEFT", 3, -3)
		_G[bName .. "IconGloss"]:SetPoint("BOTTOMRIGHT", _G[bName], "BOTTOMRIGHT", -3, 3)

		_G[bName .. "Count"]:SetParent(_G[bName])

		_G[bName]:HookScript("OnEnter", function(self) 
			self:SetBackdropBorderColor(self.r, self.g, self.b)
			_G[self:GetName().."Background"]:SetVertexColor(self.r, self.g, self.b, 2/3)
		end)

		_G[bName]:HookScript("OnLeave", function(self) 
			self:SetBackdropBorderColor(self.r * 3/4, self.g * 3/4, self.b * 3/4)
			_G[self:GetName().."Background"]:SetVertexColor(self.r, self.g, self.b, 1/3)
		end)

	end
end

local InitRollFrames = function(index)
	for index = 1, NUM_GROUP_LOOT_FRAMES, 1 do
		local fName = "GroupLootFrame" .. index

		-- MoP edits
		if (_G[fName .. "IconFrame"]) then
			_G[fName .. "IconFrame"]:SetBackdrop(M["Backdrop"]["PixelBorder-Blank"])
			_G[fName .. "IconFrame"]:SetBackdropBorderColor(unpack(C["border"]))
		end 

		if (_G[fName .. "Timer"]) then
			MakeBackdrop(_G[fName .. "Timer"])
		end
		
		SetUpRollFrame(fName)
	end
	
	GroupLootFrame1:ClearAllPoints()
	GroupLootFrame1:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 220)
end

module.RestoreDefaults = function(self)
	GUIS_DB["loot"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["loot"] = GUIS_DB["loot"] or {}
	GUIS_DB["loot"] = ValidateTable(GUIS_DB["loot"], defaults)
end

module.OnInit = function(self)
	if (F.kill(self:GetName())) then 
		self:Kill() 
		return 
	end
end

module.OnEnable = function(self)
	UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootFrame1"] = nil

	InitLootFrame()
	InitRollFrames()
	
	RegisterCallback("CHAT_MSG_LOOT", PostUpdateRollChoices)
	RegisterCallback("LOOT_OPENED", PostUpdateLootFrame)
	RegisterCallback("LOOT_SLOT_CHANGED", PostUpdateLootFrame)
	RegisterCallback("LOOT_SLOT_CLEARED", PostUpdateLootFrame)
	RegisterCallback("START_LOOT_ROLL", PostUpdateRollFrames)
end
