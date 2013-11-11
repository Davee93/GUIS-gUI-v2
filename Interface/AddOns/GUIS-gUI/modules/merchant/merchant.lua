--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...
local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: Merchant")

-- Lua API
local min, max = math.min, math.max
local print = print
local select = select

-- WoW API
local BuyMerchantItem = BuyMerchantItem
local CanMerchantRepair = CanMerchantRepair
local GetGuildBankMoney = GetGuildBankMoney
local GetGuildBankWithdrawMoney = GetGuildBankWithdrawMoney
local GetMoney = GetMoney
local GetMerchantItemLink = GetMerchantItemLink
local GetMerchantItemMaxStack = GetMerchantItemMaxStack
local GetContainerItemID = GetContainerItemID
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerNumSlots = GetContainerNumSlots
local GetItemInfo = GetItemInfo
local GetRepairAllCost = GetRepairAllCost
local IsInGuild = IsInGuild
local RepairAllItems = RepairAllItems
local UseContainerItem = UseContainerItem

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local CreateChatCommand = function(...) module:CreateChatCommand(...) end

local defaults = {
	autorepair = true;
	autosell = true;
	guildrepair = true;
	detailedreport = false;
}

local menuTable = {
	{
		type = "group";
		name = module:GetName();
		order = 1;
		virtual = true;
		children = {
			{
				type = "widget";
				element = "Title";
				order = 1;
				msg = F.getName(module:GetName());
			};
			{
				type = "widget";
				element = "Text";
				order = 2;
				msg = L["Here you can configure the options for automatic actions upon visiting a merchant, like selling junk and repairing your armor."];
			};
			{
				type = "group";
				order = 5;
				virtual = true;
				children = {
					{ -- detailedreport
						type = "widget";
						element = "CheckButton";
						name = "detailedreport";
						order = 11;
						indented = true;
						msg = L["Show detailed sales reports"];
						desc = L["Enabling this option will show a detailed report of the automatically sold items in the default chat frame. Disabling it will restrict the report to gold earned, and the cost of repairs."];
						set = function(self) 
							GUIS_DB["merchant"].detailedreport = not(GUIS_DB["merchant"].detailedreport)
						end;
						get = function() return GUIS_DB["merchant"].detailedreport end;
					};
					{ -- autosell
						type = "widget";
						element = "CheckButton";
						name = "autosell";
						order = 10;
						msg = L["Automatically sell poor quality items"];
						desc = L["Enabling this option will automatically sell poor quality items in your bags whenever you visit a merchant."];
						set = function(self) 
							GUIS_DB["merchant"].autosell = not(GUIS_DB["merchant"].autosell)
							self:onrefresh()
						end;
						get = function() return GUIS_DB["merchant"].autosell end;
						onrefresh = function(self)
							if (GUIS_DB["merchant"].autosell) then
								self.parent.child.detailedreport:Enable()
							else
								self.parent.child.detailedreport:Disable()
							end
						end;
						init = function(self)
							self:onrefresh()
						end;
					};
					{ -- autorepair
						type = "widget";
						element = "CheckButton";
						name = "autorepair";
						order = 15;
						msg = L["Automatically repair your armor and weapons"];
						desc = L["Enabling this option will automatically repair your items whenever you visit a merchant with repair capability, as long as you have sufficient funds to pay for the repairs."];
						set = function(self) 
							GUIS_DB["merchant"].autorepair = not(GUIS_DB["merchant"].autorepair)
							self:onrefresh()
						end;
						get = function() return GUIS_DB["merchant"].autorepair end;
						onrefresh = function(self)
							if (GUIS_DB["merchant"].autorepair) then
								self.parent.child.guildrepair:Enable()
							else
								self.parent.child.guildrepair:Disable()
							end
						end;
						init = function(self)
							self:onrefresh()
						end;
					};
					{ -- guildrepair
						type = "widget";
						element = "CheckButton";
						name = "guildrepair";
						order = 20;
						indented = true;
						msg = L["Use your available Guild Bank funds to when available"];
						desc = L["Enabling this option will cause the automatic repair to be done using Guild funds if available."];
						set = function(self) 
							GUIS_DB["merchant"].guildrepair = not(GUIS_DB["merchant"].guildrepair)
						end;
						get = function() return GUIS_DB["merchant"].guildrepair end;
					};
				};
			};
		};
	};
}

module.MERCHANT_SHOW = function(self)
	local gain, sold 		= 0, 0
	local repaired 			= false
	local useGuildFunds 	= (IsInGuild()) and GUIS_DB.merchant.guildrepair or false
	local usedGuildFunds 	= false
	local yourGuildFunds 	= min((GetGuildBankWithdrawMoney() ~= -1) and GetGuildBankWithdrawMoney() or GetGuildBankMoney(), GetGuildBankMoney())
	local repairCost 		= (select(1, GetRepairAllCost())) or 0

	local itemID, count, link, rarity, price, stack
	if (GUIS_DB.merchant.autosell == true) then
		for bag = 0,4,1 do 
			for slot = 1, GetContainerNumSlots(bag), 1 do 
				itemID = GetContainerItemID(bag, slot)
				if itemID then
					count = (select(2, GetContainerItemInfo(bag, slot)))
					_, link, rarity, _, _, _, _, _, _, _, price = GetItemInfo(itemID)

					if rarity == 0 then
						stack = (price or 0) * (count or 1)
						sold = sold + stack
						
						if GUIS_DB.merchant.detailedreport then
							print(L["-%s|cFF00DDDDx%d|r %s"]:format(link, count, ("[money:%d]"):format(stack):tag()))
						end
						
						UseContainerItem(bag, slot)
					end
				end 
			end 
		end
		gain = gain + sold
	end

	if sold > 0 then 
		print(L["Earned %s"]:format(("[money:%d]"):format(sold):tag()))
	end

	if GUIS_DB.merchant.autorepair and CanMerchantRepair() and repairCost > 0 then

		if max(GetMoney(), yourGuildFunds) > repairCost then
		
			if (useGuildFunds and yourGuildFunds > repairCost) and MerchantGuildBankRepairButton:IsEnabled() and MerchantGuildBankRepairButton:IsShown() then
				RepairAllItems(1)
				usedGuildFunds = true
				repaired = true
				print(L["You repaired your items for %s using Guild Bank funds"]:format(("|cffff0000[money:%d]|r"):format(repairCost):tag()))
	
			elseif GetMoney() > repairCost then
				RepairAllItems() 
				repaired = true
				print(L["You repaired your items for %s"]:format(("|cffff0000[money:%d]|r"):format(repairCost):tag()))
				
				gain = gain - repairCost
			end
			
		else
			print(L["You haven't got enough available funds to repair!"])
		end
	end

	if gain > 0 then
		print(L["Your profit is %s"]:format(("[money:%d]"):format(gain):tag()))
		
	elseif gain < 0 then 
		print(L["Your expenses are %s"]:format(("|cFFFF0000[money:%d]|r"):format(-gain):tag()))
	end

end

-- update menu options
module.PostUpdateGUI = function(self)
	LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu"):Refresh(F.getName(self:GetName()))
end

module.RestoreDefaults = function(self)
	GUIS_DB["merchant"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["merchant"] = GUIS_DB["merchant"] or {}
	GUIS_DB["merchant"] = ValidateTable(GUIS_DB["merchant"], defaults)
end

module.OnInit = function(self)
	if F.kill(self:GetName()) then 
		self:Kill()
		return 
	end
	
	-- pre-hook the modified click handler
	local OrigMerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
	MerchantItemButton_OnModifiedClick = function(self, ...)
		if (IsAltKeyDown()) then
			local ID = self:GetID()
			
			if (ID) then
				local max = select(8, GetItemInfo(GetMerchantItemLink(ID)))
				if (max and max > 1) then
					BuyMerchantItem(ID, GetMerchantItemMaxStack(ID))
				end
			end
		end
		
		OrigMerchantItemButton_OnModifiedClick(self, ...)
	end
	
	-- set the tooltip to reflect the added functionality
	ITEM_VENDOR_STACK_BUY = ITEM_VENDOR_STACK_BUY .. "|n" .. L["<Alt-Click to buy the maximum amount>"]
	
	-- create the options menu
	do
		local restoreDefaults = function()
			if (InCombatLockdown()) then 
				print(L["Can not apply default settings while engaged in combat."])
				return
			end
			
			-- restore all frame positions
			self:RestoreDefaults()
			
			-- request a restart if needed
			F.RestartIfScheduled()
		end
		
		local cancelChanges = function()
		end
		
		local applySettings = function()
		end
		
		local applyChanges = function()
		end
		
		local gOM = LibStub("gCore-3.0"):GetModule("GUIS-gUI: OptionsMenu")
		gOM:RegisterWithBlizzard(gOM:New(menuTable), F.getName(self:GetName()), 
 			"default", restoreDefaults, 
			"cancel", cancelChanges, 
			"okay", applyChanges)
	end

	CreateChatCommand(function() 
		GUIS_DB["merchant"].autorepair = true 
		print(L["Your items will now be automatically repaired when visiting a vendor with repair capabilities"])
		module:PostUpdateGUI()
	end, "enableautorepair")
	
	CreateChatCommand(function() 
		GUIS_DB["merchant"].autorepair = false 
		print(L["Your items will no longer be automatically repaired"])
		module:PostUpdateGUI()
	end, "disableautorepair")
	
	CreateChatCommand(function() 
		GUIS_DB["merchant"].autosell = true 
		print(L["Poor Quality items will now be automatically sold when visiting a vendor"])
		module:PostUpdateGUI()
	end, "enableautosell")
	
	CreateChatCommand(function() 
		GUIS_DB["merchant"].autosell = false 
		print(L["Poor Quality items will no longer be automatically sold"])
		module:PostUpdateGUI()
	end, "disableautosell")
	
	CreateChatCommand(function() 
		GUIS_DB["merchant"].guildrepair = true 
		print(L["Your items will now be repaired using the Guild Bank if the options and the funds are available"])
		module:PostUpdateGUI()
	end, "enableguildrepair")
	
	CreateChatCommand(function() 
		GUIS_DB["merchant"].guildrepair = false 
		print(L["Your items will now be repaired using your own funds"])
		module:PostUpdateGUI()
	end, "disableguildrepair")
	
	CreateChatCommand(function() 
		GUIS_DB["merchant"].detailedreport = true 
		print(L["Detailed reports for autoselling of Poor Quality items turned on"])
		module:PostUpdateGUI()
	end, "enabledetailedreport")
	
	CreateChatCommand(function() 
		GUIS_DB["merchant"].detailedreport = false 
		print(L["Detailed reports for autoselling of Poor Quality items turned off, only summary will be shown"])
		module:PostUpdateGUI()
	end, "disabledetailedreport")

	self:RegisterEvent("MERCHANT_SHOW")
end

