local P = require("OMHTT/DefenseCombatProtocol")
local I = {}
local guards = setmetatable({}, {__mode = "k"})
local serial, received = 0, {}

---@param player IsoPlayer Local victim
---@param amount number Body-part health loss, at most ten
---@param chance number Scratch probability
---@return nil
local function blastInjury(player, amount, chance)
    if player:isDead() or player:isGodMod() or player:isNoClip() or player:isGhostMode() then return end
    local parts = {BodyPartType.ForeArm_L, BodyPartType.ForeArm_R, BodyPartType.UpperLeg_L, BodyPartType.UpperLeg_R}
    local part = player:getBodyDamage():getBodyPart(parts[ZombRand(#parts) + 1])
    part:AddDamage(amount)
    if ZombRand(10000) < chance * 10000 then
        part:setScratched(true, true)
    end
end

---@param player IsoPlayer Server-selected collateral victim
---@param amount number Bounded injury
---@param chance number Bounded scratch probability
---@return nil
function I.blast(player, amount, chance)
    if isClient() or amount <= 0 or player:isDead() or player:isGodMod() or player:isNoClip() or player:isGhostMode() then return end
    amount, chance = math.min(10, amount), math.max(0, math.min(.5, chance))
    if isServer() then
        serial = serial + 1
        sendServerCommand(player, "OMHTT_InjuryV1", "blast", {id = player:getOnlineID(), serial = serial, amount = amount, chance = chance})
    else
        blastInjury(player, amount, chance)
    end
end

---@param player IsoPlayer Local victim
---@param kind string bruise or cut
---@return nil
local function apply(player, kind)
    if player:isDead() or player:isGodMod() or player:isNoClip() or player:isGhostMode() then return end
    local parts = {BodyPartType.ForeArm_L, BodyPartType.ForeArm_R, BodyPartType.UpperLeg_L, BodyPartType.UpperLeg_R}
    if kind == "bruise" then
        parts = {BodyPartType.ForeArm_L, BodyPartType.ForeArm_R, BodyPartType.LowerLeg_L, BodyPartType.LowerLeg_R}
    end
    local part = player:getBodyDamage():getBodyPart(parts[ZombRand(#parts) + 1])
    if kind == "scratch" then
        player:getBodyDamage():getBodyPart(ZombRand(2) == 0 and BodyPartType.LowerLeg_L or BodyPartType.LowerLeg_R):setScratched(true, true)
    elseif kind == "cut" then
        part:setCut(true, true)
    else
        part:AddDamage(2)
        part:setAdditionalPain(math.min(100, part:getAdditionalPain() + 5))
    end
end

---@param player IsoPlayer Server-validated contact victim
---@param kind string bruise or cut
---@param interval number Milliseconds between injuries
---@return nil
function I.request(player, kind, interval)
    if not isServer() or player:isDead() or player:isGodMod() or player:isNoClip() or player:isGhostMode() then return end
    local now = getTimestampMs()
    local guard = guards[player]
    if not guard then guard = {}; guards[player] = guard end
    local group = kind == "bruise" and "burst" or "rotary"
    if guard[group] and now < guard[group] then return end
    guard[group] = now + interval
    serial = serial + 1
    sendServerCommand(player, "OMHTT_InjuryV1", kind, {id = player:getOnlineID(), serial = serial})
end

function I.poke(player, kind)
    if isClient() or player:isDead() or player:isGodMod() or player:isNoClip() or player:isGhostMode() then return end
    if isServer() then
        serial = serial + 1
        sendServerCommand(player, "OMHTT_InjuryV1", kind, {id = player:getOnlineID(), serial = serial})
    else
        apply(player, kind)
    end
end

---@param module string Server namespace
---@param command string Injury kind
---@param message table Server-selected victim and event
---@return nil
function I.receive(module, command, message)
    if not isClient() or module ~= "OMHTT_InjuryV1" or (command ~= "bruise" and command ~= "scratch" and command ~= "cut" and command ~= "rotaryBruise" and command ~= "blast")
        or type(message) ~= "table" or not P.identity(message.id) or not P.number(message.serial, 1, 1000000000000) then return end
    if command == "blast" and (not P.number(message.amount, 0, 10) or not P.number(message.chance, 0, .5)) then return end
    for index = 0, 3 do
        local player = getSpecificPlayer(index)
        if player and player:getOnlineID() == message.id and message.serial > (received[index] or 0) then
            received[index] = message.serial
            if command == "blast" then
                blastInjury(player, message.amount, message.chance)
            else
                apply(player, command)
            end
            return
        end
    end
end

Events.OnServerCommand.Add(I.receive)
return I
