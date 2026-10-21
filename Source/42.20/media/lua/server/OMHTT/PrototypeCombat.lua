local Horde = require("OMHTT/DefenseHorde")
local Budget = require("OMHTT/TurretScheduler")
local Clock = require("OMHTT/TurretClock")
if isClient() then return end

local Foundation = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local Damage = require("OMHTT/Damage")
local Modules = require("OMHTT/TurretModules")
local Conditional = require("OMHTT/TurretConditionalHit")

---@class OMHTTPrototypeCombat
local Combat = {
    RANGE = 6,
    CANDIDATE_LIMIT = 64,
    SHOT_INTERVAL_MS = 1000,
    KNOCKDOWN_GUARD_MS = 3000,
    KNOCKDOWN_CHANCE = 40,
    DIRECT_DAMAGE = 0.50,
    SPLASH_DAMAGE = 0.001,
    SPLASH_LIMIT = 3,
}
local weapon = nil

local observations = {}
Combat.pending, Combat.cursor = {}, 1

---@return nil
function Combat.observeImpacts()
    if isClient() or isServer() then return end
    if not Diagnostics.enabled("turrets") or SandboxVars.OMHTurretsTraps.TurretDetailedLogging ~= true then
        if #observations > 0 then observations = {} end
        return
    end
    if #observations == 0 then return end
    local now = getTimestampMs()
    local deadline = Budget.limit(1)
    for i = #observations, math.max(1, #observations - 3), -1 do
        if getTimestampMs() >= deadline then break end
        local entry = observations[i]
        if now >= entry.checkAt then
            local zombie = entry.zombie
            Diagnostics.emit("shot-reaction-observed", {id = entry.id, shot = entry.shot,
                elapsedMs = now - entry.started, state = zombie:getCurrentStateName(),
                loaded = zombie:getSquare() ~= nil, dead = zombie:isDead(), onFloor = zombie:isOnFloor(),
                knockedDown = zombie:isKnockedDown(), ragdoll = zombie:isRagdoll(),
                physicsRequested = zombie:usePhysicHitReaction(),
                displacementX = zombie:getX() - entry.x, displacementY = zombie:getY() - entry.y})
            entry.stage = entry.stage + 1
            if entry.stage >= 3 or zombie:getSquare() == nil then
                table.remove(observations, i)
            elseif entry.stage == 1 then
                entry.checkAt = entry.started + 600
            else
                entry.checkAt = entry.started + 1500
            end
        end
    end
end

---@return nil
function Combat.resetObservations()
    observations = {}
    Combat.pending, Combat.cursor = {}, 1
end

Combat.clearLane = require("OMHTT/DefenseLine").clear

---@param origin IsoGridSquare Device square
---@param range number? Maximum tile distance
---@return table candidates Bounded zombie list
---@return number visits Number of moving objects examined
function Combat.candidates(origin, range)
    range = range or Combat.RANGE
    local found = {}
    local seen = {}
    local visits = 0
    for radius = 0, math.ceil(range) do
        for dx = -radius, radius do
            local stride = 1
            if math.abs(dx) < radius then
                stride = radius * 2
            end
            for dy = -radius, radius, stride do
                if math.max(math.abs(dx), math.abs(dy)) == radius then
                    local square = getCell():getGridSquare(origin:getX() + dx, origin:getY() + dy, origin:getZ())
                    if square then
                        local objects = square:getMovingObjects()
                        for index = 0, objects:size() - 1 do
                            if visits >= Combat.CANDIDATE_LIMIT then
                                table.sort(found, function(a, b) return a.distance < b.distance end)
                                return found, visits
                            end
                            visits = visits + 1
                            local zombie = objects:get(index)
                            if not seen[zombie] and instanceof(zombie, "IsoZombie") and not zombie:isDead() and Horde.allowed(zombie) then
                                seen[zombie] = true
                                local zx = zombie:getX() - origin:getX() - 0.5
                                local zy = zombie:getY() - origin:getY() - 0.5
                                local distance = zx * zx + zy * zy
                                if distance <= range * range then
                                    found[#found + 1] = {zombie = zombie, distance = distance}
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    table.sort(found, function(a, b) return a.distance < b.distance end)
    return found, visits
end

---@param record table Persisted device state
---@param object IsoObject Exact device
---@param player IsoPlayer Test operator, SP only
---@param options table? Managed device tuning and resource commit
---@return string status
---@return table? impact Numeric effect facts
function Combat.fire(record, object, player, options)
    options = options or {range = Combat.RANGE, interval = Combat.SHOT_INTERVAL_MS, damage = Combat.DIRECT_DAMAGE,
        knockdown = Combat.KNOCKDOWN_CHANCE, splash = Combat.SPLASH_DAMAGE, radius = 1.1}
    Diagnostics.defer("shot-attempt", {id = record.id, ammo = record.ammo, shots = record.shots,
        nowMs = getTimestampMs(), nextShotMs = record.nextShot, kind = record.kind})
    if isClient() or (isServer() and not options.managed) then return "MPCombatDeferred" end
    if record.kind ~= "potato" then return "WrongDevice" end
    if record.ammo <= 0 then return "Empty" end
    local now = Clock.now()
    if not options.managed and record.nextShot > now + options.interval then
        Diagnostics.defer("shot-clock-rebased", {id = record.id, previous = record.nextShot, nowMs = now})
        record.nextShot = now + options.interval
    end
    if not options.managed and now < record.nextShot then return "Cooling" end
    local origin = object:getSquare()
    local candidates, visits = {}, 0
    local target, bestDistance = nil, 0
    if not options.target then
        candidates, visits = Combat.candidates(origin, options.range)
        for i = 1, #candidates do
            local zombie = candidates[i].zombie
            local inside = not options.profile or Modules.inside(origin, zombie, options.profile)
            if inside and Combat.clearLane(origin, zombie:getSquare(), options.range)
                and Modules.better(zombie, candidates[i].distance, target, bestDistance,
                    options.profile and options.profile.priority or "Closest") then
                target, bestDistance = zombie, candidates[i].distance
            end
        end
    end
    if options.target then
        local inside = Modules.inside(origin, options.target, options.profile)
        if inside and require("OMHTT/ControlCombat").eligible(object, options.target) and Combat.clearLane(origin, options.target:getSquare(), options.range) then
            target = options.target
        else
            target = nil
        end
    end
    record.lastCandidates = visits
    Diagnostics.defer("shot-search", {id = record.id, visits = visits, candidates = #candidates,
        selected = target ~= nil, capped = visits >= Combat.CANDIDATE_LIMIT})
    if not target then return "NoTarget" end
    options.visits = visits
    if options.align and not options.align(target) then return "Aiming" end
    if options.projectileSpeed and #Combat.pending >= 128 then return "Unavailable" end
    local volley = require("OMHTT/TurretVolley")
    if not volley.reserve(options) then return "Unavailable" end
    if options.commit and not options.commit() then
        volley.cancel(options)
        return options.failure or "Unavailable"
    end
    options.critical = ZombRand(10000) < (options.critChance or 0) * 100
    if not options.resolve and not weapon then
        weapon = instanceItem("Base.Hammer")
        weapon:setRanged(true)
        weapon:setKnockBackOnNoDeath(false)
        weapon:setSplatBloodOnNoDeath(false)
    end
    options.effectWeapon = options.resolve and options.weapon or weapon
    record.ammo = record.ammo - (options.ammoCost or 1)
    record.shots = record.shots + 1
    record.nextShot = now + options.interval
    record.cooldownClock = "realtime-ms-v1"
    local tx = target:getX()
    local ty = target:getY()
    local angle = math.atan2(-(ty - origin:getY() - 0.5), tx - origin:getX() - 0.5)
    record.facing = Foundation.normalizeFacing(math.floor(angle / (math.pi * 2) * 16 + 0.5))
    record.aimDegrees = (angle * 180 / math.pi + 360) % 360
    if not options.managed then
        object:setSprite(Foundation.spriteFor(record.kind, record.facing))
        object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_MODIFY)
    end
    local facts = {x = tx, y = ty, z = origin:getZ(), id = record.id, shot = record.shots,
        fromX = origin:getX() + 0.5, fromY = origin:getY() + 0.5, target = target}
    if options.projectileSpeed then
        local dx, dy = tx - facts.fromX, ty - facts.fromY
        facts.projectile = options.projectile
        facts.sound = options.projectile == "spear" and "SpearCraftedSwing" or nil
        facts.start = now
        facts.flight = math.max(50, math.sqrt(dx * dx + dy * dy) / options.projectileSpeed * 1000)
        Combat.pending[#Combat.pending + 1] = {record = {id = record.id, shots = record.shots, ammo = record.ammo, facing = record.facing},
            origin = origin, target = target, player = player, options = options, facts = facts, due = now + facts.flight}
        Diagnostics.defer("shot-launched", {id = record.id, shot = record.shots, flightMs = facts.flight,
            pending = #Combat.pending, x = tx, y = ty})
        return "Fired", facts
    end
    if options.resolve then return "Fired", options.resolve(record, origin, target, player, options) end
    return "Fired", Combat.hit(record, origin, target, player, options)
end

---@param record table Shot snapshot
---@param origin IsoGridSquare Launch square
---@param target IsoZombie Revalidated victim
---@param player IsoPlayer? Operator
---@param options table Damage snapshot
---@return table impact Presentation facts
---@param record table Source identity
---@param target IsoZombie Direct contact excluded from splash
---@param impactSquare IsoGridSquare Contact square
---@param tx number Contact X
---@param ty number Contact Y
---@param options table Bounded splash settings
---@return number contacts
function Combat.splash(record, target, impactSquare, tx, ty, options)
    local splash = 0
    local nearby = {}
    if options.splash > 0 and options.radius > 0 then
        nearby = Combat.candidates(impactSquare, options.radius + 1)
    end
    for i = 1, #nearby do
        local zombie = nearby[i].zombie
        if splash >= Combat.SPLASH_LIMIT then break end
        if zombie ~= target and not zombie:isDead() then
            local dx = zombie:getX() - tx
            local dy = zombie:getY() - ty
            if options.splash > 0 and dx * dx + dy * dy <= options.radius * options.radius
                and Combat.clearLane(impactSquare, zombie:getSquare(), options.range) then
                Damage.resolve(zombie, options.splash, record.id, "splash", function(lost)
                    if lost > 0 then
                        require("OMHTT/TurretSiphon").hit(zombie, options.siphon, options.secondary == true)
                    end
                end)
                splash = splash + 1
            end
        end
    end
    return splash
end

function Combat.hit(record, origin, target, player, options)
    if instanceof(target, "IsoPlayer") then
        local hit = require("OMHTT/TurretPlayerHit").hit(target, options, "Potato")
        local volley = require("OMHTT/TurretVolley")
        if not volley.pierce(record, origin, target, player, options, target:getSquare(), target:getX(), target:getY()) then
            volley.fragment(record, target:getX(), target:getY(), origin:getZ(), target, player, options)
        end
        Combat.splash(record, target, target:getSquare(), target:getX(), target:getY(), options)
        volley.release(options)
        return {id = record.id, shot = record.shots, x = target:getX(), y = target:getY(), z = target:getZ(), missed = not hit}
    end
    if not Horde.allowed(target) then
        require("OMHTT/TurretVolley").release(options)
        return {id = record.id, shot = record.shots, x = target:getX(), y = target:getY(), z = target:getZ(), missed = true}
    end
    local now, tx, ty = getTimestampMs(), target:getX(), target:getY()
    local before = target:getHealth()
    local impactSquare = target:getSquare()
    Diagnostics.defer("shot-hit-begin", {id = record.id, shot = record.shots, x = tx, y = ty, health = before,
        ammo = record.ammo, damageInput = options.damage, facing = record.facing})
    local critical = options.critical
    if critical == nil then critical = ZombRand(10000) < (options.critChance or 0) * 100 end
    local directDamage = options.damage * (critical and options.critMultiplier or 1)
    if options.stats then directDamage = Conditional.damage(target, directDamage, Conditional.snapshot(target, options.stats)) end
    local damagedAt = getTimestampMs()
    local knocked = false
    local volley = require("OMHTT/TurretVolley")
    if not volley.pierce(record, origin, target, player, options, impactSquare, tx, ty) then
        volley.fragment(record, tx, ty, origin:getZ(), target, player, options)
    end
    require("OMHTT/TurretHit").resolve(target, directDamage, record.id, "potato", options, function()
        require("OMHTT/TurretProc").hit(target, true, tx, ty, origin:getZ(), record, player, options)
        local guard = require("OMHTT/DefenseActorState").get(target).OMHTTKnockdownUntilMs
        if not target:isDead() and not target:isOnFloor() and not target:isKnockedDown()
            and (not guard or guard <= getTimestampMs()) and ZombRand(100) < options.knockdown then
            knocked = require("OMHTT/DefenseMotion").request(target, "knock", record.id, origin:getX() + .5, origin:getY() + .5)
            if knocked then require("OMHTT/DefenseActorState").get(target).OMHTTKnockdownUntilMs = getTimestampMs() + Combat.KNOCKDOWN_GUARD_MS end
        end
        Conditional.impact(target, origin, options)
        Diagnostics.defer("shot-damage-confirmed", {id = record.id, shot = record.shots, dead = target:isDead(), knocked = knocked})
        if not isServer() and Diagnostics.enabled("turrets") and SandboxVars.OMHTurretsTraps.TurretDetailedLogging == true then
            if #observations >= 12 then table.remove(observations, 1) end
            observations[#observations + 1] = {zombie = target, id = record.id, shot = record.shots,
                started = now, checkAt = now + 150, stage = 0, x = tx, y = ty}
        end
    end)
    local splashStarted = getTimestampMs()
    local splash = Combat.splash(record, target, impactSquare, tx, ty, options)
    Diagnostics.defer("shot-hit-end", {id = record.id, shot = record.shots, before = before, after = target:getHealth(),
        dead = target:isDead(), critical = critical, knockdown = knocked, splash = splash, ammo = record.ammo,
        directMs = damagedAt - now, reactionMs = splashStarted - damagedAt,
        splashMs = getTimestampMs() - splashStarted, hitMs = getTimestampMs() - now})
    require("OMHTT/TurretVolley").release(options)
    return {x = tx, y = ty, z = origin:getZ(), id = record.id, shot = record.shots, target = target,
        fromX = origin:getX() + 0.5, fromY = origin:getY() + 0.5}
end

---@param shot table Committed in-flight shot
---@return table impact Arrival facts
function Combat.arrive(shot)
    local target, origin, options = shot.target, shot.origin, shot.options
    local square = target:getSquare()
    local dx, dy = target:getX() - shot.facts.x, target:getY() - shot.facts.y
    if require("OMHTT/ControlCombat").eligible(options.object, target) and not target:isDead() and square and target:getZ() == origin:getZ() and dx * dx + dy * dy <= 4
        and getCell():getGridSquare(square:getX(), square:getY(), square:getZ()) == square
        and getCell():getGridSquare(origin:getX(), origin:getY(), origin:getZ()) == origin
        and Combat.clearLane(origin, square, options.range) then
        if options.resolve then return options.resolve(shot.record, origin, target, shot.player, options) end
        return Combat.hit(shot.record, origin, target, shot.player, options)
    end
    local volley = require("OMHTT/TurretVolley")
    volley.miss(shot.record, origin, target, shot.player, options, shot.facts.x, shot.facts.y)
    volley.release(options)
    local facts = shot.facts
    Diagnostics.defer("shot-missed", {id = facts.id, shot = facts.shot, reason = "target-or-path-changed"})
    return {id = facts.id, shot = facts.shot, x = facts.x, y = facts.y, z = facts.z, missed = true}
end

---@return nil
function Combat.tickFlights()
    if isClient() then return end
    local now, done = Clock.now(), 0
    local deadline = Budget.limit(2)
    for i = 1, math.min(16, #Combat.pending) do
        if #Combat.pending == 0 or done >= 4 or getTimestampMs() >= deadline then return end
        if Combat.cursor > #Combat.pending then Combat.cursor = 1 end
        local shot = Combat.pending[Combat.cursor]
        if now >= shot.due then
            table.remove(Combat.pending, Combat.cursor)
            local facts = Combat.arrive(shot)
            require("OMHTT/DefenseEffects").emit("Impact", facts)
            Diagnostics.defer("shot-arrived", {id = facts.id, shot = facts.shot, delayMs = now - shot.facts.start,
                lateMs = now - shot.due, missed = facts.missed == true})
            done = done + 1
        else
            Combat.cursor = Combat.cursor + 1
        end
    end
end

Budget.register("Combat.tickFlights", Combat.tickFlights)

Budget.register("Combat.observeImpacts", Combat.observeImpacts)
Events.OnGameStart.Add(Combat.resetObservations)

Foundation.prototypeFire = Combat.fire
return Combat
