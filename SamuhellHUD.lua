-- SamuhellHUD Main Controller
-- Author: SamuHell
-- Loads and manages all individual SamuhellScripts.

local SCRIPTS_FOLDER = "SamuhellScripts/"
local STORAGE_FOLDER = "SamuhellScripts/Storage/"

-- Item ID for the main settings icon.
local SETTINGS_ICON_ID = 9153

-- Position of the main settings icon on the screen.
local gameWindow = Client.getGameWindowDimensions()
local ICON_POSITION_X = 10
local ICON_POSITION_Y = gameWindow.height - 42

-- List of all manageable scripts.
local allScripts = {
    { name = "Eat", file = "eat.lua.script", defaultState = true },
    { name = "Rage", file = "rage.lua.script", defaultState = false },
    { name = "Open Doors", file = "doors.lua.script", defaultState = true },
    { name = "Exiva", file = "exiva.lua.script", defaultState = true },
    { name = "Oberon", file = "oberon.lua.script", defaultState = true },
    { name = "Fishing", file = "fishing.lua.script", defaultState = true },
    { name = "Skinner", file = "skinner.lua.script", defaultState = true },
    { name = "Autoloot", file = "autoloot.lua.script", defaultState = true },
    { name = "Anti-Push", file = "anti_push.lua.script", defaultState = true },
    { name = "Haste", file = "autohaste.lua.script", defaultState = true },
    { name = "Autoshoot", file = "autoshoot.lua.script", defaultState = false },
    { name = "Hold Target", file = "holdtarget.lua.script", defaultState = true },
    { name = "MWall", file = "shootmwall.lua.script", defaultState = true },
    { name = "FPS/Ping", file = "fps_latency.lua.script", defaultState = true },
    { name = "SSA/Might", file = "auto_ssa_might.lua.script", defaultState = true },
    { name = "Effects", file = "toggle_effects.lua.script", defaultState = true },
    { name = "Exercise", file = "training.lua.script", defaultState = true },
    { name = "CaveBot", file = "cavebot_toggle.lua.script", defaultState = true },
    -- New: Native bot system toggles (Column 2)
    { name = "Healing", file = "healing_toggle.lua.script", defaultState = true },
    { name = "Targeting", file = "targeting_toggle.lua.script", defaultState = true },
    { name = "Shooter", file = "magic_shooter_toggle.lua.script", defaultState = true },
    { name = "Equipment", file = "equipment_toggle.lua.script", defaultState = true },
    { name = "HealFriend", file = "heal_friend_toggle.lua.script", defaultState = true },
    { name = "Timer", file = "timer_toggle.lua.script", defaultState = true },
    { name = "BotMaster", file = "bot_master_toggle.lua.script", defaultState = true },
    { name = "Profiles", file = "profile_switcher.lua.script", defaultState = true },
}

-- Runtime state variables
local settingsIcon = nil
local settingsModal = nil
local layoutModule = nil
local charInfoModule = nil
local botStatusModule = nil
local playerStatsModule = nil

-- Initialize runtime state for each script
for i, script in ipairs(allScripts) do
    script.module = nil
    script.isLoaded = false
end

-- Forward declarations for script loading functions
local loadScript, unloadScript

local function getStorageFileName(scriptName)
    local worldName = Client.getWorldName()
    local charName = Player.getName()

    -- Trim and replace spaces and colons
    worldName = worldName:gsub("^%s*(.-)%s*$", "%1"):gsub("%s", "_"):gsub(":", ".")
    charName = charName:gsub("^%s*(.-)%s*$", "%1"):gsub("%s", "_"):gsub(":", ".")

    return string.format("%s_%s_%s.json", worldName, charName, scriptName)
end

local function saveScriptStates()
    local states = {}
    for _, script in ipairs(allScripts) do
        states[script.name] = script.isLoaded
    end

    local fileName = getStorageFileName("SamuhellHUD")
    local filePath = Engine.getScriptsDirectory() .. "/" .. STORAGE_FOLDER .. fileName
    local file = io.open(filePath, "w")
    if file then
        file:write(JSON.encode(states))
        file:close()
    end
end

local function loadScriptStates()
    local fileName = getStorageFileName("SamuhellHUD")
    local filePath = Engine.getScriptsDirectory() .. "/" .. STORAGE_FOLDER .. fileName
    local file = io.open(filePath, "r")
    if file then
        local content = file:read("*a")
        file:close()
        local states = JSON.decode(content)
        if states then
            for i, script in ipairs(allScripts) do
                if states[script.name] and not script.isLoaded then
                    loadScript(i)
                elseif not states[script.name] and script.isLoaded then
                    unloadScript(i)
                end
            end
        end
        return true -- States loaded
    end
    return false -- No states file
end


-- Tries to load a script module by its file name.
loadScript = function(scriptIndex)
    local script = allScripts[scriptIndex]
    if not script or script.isLoaded then
        return
    end

    local filePath = Engine.getScriptsDirectory() .. "/" .. SCRIPTS_FOLDER .. script.file

    local chunk, compileError = loadfile(filePath)
    if not chunk then
        print(string.format("!! ERROR compiling module %s: %s", script.file, tostring(compileError)))
        return
    end

    local success, module = pcall(chunk)

    if success and type(module) == "table" and module.load then
        script.module = module
        script.module.load()
        script.isLoaded = true
        print(string.format(">> Loaded module: %s", script.name))
    else
        print(string.format("!! ERROR loading module %s: %s", script.file, tostring(module)))
    end
end

-- Unloads a script module.
unloadScript = function(scriptIndex)
    local script = allScripts[scriptIndex]
    if not script or not script.isLoaded or not script.module then
        return
    end

    if script.module.unload then
        script.module.unload()
    end

    script.module = nil
    script.isLoaded = false
    print(string.format(">> Unloaded module: %s", script.name))
end

-- Main function to open the settings panel.
local openSettingsModal

-- Callback for modal button clicks.
local function onModalButtonClick(buttonIndex)
    if buttonIndex == #allScripts then
        if settingsModal then
            saveScriptStates()
            settingsModal:destroy()
            settingsModal = nil
        end
        return
    end

    local scriptIndex = buttonIndex + 1
    local script = allScripts[scriptIndex]
    if script.isLoaded then
        unloadScript(scriptIndex)
    else
        loadScript(scriptIndex)
    end

    openSettingsModal()
end

-- Definition of the function to open the settings modal.
openSettingsModal = function()
    if settingsModal then
        settingsModal:destroy()
    end

    settingsModal = CustomModalWindow("SamuhellHUD Scripts", "Toggle scripts on or off.")

    for i, script in ipairs(allScripts) do
        local status = script.isLoaded and '<font color="#00FF00">ON</font>' or '<font color="#FF6666">OFF</font>'
        local buttonText = string.format("%s: %s", script.name, status)
        settingsModal:addButton(buttonText)
    end

    settingsModal:addButton("Save & Close")
    settingsModal:setCallback(onModalButtonClick)
end

-- Helper: load an always-on module (char_info, bot_status, etc.)
local function loadAlwaysOnModule(scriptFile, label)
    local path = Engine.getScriptsDirectory() .. "/" .. SCRIPTS_FOLDER .. scriptFile
    local chunk, err = loadfile(path)
    if not chunk then
        print(string.format("!! ERROR loading module %s: %s", scriptFile, tostring(err)))
        return nil
    end
    local success, mod = pcall(chunk)
    if success and type(mod) == "table" and mod.load then
        mod.load()
        print(string.format(">> Loaded module: %s", label))
        return mod
    else
        print(string.format("!! ERROR initialising %s: %s", scriptFile, tostring(mod)))
        return nil
    end
end

-- Main load function for the entire HUD controller.
local function loadController()
    print(">> SamuhellHUD Controller loading...")

    -- Settings icon (improved: scale + subtle opacity boost)
    settingsIcon = HUD.new(ICON_POSITION_X, ICON_POSITION_Y, SETTINGS_ICON_ID, true)
    if settingsIcon then
        settingsIcon:setScale(1.4)
        settingsIcon:setOpacity(0.92)
        settingsIcon:setCallback(openSettingsModal)
    end

    -- Load layout manager FIRST (exposes HudLayout globally)
    layoutModule = loadAlwaysOnModule("hud_layout.lua.script", "HUD Layout")
    if layoutModule then
        HudLayout = layoutModule
    end

    -- Always-on modules (not toggleable via menu)
    charInfoModule    = loadAlwaysOnModule("char_info.lua.script",    "Char Info")
    botStatusModule   = loadAlwaysOnModule("bot_status.lua.script",   "Bot Status")
    playerStatsModule = loadAlwaysOnModule("player_stats.lua.script", "Player Stats")

    if not loadScriptStates() then
        -- Determine vocation for default script loading
        local player = Creature(Player.getId())
        local vocation = player and player:getVocation() or Enums.Vocations.NONE
        local isKnight = (vocation == Enums.Vocations.KNIGHT or vocation == Enums.Vocations.ELITE_KNIGHT)

        for i, script in ipairs(allScripts) do
            local shouldLoad = script.defaultState

            if script.name == "Rage" then
                shouldLoad = isKnight
            elseif script.name == "Autoshoot" then
                shouldLoad = not isKnight
            end

            if shouldLoad then
                loadScript(i)
            end
        end
    end

    print(">> SamuhellHUD Controller loaded successfully.")
end

-- Main unload function for the entire HUD controller.
local function unloadController()
    print(">> SamuhellHUD Controller unloading...")
    for i, script in ipairs(allScripts) do
        if script.isLoaded then
            unloadScript(i)
        end
    end

    -- Unload always-on modules
    if charInfoModule and charInfoModule.unload then
        charInfoModule.unload()
        charInfoModule = nil
    end

    if botStatusModule and botStatusModule.unload then
        botStatusModule.unload()
        botStatusModule = nil
    end

    if playerStatsModule and playerStatsModule.unload then
        playerStatsModule.unload()
        playerStatsModule = nil
    end

    -- Unload layout manager LAST
    if layoutModule and layoutModule.unload then
        layoutModule.unload()
        layoutModule = nil
        HudLayout = nil
    end

    if settingsIcon then
        settingsIcon:destroy()
        settingsIcon = nil
    end

    if settingsModal then
        settingsModal:destroy()
        settingsModal = nil
    end

    print(">> SamuhellHUD Controller unloaded successfully.")
end

-- The script starts here by calling the main load function.
loadController()

-- Provide the unload function globally so it can be called if the script is reloaded.
SamuhellHUD_Unload = unloadController
