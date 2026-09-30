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
check(profile.heading == 0 and profile.cone == 90 and profile.priority == "Closest", "Placement cone and default priority ignore head aim and missing Filter")
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
local detector = add("Base.OMHTTModuleMotionDetection")
local firing = add("Base.OMHTTModuleFiring")
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
        if not entry.job and entry.status ~= "Aiming" then return end
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
local previousPower = W.power
W.power = function() return nil end
run()
check(entry.status == "inactive" and entry.target == nil, "Exhausted power stops targeting and idle sweep eligibility")
W.power = previousPower
local originalNear = W.near
W.near = function() return true end
record.automatic = false
record.aimDegrees = 180
add("Base.Potato")
head.data.OMHTTCycle = {schema = 1, loaded = 1, nextShot = 0}
record.nextShot = 0
local manualAmmo = T.contents(storage).ammo
local manualShots = record.shots
check(W.fire({}, object, front) == "Aiming" and T.contents(storage).ammo == manualAmmo, "Manual command queues turning without spending resources")
for i = 1, 30 do testMillis = testMillis + 100; Aim.tick() end
check(record.shots == manualShots + 1 and T.contents(storage).ammo == manualAmmo - 1, "Manual queued shot fires exactly once after alignment")
W.near = originalNear
object.index = -1
A.tick()
check(A.entries[object] == nil, "Removed turret retires from scheduler")
A.entries, A.order, A.cursor = {}, {}, 1
W.refresh = oldRefresh
SandboxVars.OMHTurretsTraps.PotatoRequirePower = oldPowerSetting
SandboxVars.OMHTurretsTraps.AutomationEnabled = oldEnabled
SandboxVars.OMHTurretsTraps.DetectionInterval = oldInterval
SandboxVars.OMHTurretsTraps.ForwardCone = oldCone
