local F = require("OMHTT/Foundation")
local S = require("OMHTT/FoundationServer")
testData = nil
testSquares = {}
testMode = "sp"
testMillis = testMillis + 4000
testPlayer.x, testPlayer.y, testPlayer.z = 100.5, 100.5, 0
S.initialize()
triggerEvent("OnGameStart")
local square = makeSquare(100, 100, 0)
makeSquare(100, 101, 0)
makeSquare(101, 100, 0)
local function command(name, previous)
    local args = {x = 100, y = 100, z = 0, request = 1000, version = F.VERSION, epoch = 0}
    if previous then args.epoch, args.id, args.revision = previous.epoch, previous.id, previous.revision end
    S.onCommand(F.MODULE, name, testPlayer, args)
    return testResults[#testResults]
end
local placed = command("PlaceBarrier")
local object = square.objects[1]
check(object.sprite == F.spriteFor("barrier", 0) and square.changed and object.renderInvalidated == FBORenderChunk.DIRTY_REDRAW,
    "barrier uses its own sprite and requests world redraw on confirmed placement")
object.noTexture = true
object.renderInvalidated = nil
testDraws = 0
triggerEvent("OnPostUIDraw")
check(testDraws == 3, "placement label and location cross show before texture exists")
testMillis = testMillis + 150
triggerEvent("OnTick")
check(object.renderInvalidated == nil, "missing texture does not claim readiness")
object.noTexture = false
object.texturePending = true
testMillis = testMillis + 300
triggerEvent("OnTick")
check(object.renderInvalidated == nil, "allocated but pending texture does not claim readiness")
object.texturePending = false
testMillis = testMillis + 300
triggerEvent("OnTick")
check(object.renderInvalidated == FBORenderChunk.DIRTY_REDRAW, "ready texture causes a bounded deferred redraw")
local rotated = command("RotateBarrier", placed)
check(rotated.status == "BarrierRotated" and rotated.facing == 4 and object.sprite == F.spriteFor("barrier", 4),
    "barrier rotates one quarter turn with its own marker")
check(object.blockAll and not object.hoppable and object.health == 100 and rotated.ammo == 0,
    "visual rotation preserves collision, health and supplies")
check(command("RotateBarrier", placed).status == "Stale", "duplicate barrier rotation rejected")
testData = nativeRoundTrip(testData)
S.initialize()
object.sprite = F.SPRITE
S.reconcile(square)
check(object.sprite == F.spriteFor("barrier", 4) and object.data.OMHTT.facing == 4 and object.data.OMHTT.revision == rotated.revision,
    "reload migrates legacy cube visuals without changing device state")
testMillis = testMillis + 6100
triggerEvent("OnTick")
testDraws = 0
triggerEvent("OnPostUIDraw")
check(testDraws == 0, "temporary labels expire")
local inspected = command("Inspect")
testDraws = 0
triggerEvent("OnPostUIDraw")
check(testDraws == 3, "inspect restores one current marker")
command("Remove", inspected)
testDraws = 0
triggerEvent("OnPostUIDraw")
check(testDraws == 0, "removed device has no lingering marker")
check(F.spriteFor("foundation", 0) ~= F.spriteFor("barrier", 0) and F.spriteFor("barrier", 0) ~= F.spriteFor("potato", 0),
    "prototype kinds cannot share an indistinguishable sprite")
