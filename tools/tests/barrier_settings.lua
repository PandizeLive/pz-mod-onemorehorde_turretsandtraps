local F = require("OMHTT/Foundation")
local S = require("OMHTT/FoundationServer")
local P = require("OMHTT/BarrierFootprint")
local Service = require("OMHTT/BarrierService")
local options = SandboxVars.OMHTurretsTraps
check(F.barrierDamage() == 10 and F.barrierHealth() == 100, "legacy saves use default 10 damage and 100 HP")
options.SpikeBarrierDamage, options.SpikeBarrierHealth = -1, 20000
check(F.barrierDamage() == 0 and F.barrierHealth() == 10000, "options are bounded")
options.SpikeBarrierDamage, options.SpikeBarrierHealth = "bad", 0/0
check(F.barrierDamage() == 10 and F.barrierHealth() == 100, "invalid options fall back safely")
options.SpikeBarrierDamage, options.SpikeBarrierHealth = nil, 200
testData, testSquares = nil, {}
S.initialize()
testPlayer.x, testPlayer.y = 400.5, 399.5
local first, second = makeSquare(400, 400, 0), makeSquare(400, 401, 0)
local status, slot = P.place(first, testPlayer)
local record = slot.device
record.placementSource = "construction"
local parts = P.parts(record)
check(record.condition == 200 and record.maxHealth == 200 and parts[2]:getMaxHealth() == 200, "new barrier uses configured shared maximum")
parts[1]:setHealth(180); parts[2]:setHealth(170)
options.SpikeBarrierHealth = 400
P.sync(slot)
check(record.condition == 300 and record.maxHealth == 400 and parts[1]:getHealth() == 300 and parts[2]:getMaxHealth() == 400,
    "collect outstanding damage on both halves before preserving percentage at new maximum")
P.sync(slot)
check(record.condition == 300, "repeated settings reconciliation cannot heal or double damage")
testRepairSupply(testPlayer, "Barrier")
check(Service.apply(testPlayer, parts[1], record.id, "Repair") and record.condition == 400 and parts[2]:getHealth() == 400,
    "one-plank repair restores configured maximum on both parts")
parts[1]:setHealth(148); P.sync(slot)
testData = nativeRoundTrip(testData); S.initialize()
record = testData.tiles[F.key(400, 400, 0)].device
P.sync(testData.tiles[F.key(400, 400, 0)])
check(record.condition == 148 and record.maxHealth == 400, "saved maximum and damaged health survive restart")
record.maxHealth, record.condition = nil, 37
parts[1]:setHealth(37); parts[2]:setHealth(37)
options.SpikeBarrierHealth = 200
P.sync(testData.tiles[F.key(400, 400, 0)])
check(record.condition == 74 and record.maxHealth == 200, "pre-settings save migrates from former 100 maximum without healing")
options.SpikeBarrierHealth = 1
P.sync(testData.tiles[F.key(400, 400, 0)])
check(record.condition == 1 and parts[2]:getMaxHealth() == 1, "minimum HP cannot kill a living barrier during migration")
options.SpikeBarrierHealth, options.SpikeBarrierDamage = nil, nil
