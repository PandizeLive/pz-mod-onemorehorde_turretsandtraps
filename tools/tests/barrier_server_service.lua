local S = require("OMHTT/FoundationServer")
local P = require("OMHTT/BarrierFootprint")
local oldMode, oldAdd = testMode, sendAddItemToContainer
testMode, testData, testSquares = "server", nil, {}
testPlayer.x, testPlayer.y, testPlayer.z, testPlayer.dead = 300.5, 299.5, 0, false
testInventory.items, testInventory.room = {}, true
S.initialize()
local first, second = makeSquare(300, 300, 0), makeSquare(300, 301, 0)
local _, slot = P.place(first, testPlayer)
local record = slot.device
record.placementSource = "construction"
local parts = P.parts(record)
parts[1]:getModData().OMHTT = {id = "forged", schema = 1}
parts[1]:getModData().OMHTTEdge = {id = "forged"}
check(P.exact(parts[1]) == record and #P.parts(record) == 2,
    "Server barrier identity survives overwritten public markers")
for i = 1, #parts do
    parts[i].sync = function(self) self.nativeSynced = true end
end
parts[1]:setHealth(40)
local repair = OMHTTBarrierServiceAction:new(testPlayer, parts[1], record.id, "Repair")
check(repair:getDuration() == 500 and repair.elapsed == 0 and repair:complete(),
    "Server repair uses native duration, without client start/update fields")
check(record.condition == 100 and parts[2]:getHealth() == 100 and parts[1].nativeSynced and parts[2].nativeSynced,
    "Server repair synchronizes both native health objects")
check(not repair:complete(), "Server repair replay rejected")
local firstPickup = OMHTTBarrierServiceAction:new(testPlayer, parts[1], record.id, "Pickup")
local otherPickup = OMHTTBarrierServiceAction:new(testPlayer, parts[2], record.id, "Pickup")
local added = 0
sendAddItemToContainer = function(container, item)
    check(container == testInventory and item == testInventory.items[1], "Pickup syncs the exact added item")
    added = added + 1
end
local originalAdd = testInventory.AddItem
testInventory.AddItem = function() return nil end
check(not firstPickup:complete() and slot.device == record and added == 0,
    "Failed insertion retains the paired barrier and emits no item grant")
testInventory.AddItem = originalAdd
firstPickup = OMHTTBarrierServiceAction:new(testPlayer, parts[1], record.id, "Pickup")
check(firstPickup:getDuration() == 250 and firstPickup:complete() and not otherPickup:complete(),
    "Simultaneous server pickups retire one pair and reject the other action")
check(#testInventory.items == 1 and added == 1 and not firstPickup:complete(), "Pickup grants and broadcasts once")
testMode, sendAddItemToContainer = oldMode, oldAdd
