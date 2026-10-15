local P = require("OMHTT/DefenseCombatProtocol")
local C = {}
local indexed = setmetatable({}, {__mode = "v"})
local receipts = setmetatable({}, {__mode = "k"})
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
    if isClient() and not zombie:isDead() and zombie:getOnlineID() ~= -1 then
        indexed[zombie:getOnlineID()] = zombie
    end
end

---@param zombie IsoZombie Newly created/recycled native instance
---@return nil
function C.created(zombie)
    receipts[zombie] = nil
    C.observe(zombie)
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
    if not zombie or zombie:isDead() or zombie:getOnlineID() ~= message.id
        or zombie:getPersistentOutfitID() ~= message.outfit or zombie:isRemoteZombie() then
        reply(player, "Reject", message)
        return
    end
    local prior = receipts[zombie]
    if command == "Prepare" then
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
        serial = serial + 1
        local receipt = {token = message.token, sequence = message.sequence, nonce = session .. ":" .. serial,
            expires = getTimestampMs() + P.TIMEOUT}
        receipts[zombie] = receipt
        reply(player, "Ready", message, receipt)
    elseif command == "Commit" then
        if not prior or prior.token ~= message.token or prior.sequence ~= message.sequence
            or not P.token(message.receipt) or prior.nonce ~= message.receipt then return end
        if prior.applied then reply(player, "Applied", message, prior); return end
        if getTimestampMs() > prior.expires or not P.number(message.amount, 0.000001, 1000000)
            or zombie:isInvulnerable() then reply(player, "Reject", message); return end
        local before = zombie:getHealth()
        if not P.number(before, P.EPSILON, 1000000) then reply(player, "Reject", message); return end
        local after, _, lethal = P.result(before, message.amount)
        prior.before, prior.after, prior.lethal, prior.applied = before, after, lethal, true
        zombie:setHealth(after)
        -- The server owns terminal death and Horde attribution; no player attack is fabricated.
        reply(player, "Applied", message, prior)
    end
end

Events.OnZombieCreate.Add(C.created)
Events.OnZombieUpdate.Add(C.observe)
Events.OnServerCommand.Add(C.command)
return C
