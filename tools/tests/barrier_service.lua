local F = require("OMHTT/Foundation")
local S = require("OMHTT/FoundationServer")
local P = require("OMHTT/BarrierFootprint")
local Service = require("OMHTT/BarrierService")
testMode = "sp"
testData, testSquares = nil, {}
testPlayer.x, testPlayer.y = 300.5, 299.5
SandboxVars.OMHTurretsTraps.Enabled, SandboxVars.OMHTurretsTraps.SpikeBarrier = true, true
S.initialize()
local first, second = makeSquare(300, 300, 0), makeSquare(300, 301, 0)
local status, slot = P.place(first, testPlayer)
local record = slot.device
record.placementSource = "construction"
local parts = P.parts(record)
parts[1]:setHealth(57)
P.sync(slot)
local id = record.id
local menuHandler = testBarrierMenuHandler
testMenu.options = {}
menuHandler(0, testMenu, {parts[1]}, false)
check(testMenu.options["Condition: 57/100"] ~= nil and not testMenu.options["Repair (free, 10 seconds)"].notAvailable,
    "world menu shows exact shared durability and repair without developer controls")

check(Service.resolve(testPlayer, parts[1], id) == record and record.condition == 57, "service resolves paired construction condition")
check(not Service.apply(testPlayer, parts[1], "stale", "Pickup"), "wrong device cannot return an item")
testPlayer.x = 310
check(not Service.apply(testPlayer, parts[1], id, "Repair"), "distant repair rejected")
testPlayer.x = 300.5
testMode = "server"
check(not Service.apply(testPlayer, parts[1], id, "Pickup"), "multiplayer service remains closed")
testMode = "sp"
local action = testServiceAction(testPlayer, parts[1], id, "Repair")
action:start()
for i = 1, 99 do action:update() end
check(not action.forced and not action:complete() and record.condition == 57, "repair cannot apply before ten active seconds")
action:update(); action:update()
check(action.forced and action:complete() and record.condition == 100 and parts[2]:getHealth() == 100,
    "ten-second repair restores both halves with no inventory charge")
check(not action:complete() and #testInventory.items == 0, "repair completion is idempotent and creates no items")
check(not Service.apply(testPlayer, parts[1], id, "Repair"), "undamaged barrier cannot be repaired")
testMenu.options = {}
menuHandler(0, testMenu, {parts[2]}, false)
check(testMenu.options["Condition: 100/100"] ~= nil and testMenu.options["Repair (free, 10 seconds)"].notAvailable,
    "second-half world menu shows same condition and disables needless repair")

parts[2]:setHealth(42)
P.sync(slot)
testPlayer.y = 302.5
local cancelled = testServiceAction(testPlayer, parts[2], id, "Pickup")
cancelled:start(); cancelled:update(); cancelled:stop()
check(not cancelled:complete() and slot.device == record and #testInventory.items == 0,
    "interrupted pickup retains barrier and awards nothing")
testInventory.room = false
check(not Service.apply(testPlayer, parts[2], id, "Pickup") and slot.device ~= nil, "full inventory preserves both parts")
testInventory.room = true
local pickup = testServiceAction(testPlayer, parts[2], id, "Pickup")
pickup:start()
for i = 1, 101 do pickup:update() end
check(pickup:complete() and #testInventory.items == 1 and testInventory.items[1].condition == 100,
    "pickup from second half creates exactly one full-condition item")
check(slot.device == nil and parts[1].removed and parts[2].removed, "pickup retires both world halves")
check(not pickup:complete() and not Service.apply(testPlayer, parts[1], id, "Pickup") and #testInventory.items == 1,
    "replayed action and stale first-half action cannot duplicate pickup")
check(pickup.stopOnWalk and pickup.stopOnRun and pickup.stopOnAim and pickup:getDuration() == action:getDuration(),
    "pickup and repair share duration and native movement interrupts")
