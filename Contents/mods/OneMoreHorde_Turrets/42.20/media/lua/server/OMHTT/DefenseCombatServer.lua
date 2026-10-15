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
    if job.callback then job.callback(lost, reason) end
end

---@param job table Pending operation
---@return boolean valid
local function current(job)
    local zombie = job.zombie
    return not zombie:isDead() and zombie:getOnlineID() == job.id
        and zombie:getPersistentOutfitID() == job.outfit and zombie:getOwnerPlayer() == job.player
        and zombie:getOwner() == job.connection and not job.player:isDead() and H.allowed(zombie)
end

---@param job table Authorized operation
---@return table message Plain network values only
local function envelope(job)
    return {token = job.token, id = job.id, outfit = job.outfit, owner = job.player:getOnlineID(), sequence = job.sequence}
end

---@param zombie IsoZombie Exact server victim
---@param amount number Server-calculated native damage
---@param source string Server device identity
---@param kind string Server effect family
---@param callback function? Invoked once with confirmed damage and result
---@return boolean queued
function S.request(zombie, amount, source, kind, callback)
    if not isServer() or not zombie or zombie:isDead() or victims[zombie] or #order >= P.MAX_PENDING
        or not P.number(amount, 0.000001, 1000000) or zombie:isInvulnerable()
        or type(source) ~= "string" or #source == 0 or #source > 160
        or type(kind) ~= "string" or #kind == 0 or #kind > 64 or not H.allowed(zombie) then return false end
    local player = zombie:getOwnerPlayer()
    if not player or not zombie:getOwner() or player:isDead() or zombie:getOnlineID() == -1
        or not P.identity(player:getOnlineID()) or not P.identity(zombie:getOnlineID())
        or not P.identity(zombie:getPersistentOutfitID()) then return false end
    serial = serial + 1
    local sequence = (serials[zombie] or 0) + 1
    serials[zombie] = sequence
    local job = {token = session .. ":" .. serial, sequence = sequence, zombie = zombie, player = player,
        connection = zombie:getOwner(),
        id = zombie:getOnlineID(), outfit = zombie:getPersistentOutfitID(), amount = amount,
        source = source, kind = kind, callback = callback, phase = "prepare", deadline = getTimestampMs() + P.TIMEOUT,
        index = #order + 1}
    pending[job.token], victims[zombie], order[job.index] = job, job, job
    local message = envelope(job)
    message.x, message.y, message.z = zombie:getX(), zombie:getY(), zombie:getZ()
    sendServerCommand(player, P.MODULE, "Prepare", message)
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
    if getTimestampMs() > job.deadline or not current(job) then
        finish(job, 0, job.phase == "commit" and "ownership-uncertain" or "cancelled")
        return
    end
    if command == "Reject" then finish(job, 0, "rejected"); return end
    if command == "Ready" and job.phase == "prepare" then
        if not P.token(message.receipt) then return end
        job.phase = "commit"
        job.receipt = message.receipt
        local commit = envelope(job)
        commit.amount, commit.receipt = job.amount, job.receipt
        sendServerCommand(player, P.MODULE, "Commit", commit)
    elseif command == "Applied" and job.phase == "commit" then
        if message.receipt ~= job.receipt then return end
        if not P.number(message.before, P.EPSILON, 1000000) then return end
        local after, lost, lethal = P.result(message.before, job.amount)
        if not P.number(message.after, P.EPSILON, 1000000) or math.abs(message.after - after) > 0.00001
            or message.lethal ~= lethal then return end
        -- No await between consent/finisher context and the server's actual death.
        local allowed, core, token = H.beginDamage(job.zombie, lost, job.source, job.kind, lethal)
        if not allowed then finish(job, 0, "consent-changed"); return end
        job.zombie:setHealth(math.min(job.zombie:getHealth(), after))
        if lethal then
            job.zombie:setHealth(0)
            job.zombie:Kill(nil, false)
        end
        if core then core.endDamage(job.zombie, token) end
        -- Remove before publishing to prevent reentrant callbacks from completing twice.
        finish(job, lost, "applied")
        triggerEvent("OnOMHTTDamage", job.zombie, lost, job.source, job.kind)
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
        if now > job.deadline or not current(job) then
            finish(job, 0, job.phase == "commit" and "ownership-uncertain" or "cancelled")
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
