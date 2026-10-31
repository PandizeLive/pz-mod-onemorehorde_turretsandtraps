-- Focused regression/operation-count audit. Timings here are not game-frame FPS.
local D = require("OMHTT/ControlDiscovery")
local A = require("OMHTT/ControlAccess")
local E = require("OMHTT/ControlExpansion")
local old = {state = A.state, objects = D.objects, pending = D.pending, byId = D.byId,
    due = D.due, mode = testMode, millis = testMillis, settings = SandboxVars.OMHTurretsTraps,
    queue = D.queue, queued = D.queued, first = D.first, last = D.last, list = D.list, listIndex = D.listIndex, listSize = D.listSize}
testMode, testMillis = "client", 0
SandboxVars.OMHTurretsTraps = {}
D.objects, D.pending, D.byId, D.due = {}, {}, {}, nil
D.queue, D.queued, D.first, D.last = {}, {}, 1, 0
D.list, D.listIndex, D.listSize = {}, {}, 0
local reads, nodes = 0, {}
A.state = function(object) reads = reads + 1; return object and object.state end
for i = 1, 256 do
    local object = {kind = "IsoThumpable", getObjectIndex = function() return 0 end}
    nodes[i] = object
    D.add(object)
end
-- Pick a pending object beyond the first slice in the actual Kahlua iteration order.
local tail, count = nil, 0
for object in pairs(D.pending) do
    count = count + 1
    if count == 200 then tail = object end
end
check(tail ~= nil, "Discovery audit seeded 256 pending objects")
tail.state = {id = "c399-delayed", kind = "Turret"}
local maximum = 0
for i = 1, 4 do
    testMillis = i * 250
    local before = reads
    D.tick()
    maximum = math.max(maximum, reads - before)
end
print("C399 discovery: pending=256 slices=4 maxStateReads=" .. maximum .. " recovered=" .. tostring(D.byId[tail.state.id] == tail))
check(D.byId[tail.state.id] == tail, "Pending discovery must reach later objects without waiting for earlier expiry")
check(maximum <= 64, "Discovery maintains its 64-object update budget")
local reached = 0
for i = 1, #nodes do
    nodes[i].state = {id = "c399-node-" .. i, kind = "Turret"}
end
for i = 1, 4 do testMillis = testMillis + 250; D.tick() end
for i = 1, #nodes do
    if D.byId[nodes[i].state.id] == nodes[i] then reached = reached + 1 end
end
-- The previously discovered object already had its own stable identity.
check(reached == 255, "All other pending devices receive a fair discovery turn")
check(D.first == 1 and D.last == 0, "Drained discovery queue releases entries and resets indices")
local removed = {kind = "IsoThumpable", getObjectIndex = function() return 0 end}
D.add(removed)
D.remove(removed)
testMillis = testMillis + 250
D.tick()
check(D.first == 1 and D.last == 0 and D.pending[removed] == nil, "Removal drains queued tombstones")
D.add(removed)
D.remove(removed)
D.add(removed)
check(D.last - D.first + 1 == 1, "Re-added pending object is queued only once")
removed.state = {id = "c399-expiry-arrival", kind = "Turret"}
testMillis = testMillis + 11000
D.tick()
check(D.byId[removed.state.id] == removed, "Arrived metadata is checked before timeout eviction")
D.remove(removed)
check(D.byId[removed.state.id] == nil, "Removing discovered device clears its lookup")
local expired = {kind = "IsoThumpable", getObjectIndex = function() return 0 end}
D.add(expired)
testMillis = testMillis + 11000
D.tick()
check(D.pending[expired] == nil and D.first == 1 and D.last == 0, "Unresolved expired candidates release queue references")
local lookups = 0
local storage = {}
local state = {id = "c399-host", kind = "Controller", expansionId = 500, expansionTier = 4}
local kit = {getID = function() return 500 end, getFullType = function() return "Base.OMHTTModuleExpansionLarge" end,
    getContainer = function() return storage end}
local arrived = false
function storage:getItemWithID(id) lookups = lookups + 1; return arrived and kit or nil end
local host = {state = state, getContainer = function() return storage end}
check(E.capacity(host) == 500 and A.radius(host) == 50, "Client uses published expansion grade before inventory arrival")
testMode, arrived = "sp", true
for i = 1, 6400 do E.capacity(host); A.radius(host) end
print("C399 expansion: allowanceQueries=12800 inventoryLookups=" .. lookups)
local measuredLookups = lookups
check(lookups <= 2, "Unchanged installed kit does not repeatedly search the stockpile")
kit.getContainer = function() return nil end
arrived = false
check(E.capacity(host) == 100, "Removed exact kit invalidates cached allowance immediately")
testMode = "client"
state.expansionTier = 0
check(E.capacity(host) == 100, "New server grade overrides old client inventory/cache")
A.state, testMode, testMillis = old.state, old.mode, old.millis
SandboxVars.OMHTurretsTraps = old.settings
D.objects, D.pending, D.byId, D.due = old.objects, old.pending, old.byId, old.due
D.queue, D.queued, D.first, D.last = old.queue, old.queued, old.first, old.last
D.list, D.listIndex, D.listSize = old.list, old.listIndex, old.listSize
testC399Audit = "pending=256 slicesToLast=4 maxStateReads=" .. maximum .. " allowanceQueries=12800 inventoryLookups=" .. measuredLookups .. " removalInvalidation=pass lateClientState=pass"
testPackAudit = testC399Audit

-- Exercise the real mixed Controller scheduler with cheap device test doubles.
local W = require("OMHTT/ControlWorld")
local P = require("OMHTT/ControlPower")
local Poke = require("OMHTT/ControlPoke")
local Sensor = require("OMHTT/ControlSensor")
local Mount = require("OMHTT/ControlMount")
local saved = {order = W.order, objects = W.objects, records = W.records, cursor = W.cursor,
    dirty = W.dirty, dirtySet = W.dirtySet, due = W.due, receiver = W.receiver,
    updatePlate = W.updatePlate, updateInput = W.updateInput, refresh = P.refresh,
    step = Poke.step, advance = Poke.advance, sensor = Sensor.step, mount = Mount.resolve,
    paused = GameTime.isGamePaused, mode = testMode, millis = testMillis, time = getGameTime}
local records, visited, calls, maxSlice = {}, {}, 0, 0
local function visit(object)
    calls = calls + 1
    visited[object] = (visited[object] or 0) + 1
end
testMode = "sp"
W.order, W.objects, W.cursor, W.dirty, W.dirtySet, W.due = {}, {}, 1, {}, {}, nil
W.records = function() return {records = records} end
W.receiver, W.updatePlate, W.updateInput, P.refresh = visit, visit, visit, visit
Poke.step, Poke.advance, Sensor.step, Mount.resolve = visit, function() end, visit, function() return {} end
GameTime.isGamePaused = function() return false end
getGameTime = function() return {getMultiplier=function() return 1 end, getTrueMultiplier=function() return 1 end,getWorldAgeHours = function() return 10 end} end
local kinds = {"Controller", "Poke", "Plate", "Lever", "Laser", "Button", "Turret", "Tether"}
for i = 1, 320 do
    local square = makeSquare(5000 + i, 5000, 0)
    local state = {id = "c399-mixed-" .. i, kind = kinds[(i - 1) % #kinds + 1], x = 5000 + i, y = 5000, z = 0}
    local object = {getSquare = function() return square end, getObjectIndex = function() return 0 end,
        getHealth = function() return 100 end}
    W.order[i], W.objects[state.id], records[state.id] = state.id, object, state
end
for i = 1, 5 do
    testMillis = 1000000 + i * 100
    local before = calls
    W.tick()
    maxSlice = math.max(maxSlice, calls - before)
end
local total = 0
for object, count in pairs(visited) do
    check(count == 1, "Mixed scheduler does not revisit devices before completing its round")
    total = total + 1
end
check(total == 320 and maxSlice <= 64, "All eight device families receive bounded round-robin work")
testC399Audit = testC399Audit .. " mixedDevices=" .. total .. " maxDevicesPerSlice=" .. maxSlice
W.order, W.objects, W.records, W.cursor = saved.order, saved.objects, saved.records, saved.cursor
W.dirty, W.dirtySet, W.due = saved.dirty, saved.dirtySet, saved.due
W.receiver, W.updatePlate, W.updateInput, P.refresh = saved.receiver, saved.updatePlate, saved.updateInput, saved.refresh
Poke.step, Poke.advance, Sensor.step, Mount.resolve = saved.step, saved.advance, saved.sensor, saved.mount
GameTime.isGamePaused, testMode, testMillis = saved.paused, saved.mode, saved.millis
getGameTime = saved.time
