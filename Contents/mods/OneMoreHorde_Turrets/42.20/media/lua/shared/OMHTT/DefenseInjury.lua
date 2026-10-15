local P = require("OMHTT/DefenseCombatProtocol")
local I = {}
local guards = setmetatable({}, {__mode = "k"})
local serial, received = 0, {}

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
    if kind == "cut" then
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

---@param module string Server namespace
---@param command string Injury kind
---@param message table Server-selected victim and event
---@return nil
function I.receive(module, command, message)
    if not isClient() or module ~= "OMHTT_InjuryV1" or (command ~= "bruise" and command ~= "cut" and command ~= "rotaryBruise")
        or type(message) ~= "table" or not P.identity(message.id) or not P.number(message.serial, 1, 1000000000000) then return end
    for index = 0, 3 do
        local player = getSpecificPlayer(index)
        if player and player:getOnlineID() == message.id and message.serial > (received[index] or 0) then
            received[index] = message.serial
            apply(player, command)
            return
        end
    end
end

Events.OnServerCommand.Add(I.receive)
return I
