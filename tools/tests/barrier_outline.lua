local F = require("OMHTT/Foundation")
local P = require("OMHTT/BarrierFootprint")
local O = require("OMHTT/BarrierOutline")
local G = require("OMHTT/BarrierGeometry")
local S = require("OMHTT/FoundationServer")
local Service = require("OMHTT/BarrierService")
local V = require("OMHTT/BarrierVault")
local B = require("OMHTT/BarrierRetaliation")
local function reset()
    testMode, testData, testSquares = "sp", nil, {}
    testPlayer.x, testPlayer.y, testPlayer.z = 800.5, 800.5, 0
    testPlayer.state, testPlayer.dead = "idle", false
    S.initialize()
    for x = 788, 812 do
        for y = 788, 812 do
            local sq = makeSquare(x, y, 0)
            function sq:getVehicleContainer() return nil end
            function sq:isPlayerAbleToHopWallTo() return true end
        end
    end
end
local function build(x, y, facing)
    check(P.canBuild(x, y, 0, facing) == nil, "outline validates loaded footprint and outer-edge anchors")
    local sx, sy = P.second({x = x, y = y}, facing)
    local record
    for i = 1, 2 do
        local square = testSquares[F.key(i == 1 and x or sx, i == 1 and y or sy, 0)]
        local object = IsoThumpable.new(getCell(), square, "omhtt_barrier_01_" .. (facing / 2 + i - 1), facing == 4 or facing == 12)
        square:AddSpecialObject(object)
        record = P.adoptBuild(object, testPlayer, x, y, facing, "OMHTTSpikeBarrier")
    end
    for i = 1, 16 do S.tick() end
    return record
end
local function counts(records)
    local fronts, caps, keys = 0, 0, {}
    for i = 1, #records do
        local objects = O.objects(records[i])
        for j = 1, #objects do
            local object = objects[j]
            local edge = object:getModData().OMHTTEdge
            check(not keys[edge.key], "only one native collider per occupied edge")
            keys[edge.key] = true
            check(not object:isCanPassThrough() and not object:isHoppable(), "outline blocks zombies without exposing hopping flags")
            local cx, cy = (edge.x + edge.tx) / 2, (edge.y + edge.ty) / 2
            check(B.face(records[i], cx + edge.nx * 0.5, cy + edge.ny * 0.5, edge) == (edge.role == "cap" and "side" or "front"),
                "outer front and side caps retaliate against their actual attack face")
            check(B.face(records[i], cx - edge.nx * 0.5, cy - edge.ny * 0.5, edge) == "rear", "inside-facing thumps stay safe")
            if edge.role == "front" then fronts = fronts + 1 else caps = caps + 1 end
        end
    end
    return fronts, caps
end
for facing = 0, 12, 4 do
    reset()
    local nx, ny = F.barrierDirection(facing)
    local first = build(800, 800, facing)
    local fronts, caps = counts({first})
    check(fronts == 2 and caps == 2, "isolated U has two front units and two ends")
    local second = build(800 - ny * 2, 800 + nx * 2, facing)
    local third = build(800 - ny * 4, 800 + nx * 4, facing)
    fronts, caps = counts({first, second, third})
    check(fronts == 6 and caps == 2, "three-barrier run caps only exposed ends in every facing")
    local shape = G.shape(first)
    for i = 1, #shape do
        local edge = shape[i]
        local cx, cy = (edge.x + edge.tx) / 2, (edge.y + edge.ty) / 2
        check((cx - first.x - 0.5) * nx + (cy - first.y - 0.5) * ny == 0.5,
            "front collision is on spike-facing footprint boundary")
    end
    local removed = O.objects(second)
    P.retire(testData.tiles[second.slotKey])
    for i = 1, 16 do S.tick() end
    fronts, caps = counts({first, third})
    check(fronts == 4 and caps == 4, "removing middle adds exactly the two newly exposed end caps")
    for i = 1, #removed do check(removed[i].removed, "middle's collision leaves with its item") end
    local restored = build(800 - ny * 2, 800 + nx * 2, facing)
    fronts, caps = counts({first, restored, third})
    check(fronts == 6 and caps == 2, "replacing middle removes internal caps")
    local collider = O.objects(first)[1]
    collider:setHealth(73)
    P.sync(testData.tiles[first.slotKey])
    check(first.condition == 73 and restored.condition == 100, "collider damage affects only its own barrier")
    local part = P.parts(first)[1]
    testPlayer.x, testPlayer.y = first.x + 0.5, first.y + 0.5
    check(Service.apply(testPlayer, part, first.id, "Repair") and collider:getHealth() == 100,
        "repair restores outline and visible parts without damage replay")
    for i = 1, #O.objects(first) do
        local edge = O.objects(first)[i]
        local square = edge:getSquare()
        testPlayer.x, testPlayer.y = square.x + 0.5, square.y + 0.5
        check(V.plan(testPlayer, edge, first.id) ~= nil, "every exposed front/cap accepts native vault planning")
    end
    testData = nativeRoundTrip(testData)
    S.initialize()
    for i = 1, 16 do S.tick() end
    fronts, caps = counts(O.records())
    check(fronts == 6 and caps == 2, "restart retains connected topology without duplicate helpers")
end
reset()
local north = build(800, 800, 4)
local west = build(800, 801, 8)
local fronts, caps = counts({north, west})
check(fronts == 4 and caps == 2, "perpendicular joined corner has no internal cap")
local isolated = build(806, 806, 4)
fronts, caps = counts({north, west, isolated})
check(fronts == 6 and caps == 4, "gap is not silently bridged")
local before = #O.objects(north)
local neighborSquare = testSquares[F.key(800, 801, 0)]
testSquares[F.key(800, 801, 0)] = nil
O.changed()
O.refresh(north)
check(#O.objects(north) == before, "unloading a neighbor does not add a false cap at its join")
testSquares[F.key(800, 801, 0)] = neighborSquare
local dying = O.objects(west)[1]
dying:getSquare():transmitRemoveItemFromSquare(dying)
for i = 1, 16 do S.tick() end
check(not testData.tiles[west.slotKey].device and #O.objects(west) == 0, "native collider destruction retires its entire owner")
fronts, caps = counts({north, isolated})
check(fronts == 4 and caps == 4, "native destruction exposes neighbor cap without retiring neighbor")
local staleSquare = testSquares[F.key(810, 810, 0)]
local stale = IsoThumpable.new(getCell(), staleSquare, "omhtt_barrier_01_16", true)
stale:setName(F.PREFIX .. "gone:" .. F.key(810, 810, 0) .. ":N")
stale:getModData().OMHTTEdge = {id = "gone", anchor = "gone", key = F.key(810, 810, 0) .. ":N"}
staleSquare:AddSpecialObject(stale)
O.reconcile(staleSquare)
check(stale.removed, "orphan persisted collider is cleaned on load")
reset()
local status, slot = P.place(testSquares[F.key(800, 800, 0)], testPlayer)
local old = slot.device
old.placementSource, old.collisionModel, old.condition = "construction", "edge-v1", 45
local oldParts = P.parts(old)
for i = 1, #oldParts do oldParts[i]:setHealth(45) end
testData = nativeRoundTrip(testData)
S.initialize()
slot = testData.tiles[F.key(800, 800, 0)]
old = slot.device
P.sync(slot, "load")
check(old.collisionModel == "outline-v1" and #O.objects(old) == 4 and old.condition == 45,
    "old coordinate-only ledger migrates without moving its reservations or healing")
check(P.canBuild(800, 800, 0, 8) == "Occupied", "old ledger cannot bypass parallel footprint overlap")
P.retire(slot)
check(#O.objects(old) == 0 and oldParts[1].removed and oldParts[2].removed,
    "migrated coordinate-only ledger retires all physical and visible parts")
