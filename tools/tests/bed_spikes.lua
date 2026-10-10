local C = require("OMHTT/BedContact")
local B = require("OMHTT/BedSpikes")
local F = require("OMHTT/Foundation")
local state = {}
local frame = {now = 100, recovery = 5000, prone = false, down = false, crawler = false,
    moving = true, bed = "bed-a", tile = "1:1:0", x = 1.5, y = 1.5}
local hit, roll = C.step(state, frame)
check(not hit and roll, "First upright bed entry offers a chance, not guaranteed damage")
hit, roll = C.step(state, frame)
check(not hit and not roll, "Standing in one tile cannot reroll every update")
frame.tile, frame.x = "2:1:0", 1.6
hit, roll = C.step(state, frame)
check(not roll, "Boundary jitter does not create another trip roll")
frame.x = 2.5
hit, roll = C.step(state, frame)
check(roll, "Real movement into another tile permits another chance")
frame.prone, frame.down = true, true
hit, roll = C.step(state, frame)
check(hit and not roll, "A fresh fall from any source lands one hit")
frame.bed = "bed-b"
for i = 1, 50 do
    frame.now = frame.now + 100
    hit, roll = C.step(state, frame)
    check(not hit and not roll, "Lying across adjacent beds cannot duplicate a fall")
end
frame.prone = false
hit, roll = C.step(state, frame)
check(not hit and not roll, "Getting up remains protected before floor flags finish changing")
frame.down = false
frame.now = 6000
C.step(state, frame)
check(state.protectedUntil == 11000, "Five-second protection begins after complete recovery")
frame.tile, frame.x, frame.now = "3:1:0", 3.5, 10999
hit, roll = C.step(state, frame)
check(not hit and not roll, "Neighbor bed shares recovery protection")
frame.now = 11000
hit, roll = C.step(state, frame)
check(roll, "Fresh movement can trip again after five seconds")
frame.prone, frame.down = true, true
hit, roll = C.step(state, frame)
check(hit, "Second genuinely new fall can deal damage")
state = {}
hit, roll = C.step(state, frame)
check(not hit and not roll, "First observation of an already-prone zombie does not damage it")
frame.crawler = true
frame.prone, frame.down = false, false
C.step(state, frame)
frame.now = 99999
frame.prone = true
hit, roll = C.step(state, frame)
check(not hit and not roll, "Existing crawlers neither trip nor accumulate fall damage")

B.initialize()
testSquares = {}
local candidate = makeSquare(9, 9, 0)
function candidate:isSolid() return self.solid == true end
function candidate:isSolidTrans() return false end
check(B.clear(candidate), "Clear floor permits bed placement")
local panel = IsoThumpable.new(getCell(), candidate, "omhtt_barrier_01_52", false, nil)
panel:getModData().OMHTTBarbFrame = {id = "placement-panel"}
candidate:AddSpecialObject(panel)
local fence = IsoThumpable.new(getCell(), candidate, "carpentry_02_80", false, nil)
function fence:isDoor() return false end
function fence:isWindow() return false end
function fence:isHoppable() return true end
function fence:isTallHoppable() return false end
candidate:AddSpecialObject(fence)
check(B.clear(candidate), "Fence and attached panel do not occupy the adjacent floor footprint")
candidate.solid = true
check(not B.clear(candidate), "Solid obstacles remain blocked beside panels")
candidate.solid = false
local obstruction = IsoThumpable.new(getCell(), candidate, "omhtt_barrier_01_28", false, nil)
obstruction:getModData().OMHTTBed = {id = "occupied"}
candidate:AddSpecialObject(obstruction)
check(not B.clear(candidate), "Existing bed cannot be overlapped")
local square, second = makeSquare(10, 10, 0), makeSquare(10, 11, 0)
local a = IsoThumpable.new(getCell(), square, "omhtt_barrier_01_28", false, nil)
local b = IsoThumpable.new(getCell(), second, "omhtt_barrier_01_29", false, nil)
square:AddSpecialObject(a)
second:AddSpecialObject(b)
B.onCreate({thumpable = a, facing = "e"})
B.onCreate({thumpable = b, facing = "e"})
local record = B.record(a)
check(record == B.record(b) and record.health == 100 and #B.parts(record) == 2, "Both native callbacks adopt one bed and health pool")
check(a.passThrough and b.passThrough and not a.hoppable and not a.thumpable, "Beds are passable and cannot be vaulted or thumped")
local tripper = makeZombie(square, 10)
function tripper:isGettingUp() return false end
function tripper:isCrawling() return false end
function tripper:getBumpType() return self.bump or "" end
function tripper:setBumpType(value) self.bump = value end
B.zombie(tripper)
tripper.square = second
testRoll = 0
B.zombie(tripper)
check(tripper.bump == "OMHTTBedTrip" and tripper.variables.SprinterTripped == false and not tripper.nativeKnockdown,
    "Winning entry requests forward stumble with fresh native recovery flags and no shove")
check(record.health == 100, "Requesting a fall does not charge damage or wear before landing")
local zombie = makeZombie(square, 10)
local impacts = 0
function zombie:getEmitter() return {playSound = function(_, name)
    check(name == "SpearCraftedHit", "Bed impact uses the registered native crafted-spear hit")
    impacts = impacts + 1
end} end
function zombie:isGettingUp() return self.gettingUp == true end
function zombie:isCrawling() return self.crawler == true end
function zombie:getBumpType() return self.bump or "" end
function zombie:setBumpType(value) self.bump = value end
B.zombie(zombie)
zombie.floor, zombie.knocked = true, true
B.zombie(zombie)
check(math.abs(zombie.health - 9.8) < .00001 and record.health == 94 and a.health == 94 and b.health == 94,
    "Fresh fall applies 20 damage and six wear once to shared durability")
for i = 1, 30 do B.zombie(zombie) end
check(record.health == 94 and math.abs(zombie.health - 9.8) < .00001, "Prone updates cannot repeat wear or damage")
check(impacts == 1, "A damaging fall plays one impact; prone updates stay silent")
zombie.floor, zombie.knocked, zombie.gettingUp = false, false, false
B.zombie(zombie)
record.tier, record.maxHealth, record.health = "reinforced", 200, 200
B.configure(record, a)
B.configure(record, b)
zombie.floor = true
B.zombie(zombie)
check(math.abs(zombie.health - 9.3) < .00001 and record.health == 194, "External falls retain 50 reinforced damage during trip protection")
check(a.sprite == "omhtt_barrier_01_44" and b.sprite == "omhtt_barrier_01_45", "Reinforcement updates both registered part identities")
zombie.floor, zombie.knocked = false, false
B.zombie(zombie)
local protection = zombie.data.OMHTTBedContact.protectedUntil
B.time = B.time + 2000
B.zombie(zombie)
check(zombie.data.OMHTTBedContact.protectedUntil == protection, "Leaving nearby tracking cannot erase shared trip protection")
B.session = "reload-fixture"
local remaining = protection - zombie.data.OMHTTBedContact.seen
B.time = 0
B.zombie(zombie)
check(zombie.data.OMHTTBedContact.protectedUntil == remaining, "Fresh session rebases unexpired trip protection without offline progress")
B.store = nativeRoundTrip(B.store)
record = B.record(a)
check(record == B.record(b) and record.health == 194 and record.tier == "reinforced", "Authority survives native serialization without split health")
record.health = 2
zombie.floor = false
B.zombie(zombie)
zombie.floor = true
B.zombie(zombie)
check(B.record(a) == nil and a.removed and b.removed, "Last damaging fall retires both parts without nested removal")
check(B.tiles[F.key(10, 10, 0)] == nil and B.nearby[F.key(10, 10, 0)] == nil, "Retirement clears collision-free contact index")

square, second = makeSquare(12, 10, 0), makeSquare(12, 11, 0)
a = IsoThumpable.new(getCell(), square, "omhtt_barrier_01_28", false, nil)
b = IsoThumpable.new(getCell(), second, "omhtt_barrier_01_29", false, nil)
square:AddSpecialObject(a); second:AddSpecialObject(b)
B.onCreate({thumpable = a, facing = "e"}); B.onCreate({thumpable = b, facing = "e"})
square:transmitRemoveItemFromSquare(a)
check(not b.removed and #B.removals == 1, "External deletion defers companion cleanup outside native removal callback")
B.tick()
check(b.removed and #B.removals == 0, "Bounded cleanup removes orphan companion next tick")

square, second = makeSquare(14, 10, 0), makeSquare(14, 11, 0)
a = IsoThumpable.new(getCell(), square, "omhtt_barrier_01_28", false, nil)
b = IsoThumpable.new(getCell(), second, "omhtt_barrier_01_29", false, nil)
square:AddSpecialObject(a); second:AddSpecialObject(b)
B.onCreate({thumpable = a, facing = "e"}); B.onCreate({thumpable = b, facing = "e"})
record = B.record(a)
function square:isSomethingTo(other) return self.blocked or other.blocked end
local scratches, cuts, animation = 0, 0, nil
local inventory = {room = false, items = {}}
function inventory:hasRoomFor() return self.room end
function inventory:AddItem(item) self.items[#self.items + 1] = item end
local player = {running = false, sprinting = false, square = square}
function player:isDead() return false end
function player:isNoClip() return self.noclip == true end
function player:isGhostMode() return self.ghost == true end
function player:isOnFloor() return self.floor == true end
function player:clearVariable() end
function player:setBumpType(value) self.bump = value end
function player:setBumpFall(value) self.bumpFall = value end
function player:setBumpFallType(value) self.bumpFallType = value end
function player:reportEvent(value) self.event = value end
function player:getSquare() return self.square end
function player:getX() return self.square.x + .5 end
function player:getY() return self.square.y + .5 end
function player:getZ() return 0 end
function player:getPlayerNum() return 0 end
function player:isPlayerMoving() return true end
function player:isRunning() return self.running end
function player:isSprinting() return self.sprinting end
function player:isGodMod() return false end
function player:setVariable(name, value) animation = value end
function player:getInventory() return inventory end
function player:setHaloNote() end
function player:isBuildCheat() return true end
function player:getBodyDamage() return {getBodyPart = function() return {setScratched = function(_, value, safe)
    check(value and safe, "Bed scratch uses environmental non-infected damage")
    scratches = scratches + 1
end, setCut = function(_, value, safe)
    check(value and safe, "Fall laceration is environmental, not zombie infection")
    cuts = cuts + 1
end} end} end
testRoll = 0
B.player(player)
check(scratches == 0 and animation, "Walking brushes through without injury even on winning scratch roll")
player.square = makeSquare(13, 10, 0)
B.player(player)
check(not animation, "Exiting clears custom movement variable")
player.square, player.running = square, true
B.player(player)
player.square = second
B.player(player)
check(scratches == 1, "Running scratches once across the whole two-tile bed")
player.square = testSquares[F.key(13, 10, 0)]
B.player(player)
player.square, player.running, player.sprinting = square, false, true
B.player(player)
check(scratches == 2, "Sprinting inherits the per-entry running risk")
check(player.bumpFall and player.bump == "OMHTTBedTrip" and not player.bumpFallType and player.event == "wasBumped",
    "Winning sprint entry requests forward fall without pushedFront backward animation")
player.floor = true
B.player(player)
B.player(player)
check(cuts == 1, "Only an actual new landing causes one laceration")
player.floor, player.noclip = false, true
B.player(player)
check(not animation and cuts == 1 and scratches == 2, "Noclip clears brush and bypasses bed injury")
player.noclip, player.ghost = false, true
B.player(player)
check(not animation and cuts == 1 and scratches == 2, "Ghost mode also bypasses foliage")
player.ghost, player.running, player.sprinting = false, false, false
B.player(player)
check(animation and cuts == 1 and scratches == 2, "Normal safe walking resumes after leaving noclip")
player.floor = true
B.player(player)
check(cuts == 2, "A second distinct fall can injure again")
player.floor = false
B.player(player)

local S = require("OMHTT/BedService")
record.health = 40
check(S.apply(player, a, record.id, "Repair") and record.health == 100 and a.health == 100 and b.health == 100,
    "Free repair restores both tiles from one shared record")
SandboxVars.OMHTurretsTraps.SpikeBarrier = false
check(S.apply(player, a, record.id, "Reinforce") and record.health == 200 and record.tier == "reinforced",
    "Bed reinforcement works independently of the Spike Barrier switch")
local oldSpecific, oldContext = getSpecificPlayer, ISContextMenu
getSpecificPlayer = function() return player end
local function newMenu()
    local result = {numOptions = 1, options = {}}
    function result:addOption(name, target, callback, ...)
        local option = {name = name, target = target, callback = callback}
        self.options[self.numOptions] = option
        self.numOptions = self.numOptions + 1
        return option
    end
    function result:addSubMenu(option, submenu) self.submenu = submenu end
    return result
end
ISContextMenu = {getNew = function() return newMenu() end}
local context = newMenu()
local handlers = Events.OnFillWorldObjectContextMenu.handlers
handlers[#handlers](0, context, {a}, false)
check(context.numOptions == 2 and context.submenu.numOptions == 4
    and context.submenu.options[3].onHighlightParams[1][2] == b,
    "Native next-slot menu indexing safely binds both-part highlighting")
getSpecificPlayer, ISContextMenu = oldSpecific, oldContext
function player:faceThisObject() end
function player:shouldBeTurning() return false end
function player:setIsFarming() end
local oldGameTime = getGameTime
local oldQueue = ISTimedActionQueue
ISTimedActionQueue = {getTimedActionQueue = function() return {resetQueue = function() end} end}
getGameTime = function() return {getRealworldSecondsSinceLastUpdate = function() return .1 end} end
record.health = 80
local action = OMHTTBedServiceAction:new(player, a, record.id, "Repair")
action.action = {setActionAnim = function() end, setAnimVariable = function() end,
    setOverrideHandModelsObject = function() end, setJobDelta = function() end,
    forceComplete = function() action.forced = true end}
action:start()
for i = 1, 99 do action:update() end
check(not action.forced and not action:complete() and record.health == 80, "Bed service cannot finish before ten active seconds")
action:update(); action:update()
check(action.forced and action:complete() and record.health == 200 and not action:complete(), "Bed timed repair restores both parts exactly once")
action = OMHTTBedServiceAction:new(player, a, record.id, "Pickup")
action.action = {setActionAnim = function() end, setAnimVariable = function() end,
    setOverrideHandModelsObject = function() end, setJobDelta = function() end}
action:start(); action:update(); action:stop()
check(not action:complete() and B.record(a) == record and action.stopOnWalk and action.stopOnRun,
    "Cancelled bed pickup preserves the bed and native movement interrupts")
getGameTime = oldGameTime
ISTimedActionQueue = oldQueue
check(not S.apply(player, a, record.id, "Pickup") and B.record(a), "Full inventory preserves bed and both parts")
inventory.room = true
check(S.apply(player, a, record.id, "Pickup") and #inventory.items == 1 and a.removed and b.removed,
    "Pickup retires both tiles and returns exactly one item")
check(not S.apply(player, a, record.id, "Pickup") and #inventory.items == 1, "Stale pickup cannot duplicate a portable bed")
