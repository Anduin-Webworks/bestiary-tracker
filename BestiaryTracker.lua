local addonName, addonTable = ...
local frame = CreateFrame("Frame")

local function RecordKill(creatureName)
    if not creatureName or creatureName == "" then return end

    -- Initialize Database if it doesn't exist
    BestiaryKillsDB = BestiaryKillsDB or {}
    
    -- Name is our unique key
    if not BestiaryKillsDB[creatureName] then
        BestiaryKillsDB[creatureName] = {
            name = creatureName,
            count = 0,
            firstKilled = date("%Y-%m-%d"),
            zone = GetRealZoneText() or "Unknown"
        }
    end
    
    BestiaryKillsDB[creatureName].count = BestiaryKillsDB[creatureName].count + 1
    BestiaryKillsDB[creatureName].lastKilled = date("%Y-%m-%d %H:%M:%S")
    
    -- Print confirmation to your chat
    print(string.format("|cFFBBFF00[Bestiary]|r Recorded: %s (Total: %d)", creatureName, BestiaryKillsDB[creatureName].count))
    
    -- Refresh UI if it's open
    if BestiaryFrame and BestiaryFrame:IsShown() then
        BestiaryFrame:Refresh()
    end
end

-- Event Handling
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            BestiaryKillsDB = BestiaryKillsDB or {}
            print("|cFF00FF00Bestiary Tracker Loaded!|r Type /bt display to open")
        end

    elseif event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" then
        local msg = ...
        if msg then
            -- These patterns cover different locales and variations
            -- "You have slain X!"
            -- "You killed X."
            -- Remove any color codes first
            local cleanMsg = msg:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
            
            local name = cleanMsg:match("^You have slain (.+)!$") or 
                        cleanMsg:match("^You killed (.+)%.$") or
                        cleanMsg:match("^(.+) dies%.$")  -- Sometimes it's just "X dies."
            
            if name then
                RecordKill(name)
            end
        end
    end
end)

-- Slash Command
SLASH_BESTIARY1 = "/bt"
SLASH_BESTIARY2 = "/bestiary"
SlashCmdList["BESTIARY"] = function(msg)
    msg = msg:lower():trim()
    
    if msg == "display" or msg == "" then
        addonTable.CreateBestiaryUI()
    elseif msg == "reset" then
        BestiaryKillsDB = {}
        print("|cFFFFFF00[Bestiary]|r Kill database reset!")
        if BestiaryFrame and BestiaryFrame:IsShown() then
            BestiaryFrame:Refresh()
        end
    else
        print("|cFFFFFF00Bestiary Tracker Commands:|r")
        print("  /bt display - Open kill tracker window")
        print("  /bt reset - Clear all kill data")
    end
end
