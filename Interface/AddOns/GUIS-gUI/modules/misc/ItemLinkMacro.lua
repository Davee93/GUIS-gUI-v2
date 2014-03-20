    local commands = {
        [string.gsub(SLASH_CAST1, '/', '')] = true,
        [string.gsub(SLASH_EQUIP1, '/', '')] = true,
        [string.gsub(SLASH_USE1, '/', '')] = true,
        ['cast'] = true,
        ['equip'] = true,
        ['use'] = true,
    }
     
    hooksecurefunc('ChatEdit_InsertLink', function(link)
        if(MacroFrameText and MacroFrameText:HasFocus() and string.find(link, 'item:', 1, true)) then
            local macroText = MacroFrameText:GetText()
            local _, _, commandName = string.find(macroText, '/(%l+)')
            if(not commands[commandName]) then
                local item = string.match(link, '%[(.-)%]')
                if(string.find(macroText, item, 1, true)) then
                    item = string.gsub(item, '%-', '%%-')
     
                    local newline = string.find(macroText, '\n$') and '\n' or ''
                    local newMacroText = string.gsub(string.gsub(macroText, item .. '$', ''), item .. '\n$', '') .. link .. newline
                    if(string.len(newMacroText) <= 255) then
                        MacroFrameText:SetText(newMacroText)
                    end
                end
            end
        end
    end)