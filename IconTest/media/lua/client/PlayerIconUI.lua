require "ISUI/ISUIElement"

-- PlayerIconUI class definition
PlayerIconUI = ISUIElement:derive("PlayerIconUI")

-- Constructor for the UI element
function PlayerIconUI:new(player)
    local o = ISUIElement:new(0, 0, 32, 32)  -- Icon size (32x32)
    setmetatable(o, self)
    self.__index = self
    o.player = player
    o.baseSize = { width = 32, height = 32 }  -- Base icon size (32x32)
    return o
end

-- Function to update the UI element position and rendering logic
function PlayerIconUI:update()
    if self.player and self.player:isAlive() then
        local modData = self.player:getModData()

        -- Determine which icon to use based on the player's mod data
        if modData.iconType == "Sword" then
            self.iconTexture = getTexture("media/textures/Sword.png")
            print("[DEBUG] Player " .. tostring(self.player:getUsername()) .. " has selected the Sword icon.")
        elseif modData.iconType == "Hammer" then
            self.iconTexture = getTexture("media/textures/Hammer.png")
            print("[DEBUG] Player " .. tostring(self.player:getUsername()) .. " has selected the Hammer icon.")
        else
            self.iconTexture = nil  -- No icon if "Off" is selected
            print("[DEBUG] Player " .. tostring(self.player:getUsername()) .. " has turned the icon off.")
        end

        -- If there's no icon selected, hide the icon
        if not self.iconTexture then
            self:setVisible(false)
            return
        end

        -- Get player's world position
        local playerX, playerY, playerZ = self.player:getX(), self.player:getY(), self.player:getZ()

        -- Get the zoom level and calculate inverse zoom for scaling
        local zoomFactor = getCore():getZoom(0)
        local inverseZoom = 1 / zoomFactor

        -- Convert player's world position to screen coordinates
        local screenX = (IsoUtils.XToScreen(playerX, playerY, playerZ, 0) - IsoCamera.getOffX() - self.player:getOffsetX()) / zoomFactor
        local screenY = (IsoUtils.YToScreen(playerX, playerY, playerZ, 0) - IsoCamera.getOffY() - self.player:getOffsetY()) / zoomFactor

        -- Define offsets for the icon position relative to the player
        local offsetX = 40 / zoomFactor
        local offsetY = 170 / zoomFactor

        -- Set the UI element's position, adjusting for zoom and offsets
        self:setX(screenX - self.width / 2 + offsetX)
        self:setY(screenY - offsetY)

        -- Scale the icon size based on zoom
        local scaledWidth = self.baseSize.width * inverseZoom
        local scaledHeight = self.baseSize.height * inverseZoom

        -- Update the width and height based on zoom
        self:setWidth(scaledWidth)
        self:setHeight(scaledHeight)

        -- Make the icon visible
        self:setVisible(true)
    else
        -- Hide the icon if the player is dead
        self:setVisible(false)
    end
end

-- Function to render the icon
function PlayerIconUI:render()
    if self.iconTexture then
        -- Draw the icon texture at the element's position
        self:drawTextureScaled(self.iconTexture, 0, 0, self.width, self.height, 1)
    end
end

-- Create and manage PlayerIconUI for each player
local playerIcons = {}  -- Store PlayerIconUI instances for each player

-- Function to add the UI element for a player
function addPlayerIconUI(player)
    if not playerIcons[player] then
        local iconUI = PlayerIconUI:new(player)
        iconUI:initialise()
        iconUI:addToUIManager()
        playerIcons[player] = iconUI
        print("[DEBUG] Added icon UI for player: " .. tostring(player:getUsername()))
    end
end

-- Function to remove PlayerIconUI for a player
function removePlayerIconUI(player)
    if playerIcons[player] then
        playerIcons[player]:removeFromUIManager()
        playerIcons[player] = nil
        print("[DEBUG] Removed icon UI for player: " .. tostring(player:getUsername()))
    end
end

-- Function to update all player icons
function updateAllPlayerIcons()
    -- Loop through all active players (including local and remote players in multiplayer)
    for i = 0, getNumActivePlayers() - 1 do
        local player = getSpecificPlayer(i)
        if player then
            -- Add an icon if not already present
            addPlayerIconUI(player)
        end
    end

    -- Clean up icons for players no longer present
    for player, iconUI in pairs(playerIcons) do
        if not player or not player:isAlive() then
            removePlayerIconUI(player)
        end
    end
end

-- Hook into the game's render event to update the icon above each player's head
Events.OnRenderTick.Add(function()
    updateAllPlayerIcons()  -- Update the icons for all players
    for _, iconUI in pairs(playerIcons) do
        iconUI:update()  -- Update each player's icon
    end
end)
