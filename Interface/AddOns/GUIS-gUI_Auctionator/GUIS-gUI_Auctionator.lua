if not IsAddOnLoaded("Auctionator") then return end

local GUIS = LibStub("gCore-3.0"):GetModule("GUIS-gUI: Core")
local M = LibStub("gMedia-3.0")
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end

local function styleAuctionator()

	-- Options skinning
	
	Atr_BasicOptionsFrame:RemoveTextures()
	Atr_BasicOptionsFrame:SetUITemplate('simplebackdrop')
	Atr_TooltipsOptionsFrame:RemoveTextures()
	Atr_TooltipsOptionsFrame:SetUITemplate('simplebackdrop')
	Atr_UCConfigFrame:RemoveTextures()
	Atr_UCConfigFrame:SetUITemplate('simplebackdrop')
	Atr_StackingOptionsFrame:RemoveTextures()
	Atr_StackingOptionsFrame:SetUITemplate('simplebackdrop')
	Atr_ScanningOptionsFrame:RemoveTextures()
	Atr_ScanningOptionsFrame:SetUITemplate('simplebackdrop')
	AuctionatorResetsFrame:RemoveTextures()
	AuctionatorResetsFrame:SetUITemplate('simplebackdrop')
	Atr_ShpList_Options_Frame:RemoveTextures()
	Atr_ShpList_Options_Frame:SetUITemplate('simplebackdrop')
	AuctionatorDescriptionFrame:RemoveTextures()
	AuctionatorDescriptionFrame:SetUITemplate('simplebackdrop')
	Atr_Stacking_List:RemoveTextures()
	Atr_Stacking_List:SetUITemplate('simplebackdrop')
	Atr_ShpList_Frame:RemoveTextures()
	Atr_ShpList_Frame:SetUITemplate('simplebackdrop')
	
	AuctionatorOption_Enable_Alt_CB:SetUITemplate('checkbox')
	AuctionatorOption_Open_All_Bags_CB:SetUITemplate('checkbox')
	AuctionatorOption_Show_StartingPrice_CB:SetUITemplate('checkbox')
	ATR_tipsVendorOpt_CB:SetUITemplate('checkbox')
	ATR_tipsAuctionOpt_CB:SetUITemplate('checkbox')
	ATR_tipsDisenchantOpt_CB:SetUITemplate('checkbox')
	
	AuctionatorOption_Deftab:SetUITemplate('dropdown', true)
	AuctionatorOption_Deftab:SetWidth(150)
	Atr_tipsShiftDD:SetUITemplate('dropdown', true)
	Atr_tipsShiftDD:SetWidth(150)
	Atr_deDetailsDD:SetUITemplate('dropdown', true)
	Atr_deDetailsDD:SetWidth(150)
	Atr_scanLevelDD:SetUITemplate('dropdown', true)
	Atr_scanLevelDD:SetWidth(150)
	Atr_deDetailsDDText:SetJustifyH('RIGHT')
	
	local moneyEditBoxes = {
		'UC_5000000_MoneyInput',
		'UC_1000000_MoneyInput',
		'UC_200000_MoneyInput',
		'UC_50000_MoneyInput',
		'UC_10000_MoneyInput',
		'UC_2000_MoneyInput',
		'UC_500_MoneyInput',
	}
	for i = 1, #moneyEditBoxes do
		_G[moneyEditBoxes[i]..'Gold']:SetUITemplate('editbox')
		_G[moneyEditBoxes[i]..'Silver']:SetUITemplate('editbox')
		_G[moneyEditBoxes[i]..'Copper']:SetUITemplate('editbox')
	end
	Atr_Starting_Discount:SetUITemplate('editbox')
	Atr_ScanOpts_MaxHistAge:SetUITemplate('editbox')
	
	Atr_UCConfigFrame_Reset:SetUITemplate('button')
	Atr_StackingOptionsFrame_Edit:SetUITemplate('button')
	Atr_StackingOptionsFrame_New:SetUITemplate('button')
	
	for i = 1, Atr_ShpList_Options_Frame:GetNumChildren() do
		local object = select(i, Atr_ShpList_Options_Frame:GetChildren())
		if object:GetObjectType() == 'Button' then
			object:SetUITemplate('button')
		end
	end
	
	for i = 1, AuctionatorResetsFrame:GetNumChildren() do
		local object = select(i, AuctionatorResetsFrame:GetChildren())
		if object:GetObjectType() == 'Button' then
			object:SetUITemplate('button')
		end
	end
	
	--[[ Main window skinning ]]--
	
	local AtrSkin = CreateFrame('Frame')
	AtrSkin:RegisterEvent('AUCTION_HOUSE_SHOW')
	AtrSkin:SetScript('OnEvent', function(self)
		Atr_Duration:SetUITemplate('dropdown')
		Atr_DropDownSL:SetUITemplate('dropdown')
		Atr_ASDD_Class:SetUITemplate('dropdown')
		Atr_ASDD_Subclass:SetUITemplate('dropdown')
		
		Atr_Search_Button:SetUITemplate('button')
		Atr_Back_Button:SetUITemplate('button')
		Atr_Buy1_Button:SetUITemplate('button')
		Atr_Adv_Search_Button:SetUITemplate('button')
		Atr_FullScanButton:SetUITemplate('button')
		Auctionator1Button:SetUITemplate('button')
		
		-- Custom SetPoints. They are off with GUI skinning.
		Atr_ListTabsTab1:SetUITemplate('tab')
		Atr_ListTabsTab1:SetPoint('BOTTOM', Atr_HeadingsBar, 'TOP', 0, 4)
		Atr_ListTabsTab2:SetUITemplate('tab')
		Atr_ListTabsTab2:SetPoint('BOTTOM', Atr_HeadingsBar, 'TOP', 0, 4)
		Atr_ListTabsTab3:SetUITemplate('tab')
		Atr_ListTabsTab3:SetPoint('BOTTOM', Atr_HeadingsBar, 'TOP', 0, 4)
		
		Atr_CreateAuctionButton:SetUITemplate('button')
		Atr_RemFromSListButton:SetUITemplate('button')
		Atr_AddToSListButton:SetUITemplate('button')
		Atr_SrchSListButton:SetUITemplate('button')
		Atr_MngSListsButton:SetUITemplate('button')
		Atr_NewSListButton:SetUITemplate('button')
		Atr_CheckActiveButton:SetUITemplate('button')
		AuctionatorCloseButton:SetUITemplate('button')
		Atr_CancelSelectionButton:SetUITemplate('button')
		Atr_FullScanStartButton:SetUITemplate('button')
		Atr_FullScanDone:SetUITemplate('button')
		Atr_CheckActives_Yes_Button:SetUITemplate('button')
		Atr_CheckActives_No_Button:SetUITemplate('button')
		Atr_Adv_Search_ResetBut:SetUITemplate('button')
		Atr_Adv_Search_OKBut:SetUITemplate('button')
		Atr_Adv_Search_CancelBut:SetUITemplate('button')
		Atr_Buy_Confirm_OKBut:SetUITemplate('button')
		Atr_Buy_Confirm_CancelBut:SetUITemplate('button')
		Atr_SaveThisList_Button:SetUITemplate('button')

		Atr_StackPriceGold:SetUITemplate('editbox')
		Atr_StackPriceSilver:SetUITemplate('editbox')
		Atr_StackPriceCopper:SetUITemplate('editbox')
		Atr_StartingPriceGold:SetUITemplate('editbox')
		Atr_StartingPriceSilver:SetUITemplate('editbox')
		Atr_StartingPriceCopper:SetUITemplate('editbox')
		Atr_ItemPriceGold:SetUITemplate('editbox')
		Atr_ItemPriceSilver:SetUITemplate('editbox')
		Atr_ItemPriceCopper:SetUITemplate('editbox')
		Atr_Batch_NumAuctions:SetUITemplate('editbox')
		Atr_Batch_Stacksize:SetUITemplate('editbox')
		Atr_Search_Box:SetUITemplate('editbox')
		Atr_AS_Searchtext:SetUITemplate('editbox')
		Atr_AS_Minlevel:SetUITemplate('editbox')
		Atr_AS_Maxlevel:SetUITemplate('editbox')
		Atr_AS_MinItemlevel:SetUITemplate('editbox')
		Atr_AS_MaxItemlevel:SetUITemplate('editbox')

		Atr_FullScanResults:RemoveTextures()
		Atr_FullScanResults:SetUITemplate('backdrop')
		Atr_Adv_Search_Dialog:RemoveTextures()
		Atr_Adv_Search_Dialog:SetUITemplate('backdrop')
		Atr_FullScanFrame:RemoveTextures()
		Atr_FullScanFrame:SetUITemplate('backdrop')
		Atr_HeadingsBar:RemoveTextures()
		Atr_HeadingsBar:SetUITemplate('backdrop')
		Atr_HeadingsBar:ClearAllPoints()
		Atr_HeadingsBar:SetPoint('CENTER', UIParent, 'CENTER', -426, 238) -- Same thing here. clear then set
		Atr_HeadingsBar:SetHeight(19)
		Atr_Error_Frame:RemoveTextures()
		Atr_Error_Frame:SetUITemplate('backdrop')
		Atr_Hlist:RemoveTextures()
		Atr_Hlist:SetWidth(196)
		Atr_Hlist:SetUITemplate('simplebackdrop', true)
		Atr_Hlist:ClearAllPoints()
		Atr_Hlist:SetPoint("TOPLEFT", -195, -75)
		Atr_Buy_Confirm_Frame:RemoveTextures()
		Atr_Buy_Confirm_Frame:SetUITemplate('backdrop')
		Atr_CheckActives_Frame:RemoveTextures()
		Atr_CheckActives_Frame:SetUITemplate('backdrop')
		
		Atr_RecommendItem_Tex:SetUITemplate('backdrop') -- There you are!

		-- resize some buttons to fit
		Atr_SrchSListButton:SetWidth(196)
		Atr_MngSListsButton:SetWidth(196)
		Atr_NewSListButton:SetWidth(196)
		Atr_CheckActiveButton:SetWidth(196)

		-- Button Positions
		AuctionatorCloseButton:ClearAllPoints()
		AuctionatorCloseButton:SetPoint("BOTTOMLEFT", Atr_Main_Panel, "BOTTOMRIGHT", -17, 12)
		Atr_Buy1_Button:SetPoint("RIGHT", AuctionatorCloseButton, "LEFT", -5, 0)
		Atr_CancelSelectionButton:SetPoint("RIGHT", Atr_Buy1_Button, "LEFT", -5, 0)
		Atr_SellControls_Tex:SetUITemplate("itembackdrop")

		for i = 4, AuctionFrame.numTabs do -- We need this to start at 4
			_G["AuctionFrameTab"..i]:SetUITemplate('tab')
		end

		self:UnregisterEvent('AUCTION_HOUSE_SHOW')
	end)
end

if IsAddOnLoaded("Auctionator") then
	styleAuctionator()
end

local init = CreateFrame("Frame")
init:RegisterEvent("ADDON_LOADED")
init:SetScript("OnEvent", function(self, _, addon)
	if addon == "Auctionator" then -- in case we load it on demand
		styleAuctionator()
		self:UnregisterEvent("ADDON_LOADED")
		init = nil
	end
end)
