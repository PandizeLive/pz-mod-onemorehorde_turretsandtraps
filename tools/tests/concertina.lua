local B = require("OMHTT/BarbSections")
local Beds = require("OMHTT/BedSpikes")
local Service = require("OMHTT/BarbService")
B.initialize()
testMode, testLoaded = "sp", true
SandboxVars.OMHTurretsTraps.BarbSections = true
SandboxVars.OMHTurretsTraps.BarbWire = true
local square = makeSquare(400, 400, 0)
local second = makeSquare(400, 401, 0)
local function coil(floor)
    local object = IsoThumpable.new(getCell(), floor, "omhtt_barrier_01_60", false)
    floor:AddSpecialObject(object)
    B.onWireCreate({thumpable = object})
    return object, B.record(object)
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
function inventory:AddItem(item) self.items[#self.items + 1] = item end
function player:getInventory() return inventory end
function player:isBuildCheat() return false end
function player:setHaloNote() end
function second:isSomethingTo() return false end
other.health = 12
check(Service.apply(player, adjacent, other.id, "Repair") and other.health == 50, "Wire repair is free and tool-free")
inventory.room = false
check(not Service.apply(player, adjacent, other.id, "Remove") and B.record(adjacent), "Full inventory blocks recovery without losing wire")
inventory.room = true
check(Service.apply(player, adjacent, other.id, "Remove") and #inventory.items == 1 and adjacent.removed,
    "Wire pickup yields exactly one recovered coil")
check(not Service.apply(player, adjacent, other.id, "Remove") and #inventory.items == 1, "Repeated pickup cannot duplicate a coil")
B.retire(record)
check(B.contact(zombie) == nil, "Depleted/removed coil cannot strand movement contact")
testResults[#testResults + 1] = "Concertina contact, movement, player injuries and recovery: passed"
