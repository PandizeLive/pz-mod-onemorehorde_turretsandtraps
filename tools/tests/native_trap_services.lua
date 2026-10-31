-- Actual native items/actions, with synthetic square lookup. Not a mapped-world/network test.
return function(player)
    if EXPECT_READ then
        local serviceFixture = ModData.getOrCreate("OMHTTNativeServiceC369")
        local servicePacked = ModData.getOrCreate("OMHTTDefenseNamesV1").packed[serviceFixture.item]
        assert(servicePacked and servicePacked.health == 13 and servicePacked.maxHealth == 50,
            "Fresh process lost exact private trap condition")
        print("[OMHTT-C369] private-condition fresh-process=preserved")
    end
    local Beds = require("OMHTT/BedSpikes")
    local Wire = require("OMHTT/BarbSections")
    require("OMHTT/BedServiceAction")
    require("OMHTT/BarbServiceAction")
    local nativeCell, nativeGetCell = getCell(), getCell
    local squares = {}
    local function key(x, y, z) return x .. ":" .. y .. ":" .. z end
    local function square(x, y)
        local result = IsoGridSquare.new(nativeCell, nil, x, y, 0)
        local chunk = IsoChunk.new(nativeCell)
        chunk:assignLoadID()
        chunk:setSquare(x % 8, y % 8, 0, result)
        assert(result:getChunk() == chunk, "Fixture square needs native chunk ownership")
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
        return {getZombieList = function() return nativeCell:getZombieList() end, getGridSquare = function(_, x, y, z) return squares[key(x, y, z)] end}
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
    player:getInventory():AddItem("Base.Plank")
    player:getInventory():AddItem("Base.Hammer")
    local repair = OMHTTBedServiceAction:new(player, bed, record.id, "Repair")
    assert(repair:getDuration() == 200 and repair:complete() and not repair:complete(), "Native bed repair without client start failed")
    assert(bed:getHealth() == 50 and record.health == 50 and bed:getModData().OMHTTBed.view.health == 50, "Native bed repair does not agree with private/snapshot health")
    local pickup = OMHTTBedServiceAction:new(player, bed, record.id, "Pickup")
    assert(pickup:getDuration() == 100 and pickup:complete() and not pickup:complete() and not Beds.record(bed), "Native bed pickup transaction replayed")
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
    player:getInventory():AddItem("Base.ScrapMetal")
    player:getInventory():AddItem("Base.Pliers")
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
    player:getInventory():AddItem("Base.Plank")
    player:getInventory():AddItem("Base.Hammer")
    local repairBarrier = OMHTTBarrierServiceAction:new(player, barrierParts[1], state.id, "Repair")
    assert(repairBarrier:getDuration() == 200 and repairBarrier:complete() and not repairBarrier:complete(),
        "Native server barrier repair relies on client elapsed time or replays")
    assert(barrierParts[2]:getHealth() == F.barrierHealth(state), "Native barrier partner health not repaired")
    local pickupBarrier = OMHTTBarrierServiceAction:new(player, barrierParts[2], state.id, "Pickup")
    assert(pickupBarrier:getDuration() == 100 and pickupBarrier:complete() and not pickupBarrier:complete(),
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
    local panelSquare = square(36, 20)
    local window = IsoWindow.new(nativeCell, panelSquare, getSprite("fixtures_windows_01_0"), false)
    panelSquare:getObjects():add(window)
    panelSquare:getSpecialObjects():add(window)
    local temporary = IsoThumpable.new(nativeCell, panelSquare, "omhtt_barrier_01_52", false)
    panelSquare:getObjects():add(temporary)
    panelSquare:getSpecialObjects():add(temporary)
    local initialGlass = window:getHealth()
    local panel = Wire.onCreate({thumpable = temporary, facing = "e"}).object
    local panelRecord = Wire.record(panel)
    local Support = require("OMHTT/BarbSupport")
    local attachment = Support.record(window, false, panelRecord.side)
    assert(attachment and attachment.health == 50 and window:getHealth() == initialGlass, "Native panel changed glass health")
    window:getModData().OMHTTBarbs = {}
    panel:getModData().OMHTTBarbFrame = {id = "forged"}
    assert(Wire.record(panel) == panelRecord and Support.attachment(window, false, panelRecord.side) == panelRecord.id,
        "Native panel accepts public metadata as authority")
    Wire.initialize()
    Wire.loaded(panelSquare)
    panelRecord = Wire.record(panel)
    attachment = Support.record(window, false, panelRecord.side)
    assert(attachment and attachment.health == 50, "Native panel private bindings did not survive registry reload")
    attachment.health = 13
    player:getInventory():AddItem(instanceItem("Base.Hammer"))
    player:getInventory():AddItem(instanceItem("Base.Pliers"))
    player:setX(36.5)
    player:setY(20.5)
    player:setCurrent(panelSquare)
    player:getInventory():AddItem("Base.ScrapMetal")
    player:getInventory():AddItem("Base.Pliers")
    local panelFix = OMHTTBarbServiceAction:new(player, panel, panelRecord.id, "Repair")
    assert(panelFix:complete() and not panelFix:complete() and attachment.health == 50, "Native panel repair failed")
    local panelRemove = OMHTTBarbServiceAction:new(player, panel, panelRecord.id, "Remove")
    assert(panelRemove:complete() and not panelRemove:complete() and not Wire.record(panel), "Native panel retirement failed")
    assert(window:getHealth() == initialGlass, "Native panel service changed supporting glass health")
    print("[OMHTT-Smoke] native-server-panel construct=production repair=once removal=once glass=unchanged publicMarkers=ignored clients=0")
    local Names = require("OMHTT/DefenseNames")
    local fresh = instanceItem("Base.OMHTTTrapBedSpikes")
    local worn = instanceItem("Base.OMHTTTrapBedSpikes")
    Names.pack({id = "native-worn-bed", health = 17, maxHealth = 50}, worn)
    local mixed = ArrayList.new()
    mixed:add(fresh)
    mixed:add(worn)
    local mixedData = {getAllConsumedItems = function() return mixed end}
    -- Reverse native callbacks must still select the corresponding input, including fresh first.
    for part = 1, 0, -1 do
        local tile = square(50 + Beds.store.nextId * 2, 50 + part)
        local object = IsoThumpable.new(nativeCell, tile, "omhtt_barrier_01_" .. (36 + part), false)
        tile:getObjects():add(object)
        tile:getSpecialObjects():add(object)
        Beds.onCreate({thumpable = object, facing = "e", craftRecipeData = mixedData})
        assert(Beds.record(object).health == (part == 0 and 50 or 17), "Mixed Bed inputs lost exact per-tile condition")
        Beds.retire(Beds.record(object))
    end
    local saved = instanceItem("Base.OMHTTTrapConcertinaWire")
    Names.pack({id = "native-saved-wire", kind = "wire", health = 13}, saved)
    ModData.getOrCreate("OMHTTNativeServiceC369").item = tostring(saved:getID())
    print("[OMHTT-C369] native mixed-bed=exact callback-order=reverse private-condition=written")
    getCell = nativeGetCell
    print("[OMHTT-Smoke] native-server-traps bed=repair-pickup wire=paired-repair-pickup publicMarkers=ignored clients=0 mappedRemoval=not-tested")
end
