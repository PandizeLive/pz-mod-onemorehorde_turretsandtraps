if isClient() then return end
local Actors = require("OMHTT/DefenseActors")
local Horde = require("OMHTT/DefenseHorde")
local G = require("OMHTT/Firearms")
local Accuracy = require("OMHTT/FirearmAccuracy")
local Damage = require("OMHTT/Damage")
local D = require("OMHTT/Diagnostics")
local Modules = require("OMHTT/TurretModules")
local Conditional = require("OMHTT/TurretConditionalHit")
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
        local candidates = Combat.candidates(Actors.square(target), 2)
        for i = 1, #candidates do
            if #targets >= 3 then break end
            local zombie = candidates[i].zombie
            local dx, dy = zombie:getX() - target:getX(), zombie:getY() - target:getY()
            if zombie ~= target and dx * dx + dy * dy <= 1.44
                and Modules.inside(origin, zombie, options.profile)
                and Combat.clearLane(origin, Actors.square(zombie), stats.range) then
                targets[#targets + 1] = zombie
            end
        end
    end
    local hits, lost = 0, 0
    local critical = options.critical
    if critical == nil then critical = ZombRand(10000) < stats.critChance * 100 end
    local multiplier = critical and stats.critMultiplier or 1
    local dx, dy = target:getX() - origin:getX() - .5, target:getY() - origin:getY() - .5
    local aimHit = ZombRand(10000) < Accuracy.chance(gun, stats, math.sqrt(dx * dx + dy * dy), target:isProne()) * 100
    local firstHit
    local eligibility = {}
    for i = 1, #targets do
        if instanceof(targets[i], "IsoZombie") then
            eligibility[targets[i]] = Conditional.snapshot(targets[i], stats)
        end
    end
    for i = 1, #targets do
        local victim = targets[i]
        local allocated = math.floor((pellets - i) / #targets) + 1
        if allocated > 0 and aimHit and not victim:isDead() and require("OMHTT/ControlCombat").eligible(options.object, victim) then
            local hitX, hitY, hitSquare = victim:getX(), victim:getY(), Actors.square(victim)
            local admitted
            if instanceof(victim, "IsoPlayer") then
                admitted = require("OMHTT/TurretPlayerHit").hit(victim, options, pellets > 1 and "Shotgun" or "Firearm", allocated / pellets)
            else
                local amount = Conditional.damage(victim, stats.damage * multiplier / 100 / pellets * allocated, eligibility[victim])
                admitted = require("OMHTT/TurretHit").resolve(victim, amount, record.id, "firearm", options, function(actual)
                    lost = lost + actual
                    require("OMHTT/TurretProc").hit(victim, true, hitX, hitY, origin:getZ(), record, player, options)
                    local guard = require("OMHTT/DefenseActorState").get(victim).OMHTTKnockdownUntilMs
                    local chance = 1 - (1 - stats.knockdown / 100) ^ allocated
                    if not victim:isDead() and not victim:isOnFloor() and not victim:isKnockedDown()
                        and (not guard or guard < getTimestampMs()) and ZombRand(10000) < chance * 10000 then
                        if require("OMHTT/DefenseMotion").request(victim, "knock", record.id) then
                            require("OMHTT/DefenseActorState").get(victim).OMHTTKnockdownUntilMs = require("OMHTT/ControlClock").now() + Combat.KNOCKDOWN_GUARD_MS
                        end
                    end
                    Conditional.impact(victim, origin, options)
                end)
            end
            if admitted then
                if not firstHit then firstHit = {victim = victim, x = hitX, y = hitY, square = hitSquare} end
                hits = hits + allocated
            end
        end
    end
    local Volley = require("OMHTT/TurretVolley")
    if firstHit then
        if not Volley.pierce(record, origin, firstHit.victim, player, options, firstHit.square, firstHit.x, firstHit.y) then
            Volley.fragment(record, firstHit.x, firstHit.y, origin:getZ(), firstHit.victim, player, options)
        end
    else
        Volley.miss(record, origin, target, player, options)
    end
    Volley.release(options)
    local wear = gun:getConditionLowerChance()
    if wear > 0 and ZombRand(wear) == 0 then gun:setCondition(math.max(0, gun:getCondition() - 1)) end
    local hearingRadius = require("OMHTT/TurretStats").hearingRadius(gun, stats)
    Horde.sound(options.object, origin:getX(), origin:getY(), origin:getZ(), hearingRadius, gun:getSoundVolume())
    D.defer("firearm-shot", {id = record.id, gun = gun:getFullType(), shot = record.shots,
        critical = critical, critChance = stats.critChance, critMultiplier = multiplier, hearingRadius = hearingRadius, suppressed = stats.suppressed, pellets = pellets, hits = hits, damage = lost * 100, condition = gun:getCondition(),
        magazine = gun:getCurrentAmmoCount(), chamber = gun:isRoundChambered(), ms = getTimestampMs() - started}, "turrets")
    return {id = record.id, shot = record.shots, x = target:getX(), y = target:getY(), z = origin:getZ(),
        fromX = origin:getX() + 0.5, fromY = origin:getY() + 0.5, sound = gun:getSwingSound(),
        muzzle = G.profile(gun).muzzle * 1.5, muzzleHeight = require("OMHTT/Turret").HEAD_VISUAL.height + 0.1, firearm = true, missed = hits == 0}
end

return C
