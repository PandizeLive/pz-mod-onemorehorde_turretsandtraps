if isServer() then return end
local F = require("OMHTT/Foundation")
local Clock = require("OMHTT/TurretClock")
local markers, due = {}, 0

---@param module string Server presentation namespace
---@param command string Effect type
---@param facts table Committed sound facts
---@return nil
local function receive(module, command, facts)
    if module ~= F.MODULE or command ~= "Click" or facts.sound ~= "OMHTTLure" then return end
    if type(facts.lureRange) ~= "number" or facts.lureRange < 5 or facts.lureRange > 20 then return end
    if #markers >= 32 then return end
    local square = getCell():getGridSquare(math.floor(facts.x), math.floor(facts.y), facts.z)
    if not square then return end
    local visible = false
    for i = 0, getNumActivePlayers() - 1 do
        local player = getSpecificPlayer(i)
        if player and math.floor(player:getZ()) == facts.z and square:isCanSee(i) then visible = true end
    end
    if not visible then return end
    local marker = getWorldMarkers():addGridSquareMarker(square, .4, .75, 1, false, facts.lureRange * 2)
    marker:setScaleCircleTexture(true)
    markers[#markers + 1] = {marker = marker, expires = Clock.now() + 1000}
end

---@return nil
local function update()
    local now = Clock.now()
    if now < due then return end
    due = now + 100
    for i = #markers, 1, -1 do
        if now >= markers[i].expires then
            markers[i].marker:remove()
            table.remove(markers, i)
        end
    end
end

Events.OnServerCommand.Add(receive)
Events.OnTick.Add(update)
