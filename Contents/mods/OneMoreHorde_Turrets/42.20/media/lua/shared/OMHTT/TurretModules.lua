local Actors = require("OMHTT/DefenseActors")
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
---@return number degrees
---@nodiscard
function M.heading(state)
    return state.facingDegrees or (state.baseFacing or state.facing or 0) * 22.5
end

---@param state table Device state
---@param contents table Inventory summary
---@param automatic boolean? Apply automatic detection limits
---@return table profile
---@nodiscard
---@param resolved table? Already resolved operation stats
function M.profile(state, contents, automatic, resolved)
    local active = contents.active
    local stats = resolved or T.cycleConfig(contents)
    local key = stats.headKind or (stats.firearm and "Firearm" or "Potato")
    local legacy = M.option("ForwardCone", 90, 10, 360)
    local inherited = legacy
    if legacy < 360 then
        inherited = stats.cone or legacy
        if stats.rotary then
            inherited = 90
        end
    end
    local cone = M.option(key .. "ForwardCone", -1, -1, 360)
    if cone < 0 then
        cone = inherited
    end
    cone = math.max(10, cone)
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
    local range = stats.range
    if automatic and active.MotionDetectionImprovised then range = range * 0.75 end
    return {rotary = stats.rotary, stats = stats, heading = M.heading(state), cone = cone, omni = cone >= 360,
        range = stats.rotary and not automatic and stats.range or math.min(range, state.engagementRange or 100000), priority = priority}
end

---@param origin IsoGridSquare Turret tile
---@param zombie IsoZombie Candidate
---@param profile table Effective tuning
---@param x number? Validated contact X when already sampled
---@param y number? Validated contact Y when already sampled
---@return boolean inside
---@return number distanceSquared
---@nodiscard
function M.inside(origin, zombie, profile, x, y)
    local square = Actors.square(zombie)
    if zombie:isDead() or not square or square:getZ() ~= origin:getZ()
        or getCell():getGridSquare(square:getX(), square:getY(), square:getZ()) ~= square then return false, 0 end
    if x == nil or y == nil then x, y = Actors.position(zombie) end
    local dx, dy = x - origin:getX() - 0.5, y - origin:getY() - 0.5
    local distance = dx * dx + dy * dy
    if distance > profile.range * profile.range then return false, distance end
    if profile.stats and distance < (profile.stats.minimumRange or 0) ^ 2 then return false, distance end
    if distance < 0.000001 or profile.cone >= 360 then return true, distance end
    local heading = math.rad(profile.heading)
    local dot = (dx * math.cos(heading) - dy * math.sin(heading)) / math.sqrt(distance)
    if profile.rotary then dot = math.abs(dot) end
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
    if priority == "Weakest" and Health.current(candidate) ~= Health.current(best) then return Health.current(candidate) < Health.current(best) end
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
    if require("OMHTT/TurretHeads").get(contents.head) then enabled = true end
    if gun.profile(contents.head) then enabled = gun.enabled() end
    return enabled and T.enabled() and T.isOn(state)
        and contents.heads == 1 and contents.head:getCondition() > 0 and contents.active.MotionDetection ~= nil
end

return M
