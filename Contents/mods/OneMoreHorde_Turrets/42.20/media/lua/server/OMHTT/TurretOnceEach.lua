local M = require("OMHTT/TurretModules")
local CombatPolicy = require("OMHTT/ControlCombat")
local R = {}

---@param round table Round snapshot
---@param origin IsoGridSquare Turret position
---@param profile table Current eligibility
---@param heading number Current aim degrees
---@param deadline number Shared scheduler deadline
---@return boolean complete Selection finished
---@return IsoZombie? target Next eligible primary
function R.select(round, origin, profile, heading, deadline)
    local Combat = require("OMHTT/PrototypeCombat")
    local index = round.index or 1
    for _ = 1, 32 do
        if getTimestampMs() >= deadline then return false end
        if index > #round.members then
            local best = round.best
            round.index, round.best, round.angle, round.distance = nil, nil, nil, nil
            return true, best
        end
        local zombie = round.members[index]
        if not round.used[zombie] then
            local inside, distance = M.inside(origin, zombie, profile)
            if inside and CombatPolicy.eligible(profile.object, zombie) and Combat.clearLane(origin, zombie:getSquare(), profile.range) then
                local angle = math.deg(math.atan2(-(zombie:getY() - origin:getY() - .5), zombie:getX() - origin:getX() - .5))
                local turn = math.abs((angle - heading + 180) % 360 - 180)
                if not round.started then turn = 0 end
                if not round.best or turn < round.angle or turn == round.angle and distance < round.distance then
                    round.best, round.angle, round.distance = zombie, turn, distance
                end
            else
                round.used[zombie] = true
            end
        end
        index = index + 1
        round.index = index
    end
    return false
end

return R
