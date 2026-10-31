local Class = require("OMHTT/FirearmClass")
local Accuracy = require("OMHTT/FirearmAccuracy")
local gun = {range = 40, mechanism = "boltaction", modes = {"Single"}, two = true, pellets = 1}
function gun:getFullType() return "Example.Test" end
function gun:isTwoHandWeapon() return self.two end
function gun:getProjectileCount() return self.pellets end
function gun:getFireModePossibilities() return {size = function() return #gun.modes end, get = function(self, i) return gun.modes[i + 1] end} end
function gun:getFireMode() return "Single" end
function gun:getWeaponReloadType() return self.mechanism end
function gun:getScriptItem() return {getMaxRange = function() return gun.range end} end
function gun:isRackAfterShoot() return self.rack == true end
function gun:getMinSightRange() return 2 end
function gun:getMaxSightRange() return 10 end
check(Class.precision(gun), "Semi-auto native-range rifle qualifies")
gun.range = 30
check(Class.precision(gun), "Thirty-tile modded rifle qualifies without forty-tile cutoff")
gun.range, gun.modes = 60, {"Single", "Auto"}
check(not Class.precision(gun), "Long-range machine gun in single mode stays ordinary")
gun.modes = {"Single", "Burst"}
check(not Class.precision(gun), "Burst-capable rifle stays ordinary")
gun.modes, gun.two = {"Single"}, false
check(not Class.precision(gun), "Long-range handgun cannot qualify")
gun.two, gun.pellets = true, 9
check(not Class.precision(gun), "Shotgun cannot qualify")
gun.pellets, gun.range, gun.mechanism, gun.rack = 1, 20, "leveraction", true
check(Class.precision(gun), "Identified short lever rifle qualifies")
local settings = SandboxVars.OMHTurretsTraps
for _, far in pairs({0, 30, 60, 80, 100}) do
    local stats = {range = 40, accuracy = 62, farAccuracy = far}
    check(Accuracy.chance(gun, stats, 40, false) == far, "Configured maximum-range accuracy honored")
    local previous = 101
    for distance = 0, 40 do
        local chance = Accuracy.chance(gun, stats, distance, false)
        check(chance >= far and chance <= previous, "Distance curve is bounded and closer is easier")
        previous = chance
    end
end
local S = require("OMHTT/TurretStats")
check(S.hearingRadius(gun, {firearm = false, hearingMultiplier = 1}) == 8, "Potato noise radius matches eight-tile hearing")
check(S.hearingRadius(gun, {firearm = false, hearingMultiplier = .4}) == 4, "Suppression noise ring matches rounded emitted radius")
local Clock = require("OMHTT/TurretClock")
local cycle = {clockSession = "previous-process", clockAt = 100, nextShot = 600, reloadReady = 900, rackReady = 300}
Clock.restore(cycle, 90000)
check(cycle.nextShot == 90500 and cycle.reloadReady == 90800 and cycle.rackReady == 90200, "Restart preserves remaining cooldown, reload and cycling")
Clock.restore(cycle, 90100)
check(cycle.nextShot == 90500, "Continuous play advances timers normally")
local realNow = Clock.now
Clock.now = testActiveClockNow
Clock.tick()
local start = Clock.now()
GameTime.isGamePaused = function() return true end
testMillis = testMillis + 10000
Clock.tick()
check(Clock.now() == start, "Paused active clock cannot grant reload progress")
GameTime.isGamePaused = function() return false end
testMillis = testMillis + 10000
Clock.tick()
check(Clock.now() == start, "Resume excludes pause time")
testMillis = testMillis + 700
testTime = testTime + 700 / 150000
Clock.tick()
check(math.abs(Clock.now() - start - 700) < .001, "World-time progress advances cooldown at normal speed")
local ActiveTime = require("OMHTT/ActiveTime")
local observed = ActiveTime.new()
check(ActiveTime.step(observed) == 0, "Fresh clock cannot grant offline progress")
GameTime.isGamePaused = function() return true end
testMillis = testMillis + 10000
triggerEvent("OnTickEvenPaused")
GameTime.isGamePaused = function() return false end
testMillis = testMillis + 10000
check(ActiveTime.step(observed) == 0, "Native paused event excludes pause even without ordinary tick calls")
testMillis = testMillis + 700
check(ActiveTime.step(observed) == 700, "Observer counts full active elapsed time")
testMillis = testMillis - 100
check(ActiveTime.step(observed) == 0, "Clock rollback cannot reverse cooldown progress")
local C = require("OMHTT/TurretCycle")
local settings = {magazine = 2, reload = 2000, cooldown = 2000}
local delayed = {loaded = 2, nextShot = 1000}
check(C.update(delayed, 2, settings, 10000) == "Ready", "Long stall permits the due shot")
C.consume(delayed, 1, settings, 10000)
for i = 1, 10 do check(C.update(delayed, 1, settings, 10000) == "Cooling", "Missed shot deadlines never form a catch-up burst") end
Clock.now = realNow
local B = require("OMHTT/TurretScheduler")
local workers, cursor = B.workers, B.cursor
local calls = {0, 0, 0}
B.workers, B.cursor = {}, 1
for i = 1, 3 do
    local index = i
    B.register(tostring(i), function() calls[index] = calls[index] + 1; testMillis = testMillis + 3 end)
end
B.tick(); B.tick(); B.tick()
check(calls[1] == 1 and calls[2] == 1 and calls[3] == 1, "Exhausted shared budget rotates workers fairly across frames")
B.workers, B.cursor = workers, cursor
local Combat = require("OMHTT/PrototypeCombat")
local origin, destination = makeSquare(500, 500, 0), makeSquare(501, 500, 0)
function origin:isBlockedTo() return true end
check(Combat.clearLane(origin, destination, 6), "Low fence movement collision permits firing")
function origin:testVisionAdjacent() return "ClearThroughOpenDoor" end
check(Combat.clearLane(origin, destination, 6), "Open door permits firing")
function origin:testVisionAdjacent() return "ClearThroughClosedDoor" end
check(not Combat.clearLane(origin, destination, 6), "Closed door blocks firing")
function origin:testVisionAdjacent() return "Blocked" end
check(not Combat.clearLane(origin, destination, 6), "Opaque wall or tall solid fence blocks firing")
function origin:testVisionAdjacent() return "ClearThroughWindow" end
check(not Combat.clearLane(origin, destination, 6), "Window remains blocking")
