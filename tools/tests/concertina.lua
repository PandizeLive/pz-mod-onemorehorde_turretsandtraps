local B = require("OMHTT/BarbSections")
local Beds = require("OMHTT/BedSpikes")
local Service = require("OMHTT/BarbService")
B.initialize()
testMode, testLoaded = "sp", true
SandboxVars.OMHTurretsTraps.BarbSections = true
SandboxVars.OMHTurretsTraps.BarbWire = true
local square = makeSquare(400, 400, 0)
local second = makeSquare(400, 401, 0)
local function coil(floor, facing)
    facing = facing or 0
    local object = IsoThumpable.new(getCell(), floor, "omhtt_barrier_01_" .. (60 + facing), false)
    floor:AddSpecialObject(object)
    B.onWireCreate({thumpable = object})
    local x, y = floor.x + facing % 2, floor.y + 1 - facing % 2
    local otherFloor = getCell():getGridSquare(x, y, 0) or makeSquare(x, y, 0)
    local otherObject = IsoThumpable.new(getCell(), otherFloor, "omhtt_barrier_01_" .. (72 + facing), false)
    otherFloor:AddSpecialObject(otherObject)
    B.onWireCreate({thumpable = otherObject})
    check(B.record(otherObject) == B.record(object), "Both wire halves resolve one durable identity")
    return object, B.record(object), otherObject
end
local object, record = coil(square)
local adjacent, other = coil(second)
local zombie = makeZombie(square, 10)
function zombie:getX() return self.x end
function zombie:getY() return self.y end
function zombie:getNextX() return self.nx end
function zombie:getNextY() return self.ny end
function zombie:setNextX(value) self.nx = value end
function zombie:setNextY(value) self.ny = value end
function zombie:isClimbing() return self.climbing == true end
function zombie:isBumpFall() return self.falling == true end
function zombie:getWidth() return .3 end
function zombie:getEmitter() return {playSound = function() return 1 end, setVolume = function() end} end
zombie.x, zombie.y, zombie.nx, zombie.ny = 400.5, 400.5, 400.9, 400.7
B.zombie(zombie)
check(math.abs(zombie.nx - 400.7) < .00001 and math.abs(zombie.ny - 400.6) < .00001,
    "Wire halves the current step without touching base speed")
check(record.health == 49 and math.abs(zombie.health - 9.9) < .00001, "Coil loses one durability per damaging activation")
zombie.nx, zombie.ny = 401.3, 400.9
B.time = B.time + 100
B.zombie(zombie)
check(math.abs(zombie.nx - 400.9) < .00001 and record.health == 49,
    "A changed external movement step is halved during damage cooldown without another activation")
-- Simulate overlapping geometry to verify the combined handler still applies one factor and one timer.
local overlap, overlapping = coil(square)
B.time = B.time + 2000
zombie.nx, zombie.ny = 400.9, 400.7
B.zombie(zombie)
check(math.abs(zombie.nx - 400.7) < .00001 and record.health + overlapping.health == 98,
    "Overlapping hazards cannot stack slowing or damage")
B.retire(overlapping)
zombie.climbing, zombie.nx = true, 400.9
B.zombie(zombie)
check(zombie.nx == 400.9, "Native vault/climb motion bypasses custom movement scaling")
zombie.climbing, zombie.falling = false, true
B.zombie(zombie)
check(zombie.nx == 400.9, "Native fall displacement bypasses custom movement scaling")
zombie.falling, zombie.square = false, makeSquare(402, 400, 0)
zombie.x, zombie.nx = 402.5, 403.3
B.zombie(zombie)
check(zombie.nx == 403.3, "Leaving wire requires no stored-speed restoration")
zombie.square, zombie.x, zombie.nx = square, 400.5, 400.9
SandboxVars.OMHTurretsTraps.BarbWire = false
B.zombie(zombie)
check(zombie.nx == 400.9, "Disabling wire ends its contact effects immediately")
SandboxVars.OMHTurretsTraps.BarbWire = true

local scratches, cuts = 0, 0
local player = {square = square, moving = true, running = false, sprinting = false, nx = 400.9, ny = 400.7}
function player:getSquare() return self.square end
function player:getX() return self.square.x + .5 end
function player:getY() return self.square.y + .5 end
function player:getZ() return 0 end
function player:getPlayerNum() return 3 end
function player:getWidth() return .3 end
function player:getNextX() return self.nx end
function player:getNextY() return self.ny end
function player:setNextX(value) self.nx = value end
function player:setNextY(value) self.ny = value end
function player:isDead() return false end
function player:isNoClip() return self.noclip == true end
function player:isGhostMode() return false end
function player:isGodMod() return self.god == true end
function player:isKnockedDown() return false end
function player:isRagdoll() return false end
function player:isClimbing() return false end
function player:isBumpFall() return false end
function player:isOnFloor() return self.floor == true end
function player:isPlayerMoving() return true end
function player:isRunning() return self.running end
function player:isSprinting() return self.sprinting end
function player:setVariable(name, value) self[name] = value end
function player:clearVariable() end
function player:setBumpType(value) self.bump = value end
function player:setBumpFall(value) self.trip = value end
function player:reportEvent() end
function player:getBodyDamage() return {getBodyPart = function() return {
    setScratched = function() scratches = scratches + 1 end,
    setCut = function() cuts = cuts + 1 end,
} end} end
testRoll = 0
Beds.player(player)
check(scratches == 0 and math.abs(player.nx - 400.7) < .00001, "Walking through wire slows safely")
player.square = zombie.square
player.noclip = true
Beds.player(player)
player.noclip, player.running, player.sprinting = false, true, true
Beds.player(player)
check(scratches == 1 and player.trip, "Sprint contact uses the approved entry scratch and trip rules")
player.square = second
Beds.player(player)
check(scratches == 1, "Independent adjoining coils do not reroll player entry injuries")
player.floor = true
Beds.player(player); Beds.player(player)
check(cuts == 1, "A fresh wire landing causes one cut, never repeated prone damage")
player.noclip = true
Beds.player(player)
player.noclip, player.floor, player.god, player.trip = false, false, true, false
Beds.player(player)
check(scratches == 1 and not player.trip, "God mode prevents barb injury and trips")
local inventory = {items = {}, room = true}
function inventory:hasRoomFor() return self.room end
function inventory:AddItem(item) self.items[#self.items + 1] = item; return item end
function player:getInventory() return inventory end
function player:isBuildCheat() return false end
function player:setHaloNote() end
function second:isSomethingTo() return false end
other.health = 12
testRepairSupply(player, "Wire")
check(Service.apply(player, adjacent, other.id, "Repair") and other.health == 50, "Wire repair consumes one scrap with retained Pliers")
inventory.room = false
check(not Service.apply(player, adjacent, other.id, "Remove") and B.record(adjacent), "Full inventory blocks recovery without losing wire")
inventory.room = true
check(Service.apply(player, adjacent, other.id, "Remove") and #inventory.items == 1 and adjacent.removed,
    "Wire pickup yields exactly one recovered coil")
check(not Service.apply(player, adjacent, other.id, "Remove") and #inventory.items == 1, "Repeated pickup cannot duplicate a coil")
B.retire(record)
check(B.contact(zombie) == nil, "Depleted/removed coil cannot strand movement contact")
for facing = 0, 3 do
    local floor = makeSquare(450 + facing * 4, 450, 0)
    local tailFloor = makeSquare(floor.x + facing % 2, floor.y + 1 - facing % 2, 0)
    function floor:isSolid() return false end
    function floor:isSolidTrans() return false end
    function tailFloor:isSolid() return false end
    function tailFloor:isSolidTrans() return false end
    function floor:isSomethingTo() return self.blocked == true end
    function tailFloor:isSomethingTo() return false end
    local direction = ({"e", "n", "w", "s"})[facing + 1]
    local params = {square = floor, facing = direction, tileInfo = {getX = function() return 0 end, getY = function() return 0 end}}
    check(B.onWireValid(params), "Both rotated wire tiles accept clear connected floors")
    floor.blocked = true
    check(not B.onWireValid(params), "Wire pair cannot span a wall")
    floor.blocked = false
    local head, pair, tail = coil(floor, facing)
    check(not B.onWireValid(params), "Occupied paired footprint rejects duplicate placement")
    zombie.square, zombie.x, zombie.y = floor, floor.x + .5, floor.y + .5
    B.time = B.time + 3000
    B.zombie(zombie)
    check(pair.health == 49, "First half wears shared durability once")
    zombie.square, zombie.x, zombie.y = tailFloor, tailFloor.x + .5, tailFloor.y + .5
    B.zombie(zombie)
    check(pair.health == 49 and B.contact(zombie) == pair, "Crossing the seam preserves contact and damage cooldown")
    B.time = B.time + 2000
    B.zombie(zombie)
    check(pair.health == 48, "Second half wears the same durability pool")
    B.initialize()
    B.loaded(tailFloor); B.loaded(floor)
    check(B.record(head) == B.record(tail) and #B.order == 1 and B.record(tail).health == 48,
        "Reload order restores a single shared pool and scheduler entry")
    local tailKey = require("OMHTT/Foundation").key(tailFloor.x, tailFloor.y, 0)
    testSquares[tailKey] = nil
    local _, _, _, unloadedStatus = B.resolve(pair)
    check(unloadedStatus == "unloaded" and B.store.wires[pair.id] == pair, "Unloaded partner preserves shared durability")
    testSquares[tailKey] = tailFloor
    player.square, player.god = tailFloor, false
    testRepairSupply(player, "Wire")
check(Service.apply(player, tail, pair.id, "Repair") and pair.health == 50, "Either half repairs the whole trap")
    local count = #inventory.items
    check(Service.apply(player, tail, pair.id, "Remove") and head.removed and tail.removed and #inventory.items == count + 1,
        "Pickup from the second half removes both and yields one item")
    check(not Service.apply(player, head, pair.id, "Remove") and #inventory.items == count + 1, "Other-half pickup replay cannot refund again")
    local first, replacement, last = coil(floor, facing)
    B.removed(last)
    tailFloor:transmitRemoveItemFromSquare(last)
    check(first.removed and not B.store.wires[replacement.id] and not B.nodes[replacement.id], "External half removal retires the complete trap")
    local stale = IsoThumpable.new(getCell(), tailFloor, "omhtt_barrier_01_" .. (72 + facing), false)
    stale:getModData().OMHTTBarbFrame = {id = replacement.id, paired = true, kind = "wire"}
    tailFloor:AddSpecialObject(stale)
    B.loaded(tailFloor)
    check(stale.removed, "A retired half loading later cannot resurrect contact or inventory")
    local depletedHead, depleted, depletedTail = coil(floor, facing)
    depleted.health = 1
    zombie.square, zombie.x, zombie.y = floor, floor.x + .5, floor.y + .5
    B.time = B.time + 3000
    B.zombie(zombie)
    check(depletedHead.removed and depletedTail.removed and not B.store.wires[depleted.id], "Final damage activation breaks both halves")
end
testResults[#testResults + 1] = "Concertina contact, movement, player injuries and recovery: passed"
