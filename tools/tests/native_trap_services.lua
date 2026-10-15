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
    getCell = nativeGetCell
    print("[OMHTT-Smoke] native-server-traps bed=repair-pickup wire=paired-repair-pickup publicMarkers=ignored clients=0 mappedRemoval=not-tested")
end
