--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningTradeSkill")

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

	local SkinFunc = function()
		local panelAlpha, r, g, b = 1/5, unpack(C["overlay"])
		
		TradeSkillFrame:RemoveTextures()
		TradeSkillFramePortrait:RemoveTextures()
		TradeSkillDetailScrollFrame:RemoveTextures()
		TradeSkillDetailScrollChildFrame:RemoveTextures()
		TradeSkillExpandButtonFrame:RemoveTextures()
		TradeSkillFrameInset:RemoveTextures()
		TradeSkillListScrollFrame:RemoveTextures()
		TradeSkillGuildFrame:RemoveTextures()
		
		TradeSkillFramePortrait:Kill()
		TradeSkillFrameTabardEmblem:Kill()
		
		TradeSkillDecrementButton:SetUITemplate("arrow")
		TradeSkillIncrementButton:SetUITemplate("arrow")
		TradeSkillCollapseAllButton:SetUITemplate("arrow")

		TradeSkillCancelButton:SetUITemplate("button", true)
		TradeSkillCreateAllButton:SetUITemplate("button", true)
		TradeSkillCreateButton:SetUITemplate("button", true)
		TradeSkillFilterButton:SetUITemplate("button", true)
		TradeSkillViewGuildCraftersButton:SetUITemplate("button", true)

		TradeSkillFrameCloseButton:SetUITemplate("closebutton")
		TradeSkillGuildFrameCloseButton:SetUITemplate("closebutton")

		TradeSkillFrameSearchBox:SetUITemplate("editbox")
		TradeSkillInputBox:SetUITemplate("editbox")

		TradeSkillFrame:SetUITemplate("backdrop", nil, -6, -2, 0, 0)
		TradeSkillGuildFrame:SetUITemplate("simplebackdrop")
		TradeSkillGuildFrameContainer:SetUITemplate("simplebackdrop"):SetBackdropColor(r, g, b, panelAlpha)

--		TradeSkillSkillIcon:SetUITemplate("backdrop")
		
		local listBackdrop = CreateFrame("Frame", nil, TradeSkillFrame)
		listBackdrop:SetPoint("TOP", TradeSkillListScrollFrame, "TOP", 0, 0)
		listBackdrop:SetPoint("BOTTOM", TradeSkillListScrollFrame, "BOTTOM", 0, 0)
		listBackdrop:SetPoint("LEFT", TradeSkillListScrollFrame, "LEFT", 0, 0)
		listBackdrop:SetPoint("RIGHT", TradeSkillFrame, "RIGHT", -8, 0)
		
		local detailBackdrop = CreateFrame("Frame", nil, TradeSkillFrame)
		detailBackdrop:SetPoint("TOP", TradeSkillDetailScrollFrame, "TOP", 0, 0)
		detailBackdrop:SetPoint("BOTTOM", TradeSkillDetailScrollFrame, "BOTTOM", 0, 0)
		detailBackdrop:SetPoint("LEFT", TradeSkillDetailScrollFrame, "LEFT", 0, 0)
		detailBackdrop:SetPoint("RIGHT", TradeSkillFrame, "RIGHT", -8, 0)
		
		detailBackdrop:SetUITemplate("backdrop", nil, 0, 0, -2, 0):SetBackdropColor(r, g, b, panelAlpha)
		listBackdrop:SetUITemplate("backdrop", nil, 0, 0, 0, 0):SetBackdropColor(r, g, b, panelAlpha)
		
		local iconBackdrop = CreateFrame("Frame", nil, TradeSkillDetailScrollChildFrame)
		iconBackdrop:SetAllPoints(TradeSkillSkillIcon)
		iconBackdrop:SetUITemplate("backdrop")
		TradeSkillSkillIcon:SetParent(iconBackdrop)
		
		local iconCandy = CreateFrame("Frame", nil, TradeSkillSkillIcon)
		iconCandy:SetFrameLevel(TradeSkillSkillIcon:GetFrameLevel() + 1)
		iconCandy:SetPoint("TOPLEFT", 3, -3)
		iconCandy:SetPoint("BOTTOMRIGHT", -3, 3)
		F.GlossAndShade(iconCandy)
		TradeSkillSkillIcon.iconCandy = iconCandy
		
		TradeSkillListScrollFrameScrollBar:SetUITemplate("scrollbar")
		TradeSkillDetailScrollFrameScrollBar:SetUITemplate("scrollbar")
		TradeSkillRankFrame:SetUITemplate("statusbar", true)
		
		local point, anchor, relpoint, x, y = TradeSkillDetailScrollFrame:GetPoint()
		TradeSkillDetailScrollFrame:SetPoint(point, anchor, relpoint, x, -8)
		TradeSkillDetailScrollFrame:SetHeight(TradeSkillDetailScrollFrame:GetHeight() - 8)
		
		TradeSkillLinkButton:GetNormalTexture():SetTexCoord(0.25, 0.7, 0.37, 0.75)
		TradeSkillLinkButton:GetPushedTexture():SetTexCoord(0.25, 0.7, 0.45, 0.8)
		TradeSkillLinkButton:GetHighlightTexture():Hide()
		TradeSkillLinkButton:GetHighlightTexture().Show = noop
		TradeSkillLinkButton:SetSize(16, 16)
		TradeSkillLinkButton:SetPoint("LEFT", 12, 0)
		
		TradeSkillRankFrame:SetPoint("TOPLEFT", 45, -32)
		TradeSkillFrameSearchBox:SetPoint("TOPLEFT", TradeSkillRankFrame, "BOTTOMLEFT", 28, -8)

		for i = 1, TRADE_SKILLS_DISPLAYED do
			local button = _G["TradeSkillSkill" .. i]
			button:SetUITemplate("arrow", "collapse")
		end
		
		local updateTradeSkillList = function() 
			local buttonIndex
			local hasFilterBar = TradeSkillFilterBar:IsShown()
			local skillOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame)
			
			for i = 1, TRADE_SKILLS_DISPLAYED do
				local skillName, skillType, numAvailable, isExpanded, altVerb, numSkillUps = GetTradeSkillInfo(i + skillOffset)

				if (hasFilterBar) then
					buttonIndex = i+1
				else
					buttonIndex = i
				end
				
				local button = _G["TradeSkillSkill" .. buttonIndex]
				if (button) then
					if (skillType == "header") then
						button:SetNormalTexture(button:GetNormalTexture():GetTexture())
					else
						-- we need to override our smart arrow function here
						button:BlizzSetNormalTexture("")
					end
				end
			end
		end
		hooksecurefunc("TradeSkillFrame_Update", updateTradeSkillList)
		
		local FixReagents = function()
			if (TradeSkillSkillIcon:GetNormalTexture()) then
				TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(5/64, 59/64, 5/64, 59/64)
				TradeSkillSkillIcon:GetNormalTexture():ClearAllPoints()
				TradeSkillSkillIcon:GetNormalTexture():SetPoint("TOPLEFT", 3, -3)
				TradeSkillSkillIcon:GetNormalTexture():SetPoint("BOTTOMRIGHT", -3, 3)
			end

			for i=1, MAX_TRADE_SKILL_REAGENTS do
				local button = _G["TradeSkillReagent" .. i]
				local icon = _G["TradeSkillReagent" .. i .. "IconTexture"]
				local count = _G["TradeSkillReagent" .. i .. "Count"]
				local name = _G["TradeSkillReagent" .. i .. "Name"]

				button:RemoveTextures()
				button:SetUITemplate("simplebackdrop-indented"):SetBackdropColor(r, g, b, 1/3)
				
				icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
				icon:SetDrawLayer("OVERLAY", -1)
				icon:ClearAllPoints()
				icon:SetPoint("TOPLEFT", button, "TOPLEFT", 8, -8)
				icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", 8 + (button:GetHeight() - 16), 8)
				
				if not(icon.backdrop) then
					local BackdropHolder = CreateFrame("Frame", nil, button)
					BackdropHolder:SetFrameLevel(button:GetFrameLevel() - 1)
					BackdropHolder:SetAllPoints(icon)

					local iconCandy = CreateFrame("Frame", nil, button)
					iconCandy:SetAllPoints(icon)
					F.GlossAndShade(iconCandy)
					
					icon.backdrop = BackdropHolder:SetUITemplate("border")
				end
				
				icon:SetParent(icon.backdrop)

				count:SetParent(icon.backdrop)
				count:SetDrawLayer("OVERLAY")

				name:SetParent(icon.backdrop)
				name:SetDrawLayer("OVERLAY")

				_G["TradeSkillReagent" .. i .. "NameFrame"]:Hide()
				_G["TradeSkillReagent" .. i .. "NameFrame"].Show = noop
			end
		end
		hooksecurefunc("TradeSkillFrame_SetSelection", FixReagents)
		
		-- extra button for the enchantframe
		do
			local scroll, enchant = 38682, GetSpellInfo(7411)

			local enchantScrollButton = CreateFrame("Button", "GUIS_CreateScrollOfEnchant", TradeSkillFrame, "MagicButtonTemplate")
			enchantScrollButton:SetPoint("TOPRIGHT", TradeSkillCreateButton, "TOPLEFT")
			enchantScrollButton:SetScript("OnClick",function()
				DoTradeSkill(TradeSkillFrame.selectedSkill)
				UseItemByName(scroll)
			end)
			
			enchantScrollButton:SetScript("OnShow", function(self) 
				self:SetUITemplate("button", true)
				self:SetScript("OnShow", nil)
			end)
			
			local enchantScrollButton = function(index)
				local skillName, skillType, numAvailable, isExpanded, serviceType, numSkillUps = GetTradeSkillInfo(index)
				
				if (((serviceType) and (CURRENT_TRADESKILL == enchant)) or ((serviceType) and GetLocale():find("zh"))) 
				and not((IsTradeSkillGuild()) or (IsTradeSkillLinked())) then
					
					local scrolls = GetItemCount(scroll)
					enchantScrollButton:SetText(L["Scroll"] .. " (" .. scrolls .. ")")

					local failed, reagentName, reagentTexture, reagentCount, playerReagentCount
					for i = 1, GetTradeSkillNumReagents(index) do
						reagentName, reagentTexture, reagentCount, playerReagentCount = GetTradeSkillReagentInfo(index, i)
						if (playerReagentCount < reagentCount) then
							failed = true
						end
					end
					
					if ((skillName) and not(scrolls == 0) and not(failed)) then
						enchantScrollButton:Enable()
					else
						enchantScrollButton:Disable()
					end

					enchantScrollButton:Show()
				else
					enchantScrollButton:Hide()
				end
			end
			hooksecurefunc("TradeSkillFrame_SetSelection", enchantScrollButton)
		end
	end
	F.SkinAddOn("Blizzard_TradeSkillUI", SkinFunc)
end
