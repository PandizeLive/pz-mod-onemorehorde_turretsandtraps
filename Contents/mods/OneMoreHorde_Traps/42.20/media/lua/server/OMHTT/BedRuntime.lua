local Actors = require("OMHTT/DefenseActors")
if isClient() then
    return
end
local Horde = require("OMHTT/DefenseHorde")
local B = require("OMHTT/BedSpikes")
local C = require("OMHTT/BedContact")
local F = require("OMHTT/Foundation")
local D = require("OMHTT/Diagnostics")
local Damage = require("OMHTT/Damage")
local frame = {}

---@param zombie IsoZombie Updated zombie
---@return nil
function B.zombie(zombie, position)
    if not Horde.allowed(zombie) then return end
    if B.count == 0 or not B.enabled() or not B.store or zombie:isDead() then
        return
    end
    local square = position and getCell():getGridSquare(math.floor(position.x),math.floor(position.y),position.z) or Actors.square(zombie)
    if not square then
        return
    end
    local key = F.key(square:getX(), square:getY(), square:getZ())
    if not B.nearby[key] then
        return
    end
    local started = D.enabled("traps") and getTimestampMs()
    local data = require("OMHTT/DefenseActorState").get(zombie)
    local state = data.OMHTTBedContact
    local recovery = B.option("RecoverySeconds", 5, 0, 60) * 1000
    local observedAt = getTimestampMs()
    if not state or state.session ~= B.session or not state.observedAt or observedAt - state.observedAt > 1000 then
        local protected = state and state.protectedUntil
        if protected and state.session ~= B.session then
            protected = B.time + math.max(0, math.min(recovery, protected - (state.seen or protected)))
        end
        state = {session = B.session, protectedUntil = protected}
        data.OMHTTBedContact = state
    end
    state.seen = B.time
    state.observedAt = observedAt
    local x, y = position and position.x or zombie:getX(), position and position.y or zombie:getY()
    local moving = state.x ~= nil and ((x - state.x) ^ 2 + (y - state.y) ^ 2) > 0.000001
    state.x, state.y = x, y
    local record = B.store.records[B.tiles[key]]
    local prone, down = require("OMHTT/DefenseActorState").stance(zombie)
    if position and position.ownerReport then prone, down = position.prone or position.landing, position.down or position.landing end
    frame.now, frame.recovery = B.time, recovery
    frame.prone, frame.down, frame.crawler, frame.moving = prone, down, zombie:isCrawling(), moving
    frame.bed, frame.tile, frame.x, frame.y = record and record.id, key, x, y
    local hit, roll = C.step(state, frame)
    if state.retryBed then
        if not prone or not record or record.id ~= state.retryBed or zombie:isCrawling() then
            state.retryBed, state.retryAt = nil, nil
        elseif getTimestampMs() >= state.retryAt then
            hit = true
            state.retryBed, state.retryAt = nil, nil
        end
    end
    if hit and record and #B.parts(record) == 1 then
        local amount = B.option("Damage", 20, 0, 1000)
        if record.tier == "reinforced" then
            amount = B.option("ReinforcedDamage", 50, 0, 2500)
        end
        require("OMHTT/DefenseXP").register(record.id, record.owner, record.x, record.y, record.z)
        D.defer("bed-landing", {id=record.id,victim=zombie:getOnlineID(),x=x,y=y,
            memberX=zombie:getSquare():getX(),memberY=zombie:getSquare():getY(),stance=zombie:getRealState()}, "traps")
        Damage.resolve(zombie, amount / 100, record.id, "bed-spikes", function(lost, reason)
            if lost <= 0 then
                state.retryBed, state.retryAt = record.id, getTimestampMs() + 1000
                return
            end
            state.retryBed, state.retryAt = nil, nil
            require("OMHTT/DefenseEffects").contact("SpearCraftedHit", zombie, 1)
            if B.store.records[record.id] ~= record then return end
            record.health = math.max(0, record.health - B.option("Wear", 6, 0, 1000))
            D.defer("bed-fall", {id = record.id, health = record.health, damage100 = lost * 100}, "traps")
            if record.health == 0 then B.retire(record)
            else
                local parts = B.parts(record)
                for i = 1, #parts do
                    parts[i]:setHealth(record.health)
                    if isServer() then
                        parts[i]:getModData().OMHTTBed.view.health = record.health
                        parts[i]:transmitModData()
                        parts[i]:sync()
                    end
                end
            end
        end)
    elseif roll and record and zombie:getBumpType() == "" and ZombRand(100) < B.option("TripChance", 40, 0, 100) then
        if require("OMHTT/DefenseMotion").request(zombie, "trip", record.id) then
            state.requestedUntil = B.time + 2000
        end
        D.defer("bed-trip", {id = record.id}, "traps")
    end
    if started then D.measure("bed-contact", getTimestampMs() - started, "traps") end
end

require("OMHTT/DefenseContacts").handlers.bed = B.zombie
if not isServer() then
    Events.OnZombieUpdate.Add(B.zombie)
end
