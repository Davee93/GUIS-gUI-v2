
	-- ICON CONFIG // TRUE or FALSE 
	
	local lefticon = true             -- set to true if you use left icon // Default
	local righticon = false           -- set to true if you use right icon
	
	-- ICON CONFIG END //
	
	hooksecurefunc('CreateFrame', function(...)
        local _, name, _, template = ...
        if(template == 'DBTBarTemplate') then
            local frame = _G[name]     
            local bar = _G[frame:GetName().."Bar"]
			local spark = _G[frame:GetName().."BarSpark"]
			local texture = _G[frame:GetName().."BarTexture"]
			local icon1 = _G[frame:GetName().."BarIcon1"]
			local icon2 = _G[frame:GetName().."BarIcon2"]
			local name = _G[frame:GetName().."BarName"]
			local timer = _G[frame:GetName().."BarTimer"]
			bar:SetHeight(10)
			bar:SetFrameLevel(0)
			
			-- gUI API 
			local GUIS = LibStub("gCore-3.0"):GetModule("GUIS-gUI: Core")
			local M = LibStub("gMedia-3.0")
			local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
			local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
			local RegisterCallback = function(...) return module:RegisterCallback(...) end
			
			-- BAR STYLE			
			texture:SetTexture("Interface\\AddOns\\GUIS-gUI\\media\\texture\\statusbar")
			icon1:SetTexCoord(.1,.9,.1,.9) 
			icon1:ClearAllPoints()
			icon1:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -6, 5)
			icon2:SetTexCoord(.1,.9,.1,.9) 
			icon2:ClearAllPoints()
			icon2:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 6, 5)
			name:ClearAllPoints()
			name:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 3)
			name:SetFont("Interface\\AddOns\\GUIS-gUI\\media\\fonts\\PT Sans Narrow Bold.ttf", 12, "OUTLINE")
			name:SetShadowColor(0, 0, 0, 0)
			timer:ClearAllPoints()
			timer:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", 0, 3)  
			timer:SetJustifyH"RIGHT"
			timer:SetFont("Interface\\AddOns\\GUIS-gUI\\media\\fonts\\PT Sans Narrow Bold.ttf", 10, "OUTLINE") 
			timer:SetFont("Interface\\AddOns\\GUIS-gUI\\media\\fonts\\PT Sans Narrow Bold.ttf", 10, "OUTLINE") 
			timer:SetShadowColor(0, 0, 0, 0)
			spark:SetAlpha(1)
			spark:SetHeight(30)
			spark:SetWidth(8)
			
			name.SetFont = function() end
			texture.SetTexture = function() end
			timer.SetFont = function() end
			spark.SetAlpha = function() end

			-- BACKDROP AND BORDER					
			local bg = CreateFrame("Frame", nil, bar)
			bg:SetUITemplate("simpleborder")
			bg:SetPoint("TOPLEFT", bar, "TOPLEFT", -1, 1)
			bg:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 1, -1)
			bg:SetFrameLevel(1)
			F.GlossAndShade(bar)
			
			-- LEFT ICON
		if lefticon then
			local ibg = CreateFrame("Frame", icon1)
			ibg:SetUITemplate("simpleborder")
			ibg:SetPoint("TOPRIGHT", icon1, 1, 1)
			ibg:SetPoint("BOTTOMLEFT", icon1, -1, -1)
			ibg:SetParent(bar)
			ibg:SetFrameLevel(1)
		end

			-- RIGHT ICON
		if righticon then
			local ibg = CreateFrame("Frame", icon2)
			ibg:SetUITemplate("simpleborder")
			ibg:SetPoint("TOPRIGHT", icon2, 1, 1)
			ibg:SetPoint("BOTTOMLEFT", icon2, -1, -1)
			ibg:SetParent(bar)
			ibg:SetFrameLevel(1)
		end
	end
end)
