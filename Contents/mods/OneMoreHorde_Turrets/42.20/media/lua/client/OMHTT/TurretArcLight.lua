if isServer() then return end
local Options = require("OMHTT/ControlOptions")
local L = {lights = {}, cursor = 1, due = 0}

---@return nil
function L.clear()
    for i = 1, #L.lights do
        local entry = L.lights[i]
        entry.cell:removeLamppost(entry.light)
    end
    L.lights, L.cursor = {}, 1
end

---@param x number World X
---@param y number World Y
---@param z number Floor
---@return nil
function L.flash(x, y, z)
    local now, cell = getTimestampMs(), getCell()
    if not cell or now < L.due or not Options.get("ArcLighting") then return end
    local strength = Options.get("ArcLightIntensity") / 100
    if strength <= 0 then return end
    local visible = false
    local square = cell:getGridSquare(math.floor(x), math.floor(y), z)
    if not square then return end
    for index = 0, getNumActivePlayers() - 1 do
        local player = getSpecificPlayer(index)
        if player and math.floor(player:getZ()) == z and square:isCanSee(index)
            and (player:getX() - x) ^ 2 + (player:getY() - y) ^ 2 < 2500 then
            visible = true
            break
        end
    end
    if not visible then return end
    L.due = now + 80
    local old = L.lights[L.cursor]
    if old then
        old.cell:removeLamppost(old.light)
    end
    local light = IsoLightSource.new(math.floor(x), math.floor(y), z, .25 * strength, .65 * strength, strength, 3)
    cell:addLamppost(light)
    L.lights[L.cursor] = {light = light, cell = cell, untilTime = now + 280, x = x, y = y, z = z}
    L.cursor = L.cursor % 4 + 1
end

---@return nil
function L.tick()
    if not Options.get("ArcLighting") or not getCell() then
        L.clear()
        return
    end
    local now = getTimestampMs()
    for i = 1, #L.lights do
        local entry = L.lights[i]
        local square = entry.cell:getGridSquare(math.floor(entry.x), math.floor(entry.y), entry.z)
        local strength = math.max(0, (entry.untilTime - now) / 280) * Options.get("ArcLightIntensity") / 100
        if not square then
            strength = 0
        end
        entry.light:setR(.25 * strength)
        entry.light:setG(.65 * strength)
        entry.light:setB(strength)
        entry.light:setActive(strength > 0)
    end
end

Events.OnTick.Add(L.tick)
Events.OnGameStart.Add(L.clear)
return L
