local addon, ns = ...

local GUIS = LibStub("gCore-3.0"):GetModule("GUIS-gUI: Core")
local CreateChatCommand = function(...) GUIS:CreateChatCommand(...) end

-- global chat commands unrelated to any specific module
-- usually shortcuts for Blizzard functions

CreateChatCommand(function() 
	if (GetNumTalentGroups() == 1) then return end
	if (GetActiveTalentGroup() ~= 1) then
		SetActiveTalentGroup(1)
	end
end, {"spec1", "mainspec"})

CreateChatCommand(function() 
	if (GetNumTalentGroups() == 1) then return end
	if (GetActiveTalentGroup() ~= 2) then
		SetActiveTalentGroup(2)
	end
end, {"spec2", "offspec"})

CreateChatCommand(function() 
	if (GetNumTalentGroups() == 1) then return end
	SetActiveTalentGroup((GetActiveTalentGroup() == 1) and 2 or 1)
end, {"togglespec"})

CreateChatCommand(CombatLogClearEntries, "fixlog")
CreateChatCommand(DoReadyCheck, "rc")
CreateChatCommand(LeaveParty, "leaveparty")
CreateChatCommand(ReloadUI, "rl")
CreateChatCommand(RepopMe, "release")
CreateChatCommand(ToggleHelpFrame, "gm")
