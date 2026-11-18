if isClient() then return end
local V = require("OMHTT/TurretVolley")
local Clock = require("OMHTT/TurretClock")
local B = {}

---@param record table Authoritative turret state
---@param object IsoObject Exact turret
---@param player IsoPlayer? Manual operator
---@param options table Validated resource transaction
---@return string result
---@return table? facts
function B.fire(record, object, player, options)
    local stats, origin = options.stats, object:getSquare()
    local x, y = origin:getX() + .5, origin:getY() + .5
    local heading = require("OMHTT/TurretModules").heading(record)
    local angle = -math.rad(heading)
    local distance = options.range
    if stats.headKind == "Lobber" then
        distance = math.max(stats.minimumRange, math.min(stats.range, record.landingRange or stats.range))
    end
    options.aimX, options.aimY = x + math.cos(angle) * distance, y + math.sin(angle) * distance
    if not V.reserve(options) then return "Unavailable" end
    if not options.commit() then
        V.cancel(options)
        return options.failure or "Unavailable"
    end
    options.critical = ZombRand(10000) < options.critChance * 100
    options.effectWeapon = options.weapon
    record.aimDegrees = heading
    record.facing = require("OMHTT/Foundation").normalizeFacing(math.floor(heading / 22.5 + .5))
    record.ammo = record.ammo - options.ammoCost
    record.shots = record.shots + 1
    record.nextShot = Clock.now() + options.interval
    if stats.headKind == "Arc" then
        return "Fired", require("OMHTT/TurretArc").launch(record, origin, nil, player, options)
    end
    if stats.headKind == "Lobber" or stats.headKind == "Scrapshot" then
        return "Fired", require("OMHTT/TurretOrdnance").launch(record, origin, nil, player, options)
    end
    local group = {options = options, kind = "forward", primary = true, player = player, weapon = options.weapon,
        stats = stats, hits = {}, left = 1 + stats.piercing}
    V.ray(record, x, y, origin:getZ(), angle, options.range,
        options.damage * (options.critical and options.critMultiplier or 1), group, 1)
    local ray = V.queue[#V.queue]
    local facts = {id = record.id, shot = record.shots, fromX = x, fromY = y, z = origin:getZ(),
        x = options.aimX, y = options.aimY, firearm = stats.firearm, missed = true}
    if stats.firearm then
        local gun = options.weapon
        facts.sound, facts.deferVisual = gun:getSwingSound(), true
        local wear = gun:getConditionLowerChance()
        if wear > 0 and ZombRand(wear) == 0 then gun:setCondition(math.max(0, gun:getCondition() - 1)) end
        require("OMHTT/DefenseHorde").sound(object, origin:getX(), origin:getY(), origin:getZ(),
            require("OMHTT/TurretStats").hearingRadius(gun, stats), gun:getSoundVolume())
    else
        ray.speed, ray.flightStart = options.projectileSpeed, Clock.now()
        facts.shot = ray.shot
        facts.start, facts.flight = ray.flightStart, options.range / ray.speed * 1000
        local family, speed, ammoType = require("OMHTT/TurretProjectileStyle").describe(stats, options)
        facts.projectile, facts.ammoType = family, ammoType
        ray.projectile, ray.ammoType = family, ammoType
        facts.sound = options.projectile == "spear" and "SpearCraftedSwing" or nil
    end
    V.release(options)
    return "Fired", facts
end

return B
