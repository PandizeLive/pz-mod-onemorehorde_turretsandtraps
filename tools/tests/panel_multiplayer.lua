local B = require("OMHTT/BarbSections")
local S = require("OMHTT/BarbSupport")
local Service = require("OMHTT/BarbService")
local F = require("OMHTT/Foundation")
local oldMode, oldStore = testMode, ModData.getOrCreate
local persisted = {}
ModData.getOrCreate = function() return persisted end
testMode = "server"
B.initialize()
for i, face in pairs({"e", "n", "w", "s"}) do
    local floor = makeSquare(650 + i * 4, 650, 0)
    local x, y, north = require("OMHTT/BarbContact").edge(floor.x, floor.y, face)
    local square = testSquares[F.key(x, y, 0)] or makeSquare(x, y, 0)
    local host = IsoThumpable.new(getCell(), square, "test-window", north)
    host.kind, host.health = "IsoWindow", 50
    function host:IsOpen() return self.open == true end
    function host:isSmashed() return self.smashed == true end
    function host:isDestroyed() return self.health <= 0 end
    square:AddSpecialObject(host)
    local temporary = IsoThumpable.new(getCell(), floor, "omhtt_barrier_01_52", north)
    floor:AddSpecialObject(temporary)
    local frame = B.onCreate({thumpable = temporary, facing = face}).object
    local record = B.record(frame)
    local attachment = S.record(host, north, record.side)
    check(record and attachment.health == 50 and host.health == 50, "MP panel owns 50 HP without increasing window HP")
    host:getModData().OMHTTBarbs = {}
    host:getModData().OMHTTTurret = {id = "forged"}
    frame:getModData().OMHTTBarbFrame = {id = "forged", view = {health = 9999}}
    check(S.attachment(host, north, record.side) == record.id and B.record(frame) == record,
        "Host and frame public markers cannot replace panel authority")
    B.initialize(); B.loaded(square)
    record = B.record(frame)
    attachment = S.record(host, north, record.side)
    check(record and attachment.health == 50, "Panel reload restores from private ledger and native frame identity")
    host.open, host.smashed, host.health = true, true, 0
    check(select(4, B.resolve(record)) == "active", "Open smashed window keeps independent panel health")
    attachment.health = 12
    local player = {}
    function player:isBuildCheat() return true end
    function player:isDead() return false end
    function player:getZ() return 0 end
    function player:getSquare() return self.square end
    function player:getX() return self.square.x + .5 end
    function player:getY() return self.square.y + .5 end
    local ax, ay = record.x, record.y
    if record.side < 0 then
        if north then ay = ay - 1 else ax = ax - 1 end
    end
    player.square = testSquares[F.key(ax, ay, 0)] or makeSquare(ax, ay, 0)
    function player.square:isSomethingTo() return false end
    local repair = OMHTTBarbServiceAction:new(player, frame, record.id, "Repair")
    check(repair:complete() and not repair:complete() and attachment.health == 50 and host.health == 0,
        "Server panel repair is repeat-safe and leaves broken glass alone")
    if i % 2 == 0 then
        local remove = OMHTTBarbServiceAction:new(player, frame, record.id, "Remove")
        check(remove:complete() and not remove:complete() and frame.removed and not host.removed,
            "Panel removal retires only the frame, exactly once")
    else
        square:transmitRemoveItemFromSquare(host)
        B.tick()
        check(frame.removed and not persisted.panels[record.id], "Host removal retires panel outside native removal callback")
    end
    B.initialize(); B.loaded(square)
    check(B.record(frame) == nil, "Retired panel cannot return after reload")
end
testMode, ModData.getOrCreate = oldMode, oldStore
B.initialize()
