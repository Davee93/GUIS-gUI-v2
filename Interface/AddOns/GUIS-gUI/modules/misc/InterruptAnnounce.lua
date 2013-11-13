-- ------------------------------------------------------------------------
-- > InterruptAnnounce 
-- ------------------------------------------------------------------------

local announce = CreateFrame("Frame")
local player = GetUnitName("player")
local priority = 0

announce:RegisterEvent("ADDON_LOADED");
announce:RegisterEvent("CHAT_MSG_ADDON")
announce:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");


function announceEvent(self, event, ...)


	if event == "ADDON_LOADED" then
		if activate == nil  then activate = true end
		if say == nil then say = false end
		if player == nil then player = false end
		
	end

        if event == "CHAT_MSG_ADDON" then

            local prefix, message, channel = ...;
		if prefix == "IA Priority" then
			priority = message
			
		end
        end

	if event == "COMBAT_LOG_EVENT_UNFILTERED" then

		if(activate) then
                    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags,
                    spellID, spellName, spellSchool, extraSpellID, extraSpellName  = ...;
		    
			
                        if not (subevent == "SPELL_INTERRUPT" and ( UnitInParty(sourceName) or UnitInRaid(sourceName)) ) then return end
			
			if (say) then
				sendInterruptMessage(sourceName, destName, extraSpellID, extraSpellName, spellID, spellName, "say")
			else	
				if (GetRealNumRaidMembers() > 0) then
					sendInterruptMessage(sourceName, destName, extraSpellID, extraSpellName, spellID, spellName, "raid")
				elseif (GetRealNumPartyMembers() > 0) then
					sendInterruptMessage(sourceName, destName, extraSpellID, extraSpellName, spellID, spellName, "party")
				end	
			end
		end
	end
end


function sendInterruptMessage(sourceName, destName, extraSpellID, extraSpellName, spellID, spellName, channel)


	--[[if sourceName == player then
	
		SendAddonMessage("IA Priority", "5", "WHISPER", "Apocapthc" )
	end

	if priority == 0 then
		SendChatMessage("-"..sourceName.."- "..INTERRUPTED.." "..destName.."'s \124cff71d5ff\124Hspell:"..extraSpellID.."\124h["..extraSpellName.."]\124h\124r! with \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", channel, nil, nil)
	end]]--
	
	SendChatMessage("-"..sourceName.."- "..INTERRUPTED.." "..destName.."'s \124cff71d5ff\124Hspell:"..extraSpellID.."\124h["..extraSpellName.."]\124h\124r! with \124cff71d5ff\124Hspell:"..spellID.."\124h["..spellName.."]\124h\124r!", channel, nil, nil)
end


announce:SetScript("OnEvent", announceEvent);

SLASH_IA1 = "/ia"
SLASH_IA2 = "/interruptannounce"
	
local cmdHandler = function(msg)
		
local cmd, arg = msg:match("^(%S*)%s*(.-)$")
	if ( cmd == "toggle" or cmd == "activate")  then
		if(activate == true) then 
			activate=false
			print("|cffade516Interrupt Annouce|r |cfff00000deactivated |r" )
		else
			activate=true
			print("|cffade516Interrupt Annouce|r |c000fff00activated |r" )
		end
	elseif ( cmd == "say")  then 
		if(say) then 
			say=false
			print("|cffade516Use say channel|r |cfff00000deactivated |r" )
		else
			say=true
			print("|cffade516Use say channel|r |c000fff00activated |r" )
		end
	--[[elseif ( cmd == "player")  then 
		if(player) then 
			player=false
			print("|cffade516Only self interrupts|r |cfff00000deactivated |r" )
		else
			player=true
			print("|cffade516Only self interrupts |r |c000fff00activated |r" )
		end--]] --not yet implemented
	else
		print("|cffe4ff00Syntax:|r")
		print("|cffe4ff00To activate or deactivate Interrupt Announce type:|r")
		print("/interruptannounce |cffade516activate|r or /ia |cffade516toggle|r ")
		print("|cffe4ff00To always announce to say channel:|r")
		print("/interruptannounce |cffade516activate|r or /ia |cffade516say|r")
	
	end
end
		
SlashCmdList["IA"] = cmdHandler
