local F = require("OMHTT/Foundation")
local E = {}
local serial, cursor = 0, 1
local received, order = {}, {}

---@param module string Presentation namespace
---@param command string Presentation event
---@param facts table Plain snapshot
---@return nil
function E.send(module, command, facts)
    local anchor = facts.rays and facts.rays[1] or facts
    if not anchor then return end
    local x, y = anchor.fromX or anchor.x, anchor.fromY or anchor.y
    if not x or not y then return end
    serial = serial + 1
    facts.packet = serial
    local players = getOnlinePlayers()
    local recipients = 0
    for i = 0, players:size() - 1 do
        local player = players:get(i)
        if math.abs(player:getX() - x) <= 100 and math.abs(player:getY() - y) <= 100 then
            sendServerCommand(player, module, command, facts)
            recipients = recipients + 1
        end
    end
    local diagnostics = require("OMHTT/Diagnostics")
    if module == F.MODULE and diagnostics.enabled("turrets") then
        diagnostics.defer("presentation-send", {packet = serial, command = command, id = facts.id,
            shot = facts.shot, recipients = recipients, x = x, y = y}, "turrets")
    end
end

---@param facts table Presentation snapshot
---@return boolean fresh Suppress duplicate connection delivery for split-screen recipients
function E.accept(facts)
    if not isClient() or not facts.packet then return true end
    if received[facts.packet] then return false end
    local old = order[cursor]
    if old then received[old] = nil end
    order[cursor], received[facts.packet] = facts.packet, true
    cursor = cursor % 512 + 1
    return true
end

---@param command string Presentation event
---@param facts table Plain values, plus optional local-only target
---@return nil
function E.emit(command, facts)
    if isClient() then return end
    if isServer() then
        local message = {}
        for key, value in pairs(facts) do
            if key ~= "target" then message[key] = value end
        end
        if facts.target and instanceof(facts.target, "IsoZombie") then
            message.targetId = facts.target:getOnlineID()
            message.targetOutfit = require("OMHTT/DefenseCombatProtocol").outfit(facts.target:getPersistentOutfitID())
        end
        E.send(F.MODULE, command, message)
    else
        triggerEvent("OnServerCommand", F.MODULE, command, facts)
    end
end

---@param name string Native contact sound
---@param actor IsoGameCharacter Contact position
---@param gain number Playback volume
---@return nil
function E.contact(name, actor, gain)
    if isClient() then return end
    if isServer() then
        E.send("OMHTT_ContactAudio", "Play", {sound = name, x = actor:getX(), y = actor:getY(), z = actor:getZ(), gain = gain})
    else
        local emitter = actor:getEmitter()
        local handle = emitter:playSound(name)
        emitter:setVolume(handle, gain * require("OMHTT/ControlOptions").volume())
    end
end

---@param module string Namespace
---@param command string Sound operation
---@param facts table Server values
---@return nil
function E.receive(module, command, facts)
    if not isClient() or module ~= "OMHTT_ContactAudio" or command ~= "Play" then return end
    if not E.accept(facts) then return end
    local emitter = getWorld():getFreeEmitter(facts.x, facts.y, facts.z)
    local handle = emitter:playSound(facts.sound)
    emitter:setVolume(handle, facts.gain * require("OMHTT/ControlOptions").volume())
end

Events.OnServerCommand.Add(E.receive)

return E
