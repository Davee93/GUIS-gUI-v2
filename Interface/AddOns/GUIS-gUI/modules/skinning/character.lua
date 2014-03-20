--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningCharacter")

-- Lua API
local pairs, select, unpack = pairs, select, unpack

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end

local Skin
local gearSlots = {
	"BackSlot";
	"ChestSlot";
	"HandsSlot";
	"HeadSlot";
	"FeetSlot";
	"Finger0Slot";
	"Finger1Slot";
	"LegsSlot";
	"MainHandSlot";
	"NeckSlot";
	"RangedSlot";
	"SecondaryHandSlot";
	"ShirtSlot";
	"ShoulderSlot";
	"TabardSlot";
	"Trinket0Slot";
	"Trinket1Slot";
	"WaistSlot";
	"WristSlot";
}

module.OnInit = function(self)
	if (F.kill("GUIS-gUI: UISkinning")) or not(GUIS_DB["skinning"][self:GetName()]) then 
		self:Kill() 
		return 
	end
	
	local PaperDollFrameItemFlyoutButtonName = PaperDollFrameItemFlyout and "PaperDollFrameItemFlyoutButtons" or "EquipmentFlyoutFrameButton"
	local PDFITEMFLYOUT_MAXITEMS = PDFITEMFLYOUT_MAXITEMS or EQUIPMENTFLYOUT_MAXITEMS
	local PaperDollFrameItemFlyout = PaperDollFrameItemFlyout or EquipmentFlyoutFrame
	local PaperDollFrameItemFlyoutButtons = PaperDollFrameItemFlyoutButtons or EquipmentFlyoutFrameButtons
	
	CharacterFramePortrait:Kill()
	
	CharacterFrame:RemoveTextures()
	CharacterFrameInset:RemoveTextures()
	CharacterFrameInsetRight:RemoveTextures()
	CharacterModelFrame:RemoveTextures()
	CharacterModelFrame:RemoveTextures()
	CharacterStatsPane:RemoveTextures()
	CharacterStatsPaneCategory1:RemoveTextures()
	CharacterStatsPaneCategory2:RemoveTextures()
	CharacterStatsPaneCategory3:RemoveTextures()
	CharacterStatsPaneCategory4:RemoveTextures()
	CharacterStatsPaneCategory5:RemoveTextures()
	CharacterStatsPaneCategory6:RemoveTextures()
	CharacterStatsPaneCategory7:RemoveTextures()
	GearManagerDialogPopup:RemoveTextures()
	GearManagerDialogPopupScrollFrame:RemoveTextures()
	ReputationListScrollFrame:RemoveTextures()
	if (PaperDollEquipmentManagerPane) then PaperDollEquipmentManagerPane:RemoveTextures() end
	if (PaperDollFrameItemFlyout) then PaperDollFrameItemFlyout:RemoveTextures() end 
	if (PaperDollSidebarTabs) then PaperDollSidebarTabs:RemoveTextures() end
	ReputationDetailFrame:RemoveTextures()
	ReputationFrame:RemoveTextures()
	ReputationListScrollFrame:RemoveTextures()
	TokenFramePopup:RemoveTextures()

	-- most rotationarrows for character models removed in 4.3
	if (CharacterModelFrameRotateLeftButton) then CharacterModelFrameRotateLeftButton:SetUITemplate("arrow", "left") end
	if (CharacterModelFrameRotateRightButton) then CharacterModelFrameRotateRightButton:SetUITemplate("arrow", "right") end

	CharacterFrameExpandButton:SetUITemplate("arrow")
	PetModelFrameRotateLeftButton:SetUITemplate("arrow", "left")
	PetModelFrameRotateRightButton:SetUITemplate("arrow", "right")
	
	GearManagerDialogPopupCancel:SetUITemplate("button")
	GearManagerDialogPopupOkay:SetUITemplate("button")
	if (PaperDollEquipmentManagerPaneEquipSet) then PaperDollEquipmentManagerPaneEquipSet:SetUITemplate("button") end
	if (PaperDollEquipmentManagerPaneSaveSet) then PaperDollEquipmentManagerPaneSaveSet:SetUITemplate("button") end

	ReputationDetailInactiveCheckBox:SetUITemplate("checkbutton")
	ReputationDetailAtWarCheckBox:SetUITemplate("checkbutton")
	ReputationDetailMainScreenCheckBox:SetUITemplate("checkbutton")
	TokenFramePopupInactiveCheckBox:SetUITemplate("checkbutton")
	TokenFramePopupBackpackCheckBox:SetUITemplate("checkbutton")
	
	CharacterFrameCloseButton:SetUITemplate("closebutton")
	ReputationDetailCloseButton:SetUITemplate("closebutton")
	TokenFramePopupCloseButton:SetUITemplate("closebutton")

	GearManagerDialogPopupEditBox:SetUITemplate("editbox")

	CharacterFrame:SetUITemplate("backdrop", nil, -6, 0, 6, 0)
	CharacterModelFrame:SetUITemplate("backdrop", nil, -3, 3, 3, -3)
	TokenFramePopup:SetUITemplate("simplebackdrop")
	GearManagerDialogPopup:SetUITemplate("simplebackdrop")
	ReputationDetailFrame:SetUITemplate("simplebackdrop")
	TokenFramePopup:SetUITemplate("simplebackdrop")
	PetModelFrame:SetUITemplate("simplebackdrop")

	ChannelRosterScrollFrameScrollBar:SetUITemplate("scrollbar")
	CharacterStatsPaneScrollBar:SetUITemplate("scrollbar")
	GearManagerDialogPopupScrollFrameScrollBar:SetUITemplate("scrollbar")
	if (PaperDollTitlesPaneScrollBar) then PaperDollTitlesPaneScrollBar:SetUITemplate("scrollbar") end
	if (PaperDollEquipmentManagerPaneScrollBar) then PaperDollEquipmentManagerPaneScrollBar:SetUITemplate("scrollbar") end
	ReputationListScrollFrameScrollBar:SetUITemplate("scrollbar")

	PetPaperDollFrameExpBar:SetUITemplate("statusbar", true)

	CharacterFrameTab1:SetUITemplate("tab")
	CharacterFrameTab2:SetUITemplate("tab")
	CharacterFrameTab3:SetUITemplate("tab")
	CharacterFrameTab4:SetUITemplate("tab")

	if (PaperDollFrameItemFlyout) then
		local FlyOutBackdrop = CreateFrame("Frame", nil, PaperDollFrameItemFlyout)
		FlyOutBackdrop:SetPoint("TOPLEFT", PaperDollFrameItemFlyoutButtons, "TOPLEFT", 0, 0)
		FlyOutBackdrop:SetPoint("BOTTOMRIGHT", PaperDollFrameItemFlyoutButtons, "BOTTOMRIGHT", 2, 0)
		FlyOutBackdrop:SetUITemplate("backdrop"):SetBackdropBorderColor(unpack(C["value"]))
	end

	for i = 1, NUM_GEARSET_ICONS_SHOWN do
		local button = _G["GearManagerDialogPopupButton" .. i]
		
		button:RemoveTextures()
		F.StyleActionButton(button)
	end

	for i,v in pairs(gearSlots) do
		local button = _G["Character" .. v]
		
		-- need to manually strip the textures, as the ignoreTexture hasn't got a name to whitelist
		for w = 1, button:GetNumRegions() do
			local region = select(w, button:GetRegions())
			if (region) and (region:GetObjectType() == "Texture") and not(region:GetName()) and not(region == button.ignoreTexture) then
				region:RemoveTextures()
			end
		end

		F.StyleActionButton(button)

		local Durability = button:CreateFontString(button:GetName() .. "Durability", "OVERLAY")
		Durability:SetJustifyH("CENTER")
		Durability:SetJustifyV("MIDDLE")
		Durability:SetPoint("CENTER", button, "BOTTOM", 2, 10)
		Durability:SetShadowOffset(0, 0)
		Durability:SetFontObject(GUIS_PanelFont)
		Durability:Hide()
		
		button.Durability = Durability
	end

	for i = 1, NUM_FACTIONS_DISPLAYED do
		local bar = _G["ReputationBar" .. i .. "ReputationBar"]
		local barText = _G["ReputationBar" .. i .. "ReputationBarFactionStanding"]
		local name = _G["ReputationBar" .. i]
		local expandorcollapse = _G["ReputationBar" .. i .. "ExpandOrCollapseButton"]
		
		if (expandorcollapse) then
			expandorcollapse:SetUITemplate("arrow")
		end

		if (name) then
			name:RemoveTextures()
		end

		if (bar) then
			bar:SetUITemplate("statusbar", true)
			barText:SetFontObject(GUIS_SystemFontSmallWhite)
		end	
	end
	
	local UpdateCurrency = function()
		for i = 1, GetCurrencyListSize() do
			local currency = _G["TokenFrameContainerButton" .. i]
			
			if (currency) then
			
				currency.highlight:RemoveTextures()
				currency.categoryMiddle:RemoveTextures()
				currency.categoryLeft:RemoveTextures()
				currency.categoryRight:RemoveTextures()
				
				if (currency.icon) then
					currency.icon:SetTexCoord(2/25, 23/25, 2/25, 23/25)
				end
			end
		end
	end

	local UpdateEQList = function(self)
		for i, v in pairs(PaperDollEquipmentManagerPane.buttons) do
			v.BgTop:SetTexture("")
			v.BgBottom:SetTexture("")
			v.BgMiddle:SetTexture("")
			v.icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			v.icon:ClearAllPoints()
			v.icon:SetSize(v:GetHeight()-16, v:GetHeight()-16)
			v.icon:SetPoint("TOPLEFT", v, "TOPLEFT", 8, -8)
			v.icon:SetPoint("BOTTOMRIGHT", v, "BOTTOMLEFT", 8 + (v:GetHeight()-16), 8)

			if not(v.IconBackdrop) then
				local IconBackdrop = CreateFrame("Frame", nil, v)
				IconBackdrop:SetAllPoints(v.icon)
				IconBackdrop:SetUITemplate("border")

				v.IconBackdrop = IconBackdrop
			end
		end
	end

	local UpdateFlyoutSlot = function(self)
		PaperDollFrameItemFlyoutButtons:RemoveTextures()

		for i = 1, PDFITEMFLYOUT_MAXITEMS do
			local button = _G[PaperDollFrameItemFlyoutButtonName .. i]

			if (button) then 
				if not(button.gUISkinned) then
					button:RemoveTextures()
					F.StyleActionButton(button)
					
					button.gUISkinned = true
				end
			end
		end
	end

	local UpdateGearSlot = function()
		for i, v in pairs(gearSlots) do

			local item = _G["Character" .. v]
			local slot = GetInventorySlotInfo(v)
			local itemID = GetInventoryItemID("player", slot)
			
			if (itemID) then
				local quality = (select(3, GetItemInfo(itemID)))
				local current, maximum = GetInventoryItemDurability(slot)
				
				if (quality) then
					local r, g, b, hex = GetItemQualityColor(quality)
					item:SetBackdropBorderColor(r, g, b)
				end
				
				if (maximum) and (maximum > 0) and (current < maximum) then -- only show for damaged items
					local r, g, b = F.GetDurabilityColor(current, maximum)
					item.Durability:SetText(("|cFF%s%d%%|r"):format(RGBToHex(r, g, b), (current or 0)/maximum * 100))
					item.Durability:Show()
				else
					item.Durability:Hide()
				end
			else
				item:SetBackdropBorderColor(unpack(C["border"]))
				item.Durability:Hide()
			end
		end
	end
	
	local UpdateSideBar = function ()
		for i = 1, #PAPERDOLL_SIDEBARS do
			local button = _G["PaperDollSidebarTab"..i]
			if (button) then
				button.Highlight:SetTexture(1, 1, 1, 0.3)
				button.Highlight:ClearAllPoints()
				button.Highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
				button.Highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
				
				button.Hider:SetTexture(0, 0, 0, 0.6)
				button.Hider:ClearAllPoints()
				button.Hider:SetPoint("TOPLEFT", button, "TOPLEFT", -2, 2)
				button.Hider:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)

				button.TabBg:Hide()
				button.TabBg.Show = noop

				local border = button:SetUITemplate("border")
				border:ClearAllPoints()
				border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
				border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
			end
		end
	end
	
	local UpdateTitlesList = function(self)
		for _, button in pairs(PaperDollTitlesPane.buttons) do
			button.BgTop:SetTexture("")
			button.BgBottom:SetTexture("")
			button.BgMiddle:SetTexture("")
		end
	end

	CharacterFrame:HookScript("OnShow", UpdateGearSlot)

	if (PaperDollFrameItemFlyout) then
		PaperDollFrameItemFlyout:HookScript("OnShow", UpdateFlyoutSlot)
		hooksecurefunc(PaperDollFrameItemFlyout, "SetPoint", UpdateFlyoutSlot)
	end

	if (PaperDollEquipmentManagerPane) then PaperDollEquipmentManagerPane:HookScript("OnShow", UpdateEQList) end
	if (PaperDollTitlesPane) then PaperDollTitlesPane:HookScript("OnShow", UpdateTitlesList) end
	TokenFrame:HookScript("OnShow", UpdateCurrency)

	RegisterCallback("PLAYER_EQUIPMENT_CHANGED", UpdateGearSlot)
	RegisterCallback("UPDATE_INVENTORY_DURABILITY", UpdateGearSlot)

	if (PaperDollFrame_UpdateSidebarTabs) then hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", UpdateSideBar) end
end
