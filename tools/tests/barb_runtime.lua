local B = require("OMHTT/BarbSections")
local S = require("OMHTT/BarbSupport")
local Service = require("OMHTT/BarbService")
local F = require("OMHTT/Foundation")
testMode, testLoaded = "sp", true
testSquares = {}
IsoPropertyType = {DOUBLE_DOOR = "double", GARAGE_DOOR = "garage"}
SandboxVars.OMHTurretsTraps.Enabled, SandboxVars.OMHTurretsTraps.BarbSections = true, true
B.initialize()
local originalCtor = IsoThumpable.new
IsoThumpable.new = function(cell, square, sprite, north)
    local o = originalCtor(cell, square, sprite, north)
    function o:isDoor() return false end
    function o:isWindow() return false end
    function o:isDestroyed() return self.health ~= nil and self.health <= 0 end
    return o
end
local faces = {"e", "n", "w", "s"}
local records, hosts, frames = {}, {}, {}
for i = 1, #faces do
    local floor = makeSquare(100 + i * 10, 100, 0)
    function floor:getCell() return getCell() end
    function floor:isSolid() return false end
    function floor:isSolidTrans() return false end
    local x, y, north = require("OMHTT/BarbContact").edge(floor.x, floor.y, faces[i])
    local square = testSquares[F.key(x, y, 0)] or makeSquare(x, y, 0)
    function square:getCell() return getCell() end
    local host = IsoThumpable.new(getCell(), square, "test-wall", north)
    host.kind, host.health = "IsoWindow", 50
    function host:IsOpen() return self.open == true end
    function host:isSmashed() return self.smashed == true end
    square:AddSpecialObject(host)
    local params = {square = floor, facing = faces[i]}
    check(B.onIsValid(params) and params.testCollisions == false, "Four orientations accept exact backing")
    local temporary = IsoThumpable.new(getCell(), floor, "omhtt_barrier_01_52", north)
    floor:AddSpecialObject(temporary)
    local result = B.onCreate({thumpable = temporary, facing = faces[i]})
    local frame = result.object
    local record = B.record(frame)
    records[i], hosts[i], frames[i] = record, host, frame
    check(temporary.removed and frame.passThrough and not frame.thumpable and host.health == 50, "Native replacement preserves host HP and adds no blocking collider")
    check(not B.onIsValid(params), "Duplicate placement is blocked")
    check(B.onCreate({thumpable = temporary, facing = faces[i]}) == nil, "Duplicate create cannot attach again")
    check(B.resolve(record) == frame, "Frame and exact support resolve")
end
check(#B.order == 4, "One index entry per section")
local record, host, frame = records[4], hosts[4], frames[4]
local attachment = host.data.OMHTTBarbs[S.faceKey(record.north, record.side)]
local zombie = makeZombie(host.square, 10)
function zombie:getWidth() return .3 end
function zombie:getX() return self.x end
function zombie:getY() return self.y end
zombie.x, zombie.y = record.x + .5, record.y + .15
B.zombie(zombie)
check(math.abs(zombie.health - 9.9) < .00001 and attachment.health == 49 and host.health == 50, "First runtime hit wears only window barbs")
local savedResolve, contactLookups = B.resolve, 0
B.resolve = function(r) contactLookups = contactLookups + 1 return savedResolve(r) end
for i = 1, 60 do B.zombie(zombie) end
check(attachment.health == 49 and contactLookups == 0, "Cooldown skips redundant geometry and support lookups")
B.resolve = savedResolve
B.time = 2000
B.zombie(zombie)
check(attachment.health == 48, "Recurring runtime contact wears once")
zombie.y = record.y + .8
B.time = 4000
B.zombie(zombie)
check(attachment.health == 48, "Runtime exit stops damage and wear")
host.open, host.smashed, host.health = true, true, 0
zombie.y = record.y + .15
B.zombie(zombie)
check(attachment.health == 47 and host.health == 0, "Smashed open glass leaves independent frame barbs active")
local player = {}
function player:isDead() return false end
function player:getX() return self.x end
function player:getY() return self.y end
function player:getZ() return self.z end
player.square, player.x, player.y, player.z = host.square, record.x + .5, record.y + .5, 0
function player:getSquare() return self.square end
function player:isBuildCheat() return true end
function host.square:isSomethingTo() return false end
check(Service.apply(player, frame, record.id, "Repair") and attachment.health == 50 and host.health == 0, "Barb repair cannot repair glass")
local oldGameTime, oldQueue = getGameTime, ISTimedActionQueue
getGameTime = function() return {getRealworldSecondsSinceLastUpdate = function() return .1 end} end
ISTimedActionQueue = {getTimedActionQueue = function() return {resetQueue = function() end} end}
function player:faceThisObject() end
function player:shouldBeTurning() return false end
function player:setIsFarming() end
attachment.health = 20
local action = OMHTTBarbServiceAction:new(player, frame, record.id, "Repair")
action.action = {setActionAnim = function() end, setAnimVariable = function() end,
    setOverrideHandModelsObject = function() end, setJobDelta = function() end,
    forceComplete = function() action.forced = true end}
action:start()
for i = 1, 99 do action:update() end
check(not action:complete() and attachment.health == 20, "Barb repair cannot finish before ten active seconds")
action:update(); action:update()
check(action.forced and action:complete() and attachment.health == 50 and not action:complete(), "Timed repair completes exactly once")
local cancelled = OMHTTBarbServiceAction:new(player, frame, record.id, "Remove")
cancelled.action = {setActionAnim = function() end, setOverrideHandModelsObject = function() end}
cancelled:start(); cancelled:stop()
check(not cancelled:complete() and not frame.removed, "Cancelled removal preserves barbs")
getGameTime, ISTimedActionQueue = oldGameTime, oldQueue
check(not Service.apply(player, frame, "stale", "Remove"), "Stale service identity is rejected")
player.x = record.x + 10
check(not Service.apply(player, frame, record.id, "Remove"), "Remote service is rejected")
player.x = record.x + .5
check(Service.apply(player, frame, record.id, "Remove") and frame.removed, "Removal retires the section")
check(not Service.apply(player, frame, record.id, "Remove"), "Removal replay cannot repeat")
local other = records[1]
testLoaded = false
B.tick()
check(#B.order == 0, "Bounded maintenance drops unloaded references without destroying supports")
testLoaded = true
for i = 1, 3 do B.loaded(hosts[i].square) end
check(#B.order == 3 and B.resolve(other) == frames[1], "Reload restores identities from world markers")
local old = hosts[1]
old.removed = true
for i = #old.square.objects, 1, -1 do
    if old.square.objects[i] == old then table.remove(old.square.objects, i) end
end
B.tick()
check(frames[1].removed and not B.nodes[other.id], "Backing loss retires orphan marker")
SandboxVars.OMHTurretsTraps.BarbSections = false
check(not B.enabled(), "Barb switch disables contact independently")
SandboxVars.OMHTurretsTraps.BarbSections = true
IsoThumpable.new = originalCtor
B.initialize()
for i = 1, 1000 do B.index({id = "load-" .. i, x = i, y = 0, z = 0}, true) end
local oldResolve, visits = B.resolve, 0
B.resolve = function() visits = visits + 1 return nil, nil, nil, "unloaded" end
B.tick()
check(visits == 4 and #B.order == 996, "Dense cleanup processes at most four sections per tick")
B.resolve = oldResolve
B.initialize()
local before = B.time
local oldPaused = GameTime.isGamePaused
GameTime.isGamePaused = function() return true end
testMillis = testMillis + 10000
B.tick()
check(B.time == before, "Paused clock cannot accelerate contact damage")
GameTime.isGamePaused = oldPaused
testMillis = testMillis + 10000
B.tick()
check(B.time == before + 100, "Long stalled frames cannot create catch-up damage bursts")
testResults[#testResults + 1] = "Barb runtime/placement/lifecycle/service: passed"
