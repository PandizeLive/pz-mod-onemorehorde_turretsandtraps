local P = require("OMHTT/DefenseCombatProtocol")
local C = {}
local indexed = setmetatable({}, {__mode = "v"})
local createdAt = setmetatable({}, {__mode = "k"})
local receipts = setmetatable({}, {__mode = "k"})
local history, historyOrder, historyCursor = {}, {}, 1

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
            result.processingMs = receipt.processingMs
            result.x, result.y = receipt.x, receipt.y
        end
    end
    sendClientCommand(player, P.MODULE, command, result)
end

local function reject(player, message, reason, zombie)
    local result = {token = message.token, id = message.id, outfit = message.outfit,
        owner = message.owner, sequence = message.sequence, reason = reason}
    if zombie then
        result.x, result.y, result.z = zombie:getX(), zombie:getY(), zombie:getZ()
        result.actualOutfit = P.outfit(zombie:getPersistentOutfitID())
        result.remote, result.health = zombie:isRemoteZombie(), zombie:getHealth()
    end
    sendClientCommand(player, P.MODULE, "Reject", result)
    local D = require("OMHTT/Diagnostics")
    D.count("combat-reject-" .. reason, 1)
    D.defer("combat-reject", result)
end

-- Presentation and combat resolve the same live identity, never a recycled ID.
function C.find(id, outfit)
    local zombie = indexed[id]
    if P.living(zombie) and zombie:getOnlineID() == id and P.outfit(zombie:getPersistentOutfitID()) == outfit then return zombie end
end

---@param zombie IsoZombie Native observed instance
---@return nil
function C.observe(zombie)
    if not isClient() or not P.living(zombie) then return end
    local id = zombie:getOnlineID()
    if id ~= -1 and indexed[id] ~= zombie then
        indexed[id] = zombie
        createdAt[zombie] = GameTime.getServerTimeMills()
    end
end

---@param zombie IsoZombie Newly created/recycled native instance
---@return nil
function C.created(zombie)
    receipts[zombie] = nil
    createdAt[zombie] = GameTime.getServerTimeMills()
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
    if not player or player:isDead() then return end
    local zombie = indexed[message.id]
    local saved = history[message.token]
    local prior = zombie and receipts[zombie]
    if command ~= "Apply" and command ~= "Reconcile" and command ~= "Status" then return end
    if not P.token(message.receipt) then return end
    local started = getTimestampMs()
    -- Status is a cancellation barrier even when it overtakes the initial Apply.
    if command == "Status" then
        if saved and saved.sequence == message.sequence and saved.nonce == message.receipt then
            if not saved.applied then saved.cancelled = true end
            reply(player, saved.applied and "Applied" or "Unapplied", message, saved)
        elseif not saved or saved.sequence < message.sequence then
            if #historyOrder >= P.MAX_PENDING * 4 then return end
            saved = {token=message.token, sequence=message.sequence, nonce=message.receipt,
                id=message.id, outfit=message.outfit, owner=message.owner, cancelled=true,
                retainedUntil=started + P.TIMEOUT*2}
            history[message.token], historyOrder[#historyOrder+1] = saved, saved
            if zombie and (not prior or prior.sequence < message.sequence) then receipts[zombie]=saved end
            reply(player, "Unapplied", message, saved)
        end
        return
    end
    if saved and saved.sequence == message.sequence then
        if saved.id ~= message.id or saved.outfit ~= message.outfit or saved.owner ~= message.owner
            or saved.nonce ~= message.receipt then return end
        if saved.applied then reply(player, saved.reconciled and "Reconciled" or "Applied", message, saved)
        else reject(player, message, "cancelled", zombie) end
        return
    end
    local reason
    if not zombie then reason="missing"
    elseif zombie:getOnlineID() ~= message.id or P.outfit(zombie:getPersistentOutfitID()) ~= message.outfit then reason="identity"
    elseif not P.living(zombie) then reason="dead"
    elseif zombie:isRemoteZombie() then reason="not-owner"
    elseif zombie:isInvulnerable() then reason="invulnerable" end
    if reason then reject(player,message,reason,zombie); return end
    local serverNow = GameTime.getServerTimeMills()
    if serverNow <= 0 or not P.number(message.issuedAt, 1, 1000000000000000)
        or not P.number(message.expiresAt, message.issuedAt, message.issuedAt + P.TIMEOUT)
        or serverNow > message.expiresAt then reject(player,message,"expired",zombie); return end
    if command == "Apply" and message.issuedAt < (createdAt[zombie] or serverNow) then reject(player,message,"identity",zombie); return end
    if prior and message.sequence <= prior.sequence then reject(player,message,"cancelled",zombie); return end
    if not P.number(message.x,-1000000,1000000) or not P.number(message.y,-1000000,1000000)
        or not P.number(message.z,-32,32) or math.abs(zombie:getZ()-message.z)>.5
        or (zombie:getX()-message.x)^2+(zombie:getY()-message.y)^2>64 then reject(player,message,"position",zombie); return end
    if #historyOrder >= P.MAX_PENDING*4 then reject(player,message,"capacity",zombie); return end
    local before=zombie:getHealth()
    if not P.number(before,P.EPSILON,1000000) then reject(player,message,"health",zombie); return end
    local after,lost,lethal
    if command=="Reconcile" then
        if not P.number(message.health,P.EPSILON,1000000) then return end
        after,lethal=math.min(before,message.health),false
    else
        if not P.number(message.amount,.000001,1000000) then return end
        after,lost,lethal=P.result(before,message.amount)
    end
    local receipt={token=message.token,sequence=message.sequence,nonce=message.receipt,
        id=message.id,outfit=message.outfit,owner=message.owner,applied=true,
        reconciled=command=="Reconcile",before=before,after=after,lethal=lethal,
        x=zombie:getX(),y=zombie:getY(),
        retainedUntil=started+P.TIMEOUT*2}
    receipts[zombie],history[message.token]=receipt,receipt
    historyOrder[#historyOrder+1]=receipt
    zombie:setHealth(after)
    receipt.processingMs=getTimestampMs()-started
    reply(player,receipt.reconciled and "Reconciled" or "Applied",message,receipt)
end

Events.OnZombieCreate.Add(C.created)
Events.OnTick.Add(C.expire)
Events.OnZombieUpdate.Add(C.observe)
Events.OnServerCommand.Add(C.command)
return C
