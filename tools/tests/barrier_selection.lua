local F = require("OMHTT/Foundation")
local P = require("OMHTT/BarrierFootprint")
local S = require("OMHTT/FoundationServer")
local Selection = require("OMHTT/BarrierSelection")
testMode, testData, testSquares = "sp", nil, {}
testPlayer.x, testPlayer.y, testPlayer.z, testPlayer.dead = 1000.5, 1000.5, 0, false
S.initialize()
for x = 997, 1006 do
    for y = 997, 1006 do
        local square = makeSquare(x, y, 0)
        function square:getVehicleContainer() return nil end
        function square:isPlayerAbleToHopWallTo() return true end
    end
end
local function build(x, y, facing, entity, offset)
    local sx, sy = P.second({x = x, y = y}, facing)
    local record
    for part = 0, 1 do
        local square = getCell():getGridSquare(part == 0 and x or sx, part == 0 and y or sy, 0)
        local object = IsoThumpable.new(getCell(), square, "omhtt_barrier_01_" .. (offset + facing / 2 + part), facing == 4 or facing == 12)
        square:AddSpecialObject(object)
        record = P.adoptBuild(object, testPlayer, x, y, facing, entity)
    end
    return record
end
local a = build(1000, 1000, 4, "OMHTTSpikeBarrier", 0)
local b = build(1000, 1001, 8, "OMHTTDeployReinforcedBarrier", 20)
local ap, bp = P.parts(a), P.parts(b)
local floor = IsoObject.new(ap[1]:getSquare(), "floor", "floor")
local entries = Selection.collect(testPlayer, {floor}, 1000.5, 1000.5)
check(#entries == 2 and entries[1].record.id ~= entries[2].record.id, "floor click at shared corner finds both identities")
entries = Selection.collect(testPlayer, {ap[2], ap[1], ap[2]}, 1001.5, 1000.5)
check(#entries == 1 and entries[1].record.id == a.id, "both visible halves deduplicate into one whole barrier count=" .. #entries .. " d=" .. tostring(entries[2] and entries[2].distance))
entries = Selection.collect(testPlayer, {}, 1001.5, 1000.5)
check(#entries == 1 and entries[1].record.id == a.id and entries[1].source == "footprint", "empty native picker still selects occupied footprint")
entries = Selection.collect(testPlayer, {}, 1002.15, 1000.5)
check(#entries == 1 and entries[1].record.id == a.id, "small boundary tolerance covers edge clicks")
check(#Selection.collect(testPlayer, {}, 1002.3, 1000.5) == 0, "outside tolerance does not select nearby barriers")
check(#Selection.collect(testPlayer, {}, 1005.5, 1005.5) == 0, "empty ground does not select distant barriers")
local edges = P.colliders(b)
entries = Selection.collect(testPlayer, {edges[1]}, 1005.5, 1005.5)
check(#entries == 1 and entries[1].record.id == b.id and entries[1].object == bp[1], "picked helper resolves exact reinforced visual object")
testPlayer.z = 1
check(#Selection.collect(testPlayer, {ap[1]}, 1000.5, 1000.5) == 0, "other floor cannot target barrier")
testPlayer.z = 0
testLoaded = false
check(#Selection.collect(testPlayer, {ap[1]}, 1000.5, 1000.5) == 0, "unloaded footprint is rejected")
testLoaded = true
local core = getCore()
local originalCore = getCore
core.getWorldItemHighlightColor = function() return "highlight" end
getCore = function() return core end
for _, part in pairs({ap[1], ap[2], bp[1], bp[2]}) do
    function part:setHighlighted(player, active) self.highlighted = active end
    function part:setHighlightColor(player, color) self.highlightColor = color end
    function part:setOutlineHighlight(player, active) self.outlineHighlighted = active end
    function part:setOutlineHighlightCol(player, color) self.outlineColor = color end
end
local option = {}
Selection.bindHighlight(option, ap)
option:onHighlight({player = 0}, true, unpack(option.onHighlightParams))
check(ap[1].highlighted and ap[2].highlighted and not bp[1].highlighted, "hover highlights both halves of only the selected barrier")
option:onHighlight({player = 0}, false, unpack(option.onHighlightParams))
check(not ap[1].highlighted and not ap[2].outlineHighlighted, "native hover-exit callback clears both parts")
local oldX, oldY = IsoUtils.XToIso, IsoUtils.YToIso
IsoUtils.XToIso = function() return 1000.5 end
IsoUtils.YToIso = function() return 1000.5 end
testMenu.options = {}
testBarrierMenuHandler(0, testMenu, {floor}, false)
local choices = 0
for name, entry in pairs(testMenu.options) do
    if string.find(name, "Barrier", 1, true) and entry.onHighlight then choices = choices + 1 end
end
check(choices == 2, "ambiguous corner gets two independently highlighted menu choices")
IsoUtils.XToIso = function() return 1005.5 end
IsoUtils.YToIso = function() return 1005.5 end
testMillis = testMillis + 2000
testBarrierMenuHandler(0, testMenu, {}, false)
check(string.find(testLogs[#testLogs], "result=miss", 1, true) ~= nil, "empty selection logs a diagnostic miss")
IsoUtils.XToIso, IsoUtils.YToIso = oldX, oldY
P.retire(P.slot(ap[1]:getSquare(), a.id))
entries = Selection.collect(testPlayer, {ap[1]}, 1000.5, 1000.5)
check(#entries == 1 and entries[1].record.id == b.id, "removed corner neighbor cannot leave stale selection")
option:onHighlight({player = 0}, false, unpack(option.onHighlightParams))
getCore = originalCore

for facing = 0, 12, 4 do
    testData, testSquares = nil, {}
    S.initialize()
    for x = 1997, 2003 do
        for y = 1997, 2003 do makeSquare(x, y, 0) end
    end
    local record = build(2000, 2000, facing, "OMHTTSpikeBarrier", 0)
    local parts = P.parts(record)
    for i = 1, 2 do
        local square = parts[i]:getSquare()
        entries = Selection.collect(testPlayer, {}, square:getX() + 0.5, square:getY() + 0.5)
        check(#entries == 1 and entries[1].record.id == record.id, "footprint fallback covers both halves in every heading")
    end
end
