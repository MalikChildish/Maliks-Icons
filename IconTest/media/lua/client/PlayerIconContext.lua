PlayerIconMenu = PlayerIconMenu or {}

-- Function to handle icon selection
function PlayerIconMenu.setIcon(player, iconType)
    local modData = player:getModData()

    -- Update the player's mod data with the selected icon type locally
    modData.iconType = iconType
    print("[DEBUG] Player " .. player:getUsername() .. " selected icon: " .. tostring(iconType))

    -- Send the selection to the server to sync with other players
    sendClientCommand(player, "PlayerIconSync", "SetIcon", { iconType = iconType })
end

-- Function to create the context menu for the player
function PlayerIconMenu.createMenu(player, context)
    local mainOption = context:addOption("Select Icon")
    local iconSubMenu = ISContextMenu:getNew(context)
    context:addSubMenu(mainOption, iconSubMenu)

    -- Add "Sword" option
    iconSubMenu:addOption("Sword", player, function()
        PlayerIconMenu.setIcon(player, "Sword")
    end)

    -- Add "Hammer" option
    iconSubMenu:addOption("Hammer", player, function()
        PlayerIconMenu.setIcon(player, "Hammer")
    end)

    -- Add "Off" option
    iconSubMenu:addOption("Off", player, function()
        PlayerIconMenu.setIcon(player, "Off")
    end)
end

-- Hook into the game's context menu event to show the options when right-clicking on the player
function PlayerIconMenu.onFillWorldObjectContextMenu(playerNum, context, worldobjects)
    local player = getSpecificPlayer(playerNum)
    if player then
        PlayerIconMenu.createMenu(player, context)
    end
end

Events.OnFillWorldObjectContextMenu.Add(PlayerIconMenu.onFillWorldObjectContextMenu)

-- Function to handle receiving the SyncIcon command from the server
local function OnServerSyncIcon(module, command, args)
    if module == "PlayerIconSync" and command == "SyncIcon" then
        -- Get the player by their online ID
        local player = getPlayerByOnlineID(args.playerID)
        if player then
            local modData = player:getModData()
            modData.iconType = args.iconType

            print("[CLIENT DEBUG] Updated icon for player " .. player:getUsername() .. " to " .. tostring(args.iconType))
        end
    end
end

-- Add the command handler for receiving updates from the server
Events.OnServerCommand.Add(OnServerSyncIcon)
