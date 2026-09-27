if isServer() then return end

local Foundation = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local markers = {}
local cardinal = {"E", "N", "W", "S"}

---@param module string Command namespace
---@param command string Command category
---@param result table Authoritative device state
---@return nil
local function onResult(module, command, result)
    if module ~= Foundation.MODULE or command ~= "Result" or not result.stateIncluded then return end
    local player = getSpecificPlayer(result.playerNum)
    if not Foundation.canUse(player) then return end
    for i = #markers, 1, -1 do
        local marker = markers[i]
        if marker.playerNum == result.playerNum and marker.x == result.x and marker.y == result.y and marker.z == result.z then
            table.remove(markers, i)
        end
    end
    if result.id == "" or result.count ~= 1 then return end
    local heading = cardinal[math.floor((result.facing + 2) / 4) % 4 + 1]
    local label = getText("UI_OMHTT_MarkerTest", result.id)
    if result.kind == "barrier" then
        label = getText("UI_OMHTT_MarkerBarrier", result.id, heading)
    elseif result.kind == "potato" then
        label = getText("UI_OMHTT_MarkerPotato", result.id, result.ammo)
    end
    if #markers >= 8 then table.remove(markers, 1) end
    markers[#markers + 1] = {
        id = result.id, kind = result.kind, x = result.x, y = result.y, z = result.z,
        playerNum = result.playerNum, label = label, start = getTimestampMs(), nextCheck = getTimestampMs() + 100,
        ready = false, finished = false,
    }
    Diagnostics.emit("marker-queued", {id = result.id, label = label, x = result.x, y = result.y, z = result.z})
end

---@return nil
local function update()
    local now = getTimestampMs()
    local checked = 0
    for i = #markers, 1, -1 do
        local marker = markers[i]
        if now - marker.start >= 6000 then
            table.remove(markers, i)
        elseif not marker.finished and now >= marker.nextCheck and checked < 2 then
            checked = checked + 1
            marker.nextCheck = now + 250
            local square = getCell():getGridSquare(marker.x, marker.y, marker.z)
            if square then
                local object, count = Foundation.find(square, marker.id)
                if count == 1 then
                    local sprite = object:getSprite()
                    local texture = sprite and sprite:getTextureForCurrentFrame(IsoDirections.N)
                    marker.ready = texture ~= nil and texture:isReady()
                    if marker.ready then
                        object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_REDRAW)
                        marker.finished = true
                        Diagnostics.emit("marker-texture-ready", {id = marker.id, elapsedMs = now - marker.start,
                            sprite = tostring(object:getSpriteName())})
                    end
                end
            end
            if not marker.finished and now - marker.start >= 3000 then
                marker.finished = true
                Diagnostics.emit("marker-texture-timeout", {id = marker.id, elapsedMs = now - marker.start})
            end
        end
    end
end

---@return nil
local function render()
    for i = 1, #markers do
        local marker = markers[i]
        local player = getSpecificPlayer(marker.playerNum)
        if Foundation.canUse(player) and math.floor(player:getZ()) == marker.z then
            local zoom = getCore():getZoom(marker.playerNum)
            local x = (IsoUtils.XToScreen(marker.x + 0.5, marker.y + 0.5, marker.z, 0) - IsoCamera.getOffX(marker.playerNum)) / zoom
            local y = (IsoUtils.YToScreen(marker.x + 0.5, marker.y + 0.5, marker.z, 0) - IsoCamera.getOffY(marker.playerNum)) / zoom
            local lift = 52
            if marker.kind == "potato" then
                lift = 180
            end
            local labelY = y - lift / zoom
            getTextManager():DrawStringCentre(UIFont.Small, x + 1, labelY + 1, marker.label, 0, 0, 0, 1)
            getTextManager():DrawStringCentre(UIFont.Small, x, labelY, marker.label, 1, 1, 1, 1)
            getTextManager():DrawStringCentre(UIFont.Small, x, y, "+", 1, 1, 1, 1)
        end
    end
end

---@return nil
local function reset()
    markers = {}
end

Events.OnServerCommand.Add(onResult)
Events.OnTick.Add(update)
Events.OnPostUIDraw.Add(render)
Events.OnGameStart.Add(reset)
