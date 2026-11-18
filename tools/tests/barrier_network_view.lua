local F = require("OMHTT/Foundation")
local P = require("OMHTT/BarrierFootprint")
local C = require("OMHTT/Construction")
local V = require("OMHTT/BarrierView")
local oldMode, oldMillis = testMode, testMillis
testMode, testData, testSquares = "server", nil, {}
SandboxVars.OMHTurretsTraps.Enabled, SandboxVars.OMHTurretsTraps.SpikeBarrier = true, true
require("OMHTT/FoundationServer").initialize()
for x = 60, 69 do for y = 60, 69 do makeSquare(x, y, 0) end end
local record
for part = 0, 1 do
    local square = getCell():getGridSquare(64, 64 + part, 0)
    local object = IsoThumpable.new(getCell(), square, "omhtt_barrier_01_" .. part, false)
    square:AddSpecialObject(object)
    C.onCreate({thumpable = object, character = testPlayer, facing = "e"})
    record = P.exact(object)
end
check(record and #P.parts(record) == 2 and #P.colliders(record) > 0, "Server callback creates paired barrier and native collision outline")
local parts = P.parts(record)
local edges = P.colliders(record)
for i = 1, #edges do check(edges[i].sent, "Every server-created collision edge is broadcast") end
testMode = "client"
testMillis = testMillis + 101
local view = V.exact(parts[1])
check(view and view.id == record.id and V.parts(view)[2] == parts[2], "Client finds both parts from detached replicated presentation")
view.condition = 1
check(record.condition == 100 and parts[1]:getModData().OMHTT.condition == 100, "Client view cannot mutate server state or its source snapshot")
check(V.exact(edges[1]).id == record.id, "Native edge selection resolves its visual anchor")
for x = 62, 66 do
    for y = 62, 66 do
        for face = 0, 3 do
            testMillis = testMillis + 101
            local preview = V.canBuild(x, y, 0, face * 4)
            testMode = "server"
            local actual = P.canBuild(x, y, 0, face * 4)
            testMode = "client"
            check((preview == nil) == (actual == nil), "Client placement agrees with server geometry at " .. x .. ":" .. y .. ":" .. face)
        end
    end
end
testPlayer.x, testPlayer.y, testPlayer.z = 63.5, 64.5, 0
ClimbOverFenceState = {instance = function() return "ClimbOverFenceState" end}
function testPlayer:getCurrentState() return self.state end
function testPlayer:getCurrentSquare() return nil end
local action = OMHTTBarrierServiceAction:new(testPlayer, parts[1], record.id, "Pickup")
check(action:isValid() and not action:complete() and P.parts(record) ~= nil, "Client service preview is valid but cannot grant or retire")
local savedRequire = require
require = function(name)
    check(name ~= "OMHTT/BarrierService" and name ~= "OMHTT/BarrierFootprint", "MP menu cannot require server authority modules")
    return savedRequire(name)
end
testMenu.options = {}
testBarrierMenuHandler(0, testMenu, {parts[1]}, false)
check(testMenu.options[getText("ContextMenu_OMHTT_RepairBarrier")] and testMenu.options[getText("ContextMenu_OMHTT_PickupBarrier")], "Client receives server-backed barrier services")
require = savedRequire
testMode = "server"
local Outline = require("OMHTT/BarrierOutline")
local edge = edges[1]
local expected = edge:getModData().OMHTTEdge
edge:getModData().OMHTTEdge = {id = "forged", key = "wrong", anchor = "wrong"}
check(Outline.exact(edge) == record and #P.colliders(record) == #edges, "Public edge identity cannot redirect server ownership or health enumeration")
local foreign = IsoThumpable.new(getCell(), edge:getSquare(), "native-wall", edge:getNorth())
foreign:setName("Foreign wall")
foreign:getModData().OMHTTEdge = expected
edge:getSquare():AddSpecialObject(foreign)
check(not Outline.onRemoved(foreign), "Forged metadata on a foreign object cannot retire a barrier")
Outline.reconcile(edge:getSquare())
check(not foreign.removed and edge:getModData().OMHTTEdge.id == record.id,
    "Reconciliation restores the authoritative edge marker and preserves foreign objects")
testMode, testMillis = oldMode, oldMillis
