-- Actual native items/actions, with synthetic square lookup. Not a mapped-world/network test.
return function(player)
    local Beds = require("OMHTT/BedSpikes")
    local Wire = require("OMHTT/BarbSections")
    require("OMHTT/BedServiceAction")
    require("OMHTT/BarbServiceAction")
    local nativeCell, nativeGetCell = getCell(), getCell
    local squares = {}
    local function key(x, y, z) return x .. ":" .. y .. ":" .. z end
    local function square(x, y)
        local result = IsoGridSquare.new(nativeCell, nil, x, y, 0)
        squares[key(x, y, 0)] = result
        return result
    end
    local bedSquare = square(20, 20)
    local firstSquare, lastSquare = square(22, 20), square(22, 21)
    local bed = IsoThumpable.new(nativeCell, bedSquare, "omhtt_barrier_01_64", false)
    local first = IsoThumpable.new(nativeCell, firstSquare, "omhtt_barrier_01_60", false)
    local last = IsoThumpable.new(nativeCell, lastSquare, "omhtt_barrier_01_72", false)
    local objects = {bed, first, last}
    for i = 1, #objects do
        local object = objects[i]
        object:getSquare():getObjects():add(object)
        object:getSquare():getSpecialObjects():add(object)
    end
    getCell = function()
        return {getGridSquare = function(_, x, y, z) return squares[key(x, y, z)] end}
    end
    Beds.onCreate({thumpable = bed, facing = "e"})
    local record = Beds.record(bed)
    bed:getModData().OMHTTBed = {id = "forged"}
    assert(Beds.record(bed) == record, "Native bed accepts forged identity")
    record.health = 17
    bed:setHealth(17)
    player:setX(20.5)
    player:setY(20.5)
    player:setZ(0)
    player:setCurrent(bedSquare)
    local repair = OMHTTBedServiceAction:new(player, bed, record.id, "Repair")
    assert(repair:getDuration() == 500 and repair:complete() and not repair:complete(), "Native bed repair without client start failed")
    assert(bed:getHealth() == 50 and record.health == 50 and bed:getModData().OMHTTBed.view.health == 50, "Native bed repair does not agree with private/snapshot health")
    local pickup = OMHTTBedServiceAction:new(player, bed, record.id, "Pickup")
    assert(pickup:getDuration() == 250 and pickup:complete() and not pickup:complete() and not Beds.record(bed), "Native bed pickup transaction replayed")
    assert(player:getInventory():getFirstType("Base.OMHTTTrapBedSpikes"), "Native bed pickup item missing")
    Wire.onWireCreate({thumpable = first})
    Wire.onWireCreate({thumpable = last})
    local paired = Wire.record(first)
    assert(paired == Wire.record(last), "Native wire did not bind both halves")
    first:getModData().OMHTTBarbFrame = {id = "forged"}
    paired.health = 12
    player:setX(22.5)
    player:setY(21.5)
    player:setCurrent(lastSquare)
    local fix = OMHTTBarbServiceAction:new(player, last, paired.id, "Repair")
    assert(fix:complete() and not fix:complete() and paired.health == 50, "Native wire repair failed")
    local remove = OMHTTBarbServiceAction:new(player, last, paired.id, "Remove")
    assert(remove:complete() and not remove:complete() and not Wire.record(first) and not Wire.record(last), "Native wire pickup did not retire both bindings exactly once")
    assert(player:getInventory():getFirstType("Base.OMHTTTrapConcertinaWire"), "Native recovered wire missing")
    local F = require("OMHTT/Foundation")
    local P = require("OMHTT/BarrierFootprint")
    require("OMHTT/BarrierServiceAction")
    local a, b = square(26, 20), square(26, 21)
    local state = {id = "native-service-barrier", kind = "barrier", x = 26, y = 20, z = 0, facing = 0,
        width = 2, placementSource = "construction", condition = 40, maxHealth = 100, observedLoss = 0, revision = 1}
    local keyA, keyB = F.key(26, 20, 0), F.key(26, 21, 0)
    local ledger = {tiles = {}, nextId = 1, tileCount = 2}
    ledger.tiles[keyA] = {device = state, x = 26, y = 20, z = 0, epoch = 1}
    ledger.tiles[keyB] = {anchor = keyA, x = 26, y = 21, z = 0, epoch = 1}
    P.initialize(ledger, {keyA, keyB})
    local barrierParts = {}
    for i = 1, 2 do
        local target = i == 1 and a or b
        local part = IsoThumpable.new(nativeCell, target, "omhtt_barrier_01_" .. (i - 1), false)
        part:setName(F.PREFIX .. state.id)
        part:setMaxHealth(100)
        part:setHealth(40)
        F.writeMarker(part, state)
        target:getObjects():add(part)
        target:getSpecialObjects():add(part)
        barrierParts[i] = part
    end
    local approach = square(25, 20)
    player:setX(25.5)
    player:setY(20.5)
    player:setCurrent(approach)
    local repairBarrier = OMHTTBarrierServiceAction:new(player, barrierParts[1], state.id, "Repair")
    assert(repairBarrier:getDuration() == 500 and repairBarrier:complete() and not repairBarrier:complete(),
        "Native server barrier repair relies on client elapsed time or replays")
    assert(barrierParts[2]:getHealth() == 100, "Native barrier partner health not repaired")
    local pickupBarrier = OMHTTBarrierServiceAction:new(player, barrierParts[2], state.id, "Pickup")
    assert(pickupBarrier:getDuration() == 250 and pickupBarrier:complete() and not pickupBarrier:complete(),
        "Native server barrier pickup failed or duplicated")
    assert(player:getInventory():getFirstType("Base.OMHTTTrapSpikeBarrier"), "Native recovered barrier missing")
    print("[OMHTT-Smoke] native-server-barrier repair=both pickup=once clientElapsed=unused mappedRemoval=not-tested")
    local buildLedger = {tiles = {}, nextId = 100, tileCount = 0}
    P.initialize(buildLedger, {})
    for x = 31, 34 do for y = 19, 23 do square(x, y) end end
    local built
    for part = 0, 1 do
        local target = squares[key(32, 20 + part, 0)]
        local object = IsoThumpable.new(nativeCell, target, "omhtt_barrier_01_" .. part, false)
        target:getObjects():add(object)
        target:getSpecialObjects():add(object)
        local info = SpriteConfigManager.GetObjectInfo("OMHTTSpikeBarrier")
        GameEntityFactory.CreateIsoObjectEntity(object, info:getScript():getParent(), true)
        require("OMHTT/Construction").onCreate({thumpable = object, character = player, facing = "e"})
        built = P.exact(object)
    end
    assert(built and #P.parts(built) == 2 and #P.colliders(built) == 4, "Native server construction did not create its paired four-edge outline")
    print("[OMHTT-Smoke] native-server-barrier-build callback=production parts=2 colliders=4 clients=0")
    getCell = nativeGetCell
    print("[OMHTT-Smoke] native-server-traps bed=repair-pickup wire=paired-repair-pickup publicMarkers=ignored clients=0 mappedRemoval=not-tested")
end
