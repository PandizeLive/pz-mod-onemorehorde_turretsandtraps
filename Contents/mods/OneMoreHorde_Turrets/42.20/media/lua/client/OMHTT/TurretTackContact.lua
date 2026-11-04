if isServer() then return end
local Horde = require("OMHTT/DefenseHorde")
local E
local P = require("OMHTT/ContactPlayer")
local Movement = require("OMHTT/BarbMovement")
local Contact = require("OMHTT/BarbContact")
local Clock = require("OMHTT/TurretClock")
local Damage

local session = tostring(getTimestampMs())

---@param player IsoPlayer Updated player
---@return nil
local function playerUpdate(player)
    if P.trapsRegistered or (isClient() and not player:isLocalPlayer()) then return end
    P.update(player, nil, E.contact(player), 2, 20, 20)
end

---@param zombie IsoZombie Updated zombie
---@return nil
local function zombieUpdate(zombie)
    if zombie:isDead() or not Horde.allowed(zombie) then return end
    -- Built wire owns overlap contact; use the same persisted timer when crossing its boundary.
    if P.barbs and P.barbs.contact(zombie) then return end
    local field = E.contact(zombie)
    if not field then return end
    Movement.apply(zombie, 2)
    local data = zombie:getModData()
    if not data.OMHTTBarbContact then data.OMHTTBarbContact = {} end
    local now, identity = getTimestampMs(), session
    if P.barbs then now, identity = P.barbs.time, P.barbs.session end
    if Contact.step(data.OMHTTBarbContact, now, identity, true, 2000) then
        Damage.resolve(zombie, field.damage / 100, field.source, "tack", function(lost)
            if lost > 0 then
                require("OMHTT/TurretSiphon").hit(zombie, field.siphon, true)
            end
        end)
    end
end

Events.OnGameStart.Add(function()
    E = require(isClient() and "OMHTT/TurretTackView" or "OMHTT/TurretProc")
    if not isClient() then Damage = require("OMHTT/Damage") end
    P.tackContact = E.contact
    if isClient() then
        require("OMHTT/DefenseContactClient").checks.tacks = function(zombie)
            local key = require("OMHTT/Foundation").key(math.floor(zombie:getX()/8), math.floor(zombie:getY()/8), math.floor(zombie:getZ()))
            return E.buckets[key] ~= nil
        end
    end
    Events.OnPlayerUpdate.Add(playerUpdate)
    if not isClient() then Events.OnZombieUpdate.Add(zombieUpdate) end
    require("OMHTT/DefenseMotion").checks.tack = function(zombie, source)
        local field = E.contact(zombie)
        if field and (source == nil or field.source == source) then return 2 end
        return nil
    end
end)
return {player = playerUpdate, zombie = zombieUpdate}
