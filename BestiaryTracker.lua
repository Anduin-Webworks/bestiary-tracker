local addonName, addonTable = ...
local frame = CreateFrame("Frame", "BestiaryTrackerFrame")

-- Helper: Safely get a name/ID for a unit
-- In 12.0, we use Tooltip Data because raw GUIDs are "Secret"
local function GetUnitInfo(unit)
    local name = UnitName(unit)
    if not name then return nil, nil end
    
    -- Attempt to get NPC ID via Tooltip (Midnight workaround)
    local npcID = "Unknown"
    local tooltipData = C_TooltipInfo.GetUnit(unit)
    if tooltipData and tooltipData.guid then
        -- We pcall this because string-ops on Secret GUIDs can crash 12.0.5+
        pcall(function()
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
    
    -- UI Feedback
    print(string.format("|cFFBBFF00[Bestiary]|r Recorded kill: %s (Total: %d)", name, BestiaryKillsDB[npcID].count))
end

-- Event Handling
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED") -- Fired when a unit dies/is out of range
frame:RegisterEvent("PLAYER_TARGET_CHANGED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        if ... == addonName then
            BestiaryKillsDB = BestiaryKillsDB or {}
            print("|cFF00FF00Bestiary Tracker Initialized.|r (Midnight API)")
        end

    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local unit = ...
        -- If it was a hostile creature and it's now dead
        if UnitExists(unit) and UnitIsDead(unit) and not UnitIsPlayer(unit) then
            local name, npcID = GetUnitInfo(unit)
            RecordKill(name, npcID)
        end
    end
end)

-- Manual Slash Command for current target
SLASH_BESTIARY1 = "/bt"
SlashCmdList["BESTIARY"] = function()
    local name, npcID = GetUnitInfo("target")
    if name and BestiaryKillsDB[npcID] then
        print(string.format("Kills for %s: %d", name, BestiaryKillsDB[npcID].count))
    elseif name then
        print("No records for " .. name)
    else
        print("Target something first!")
    end
end