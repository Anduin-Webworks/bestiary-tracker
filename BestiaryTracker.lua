local addonName, addonTable = ...
local frame = CreateFrame("Frame", "BestiaryTrackerFrame")

-- Helper: Safely get info (12.0 Midnight Workaround)
local function GetUnitInfo(unit)
    local name = UnitName(unit)
    if not name then return nil, nil end
    
    local npcID = "Unknown"
    local tooltipData = C_TooltipInfo.GetUnit(unit)
    if tooltipData and tooltipData.guid then
        pcall(function()
            -- Split the GUID string to find the NPC ID
            local _, _, _, _, _, id = strsplit("-", tooltipData.guid)
            npcID = id
        end)
    end
    return name, npcID
end

local function RecordKill(name, npcID)
    if not name then return end
    npcID = npcID or "Unknown"
    
    if not BestiaryKillsDB[npcID] then
        BestiaryKillsDB[npcID] = {
            name = name,
            count = 0,
            firstKilled = date("%Y-%m-%d"),
            zone = GetRealZoneText()
        }
    end
    
    BestiaryKillsDB[npcID].count = BestiaryKillsDB[npcID].count + 1
    BestiaryKillsDB[npcID].lastKilled = date("%Y-%m-%d %H:%M:%S")
    
    print(string.format("|cFFBBFF00[Bestiary]|r Recorded kill: %s (Total: %d)", name, BestiaryKillsDB[npcID].count))
end

-- Event Handling
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        if ... == addonName then
            BestiaryKillsDB = BestiaryKillsDB or {}
            print("|cFF00FF00Bestiary Tracker Initialized.|r")
        end

    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local unit = ...
        if UnitExists(unit) and UnitIsDead(unit) and not UnitIsPlayer(unit) then
            local name, npcID = GetUnitInfo(unit)
            RecordKill(name, npcID)
        end
    end
end)

-- Slash Command - Now correctly calling from the addonTable
SLASH_BESTIARY1 = "/bt"
SlashCmdList["BESTIARY"] = function(msg)
    if msg == "display" then
        -- This calls the function defined in BestiaryUI.lua
        addonTable.CreateBestiaryUI()
    else
        local name, npcID = GetUnitInfo("target")
        if name then
            local count = (BestiaryKillsDB[npcID] and BestiaryKillsDB[npcID].count) or 0
            print(string.format("Kills for %s: %d", name, count))
        else
            print("Usage: /bt display | Or target a creature and type /bt")
        end
    end
end