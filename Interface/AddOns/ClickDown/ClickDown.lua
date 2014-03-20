-- ClickDown by Andromerius (asilva) With extensive help from Vrul (wowinterface.com) v1.4


local buttons = {
	"ActionButton",
	"ExtraActionButton",
	"MultiBarBottomLeftButton",
	"MultiBarBottomRightButton",
	"MultiBarRightButton",
	"MultiBarLeftButton",
	"OverrideActionBarButton",
	"PetActionButton",
	"StanceButton",
}

local function SetClickMode(mode)
	for index = 1, #buttons do
		for id = 1, NUM_ACTIONBAR_BUTTONS or 12 do
			local button = _G[buttons[index] .. id]
			if button then
				button:RegisterForClicks(mode)
			end
		end
	end
end


-- Database defaults and quick reference

local defaults = {
	profile = {
		active = true,
	},
}

local globalDB


-- Ace3 options table

local options = {
	name = "ClickDown",
	type = "group",
	args = {
		active = {
			name = "Enable AddOn",
			desc = "Ticked: Enabled, Unticked: Disabled.",
			type = "toggle",
			get = function(info)
				return globalDB.active
			end,
			set = function(info, value)
				globalDB.active = value
				SetClickMode(value and "AnyDown" or "AnyUp")
			end,
		},
	},
}


-- Create and initialize addon

ClickDown = LibStub("AceAddon-3.0"):NewAddon("ClickDown", "AceConsole-3.0")

function ClickDown:OnInitialize()

	-- Register the DataBase
	self.db = LibStub("AceDB-3.0"):New("ClickDownDB", defaults, true)
	globalDB = self.db.global
	
	-- Register and add options table to the interface UI
	LibStub("AceConfig-3.0"):RegisterOptionsTable("ClickDown", options)
	local optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("ClickDown", "ClickDown")

	-- Slash command
	local function OpenOptions()
		InterfaceOptionsFrame_OpenToCategory(optionsFrame)
		if not optionsFrame:IsVisible() then									-- Temp fix for Blizzard bug
			InterfaceOptionsFrame_OpenToCategory(optionsFrame)
		end
	end
	LibStub("AceConsole-3.0"):RegisterChatCommand("clickdown", OpenOptions)
	LibStub("AceConsole-3.0"):RegisterChatCommand("cdown", OpenOptions)

	-- If enabled then change click behavior
	if globalDB.active then
		SetClickMode("AnyDown")
	end

end