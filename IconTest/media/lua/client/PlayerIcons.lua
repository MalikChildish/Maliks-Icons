require "PlayerIconUI"  -- Import the custom UI class

-- Table to store PlayerIconUI instances for each player
local playerIcons = {}

-- Function to add the UI for a single player
local function addPlayerIcon(player)
    if not playerIcons[player] then
        local iconUI = PlayerIconUI:new(player)
        iconUI:initialise()
        iconUI:addToUIManager()
        playerIcons[player] = iconUI
        print("[DEBUG] Added icon for player: " .. tostring(player:getUsername()))  -- Debugging print
    else
        print("[DEBUG] Icon already exists for player: " .. tostring(player:getUsername()))  -- Debugging print
    end
end

-- Function to remove the UI for a single player
local function removePlayerIcon(player)
    if playerIcons[player] then
        playerIcons[player]:removeFromUIManager()
        playerIcons[player] = nil
        print("[DEBUG] Removed icon for player: " .. tostring(player:getUsername()))  -- Debugging print
    else
        print("[DEBUG] No icon found for player: " .. tostring(player:getUsername()))  -- Debugging print
    end
end

-- Function to update icons for all online players
local function updateAllPlayerIcons()
    print("[DEBUG] Updating all player icons...")

    -- Get the list of all online players
    local onlinePlayers = getOnlinePlayers()
    local numPlayers = onlinePlayers:size()

    -- Debugging player count
    print("[DEBUG] Number of online players: " .. tostring(numPlayers))

    -- Loop through all online players and update their icons
    for i = 0, numPlayers - 1 do
        local player = onlinePlayers:get(i)
        if player and player:isAlive() then
            print("[DEBUG] Found player at index " .. tostring(i) .. ": " .. tostring(player:getUsername()))  -- Debugging print for each player

            -- Add icon if it's not already present for the player
            addPlayerIcon(player)

            -- Update the icon for the player
            playerIcons[player]:update()
            print("[DEBUG] Updated icon for player: " .. tostring(player:getUsername()))
        else
            print("[DEBUG] No player found at index: " .. tostring(i))  -- Debugging print if no player is found at that index
        end
    end

    -- Clean up icons for players that are no longer online
    for player, iconUI in pairs(playerIcons) do
        if not player or not onlinePlayers:contains(player) then
            removePlayerIcon(player)  -- Remove icon if player is no longer online
        end
    end
end

-- Event hook to initialize the icon UI for all players when they are created (multiplayer support)
local function onPlayerCreate(playerIndex, player)
    print("[DEBUG] Player created: " .. tostring(player:getUsername()))
    addPlayerIcon(player)  -- Add the icon for the newly created player
end

-- Hook the render event to update player icons every frame
local function onUpdate()
    updateAllPlayerIcons()  -- Update all icons every frame
end

-- Hook the game start event to initialize icons for all players
local function onGameStart()
    print("[DEBUG] Game started, initializing player icons...")

    -- Add icons for all online players
    local onlinePlayers = getOnlinePlayers()
    for i = 0, onlinePlayers:size() - 1 do
        local player = onlinePlayers:get(i)
        if player then
            addPlayerIcon(player)
        else
            print("[DEBUG] No player found at index: " .. tostring(i))  -- Debugging print if no player is found at that index
        end
    end
end

-- Event hooks
Events.OnCreatePlayer.Add(onPlayerCreate)      -- Called when a player is created (multiplayer-friendly)
Events.OnRenderTick.Add(onUpdate)              -- Called every frame to update icons
Events.OnGameStart.Add(onGameStart)            -- Called when the game starts to initialize icons

-- Debugging message to confirm the mod is loaded
print("[DEBUG] Sword Icon UI mod loaded successfully!")
