local SaySapped = CreateFrame("Frame")
SaySapped.playername = UnitName("player")

SaySapped:SetScript("OnEvent",function(...)

	if ((select(14,...) == 6770)
	and (select(11,...) == SaySapped.playername)
	and (select(4,...) == "SPELL_AURA_APPLIED" or select(4,...) == "SPELL_AURA_REFRESH"))
	then
		SendChatMessage("Sapped", "SAY")
		DEFAULT_CHAT_FRAME:AddMessage("Sapped by: "..(select(7,...) or "(unknown)"))
	end
end)

SaySapped:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
DEFAULT_CHAT_FRAME:AddMessage("SaySapped loaded")
