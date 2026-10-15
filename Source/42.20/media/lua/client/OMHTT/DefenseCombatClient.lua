local P = require("OMHTT/DefenseCombatProtocol")
local C = {}
local indexed = setmetatable({}, {__mode = "v"})
local receipts = setmetatable({}, {__mode = "k"})
local history, historyOrder, historyCursor = {}, {}, 1
local session, serial = tostring(getTimestampMs()), 0

---@param id number Server-selected owner
---@return IsoPlayer? player Local connection player
local function owner(id)
    for i = 0, 3 do
        local player = getSpecificPlayer(i)
        if player and player:getOnlineID() == id then return player end
    end
end

---@param player IsoPlayer Actual local owner
---@param command string Reply type
---@param message table Exact authorized operation
---@param receipt table? Applied result
---@return nil
local function reply(player, command, message, receipt)
    local result = {token = message.token, id = message.id, outfit = message.outfit,
        owner = message.owner, sequence = message.sequence}
    if receipt then
        result.receipt = receipt.nonce
        if receipt.applied then
            result.before, result.after, result.lethal = receipt.before, receipt.after, receipt.lethal
        end
    end
    sendClientCommand(player, P.MODULE, command, result)
end

---@param zombie IsoZombie Native observed instance
---@return nil
function C.observe(zombie)
    if not isClient() or zombie:isDead() then return end
    local id = zombie:getOnlineID()
    if id ~= -1 and indexed[id] ~= zombie then
        indexed[id] = zombie
    end
end

---@param zombie IsoZombie Newly created/recycled native instance
---@return nil
function C.created(zombie)
    receipts[zombie] = nil
    C.observe(zombie)
end

---@return nil
function C.expire()
    if not isClient() then return end
    local now = getTimestampMs()
    for _ = 1, math.min(16, #historyOrder) do
        if historyCursor > #historyOrder then historyCursor = 1 end
        local receipt = historyOrder[historyCursor]
        if now > receipt.retainedUntil then
            if history[receipt.token] == receipt then
                history[receipt.token] = nil
            end
            historyOrder[historyCursor] = historyOrder[#historyOrder]
            historyOrder[#historyOrder] = nil
        else
            historyCursor = historyCursor + 1
        end
    end
end

---@param module string Server namespace
---@param command string Server operation
---@param message table Server-authorized values
---@return nil
function C.command(module, command, message)
    if not isClient() or module ~= P.MODULE or not P.envelope(message) then return end
    local player = owner(message.owner)
    if not player then return end
    local zombie = indexed[message.id]
    local saved = history[message.token]
    local prior = zombie and receipts[zombie]
    if command == "Status" then prior = saved end
    if command == "Status" and prior and prior.token == message.token and prior.sequence == message.sequence
        and prior.nonce == message.receipt and prior.id == message.id
        and prior.outfit == message.outfit and prior.owner == message.owner then
        if not prior.applied then
            prior.cancelled = true
        end
        reply(player, prior.applied and "Applied" or "Unapplied", message, prior)
        return
    end
    if not zombie or zombie:isDead() or zombie:getOnlineID() ~= message.id
        or zombie:getPersistentOutfitID() ~= message.outfit or zombie:isRemoteZombie() then
        reply(player, "Reject", message)
        return
    end
    if command == "Prepare" then
        -- A recycled/unloaded actor must never turn an old operation into a new application.
        if saved and saved.sequence == message.sequence then
            if saved.id == message.id and saved.outfit == message.outfit and saved.owner == message.owner then
                local response = "Reject"
                if saved.applied then
                    response = saved.reconciled and "Reconciled" or "Applied"
                elseif saved == prior and not saved.cancelled then
                    response = "Ready"
                end
                reply(player, response, message, saved)
            end
            return
        end
        if not P.number(message.x, -1000000, 1000000) or not P.number(message.y, -1000000, 1000000)
            or not P.number(message.z, -32, 32) or math.abs(zombie:getZ() - message.z) > .5
            or (zombie:getX() - message.x) ^ 2 + (zombie:getY() - message.y) ^ 2 > 64 then
            reply(player, "Reject", message)
            return
        end
        if prior and message.sequence <= prior.sequence then
            if prior.token == message.token then
                reply(player, prior.applied and "Applied" or "Ready", message, prior)
            end
            return
        end
        if #historyOrder >= P.MAX_PENDING * 4 then
            reply(player, "Reject", message)
            return
        end
        serial = serial + 1
        local receipt = {token = message.token, sequence = message.sequence, nonce = session .. ":" .. serial,
            id = message.id, outfit = message.outfit, owner = message.owner,
            expires = getTimestampMs() + P.TIMEOUT, retainedUntil = getTimestampMs() + P.TIMEOUT * 2}
        receipts[zombie] = receipt
        history[message.token] = receipt
        historyOrder[#historyOrder + 1] = receipt
        reply(player, "Ready", message, receipt)
    elseif command == "Commit" or command == "Reconcile" then
        if not prior or prior.cancelled or prior.token ~= message.token or prior.sequence ~= message.sequence
            or not P.token(message.receipt) or prior.nonce ~= message.receipt then return end
        if prior.applied then reply(player, prior.reconciled and "Reconciled" or "Applied", message, prior); return end
        if command == "Reconcile" then
            if getTimestampMs() > prior.expires or not P.number(message.health, P.EPSILON, 1000000) then return end
            prior.before = zombie:getHealth()
            prior.after = math.min(prior.before, message.health)
            prior.lethal, prior.applied, prior.reconciled = false, true, true
            zombie:setHealth(prior.after)
            zombie:getNetworkCharacterAI():extraUpdate()
            reply(player, "Reconciled", message, prior)
            return
        end
        if getTimestampMs() > prior.expires or not P.number(message.amount, 0.000001, 1000000)
            or zombie:isInvulnerable() then reply(player, "Reject", message); return end
        local before = zombie:getHealth()
        if not P.number(before, P.EPSILON, 1000000) then reply(player, "Reject", message); return end
        local after, _, lethal = P.result(before, message.amount)
        prior.before, prior.after, prior.lethal, prior.applied = before, after, lethal, true
        zombie:setHealth(after)
        zombie:getNetworkCharacterAI():extraUpdate()
        -- The server owns terminal death and Horde attribution; no player attack is fabricated.
        reply(player, "Applied", message, prior)
    end
end

Events.OnZombieCreate.Add(C.created)
Events.OnTick.Add(C.expire)
Events.OnZombieUpdate.Add(C.observe)
Events.OnServerCommand.Add(C.command)
return C
