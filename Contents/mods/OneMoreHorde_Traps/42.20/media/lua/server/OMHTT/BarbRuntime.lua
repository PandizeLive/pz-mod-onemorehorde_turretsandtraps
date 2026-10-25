if isClient() then return end
local Horde = require("OMHTT/DefenseHorde")
local B = require("OMHTT/BarbSections")
local C = require("OMHTT/BarbContact")
local S = require("OMHTT/BarbSupport")
local F = require("OMHTT/Foundation")
local Damage = require("OMHTT/Damage")
local D = require("OMHTT/Diagnostics")
local soundAt = 0

---@param zombie IsoZombie Updated zombie
---@return nil
function B.zombie(zombie)
    if not Horde.allowed(zombie) then return end
    if #B.order == 0 or (not B.enabled() and not B.wireEnabled()) or zombie:isDead() then return end
    local square = zombie:getSquare()
    if not square then return end
    local bucket = B.nearby[F.key(square:getX(), square:getY(), square:getZ())]
    if not bucket then return end
    local started = D.enabled("traps") and getTimestampMs()
    local data = require("OMHTT/DefenseActorState").get(zombie)
    local state = data.OMHTTBarbContact
    if not state then
        state = {}
        data.OMHTTBarbContact = state
    end
    local interval = B.option("Interval", 2, .1, 60) * 1000
    local selected, source = B.contact(zombie, bucket)
    if selected then require("OMHTT/DefenseMotion").request(zombie, "slow", selected.id, B.option("MovementDivisor", 2, 1, 10)) end
    if C.step(state, B.time, B.session, selected ~= nil, interval) then
        require("OMHTT/DefenseXP").register(selected.id, selected.owner, selected.x, selected.y, selected.z)
        Damage.resolve(zombie, B.option("Damage", 10, 0, 1000) / 100, selected.id, "barbs", function(damage)
            local node = B.nodes[selected.id]
            if damage <= 0 or not node or node.record ~= selected then return end
            local now = getTimestampMs()
            if now >= soundAt then
                require("OMHTT/DefenseEffects").contact("ZombieClawChainlinkFence", zombie, .45)
                soundAt = now + 250
            end
            if S.wear(source, damage) then
                B.retire(selected)
            elseif isServer() then
                if selected.kind == "wire" then
                    B.publishWire(selected)
                else
                    local _, host = B.resolve(selected)
                    if host then S.publish(host) end
                end
            end
        end)
    end
    if started then D.measure("barb-contact", getTimestampMs() - started) end
end

Events.OnZombieUpdate.Add(B.zombie)
