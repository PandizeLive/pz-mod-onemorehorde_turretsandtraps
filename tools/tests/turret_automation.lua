local M = require("OMHTT/TurretModules")
local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")
local A = require("OMHTT/TurretAutomation")
local Combat = require("OMHTT/PrototypeCombat")
local oldRefresh, oldPowerSetting = W.refresh, SandboxVars.OMHTurretsTraps.PotatoRequirePower
local oldInterval = SandboxVars.OMHTurretsTraps.DetectionInterval
local oldEnabled = SandboxVars.OMHTurretsTraps.AutomationEnabled
local oldCone = SandboxVars.OMHTurretsTraps.ForwardCone
W.refresh = function(object) A.changed(object) end
SandboxVars.OMHTurretsTraps.PotatoRequirePower = false
SandboxVars.OMHTurretsTraps.AutomationEnabled = true
SandboxVars.OMHTurretsTraps.ForwardCone = 90
local square
for x = 894, 906 do for y = 894, 906 do makeSquare(x, y, 0) end end
square = testSquares["900:900:0"]
local front = makeZombie(testSquares["902:900:0"], 5)
local far = makeZombie(testSquares["905:900:0"], 2)
local side = makeZombie(testSquares["900:897:0"], 9)
local rear = makeZombie(testSquares["898:900:0"], 0.8)
local edge = makeZombie(testSquares["902:898:0"], 3)
local Aim = require("OMHTT/TurretAim")
local record = {schema = 1, id = "auto-test", kind = "potato", baseFacing = 0, facing = 8, aimDegrees = 180,
    shots = 0, nextShot = 0, priority = "Toughest"}
local plain = {active = {}}
local profile = M.profile(record, plain)
check(profile.heading == 0 and profile.cone == 90 and profile.priority == "Random", "Placement cone and default priority ignore head aim and missing Filter")
check(M.inside(square, front, profile) and M.inside(square, edge, profile), "Forward and exact cone boundary eligible")
check(not M.inside(square, side, profile) and not M.inside(square, rear, profile), "Sides and rear excluded")
local controls = {active = {Filter = 1, Detection360 = 1}}
profile = M.profile(record, controls)
check(profile.cone == 360 and profile.priority == "Toughest" and M.inside(square, rear, profile), "360 expands angular coverage without Detection")
controls.active.Detection360 = nil
check(not M.inside(square, rear, M.profile(record, controls)), "Removing 360 restores original placement cone")
local function scan(priority)
    local p = M.profile(record, controls)
    p.priority = priority
    local job = A.scan(square, p)
    local loops = 0
    while not A.advance(job, 16, testMillis + 100) do
        loops = loops + 1
        check(loops < 100, "Incremental scan terminates")
    end
    check(loops > 1, "Target acquisition yields between bounded work slices")
    return job.best
end
check(scan("Closest") == front, "Closest selects nearest eligible zombie")
check(scan("Furthest") == far, "Furthest selects farthest eligible zombie")
check(scan("Weakest") == far, "Weakest ranks current health inside cone")
check(scan("Toughest") == front, "Toughest ignores stronger zombie outside cone")
far.square.blocked = true
check(scan("Furthest") == edge, "Blocked target skipped for next eligible target")
far.square.blocked = false
local suspended = A.scan(square, profile)
check(not A.advance(suspended, 64, testMillis) and suspended.visited == 0, "Wall-clock deadline stops scan immediately")
for i = 1, 80 do makeZombie(front.square, 4) end
check(scan("Furthest") == far, "Dense near crowd does not hide far targets after 64 entities")
local items, nextId = {}, 8000
local storage = {}
function storage:getItems() return {size = function() return #items end, get = function(_, i) return items[i + 1] end} end
function storage:contains(item) for i = 1, #items do if items[i] == item then return true end end return false end
function storage:Remove(item) for i = #items, 1, -1 do if items[i] == item then table.remove(items, i) end end end
local function add(kind)
    nextId = nextId + 1
    local item = {kind = kind, condition = 100, id = nextId, data = {}}
    function item:getFullType() return self.kind end
    function item:getActualWeight() return 0.2 end
    function item:getDisplayName() return self.kind end
    function item:getID() return self.id end
    function item:getCondition() return self.condition end
    function item:getModData() return self.data end
    items[#items + 1] = item
    return item
end
local head = add(T.HEAD)
local detector = add("Base.OMHTTModuleDetection")
local firing = add("Base.OMHTTModuleFiring")
local filter = add(T.TYPES.Filter)
add("Base.Potato"); add("Base.Potato"); add("Base.Potato")
local object = {index = 0}
function object:hasModData() return true end
function object:getModData() return {OMHTTTurret = record} end
function object:getSquare() return square end
function object:getObjectIndex() return self.index end
function object:getHealth() return 100 end
function object:getContainer() return storage end
A.entries, A.order, A.cursor = {}, {}, 1
A.changed(object)
local entry = A.entries[object]
check(Aim.move(350, 10, 5) == 355 and Aim.move(10, 350, 5) == 5, "Aim takes shortest wraparound turn")
check(Aim.move(0, 4, 9) == 4, "Aim cannot overshoot")
check(not Aim.request(object, front, nil) and record.aimDegrees == 180, "Acquisition does not snap or fire")
local roundsBeforeTurn = T.contents(storage).ammo
testMillis = testMillis + 100
Aim.tick()
check(math.abs(record.aimDegrees - 171) < 0.00001 and T.contents(storage).ammo == roundsBeforeTurn,
    "90-degree turn rate moves nine degrees per 100ms without consuming ammo")

local function run()
    testMillis = testMillis + 2500
    entry.due = 0
    for i = 1, 100 do
        A.step(entry, testMillis + 100)
        if not entry.job and entry.status ~= "Aiming" then
            testMillis = testMillis + 500; Combat.tickFlights(); return
        end
        testMillis = testMillis + 100
        Aim.tick()
    end
    error("Automation scan did not complete")
end
head.data.OMHTTCycle = {schema = 1, loaded = 1, nextShot = 0}
run()
check(record.shots == 1 and T.contents(storage).ammo == 2 and front.health == 4.65, "Automatic shot uses actual ammo and damage without nearby operator")
check(record.baseFacing == 0 and record.aimDegrees == 0, "Tracking changes head without rotating placement cone")
record.automatic = false; run()
check(record.shots == 1 and entry.status == "inactive", "Individual automatic switch prevents firing")
record.automatic = true; SandboxVars.OMHTurretsTraps.AutomationEnabled = false; run()
check(record.shots == 1, "Global switch prevents automatic shots")
SandboxVars.OMHTurretsTraps.AutomationEnabled = true
storage:Remove(firing); run()
check(record.shots == 1 and entry.status == "tracking-only", "Detection alone tracks but never fires")
items[#items + 1] = firing; storage:Remove(detector); run()
check(record.shots == 1 and entry.status == "inactive", "Firing alone does not discover targets")
items[#items + 1] = detector; detector.condition = 0; run()
check(record.shots == 1, "Broken detector cannot automate")
detector.condition = 100
local before = T.contents(storage).ammo
check(W.fire(nil, object, rear) == "NoTarget" and T.contents(storage).ammo == before, "Shot-time geometry rejects stale rear target without spending ammo")
run()
local shots = record.shots
check(shots == 2, "Reinstalled modules resume without granting free ammunition")
A.changed(object); entry.due = 0
A.step(entry, testMillis + 100)
local job = entry.job
check(job ~= nil, "Scan can be in progress during configuration changes")
record.automatic = false
A.step(entry, testMillis + 100)
check(not entry.job and record.shots == shots, "Disable cancels pending target scan")
record.automatic = true
testMillis = testMillis + 10000000
record.automatic = true
run()
check(record.shots <= shots + 1, "Long time jump never drains historical automatic shots")
add("Base.Potato")
storage:Remove(filter)
add("Base.OMHTTModuleVelocity")
add("Base.OMHTTModuleRapidFire")
add("Base.OMHTTModuleReload")
add("Base.OMHTTModuleAutoloader")
head.data.OMHTTCycle = {schema = 1, loaded = 1, nextShot = 0}
record.nextShot = testMillis + 100000
record.aimDegrees = 0
local hp, ammoBefore = front.health, T.contents(storage).ammo
check(W.fire(nil, object, front) == "Fired", "Automatic modified shot uses shared cycle, not stale prototype timer")
local launchTime = testMillis
check(front.health == hp, "Modified shot damage waits for flight")
testMillis = testMillis + 500; Combat.tickFlights()
check(math.abs(front.health - (hp - 0.42)) < 0.000001 and T.contents(storage).ammo == ammoBefore - 1,
    "Velocity changes automatic direct damage while consuming one potato")
local changedCycle = head.data.OMHTTCycle
check(changedCycle.nextShot == launchTime + 1600 and changedCycle.reloadReady == nil,
    "Rapid-Fire and Autoloader reach the actual automatic firing cycle")
check(W.fire(nil, object, front) ~= "Fired", "Autoloader cannot bypass shot cooldown")
local previousPower = W.power
W.power = function() return nil end
run()
check(entry.status == "inactive" and entry.target == nil, "Exhausted power stops targeting and idle sweep eligibility")
W.power = previousPower
local originalNear = W.near
W.near = function() return true end
record.automatic = true
SandboxVars.OMHTurretsTraps.AutomationEnabled = false
record.aimDegrees = 180
add("Base.Potato")
head.data.OMHTTCycle = {schema = 1, loaded = 1, nextShot = 0}
record.nextShot = 0
local manualAmmo = T.contents(storage).ammo
local manualShots = record.shots
check(W.fire({}, object, front) == "Aiming" and T.contents(storage).ammo == manualAmmo, "Manual command queues turning without spending resources")
for i = 1, 30 do testMillis = testMillis + 100; Aim.tick(); Combat.tickFlights() end
check(record.shots == manualShots + 1 and T.contents(storage).ammo == manualAmmo - 1, "Manual queued shot fires exactly once after alignment")
local Search = require("OMHTT/TurretSearch")
add("Base.Potato")
head.data.OMHTTCycle = {schema = 1, loaded = 1, nextShot = 0}
record.aimDegrees = 0
local searchShots, searchAmmo = record.shots, T.contents(storage).ammo
check(W.fire({}, object) == "Searching" and record.shots == searchShots, "Manual click queues without scanning or firing")
check(W.fire({}, object) == "Searching" and #Search.order == 1, "Repeated clicks do not enqueue duplicate shots")
Search.tick()
check(Search.pending[object] and record.shots == searchShots, "Dense search yields after first bounded slice")
for i = 1, 50 do testMillis = testMillis + 16; Search.tick(); Aim.tick(); Combat.tickFlights() end
check(not Search.pending[object] and record.shots == searchShots + 1 and T.contents(storage).ammo == searchAmmo - 1,
    "Queued search and aim commit exactly once")
add("Base.Potato")
head.data.OMHTTCycle = {schema = 1, loaded = 1, nextShot = 0}
Search.targets[object] = nil
check(W.fire({}, object) == "Searching", "Second command can queue after completion")
W.near = function() return false end
Search.tick()
check(Search.results[object].status == "Unavailable" and record.shots == searchShots + 1, "Walking away cancels search without consuming ammunition")
local Health = require("OMHTT/TargetHealth")
local stronger = makeZombie(far.square, 20)
stronger.health = 0.1
check(Health.maximum(stronger) == 20 and M.better(stronger, 25, front, 4, "Toughest"), "Max Toughness ranks original health even when wounded")
stronger:getModData().OMHToughnessInitialHealth = 30
check(Health.maximum(stronger) == 30, "Horde Night recorded toughness takes precedence")
local unknown = makeZombie(far.square, 7)
unknown:getModData().OMHTTInitialHealth = nil
check(Health.maximum(unknown) == 0, "Unknown historical health is never presented as maximum")
W.near = function() return true end
record.automatic, record.powered = false, nil
check(not T.isOn(record), "Legacy Automatic Off migrates to Power Off")
W.setPower({}, object, true)
check(T.isOn(record) and record.automatic == nil, "Power On replaces legacy control without two competing switches")
record.aimDegrees = 180
add("Base.Potato")
head.data.OMHTTCycle = {schema = 1, loaded = 1, nextShot = 0}
local beforePower = T.contents(storage).ammo
check(W.fire({}, object, front) == "Aiming", "Power cancellation fixture queues a shot")
W.setPower({}, object, false)
testMillis = testMillis + 10000; Aim.tick()
local cycle, off = T.cycle(T.contents(storage), testMillis)
check(not Aim.entries[object] and off == "Off" and T.contents(storage).ammo == beforePower, "Power Off cancels queued aim and preserves ammo")
check(W.fire({}, object, front) == "Off", "Manual fire respects Power Off")
head.data.OMHTTCycle.loaded = 0
for i = 1, 4 do testMillis = testMillis + 10000; T.cycle(T.contents(storage), testMillis) end
check(head.data.OMHTTCycle.loaded == 0 and head.data.OMHTTCycle.reloadReady == nil, "Opening Manage cannot reload while switched off")
check(nativeRoundTrip(record).powered == false, "Native serialization preserves Power Off")
W.setPower({}, object, true)
record.aimDegrees = 0
head.data.OMHTTCycle = {schema = 1, loaded = 1, nextShot = 0}
local beforeImpact = front.health
local powerShot = W.fire({}, object, front)
check(powerShot == "Fired", "Powered shot launches before shutdown: " .. powerShot .. " health=" .. tostring(front.health))
W.setPower({}, object, false)
testMillis = testMillis + 1000; Combat.tickFlights()
check(front.health < beforeImpact, "Already-fired potato still lands after Power Off")
W.setPower({}, object, true)
W.near = originalNear
SandboxVars.OMHTurretsTraps.AutomationEnabled = true
storage:Remove(firing)
-- A valid locked target must avoid a fresh crowd scan, even if a better target appears.
local priorAdvance = A.advance
for _, priority in pairs({"Random", "Toughest"}) do
    if priority == "Toughest" then items[#items + 1] = filter else storage:Remove(filter) end
    record.priority = "Toughest"
    A.changed(object)
    local p = M.profile(record, T.contents(storage))
    entry.key = p.heading .. ":" .. p.cone .. ":" .. p.range .. ":" .. p.priority
    entry.target, entry.due = front, 0
    A.advance = function() error("Valid sticky target unexpectedly rescanned") end
    A.step(entry, testMillis + 100)
    check(entry.target == front, priority .. " retains its valid target rather than changing to stronger arrivals")
    A.advance = priorAdvance
    front.square.blocked = true
    entry.due = 0
    A.step(entry, testMillis + 100)
    check(entry.job ~= nil, priority .. " reacquires after target obstruction")
    front.square.blocked = false
end
storage:Remove(filter)
record.engagementRange = 3
local reduced = M.profile(record, T.contents(storage))
check(reduced.range == 3 and M.inside(square, front, reduced) and not M.inside(square, far, reduced), "Engagement range restricts both acquired and new targets")
check(nativeRoundTrip(record).engagementRange == 3, "Engagement range persists in native mod-data serialization")
record.engagementRange = 999
check(M.profile(record, T.contents(storage)).range == T.cycleConfig(T.contents(storage)).range, "Saved range cannot exceed current head and modules")
record.engagementRange = nil
items[#items + 1] = firing
testMillis = testMillis + 250
A.changed(object)
local p = M.profile(record, T.contents(storage))
entry.key = p.heading .. ":" .. p.cone .. ":" .. p.range .. ":" .. p.priority
entry.target, entry.due, entry.fireDue = front, testMillis + 5000, 0
record.aimDegrees = 0
local oldFire, oldStats, fired = W.fire, T.cycleConfig, 0
W.fire = function() fired = fired + 1; return "Fired" end
T.cycleConfig = function(contents) local stats = oldStats(contents); stats.cooldown = 100; return stats end
A.advance = function() error("Acquired target caused a new detection scan") end
local originalLane, laneChecks = Combat.clearLane, 0
Combat.clearLane = function(...) laneChecks = laneChecks + 1; return originalLane(...) end
for i = 1, 10 do testMillis = testMillis + 100; A.step(entry, testMillis + 100) end
check(fired == 10, "Fast acquired target fires ten times while detection deadline remains five seconds away")
check(laneChecks == 10, "Retained target performs one advisory LOS check per step")
Combat.clearLane = originalLane
local beforeRescan = fired
entry.due = 0
entry.job = A.scan(square, p)
A.advance = function() return false end
for i = 1, 10 do testMillis = testMillis + 100; A.step(entry, testMillis + 100) end
check(fired == beforeRescan + 10 and entry.job ~= nil, "Incomplete reprioritization scan cannot stall a valid acquired target")
entry.job = nil
A.advance, W.fire, T.cycleConfig = priorAdvance, oldFire, oldStats
local savedFailure = SandboxVars.OMHTurretsTraps.ImprovisedFiringFailure
local beforeFailurePower = W.power
local testBattery = {charge = .5, getCurrentUsesFloat = function(self) return self.charge end,
    setCurrentUsesFloat = function(self, value) self.charge = value end}
testBattery.data = {}
function testBattery:getModData() return self.data end
W.power = function() return {kind = "battery", battery = testBattery, cost = .01} end
SandboxVars.OMHTurretsTraps.ImprovisedFiringFailure = 100
firing.kind, detector.kind = T.TYPES.FiringImprovised, T.TYPES.MotionDetectionImprovised
firing.kind, detector.kind = T.TYPES.FiringEnhanced, T.TYPES.MotionDetectionEnhanced
local enhanced = T.contents(storage)
check(enhanced.active.Firing and enhanced.active.MotionDetection and enhanced.moduleCounts.Firing == 1,
    "Enhanced modules occupy one slot each and satisfy their normal roles")
check(T.turnSpeed(head, enhanced.active) == T.turnSpeed(head) * 3, "Enhanced Detection triples tracking speed")
local duplicate = add(T.TYPES.Firing); storage:Remove(duplicate)
check(not T.accept(storage, duplicate), "Enhanced Firing excludes normal Firing")
duplicate.kind = T.TYPES.MotionDetectionImprovised
check(not T.accept(storage, duplicate), "Enhanced Detection excludes makeshift Detection")
firing.kind, detector.kind = T.TYPES.FiringImprovised, T.TYPES.MotionDetectionImprovised
local improvised = T.contents(storage)
check(improvised.active.Firing and improvised.active.MotionDetection
    and improvised.moduleCounts.Firing == 1 and improvised.moduleCounts.MotionDetection == 1,
    "Improvised variants enable their standard roles without using extra slots")
local spare = add(T.TYPES.Firing); storage:Remove(spare)
check(not T.accept(storage, spare), "Standard Firing cannot coexist with improvised Firing")
firing.kind = T.TYPES.Firing; spare.kind = T.TYPES.FiringImprovised
check(not T.accept(storage, spare), "Improvised Firing cannot coexist with standard Firing")
firing.kind = T.TYPES.FiringImprovised
local range = add(T.TYPES.Range)
local fullRange = T.cycleConfig(T.contents(storage)).range
check(M.profile(record, T.contents(storage), true).range == fullRange * .75
    and M.profile(record, T.contents(storage)).range == fullRange, "Improvised detection applies after Range bonuses and leaves manual reach unchanged")
storage:Remove(range)
add("Base.Potato")
head.data.OMHTTCycle = {schema = 1, loaded = 1, nextShot = 0}
record.aimDegrees = 0
local beforeMisfire, shotsBeforeMisfire = T.contents(storage).ammo, record.shots
check(W.fire(nil, object, far) == "NoTarget", "Automatic commit rejects a target outside reduced detection reach")
check(W.fire(nil, object, front) == "Misfire", "Guaranteed improvised failure returns a click-only outcome")
check(T.contents(storage).ammo == beforeMisfire and record.shots == shotsBeforeMisfire
    and head.data.OMHTTCycle.loaded == 1 and testBattery.charge == .5, "Failed trigger preserves ammunition, shot power, loaded round and shot count")
check(W.fire(nil, object, front) == "Cooling", "Failed trigger cannot retry before normal cooldown")
head.data.OMHTTCycle = nativeRoundTrip(head.data.OMHTTCycle)
check(W.fire(nil, object, front) == "Cooling", "Serialized exact-head failure cooldown remains enforced")
testMillis = head.data.OMHTTCycle.nextShot
local nearBefore = W.near
W.near = function() return true end
check(W.fire({}, object, far) == "Fired", "Manual fire keeps full range and bypasses the improvised failure roll")
W.near = nearBefore
testMillis = testMillis + 2500
add("Base.Potato")
head.data.OMHTTCycle = {schema = 1, loaded = 1, nextShot = 0}
SandboxVars.OMHTurretsTraps.ImprovisedFiringFailure = 0
check(W.fire(nil, object, front) == "Fired", "Zero failure setting permits normal automatic firing")
local priorContents, scans = T.contents, 0
T.contents = function(container) scans = scans + 1; return priorContents(container) end
testMillis = testMillis + 250
record.aimDegrees = 180
for i = 1, 10 do Aim.request(object, front, nil) end
check(scans == 1, "Repeated same-window aim requests share one inventory scan")
detector.condition = 0
head.data.OMHTTCycle = {schema = 1, loaded = 1, nextShot = 0}
check(W.fire(nil, object, front) == "Unavailable", "Fresh shot check rejects same-count broken detector despite cached aiming summary")
T.contents = priorContents
detector.condition = 100
firing.kind, detector.kind = T.TYPES.Firing, T.TYPES.MotionDetection
SandboxVars.OMHTurretsTraps.ImprovisedFiringFailure = savedFailure
W.power = beforeFailurePower
testMillis = testMillis + 3000
Combat.tickFlights()
object.index = -1
A.tick()
check(A.entries[object] == nil, "Removed turret retires from scheduler")
A.entries, A.order, A.cursor = {}, {}, 1
W.refresh = oldRefresh
SandboxVars.OMHTurretsTraps.PotatoRequirePower = oldPowerSetting
SandboxVars.OMHTurretsTraps.AutomationEnabled = oldEnabled
SandboxVars.OMHTurretsTraps.DetectionInterval = oldInterval
SandboxVars.OMHTurretsTraps.ForwardCone = oldCone
