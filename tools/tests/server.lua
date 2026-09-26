local F = require("OMHTT/Foundation")
local S = require("OMHTT/FoundationServer")
local square = makeSquare(100, 100, 0)
local unrelated = IsoObject.new(square, F.SPRITE, "unrelated-same-sprite")
square:AddTileObject(unrelated)
triggerEvent("OnInitGlobalModData", true)

local request = {x = 100, y = 100, z = 0, request = 1, version = F.VERSION, epoch = 0}
local function run(command, args)
    S.onCommand(F.MODULE, command, testPlayer, args)
    return testResults[#testResults]
end

local placed = run("Place", request)
check(placed.status == "Placed" and placed.count == 1 and placed.condition == 100, "place one device")
check(#square.objects == 2, "preserve unrelated object on placement")
local id = placed.id
check(run("Place", request).status == "Stale" and #square.objects == 2, "repeat placement rejected")
local change = {x = 100, y = 100, z = 0, request = 2, version = F.VERSION, epoch = placed.epoch, id = id, revision = 1, condition = 37}
local changed = run("Condition", change)
check(changed.condition == 37 and changed.revision == 2, "condition mutation")
check(run("Condition", change).status == "Stale", "duplicate mutation rejected")
local oldObject = square.objects[2]
local savedMarker = nativeRoundTrip(oldObject.data)
testData = nativeRoundTrip(testData)
square.objects[2] = IsoObject.new(square, F.SPRITE, oldObject.name)
square.objects[2].data = savedMarker
triggerEvent("OnInitGlobalModData", false)
triggerEvent("LoadGridsquare", square)
local restored = run("Inspect", request)
check(restored.id == id and restored.condition == 37 and restored.revision == 2 and #square.objects == 2, "native table persistence roundtrip")
testLoaded = false
check(run("Inspect", request).status == "Unavailable", "unloaded tile not fabricated")
testLoaded = true
triggerEvent("LoadGridsquare", square)
check(run("Inspect", request).condition == 37, "unload return preserves state")
square.objects[2].data.OMHTT.condition = 100
triggerEvent("LoadGridsquare", square)
check(square.objects[2].data.OMHTT.condition == 37, "server registry repairs stale marker value")

testMode = "server"
testAdmin = false
check(run("Remove", change).status == "Denied" and #square.objects == 2, "non-admin denied")
testAdmin = true
SandboxVars.OMHTurretsTraps.FoundationTestControls = false
check(run("Place", request).status == "Denied", "disabled controls denied")
SandboxVars.OMHTurretsTraps.FoundationTestControls = true
testPlayer.x = 110
check(run("Inspect", request).status == "TooFar", "range validation")
testPlayer.x = 100.5
testPlayer.z = 1
check(run("Inspect", request).status == "TooFar", "floor validation")
testPlayer.z = 0
local bad = {x = 100, y = 100, z = 0, request = 4, version = "old", epoch = 0}
check(run("Place", bad).status == "VersionMismatch", "version mismatch rejected")
local before = #testResults
bad.x = 0 / 0
run("Place", bad)
check(#testResults == before, "NaN coordinate ignored")
bad.x = 100
bad.request = "wrong"
run("Place", bad)
check(#testResults == before, "malformed request ignored")
S.onCommand("other", "Remove", testPlayer, change)
S.onCommand(F.MODULE, "Unknown", testPlayer, change)
check(#testResults == before, "namespace and command allowlist")
triggerEvent("OnObjectAboutToBeRemoved", unrelated)
check(run("Inspect", request).id == id, "unrelated same-sprite removal does not retire device")

local remove = {x = 100, y = 100, z = 0, request = 5, version = F.VERSION, epoch = changed.epoch, id = id, revision = 2}
local removed = run("Remove", remove)
check(removed.status == "Removed" and removed.id == "" and #square.objects == 1, "exact removal")
check(square.objects[1] == unrelated, "unrelated object survives")
check(run("Place", request).status == "Stale" and #square.objects == 1, "old placement cannot resurrect deleted device")
testData = nativeRoundTrip(testData)
triggerEvent("OnInitGlobalModData", false)
triggerEvent("LoadGridsquare", square)
check(run("Inspect", request).id == "", "removal persists")
check(run("Place", request).status == "Stale", "old placement remains stale after reload")
request.epoch = removed.epoch
local second = run("Place", request)
check(second.status == "Placed" and second.id ~= id, "replacement gets new identity")
check(run("Remove", remove).status == "Stale" and #square.objects == 2, "old remove cannot delete replacement")
local duplicate = IsoObject.new(square, F.SPRITE, square.objects[2].name)
duplicate.data = nativeRoundTrip(square.objects[2].data)
square:AddTileObject(duplicate)
local conflict = {x = 100, y = 100, z = 0, request = 6, version = F.VERSION, epoch = second.epoch, id = second.id, revision = 1}
check(run("Remove", conflict).status == "Conflict" and #square.objects == 3, "ambiguous identity fails closed")
table.remove(square.objects, 3)
table.remove(square.objects, 2)
triggerEvent("LoadGridsquare", square)
check(run("Remove", conflict).status == "Conflict" and #square.objects == 1, "missing exact object not recreated")
check(run("Place", conflict).status == "Occupied", "missing-object record preserved for diagnosis")
square:AddTileObject(duplicate)
testPlayer.dead = true
check(run("Remove", conflict).status == "Denied", "dead sender denied")
testPlayer.dead = false
testData.tileCount = 64
local other = makeSquare(101, 100, 0)
local limit = {x = 101, y = 100, z = 0, request = 7, version = F.VERSION, epoch = 0}
check(run("Place", limit).status == "Limit" and #other.objects == 0, "bounded persistent tile ledger")
testMode = "sp"
