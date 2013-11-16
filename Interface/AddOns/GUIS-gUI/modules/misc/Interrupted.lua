-------IA v1.12--------

-- Start of Settings --
local IAraid = false;
local IAparty = false;
local IAsay = true;
--- End of Settings ---


local function OnEvent(self, event, ...)

	if ( event == "PLAYER_LOGIN" ) then
		self:UnregisterEvent("PLAYER_LOGIN");
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	elseif ( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
		local ZoneName = GetRealZoneText();
		local numParty	= GetNumPartyMembers();

		if (ZoneName == "Tol Barad") or (ZoneName == "Tol Barad Peninsula") or (ZoneName == "Wintergrasp") or (ZoneName == "Alterac Valley") or (ZoneName == "Arathi Basin") or (ZoneName == "Eye of the Storm") or (ZoneName == "Isle of Conquest") or (ZoneName == "Strand of the Ancients") or (ZoneName == "The Battle for Gilneas") or (ZoneName == "Twin Peaks") or (ZoneName == "Warsong Gulch") then
		else
					
			
			local event = select(2, ...)
			local sourceName = select(5, ...)
			local destName = select(9, ...)
			local extraSpellID = select(15, ...);


			
			------- Spell Interrupt -------

			if (event == "SPELL_INTERRUPT") and sourceName == UnitName("player") then
				intmsg = ("Interrupted "..destName.."'s "  ..GetSpellLink(extraSpellID).. ".")
				if UnitInRaid("player") and (IAraid == true) then
					SendChatMessage(intmsg, "RAID")
				elseif UnitInParty("player") and (IAparty == true) and (numParty > 0) then
					SendChatMessage(intmsg, "PARTY")
				elseif (IAsay == true) then
					SendChatMessage(intmsg, "SAY")
				end

			------- Spell Dispell (both Friend and Foe)-------

			elseif (event == "SPELL_DISPEL") and sourceName == UnitName("player") then
				intmsg = ("Dispelled "..destName.."'s "  ..GetSpellLink(extraSpellID).. ".")
				if UnitInRaid("player") and (IAraid == true) then
					SendChatMessage(intmsg, "RAID")
				elseif UnitInParty("player") and (IAparty == true) and (numParty > 0) then
					SendChatMessage(intmsg, "PARTY")
				elseif (IAsay == true) then
					SendChatMessage(intmsg, "SAY")
				end
			
			------- Spellsteal (with Exclusions) -------
			
			elseif (event == "SPELL_STOLEN") and sourceName == UnitName("player") 
								and (destName ~= "Arcanotron")
								and (destName ~= "Lord Jaraxxus")
								then
				intmsg = ("Spellstole "..destName.."'s "  ..GetSpellLink(extraSpellID).. ".")
				if UnitInRaid("player") and (IAraid == true) then
					SendChatMessage(intmsg, "RAID")
				elseif UnitInParty("player") and (IAparty == true) and (numParty > 0) then
					SendChatMessage(intmsg, "PARTY")
				elseif (IAsay == true) then
					SendChatMessage(intmsg, "SAY")
				end

			------- Spell Reflect is in a different file -------

			end
		end
	end;
end

local ImmortalisAnnounce = CreateFrame("Frame")
ImmortalisAnnounce:RegisterEvent("PLAYER_LOGIN")
ImmortalisAnnounce:SetScript("OnEvent", OnEvent)