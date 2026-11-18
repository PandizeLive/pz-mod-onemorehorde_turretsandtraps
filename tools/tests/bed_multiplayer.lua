local B = require("OMHTT/BedSpikes")
local S = require("OMHTT/BedService")
local oldMode, oldStore, oldAdd = testMode, ModData.getOrCreate, sendAddItemToContainer
local persisted, grants = {}, 0
ModData.getOrCreate = function(key)
    check(key == "OMHTTBedSpikes", "Bed authority uses its private global store")
    return persisted
end
testMode = "server"
B.initialize()
local square = makeSquare(230, 230, 0)
function square:isSomethingTo() return false end
local object = IsoThumpable.new(getCell(), square, "omhtt_barrier_01_64", false)
square:AddSpecialObject(object)
B.onCreate({thumpable = object, facing = "e"})
local record = B.record(object)
check(record and record.single and record.health == 50, "Server creates one independent bed")
object:getModData().OMHTTBed = {id = "forged", part = 1, view = {health = 99999}}
check(B.record(object) == record and record.health == 50, "Client marker replacement cannot change bed identity or durability")
local forged = IsoThumpable.new(getCell(), square, "carpentry_01_0", false)
forged:getModData().OMHTTBed = {id = record.id}
square:AddSpecialObject(forged)
check(B.record(forged) == nil, "Copied marker cannot acquire an authoritative trap binding")
B.initialize()
check(B.record(object) == nil, "World reload starts with no live object bindings")
B.loaded(square)
record = B.record(object)
check(record and record.health == 50 and B.record(forged) == nil, "Reload rebinds native trap by persisted location and sprite")
local inventory = {items = {}, room = true}
function inventory:hasRoomFor() return self.room end
function inventory:AddItem(item)
    if self.fail then return nil end
    self.items[#self.items + 1] = item
    return item
end
local player = {}
function player:isDead() return false end
function player:getX() return 230.5 end
function player:getY() return 230.5 end
function player:getZ() return 0 end
function player:getSquare() return square end
function player:getInventory() return inventory end
function player:setHaloNote() end
sendAddItemToContainer = function(destination, item)
    check(destination == inventory and inventory.items[#inventory.items] == item, "Pickup replicates only a committed exact item")
    grants = grants + 1
end
local action = OMHTTBedServiceAction:new(player, object, record.id, "Pickup")
check(action.maxTime == 100 and action.elapsed == 0, "Native server pickup uses two seconds without client start state")
inventory.fail = true
check(not action:complete() and B.record(object) == record and grants == 0, "Failed insertion preserves trap and grants nothing")
inventory.fail = false
action = OMHTTBedServiceAction:new(player, object, record.id, "Pickup")
testMode = "client"
check(not action:complete() and not S.apply(player, object, record.id, "Pickup"), "Clients cannot retire or grant beds")
testMode = "server"
check(action:complete() and not action:complete() and #inventory.items == 1 and grants == 1,
    "Server pickup without start commits once and replay cannot duplicate")
check(B.record(object) == nil and B.record(forged) == nil, "Retired trap and forged marker remain unavailable")
testMode, ModData.getOrCreate, sendAddItemToContainer = oldMode, oldStore, oldAdd
B.initialize()
