if isClient() then return end

require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local Horde = require("OMHTT/DefenseHorde")
local Protocol = require("OMHTT/DefenseCombatProtocol")
local Damage = {}
local waiting, active = {}, setmetatable({}, {__mode = "k"})
local byVictim = setmetatable({}, {__mode = "k"})
local queued, cursor = 0, 1

---@param zombie IsoZombie Living victim
---@param amount number Fixed native health loss
---@param source string Device identity
---@param kind string Direct, splash or barrier
---@param operator IsoPlayer? Manual test operator
---@param weapon HandWeapon? Native kill context for manual fire
---@return number lost Actual native health removed
local function apply(zombie, amount, source, kind, operator, weapon)
    if isClient() or zombie:isDead() or amount <= 0 then return 0 end
    local allowed, core, token = Horde.beginDamage(zombie, amount, source, kind)
    if not allowed then return 0 end
    local before = zombie:getHealth()
    local remaining = before - amount
    if remaining < 0.000001 then
        remaining = 0
    end
    zombie:setHealth(remaining)
    if remaining == 0 then
        -- Manual device fire must not grant ordinary weapon-kill credit.
        zombie:Kill(nil, false)
    end
    if core then
        core.endDamage(zombie, token)
    end
    local lost = before - zombie:getHealth()
    Diagnostics.defer("damage-applied", {id = source, kind = kind, before = before,
        after = zombie:getHealth(), nativeDamage = lost, damage100 = lost * 100, dead = zombie:isDead()})
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
function Damage.request(zombie, amount, source, kind, callback)
    if isClient() or not zombie or zombie:isDead() or zombie:isInvulnerable()
        or not Protocol.number(amount, 0.000001, 1000000)
        or type(source) ~= "string" or #source == 0 or #source > 160
        or type(kind) ~= "string" or #kind == 0 or #kind > 64 then return false end
    if isServer() and zombie:getOwner() ~= nil then
        return require("OMHTT/DefenseCombatServer").request(zombie, amount, source, kind, callback)
    end
    local lost = apply(zombie, amount, source, kind, nil, nil)
    if callback then callback(lost, lost > 0 and "applied" or "rejected") end
    return lost > 0
end

---@param job table Server-calculated hit
---@return nil
local function dispatch(job)
    local zombie = job.zombie
    active[zombie] = job
    local completed = false
    ---@param lost number Confirmed loss
    ---@param reason string Completion result
    ---@return nil
    local function done(lost, reason)
        if completed then return end
        completed = true
        if active[zombie] == job then active[zombie] = nil end
        if job.callback then job.callback(lost, reason) end
    end
    if not Damage.request(zombie, job.amount, job.source, job.kind, done) then
        done(0, "rejected")
    end
end

---@param zombie IsoZombie Exact victim
---@param amount number Native health loss
---@param source string Device identity
---@param kind string Effect family
---@param callback function? Invoked exactly once, including rejection
---@return boolean admitted Accepted for immediate or bounded serialized application
function Damage.resolve(zombie, amount, source, kind, callback)
    if isClient() or not zombie or zombie:isDead() or queued >= 256
        or (byVictim[zombie] and #byVictim[zombie] >= 8)
        or not Protocol.number(amount, .000001, 1000000) then
        if callback then callback(0, "rejected") end
        return false
    end
    if not isServer() then
        local lost = Damage.apply(zombie, amount, source, kind)
        if callback then callback(lost, lost > 0 and "applied" or "rejected") end
        return lost > 0
    end
    local lease = Horde.capture(zombie)
    if not lease then
        if callback then callback(0, "rejected") end
        return false
    end
    local job = {zombie = zombie, amount = amount, source = source, kind = kind, callback = callback,
        lease = lease, deadline = getTimestampMs() + Protocol.TIMEOUT,
        id = zombie:getOnlineID(), outfit = zombie:getPersistentOutfitID()}
    if active[zombie] or byVictim[zombie] then
        local queue = byVictim[zombie]
        if not queue then queue = {}; byVictim[zombie] = queue end
        queue[#queue + 1] = job
        waiting[#waiting + 1], queued = job, queued + 1
    else
        dispatch(job)
    end
    return true
end

---@return nil
function Damage.tick()
    if not isServer() or queued == 0 then return end
    local now = getTimestampMs()
    local processed = {}
    for _ = 1, math.min(16, #waiting) do
        if #waiting == 0 then return end
        if cursor > #waiting then cursor = 1 end
        local job = waiting[cursor]
        local zombie = job.zombie
        local valid = now <= job.deadline and not zombie:isDead() and zombie:getOnlineID() == job.id
            and zombie:getPersistentOutfitID() == job.outfit and Horde.matches(zombie, job.lease)
        local queue = byVictim[zombie]
        if not valid or (not active[zombie] and not processed[zombie] and queue[1] == job) then
            table.remove(waiting, cursor)
            queued = queued - 1
            for index = 1, #queue do
                if queue[index] == job then table.remove(queue, index); break end
            end
            if #queue == 0 then byVictim[zombie] = nil end
            if valid then
                processed[zombie] = true
                dispatch(job)
            elseif job.callback then
                job.callback(0, "cancelled")
            end
        else
            cursor = cursor + 1
        end
    end
end

Events.OnTick.Add(Damage.tick)

return Damage
