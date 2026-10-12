if isClient() or isServer() then return end
local E = require("OMHTT/TurretProc")
local P = require("OMHTT/ContactPlayer")
local Movement = require("OMHTT/BarbMovement")
local Contact = require("OMHTT/BarbContact")
local Clock = require("OMHTT/TurretClock")
local Damage = require("OMHTT/Damage")
P.tackContact = E.contact
local session = tostring(getTimestampMs())

---@param player IsoPlayer Updated player
---@return nil
local function playerUpdate(player)
    if P.trapsRegistered then return end
    P.update(player, nil, E.contact(player), 2, 20, 20)
end

---@param zombie IsoZombie Updated zombie
---@return nil
local function zombieUpdate(zombie)
    if zombie:isDead() then return end
    -- Built wire owns overlap contact; use the same persisted timer when crossing its boundary.
    if P.barbs and P.barbs.contact(zombie) then return end
    local field = E.contact(zombie)
    if not field then return end
    Movement.apply(zombie, 2)
    local data = zombie:getModData()
    if not data.OMHTTBarbContact then data.OMHTTBarbContact = {} end
    local now, identity = Clock.now(), session
    if P.barbs then now, identity = P.barbs.time, P.barbs.session end
    if Contact.step(data.OMHTTBarbContact, now, identity, true, 2000) then
        Damage.apply(zombie, field.damage / 100, field.source, "tack", nil, nil)
    end
end

Events.OnPlayerUpdate.Add(playerUpdate)
Events.OnZombieUpdate.Add(zombieUpdate)
return {player = playerUpdate, zombie = zombieUpdate}
