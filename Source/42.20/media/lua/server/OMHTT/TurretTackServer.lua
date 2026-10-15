if isClient() then return end
local E = require("OMHTT/TurretProc")
local Clock = require("OMHTT/TurretClock")
local Damage = require("OMHTT/Damage")
local H = require("OMHTT/DefenseHorde")
local Contact = require("OMHTT/BarbContact")
local Motion = require("OMHTT/DefenseMotion")
local S = {}
local requests = setmetatable({}, {__mode = "k"})
local session = tostring(getTimestampMs())

---@param field table Private active field
---@return table view Plain relative-time snapshot
function S.view(field)
    local now = Clock.now()
    return {id = field.id, x = field.x, y = field.y, z = field.z, radius = field.radius,
        source = field.source, remaining = math.max(0, field.expires - now), startsIn = math.max(0, field.starts - now)}
end

---@param field table Changed field
---@param removed boolean? Field expired
---@return nil
function S.publish(field, removed)
    if not isServer() then return end
    if removed then
        sendServerCommand("OMHTT_TackView", "Remove", {id = field.id})
    else
        sendServerCommand("OMHTT_TackView", "Fields", {S.view(field)})
    end
end

---@param module string Namespace
---@param command string Read-only snapshot request
---@param player IsoPlayer Authenticated sender
---@return nil
function S.command(module, command, player)
    if not isServer() or module ~= "OMHTT_TackView" or command ~= "Request" or player:isDead() then return end
    local now = getTimestampMs()
    if requests[player] and now - requests[player] < 5000 then return end
    requests[player] = now
    local fields = {}
    for i = 1, #E.fieldOrder do
        local field = E.fieldOrder[i]
        if math.abs(field.x - player:getX()) < 100 and math.abs(field.y - player:getY()) < 100 then
            fields[#fields + 1] = S.view(field)
            if #fields == 32 then
                sendServerCommand(player, "OMHTT_TackView", "Fields", fields)
                fields = {}
            end
        end
    end
    if #fields > 0 then sendServerCommand(player, "OMHTT_TackView", "Fields", fields) end
end

---@param zombie IsoZombie Server-updated contact candidate
---@return nil
function S.update(zombie)
    if not isServer() or zombie:isDead() or not H.allowed(zombie) then return end
    local barbs = rawget(_G, "OMHTT_BarbSections")
    if barbs and barbs.contact(zombie) then return end
    local field = E.contact(zombie)
    if not field then return end
    Motion.request(zombie, "slow", field.source, 2)
    local data = require("OMHTT/DefenseActorState").get(zombie)
    if not data.OMHTTBarbContact then data.OMHTTBarbContact = {} end
    local now, identity = Clock.now(), session
    if barbs then now, identity = barbs.time, barbs.session end
    if Contact.step(data.OMHTTBarbContact, now, identity, true, 2000) then
        Damage.resolve(zombie, field.damage / 100, field.source, "tack")
    end
end

Events.OnClientCommand.Add(S.command)
Events.OnZombieUpdate.Add(S.update)
return S
