if isClient() or isServer() then return end
local B = require("OMHTT/BarbSections")
local C = require("OMHTT/BarbContact")
local S = require("OMHTT/BarbSupport")
local F = require("OMHTT/Foundation")
local Damage = require("OMHTT/Damage")
local Movement = require("OMHTT/BarbMovement")
local D = require("OMHTT/Diagnostics")
local soundAt = 0

---@param zombie IsoZombie Updated zombie
---@return nil
function B.zombie(zombie)
    if #B.order == 0 or (not B.enabled() and not B.wireEnabled()) or zombie:isDead() then return end
    local square = zombie:getSquare()
    if not square then return end
    local bucket = B.nearby[F.key(square:getX(), square:getY(), square:getZ())]
    if not bucket then return end
    local started = D.enabled("traps") and getTimestampMs()
    local data = zombie:getModData()
    local state = data.OMHTTBarbContact
    if not state then
        state = {}
        data.OMHTTBarbContact = state
    end
    local interval = B.option("Interval", 2, .1, 60) * 1000
    local selected, source = B.contact(zombie, bucket)
    if selected then Movement.apply(zombie, B.option("MovementDivisor", 2, 1, 10)) end
    if C.step(state, B.time, B.session, selected ~= nil, interval) then
        local damage = Damage.apply(zombie, B.option("Damage", 10, 0, 1000) / 100, selected.id, "barbs", nil, nil)
        local now = getTimestampMs()
        if damage > 0 and now >= soundAt then
            local handle = zombie:getEmitter():playSound("ZombieClawChainlinkFence")
            zombie:getEmitter():setVolume(handle, 0.45)
            soundAt = now + 250
        end
        if S.wear(source, damage) then
            B.retire(selected)
        end
    end
    if started then D.measure("barb-contact", getTimestampMs() - started) end
end

Events.OnZombieUpdate.Add(B.zombie)
