local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: DeveloperTools")

-- Lua API
local print = print
local pairs, select = pairs, select
local strmatch = string.match
local tonumber = tonumber

local CreateChatCommand = function(...) module:CreateChatCommand(...) end
local RegisterCallback = function(...) module:RegisterCallback(...) end

module.OnInit = function(self)
	local GetRegionNames = function (cmd)
		if (cmd) and (_G[cmd]) then
			local regions = { _G[cmd]:GetRegions() }

			for i, v in pairs(regions) do
				print(i, v.GetName and v:GetName() or "")
			end
		elseif (cmd) then
			print("Nothing found for "..cmd)
		end
	end
	
	local HideRegion = function (cmd,opt)
		if (cmd) and (_G[cmd]) then
			(select(tonumber(opt),_G[cmd]:GetRegions())):Hide()
		end
	end
	
	local GetItemString = function(...)
		local _, itemLink = GetItemInfo(strjoin(" ", ...))
		
		if (itemLink) then
			print(strmatch(itemLink, "item[%-?%d:]+"))
		end
	end
	
	local GetItemID = function(...)
		local itemLink, itemID

		local link = strjoin(" ", ...)
		if (strsub(link, 1, 7) == "|Hitem:") then
			itemLink = link
		else
			itemLink = (select(2, GetItemInfo(link)))
		end
		
		if (itemLink) then
			local itemString = strmatch(itemLink, "item[%-?%d:]+")
			local _, itemID = strsplit(":", itemString)
			
			print(itemLink, itemID)
		end
	end

	CreateChatCommand(GetRegionNames, "getregions")
	CreateChatCommand(HideRegion, "hideregion")
	CreateChatCommand(GetItemID, "itemid")
	CreateChatCommand(GetItemString, "itemstring")
end

