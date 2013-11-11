--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningQuest")

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
	
	EmptyQuestLogFrame:RemoveTextures()
	QuestDetailScrollFrame:RemoveTextures()
	QuestDetailScrollChildFrame:RemoveTextures()
	QuestFrame:RemoveTextures()
	QuestFrameDetailPanel:RemoveTextures()
	QuestFrameRewardPanel:RemoveTextures()
	QuestFrameProgressPanel:RemoveTextures()
	QuestInfoSkillPointFrame:RemoveTextures()
	QuestInfoItemHighlight:RemoveTextures()
	QuestLogCount:RemoveTextures()
	QuestLogFrame:RemoveTextures()
	QuestLogDetailFrame:RemoveTextures()
	QuestLogDetailScrollFrame:RemoveTextures()
	QuestLogFrameShowMapButton:RemoveTextures()
	QuestNPCModel:RemoveTextures()
	QuestNPCModelTextFrame:RemoveTextures()
	QuestRewardScrollFrame:RemoveTextures()
	QuestRewardScrollChildFrame:RemoveTextures()
	QuestFrameRewardPanelBotRight:RemoveTextures()
	QuestFrameRewardPanelMaterialTopLeft:RemoveTextures()
	QuestFrameRewardPanelMaterialTopRight:RemoveTextures()
	QuestFrameRewardPanelMaterialBotLeft:RemoveTextures()
	QuestFrameRewardPanelMaterialBotRight:RemoveTextures()
	QuestFrameDetailPanelBotRight:RemoveTextures()
	QuestFrameDetailPanelMaterialTopLeft:RemoveTextures()
	QuestFrameDetailPanelMaterialTopRight:RemoveTextures()
	QuestFrameDetailPanelMaterialBotLeft:RemoveTextures()
	QuestFrameDetailPanelMaterialBotRight:RemoveTextures()
	QuestInfoSpecialObjectivesFrame:RemoveTextures()
	QuestInfoSpellObjectiveFrame:RemoveTextures()

	QuestFramePortrait:Kill()

	QuestFrameRewardPanelBotRight:Kill()
	QuestFrameDetailPanelBotRight:Kill()
	
	QuestFrameAcceptButton:SetUITemplate("button")
	QuestFrameDeclineButton:SetUITemplate("button")
	QuestFrameCompleteButton:SetUITemplate("button")
	QuestFrameGoodbyeButton:SetUITemplate("button")
	QuestFrameCompleteQuestButton:SetUITemplate("button")
	QuestLogFrameAbandonButton:SetUITemplate("button")
	QuestLogFrameCancelButton:SetUITemplate("button")
	QuestLogFrameCompleteButton:SetUITemplate("button")
	QuestLogFramePushQuestButton:SetUITemplate("button")
	QuestLogFrameTrackButton:SetUITemplate("button")
	QuestLogFrameShowMapButton:SetUITemplate("button")

	QuestFrameCloseButton:SetUITemplate("closebutton", "TOPRIGHT", QuestFrame, -35, -8)
	QuestLogDetailFrameCloseButton:SetUITemplate("closebutton")
	QuestLogFrameCloseButton:SetUITemplate("closebutton", "TOPRIGHT", -4, -4)

	QuestFrame:SetUITemplate("backdrop", nil, 4, 4, 65, 27)
	QuestLogFrame:SetUITemplate("backdrop", nil, 0, 0, 4, 0)
	QuestLogDetailFrame:SetUITemplate("simplebackdrop")
	QuestNPCModel:SetUITemplate("backdrop", nil, -3, -3, -3, -3)
	QuestNPCModelTextFrame:SetUITemplate("backdrop", nil, -3, -3, -3, -3) -- :SetBackdropColor(r, g, b, panelAlpha)
--	QuestInfoItemHighlight:SetUITemplate("backdrop")

	QuestLogScrollFrame:SetUITemplate("backdrop", nil, 0, 0, 4, 0):SetBackdropColor(r, g, b, panelAlpha)
	QuestLogDetailScrollFrame:SetUITemplate("backdrop", nil, 0, 0, 4, 0):SetBackdropColor(r, g, b, panelAlpha)
	
	QuestDetailScrollFrameScrollBar:SetUITemplate("scrollbar")
	QuestLogDetailScrollFrameScrollBar:SetUITemplate("scrollbar")
	QuestLogScrollFrameScrollBar:SetUITemplate("scrollbar")
	QuestNPCModelTextScrollFrameScrollBar:SetUITemplate("scrollbar")
	QuestProgressScrollFrameScrollBar:SetUITemplate("scrollbar")
	QuestRewardScrollFrameScrollBar:SetUITemplate("scrollbar")
	
	QuestLogFrameShowMapButton.text:ClearAllPoints()
	QuestLogFrameShowMapButton.text:SetPoint("CENTER")
	QuestLogFrameShowMapButton:SetSize(QuestLogFrameShowMapButton:GetWidth() - 30, QuestLogFrameShowMapButton:GetHeight(), - 40)

--	QuestInfoSkillPointFrame:SetWidth(QuestInfoSkillPointFrame:GetWidth() - 4)
	QuestInfoSkillPointFrame:SetFrameLevel(QuestInfoSkillPointFrame:GetFrameLevel() + 2)
	local skillBackdrop = QuestInfoSkillPointFrame:SetUITemplate("itembackdrop", QuestInfoSkillPointFrameIconTexture)
	F.GlossAndShade(skillBackdrop, QuestInfoSkillPointFrameIconTexture)
	
	QuestInfoSkillPointFrameIconTexture:SetTexCoord(5/64, 59/64, 5/64, 59/64)
	QuestInfoSkillPointFrameIconTexture:SetDrawLayer("OVERLAY")
	QuestInfoSkillPointFrameIconTexture:SetPoint("TOPLEFT", 0, 0)
	QuestInfoSkillPointFrameIconTexture:SetSize(QuestInfoSkillPointFrameIconTexture:GetWidth() - 3, QuestInfoSkillPointFrameIconTexture:GetHeight() - 3)
	QuestInfoSkillPointFrameCount:SetDrawLayer("OVERLAY")
	QuestInfoSkillPointFrameCount:SetFontObject(GUIS_NumberFontNormal)
	QuestInfoSkillPointFramePoints:ClearAllPoints()
	QuestInfoSkillPointFramePoints:SetPoint("BOTTOMRIGHT", QuestInfoSkillPointFrameIconTexture, "BOTTOMRIGHT")
	QuestInfoSkillPointFramePoints:SetFontObject(GUIS_NumberFontNormal)

	QuestInfoSkillPointFrameCount:SetParent(skillBackdrop)
	QuestInfoSkillPointFramePoints:SetParent(skillBackdrop)
	QuestInfoSkillPointFrameIconTexture:SetParent(skillBackdrop)
	
	QuestInfoSkillPointFrameName:SetPoint("LEFT", QuestInfoSkillPointFrameIconTexture, "RIGHT", 6, 0)
	
	QuestInfoItemHighlight:SetUITemplate("targetborder")
	QuestInfoItemHighlight:SetBackdropBorderColor(unpack(C["value"]))
	QuestInfoItemHighlight:SetBackdropColor(0, 0, 0, 0)
	QuestInfoItemHighlight:SetSize(142, 40)

	QuestInfoSpellObjectiveFrame.backdrop = QuestInfoSpellObjectiveFrame:SetUITemplate("itembackdrop", QuestInfoSpellObjectiveFrame.Icon)
	QuestInfoSpellObjectiveFrame.Icon:SetParent(QuestInfoSpellObjectiveFrame.backdrop)
	QuestInfoSpellObjectiveFrame.Icon:SetDrawLayer("OVERLAY")
	QuestInfoSpellObjectiveFrame.Icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
	F.GlossAndShade(QuestInfoSpellObjectiveFrame.backdrop, QuestInfoSpellObjectiveFrame.Icon)
	
	local updateQuestLog = function()
		local numEntries, numQuests = GetNumQuestLogEntries()
		local scrollOffset = HybridScrollFrame_GetOffset(QuestLogScrollFrame)
		
		local questLogTitle, questIndex, isCollapsed, isHeader
		
		local buttons = QuestLogScrollFrame.buttons
		for i = 1, #buttons do
			questLogTitle = buttons[i]
			questIndex = i + scrollOffset
			
			if ( questIndex <= numEntries ) then
				_, _, _, _, isHeader, isCollapsed, _, _, _, _, _ = GetQuestLogTitle(questIndex)
				if (isHeader) then
					if (isCollapsed) then
						questLogTitle:SetUITemplate("arrow", "down")
					else
						questLogTitle:SetUITemplate("arrow", "up")
					end
				end
			end
		end
	end
	updateQuestLog()
	
	for i = 1, 6 do
		local button = _G["QuestProgressItem" .. i]
		local icon = _G["QuestProgressItem" .. i .. "IconTexture"]
		local count = _G["QuestProgressItem" .. i .. "Count"]
		
		button:RemoveTextures()

		local backdrop = button:SetUITemplate("itembackdrop", icon)
		button:SetWidth(button:GetWidth() - 4)
		button:SetFrameLevel(button:GetFrameLevel() + 2)
		
		icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		icon:SetDrawLayer("OVERLAY")
		icon:SetPoint("TOPLEFT", 3, -3)
		icon:SetSize(icon:GetWidth() - 3, icon:GetHeight() - 3)
		icon:SetParent(backdrop)
		
		F.GlossAndShade(backdrop, icon)

		count:SetDrawLayer("OVERLAY")
		count:SetParent(backdrop)
		
		button.backdrop = backdrop
	end
	
	do
		local button = QuestInfoRewardSpell
		local icon = QuestInfoRewardSpellIconTexture

		button:RemoveTextures()

		local backdrop = button:SetUITemplate("itembackdrop", icon)
		button:SetWidth(button:GetWidth() - 4)
		button:SetFrameLevel(button:GetFrameLevel() + 2)
		
		icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		icon:SetDrawLayer("OVERLAY")
		icon:SetPoint("TOPLEFT", 3, -3)
		icon:SetSize(icon:GetWidth() - 3, icon:GetHeight() - 3)
		icon:SetParent(backdrop)
		
		F.GlossAndShade(backdrop, icon)

		button.backdrop = backdrop
	end
	
	for i = 1, MAX_NUM_ITEMS do
		local item = _G["QuestInfoItem" .. i]
		local icon = _G["QuestInfoItem" .. i .. "IconTexture"]
		local count = _G["QuestInfoItem" .. i .. "Count"]
		local pawn = item.PawnQuestAdvisor
		
		item:RemoveTextures()
		
		local backdrop = item:SetUITemplate("itembackdrop", icon)
		item:SetWidth(item:GetWidth() - 4)
		item:SetFrameLevel(item:GetFrameLevel() + 2)
		
		F.GlossAndShade(backdrop, icon)

		icon:SetDrawLayer("OVERLAY")
		icon:SetTexCoord(5/64, 59/64, 5/64, 59/64)
		icon:SetPoint("TOPLEFT", 3, -3)
		icon:SetSize(icon:GetWidth() - 3, icon:GetHeight() - 3)
		icon:SetParent(backdrop)
		
		count:SetDrawLayer("OVERLAY")
		count:SetParent(backdrop)
		count:SetFontObject(GUIS_NumberFontNormal)
		
		if (pawn) then
			pawn:SetDrawLayer("OVERLAY")
			pawn:SetParent(backdrop)
		end
		
		item.backdrop = backdrop
	end
	
	-- compability fix, not any actual skinning
	if (PawnUI_OnQuestInfo_ShowRewards) then
		local fixPawn = function()
			for i = 1, MAX_NUM_ITEMS do
				local item = _G["QuestInfoItem" .. i]
				local pawn = item.PawnQuestAdvisor

				if (pawn) then
					pawn:SetDrawLayer("OVERLAY")
					pawn:SetParent(item.backdrop)
				end	
			end
		end
		hooksecurefunc("PawnUI_OnQuestInfo_ShowRewards", fixPawn)
	end
	
	-- postupdate item coloring
	local updateQuestInfoItems = function()
		local name, texture, numItems, quality, isUsable
		local texture, name, isTradeskillSpell, isSpellLearned
		
		local questItem
	
		local numQuestRewards = 0
		local numQuestChoices = 0
		local numQuestCurrencies = 0
		local numQuestSpellRewards = 0
		
		if (QuestInfoFrame.questLog) then
			numQuestRewards = GetNumQuestLogRewards()
			numQuestChoices = GetNumQuestLogChoices()
			numQuestCurrencies = GetNumQuestLogRewardCurrencies()
			if (GetQuestLogRewardSpell()) then
				numQuestSpellRewards = 1
			end
		else
			numQuestRewards = GetNumQuestRewards()
			numQuestChoices = GetNumQuestChoices()
			numQuestCurrencies = GetNumRewardCurrencies()
			if (GetRewardSpell()) then
				numQuestSpellRewards = 1
			end
		end
		
		-- just return if there are no rewards to worry about
		local totalRewards = numQuestRewards + numQuestChoices + numQuestCurrencies
		if ((totalRewards == 0) and (numQuestSpellRewards == 0)) then
			return
		end
		
		local rewardsCount = 0
		
		-- choosable rewards
		if (numQuestChoices > 0) then
			local index
			local baseIndex = rewardsCount
			for i = 1, numQuestChoices, 1 do
				index = i + baseIndex
				questItem = _G["QuestInfoItem" .. index]

				if ( QuestInfoFrame.questLog ) then
					name, texture, numItems, quality, isUsable = GetQuestLogChoiceInfo(i)
				else
					name, texture, numItems, quality, isUsable = GetQuestItemInfo("choice", i)
				end
				
				if (texture) and (quality) and (quality > 1) then
					local r, g, b, hex = GetItemQualityColor(quality)
					questItem.backdrop:SetBackdropBorderColor(r, g, b)
				else
					questItem.backdrop:SetBackdropBorderColor(unpack(C["border"]))
				end

				rewardsCount = rewardsCount + 1
			end
		end
		
		-- spell rewards
		if (numQuestSpellRewards > 0) then
			questItem = QuestInfoRewardSpell
			
			if (QuestInfoFrame.questLog) then
				texture, name, isTradeskillSpell, isSpellLearned = GetQuestLogRewardSpell()
			else
				texture, name, isTradeskillSpell, isSpellLearned = GetRewardSpell()
			end

			if (texture) and (quality) and (quality > 1) then
				local r, g, b, hex = GetItemQualityColor(quality)
				questItem.backdrop:SetBackdropBorderColor(r, g, b)
			else
				questItem.backdrop:SetBackdropBorderColor(unpack(C["border"]))
			end
		end
		
		-- mandatory rewards
		if ((numQuestRewards > 0) or (numQuestCurrencies > 0)) then
			-- items
			local index
			local baseIndex = rewardsCount
			for i = 1, numQuestRewards, 1 do
				index = i + baseIndex
				questItem = _G["QuestInfoItem" .. index]

				if (QuestInfoFrame.questLog) then
					name, texture, numItems, quality, isUsable = GetQuestLogRewardInfo(i)
				else
					name, texture, numItems, quality, isUsable = GetQuestItemInfo("reward", i)
				end
				
				if (texture) and (quality) and (quality > 1) then
					local r, g, b, hex = GetItemQualityColor(quality)
					questItem.backdrop:SetBackdropBorderColor(r, g, b)
				else
					questItem.backdrop:SetBackdropBorderColor(unpack(C["border"]))
				end

				rewardsCount = rewardsCount + 1
			end
			
			-- currency
			baseIndex = rewardsCount
			for i = 1, numQuestCurrencies, 1 do
				index = i + baseIndex
				questItem = _G["QuestInfoItem"..index]
				
				if (QuestInfoFrame.questLog) then
					name, texture, numItems = GetQuestLogRewardCurrencyInfo(i)
				else
					name, texture, numItems = GetQuestCurrencyInfo("reward", i)
				end

				if (texture) and (quality) and (quality > 1) then
					local r, g, b, hex = GetItemQualityColor(quality)
					questItem.backdrop:SetBackdropBorderColor(r, g, b)
				else
					questItem.backdrop:SetBackdropBorderColor(unpack(C["border"]))
				end
				
				rewardsCount = rewardsCount + 1
			end
		end
		
	--[[
		for i = 1, MAX_NUM_ITEMS do
			local item = _G["QuestInfoItem" .. i]
			local name, texture, numItems, quality, isUsable
			
			if (QuestInfoFrame.questLog) then
			
				if (item.type == "reward") then
					if (item.objectType == "item") then
						name, texture, numItems, quality, isUsable = GetQuestLogRewardInfo(i)
					elseif (item.objectType == "currency") then
						name, texture, numItems = GetQuestLogRewardCurrencyInfo(i)
					end
				elseif (item.type == "choice") then
					if (item.objectType == "item") then
						name, texture, numItems, quality, isUsable = GetQuestLogChoiceInfo(i)
					end
				end
			else
				
				-- we need this check to avoid nil/"invalid quest item" errors
				if (item.type == "reward") then
					if (item.objectType == "item") then
						name, texture, numItems, quality, isUsable = GetQuestItemInfo(item.type, i)
						
					elseif (item.objectType == "currency") then
						name, texture, numItems = GetQuestCurrencyInfo(item.type, i)
					end
				elseif (item.type == "choice") then
					if (item.objectType == "item") then
						name, texture, numItems, quality, isUsable = GetQuestItemInfo(item.type, i)
						
					elseif (item.objectType == "currency") then
						name, texture, numItems = GetQuestCurrencyInfo(item.type, i)
					end
				end
			end
			
	]]--
			

--		end
	end
	
	QuestInfoRewardsFrame:HookScript("OnShow", updateQuestInfoItems)
	hooksecurefunc("QuestInfo_Display", updateQuestInfoItems)
	hooksecurefunc("QuestInfo_ShowRewards", updateQuestInfoItems)
	
	local updateDisplay = function(template, parentFrame, acceptButton, material)
		QuestInfoTitleHeader:SetTextColor(unpack(C["value"]))
		QuestInfoDescriptionHeader:SetTextColor(unpack(C["value"]))
		QuestInfoDescriptionText:SetTextColor(unpack(C["index"]))
		QuestInfoGroupSize:SetTextColor(unpack(C["index"]))
		QuestInfoItemChooseText:SetTextColor(unpack(C["index"]))
		QuestInfoItemReceiveText:SetTextColor(unpack(C["index"]))
		QuestInfoObjectivesHeader:SetTextColor(unpack(C["value"]))
		QuestInfoObjectivesText:SetTextColor(unpack(C["index"]))
		QuestInfoRewardsHeader:SetTextColor(unpack(C["value"]))
		QuestInfoRewardText:SetTextColor(unpack(C["index"]))
		QuestInfoSpellLearnText:SetTextColor(unpack(C["index"]))
		QuestInfoXPFrameReceiveText:SetTextColor(unpack(C["index"]))
		QuestInfoSpellObjectiveLearnLabel:SetTextColor(unpack(C["value"]))
		
		local objectives = 0
		for i = 1, GetNumQuestLeaderBoards() do
			local _, type, done = GetQuestLogLeaderBoard(i)
			if (type ~= "spell") then
				objectives = objectives + 1

				local objective = _G["QuestInfoObjective" .. objectives]
				if (done) then
					objective:SetTextColor(unpack(C["value"]))
				else
					objective:SetTextColor(0.6, 0.6, 0.6)
				end
			end
		end			
	end

	local updateQuestProgress = function()
		QuestProgressTitleText:SetTextColor(unpack(C["value"]))
		QuestProgressText:SetTextColor(unpack(C["index"]))
		QuestProgressRequiredItemsText:SetTextColor(unpack(C["value"]))
		QuestProgressRequiredMoneyText:SetTextColor(unpack(C["value"]))
	end
	
	local updatePortrait = function(parent, portrait, text, name, x, y)
		QuestNPCModel:ClearAllPoints()
		QuestNPCModel:SetPoint("TOPLEFT", parent, "TOPRIGHT", x + 18, y)
		QuestNPCModelTextFrame:ClearAllPoints()
		QuestNPCModelTextFrame:SetPoint("TOPLEFT", QuestNPCModel, "BOTTOMLEFT", 0, -8)
		QuestNPCModelNameText:ClearAllPoints()
		QuestNPCModelNameText:SetPoint("TOP", QuestNPCModel, "TOP", 0, -8)
		
	end
	
	local updateHighlight = function(self)
		QuestInfoItemHighlight:ClearAllPoints()
		QuestInfoItemHighlight:SetAllPoints(self)
	end

	local updateMoney = function()
		local requiredMoney = GetQuestLogRequiredMoney()
		if (requiredMoney > 0) then
			if (requiredMoney > GetMoney()) then
				QuestInfoRequiredMoneyText:SetTextColor(0.6, 0.6, 0.6)
			else
				QuestInfoRequiredMoneyText:SetTextColor(unpack(C["value"]))
			end
		end			
	end
	
	hooksecurefunc("QuestInfo_Display", updateDisplay)
	hooksecurefunc("QuestInfo_ShowRequiredMoney", updateMoney)
	hooksecurefunc("QuestInfoItem_OnClick", updateHighlight)
	hooksecurefunc("QuestFrame_ShowQuestPortrait", updatePortrait)
	hooksecurefunc("QuestFrameProgressItems_Update", updateQuestProgress)
	hooksecurefunc("QuestLog_Update", updateQuestLog)
end
