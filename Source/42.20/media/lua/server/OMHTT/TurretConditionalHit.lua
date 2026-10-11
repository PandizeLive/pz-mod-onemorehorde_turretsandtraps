if isClient() or isServer() then return end
local Health = require("OMHTT/TargetHealth")
local Clock = require("OMHTT/TurretClock")
local C = {}

---@param zombie IsoZombie Primary victim before the shot damages it
---@param stats table Effective modules
---@return table eligibility Fixed health classification for the entire shot
---@nodiscard
function C.snapshot(zombie, stats)
    if stats.initialBlow == 0 and stats.execute == 0 then return {bonus = 1, execute = false} end
    local maximum = Health.maximum(zombie)
    if maximum <= 0 then return {bonus = 1, execute = false} end
    local fraction = zombie:getHealth() / maximum
    return {bonus = fraction >= stats.initialThreshold and 1 + stats.initialBlow or 1,
        execute = stats.execute > 0 and fraction <= stats.execute}
end

---@param zombie IsoZombie Successful primary victim
---@param damage number Ordinary allocated primary damage
---@param eligibility table Pre-hit health classification
---@return number damage Conditional damage or actual remaining health
---@nodiscard
function C.damage(zombie, damage, eligibility)
    if eligibility.execute then return zombie:getHealth() end
    return damage * eligibility.bonus
end

---@param zombie IsoZombie Surviving primary victim
---@param origin IsoGridSquare Muzzle position
---@param options table Committed shot and magazine entitlement
---@return boolean staggered Native standing reaction requested
function C.impact(zombie, origin, options)
    if not options.impactReady or not options.stats or options.stats.impact <= 0 then return false end
    options.impactReady = false
    local state = string.lower(zombie:getCurrentStateName())
    if zombie:isDead() or zombie:isProne() or zombie:isKnockedDown() or zombie:isStaggerBack()
        or string.find(state, "getup", 1, true) or string.find(state, "stagger", 1, true) or zombie:isBumpFall() then return false end
    local data, now = zombie:getModData(), Clock.now()
    if not data.OMHTTImpactGuard then data.OMHTTImpactGuard = {} end
    local guard = data.OMHTTImpactGuard
    Clock.restore(guard, now)
    if guard.nextShot and now < guard.nextShot then return false end
    if ZombRand(10000) >= options.stats.impact * 100 then return false end
    local dx, dy = zombie:getX() - origin:getX() - .5, zombie:getY() - origin:getY() - .5
    local length = math.sqrt(dx * dx + dy * dy)
    if length > 0 then zombie:setHitDir(Vector2.new(dx / length, dy / length)) end
    zombie:setHitForce(.1)
    zombie:setStaggerBack(true)
    guard.nextShot = now + 5000
    return true
end

return C
