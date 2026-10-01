if isClient() or isServer() then return end
local G = require("OMHTT/Firearms")
local Damage = require("OMHTT/Damage")
local D = require("OMHTT/Diagnostics")
local Modules = require("OMHTT/TurretModules")
local C = {}

---@param record table Turret state
---@param origin IsoGridSquare Muzzle square
---@param target IsoZombie Selected victim
---@param player IsoPlayer? Operator
---@param options table Shot snapshot
---@return table facts Sound and tracer facts
function C.hit(record, origin, target, player, options)
    local started = getTimestampMs()
    local gun, stats = options.weapon, options.stats
    local Combat = require("OMHTT/PrototypeCombat")
    local targets = {target}
    local pellets = math.max(1, math.min(9, gun:getProjectileCount()))
    if pellets > 1 then
        local candidates = Combat.candidates(target:getSquare(), 2)
        for i = 1, #candidates do
            if #targets >= 3 then break end
            local zombie = candidates[i].zombie
            local dx, dy = zombie:getX() - target:getX(), zombie:getY() - target:getY()
            if zombie ~= target and dx * dx + dy * dy <= 1.44
                and Modules.inside(origin, zombie, options.profile)
                and Combat.clearLane(origin, zombie:getSquare(), stats.range) then
                targets[#targets + 1] = zombie
            end
        end
    end
    local hits, lost = 0, 0
    for i = 1, pellets do
        local victim = targets[(i - 1) % #targets + 1]
        if not victim:isDead() and ZombRand(10000) < stats.accuracy * 100 then
            lost = lost + Damage.apply(victim, stats.damage / 100 / pellets, record.id, "firearm", player, gun)
            hits = hits + 1
            local guard = victim:getModData().OMHTTKnockdownUntilMs
            if not victim:isDead() and not victim:isOnFloor() and not victim:isKnockedDown()
                and (not guard or guard < started) and ZombRand(100) < stats.knockdown then
                victim:knockDown(false)
                victim:getModData().OMHTTKnockdownUntilMs = started + Combat.KNOCKDOWN_GUARD_MS
            end
        end
    end
    local wear = gun:getConditionLowerChance()
    if wear > 0 and ZombRand(wear) == 0 then gun:setCondition(math.max(0, gun:getCondition() - 1)) end
    addSound(options.object, origin:getX(), origin:getY(), origin:getZ(), gun:getSoundRadius(), gun:getSoundVolume())
    D.defer("firearm-shot", {id = record.id, gun = gun:getFullType(), shot = record.shots,
        pellets = pellets, hits = hits, damage = lost * 100, condition = gun:getCondition(),
        magazine = gun:getCurrentAmmoCount(), chamber = gun:isRoundChambered(), ms = getTimestampMs() - started})
    return {id = record.id, shot = record.shots, x = target:getX(), y = target:getY(), z = origin:getZ(),
        fromX = origin:getX() + 0.5, fromY = origin:getY() + 0.5, sound = gun:getSwingSound(),
        muzzle = G.profile(gun).muzzle * 1.5, muzzleHeight = require("OMHTT/Turret").HEAD_VISUAL.height + 0.1, firearm = true, missed = hits == 0}
end

return C
