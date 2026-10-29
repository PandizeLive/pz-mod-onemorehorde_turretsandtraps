local P = require("OMHTT/DefenseCombatProtocol")
local H = require("OMHTT/DefenseHorde")
local S = {}
local pending, order = {}, {}
local victims = setmetatable({}, {__mode = "k"})
local serials = setmetatable({}, {__mode = "k"})
local session, serial, cursor = tostring(getTimestampMs()), 0, 1

---@param job table Pending authorized operation
---@param lost number Confirmed damage
---@param reason string Completion result
---@return nil
local function finish(job, lost, reason)
    if pending[job.token] ~= job then return end
    pending[job.token], victims[job.zombie] = nil, nil
    local last = order[#order]
    if last ~= job then
        order[job.index] = last
        last.index = job.index
    end
    order[#order] = nil
    local D = require("OMHTT/Diagnostics")
    local component = string.find(job.source, "^turret") and "turrets" or "traps"
    D.count("combat-result-" .. reason, 1, component)
    D.defer("combat-result", {token = job.token, id = job.source, victim = job.id, kind = job.kind,
        phase = job.phase, reason = reason, loss = lost, elapsedMs = getTimestampMs() - job.started,
        ownerProcessingMs = job.ownerProcessingMs, dispatchMs = job.dispatched and job.dispatched - job.started, clientX = job.clientX, clientY = job.clientY, x = job.zombie:getX(), y = job.zombie:getY()}, component)
    if job.callback then job.callback(lost, reason) end
end

---@param job table Pending operation
---@return boolean valid
local function current(job)
    local zombie = job.zombie
    return P.living(zombie) and zombie:getOnlineID() == job.id
        and require("OMHTT/DefenseCombatProtocol").outfit(zombie:getPersistentOutfitID()) == job.outfit and zombie:getOwnerPlayer() == job.player
        and zombie:getOwner() == job.connection and not job.player:isDead() and H.matches(zombie, job.lease)
end

---@param job table Authorized operation
---@return table message Plain network values only
local function envelope(job)
    return {token = job.token, id = job.id, outfit = job.outfit, owner = job.player:getOnlineID(), sequence = job.sequence}
end

---@param job table Operation whose previous owner cannot still apply damage
---@return boolean prepared
local function dispatch(job)
    local zombie = job.zombie
    local player, connection = zombie:getOwnerPlayer(), zombie:getOwner()
    if not player or not connection or player:isDead() or player:getOnlineID() == -1
        or not P.identity(player:getOnlineID()) then return false end
    local sequence = (serials[zombie] or 0) + 1
    serials[zombie] = sequence
    job.player, job.connection, job.sequence, job.receipt = player, connection, sequence, nil
    job.phase = job.result and "settle-commit" or "commit"
    job.receipt = job.token .. ":" .. sequence
    if not H.mark(zombie, job.lease, job.source, job.kind) then return false end
    local message = envelope(job)
    message.receipt, message.amount = job.receipt, job.amount
    message.x, message.y, message.z = zombie:getX(), zombie:getY(), zombie:getZ()
    message.health = job.result and job.result.after or nil
    message.issuedAt = GameTime.getServerTimeMills()
    message.expiresAt = job.result and job.expiresAt or job.applyExpiresAt
    job.dispatched = getTimestampMs()
    sendServerCommand(player, P.MODULE, job.result and "Reconcile" or "Apply", message)
    return true
end

---@param job table Confirmed client result
---@return nil
local function commitResult(job)
    local result, zombie = job.result, job.zombie
    if not H.matches(zombie, job.lease) then finish(job, 0, "consent-changed"); return end
    local allowed, core, token = H.beginDamage(zombie, result.lost, job.source, job.kind, result.lethal)
    if not allowed then finish(job, 0, "consent-changed"); return end
    local notice = require("OMHTT/DamageNotice").capture(zombie, result.lost, job.source, job.kind)
    zombie:setHealth(math.min(zombie:getHealth(), result.after))
    if result.lethal then
        zombie:setHealth(0)
        require("OMHTT/DefenseXP").lethal(zombie, job.source, token and token.event)
        zombie:Kill(nil, false)
        -- The owning client reserves nonzero health and cannot enter its death
        -- animation. Complete native server death, including corpse replication.
        if zombie:getSquare() then zombie:die() end
    end
    if core then
        core.endDamage(zombie, token)
    end
    require("OMHTT/DamageNotice").send(notice)
    finish(job, result.lost, "applied")
    local component = string.find(job.source, "^turret") and "turrets" or "traps"
    local event = result.lethal and "combat-lethal" or "combat-settled"
    require("OMHTT/Diagnostics").defer(event, {id = job.source, victim = job.id,
        damage = result.lost, lethal = result.lethal, dead = zombie:isDead(),
        corpseComplete = zombie:isOnDeathDone()}, component)
    triggerEvent("OnOMHTTDamage", zombie, result.lost, job.source, job.kind)
end

---@param job table Pending operation
---@return boolean same Native identity remains alive
local function alive(job)
    return P.living(job.zombie) and job.zombie:getOnlineID() == job.id
        and require("OMHTT/DefenseCombatProtocol").outfit(job.zombie:getPersistentOutfitID()) == job.outfit
end

---@param job table Operation at an ownership boundary
---@return nil
local function handoff(job)
    if job.phase == "commit" then
        job.phase = "query"
        local message = envelope(job)
        message.receipt = job.receipt
        sendServerCommand(job.player, P.MODULE, "Status", message)
    elseif job.phase ~= "query" then
        if job.result and not job.zombie:getOwner() then
            commitResult(job)
        elseif not dispatch(job) then
            finish(job, 0, "owner-unavailable")
        end
    end
end

---@param zombie IsoZombie Exact server victim
---@param amount number Server-calculated native damage
---@param source string Server device identity
---@param kind string Server effect family
---@param callback function? Invoked once with confirmed damage and result
---@return boolean queued
function S.request(zombie, amount, source, kind, callback, expiresAt)
    if not isServer() or not zombie or not P.living(zombie) or victims[zombie] or #order >= P.MAX_PENDING
        or not P.number(amount, 0.000001, 1000000) or zombie:isInvulnerable()
        or type(source) ~= "string" or #source == 0 or #source > 160
        or type(kind) ~= "string" or #kind == 0 or #kind > 64 or not H.allowed(zombie) then return false end
    local player = zombie:getOwnerPlayer()
    if not player or not zombie:getOwner() or player:isDead() or zombie:getOnlineID() == -1 or player:getOnlineID() == -1
        or not P.identity(player:getOnlineID()) or not P.identity(zombie:getOnlineID())
        or not P.identity(require("OMHTT/DefenseCombatProtocol").outfit(zombie:getPersistentOutfitID())) then return false end
    serial = serial + 1
    local issuedAt = GameTime.getServerTimeMills()
    local lifetime = P.contact(kind) and 500 or P.TIMEOUT
    local applyExpiresAt = issuedAt + lifetime
    if expiresAt then
        if not P.number(expiresAt, issuedAt, issuedAt + P.TIMEOUT) then return false end
        applyExpiresAt = math.min(applyExpiresAt, expiresAt)
    end
    local job = {token = session .. ":" .. serial, zombie = zombie, player = player,
        connection = zombie:getOwner(),
        id = zombie:getOnlineID(), outfit = require("OMHTT/DefenseCombatProtocol").outfit(zombie:getPersistentOutfitID()), amount = amount,
        source = source, kind = kind, lease = H.capture(zombie), callback = callback, phase = "commit", deadline = getTimestampMs() + P.TIMEOUT,
        expiresAt = issuedAt + P.TIMEOUT, applyExpiresAt = applyExpiresAt,
        index = #order + 1, started = getTimestampMs()}
    pending[job.token], victims[zombie], order[job.index] = job, job, job
    if not dispatch(job) then finish(job, 0, "consent-changed"); return false end
    return true
end

---@param module string Network namespace
---@param command string Reply kind
---@param player IsoPlayer Authenticated packet sender
---@param message table Plain acknowledgement
---@return nil
function S.command(module, command, player, message)
    if not isServer() or module ~= P.MODULE or not P.envelope(message) then return end
    local job = pending[message.token]
    if not job or job.player ~= player or message.id ~= job.id or message.outfit ~= job.outfit
        or message.sequence ~= job.sequence or message.owner ~= player:getOnlineID() then return end
    if getTimestampMs() > job.deadline or not alive(job) or not H.matches(job.zombie, job.lease) then
        finish(job, 0, (job.phase == "commit" or job.phase == "query" or job.result) and "ownership-uncertain" or "cancelled")
        return
    end
    if command == "Unapplied" and job.phase == "query" and message.receipt == job.receipt then
        if not dispatch(job) then
            finish(job, 0, "owner-unavailable")
        end
        return
    end
    if command == "Reject" then
        if current(job) then
            local reasons = {missing=true, identity=true, dead=true, ["not-owner"]=true, position=true,
                capacity=true, expired=true, invulnerable=true, health=true, cancelled=true}
            local reason = reasons[message.reason] and message.reason or "rejected"
            job.clientX = P.number(message.x, -1000000, 1000000) and message.x or nil
            job.clientY = P.number(message.y, -1000000, 1000000) and message.y or nil
            finish(job, 0, job.result and "reconciliation-failed" or reason)
        else
            handoff(job)
        end
        return
    end
    if command == "Applied" and (job.phase == "commit" or job.phase == "query") then
        if message.receipt ~= job.receipt then return end
        if not P.number(message.before, P.EPSILON, 1000000) then return end
        local after, lost, lethal = P.result(message.before, job.amount)
        if not P.number(message.after, P.EPSILON, 1000000) or math.abs(message.after - after) > 0.00001
            or message.lethal ~= lethal then return end
        job.ownerProcessingMs = P.number(message.processingMs, 0, P.TIMEOUT) and message.processingMs or nil
        job.clientX = P.number(message.x,-1000000,1000000) and message.x or nil
        job.clientY = P.number(message.y,-1000000,1000000) and message.y or nil
        job.result = {after = after, lost = lost, lethal = lethal}
        if current(job) or not job.zombie:getOwner() then
            commitResult(job)
        else
            if not dispatch(job) then
                finish(job, 0, "owner-unavailable")
            end
        end
    elseif command == "Reconciled" and job.phase == "settle-commit" then
        if message.receipt ~= job.receipt or not P.number(message.before, P.EPSILON, 1000000)
            or not P.number(message.after, P.EPSILON, 1000000)
            or math.abs(message.after - math.min(message.before, job.result.after)) > .00001 then return end
        job.result.after = math.min(job.result.after, message.after)
        if current(job) then
            commitResult(job)
        else
            handoff(job)
        end
    end
end

---@return nil
function S.tick()
    if not isServer() or #order == 0 then return end
    local now = getTimestampMs()
    for i = 1, math.min(16, #order) do
        if #order == 0 then return end
        if cursor > #order then cursor = 1 end
        local job = order[cursor]
        cursor = cursor + 1
        if now > job.deadline or not alive(job) or not H.matches(job.zombie, job.lease) then
            finish(job, 0, (job.phase == "commit" or job.phase == "query" or job.result) and "ownership-uncertain" or "cancelled")
        elseif not current(job) then
            handoff(job)
        end
    end
end

---@param zombie IsoZombie New/recycled native instance
---@return nil
function S.created(zombie)
    local job = victims[zombie]
    if job then finish(job, 0, "recycled") end
    serials[zombie] = nil
end

Events.OnClientCommand.Add(S.command)
Events.OnTick.Add(S.tick)
Events.OnZombieCreate.Add(S.created)
return S
