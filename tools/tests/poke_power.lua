local W = require("OMHTT/ControlWorld")
local Power = require("OMHTT/ControlPower")
local Poke = require("OMHTT/ControlPoke")
local B = require("OMHTT/TurretBattery")
local D = require("OMHTT/Damage")
local H = require("OMHTT/DefenseHorde")
local saved = {mode = testMode, state = W.state, publish = W.publish, cell = getCell, charge = B.charge,
    spend = B.spend, damage = D.resolve, horde = H.allowed, objects = W.objects, locations = W.locations}
testMode = "sp"
local actors, states = {}, {}
local square = {getX = function() return 5 end, getY = function() return 5 end, getZ = function() return 0 end,
    haveElectricity = function() return false end, hasGridPower = function() return false end,
    getRoom = function() return nil end}
function square:getMovingObjects() return {size = function() return #actors end, get = function(_, i) return actors[i + 1] end} end
local function storage()
    local box = {items = {}}
    function box:getItems() return {size = function() return #self.items end, get = function(_, i) return self.items[i + 1] end} end
    function box:getItemWithID(id) for i = 1, #self.items do if self.items[i]:getID() == id then return self.items[i] end end end
    return box
end
local function battery(box, id, charge, kind)
    local item = {charge = charge, box = box, id = id}
    function item:getFullType() return kind or "Base.CarBattery1" end
    function item:getContainer() return self.box end
    function item:getCondition() return 100 end
    function item:getID() return self.id end
    box.items[#box.items + 1] = item
    return item
end
local function device(kind, id)
    local object = {health = 200, box = storage(), sprite = "omhtt_barrier_01_85"}
    function object:getSquare() return square end
    function object:getObjectIndex() return 0 end
    function object:getHealth() return self.health end
    function object:setHealth(value) self.health = value end
    function object:getContainer() return self.box end
    function object:getSpriteName() return self.sprite end
    function object:setSpriteFromName(value) self.sprite = value end
    states[object] = {kind = kind, id = id, placed = true, x = 5, y = 5, z = 0, links = {}}
    return object
end
W.state = function(object) return states[object] end
W.publish = function() end
W.locations, W.objects = {}, {}
getCell = function() return {getGridSquare = function() return square end} end
B.charge = function(item) return item.charge end
B.spend = function(item, amount) local spent = math.min(item.charge, amount); item.charge = item.charge - spent; return spent end
local controller, poke = device("Controller", "bank"), device("Turret", "poke")
W.objects.bank = controller
states[poke].controller = "bank"
local ordinary = battery(controller.box, 1, 1, "Base.Battery")
local first = battery(controller.box, 2, .0002)
local second = battery(controller.box, 3, .5, "Base.CarBattery3")
local source = Power.fallback(poke, .001)
check(source and source.battery == second and source.kind == "controller", "Fallback skips ordinary and insufficient car batteries")
check(math.abs(Power.spend(source) - .001) < .00000001 and ordinary.charge == 1 and first.charge == .0002,
    "Shared debit spends exactly once without deleting or draining rejected candidates")
second.charge = .001
local a, b = Power.fallback(poke, .001), Power.fallback(poke, .001)
check(Power.spend(a) ~= nil and Power.spend(b) == nil, "Concurrent prepared debits cannot overdraw the same bank")
check(Power.fallback(poke, .001) == nil, "Exhausted bank fails closed")
second.charge = .5
states[poke].controller = nil
check(Power.fallback(poke, .001) == nil, "Unassigned nearby trap cannot use another bank")
states[poke].controller = "bank"
controller.health = 0
check(Power.fallback(poke, .001) == nil, "Destroyed Controller cannot supply energy")
controller.health = 200
source = Power.fallback(poke, .001)
second.box = nil
check(Power.spend(source) == nil, "Withdrawn battery invalidates a prepared debit")
second.box = controller.box
local localBattery = battery(poke.box, 4, .1)
states[poke].kind = "Poke"
check(Power.fallback(poke, .001) == nil, "Mechanical Poke cannot draw from Controller")
localBattery.charge = 0

square.haveElectricity = function() return true end

square.haveElectricity = function() return false end
localBattery.charge = 1
local hits, allowed = 0, true
H.allowed = function() return allowed end
D.resolve = function(_, amount, _, _, callback) hits = hits + 1; check(amount == .45, "Poke damage is 45 points"); callback(amount); return true end
actors[1] = {kind = "IsoZombie", isDead = function() return false end}
actors[2] = {kind = "IsoZombie", isDead = function() return false end}
Poke.time = 0
Poke.step(poke, states[poke])
Poke.time = 1000
Poke.step(poke, states[poke])
check(states[poke].active and hits == 0 and localBattery.charge == 1 and second.charge == .5,
    "Pressure cycle spends no local or Controller charge; no immediate damage")
Poke.time = 1150
Poke.step(poke, states[poke])
check(hits == 2 and poke.health == 199, "Strike hits every eligible zombie once but wears once")
Poke.time = 1200
Poke.step(poke, states[poke])
check(hits == 2, "Raised trap has no repeated contact damage")
states[poke].enabled = false
Poke.time = 2500
Poke.step(poke, states[poke])
check(not states[poke].active and hits == 2, "Disable completes retraction and starts no new cycle")
states[poke].enabled = true
Poke.step(poke, states[poke])
Poke.time = 2650
Poke.step(poke, states[poke])
check(hits == 4 and poke.health == 198, "Stationary zombie occupancy can repeat after a full cycle")
actors = {}
Poke.time = 4000
Poke.step(poke, states[poke])
check(not states[poke].active and hits == 4, "Clear tile retracts without queued catch-up attacks")
actors[1] = {kind = "IsoZombie", isDead = function() return false end}
allowed = false
Poke.time = 6000
Poke.step(poke, states[poke])
check(not states[poke].active and hits == 4, "Horde Night opt-out prevents automatic strike")
allowed = true
Poke.step(poke, states[poke])
actors = {}
Poke.time = 6150
Poke.step(poke, states[poke])
check(poke.health == 198, "Missed paid strike does not wear the trap")
Poke.time = 7500
Poke.step(poke, states[poke])
check(not states[poke].active, "Missed strike still retracts")
check(require("OMHTT/Turret").SINGLE.Grid and require("OMHTT/LootDefinitions").WEIGHTS.Grid == 1,
    "Grid Module is nonstackable with assigned Mythic loot weight")
local Injury = require("OMHTT/DefenseInjury")
local oldPokeInjury, oldRand = Injury.poke, ZombRand
local injuries = 0
Injury.poke = function(_, kind) check(kind == "scratch", "Running contact uses one scratch result"); injuries = injuries + 1 end
ZombRand = function() return 0 end
local runner = {kind = "IsoPlayer", isDead = function() return false end, isGodMod = function() return false end,
    isNoClip = function() return false end, isGhostMode = function() return false end, isOnFloor = function() return false end,
    isRunning = function() return true end, isSprinting = function() return false end}
actors = {runner}
Poke.time = 8000; Poke.step(poke, states[poke])
check(states[poke].active and injuries == 0, "Scratch roll starts visible movement before injury")
Poke.time = 8150; Poke.step(poke, states[poke])
check(injuries == 1, "Actual upward strike applies the selected player injury once")
Poke.time = 9500; Poke.step(poke, states[poke])
Poke.time = 10000; Poke.step(poke, states[poke])
check(injuries == 1 and not states[poke].active, "Standing player does not reroll scratch every scan")
actors = {}; Poke.step(poke, states[poke])
localBattery.charge, first.charge, second.charge = 0, 0, 0
actors = {runner}; Poke.time = 11000; Poke.step(poke, states[poke])
Poke.time = 11150; Poke.step(poke, states[poke])
check(injuries == 2 and states[poke].active, "Empty batteries do not block mechanical pressure strike")
first.charge, second.charge = .1, .8
W.batteries[controller], states[controller].batteryId = first, first.id
check(Power.idle(controller, 24) and math.abs(second.charge - .4) < .00000001 and first.charge == 0,
    "Idle debt crosses exact car-battery boundaries without discarding charge")
first.charge, second.charge = 1, 1
W.batteries[controller], states[controller].batteryId = first, first.id
B.spend = function(item, amount)
    local before = item.charge
    item.charge = math.max(0, before - amount)
    return before - item.charge
end
for i = 1, 2000 do
    check(Power.idle(controller, .0001 + (i % 11) * .0000003), "Rounding remainder must not flicker a charged Controller offline")
end
Injury.poke, ZombRand = oldPokeInjury, oldRand
Poke.entries[poke] = nil
W.batteries[controller], W.batteryScan[controller] = nil, nil
testMode, W.state, W.publish, getCell = saved.mode, saved.state, saved.publish, saved.cell
B.charge, B.spend, D.resolve, H.allowed = saved.charge, saved.spend, saved.damage, saved.horde
W.objects, W.locations = saved.objects, saved.locations
print("C339 power/cycle audit: shared debit, exhaustion, withdrawal, assignment, contact phases, wear and Horde consent passed")
