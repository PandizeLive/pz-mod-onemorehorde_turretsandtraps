if isClient() then return end
local V = require("OMHTT/TurretVolley")
local S = {}

---@param record table Committed device identity
---@param origin IsoGridSquare Muzzle square
---@param target IsoZombie Fixed aim
---@param player IsoPlayer? Operator
---@param options table Admitted root
---@return table facts Fire sound
function S.launch(record, origin, target, player, options)
    local x, y, stats = origin:getX() + .5, origin:getY() + .5, options.stats
    local angle = math.atan2(target:getY() - y, target:getX() - x)
    angle = angle + math.rad((ZombRand(20001) / 10000 - 1) * 10 / math.max(1, stats.accuracy / 100))
    options.scrapId = tostring(record.id) .. ":" .. tostring(record.shots)
    options.scrapEligibility, options.scrapEffects, options.scrapInjury, options.scrapPending = {}, {}, {}, {}
    for i = 1, 8 do
        local group = {options = options, kind = "scrapshot", stats = stats, hits = {}, player = player,
            left = 1 + stats.piercing, primary = true, rays = {}, remaining = 1}
        V.ray(record, x, y, origin:getZ(), angle + math.rad(-45 + (i - 1) * 90 / 7), stats.range,
            options.damage / 8 * (options.critical and options.critMultiplier or 1), group, i)
    end
    for i = 1, stats.splitter do
        local group = {options = options, kind = "scrapshot", stats = stats, hits = {}, player = player,
            left = 1 + stats.piercing, primary = false, rays = {}, remaining = 1}
        V.ray(record, x, y, origin:getZ(), angle + math.rad(V.angle(stats.splitter, i, record.splitterSide or -1)), stats.range,
            options.damage * .5 * (options.critical and options.critMultiplier or 1), group, i + 8)
    end
    if stats.splitter % 2 == 1 then
        record.splitterSide = -(record.splitterSide or -1)
    end
    V.miss(record, origin, target, player, options)
    V.release(options)
    return {id = record.id, shot = record.shots, x = x, y = y, z = origin:getZ(),
        fromX = x, fromY = y, firearm = true, sound = "JS2000ShotgunShoot", missed = true}
end

---@param ray table Current pellet
---@param victim IsoGameCharacter First unobstructed victim
---@return boolean hit
function S.hit(ray, victim)
    local group, owner = ray.group, ray.group.options
    local actorState = require("OMHTT/DefenseActorState").get(victim)
    local saved = actorState.OMHTTScrapShot
    if isServer() and owner.savedScrap then
        local key = tostring(victim:getOnlineID()) .. ":" .. tostring(instanceof(victim, "IsoZombie") and victim:getPersistentOutfitID() or "player")
        saved = owner.savedScrap[key] or saved
    end
    if saved and saved.id == owner.scrapId then
        owner.scrapEligibility[victim] = saved.eligibility
        owner.scrapEffects[victim] = saved.effects
        owner.scrapInjury[victim] = saved.injury
    end
    local mark = {id = owner.scrapId}
    actorState.OMHTTScrapShot = mark
    if instanceof(victim, "IsoPlayer") then
        local used = owner.scrapInjury[victim] or 0
        if used < 10 then
            require("OMHTT/DefenseInjury").blast(victim, math.min(2, 10 - used), used == 0 and .25 or 0)
            owner.scrapInjury[victim] = used + 2
            mark.injury = used + 2
        end
        return true
    end
    local eligible = (group.primary and not group.penetrated) or group.stats.synergy
    local eligibility = owner.scrapEligibility[victim]
    if not eligibility then
        eligibility = require("OMHTT/TurretConditionalHit").snapshot(victim, group.stats)
        owner.scrapEligibility[victim] = eligibility
    end
    local amount = ray.damage
    mark.eligibility, mark.effects = eligibility, owner.scrapEffects[victim]
    if eligible then
        amount = amount * eligibility.bonus
        local maximum = require("OMHTT/TargetHealth").maximum(victim)
        if group.stats.execute > 0 and victim:getHealth() - amount <= maximum * group.stats.execute then
            amount = victim:getHealth()
        end
    end
    local x, y, square = victim:getX(), victim:getY(), victim:getSquare()
    owner.scrapPending = owner.scrapPending or {}
    owner.scrapPending[victim] = true
    if owner.pending then owner.pending = owner.pending + 1 end
    return require("OMHTT/Damage").resolve(victim, amount, ray.id, "scrapshot", function(lost)
        if lost > 0 and eligible and not owner.scrapEffects[victim] then
            owner.scrapEffects[victim] = true
            mark.effects = true
            require("OMHTT/TurretProc").hit(victim, true, x, y, ray.z,
                {id = ray.id, shots = ray.shot}, group.player, owner)
            require("OMHTT/TurretConditionalHit").impact(victim, square, owner)
        end
        owner.scrapPending[victim] = nil
        if owner.pending then V.done(owner) end
    end)
end

return S
