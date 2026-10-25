local P = require("OMHTT/DefenseCombatProtocol")
local I = {}
local guards = setmetatable({}, {__mode = "k"})
local serial, received = 0, {}
local session = tostring(getTimestampMs())
local pending = setmetatable({}, {__mode = "k"})

---@param player IsoPlayer Server-selected victim
---@param message table Bounded injury command
---@param source string|nil Server device identity
---@return nil
local function prepareXP(player, message, source)
    local credit = rawget(_G, "OMHTS_DefenseCredit")
    if not credit or credit.API_VERSION ~= 1 or type(source) ~= "string" then return end
    local owner = require("OMHTT/DefenseXP").owner(source)
    if not owner then return end
    local jobs = pending[player]
    if not jobs then
        jobs = {}
        pending[player] = jobs
    end
    local now = getTimestampMs()
    local count = 0
    for token, job in pairs(jobs) do
        if now > job.deadline then
            jobs[token] = nil
        else
            count = count + 1
        end
    end
    if count >= 256 then return end
    local token = session .. ":" .. message.serial
    message.xpToken = token
    jobs[token] = {owner = owner, deadline = now + 5000}
    credit.beginInjury(player, token)
end

---@param player IsoPlayer Local victim
---@return table|nil before Optional installed Trait Shop evidence
local function beforeXP(player)
    if not getActivatedMods():contains("OneMoreHorde_TraitShop") then return nil end
    if not isClient() then
        require("OMHTT/DefenseXP").beforeInjury(player)
    end
    return require("OMHTS_InjuryEvidence").capture(player)
end

---@param player IsoPlayer Local victim
---@param before table|nil Before state
---@param source string|nil SP source
---@return boolean injured
local function afterXP(player, before, source)
    if not before then return false end
    local evidence = require("OMHTS_InjuryEvidence")
    local injured = evidence.injured(before, evidence.capture(player))
    if injured then
        player:setAttackedBy(nil)
    end
    if injured and not isClient() then
        require("OMHTT/DefenseXP").injury(player, source)
    end
    return injured
end

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
    if kind == "scratch" then
        player:getBodyDamage():getBodyPart(ZombRand(2) == 0 and BodyPartType.LowerLeg_L or BodyPartType.LowerLeg_R):setScratched(true, true)
    else
        if kind == "fall" then
            parts = {BodyPartType.LowerLeg_L, BodyPartType.LowerLeg_R, BodyPartType.ForeArm_L, BodyPartType.ForeArm_R}
        end
        local part = player:getBodyDamage():getBodyPart(parts[ZombRand(#parts) + 1])
        if kind == "cut" or kind == "fall" then
            part:setCut(true, true)
        else
            part:AddDamage(2)
            part:setAdditionalPain(math.min(100, part:getAdditionalPain() + 5))
        end
    end
end

---@param player IsoPlayer Server-validated contact victim
---@param kind string bruise or cut
---@param interval number Milliseconds between injuries
---@return nil
function I.request(player, kind, interval)
    if not isServer() or player:isDead() or player:isGodMod() or player:isNoClip() or player:isGhostMode() then return end
    local now = require("OMHTT/ControlClock").now()
    local guard = guards[player]
    if not guard then guard = {}; guards[player] = guard end
    local group = kind == "bruise" and "burst" or "rotary"
    if guard[group] and now < guard[group] then return end
    guard[group] = now + interval
    serial = serial + 1
    sendServerCommand(player, "OMHTT_InjuryV1", kind, {id = player:getOnlineID(), serial = serial})
end

function I.poke(player, kind, source)
    if isClient() or player:isDead() or player:isGodMod() or player:isNoClip() or player:isGhostMode() then return end
    if isServer() then
        serial = serial + 1
        local message = {id = player:getOnlineID(), serial = serial, session = session}
        prepareXP(player, message, source)
        sendServerCommand(player, "OMHTT_InjuryV1", kind, message)
    else
        local before = beforeXP(player)
        apply(player, kind)
        afterXP(player, before, source)
    end
end

---@param player IsoPlayer Local contact recipient
---@param source string|nil Passive defense identity
---@param kind string Locally selected native injury
---@return nil
function I.contact(player, source, kind)
    if kind ~= "scratch" and kind ~= "fall" then return end
    if isClient() then
        if not player:isLocalPlayer() then return end
        sendClientCommand(player, "OMHTT_InjuryV1", "Contact", {source = source, kind = kind})
    else
        I.poke(player, kind, source)
    end
end

---@param player IsoPlayer Local victim
---@param partIndex number Selected limb index
---@param amount number Server-validated damage after armor
---@param wound string none, scratch or cut
---@return nil
local function turretInjury(player, partIndex, amount, wound)
    if player:isDead() or player:isGodMod() or player:isNoClip() or player:isGhostMode() then return end
    local part = player:getBodyDamage():getBodyPart(BodyPartType.FromIndex(partIndex))
    part:AddDamage(amount)
    if wound == "scratch" then
        part:setScratched(true, true)
    elseif wound == "cut" then
        part:setCut(true, true)
    end
end

---@param player IsoPlayer Server-selected victim
---@param part number Limb index
---@param amount number Fixed injury after armor
---@param wound string Server-selected injury
---@return nil
function I.turret(player, part, amount, wound, source)
    if isClient() then return end
    if isServer() then
        serial = serial + 1
        local message = {id = player:getOnlineID(), serial = serial, session = session,
            part = part, amount = amount, wound = wound}
        prepareXP(player, message, source)
        sendServerCommand(player, "OMHTT_InjuryV1", "turret", message)
    else
        local before = beforeXP(player)
        turretInjury(player, part, amount, wound)
        afterXP(player, before, source)
    end
end

---@param module string Server namespace
---@param command string Injury kind
---@param message table Server-selected victim and event
---@return nil
function I.receive(module, command, message)
    if not isClient() or module ~= "OMHTT_InjuryV1" or (command ~= "bruise" and command ~= "scratch" and command ~= "cut" and command ~= "fall" and command ~= "rotaryBruise" and command ~= "blast" and command ~= "turret")
        or type(message) ~= "table" or not P.identity(message.id) or not P.number(message.serial, 1, 1000000000000) then return end
    if command == "blast" and (not P.number(message.amount, 0, 10) or not P.number(message.chance, 0, .5)) then return end
    if command == "turret" then
        if not P.number(message.amount, 0, 500) or not P.number(message.part, 0, 16)
            or message.part ~= math.floor(message.part)
            or (message.wound ~= "none" and message.wound ~= "scratch" and message.wound ~= "cut") then return end
        local part = BodyPartType.FromIndex(message.part)
        if part ~= BodyPartType.ForeArm_L and part ~= BodyPartType.ForeArm_R
            and part ~= BodyPartType.UpperLeg_L and part ~= BodyPartType.UpperLeg_R then return end
    end
    for index = 0, 3 do
        local player = getSpecificPlayer(index)
        local receipt = received[index]
        if player and player:getOnlineID() == message.id and (not receipt
            or receipt.session ~= message.session or message.serial > receipt.serial) then
            received[index] = {serial = message.serial, session = message.session}
            local before
            if message.xpToken then
                before = beforeXP(player)
            end
            if command == "turret" then
                turretInjury(player, message.part, message.amount, message.wound)
            elseif command == "blast" then
                blastInjury(player, message.amount, message.chance)
            else
                apply(player, command)
            end
            if message.xpToken then
                sendClientCommand(player, "OMHTT_InjuryV1", "Applied", {
                    token = message.xpToken, injured = afterXP(player, before)})
            end
            return
        end
    end
end

---@param module string Network namespace
---@param command string Receipt command
---@param player IsoPlayer Authenticated sender
---@param message table Receipt only; no owner or XP accepted
---@return nil
function I.acknowledge(module, command, player, message)
    if not isServer() or module ~= "OMHTT_InjuryV1" or type(message) ~= "table" then return end
    if command == "Contact" then
        if type(message.source) ~= "string" or #message.source > 160
            or (message.kind ~= "scratch" and message.kind ~= "fall")
            or not require("OMHTT/DefenseXP").contact(player, message.source) then return end
        local now = require("OMHTT/ControlClock").now()
        local guard = guards[player]
        if not guard then
            guard = {}
            guards[player] = guard
        end
        if guard.passive and now < guard.passive then return end
        guard.passive = now + 5000
        I.poke(player, message.kind, message.source)
        return
    end
    if command ~= "Applied" or type(message.token) ~= "string"
        or type(message.injured) ~= "boolean" then return end
    local jobs = pending[player]
    local job = jobs and jobs[message.token]
    if not job then return end
    jobs[message.token] = nil
    local credit = rawget(_G, "OMHTS_DefenseCredit")
    if not credit or credit.API_VERSION ~= 1 then return end
    credit.finishInjury(player, message.token, job.owner,
        message.injured and getTimestampMs() <= job.deadline)
end

Events.OnServerCommand.Add(I.receive)
Events.OnClientCommand.Add(I.acknowledge)
return I
