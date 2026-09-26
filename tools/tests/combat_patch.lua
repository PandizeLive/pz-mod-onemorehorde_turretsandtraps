local F = require("OMHTT/Foundation")
local S = require("OMHTT/FoundationServer")
local C = require("OMHTT/PrototypeCombat")
testMode = "sp"
testSquares = {}
for x = 94, 106 do
    for y = 94, 106 do makeSquare(x, y, 0) end
end
local origin = testSquares[F.key(100, 100, 0)]
local object = IsoObject.new(origin, F.spriteFor("potato", 0), "test")
local record = {id = "angle-test", kind = "potato", ammo = 100, shots = 0, nextShot = 0}
local directions = {{3, 0}, {3, -1}, {2, -2}, {1, -3}, {0, -3}, {-1, -3}, {-2, -2}, {-3, -1},
    {-3, 0}, {-3, 1}, {-2, 2}, {-1, 3}, {0, 3}, {1, 3}, {2, 2}, {3, 1}}
testRoll = 99
for i = 1, #directions do
    local dx, dy = directions[i][1], directions[i][2]
    local square = testSquares[F.key(100 + dx, 100 + dy, 0)]
    local zombie = makeZombie(square, 10)
    testMillis = testMillis + 1000
    check(C.fire(record, object, testPlayer) == "Fired" and record.facing == i - 1
        and object.sprite == "media/textures/OMHTT_Aim" .. i - 1 .. ".png", "actual shot selects existing sector " .. i)
    square.moving = {}
end
local target = makeZombie(testSquares[F.key(101, 100, 0)], 10)
local rounds = record.ammo
testTime = testTime + 1000
testMillis = testMillis + 999
check(C.fire(record, object, testPlayer) == "Cooling" and record.ammo == rounds,
    "999 milliseconds and a large world-clock skip cannot bypass the shot limit")
testMillis = testMillis + 1
check(C.fire(record, object, testPlayer) == "Fired", "exactly one real second allows next shot")
check(not target.knocked, "failed knockdown roll leaves native knockdown untouched")
target.allowRagdoll = true
testRoll = 0
testMillis = testMillis + 1000
C.fire(record, object, testPlayer)
check(target.nativeKnockdown and not target.physics and target.attackPosition == "FRONT"
    and target.hitDirection.x == 1 and target.hitDirection.y == 0 and target.hitForce == 0.35,
    "successful roll selects animated stumble with small force away from turret despite ragdoll availability")
target.knocked, target.nativeKnockdown = false, false
testMillis = testMillis + 1000
C.fire(record, object, testPlayer)
check(not target.nativeKnockdown, "same target recovery guard applies across subsequent shots")
testMillis = testMillis + 2000
target.allowRagdoll = false
C.fire(record, object, testPlayer)
check(target.nativeKnockdown and not target.physics, "native animation fallback respects ragdolls disabled")
testMillis = testMillis + 200
C.observeImpacts()
local observed = false
for i = 1, #testLogs do
    if string.find(testLogs[i], "event=shot%-reaction%-observed") then observed = true end
end
check(observed, "deferred diagnostic records actual reaction state")
testData = {schema = 1, nextId = 9, tileCount = 1, tiles = {}}
local legacy = {id = "test-8", kind = "potato", facing = -3, nextShot = 200, condition = 100,
    revision = 2, testOwner = "tester", ammo = 2, shots = 2, observedLoss = 0}
testData.tiles[F.key(100, 100, 0)] = {epoch = 2, device = legacy}
object.name = F.PREFIX .. legacy.id
object.data.OMHTT = {schema = 1, id = legacy.id}
origin.objects = {object}
S.initialize()
S.reconcile(origin)
check(legacy.facing == 13 and object.sprite == F.spriteFor("potato", 13) and legacy.nextShot == 0
    and legacy.ammo == 2 and legacy.shots == 2, "legacy invisible turret repaired without refilling ammunition")
legacy.nextShot = testMillis + 1000
testData = nativeRoundTrip(testData)
S.initialize()
check(testData.tiles[F.key(100, 100, 0)].device.nextShot == testMillis + 1000,
    "new clock deadline preserved across native serialization and migration rerun")
check(F.spriteFor("barrier", -4) == "media/textures/OMHTT_Barrier3.png",
    "negative legacy barrier heading cannot request missing sprite")
testRoll = 0
C.resetObservations()
