--[[
	Copyright (c) 2012, Lars "Goldpaw" Norberg
	
	Web: http://www.friendlydruid.com
	Contact: goldpaw@friendlydruid.com
	
	All rights reserved
]]--

local addon, ns = ...

local module = LibStub("gCore-3.0"):NewModule("GUIS-gUI: GroupTools")

-- Lua API
local unpack = unpack

-- WoW API
local CompactRaidFrameManager_GetSetting = CompactRaidFrameManager_GetSetting
local CreateFrame = CreateFrame
local GetNumRaidMembers = GetNumGroupMembers or GetNumRaidMembers
local InCombatLockdown = InCombatLockdown

-- GUIS API
local M = LibStub("gMedia-3.0")
local L = LibStub("gLocale-1.0"):GetLocale(addon)
local C = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Colors")
local F = LibStub("gDB-1.0"):GetDataBase("GUIS-gUI: Functions")
local RegisterCallback = function(...) return module:RegisterCallback(...) end
local UnregisterCallback = function(...) return module:UnregisterCallback(...) end

local defaults = {}

module.RestoreDefaults = function(self)
	GUIS_DB["grouptools"] = DuplicateTable(defaults)
end

module.Init = function(self)
	GUIS_DB["grouptools"] = GUIS_DB["grouptools"] or {}
	GUIS_DB["grouptools"] = ValidateTable(GUIS_DB["grouptools"], defaults)
end

module.OnInit = function(self)
	if (F.kill(self:GetName())) then 
		self:Kill() 
		return 
	end
end

module.OnEnable = function(self)
	-- grabbing the little flag to create world raid markers, and placing it at the Minimap
	-- both party- and raid frames need this, so we need to make sure only the first to spawn creates it
	if not(_G["GUIS_GROUPTOOLS"]) then
		local LeaderTools = CreateFrame("Frame", "GUIS_GROUPTOOLS", UIParent, "SecureHandlerShowHideTemplate")
		LeaderTools:RegisterEvent("PARTY_LEADER_CHANGED")
		LeaderTools:RegisterEvent("PARTY_MEMBERS_CHANGED")
		LeaderTools:RegisterEvent("PLAYER_ENTERING_WORLD")
		LeaderTools:RegisterEvent("RAID_ROSTER_UPDATE")
		LeaderTools:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		LeaderTools:SetScript("OnEvent", function(self)
			if (InCombatLockdown()) then
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
			else
				self:UnregisterEvent("PLAYER_REGEN_ENABLED")
				self:SetVisibility(F.IsLeader())
			end
		end)

		-- now this is a mouthful. say it 11 times fast! do it!
		local bName = "CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton"
		_G[bName.."Left"]:SetTexture("")
		_G[bName.."Right"]:SetTexture("")
		_G[bName.."Middle"]:SetTexture("")
		_G[bName.."Left"].SetTexture = noop
		_G[bName.."Right"].SetTexture = noop
		_G[bName.."Middle"].SetTexture = noop
		_G[bName]:SetHighlightTexture("")
		_G[bName].SetHighlightTexture = noop
		_G[bName]:SetParent(LeaderTools)
		_G[bName]:ClearAllPoints()
		_G[bName]:SetPoint("RIGHT", Minimap, "RIGHT", 8, 0)
		
		_G["GUIS_GROUPTOOLS"] = LeaderTools
	end
end
