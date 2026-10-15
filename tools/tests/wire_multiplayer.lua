local B = require("OMHTT/BarbSections")
local oldMode, oldStore, oldAdd = testMode, ModData.getOrCreate, sendAddItemToContainer
local persisted, grants = {}, 0
ModData.getOrCreate = function() return persisted end
testMode = "server"
B.initialize()
for facing = 0, 3 do
    local square = makeSquare(550 + facing * 4, 550, 0)
    local second = makeSquare(square.x + facing % 2, square.y + 1 - facing % 2, 0)
    function square:isSomethingTo() return false end
    function second:isSomethingTo() return false end
    local first = IsoThumpable.new(getCell(), square, "omhtt_barrier_01_" .. (60 + facing), false)
    local last = IsoThumpable.new(getCell(), second, "omhtt_barrier_01_" .. (72 + facing), false)
    square:AddSpecialObject(first)
    second:AddSpecialObject(last)
    B.onWireCreate({thumpable = first})
    B.onWireCreate({thumpable = last})
    local record = B.record(first)
    check(record == B.record(last) and record.health == 50, "Native wire halves share one server-owned pool")
    first:getModData().OMHTTBarbFrame = {id = "forged", kind = "wire", paired = true}
    last:getModData().OMHTTBarbFrame.view.health = 99999
    check(B.record(first) == record and record.health == 50, "Client markers cannot replace either wire half's authority")
    local a, b, health, status = B.resolve(record)
    check(a == first and b == last and health == record and status == "active", "Server resolution ignores replaced marker IDs")
    B.initialize()
    B.loaded(second)
    B.loaded(square)
    record = B.record(first)
    check(record == B.record(last) and record.health == 50 and #B.order == 1, "Reverse reload order restores one paired identity")
    local inventory = {items = {}}
    function inventory:hasRoomFor() return true end
    function inventory:AddItem(item)
        if self.fail then return nil end
        self.items[#self.items + 1] = item
        return item
    end
    local player = {}
    function player:isDead() return false end
    function player:getX() return second.x + .5 end
    function player:getY() return second.y + .5 end
    function player:getZ() return 0 end
    function player:getSquare() return second end
    function player:getInventory() return inventory end
    sendAddItemToContainer = function(destination, item)
        check(destination == inventory and inventory.items[1] == item, "One recovered wire is synchronized after insertion")
        grants = grants + 1
    end
    record.health = 12
    local repair = OMHTTBarbServiceAction:new(player, last, record.id, "Repair")
    check(repair.maxTime == 500 and repair:complete() and not repair:complete(), "Server wire repair works without client start and rejects replay")
    check(record.health == 50 and first:getModData().OMHTTBarbFrame.view.health == 50
        and last:getModData().OMHTTBarbFrame.view.health == 50, "Both wire half snapshots receive the repaired health")
    inventory.fail = true
    local failed = OMHTTBarbServiceAction:new(player, last, record.id, "Remove")
    check(not failed:complete() and B.record(last) == record, "Failed inventory insertion cannot retire a wire pair")
    inventory.fail = false
    local removal = OMHTTBarbServiceAction:new(player, last, record.id, "Remove")
    check(removal.maxTime == 250 and removal:complete() and not removal:complete(), "Pickup from either end is five seconds and commits once")
    check(first.removed and last.removed and #inventory.items == 1, "Paired wire pickup removes both halves and returns one item")
end
check(grants == 4, "Four independent wires grant exactly four coils")
local anchor, tail = makeSquare(580, 580, 0), makeSquare(580, 581, 0)
local first = IsoThumpable.new(getCell(), anchor, "omhtt_barrier_01_60", false)
local last = IsoThumpable.new(getCell(), tail, "omhtt_barrier_01_72", false)
anchor:AddSpecialObject(first)
tail:AddSpecialObject(last)
B.onWireCreate({thumpable = first})
B.onWireCreate({thumpable = last})
local record, originalCell = B.record(first), getCell
getCell = function()
    return {getGridSquare = function(_, x, y, z)
        if x == 580 and y == 581 then return nil end
        return originalCell():getGridSquare(x, y, z)
    end}
end
B.retire(record)
check(first.removed and not last.removed and persisted.retiredTiles["580:581:0"] ~= nil,
    "Retiring a wire across unloaded tiles persists the remaining half for removal")
getCell = originalCell
B.initialize()
local other = IsoThumpable.new(getCell(), tail, "unrelated_fence", false)
tail:AddSpecialObject(other)
B.loaded(tail)
check(last.removed and not other.removed and persisted.retiredTiles["580:581:0"] == nil,
    "Reload removes only the retired native wire half and clears its tombstone")
testMode, ModData.getOrCreate, sendAddItemToContainer = oldMode, oldStore, oldAdd
B.initialize()
