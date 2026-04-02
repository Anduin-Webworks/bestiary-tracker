-- UI Frame Setup
local function CreateBestiaryUI()
    if BestiaryFrame then BestiaryFrame:Show() return end

    -- 1. Create the Main Window
    local f = CreateFrame("Frame", "BestiaryFrame", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(400, 500)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f.TitleText:SetText("Bestiary Kill Ledger")

    -- 2. Data Preparation: Convert DB to a Sortable List
    local listData = {}
    for id, data in pairs(BestiaryKillsDB) do
        table.insert(listData, {name = data.name, count = data.count})
    end
    -- Sort by highest kill count
    table.sort(listData, function(a, b) return a.count > b.count end)

    -- 3. Create the ScrollBox (The modern way to handle lists in 12.0)
    f.ScrollBox = CreateFrame("Frame", nil, f, "WowScrollBoxList")
    f.ScrollBox:SetPoint("TOPLEFT", 10, -30)
    f.ScrollBox:SetPoint("BOTTOMRIGHT", -25, 10)

    f.ScrollBar = CreateFrame("EventFrame", nil, f, "MinimalScrollBar")
    f.ScrollBar:SetPoint("TOPLEFT", f.ScrollBox, "TOPRIGHT", 5, 0)
    f.ScrollBar:SetPoint("BOTTOMLEFT", f.ScrollBox, "BOTTOMRIGHT", 5, 0)

    -- 4. Define how each "Row" looks
    local function Initializer(button, data)
        button.text:SetText(string.format("|cFFFFFFFF%s|r", data.name))
        button.count:SetText(string.format("|cFF00FF00%d|r", data.count))
    end

    local view = CreateScrollBoxListLinearView()
    view:SetElementExtent(24) -- Height of each row
    view:SetElementInitializer("Button", function(button, data)
        -- Add text to the row if it doesn't exist
        if not button.text then
            button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            button.text:SetPoint("LEFT", 5, 0)
            button.count = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            button.count:SetPoint("RIGHT", -5, 0)
        end
        Initializer(button, data)
    end)

    ScrollUtil.InitScrollBoxListWithScrollBar(f.ScrollBox, f.ScrollBar, view)
    
    -- 5. Push the Data to the UI
    local dataProvider = CreateDataProvider(listData)
    f.ScrollBox:SetDataProvider(dataProvider)

    BestiaryFrame = f
end

-- Update Slash Command to handle "display"
SLASH_BESTIARY1 = "/bt"
SlashCmdList["BESTIARY"] = function(msg)
    if msg == "display" then
        CreateBestiaryUI()
    else
        -- Your existing target-check logic here
        local name, npcID = GetUnitInfo("target")
        if name then
            print(string.format("Kills for %s: %d", name, BestiaryKillsDB[npcID] and BestiaryKillsDB[npcID].count or 0))
        else
            print("Usage: /bt display  (to see the list)")
        end
    end
end
