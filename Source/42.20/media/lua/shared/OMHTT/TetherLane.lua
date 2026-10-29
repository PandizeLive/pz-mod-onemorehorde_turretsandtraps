local C = require("OMHTT/TetherCycle")
local Actors = require("OMHTT/DefenseActors")
local W = {}

---@param state table Cycle
---@param from number Start distance
---@param destination number End distance
---@param cell IsoCell? Native world or fixture
---@return number? fraction
---@return IsoGameCharacter? victim
---@return string? reason
function W.cast(state, from, destination, cell)
    cell = cell or getCell()
    local ax, ay = state.x + state.dx * from, state.y + state.dy * from
    local bx, by = state.x + state.dx * destination, state.y + state.dy * destination
    local fraction, victim, reason = nil, nil, nil
    local steps = math.max(1, math.ceil((destination - from) / .05))
    local previous = cell:getGridSquare(math.floor(ax), math.floor(ay), state.z)
    if not previous then return 0, nil, "unloaded" end
    for i = 1, steps do
        local t = i / steps
        local x, y = math.floor(ax + (bx - ax) * t), math.floor(ay + (by - ay) * t)
        local square = cell:getGridSquare(x, y, state.z)
        if not square then
            fraction, reason = (i - 1) / steps, "unloaded"
            break
        end
        if square ~= previous then
            local vision = tostring(previous:testVisionAdjacent(x - previous:getX(), y - previous:getY(), 0, false, false))
            if (vision ~= "Clear" and vision ~= "ClearThroughOpenDoor") or previous:isWindowTo(square)
                or square:isSolid() or square:isSolidTrans() then
                fraction, reason = (i - 1) / steps, "wall"
                break
            end
        end
        previous = square
    end
    for x = math.floor(math.min(ax, bx) - .3), math.floor(math.max(ax, bx) + .3) do
        for y = math.floor(math.min(ay, by) - .3), math.floor(math.max(ay, by) + .3) do
            local square = cell:getGridSquare(x, y, state.z)
            if square then
                local objects = Actors.at(square)
                if objects:size() > 64 then return 0, nil, "density-limit" end
                for i = 0, objects:size() - 1 do
                    local actor = objects:get(i)
                    local zombie = instanceof(actor, "IsoZombie")
                    local player = instanceof(actor, "IsoPlayer")
                    local tangible = not player or not actor:isGodMod() and not actor:isNoClip() and not actor:isGhostMode()
                    if (zombie or player) and tangible and not actor:isDead() and not actor:isOnFloor()
                        and math.floor(actor:getZ()) == state.z then
                        local t = C.intersection(ax, ay, bx, by, actor:getX(), actor:getY(), .3)
                        if t and (not fraction or t < fraction) then
                            fraction, victim, reason = t, actor, player and "player" or "zombie"
                        end
                    end
                end
            end
        end
    end
    return fraction, victim, reason
end

---@param state table Cycle
---@param cell IsoCell? World or fixture
---@return IsoZombie? target
function W.detect(state, cell)
    local fraction, victim, reason = W.cast(state, 0, state.range, cell)
    if fraction and reason == "zombie" then return victim end
    return nil
end

return W
