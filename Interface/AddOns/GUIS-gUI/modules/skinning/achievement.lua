--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: UISkinningAchievement")

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
		
		local SkinStatusBar = function(self, makeBorder)
			self:SetUITemplate("statusbar", makeBorder)
				
			local name = self:GetName()
			local text = self.text or name and _G[name .. "Text"]
			if (text) then
				text:ClearAllPoints()
				text:SetPoint("RIGHT", -8, 0)
			end

			local title = self.title or name and _G[name .. "Title"]
			if (title) then
				title:ClearAllPoints()
				title:SetPoint("LEFT", 8, 0)
			end

			local label = self.label or name and _G[name .. "Label"]
			if (label) then
				label:ClearAllPoints()
				label:SetPoint("LEFT", 8, 0)
			end
		end	
		
		local StripBackdrop = function(self)
			for i = 1, self:GetNumChildren() do
				local child = select(i, self:GetChildren())
				if (child) and not(child:GetName()) then
					child:SetBackdrop(nil)
					child.SetBackdrop = noop
				end
			end
		end
		
		StripBackdrop(AchievementFrameAchievements)
		StripBackdrop(AchievementFrameComparison)
		StripBackdrop(AchievementFrameStats)
		StripBackdrop(AchievementFrameSummary)
		
		AchievementFrame:RemoveTextures()
		AchievementFrameAchievements:RemoveTextures(true)
		AchievementFrameAchievementsBackground:RemoveTextures()
		AchievementFrameCategories:RemoveTextures(true)
		AchievementFrameCategoriesBG:RemoveTextures(true)
		AchievementFrameCategoriesContainer:RemoveTextures()
		AchievementFrameComparison:RemoveTextures(true)
		AchievementFrameComparisonBackground:RemoveTextures()
		AchievementFrameComparisonDark:RemoveTextures()
		AchievementFrameComparisonWatermark:RemoveTextures()
		AchievementFrameComparisonHeader:RemoveTextures()
		AchievementFrameComparisonSummaryPlayer:RemoveTextures()
		AchievementFrameComparisonSummaryFriend:RemoveTextures()
		AchievementFrameHeader:RemoveTextures(true)
		AchievementFrameStats:RemoveTextures()
		AchievementFrameStatsBG:RemoveTextures()
		AchievementFrameSummary:RemoveTextures(true)
		AchievementFrameSummaryAchievementsHeader:RemoveTextures()
		AchievementFrameSummaryCategoriesHeader:RemoveTextures()
		
		AchievementFrameCategories:RemoveClutter()
		AchievementFrameAchievements:RemoveClutter()
		AchievementFrameComparison:RemoveClutter()

		AchievementFrameGuildEmblemLeft:Kill()
		AchievementFrameGuildEmblemRight:Kill()
		AchievementFrameWaterMark:Kill()
		
		for i = 1, 8 do
			_G["AchievementFrameSummaryCategoriesCategory" .. i .. "Button"]:RemoveTextures(true)
			_G["AchievementFrameSummaryCategoriesCategory" .. i .. "ButtonHighlight"]:RemoveTextures()
		end
		
		for i = 1, 20 do
			_G["AchievementFrameComparisonStatsContainerButton" .. i]:RemoveTextures(true)
			_G["AchievementFrameComparisonStatsContainerButton" .. i .. "HeaderMiddle"]:RemoveTextures()
			_G["AchievementFrameComparisonStatsContainerButton" .. i .. "HeaderLeft"]:RemoveTextures()
			_G["AchievementFrameComparisonStatsContainerButton" .. i .. "HeaderRight"]:RemoveTextures()

			_G["AchievementFrameStatsContainerButton" .. i]:RemoveClutter(true)
			_G["AchievementFrameStatsContainerButton" .. i .. "HeaderMiddle"]:RemoveTextures()
			_G["AchievementFrameStatsContainerButton" .. i .. "HeaderLeft"]:RemoveTextures()
			_G["AchievementFrameStatsContainerButton" .. i .. "HeaderRight"]:RemoveTextures()
			_G["AchievementFrameStatsContainerButton" .. i]:GetHighlightTexture():SetTexture(1, 1, 1, 1/3)
			
			if (i%2 == 1) then
				_G["AchievementFrameStatsContainerButton" .. i]:SetBackdrop({ bgFile = M["Background"]["Blank"] })
				_G["AchievementFrameStatsContainerButton" .. i]:SetBackdropColor(1, 1, 1, 1/10)

				_G["AchievementFrameComparisonStatsContainerButton" .. i]:SetBackdrop({ bgFile = M["Background"]["Blank"] })
				_G["AchievementFrameComparisonStatsContainerButton" .. i]:SetBackdropColor(1, 1, 1, 1/10)
			end
		end
		
		AchievementFrameCloseButton:SetUITemplate("closebutton", "TOPRIGHT", -4, 4)

		AchievementFrameFilterDropDown:SetUITemplate("dropdown", true, 160)

		AchievementFrame:SetUITemplate("backdrop", nil, -8, 0, 0, 0)
		AchievementFrameCategoriesContainer:SetUITemplate("backdrop", nil, -3, 2, -4, 2):SetBackdropColor(r, g, b, panelAlpha)
		AchievementFrameAchievementsContainer:SetUITemplate("backdrop", nil, -1, 0, -2, 5):SetBackdropColor(r, g, b, panelAlpha)
		AchievementFrameComparisonStatsContainer:SetUITemplate("backdrop", nil, -4, -1, -4, 6):SetBackdropColor(r, g, b, panelAlpha)
		AchievementFrameStatsContainer:SetUITemplate("backdrop", nil, -4, -3, -4, 0):SetBackdropColor(r, g, b, panelAlpha)
		AchievementFrameStatsContainer:SetPoint("TOPLEFT", 6, -6)
		AchievementFrameStatsContainer:SetWidth(AchievementFrameStatsContainer:GetWidth() - 6)
		AchievementFrameStatsContainer:SetHeight(AchievementFrameStatsContainer:GetHeight() - 6)
		
		AchievementFrameAchievementsContainerScrollBar:SetUITemplate("scrollbar")
		AchievementFrameCategoriesContainerScrollBar:SetUITemplate("scrollbar")
		AchievementFrameComparisonContainerScrollBar:SetUITemplate("scrollbar")
		AchievementFrameComparisonStatsContainerScrollBar:SetUITemplate("scrollbar")	
		AchievementFrameStatsContainerScrollBar:SetUITemplate("scrollbar")
		
		SkinStatusBar(AchievementFrameComparisonSummaryPlayerStatusBar, true)
		SkinStatusBar(AchievementFrameComparisonSummaryFriendStatusBar, true)
		SkinStatusBar(AchievementFrameSummaryCategoriesStatusBar, true)
		
		for i = 1, 8 do
			SkinStatusBar(_G["AchievementFrameSummaryCategoriesCategory" .. i], true)
			_G["AchievementFrameSummaryCategoriesCategory" .. i .. "Button"]:CreateHighlight()
		end
		
		local skinnedTabs = {}
		local skinTabs = function()
			local i = 1
			while (_G["AchievementFrameTab" .. i]) do
				if not(skinnedTabs[_G["AchievementFrameTab" .. i]]) then
					_G["AchievementFrameTab" .. i]:SetUITemplate("tab", true)
					skinnedTabs[_G["AchievementFrameTab" .. i]] = true
				end
				i = i + 1
			end
		end
--		skinTabs()

		AchievementFrameHeaderTitle:ClearAllPoints()
		AchievementFrameHeaderTitle:SetPoint("TOPLEFT", AchievementFrame, "TOPLEFT", -8, -4)

		AchievementFrameHeaderPoints:ClearAllPoints()
		AchievementFrameHeaderPoints:SetPoint("LEFT", AchievementFrameHeaderTitle, "RIGHT", 8, 0)

		AchievementFrameFilterDropDown:ClearAllPoints()
		AchievementFrameFilterDropDown:SetPoint("TOPRIGHT", AchievementFrame, "TOPRIGHT", -40, 5)
	
		AchievementFrameComparisonHeaderName:ClearAllPoints()
		AchievementFrameComparisonHeaderName:SetPoint("TOPRIGHT", AchievementFrame, "TOPRIGHT", -56, -4)
		AchievementFrameComparisonHeaderName:SetJustifyH("RIGHT")

		AchievementFrameComparisonHeaderPoints:ClearAllPoints()
		AchievementFrameComparisonHeaderPoints:SetPoint("RIGHT", AchievementFrameComparisonHeaderName, "LEFT", -8, 0)		

		AchievementFrameComparisonHeaderPortrait:Hide()
		AchievementFrameComparisonHeaderPortrait.Show = noop
		
		AchievementFrameComparisonStatsContainer:SetPoint("TOPLEFT", 4, -6)

		for i = 1, 7 do
			local frame = _G["AchievementFrameAchievementsContainerButton" .. i]

			local background = _G[frame:GetName() .. "Background"]
			local description = _G[frame:GetName() .. "Description"]
			local glow = _G[frame:GetName() .. "Glow"]
			local hiddendescription = _G[frame:GetName() .. "HiddenDescription"]
			local highlight = _G[frame:GetName() .. "Highlight"]
			local icon = _G[frame:GetName() .. "Icon"]
			local iconbling = _G[icon:GetName() .. "Bling"]
			local iconoverlay = _G[icon:GetName() .. "Overlay"]
			local icontexture = _G[icon:GetName() .. "Texture"]
			local tracked = _G[frame:GetName() .. "Tracked"]
			local tsunami1 = _G[frame:GetName() .. "BottomLeftTsunami"]
			local tsunami2 = _G[frame:GetName() .. "BottomRightTsunami"]
			local tsunami3 = _G[frame:GetName() .. "BottomTsunami1"]
			local tsunami4 = _G[frame:GetName() .. "TopLeftTsunami"]
			local tsunami5 = _G[frame:GetName() .. "TopRightTsunami"]
			local tsunami6 = _G[frame:GetName() .. "TopTsunami1"]
			local titlebackground = _G[frame:GetName() .. "TitleBackground"]
			local plusminus = _G[frame:GetName() .. "PlusMinus"]
			local rewardbackground = _G[frame:GetName() .. "RewardBackground"]

			if (background) then background:RemoveTextures(true) end
			if (titlebackground) then titlebackground:RemoveTextures(true) end
			if (glow) then glow:RemoveTextures(true) end
			if (highlight) then highlight:RemoveTextures(true) end
			if (iconbling) then iconbling:RemoveTextures(true) end
			if (iconoverlay) then iconoverlay:RemoveTextures(true) end
			if (tsunami1) then tsunami1:RemoveTextures(true) end
			if (tsunami2) then tsunami2:RemoveTextures(true) end
			if (tsunami3) then tsunami3:RemoveTextures(true) end
			if (tsunami4) then tsunami4:RemoveTextures(true) end
			if (tsunami5) then tsunami5:RemoveTextures(true) end
			if (tsunami6) then tsunami6:RemoveTextures(true) end
			if (plusminus) then plusminus:RemoveTextures(true) end
			if (rewardbackground) then rewardbackground:RemoveTextures(true) end
	
			if (tracked) then 
				tracked:Hide()
				tracked.Show = noop
			end

			frame:SetUITemplate("simplebackdrop-indented"):SetBackdropColor(r, g, b, panelAlpha)
			frame.SetBackdropBorderColor = noop
			
			local highlightBorder = highlight:SetUITemplate("targetborder")
			highlightBorder:ClearAllPoints()
			highlightBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
			highlightBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
			
			highlight.overlay = highlight:CreateTexture(nil, "OVERLAY")
			highlight.overlay:SetPoint("TOPLEFT", highlightBorder, "TOPLEFT", 0, 0)
			highlight.overlay:SetPoint("BOTTOMRIGHT", highlightBorder, "BOTTOMRIGHT", 0, 0)
			highlight.overlay:SetTexture(1, 1, 1, 1/10)

			description:SetTextColor(0.6, 0.6, 0.6)
			description.SetTextColor = noop
			
			hiddendescription:SetTextColor(unpack(C["index"]))
			hiddendescription.SetTextColor = noop
			
			local backdrop = icon:SetUITemplate("itembackdrop")
			icon:SetHeight(icon:GetHeight() - 4)
			icon:SetWidth(icon:GetWidth() - 4)
			icon:ClearAllPoints()
			icon:SetPoint("TOPLEFT", 12, -12)
			
			icontexture:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			icontexture:ClearAllPoints()
			icontexture:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
			icontexture:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
			
			icontexture:SetParent(backdrop)
			icontexture:SetDrawLayer("OVERLAY")
		end
		
		local fixComparisonFrame = function(self)
			local background = _G[self:GetName() .. "Background"]
			local description = _G[self:GetName() .. "Description"]
			local glow = _G[self:GetName() .. "Glow"]
			local hiddendescription = _G[self:GetName() .. "HiddenDescription"]
			local highlight = _G[self:GetName() .. "Highlight"]
			local icon = _G[self:GetName() .. "Icon"]
			local iconbling = _G[icon:GetName() .. "Bling"]
			local iconoverlay = _G[icon:GetName() .. "Overlay"]
			local icontexture = _G[icon:GetName() .. "Texture"]
			local shield = _G[self:GetName() .. "Shield"]
			local tracked = _G[self:GetName() .. "Tracked"]
			local tsunami1 = _G[self:GetName() .. "BottomLeftTsunami"]
			local tsunami2 = _G[self:GetName() .. "BottomRightTsunami"]
			local tsunami3 = _G[self:GetName() .. "BottomTsunami1"]
			local tsunami4 = _G[self:GetName() .. "TopLeftTsunami"]
			local tsunami5 = _G[self:GetName() .. "TopRightTsunami"]
			local tsunami6 = _G[self:GetName() .. "TopTsunami1"]
			local titlebackground = _G[self:GetName() .. "TitleBackground"]
			local plusminus = _G[self:GetName() .. "PlusMinus"]
			local rewardbackground = _G[self:GetName() .. "RewardBackground"]

			if (background) then background:RemoveTextures(true) end
			if (titlebackground) then titlebackground:RemoveTextures(true) end
			if (glow) then glow:RemoveTextures(true) end
			if (highlight) then highlight:RemoveTextures(true) end
			if (iconbling) then iconbling:RemoveTextures(true) end
			if (iconoverlay) then iconoverlay:RemoveTextures(true) end
			if (tsunami1) then tsunami1:RemoveTextures(true) end
			if (tsunami2) then tsunami2:RemoveTextures(true) end
			if (tsunami3) then tsunami3:RemoveTextures(true) end
			if (tsunami4) then tsunami4:RemoveTextures(true) end
			if (tsunami5) then tsunami5:RemoveTextures(true) end
			if (tsunami6) then tsunami6:RemoveTextures(true) end
			if (plusminus) then plusminus:RemoveTextures(true) end
			if (rewardbackground) then rewardbackground:RemoveTextures(true) end

			if (tracked) then 
				tracked:Hide()
				tracked.Show = noop
			end
			
			self:SetUITemplate("simplebackdrop-indented"):SetBackdropColor(r, g, b, panelAlpha)
			self.SetBackdropBorderColor = noop
			
			if (description) then
				description:SetTextColor(0.6, 0.6, 0.6)
				description.SetTextColor = noop
			end
			
			local backdrop = icon:SetUITemplate("itembackdrop")
			icon:SetHeight(icon:GetHeight() - 16)
			icon:SetWidth(icon:GetWidth() - 16)
			icon:ClearAllPoints()
			icon:SetPoint("LEFT", 8, 0)
			
			icontexture:SetTexCoord(5/64, 59/64, 5/64, 59/64)
			icontexture:ClearAllPoints()
			icontexture:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
			icontexture:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
			
			icontexture:SetParent(backdrop)
			icontexture:SetDrawLayer("OVERLAY")	

		end
		
		for i = 1, 9 do
			fixComparisonFrame(_G["AchievementFrameComparisonContainerButton" .. i .. "Player"])
			fixComparisonFrame(_G["AchievementFrameComparisonContainerButton" .. i .. "Friend"])
		end
		
		local updateCategoryList
		do
			local once
			updateCategoryList = function()
				-- always check for new tabs
				-- this provides a "first glance" compability with OverAchiever
				skinTabs()
			
				for i = 1, 20 do 
					local button = _G["AchievementFrameCategoriesContainerButton" .. i]
					local background = _G["AchievementFrameCategoriesContainerButton" .. i .. "Background"]
					local label = _G["AchievementFrameCategoriesContainerButton" .. i .. "Label"]
					
					if not(once) then
						background:Kill()
					end
					
					button:SetUITemplate("button"):SetBackdropColor(r, g, b, panelAlpha)

--					if (label) then
--						label:SetPoint("BOTTOMLEFT", 20, 8)
--						label:SetPoint("TOPRIGHT", -12, -8)
--					end
				end

				once = true
			end
		end
		
		local updateProgressBar = function(index)
			local frame = _G["AchievementFrameProgressBar" .. index]
			if (frame) then
				if not(frame.GUIskinned) then

					frame:SetUITemplate("statusbar", true)
					
					local a, b = frame:GetStatusBarTexture():GetDrawLayer()
					frame.background = frame:CreateTexture()
					frame.background:SetDrawLayer(a, b-1)
					frame.background:SetTexture(frame:GetStatusBarTexture():GetTexture())
					frame.background:SetVertexColor(0.1, 0.1, 0.1, 1)
					frame.background:SetAllPoints(frame)
					
					frame.text:ClearAllPoints()
					frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)
					frame.text:SetJustifyH("CENTER")
					
					if (index > 1) then
						frame:ClearAllPoints()
						frame:SetPoint("TOP", _G["AchievementFrameProgressBar" .. (index - 1)], "BOTTOM", 0, -6)
						frame.SetPoint = noop
						frame.ClearAllPoints = noop
					end
					
					frame.GUIskinned = true
				end
			end
		end
		
		local updateAchievementCriteria = function(objectivesFrame, id)
			local numCriteria = GetAchievementNumCriteria(id)
			local textStrings, metas = 0, 0
			for i = 1, numCriteria do	
				local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(id, i)
				
				if (criteriaType == CRITERIA_TYPE_ACHIEVEMENT) and (assetID) then
					metas = metas + 1
					local metaCriteria = AchievementButton_GetMeta(metas)			
					if (objectivesFrame.completed) and (completed) then
						metaCriteria.label:SetTextColor(1, 1, 1, 1)
						
					elseif ( completed ) then
						metaCriteria.label:SetTextColor(0, 1, 0, 1)
						
					else
						metaCriteria.label:SetTextColor(.6, .6, .6, 1)
						
					end				
				elseif (criteriaType ~= 1) then
					textStrings = textStrings + 1
					local criteria = AchievementButton_GetCriteria(textStrings)			
					if (objectivesFrame.completed) and (completed) then
						criteria.name:SetTextColor(1, 1, 1, 1)

					elseif ( completed ) then
						criteria.name:SetTextColor(0, 1, 0, 1)

					else
						criteria.name:SetTextColor(.6, .6, .6, 1)
					end		
				end
			end
		end

		local updateAchievementSummary = function()
			for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
				local frame = _G["AchievementFrameSummaryAchievement" ..i]

				local background = _G[frame:GetName() .. "Background"]
				local description = _G[frame:GetName() .. "Description"]
				local glow = _G[frame:GetName() .. "Glow"]
				local highlight = _G[frame:GetName() .. "Highlight"]
				local icon = _G[frame:GetName() .. "Icon"]
				local titlebackground = _G[frame:GetName() .. "TitleBackground"]
				
				if (background) then background:RemoveTextures(true) end
				if (glow) then glow:RemoveTextures(true) end
				if (titlebackground) then titlebackground:RemoveTextures(true) end
				if (highlight) then highlight:RemoveClutter() end
				
				if (highlight) then
					local highlightBorder = highlight:SetUITemplate("targetborder")
					highlightBorder:ClearAllPoints()
					highlightBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -2)
					highlightBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 2)
					
					if not(highlight.overlay) then
						highlight.overlay = highlight:CreateTexture(nil, "OVERLAY")
						highlight.overlay:SetPoint("TOPLEFT", highlightBorder, "TOPLEFT", 0, 0)
						highlight.overlay:SetPoint("BOTTOMRIGHT", highlightBorder, "BOTTOMRIGHT", 0, 0)
						highlight.overlay:SetTexture(1, 1, 1, 1/5)
					end
				end
				
				if (description) then
					description:SetTextColor(0.6, 0.6, 0.6)
				end

				if not(frame.GUISkinned) then
					frame:RemoveTextures()
				
					frame:SetBackdrop(nil)
					frame.SetBackdrop = nil
					
					frame.backdrop = frame:SetUITemplate("backdrop")
					frame.backdrop:SetBackdropColor(r, g, b, panelAlpha)
					frame.backdrop:SetPoint("TOPLEFT", 0, -2)
					frame.backdrop:SetPoint("BOTTOMRIGHT", 0, 2)
					
					if (icon) then
						icon:SetUITemplate("itembackdrop")
						local bling = _G[icon:GetName() .. "Bling"]
						local overlay = _G[icon:GetName() .. "Overlay"]
						
						if (bling) then bling:RemoveTextures(true) end
						if (overlay) then overlay:RemoveTextures(true) end
					
						icon:SetHeight(icon:GetHeight() - 16)
						icon:SetWidth(icon:GetWidth() - 16)
						icon:ClearAllPoints()
						icon:SetPoint("LEFT", 6, 0)

						_G[icon:GetName() .. "Texture"]:SetTexCoord(5/64, 59/64, 5/64, 59/64)
						_G[icon:GetName() .. "Texture"]:ClearAllPoints()
						_G[icon:GetName() .. "Texture"]:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
						_G[icon:GetName() .. "Texture"]:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
					end
					
					frame.GUISkinned = true
				end
			end
		end
		
		-- this is compatible with OverAchiever
		hooksecurefunc("AchievementFrame_OnShow", updateCategoryList) 
		AchievementFrame:HookScript("OnShow", updateCategoryList) 
		
		hooksecurefunc("AchievementObjectives_DisplayCriteria", updateAchievementCriteria)
		hooksecurefunc("AchievementFrameSummary_UpdateAchievements", updateAchievementSummary)
		hooksecurefunc("AchievementButton_GetProgressBar", updateProgressBar)
		
	end
	F.SkinAddOn("Blizzard_AchievementUI", SkinFunc)
	
end
