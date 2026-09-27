local F = require("OMHTT/Foundation")
local S = require("OMHTT/FoundationServer")
local P = require("OMHTT/BarrierFootprint")
local B = require("OMHTT/BarrierRetaliation")
testMode = "sp"
testData, testSquares = nil, {}
testPlayer.x, testPlayer.y, testPlayer.z = 100.5, 100.5, 0
for x = 97, 104 do
    for y = 97, 104 do makeSquare(x, y, 0) end
end
S.initialize()
local function request(command, x, y, previous)
    local args = {x = x, y = y, z = 0, request = 3000, version = F.VERSION, epoch = 0, condition = 37}
    if previous then args.epoch, args.id, args.revision = previous.epoch, previous.id, previous.revision end
    S.onCommand(F.MODULE, command, testPlayer, args)
    return testResults[#testResults]
end
local a = testSquares[F.key(100, 100, 0)]
local b = testSquares[F.key(100, 101, 0)]
local c = testSquares[F.key(101, 100, 0)]
b.free = false
check(request("PlaceBarrier", 100, 100).status == "Blocked" and #a.objects == 0 and testData.nextId == 1,
    "blocked second tile cannot create a half-barrier or consume an identity")
b.free = true
local occupant = makeZombie(b, 2)
check(request("PlaceBarrier", 100, 100).status == "Blocked", "moving occupant blocks extension")
b.moving = {}
local placed = request("PlaceBarrier", 100, 100)
local first, second = a.objects[1], b.objects[1]
check(placed.status == "Placed" and first and second and first.data.OMHTT.id == second.data.OMHTT.id,
    "two collision objects share one barrier identity")
local fromSecond = request("Inspect", 100, 101)
check(fromSecond.id == placed.id and fromSecond.revision == placed.revision, "inspection from either half resolves the same barrier")
check(request("PlacePotato", 100, 101, fromSecond).status == "Occupied", "second tile remains reserved against other devices")
check(first.blockAll and second.blockAll and not first.hoppable and not second.hoppable,
    "both occupied tiles block entry and vaulting")
first:setHealth(96)
second:setHealth(95)
local damaged = request("Inspect", 100, 101)
check(damaged.condition == 91 and first.health == 91 and second.health == 91,
    "simultaneous wear on both halves is summed once into shared durability")
S.tick()
check(first.health == 91 and second.health == 91, "polling synchronized parts cannot repeat wear or heal")
c.free = false
check(request("RotateBarrier", 100, 101, damaged).status == "Blocked" and #b.objects == 1 and #c.objects == 0,
    "blocked rotation leaves both old parts and facing intact")
c.free = true
local rotated = request("RotateBarrier", 100, 101, damaged)
check(rotated.status == "BarrierRotated" and rotated.id == "" and #b.objects == 0 and #c.objects == 1,
    "rotation from secondary tile vacates it and reports its new empty state")
local current = request("Inspect", 100, 100)
check(current.condition == 91 and current.facing == 4 and c.objects[1].health == 91,
    "rotation changes footprint and arrows without repairing durability")
check(request("RotateBarrier", 100, 100, damaged).status == "Stale", "pre-rotation request cannot replay")
local record = testData.tiles[F.key(100, 100, 0)].device
for facing = 0, 12, 4 do
    record.facing = facing
    local nx, ny = F.barrierDirection(facing)
    local cx, cy = record.x + 0.5 - ny * 0.5, record.y + 0.5 + nx * 0.5
    check(B.face(record, cx + nx, cy + ny) == "front", "front classifier agrees with arrow " .. facing)
    check(B.face(record, cx - nx, cy - ny) == "rear", "rear classifier follows orientation " .. facing)
    check(B.face(record, cx - ny * 1.7, cy + nx * 1.7) == "side"
        and B.face(record, cx + ny * 1.7, cy - nx * 1.7) == "side", "both short sides are hazardous " .. facing)
    check(B.face(record, cx - nx + ny * 1.5, cy - ny - nx * 1.5) == "rear",
        "rear diagonal corner tie stays safe " .. facing)
end
record.facing = 4
local rear = makeZombie(b, 2)
rear.state, rear.thumpTarget = "ThumpState", first
B.update(rear)
rear.variables[B.TOKEN] = "left"
B.update(rear)
check(rear.health == 2 and rear.data.OMHTTBarrierStrike.token == "left", "rear thump consumes marker without damage")
rear.square = testSquares[F.key(100, 99, 0)]
b.moving = {}
B.update(rear)
check(rear.health == 2, "moving from rear to front cannot reuse the suppressed marker")
rear.variables[B.TOKEN] = "right"
B.update(rear)
check(math.abs(rear.health - 1.9) < 0.00001, "fresh front strike deals 10 after moving around barrier")
testData = nativeRoundTrip(testData)
S.initialize()
local restored = request("Inspect", 101, 100)
check(restored.id == current.id and restored.condition == 91 and restored.facing == 4 and #a.objects == 1 and #c.objects == 1,
    "native save roundtrip preserves aliases, durability and rotated footprint")
local savedSecondary = c.objects[1]
testSquares[F.key(101, 100, 0)] = nil
a:transmitRemoveItemFromSquare(first)
check(testData.tiles[F.key(100, 100, 0)].device == nil and testData.tiles[F.key(101, 100, 0)].retired == current.id,
    "native destruction retires authority and persists cleanup for an unloaded half")
testData = nativeRoundTrip(testData)
S.initialize()
testSquares[F.key(101, 100, 0)] = c
local unrelated = IsoObject.new(c, F.spriteFor("barrier", 4), "unrelated")
c:AddTileObject(unrelated)
S.reconcile(c)
check(savedSecondary.removed and #c.objects == 1 and c.objects[1] == unrelated
    and testData.tiles[F.key(101, 100, 0)].retired == nil, "reload removes only the retired exact half")
local empty = request("Inspect", 100, 100)
local replacement = request("PlaceBarrier", 100, 100, empty)
check(replacement.status == "Placed" and replacement.id ~= current.id, "retired footprint can be replaced with fresh identity")
check(request("Remove", 100, 100, current).status == "Stale" and #a.objects == 1, "old removal cannot delete replacement")
local removed = request("Remove", 100, 101, request("Inspect", 100, 101))
check(removed.status == "Removed" and #a.objects == 0 and #b.objects == 0, "manual removal from either half removes the pair")
local legacySlot = testData.tiles[F.key(100, 100, 0)]
local legacy = {id = "legacy", kind = "barrier", condition = 67, revision = 8, facing = 0,
    testOwner = "foundation-tester", ammo = 0, shots = 0, nextShot = 0, observedLoss = 33,
    cooldownClock = "realtime-ms-v1"}
legacySlot.device = legacy
local old = IsoThumpable.new(getCell(), a, F.spriteFor("barrier", 0), false)
old:setName(F.PREFIX .. legacy.id)
old:setHealth(67)
F.writeMarker(old, legacy)
a:AddSpecialObject(old)
b.free = false
S.initialize()
S.reconcile(a)
check(legacy.width == nil and #b.objects == 0 and old.health == 67, "blocked legacy migration preserves original barrier")
b.free = true
S.reconcile(a)
check(legacy.width == 2 and #b.objects == 1 and b.objects[1].health == 67 and old.health == 67,
    "safe legacy expansion preserves identity and condition")
local legacySecond = b.objects[1]
local legacyPrimary = a.objects[1]
b:transmitRemoveItemFromSquare(legacySecond)
check(not legacyPrimary.removed, "native removal callback does not recursively remove the sibling")
S.tick()
check(legacyPrimary.removed and #a.objects == 0 and #b.objects == 0, "native destruction of secondary also removes primary")
