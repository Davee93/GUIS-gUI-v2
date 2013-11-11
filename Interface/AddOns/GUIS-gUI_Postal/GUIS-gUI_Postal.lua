local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: PostalSkin")

-- Lua API
local pairs, select, unpack = pairs, select, unpack

-- Get the various gUI files and functions
local GUIS = LibStub("gCore-3.0"):GetModule("GUIS-gUI: Core")
local M = LibStub("gMedia-3.0")
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local UnregisterCallback = function(...) return module:UnregisterCallback(...) end

module.OnInit = function(self)
	-- we need at least v2 of the GUIS engine for this to work
	if not(F.GetVersion) or not(F.GetVersion() >= 2) then
		local msg = "%s %s requires |cFF4488FFGUIS:|r |cFFFF7D0Ag|r|cFFFFBB00UI|r|cFFFFFFFF|r v2.0 or newer to run. Bailing out. Download the latest version from http://www.curse.com/addons/wow/guis-gui"
		print(msg:format(GetAddOnMetadata(addon, "Title"), GetAddOnMetadata(addon, "Version")))
		
		self:Kill() 
		return
	end

	-- Check if the user has chosen to activate skinning or not
	if (F.kill("GUIS-gUI: UISkinning")) then 
		self:Kill() 
		return 
	end
		
	local SkinFunc = function()
		local Postal = LibStub("AceAddon-3.0"):GetAddon("Postal")
		local Postal_BlackBook = Postal:GetModule("BlackBook")
		local Postal_OpenAll = Postal:GetModule("OpenAll")
		local Postal_Select = Postal:GetModule("Select")
		
		do
			local skinCallback
			local skinPostalMain = function()
				if (PostalOpenAllButton) then
					PostalOpenAllButton:SetUITemplate("button", true)
					PostalOpenAllButton:ClearAllPoints()
					PostalOpenAllButton:SetPoint("BOTTOM", InboxFrame, "BOTTOM", -30, 80)
				end
				
				if (Postal_ModuleMenuButton) then
					Postal_ModuleMenuButton:SetUITemplate("arrow", "down")
				end
				
				UnregisterCallback(skinCallback)
			end
			if (PostalOpenAllButton) then
				skinPostalMain()
			else
				skinCallback = RegisterCallback("MAIL_SHOW", skinPostalMain)
			end
		end
		
		do
			local once
			local skinBlackBook = function()
				if (once) then 
					return
				end
				
				if (Postal_BlackBookButton) then
					Postal_BlackBookButton:SetUITemplate("arrow", "down")
				end
				
				once = true
			end
			if (Postal_BlackBookButton) then
				skinBlackBook()
			else
				if (Postal_BlackBook) then
					hooksecurefunc(Postal_BlackBook, "OnEnable", skinBlackBook)
				end
			end
		end
		
		do
			local once
			local skinOpenAll = function()
				if (once) then 
					return
				end
				
				if (Postal_OpenAllMenuButton) then
					Postal_OpenAllMenuButton:SetUITemplate("arrow", "down")
				end
				
				once = true
			end
			if (Postal_OpenAllMenuButton) then
				skinOpenAll()
			else
				if (Postal_OpenAll) then
					hooksecurefunc(Postal_OpenAll, "OnEnable", skinOpenAll)
				end
			end
		end
		
		do
			local once
			local skinSelect = function()
				if (once) then 
					return
				end
				
				if (PostalSelectOpenButton) then
					PostalSelectOpenButton:SetUITemplate("button", true)
				end
				
				if (PostalSelectReturnButton) then
					PostalSelectReturnButton:SetUITemplate("button", true)
				end

				MailItem1:ClearAllPoints()
				MailItem1:SetPoint("TOPLEFT", 38, -80)
				
				local w = MailItem1:GetWidth() + 14
				
				for i = 1,INBOXITEMS_TO_DISPLAY do
					local bg = _G["MailItem" .. i]
					local expire = _G["MailItem" .. i .. "ExpireTime"]
					local b = _G["PostalInboxCB" .. i]

					expire:ClearAllPoints()
					expire:SetPoint("TOPRIGHT", -4, -4)
					
					bg:SetWidth(w)
					
					b:ClearAllPoints()
					b:SetPoint("RIGHT", bg, "LEFT", -3, -5)
					
					b:SetUITemplate("checkbutton")
				end
				
				once = true
			end
			if (PostalSelectOpenButton) then
				skinSelect()
			else
				if (Postal_Select) then
					hooksecurefunc(Postal_Select, "OnEnable", skinSelect)
				end
			end
		end
		
	end
	F.SkinAddOn("Postal", SkinFunc)

end
