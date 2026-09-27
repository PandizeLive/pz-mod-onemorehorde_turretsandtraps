local F = require("OMHTT/Foundation")
local S = require("OMHTT/FoundationServer")
local P = require("OMHTT/BarrierFootprint")
local A = require("OMHTT/BarrierApproach")
local Service = require("OMHTT/BarrierService")
testData, testSquares = nil, {}
S.initialize()
testPlayer.dead, testPlayer.x, testPlayer.y = false, 701.5, 700.5
for x = 697, 705 do
    for y = 697, 705 do makeSquare(x, y, 0) end
end

local function build(x, y, facing)
    check(P.canBuild(x, y, 0, facing) == nil, "valid native corner placement")
    local sx, sy = P.second({x = x, y = y}, facing)
    local parts = {}
    for i = 1, 2 do
        local sq = testSquares[F.key(i == 1 and x or sx, i == 1 and y or sy, 0)]
        local object = IsoThumpable.new(getCell(), sq, "omhtt_barrier_01_" .. (facing / 2 + i - 1), facing == 4 or facing == 12)
        sq:AddSpecialObject(object)
        P.adoptBuild(object, testPlayer, x, y, facing, "OMHTTSpikeBarrier")
        parts[i] = object
    end
    return parts, P.exact(parts[1])
end

local north, nr = build(700, 700, 4)
local west, wr = build(700, 701, 8)
local south, sr = build(701, 701, 12)
local east, er = build(701, 700, 0)
check(nr.id ~= wr.id and F.find(testSquares[F.key(700, 700, 0)], nr.id) ~= nil and F.find(testSquares[F.key(700, 700, 0)], wr.id) ~= nil, "corner has two independent native edges")
check(P.canBuild(700, 700, 0, 4) == "Occupied", "parallel overlap rejected")
check(P.canBuild(701, 700, 0, 12) == "Occupied", "opposite facing cannot duplicate same collision edge")
north[1]:setHealth(37)
P.sync(P.slot(north[1]:getSquare(), nr.id))
check(west[1]:getHealth() == 100 and north[2]:getHealth() == 37, "corner neighbors keep independent health")
testData = nativeRoundTrip(testData)
S.initialize()
nr, wr = P.exact(north[1]), P.exact(west[1])
check(nr.x == 700 and wr.x == 700 and nr.condition == 37 and wr.condition == 100, "edge ledger coordinates survive restart")
check(Service.resolve(testPlayer, north[1], nr.id) == nr, "service can use the second half on the current side")
local route = A.route(testPlayer, nr)
check(route and #route == 0, "already alongside edge does not walk into it")

for _, square in pairs(testSquares) do
    function square:testCollideAdjacent(player, dx, dy, dz)
        local other = testSquares[F.key(self.x + dx, self.y + dy, self.z + dz)]
        if not other then return true end
        local edgeSquare = self
        if dx > 0 or dy > 0 then edgeSquare = other end
        for i = 1, #edgeSquare.objects do
            local object = edgeSquare.objects[i]
            if not object:isCanPassThrough() and ((dx ~= 0 and not object:getNorth()) or (dy ~= 0 and object:getNorth())) then return true end
        end
        return false
    end
end
testPlayer.x, testPlayer.y = 699.5, 700.5
route = A.route(testPlayer, sr)
check(route and #route > 0, "service finds an outside route instead of crossing the enclosure")
local from = testPlayer:getCurrentSquare()
for i = 1, #route do
    local nextSquare = route[i]
    check(not from:testCollideAdjacent(testPlayer, nextSquare.x - from.x, nextSquare.y - from.y, 0), "service route never crosses an edge")
    from = nextSquare
end
P.retire(P.slot(north[1]:getSquare(), nr.id))
check(north[1].removed and north[2].removed and not west[2].removed and P.exact(west[2]).id == wr.id,
    "pickup removes only selected paired barrier at shared corner")
west[2]:getSquare():transmitRemoveItemFromSquare(west[2])
for i = 1, 16 do S.tick() end
check(west[1].removed and not south[1].removed and not east[1].removed, "native destruction cleanup preserves other edges")
