local F = require("OMHTT/Foundation")
local S = require("OMHTT/FoundationServer")
local C = require("OMHTT/PrototypeCombat")
testMode = "sp"
testData = nil
testSquares = {}
for x = 94, 106 do
    for y = 94, 106 do makeSquare(x, y, 0) end
end
S.initialize()
local function request(command, x, y, snapshot)
    local args = {x = x, y = y, z = 0, request = 90, version = F.VERSION, epoch = 0, condition = 37}
    if snapshot then
        args.epoch, args.id, args.revision = snapshot.epoch, snapshot.id, snapshot.revision
    end
    S.onCommand(F.MODULE, command, testPlayer, args)
    return testResults[#testResults]
end
local barrier = request("PlaceBarrier", 100, 101)
local wall = testSquares[F.key(100, 101, 0)].objects[1]
check(barrier.kind == "barrier" and wall.blockAll and not wall.passThrough and not wall.hoppable, "native barrier configuration")
wall:setHealth(80)
S.tick()
local observed = request("Inspect", 100, 101)
check(observed.condition == 80 and observed.revision == 2, "native HP observation advances revision")
check(request("Condition", 100, 101, barrier).status == "Stale", "old barrier request invalidated by damage")
testData = nativeRoundTrip(testData)
S.initialize()
S.reconcile(wall.square)
check(wall.health == 80, "reconcile never heals native barrier")
local potato = request("PlacePotato", 100, 100)
local other = request("PlacePotato", 101, 100)
local aimed = request("Aim", 100, 100, potato)
check(aimed.facing == 1 and request("Inspect", 101, 100).facing == 0, "independent per-instance aim")
local primarySquare = testSquares[F.key(102, 100, 0)]
local primary = makeZombie(primarySquare, 2)
local splash = makeZombie(testSquares[F.key(103, 100, 0)], 1)
local fired = request("Fire", 100, 100, aimed)
check(fired.status == "Fired" and fired.ammo == 3 and fired.shots == 1, "one shot consumes one round")
check(primary.health == 1.5 and primary.hits == 0 and primary.nativeKnockdown, "fixed half-health hit and native knockdown requested once")
check(splash.health < 1 and splash.health > 0.998 and splash.hits == 0, "tiny nonfatal splash excludes primary")
check(request("Fire", 100, 100, aimed).status == "Stale" and primary.health == 1.5, "duplicate shot request rejected")
check(request("Fire", 100, 100, fired).status == "Cooling", "cooldown enforced")
local refilled = request("Refill", 100, 100, fired)
check(refilled.ammo == 4 and refilled.nextShot == fired.nextShot, "debug refill preserves cooldown")
testData = nativeRoundTrip(testData)
S.initialize()
local restored = request("Inspect", 100, 100)
check(restored.nextShot == fired.nextShot and restored.shots == 1 and restored.ammo == 4, "native serialized supplies and cooldown survive reload")
local restoredObject = testSquares[F.key(100, 100, 0)].objects[1]
restoredObject.data.OMHTT.ammo = 900
S.reconcile(restoredObject.square)
check(restoredObject.data.OMHTT.ammo == 4, "stale ammo marker repaired from authoritative registry")
testMode = "server"
check(request("Fire", 100, 100, restored).status == "MPCombatDeferred" and primary.health == 1.5, "MP damage path fails closed")
testMode = "sp"
testMillis = testMillis + C.SHOT_INTERVAL_MS
primary.knocked = false
local second = request("Fire", 100, 100, restored)
check(second.status == "Fired" and not primary.knocked, "shared knockdown protection survives next shot")
testMillis = testMillis + C.SHOT_INTERVAL_MS
primarySquare.window = true
local denied = request("Fire", 100, 100, second)
check(denied.status == "NoTarget" and denied.ammo == second.ammo, "window obstruction spends no ammunition")
primarySquare.window = false
check(not C.clearLane(testSquares[F.key(100, 100, 0)], makeSquare(100, 100, 1)), "different floor rejected")
testLoaded = false
check(not C.clearLane(testSquares[F.key(100, 100, 0)], primarySquare), "unloaded path rejected")
testLoaded = true
for i = 1, 80 do makeZombie(primarySquare, 1) end
local list, visits = C.candidates(testSquares[F.key(100, 100, 0)])
check(visits == 64 and #list <= 64, "moving object candidate budget hard capped")
for x = 94, 106 do
    local key = F.key(x, 95, 0)
    testData.tiles[key] = {epoch = 0}
end
S.initialize()
for i = 1, 10 do S.tick() end
check(request("Inspect", 100, 100).peakVisits == 4, "shared scheduler visits at most four slots per tick")
local removed = request("Remove", 100, 101, request("Inspect", 100, 101))
check(removed.status == "Removed" and #wall.square.objects == 0, "exact native barrier removal")

local Combat = require("OMHTT/PrototypeCombat")
local Modules = require("OMHTT/TurretModules")
for x = 950, 958 do for y = 949, 952 do makeSquare(x, y, 0) end end
local origin = testSquares[F.key(950, 950, 0)]
for i = 1, 80 do makeZombie(origin, 5) end
local victim = makeZombie(testSquares[F.key(955, 950, 0)], 5)
local nearby = {}
for i = 1, 4 do nearby[i] = makeZombie(testSquares[F.key(956, 950, 0)], 1) end
local outside = makeZombie(testSquares[F.key(957, 950, 0)], 1)
local state = {id = "splash-regression", kind = "potato", baseFacing = 0, ammo = 2, shots = 0, nextShot = 0}
local options = {managed = true, range = 6, interval = 2000, damage = 0.35, splash = 0.0875, radius = 1.5,
    knockdown = 0, target = victim, profile = Modules.profile(state, {active = {}})}
local status, impact = Combat.fire(state, {getSquare = function() return origin end}, nil, options)
check(status == "Fired" and victim.health == 4.65, "Far selected target takes 35 direct damage despite dense near crowd")
local damaged = 0
for i = 1, #nearby do
    if nearby[i].health < 1 then
        damaged = damaged + 1
        check(math.abs(nearby[i].health - 0.9125) < 0.000001 and not nearby[i].nativeKnockdown,
            "Splash deals 25 percent without crowd-control")
    end
end
check(damaged == 3 and outside.health == 1, "Impact-local splash caps at three and excludes outside radius")
check(impact.fromX == 950.5 and impact.fromY == 950.5, "Visual travel facts originate at turret")
