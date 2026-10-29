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
function zombie:isClimbing() return false end
function zombie:isBumpFall() return false end
function zombie:getNextX() return self.nx or self.x end
function zombie:getNextY() return self.ny or self.y end
function zombie:setNextX(value) self.nx = value end
function zombie:setNextY(value) self.ny = value end
function zombie:getWidth() return .3 end
function zombie:getX() return self.x end
function zombie:getY() return self.y end
zombie.x, zombie.y = record.x + .5, record.y + .15
local sounds = 0
function zombie:getEmitter() return {playSound = function(_, name)
    check(name == "ZombieClawChainlinkFence", "Barb contact uses registered native wire audio")
    sounds = sounds + 1; return 1
end, setVolume = function(_, handle, gain) check(gain == .45, "Contact sound has restrained playback gain") end} end
B.zombie(zombie)
check(sounds == 1, "Successful contact emits a cue")
check(math.abs(zombie.health - 9.9) < .00001 and attachment.health == 49 and host.health == 50, "First runtime hit wears only window barbs")
local savedResolve, contactLookups = B.resolve, 0
B.resolve = function(r) contactLookups = contactLookups + 1 return savedResolve(r) end
for i = 1, 60 do B.zombie(zombie) end
check(attachment.health == 49 and contactLookups > 0, "Damage cooldown retains continuous contact checks without extra wear")
B.resolve = savedResolve
B.time = 2000
B.zombie(zombie)
check(attachment.health == 48 and sounds == 1, "Damage proceeds while the independent crowd audio cap suppresses overlapping cues")
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
function player:getInventory() return testInventory end
function host.square:isSomethingTo() return false end
testRepairSupply(player, "Barb")
check(Service.apply(player, frame, record.id, "Repair") and attachment.health == 50 and host.health == 0, "Barb repair cannot repair glass")
local oldGameTime, oldQueue = getGameTime, ISTimedActionQueue
getGameTime = function() return {getMultiplier = function() return (.1) * 48 end, getMultiplierFromTimeDelta = function() return 48 end} end
ISTimedActionQueue = {getTimedActionQueue = function() return {resetQueue = function() end} end}
function player:faceThisObject() end
function player:shouldBeTurning() return false end
function player:setIsFarming() end
attachment.health = 20
testRepairSupply(player, "Barb")
local action = OMHTTBarbServiceAction:new(player, frame, record.id, "Repair")
action.action = {setActionAnim = function() end, setAnimVariable = function() end,
    setOverrideHandModelsObject = function() end, setJobDelta = function() end,
    forceComplete = function() action.forced = true end}
action:start()
for i = 1, 39 do action:update() end
check(not action:complete() and attachment.health == 20, "Barb repair cannot finish before four active seconds")
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
check(B.time == before, "First resumed sample excludes the paused interval")
testMillis = testMillis + 700
testTime = testTime + 700 / 150000
B.tick()
check(math.abs(B.time - before - 700) < .001, "World-time progress preserves elapsed contact time")
B.initialize()
for x = -1, 1 do
    for y = -1, 1 do B.index({id = "wire-" .. x .. ":" .. y, kind = "wire", x = x, y = y, z = 0}, true) end
end
makeSquare(0,0,0)
local contactActor = {getSquare = function() return {getX = function() return 0 end, getY = function() return 0 end, getZ = function() return 0 end} end,
    getX = function() return .5 end, getY = function() return .5 end, getZ = function() return 0 end}
visits = 0
B.resolve = function(record) visits = visits + 1; return nil, nil, record, "active" end
local touching = B.contact(contactActor)
check(touching and touching.id == "wire-0:0" and visits == 1, "Nine nearby coils resolve only the tile actually occupied")
B.resolve = function() visits = visits + 1; return nil, nil, nil, "missing" end
check(B.contact(contactActor) == nil, "Occupied coil still validates removal instead of trusting stale index")
B.resolve = oldResolve
B.initialize()
testResults[#testResults + 1] = "Barb runtime/placement/lifecycle/service: passed"
