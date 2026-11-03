if isClient() then return end

local ActiveTime = require("OMHTT/ActiveTime")
local Actors = require("OMHTT/DefenseActors")
local Contacts = require("OMHTT/DefenseContacts")
local CombatServer = require("OMHTT/DefenseCombatServer")
local Notice = require("OMHTT/DamageNotice")
local XP = require("OMHTT/DefenseXP")
local Diagnostics = require("OMHTT/Diagnostics")
local Horde = require("OMHTT/DefenseHorde")
local Protocol = require("OMHTT/DefenseCombatProtocol")
local Damage = {}
local active = setmetatable({}, {__mode = "k"})
local byVictim = {}
local firstLane, lastLane
local laneCount, queued = 0, 0
local MAX_QUEUED, MAX_PER_VICTIM = 256, 8
local STARTS_PER_TICK, SLICE_MS = 32, 2
local failed = setmetatable({}, {__mode = "k"})

---@param zombie IsoZombie Exact candidate
---@return boolean capacity Bounded queue has room for another hit
function Damage.available(zombie)
    local failure = failed[zombie]
    if failure then
        local _, _, _, current, observedAt = Actors.position(zombie)
        local recovered = failure.observedAfter and current and observedAt and observedAt > failure.observedAfter
        if zombie:getOnlineID() ~= failure.id or Protocol.outfit(zombie:getPersistentOutfitID()) ~= failure.outfit
            or zombie:getOwner() ~= failure.owner or recovered or (not failure.observedAfter and getTimestampMs() >= failure.untilAt) then
            failed[zombie] = nil
        else
            return false
        end
    end
    return queued < MAX_QUEUED and (not byVictim[zombie] or #byVictim[zombie] < MAX_PER_VICTIM)
end

---@param zombie IsoZombie Living victim
---@param amount number Fixed native health loss
---@param source string Device identity
---@param kind string Direct, splash or barrier
---@param operator IsoPlayer? Manual test operator
---@param weapon HandWeapon? Native kill context for manual fire
---@return number lost Actual native health removed
local function apply(zombie, amount, source, kind, operator, weapon)
    if isClient() or not Protocol.living(zombie) or amount <= 0 then return 0 end
    local allowed, core, token = Horde.beginDamage(zombie, amount, source, kind)
    if not allowed then return 0 end
    local health = rawget(_G, "OMHTT_TargetHealth")
    if health then
        health.settle(zombie)
    end
    local before = zombie:getHealth()
    local remaining = before - amount
    if remaining < 0.000001 then
        remaining = 0
    end
    local notice = Notice.capture(zombie, before - remaining, source, kind)
    zombie:setHealth(remaining)
    if remaining == 0 then
        XP.lethal(zombie, source, token and token.event)
        -- Manual device fire must not grant ordinary weapon-kill credit.
        zombie:Kill(nil, false)
        if isServer() and zombie:getSquare() then
            zombie:die()
        end
    end
    if core then
        core.endDamage(zombie, token)
    end
    local lost = before - zombie:getHealth()
    local component = "traps"
    if type(source) == "string" and string.find(source, "^turret") then
        component = "turrets"
    end
    Diagnostics.defer("damage-applied", {id = source, kind = kind, before = before,
        after = zombie:getHealth(), nativeDamage = lost, damage100 = lost * 100, dead = not Protocol.living(zombie)}, component)
    Notice.send(notice)
    triggerEvent("OnOMHTTDamage", zombie, lost, source, kind)
    return lost
end

---@param zombie IsoZombie Victim
---@param amount number Native damage
---@param source string Device identity
---@param kind string Effect family
---@param operator IsoPlayer? Manual operator
---@param weapon HandWeapon? Native weapon context
---@return number lost Synchronous SP-only compatibility path
function Damage.apply(zombie, amount, source, kind, operator, weapon)
    if isClient() or isServer() then return 0 end
    return apply(zombie, amount, source, kind, operator, weapon)
end

---@param zombie IsoZombie Exact victim
---@param amount number Server-calculated native health loss
---@param source string Device identity
---@param kind string Effect family
---@param callback function? Completion receives actual loss and result
---@return boolean accepted Completion may be asynchronous on MP
function Damage.request(zombie, amount, source, kind, callback, expiresAt, observation, second)
    if ActiveTime.paused() then return false end
    if isClient() or not zombie or not Protocol.living(zombie) or zombie:isInvulnerable()
        or not Protocol.number(amount, 0.000001, 1000000)
        or type(source) ~= "string" or #source == 0 or #source > 160
        or type(kind) ~= "string" or #kind == 0 or #kind > 64 then return false end
    if isServer() and zombie:getOwner() ~= nil then
        local health = rawget(_G, "OMHTT_TargetHealth")
        if health then
            health.settle(zombie)
        end
        return CombatServer.request(zombie, amount, source, kind, callback, expiresAt, observation, second)
    end
    if second then return false end
    local lost = apply(zombie, amount, source, kind, nil, nil)
    if callback then
        callback(lost, lost > 0 and "applied" or "rejected")
    end
    return lost > 0
end

---@param job table Server-calculated hit
---@return nil
local function dispatch(job, second)
    local zombie = job.zombie
    Diagnostics.measure("damage-queue",getTimestampMs()-job.queuedAt,string.find(job.source,"^turret") and "turrets" or "traps")
    active[zombie] = job
    local completed = false
    local firstDelivered = false
    ---@param lost number Confirmed loss
    ---@param reason string Completion result
    ---@return nil
    local function done(lost, reason)
        if completed then return end
        completed = true
        if active[zombie] == job then
            active[zombie] = nil
        end
        if lost <= 0 and reason ~= "rejected" and reason ~= "capacity" and reason ~= "expired" then
            failed[zombie] = {id = zombie:getOnlineID(), outfit = Protocol.outfit(zombie:getPersistentOutfitID()),
                owner = zombie:getOwner(), untilAt = getTimestampMs() + 1000}
            if zombie:getOwner() and (reason == "missing" or reason == "identity" or reason == "dead" or reason == "not-owner" or reason == "position") then
                failed[zombie].observedAfter = GameTime.getServerTimeMills()
            end
            Diagnostics.defer("target-revalidate", {id = job.source, victim = zombie:getOnlineID(), reason = reason},
                string.find(job.source, "^turret") and "turrets" or "traps")
        else
            failed[zombie] = nil
        end
    end
    local function firstDone(lost, reason)
        if firstDelivered then return end
        firstDelivered = true
        if not second then
            done(lost, reason)
        end
        if job.callback then
            job.callback(lost, reason)
        end
    end
    if second then
        local callback = second.callback
        second.observedAt = second.observation and second.observation.at
        second.callback = function(lost, reason)
            if completed then return end
            done(lost, reason)
            if callback then
                callback(lost, reason)
            end
        end
    end
    if not Damage.request(zombie, job.amount, job.source, job.kind, firstDone, job.expiresAt, job.observation, second) then
        firstDone(0, "rejected")
        if second then
            second.callback(0, "rejected")
        end
    end
end

---@param lane table Victim FIFO with pending jobs
---@return nil
local function appendLane(lane)
    lane.following = nil
    if lastLane then
        lastLane.following = lane
    else
        firstLane = lane
    end
    lastLane = lane
end

---@param zombie IsoZombie Exact victim
---@param amount number Native health loss
---@param source string Device identity
---@param kind string Effect family
---@param callback function? Invoked exactly once, including rejection
---@return boolean admitted Accepted for immediate or bounded serialized application
---@param observation table? Explicit validated contact timestamp
function Damage.resolve(zombie, amount, source, kind, callback, observation)
    if isClient() or not zombie or not Protocol.living(zombie)
        or type(source) ~= "string" or #source == 0 or #source > 160
        or type(kind) ~= "string" or #kind == 0 or #kind > 64
        or not Protocol.number(amount, .000001, 1000000) then
        if callback then
            callback(0, "rejected")
        end
        return false
    end
    if not Damage.available(zombie) then
        if callback then
            callback(0, "unavailable")
        end
        return false
    end
    if not isServer() then
        local lost = Damage.apply(zombie, amount, source, kind)
        if callback then
            callback(lost, lost > 0 and "applied" or "rejected")
        end
        return lost > 0
    end
    local lease = Horde.capture(zombie)
    if not lease then
        if callback then
            callback(0, "rejected")
        end
        return false
    end
    local lifetime = Protocol.contact(kind) and 500 or Protocol.TIMEOUT
    local now = getTimestampMs()
    local serverNow = GameTime.getServerTimeMills()
    local expiresAt = serverNow + lifetime
    if kind == "rotary" and observation then
        expiresAt = math.min(expiresAt, observation.at + lifetime)
    end
    if expiresAt < serverNow then
        if callback then
            callback(0, "cancelled")
        end
        return false
    end
    local job = {zombie = zombie, amount = amount, source = source, kind = kind, callback = callback,
        lease = lease, deadline = now + (expiresAt - serverNow), expiresAt = expiresAt,
        queuedAt = now, observation = observation or Contacts.current,
        id = zombie:getOnlineID(), outfit = Protocol.outfit(zombie:getPersistentOutfitID())}
    local lane = byVictim[zombie]
    if active[zombie] or lane or (zombie:getOwner() and not CombatServer.available()) then
        if not lane then
            lane = {zombie = zombie, expiry = expiresAt}
            byVictim[zombie] = lane
            laneCount = laneCount + 1
            appendLane(lane)
        end
        lane[#lane + 1] = job
        lane.expiry = math.min(lane.expiry, expiresAt)
        queued = queued + 1
    else
        dispatch(job)
    end
    return true
end

local startsLeft, msLeft = STARTS_PER_TICK, SLICE_MS
local servicing = false

---@param visits number Maximum FIFO lanes to visit
---@return nil
local function service(visits)
    if servicing or startsLeft <= 0 or msLeft <= 0 then return end
    servicing = true
    local now = getTimestampMs()
    local serverNow = GameTime.getServerTimeMills()
    for _ = 1, visits do
        local lane = firstLane
        firstLane = lane.following
        if not firstLane then
            lastLane = nil
        end
        local zombie = lane.zombie
        if serverNow > lane.expiry or now > lane[1].deadline then
            lane.expiry = math.huge
            local i = 1
            for _ = 1, #lane do
                local job = lane[i]
                if serverNow > job.expiresAt or now > job.deadline then
                    table.remove(lane, i)
                    queued = queued - 1
                    if job.callback then
                        job.callback(0, "cancelled")
                    end
                else
                    lane.expiry = math.min(lane.expiry, job.expiresAt)
                    i = i + 1
                end
            end
        end
        if lane[1] and not active[zombie] and (not zombie:getOwner() or CombatServer.available()) then
            local job = table.remove(lane, 1)
            queued = queued - 1
            if not failed[zombie] and Protocol.living(zombie) and zombie:getOnlineID() == job.id
                and Protocol.outfit(zombie:getPersistentOutfitID()) == job.outfit and Horde.matches(zombie, job.lease) then
                local second = lane[1]
                if second and zombie:getOwner() and second.id == job.id and second.outfit == job.outfit
                    and second.deadline >= now and second.expiresAt >= serverNow and Horde.matches(zombie, second.lease) then
                    table.remove(lane, 1)
                    queued = queued - 1
                else
                    second = nil
                end
                startsLeft = startsLeft - 1
                dispatch(job, second)
            elseif job.callback then
                job.callback(0, "cancelled")
            end
        end
        if lane[1] then
            appendLane(lane)
        else
            byVictim[zombie] = nil
            laneCount = laneCount - 1
        end
        if startsLeft == 0 or getTimestampMs() - now >= msLeft then break end
    end
    msLeft = msLeft - (getTimestampMs() - now)
    servicing = false
end

---@param zombie IsoZombie Victim whose owner receipt has fully settled
---@return nil
function CombatServer.afterApplied(zombie)
    -- Only advance the front lane. An acknowledgement never jumps a waiting victim.
    if firstLane and firstLane.zombie == zombie and not active[zombie] and not ActiveTime.paused() then
        service(1)
    end
end

---@return nil
function Damage.tick()
    if not isServer() then return end
    startsLeft, msLeft = STARTS_PER_TICK, SLICE_MS
    if queued > 0 then service(laneCount) end
end

Events.OnTick.Add(Damage.tick)

return Damage
