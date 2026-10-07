if isClient() or isServer() then
    return
end
local B = require("OMHTT/BedSpikes")
local C = require("OMHTT/BedContact")
local F = require("OMHTT/Foundation")
local D = require("OMHTT/Diagnostics")
local Damage = require("OMHTT/Damage")
local frame = {}

---@param zombie IsoZombie Updated zombie
---@return nil
function B.zombie(zombie)
    if B.count == 0 or not B.enabled() or not B.store or zombie:isDead() then
        return
    end
    local square = zombie:getSquare()
    if not square then
        return
    end
    local key = F.key(square:getX(), square:getY(), square:getZ())
    if not B.nearby[key] then
        return
    end
    local data = zombie:getModData()
    local state = data.OMHTTBedContact
    local recovery = B.option("RecoverySeconds", 5, 0, 60) * 1000
    if not state or state.session ~= B.session or not state.seen or B.time - state.seen > 1000 then
        local protected = state and state.protectedUntil
        if protected and state.session ~= B.session then
            protected = B.time + math.max(0, math.min(recovery, protected - (state.seen or protected)))
        end
        state = {session = B.session, protectedUntil = protected}
        data.OMHTTBedContact = state
    end
    state.seen = B.time
    local x, y = zombie:getX(), zombie:getY()
    local moving = state.x ~= nil and ((x - state.x) ^ 2 + (y - state.y) ^ 2) > 0.000001
    state.x, state.y = x, y
    local record = B.store.records[B.tiles[key]]
    local down = zombie:isKnockedDown() or zombie:isRagdoll() or zombie:isGettingUp()
    frame.now, frame.recovery = B.time, recovery
    frame.prone, frame.down, frame.crawler, frame.moving = zombie:isOnFloor(), down, zombie:isCrawling(), moving
    frame.bed, frame.tile, frame.x, frame.y = record and record.id, key, x, y
    local hit, roll = C.step(state, frame)
    if hit and record and #B.parts(record) == 2 then
        local amount = B.option("Damage", 20, 0, 1000)
        if record.tier == "reinforced" then
            amount = B.option("ReinforcedDamage", 50, 0, 2500)
        end
        Damage.apply(zombie, amount / 100, record.id, "bed-spikes", nil, nil)
        record.health = math.max(0, record.health - B.option("Wear", 6, 0, 1000))
        D.defer("bed-fall", {id = record.id, health = record.health, damage100 = amount})
        if record.health == 0 then
            B.retire(record)
        else
            local parts = B.parts(record)
            for i = 1, #parts do parts[i]:setHealth(record.health) end
        end
    elseif roll and record and zombie:getBumpType() == "" and ZombRand(100) < B.option("TripChance", 20, 0, 100) then
        zombie:setBumpType("trippingFromSprint")
        state.requestedUntil = B.time + 2000
        D.defer("bed-trip", {id = record.id})
    end
end

Events.OnZombieUpdate.Add(B.zombie)
