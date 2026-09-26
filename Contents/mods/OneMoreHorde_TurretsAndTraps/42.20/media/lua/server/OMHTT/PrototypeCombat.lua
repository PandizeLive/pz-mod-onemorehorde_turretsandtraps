if isClient() then return end

local Foundation = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local Damage = require("OMHTT/Damage")

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
end

---@param origin IsoGridSquare Device square
---@param destination IsoGridSquare Target square
---@return boolean clear
---@return string? reason Blocked path category
---@nodiscard
function Combat.clearLane(origin, destination)
    if not origin or not destination then return false, "missing-square" end
    if origin:getZ() ~= destination:getZ() then return false, "different-floor" end
    local dx = destination:getX() - origin:getX()
    local dy = destination:getY() - origin:getY()
    local steps = math.max(math.abs(dx), math.abs(dy))
    if steps > Combat.RANGE then return false, "range" end
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
---@return table candidates Bounded zombie list
---@return number visits Number of moving objects examined
function Combat.candidates(origin)
    local found = {}
    local seen = {}
    local visits = 0
    for radius = 0, Combat.RANGE do
        for dx = -radius, radius do
            for dy = -radius, radius do
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
                                if distance <= Combat.RANGE * Combat.RANGE then
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
---@return string status
---@return table? impact Numeric effect facts
function Combat.fire(record, object, player)
    Diagnostics.emit("shot-attempt", {id = record.id, ammo = record.ammo, shots = record.shots,
        nowMs = getTimestampMs(), nextShotMs = record.nextShot, kind = record.kind})
    if isClient() or isServer() then return "MPCombatDeferred" end
    if record.kind ~= "potato" then return "WrongDevice" end
    if record.ammo <= 0 then return "Empty" end
    local now = getTimestampMs()
    if record.nextShot > now + Combat.SHOT_INTERVAL_MS then
        Diagnostics.emit("shot-clock-rebased", {id = record.id, previous = record.nextShot, nowMs = now})
        record.nextShot = now + Combat.SHOT_INTERVAL_MS
    end
    if now < record.nextShot then return "Cooling" end
    local origin = object:getSquare()
    local candidates, visits = Combat.candidates(origin)
    local target = nil
    for i = 1, #candidates do
        local zombie = candidates[i].zombie
        local clear, reason = Combat.clearLane(origin, zombie:getSquare())
        if i <= 6 then
            Diagnostics.emit("shot-candidate", {id = record.id, order = i, x = zombie:getX(), y = zombie:getY(),
                health = zombie:getHealth(), distanceSquared = candidates[i].distance, clear = clear, reason = tostring(reason)})
        end
        if clear then
            target = zombie
            break
        end
    end
    record.lastCandidates = visits
    Diagnostics.emit("shot-search", {id = record.id, visits = visits, candidates = #candidates,
        selected = target ~= nil, capped = visits >= Combat.CANDIDATE_LIMIT})
    if not target then return "NoTarget" end
    if not weapon then
        weapon = instanceItem("Base.Hammer")
        weapon:setRanged(true)
        weapon:setKnockBackOnNoDeath(false)
        weapon:setSplatBloodOnNoDeath(false)
    end
    record.ammo = record.ammo - 1
    record.shots = record.shots + 1
    record.nextShot = now + Combat.SHOT_INTERVAL_MS
    record.cooldownClock = "realtime-ms-v1"
    local tx = target:getX()
    local ty = target:getY()
    local angle = math.atan2(-(ty - origin:getY() - 0.5), tx - origin:getX() - 0.5)
    record.facing = Foundation.normalizeFacing(math.floor(angle / (math.pi * 2) * 16 + 0.5))
    object:setSprite(Foundation.spriteFor(record.kind, record.facing))
    object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_MODIFY)
    local before = target:getHealth()
    local impactSquare = target:getSquare()
    Diagnostics.emit("shot-hit-begin", {id = record.id, shot = record.shots, x = tx, y = ty, health = before,
        ammo = record.ammo, damageInput = Combat.DIRECT_DAMAGE, facing = record.facing})
    Damage.apply(target, Combat.DIRECT_DAMAGE, record.id, "potato", player, weapon)
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
                if roll < Combat.KNOCKDOWN_CHANCE then
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
        roll = roll, chance = Combat.KNOCKDOWN_CHANCE, guardRemainingMs = remaining,
        state = target:getCurrentStateName(), ragdollAllowed = target:canRagdoll(),
        physicsRequested = target:usePhysicHitReaction()})
    if #observations >= 12 then table.remove(observations, 1) end
    observations[#observations + 1] = {zombie = target, id = record.id, shot = record.shots,
        started = now, checkAt = now + 150, stage = 0, x = tx, y = ty}
    local splash = 0
    for i = 1, #candidates do
        local zombie = candidates[i].zombie
        if splash >= Combat.SPLASH_LIMIT then break end
        if zombie ~= target and not zombie:isDead() then
            local dx = zombie:getX() - tx
            local dy = zombie:getY() - ty
            if dx * dx + dy * dy <= 1.21 and Combat.clearLane(impactSquare, zombie:getSquare()) then
                Damage.apply(zombie, Combat.SPLASH_DAMAGE, record.id, "splash", player, weapon)
                splash = splash + 1
            end
        end
    end
    print("[OMHTT] potato-shot id=" .. record.id .. " sequence=" .. record.shots .. " before=" .. before
        .. " after=" .. target:getHealth() .. " dead=" .. tostring(target:isDead()) .. " knockdown=" .. tostring(knocked)
        .. " splash=" .. splash .. " candidates=" .. visits .. " ammo=" .. record.ammo)
    Diagnostics.emit("shot-hit-end", {id = record.id, shot = record.shots, before = before, after = target:getHealth(),
        dead = target:isDead(), knockdown = knocked, splash = splash, ammo = record.ammo})
    return "Fired", {x = tx, y = ty, z = origin:getZ(), id = record.id, shot = record.shots}
end

Events.OnTick.Add(Combat.observeImpacts)
Events.OnGameStart.Add(Combat.resetObservations)

return Combat
