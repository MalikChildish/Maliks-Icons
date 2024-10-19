-- Handle the SetIcon command sent from clients
local function OnClientSetIcon(module, command, player, args)
    if module == "PlayerIconSync" and command == "SetIcon" then
        -- Update the player's ModData on the server
        local modData = player:getModData()
        modData.iconType = args.iconType

        print("[SERVER DEBUG] Received icon selection from " .. player:getUsername() .. ": " .. tostring(args.iconType))

        -- Now broadcast this to all players so they know which icon this player has selected
        sendServerCommand("PlayerIconSync", "SyncIcon", { playerID = player:getOnlineID(), iconType = args.iconType })
    end
end

-- Add the command handler to listen for client commands
Events.OnClientCommand.Add(OnClientSetIcon)
