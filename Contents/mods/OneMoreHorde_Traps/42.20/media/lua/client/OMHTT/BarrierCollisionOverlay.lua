if isClient() or isServer() then return end
require("ISUI/ISUIElement")
local F = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local Overlay = {}
local lines, nextScan = {}, 0
local canvas = nil
local nextReport = 0

---@return nil
function Overlay.update()
    local options = SandboxVars.OMHTurretsTraps
    if not options or not options.ShowCollision then
        if #lines > 0 then lines = {} end
        return
    end
    local now = getTimestampMs()
    if now < nextScan and nextScan - now < 500 then return end
    nextScan = now + 250
    lines = {}
    for index = 0, getNumActivePlayers() - 1 do
        local player = getSpecificPlayer(index)
        if player then
            local px, py, z = math.floor(player:getX()), math.floor(player:getY()), math.floor(player:getZ())
            for x = px - 8, px + 8 do
                for y = py - 8, py + 8 do
                    local square = getCell():getGridSquare(x, y, z)
                    if square then
                        local objects = square:getSpecialObjects()
                        for i = 0, objects:size() - 1 do
                            local object = objects:get(i)
                            local data = object:hasModData() and object:getModData()
                            local marker = data and (data.OMHTTTurret or data.OMHTTEdge or data.OMHTT)
                            if marker and (data.OMHTTTurret or data.OMHTTEdge or (marker.kind == "barrier" and not object:isCanPassThrough())) then
                                lines[#lines + 1] = {object = object, marker = marker, player = index, x = x, y = y, z = z}
                            end
                        end
                    end
                end
            end
        end
    end
end

---@param x number World X
---@param y number World Y
---@param z number Floor
---@param index number Local player index
---@return number screenX
---@return number screenY
---@nodiscard
local function screen(x, y, z, index)
    local zoom = getCore():getZoom(index)
    return (IsoUtils.XToScreen(x, y, z, 0) - IsoCamera.getOffX(index)) / zoom + getPlayerScreenLeft(index),
        (IsoUtils.YToScreen(x, y, z, 0) - IsoCamera.getOffY(index)) / zoom + getPlayerScreenTop(index)
end

---@param x number World X
---@param y number World Y
---@param tx number End X
---@param ty number End Y
---@param entry table Render entry
---@return nil
local function draw(x, y, tx, ty, entry)
    local sx, sy = screen(x, y, entry.z, entry.player)
    local ex, ey = screen(tx, ty, entry.z, entry.player)
    canvas:drawLine2(sx, sy, ex, ey, 1, 0.25, 0.85, 1)
    canvas:drawLine2(sx, sy + 1, ex, ey + 1, 1, 0.25, 0.85, 1)
end

---@return nil
function Overlay.render()
    if #lines == 0 then return end
    if not canvas then
        canvas = ISUIElement:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
        canvas:instantiate()
    end
    for i = 1, #lines do
        local entry = lines[i]
        if entry.object:getObjectIndex() >= 0 then
            local x, y = entry.x, entry.y
            if entry.object:isBlockAllTheSquare() then
                draw(x, y, x + 1, y, entry)
                draw(x + 1, y, x + 1, y + 1, entry)
                draw(x + 1, y + 1, x, y + 1, entry)
                draw(x, y + 1, x, y, entry)
            else
                local tx, ty = x, y + 1
                if entry.object:getNorth() then
                    tx, ty = x + 1, y
                end
                draw(x, y, tx, ty, entry)
                local nx, ny = F.barrierDirection(entry.marker.facing)
                if entry.marker.role then
                    nx, ny = entry.marker.nx, entry.marker.ny
                end
                local cx, cy = (x + tx) / 2, (y + ty) / 2
                draw(cx, cy, cx + nx * 0.35, cy + ny * 0.35, entry)
                draw(cx + nx * 0.35, cy + ny * 0.35, cx + nx * 0.22 - ny * 0.1, cy + ny * 0.22 + nx * 0.1, entry)
                draw(cx + nx * 0.35, cy + ny * 0.35, cx + nx * 0.22 + ny * 0.1, cy + ny * 0.22 - nx * 0.1, entry)
            end
        end
    end
    local now = getTimestampMs()
    if now >= nextReport or nextReport - now > 5000 then
        nextReport = now + 5000
        local entry = lines[1]
        local sx, sy = screen(entry.x, entry.y, entry.z, entry.player)
        Diagnostics.emit("barrier-overlay", {phase = "ui", parts = #lines, player = entry.player,
            x = entry.x, y = entry.y, z = entry.z, screenX = sx, screenY = sy,
            zoom = getCore():getZoom(entry.player), cameraX = IsoCamera.getOffX(entry.player),
            cameraY = IsoCamera.getOffY(entry.player)}, nil, nil, "traps")
    end
end

Events.OnTick.Add(Overlay.update)
Events.OnPostUIDraw.Add(Overlay.render)
return Overlay
