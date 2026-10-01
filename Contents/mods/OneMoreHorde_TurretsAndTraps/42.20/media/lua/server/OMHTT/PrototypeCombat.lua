if isClient() then return end

local Foundation = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local Damage = require("OMHTT/Damage")
local Modules = require("OMHTT/TurretModules")

---@class OMHTTPrototypeCombat
local Combat = {
    RANGE = 6,
    CANDIDATE_LIMIT = 64,
    SHOT_INTERVAL_MS = 1000,
    KNOCKDOWN_GUARD_MS = 3000,
    KNOCKDOWN_CHANCE = 70,
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
    local now = getTimestampMs()
    for i = #observations, 1, -1 do
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

---@param origin IsoGridSquare Device square
---@param destination IsoGridSquare Target square
---@param range number? Maximum tile distance
---@return boolean clear
---@return string? reason Blocked path category
---@nodiscard
function Combat.clearLane(origin, destination, range)
    range = range or Combat.RANGE
    if not origin or not destination then return false, "missing-square" end
    if origin:getZ() ~= destination:getZ() then return false, "different-floor" end
    local dx = destination:getX() - origin:getX()
    local dy = destination:getY() - origin:getY()
    local steps = math.max(math.abs(dx), math.abs(dy))
    if steps > math.ceil(range) then return false, "range" end
    local previous = origin
    for i = 1, steps do
        local x = origin:getX() + math.floor(dx * i / steps + 0.5)
        local y = origin:getY() + math.floor(dy * i / steps + 0.5)
        local square = getCell():getGridSquare(x, y, origin:getZ())
        if not square then return false, "unloaded-path" end
        if previous:isBlockedTo(square) then return false, "blocked-edge" end
        if previous:isWindowTo(square) then return false, "window-edge" end
        if x ~= previous:getX() and y ~= previous:getY() then
            local sideX = getCell():getGridSquare(x, previous:getY(), origin:getZ())
            local sideY = getCell():getGridSquare(previous:getX(), y, origin:getZ())
            if not sideX or not sideY or previous:isBlockedTo(sideX) or previous:isBlockedTo(sideY)
                or sideX:isBlockedTo(square) or sideY:isBlockedTo(square)
                or previous:isWindowTo(sideX) or previous:isWindowTo(sideY)
                or sideX:isWindowTo(square) or sideY:isWindowTo(square) then return false, "diagonal-corner" end
        end
        previous = square
    end
    return true
end

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
                            if not seen[zombie] and instanceof(zombie, "IsoZombie") and not zombie:isDead() then
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
    Diagnostics.emit("shot-attempt", {id = record.id, ammo = record.ammo, shots = record.shots,
        nowMs = getTimestampMs(), nextShotMs = record.nextShot, kind = record.kind})
    if isClient() or isServer() then return "MPCombatDeferred" end
    if record.kind ~= "potato" then return "WrongDevice" end
    if record.ammo <= 0 then return "Empty" end
    local now = getTimestampMs()
    if not options.managed and record.nextShot > now + options.interval then
        Diagnostics.emit("shot-clock-rebased", {id = record.id, previous = record.nextShot, nowMs = now})
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
        if inside and Combat.clearLane(origin, options.target:getSquare(), options.range) then
            target = options.target
        else
            target = nil
        end
    end
    record.lastCandidates = visits
    Diagnostics.emit("shot-search", {id = record.id, visits = visits, candidates = #candidates,
        selected = target ~= nil, capped = visits >= Combat.CANDIDATE_LIMIT})
    if not target then return "NoTarget" end
    options.visits = visits
    if options.align and not options.align(target) then return "Aiming" end
    if options.projectileSpeed and #Combat.pending >= 128 then return "Unavailable" end
    if options.commit and not options.commit() then return "Unavailable" end
    if not weapon then
        weapon = instanceItem("Base.Hammer")
        weapon:setRanged(true)
        weapon:setKnockBackOnNoDeath(false)
        weapon:setSplatBloodOnNoDeath(false)
    end
    record.ammo = record.ammo - 1
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
        facts.start = now
        facts.flight = math.max(50, math.sqrt(dx * dx + dy * dy) / options.projectileSpeed * 1000)
        Combat.pending[#Combat.pending + 1] = {record = {id = record.id, shots = record.shots, ammo = record.ammo, facing = record.facing},
            origin = origin, target = target, player = player, options = options, facts = facts, due = now + facts.flight}
        Diagnostics.emit("shot-launched", {id = record.id, shot = record.shots, flightMs = facts.flight,
            pending = #Combat.pending, x = tx, y = ty})
        return "Fired", facts
    end
    return "Fired", Combat.hit(record, origin, target, player, options)
end

---@param record table Shot snapshot
---@param origin IsoGridSquare Launch square
---@param target IsoZombie Revalidated victim
---@param player IsoPlayer? Operator
---@param options table Damage snapshot
---@return table impact Presentation facts
function Combat.hit(record, origin, target, player, options)
    local now, tx, ty = getTimestampMs(), target:getX(), target:getY()
    local before = target:getHealth()
    local impactSquare = target:getSquare()
    Diagnostics.emit("shot-hit-begin", {id = record.id, shot = record.shots, x = tx, y = ty, health = before,
        ammo = record.ammo, damageInput = options.damage, facing = record.facing})
    Damage.apply(target, options.damage, record.id, "potato", player, weapon)
    local knocked = false
    local knockReason = "dead"
    local roll = -1
    local remaining = 0
    if not target:isDead() then
        if target:isOnFloor() or target:isKnockedDown() then
            knockReason = "already-down"
        else
            local last = target:getModData().OMHTTKnockdownUntilMs
            if last and last > now + Combat.KNOCKDOWN_GUARD_MS then
                last = now + Combat.KNOCKDOWN_GUARD_MS
                target:getModData().OMHTTKnockdownUntilMs = last
            end
            if last and now < last then
                remaining = last - now
                knockReason = "recovery-guard"
            else
                roll = ZombRand(100)
                knockReason = "chance-miss"
                if roll < options.knockdown then
                    target:knockDown(false)
                    target:setPlayerAttackPosition("FRONT")
                    target:setUsePhysicHitReaction(false)
                    local dx = tx - origin:getX() - 0.5
                    local dy = ty - origin:getY() - 0.5
                    local length = math.sqrt(dx * dx + dy * dy)
                    if length > 0 then
                        target:setHitDir(Vector2.new(dx / length, dy / length))
                    end
                    target:setHitForce(0.35)
                    target:getModData().OMHTTKnockdownUntilMs = now + Combat.KNOCKDOWN_GUARD_MS
                    knocked = true
                    knockReason = "requested"
                end
            end
        end
    end
    Diagnostics.emit("shot-knockdown", {id = record.id, shot = record.shots, reason = knockReason,
        roll = roll, chance = options.knockdown, guardRemainingMs = remaining,
        state = target:getCurrentStateName(), ragdollAllowed = target:canRagdoll(),
        physicsRequested = target:usePhysicHitReaction()})
    if #observations >= 12 then table.remove(observations, 1) end
    observations[#observations + 1] = {zombie = target, id = record.id, shot = record.shots,
        started = now, checkAt = now + 150, stage = 0, x = tx, y = ty}
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
                Damage.apply(zombie, options.splash, record.id, "splash", player, weapon)
                splash = splash + 1
            end
        end
    end
    print("[OMHTT] potato-shot id=" .. record.id .. " sequence=" .. record.shots .. " before=" .. before
        .. " after=" .. target:getHealth() .. " dead=" .. tostring(target:isDead()) .. " knockdown=" .. tostring(knocked)
        .. " splash=" .. splash .. " candidates=" .. (options.visits or 0) .. " ammo=" .. record.ammo)
    Diagnostics.emit("shot-hit-end", {id = record.id, shot = record.shots, before = before, after = target:getHealth(),
        dead = target:isDead(), knockdown = knocked, splash = splash, ammo = record.ammo})
    return {x = tx, y = ty, z = origin:getZ(), id = record.id, shot = record.shots, target = target,
        fromX = origin:getX() + 0.5, fromY = origin:getY() + 0.5}
end

---@param shot table Committed in-flight shot
---@return table impact Arrival facts
function Combat.arrive(shot)
    local target, origin, options = shot.target, shot.origin, shot.options
    local square = target:getSquare()
    local dx, dy = target:getX() - shot.facts.x, target:getY() - shot.facts.y
    if not target:isDead() and square and target:getZ() == origin:getZ() and dx * dx + dy * dy <= 4
        and getCell():getGridSquare(square:getX(), square:getY(), square:getZ()) == square
        and getCell():getGridSquare(origin:getX(), origin:getY(), origin:getZ()) == origin
        and Combat.clearLane(origin, square, options.range) then
        return Combat.hit(shot.record, origin, target, shot.player, options)
    end
    local facts = shot.facts
    Diagnostics.emit("shot-missed", {id = facts.id, shot = facts.shot, reason = "target-or-path-changed"})
    return {id = facts.id, shot = facts.shot, x = facts.x, y = facts.y, z = facts.z, missed = true}
end

---@return nil
function Combat.tickFlights()
    if isClient() or isServer() then return end
    local now, done = getTimestampMs(), 0
    local deadline = now + 2
    for i = 1, math.min(16, #Combat.pending) do
        if #Combat.pending == 0 or done >= 4 or getTimestampMs() >= deadline then return end
        if Combat.cursor > #Combat.pending then Combat.cursor = 1 end
        local shot = Combat.pending[Combat.cursor]
        if now >= shot.due then
            table.remove(Combat.pending, Combat.cursor)
            local facts = Combat.arrive(shot)
            triggerEvent("OnServerCommand", Foundation.MODULE, "Impact", facts)
            Diagnostics.emit("shot-arrived", {id = facts.id, shot = facts.shot, delayMs = now - shot.facts.start,
                lateMs = now - shot.due, missed = facts.missed == true})
            done = done + 1
        else
            Combat.cursor = Combat.cursor + 1
        end
    end
end

Events.OnTick.Add(Combat.tickFlights)

Events.OnTick.Add(Combat.observeImpacts)
Events.OnGameStart.Add(Combat.resetObservations)

return Combat
