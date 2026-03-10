-- Auto SSA & Might Ring HUD Toggles for Zerobot
-- Author: SamuHell
-- Creates three icons to control Auto SSA and Auto Might Ring.

-- #################### CONFIGURATION ####################
-- Item IDs for the HUD icons.
local COMBINED_ICON_ID = 7532 -- Koshei's Ancient Amulet, representing both
local SSA_ONLY_ICON_ID = 3081   -- Stone Skin Amulet
local RING_ONLY_ICON_ID = 3048  -- Might Ring

-- Position managed by HudLayout
local GROUP = "scripts"
local SLOT = 8

-- How often to check for external changes (in milliseconds).
local SYNC_INTERVAL_MS = 200

-- Opacity for the icon when ON vs OFF.
local OPACITY_ON = 1.0
local OPACITY_OFF = 0.5
-- ######################################################


-- State tracking variables for the HUD objects
local combinedIcon, ssaIcon, mightRingIcon = nil, nil, nil
local bothLabel, ssaLabel, ringLabel = nil, nil, nil

-- This single function updates the appearance of all three icons.
local function updateAllIconStates()
    if not combinedIcon then
        return
    end -- Check if icons have been created

    local isSsaEnabled = Engine.isAutoSSAEnabled()
    local isMightRingEnabled = Engine.isAutoMightRingEnabled()

    -- Update Combined Icon: On only if BOTH are enabled.
    if isSsaEnabled and isMightRingEnabled then
        combinedIcon:setOpacity(OPACITY_ON)
        if bothLabel then bothLabel:setColor(80, 220, 80) end
    else
        combinedIcon:setOpacity(OPACITY_OFF)
        if bothLabel then bothLabel:setColor(160, 160, 160) end
    end

    -- Update SSA Only Icon
    if isSsaEnabled then
        ssaIcon:setOpacity(OPACITY_ON)
        if ssaLabel then ssaLabel:setColor(80, 220, 80) end
    else
        ssaIcon:setOpacity(OPACITY_OFF)
        if ssaLabel then ssaLabel:setColor(160, 160, 160) end
    end

    -- Update Ring Only Icon
    if isMightRingEnabled then
        mightRingIcon:setOpacity(OPACITY_ON)
        if ringLabel then ringLabel:setColor(80, 220, 80) end
    else
        mightRingIcon:setOpacity(OPACITY_OFF)
        if ringLabel then ringLabel:setColor(160, 160, 160) end
    end
end

-- Toggle function for the COMBINED icon.
local function toggleCombined()
    local isSsaEnabled = Engine.isAutoSSAEnabled()
    local isMightRingEnabled = Engine.isAutoMightRingEnabled()
    -- if they aren't both on, turn them both on. If they are both on, turn them both off.
    local newState = not (isSsaEnabled and isMightRingEnabled)

    Engine.autoSSAEnable(newState)
    Engine.autoMightRingEnable(newState)

    Timer.new("UpdateCombinedDelay", function()
        updateAllIconStates()
        if newState then
            print(">> Auto SSA & Might Ring ENABLED.")
        else
            print(">> Auto SSA & Might Ring DISABLED.")
        end
    end, 100, false)
end

-- Toggle function for the SSA ONLY icon.
local function toggleSsaOnly()
    local isCurrentlyEnabled = Engine.isAutoSSAEnabled()
    Engine.autoSSAEnable(not isCurrentlyEnabled)

    Timer.new("UpdateSsaDelay", function()
        updateAllIconStates()
        if not isCurrentlyEnabled then
            print(">> Auto SSA ENABLED.")
        else
            print(">> Auto SSA DISABLED.")
        end
    end, 100, false)
end

-- Toggle function for the RING ONLY icon.
local function toggleMightRingOnly()
    local isCurrentlyEnabled = Engine.isAutoMightRingEnabled()
    Engine.autoMightRingEnable(not isCurrentlyEnabled)

    Timer.new("UpdateRingDelay", function()
        updateAllIconStates()
        if not isCurrentlyEnabled then
            print(">> Auto Might Ring ENABLED.")
        else
            print(">> Auto Might Ring DISABLED.")
        end
    end, 100, false)
end

local function load()
    local pos = HudLayout.getSlotPosition(GROUP, SLOT)
    combinedIcon = HUD.new(pos.x, pos.y, COMBINED_ICON_ID, true)
    ssaIcon = HUD.new(pos.x + 40, pos.y, SSA_ONLY_ICON_ID, true)
    mightRingIcon = HUD.new(pos.x + 80, pos.y, RING_ONLY_ICON_ID, true)
    bothLabel = HUD.new(pos.x, pos.y + 8, "Both", true)
    ssaLabel = HUD.new(pos.x + 40, pos.y + 8, "SSA", true)
    ringLabel = HUD.new(pos.x + 80, pos.y + 8, "Ring", true)

    if combinedIcon and ssaIcon and mightRingIcon then
        combinedIcon:setCallback(toggleCombined)
        ssaIcon:setCallback(toggleSsaOnly)
        mightRingIcon:setCallback(toggleMightRingOnly)
        HudLayout.registerElement(GROUP, SLOT, combinedIcon, 0, 0)
        HudLayout.registerElement(GROUP, SLOT, ssaIcon, 40, 0)
        HudLayout.registerElement(GROUP, SLOT, mightRingIcon, 80, 0)
        HudLayout.registerElement(GROUP, SLOT, bothLabel, 0, 8)
        HudLayout.registerElement(GROUP, SLOT, ssaLabel, 40, 8)
        HudLayout.registerElement(GROUP, SLOT, ringLabel, 80, 8)

        if bothLabel then bothLabel:setFontSize(8) end
        if ssaLabel then ssaLabel:setFontSize(8) end
        if ringLabel then ringLabel:setFontSize(8) end

        -- Set the initial appearance of all icons.
        updateAllIconStates()

        -- Create a single recurring timer to keep all icons synchronized.
        Timer.new("DefensiveSyncTimer", updateAllIconStates, SYNC_INTERVAL_MS, true)

        print("> Defensive Toggles HUD loaded.")
    else
        print("> ERROR: Failed to create Defensive Toggles HUD.")
    end
end

local function unload()
    if combinedIcon then HudLayout.unregisterElement(combinedIcon); combinedIcon:destroy(); combinedIcon = nil end
    if ssaIcon then HudLayout.unregisterElement(ssaIcon); ssaIcon:destroy(); ssaIcon = nil end
    if mightRingIcon then HudLayout.unregisterElement(mightRingIcon); mightRingIcon:destroy(); mightRingIcon = nil end
    if bothLabel then HudLayout.unregisterElement(bothLabel); bothLabel:destroy(); bothLabel = nil end
    if ssaLabel then HudLayout.unregisterElement(ssaLabel); ssaLabel:destroy(); ssaLabel = nil end
    if ringLabel then HudLayout.unregisterElement(ringLabel); ringLabel:destroy(); ringLabel = nil end
    destroyTimer("DefensiveSyncTimer")
    print("> Defensive Toggles HUD unloaded.")
end

return {
    load = load,
    unload = unload
}
