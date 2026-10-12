local T = require("OMHTT/Turret")
local Health = require("OMHTT/TargetHealth")
local M = {}
M.CORE = T.MODULES
M.PRIORITIES = {"Closest", "Furthest", "Weakest", "Toughest", "OnceEach"}

---@param key string Full setting suffix
---@param fallback number Default
---@param minimum number Lower bound
---@param maximum number Upper bound
---@return number value
---@nodiscard
function M.option(key, fallback, minimum, maximum)
    local settings = SandboxVars.OMHTurretsTraps
    local value = settings and settings[key]
    if type(value) ~= "number" or value ~= value then return fallback end
    return math.max(minimum, math.min(maximum, value))
end

---@param state table Device state
---@param contents table Inventory summary
---@param automatic boolean? Apply automatic detection limits
---@return table profile
---@nodiscard
---@param resolved table? Already resolved operation stats
function M.profile(state, contents, automatic, resolved)
    local active = contents.active
    local cone = M.option("ForwardCone", 90, 10, 360)
    if active.Detection360 then
        cone = 360
    end
    local priority = "Random"
    if active.Filter then
        priority = "Closest"
        for i = 1, #M.PRIORITIES do
            if state.priority == M.PRIORITIES[i] then
                priority = state.priority
            end
        end
    end
    local stats = resolved or T.cycleConfig(contents)
    local range = stats.range
    if automatic and active.MotionDetectionImprovised then range = range * 0.75 end
    return {stats = stats, heading = (state.baseFacing or state.facing or 0) * 22.5, cone = cone, omni = active.Detection360 ~= nil,
        range = math.min(range, state.engagementRange or 100000), priority = priority}
end

---@param origin IsoGridSquare Turret tile
---@param zombie IsoZombie Candidate
---@param profile table Effective tuning
---@return boolean inside
---@return number distanceSquared
---@nodiscard
function M.inside(origin, zombie, profile)
    local square = zombie:getSquare()
    if zombie:isDead() or not square or square:getZ() ~= origin:getZ()
        or getCell():getGridSquare(square:getX(), square:getY(), square:getZ()) ~= square then return false, 0 end
    local dx, dy = zombie:getX() - origin:getX() - 0.5, zombie:getY() - origin:getY() - 0.5
    local distance = dx * dx + dy * dy
    if distance > profile.range * profile.range then return false, distance end
    if distance < 0.000001 or profile.cone >= 360 then return true, distance end
    local heading = math.rad(profile.heading)
    local dot = (dx * math.cos(heading) - dy * math.sin(heading)) / math.sqrt(distance)
    return dot + 0.0000001 >= math.cos(math.rad(profile.cone / 2)), distance
end

---@param candidate IsoZombie New candidate
---@param distance number Candidate squared distance
---@param best IsoZombie? Current candidate
---@param bestDistance number Current squared distance
---@param priority string Ranking
---@return boolean better
---@nodiscard
function M.better(candidate, distance, best, bestDistance, priority)
    if not best then return true end
    if priority == "Weakest" and candidate:getHealth() ~= best:getHealth() then return candidate:getHealth() < best:getHealth() end
    if priority == "Toughest" and Health.maximum(candidate) ~= Health.maximum(best) then return Health.maximum(candidate) > Health.maximum(best) end
    if priority == "Furthest" then return distance > bestDistance end
    return distance < bestDistance
end

---@param state table Persisted controls
---@param contents table Inventory summary
---@return boolean enabled
---@nodiscard
function M.detects(state, contents)
    local gun = require("OMHTT/Firearms")
    local enabled = SandboxVars.OMHTurretsTraps.PotatoTurret ~= false
    if gun.profile(contents.head) then enabled = gun.enabled() end
    return enabled and T.enabled() and SandboxVars.OMHTurretsTraps.AutomationEnabled ~= false and T.isOn(state)
        and contents.heads == 1 and contents.head:getCondition() > 0 and contents.active.MotionDetection ~= nil
end

return M
