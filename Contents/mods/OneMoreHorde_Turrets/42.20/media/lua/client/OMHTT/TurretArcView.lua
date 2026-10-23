if isServer() then return end
local F = require("OMHTT/Foundation")
local Effects = require("OMHTT/DefenseEffects")
local Draw = require("OMHTT/ControlModelDraw")
local Clock = require("OMHTT/TurretClock")
local V = {bursts = {}, cursor = 1}

---@param module string Namespace
---@param command string Event
---@param facts table Authoritative endpoints
function V.receive(module, command, facts)
    if module ~= F.MODULE or command ~= "Arc" or type(facts) ~= "table" then return end
    for _, key in pairs({"fromX", "fromY", "x", "y", "z"}) do
        if type(facts[key]) ~= "number" or facts[key] ~= facts[key] or math.abs(facts[key]) == math.huge then return end
    end
    local dx, dy = facts.x - facts.fromX, facts.y - facts.fromY
    local length = math.sqrt(dx * dx + dy * dy)
    if length < .01 or length > 70 or not Effects.accept(facts) then return end
    local count = math.min(32, math.max(3, math.ceil(length / .3)))
    local burst = {untilTime = Clock.now() + 330, segments = {}, z = facts.z}
    local px, py, pz = facts.fromX, facts.fromY, .3
    for i = 1, count do
        local t = i / count
        local wave = i < count and math.sin(i * 13.71 + facts.x * 7.3) * .14 or 0
        local x, y = facts.fromX + dx * t - dy / length * wave, facts.fromY + dy * t + dx / length * wave
        local z = .3 + (i < count and math.cos(i * 11.3 + facts.y) * .04 or 0)
        local sx, sy, sz = x - px, y - py, (z - pz) * 2.44949
        local horizontal = math.sqrt(sx * sx + sy * sy)
        burst.segments[i] = {x = (px + x) / 2, y = (py + y) / 2, z = (pz + z) / 2,
            yaw = math.deg(math.atan2(sy, sx)), tilt = math.deg(math.atan2(sz, horizontal)),
            scale = math.sqrt(horizontal * horizontal + sz * sz) / .3}
        px, py, pz = x, y, z
    end
    V.bursts[V.cursor] = burst
    V.cursor = V.cursor % 64 + 1
end

---@param index number Native viewport
function V.render(index)
    local player, cell = getSpecificPlayer(index), getCell()
    if not player or not cell then return end
    local now, budget = Clock.now(), 192
    for id, burst in pairs(V.bursts) do
        if now >= burst.untilTime then
            V.bursts[id] = nil
        elseif math.floor(player:getZ()) == burst.z then
            local alpha = math.min(1, (burst.untilTime - now) / 250)
            alpha = alpha * alpha
            for i = 1, #burst.segments do
                if budget <= 0 then return end
                local segment = burst.segments[i]
                if (player:getX() - segment.x) ^ 2 + (player:getY() - segment.y) ^ 2 < 2500 then
                    local tile = cell:getGridSquare(math.floor(segment.x), math.floor(segment.y), burst.z)
                    if tile and tile:isCanSee(index) then
                        V.model = V.model or instanceItem("Base.OMHTTTurretArcVisual")
                        V.model:setWorldScale(segment.scale)
                        V.model:setWorldAlpha(alpha)
                        Draw.draw(V.model, tile, segment.x, segment.y, burst.z + segment.z, 0, segment.tilt, segment.yaw)
                        budget = budget - 1
                    end
                end
            end
        end
    end
end

Events.OnServerCommand.Add(V.receive)
Events.RenderOpaqueObjectsInWorld.Add(V.render)
Events.OnGameStart.Add(function() V.bursts, V.cursor = {}, 1 end)
return V
