local addonName, addonTable = ...

function addonTable.CreateBestiaryUI()
    -- Toggle if already exists
    if BestiaryFrame then 
        BestiaryFrame:SetShown(not BestiaryFrame:IsShown()) 
        if BestiaryFrame:IsShown() then 
            BestiaryFrame:Refresh() 
        end
        return 
    end

    -- Create main frame
    local f = CreateFrame("Frame", "BestiaryFrame", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(400, 500)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f.TitleText:SetText("Kill Ledger")
    
    -- Add close button functionality
    f:SetScript("OnHide", function() end)

    -- Statistics text at top
    f.StatsText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f.StatsText:SetPoint("TOPLEFT", 15, -28)
    f.StatsText:SetText("Total Kills: 0 | Unique Creatures: 0")

    -- This function clears and re-populates the list based on current data
    f.Refresh = function(self)
        -- Initialize if needed
        BestiaryKillsDB = BestiaryKillsDB or {}
        
        local listData = {}
        local totalKills = 0
        local uniqueCreatures = 0
        
        for name, data in pairs(BestiaryKillsDB) do
            table.insert(listData, {
                name = name, 
                count = data.count,
                zone = data.zone or "Unknown",
                lastKilled = data.lastKilled or "Never"
            })
            totalKills = totalKills + data.count
            uniqueCreatures = uniqueCreatures + 1
        end
        
        -- Sort by kill count (highest first)
        table.sort(listData, function(a, b) return a.count > b.count end)
        
        -- Update stats
        self.StatsText:SetText(string.format("Total Kills: %d | Unique Creatures: %d", totalKills, uniqueCreatures))
        
        -- Update scroll view
        local dataProvider = CreateDataProvider(listData)
        self.ScrollBox:SetDataProvider(dataProvider)
    end

    -- ScrollBox Setup (Standard 12.0 API)
    f.ScrollBox = CreateFrame("Frame", nil, f, "WowScrollBoxList")
    f.ScrollBox:SetPoint("TOPLEFT", 10, -50)
    f.ScrollBox:SetPoint("BOTTOMRIGHT", -25, 10)

    f.ScrollBar = CreateFrame("EventFrame", nil, f, "MinimalScrollBar")
    f.ScrollBar:SetPoint("TOPLEFT", f.ScrollBox, "TOPRIGHT", 5, 0)
    f.ScrollBar:SetPoint("BOTTOMLEFT", f.ScrollBox, "BOTTOMRIGHT", 5, 0)

    -- Configure the list view
    local view = CreateScrollBoxListLinearView()
    view:SetElementExtent(28)
    view:SetElementInitializer("Button", function(button, data)
        if not button.text then
            -- Create name text
            button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            button.text:SetPoint("LEFT", 5, 0)
            button.text:SetJustifyH("LEFT")
            button.text:SetWidth(200)
            
            -- Create count text
            button.count = button:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            button.count:SetPoint("RIGHT", -5, 0)
            
            -- Tooltip on hover
            button:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.creatureName, 1, 1, 1)
                GameTooltip:AddLine(" ")
                GameTooltip:AddDoubleLine("Kills:", self.killCount, 0.7, 0.7, 0.7, 0, 1, 0)
                if self.zoneInfo then
                    GameTooltip:AddDoubleLine("First seen:", self.zoneInfo, 0.7, 0.7, 0.7, 1, 1, 1)
                end
                if self.lastKilledInfo then
                    GameTooltip:AddDoubleLine("Last killed:", self.lastKilledInfo, 0.7, 0.7, 0.7, 1, 1, 1)
                end
                GameTooltip:Show()
            end)
            
            button:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end
        
        button.text:SetText(data.name)
        button.count:SetText("|cFF00FF00" .. data.count .. "|r")
        
        -- Store for tooltip
        button.creatureName = data.name
        button.killCount = data.count
        button.zoneInfo = data.zone
        button.lastKilledInfo = data.lastKilled
    end)

    ScrollUtil.InitScrollBoxListWithScrollBar(f.ScrollBox, f.ScrollBar, view)
    
    -- Initial refresh
    f:Refresh()
    
    -- Store globally
    BestiaryFrame = f
end
