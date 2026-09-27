local F = require("OMHTT/Foundation")
local S = require("OMHTT/FoundationServer")
local P = require("OMHTT/BarrierFootprint")
local C = require("OMHTT/Construction")
local V = require("OMHTT/BarrierVault")
local B = require("OMHTT/BarrierRetaliation")
testMode = "sp"
testData, testSquares = nil, {}
S.initialize()
SandboxVars.OMHTurretsTraps.Enabled, SandboxVars.OMHTurretsTraps.SpikeBarrier = true, true
ClimbOverFenceState = {instance = function() return "ClimbOverFenceState" end}
IdleState = {instance = function() return "idle" end}
PlayerMovementState = {instance = function() return "movement" end}
IsoWindow = {canClimbThroughHelper = function() return not testNativeGateBlocked end}
IsoFlagType = {water = "water"}
BodyPartType = {LowerLeg_L = "left", LowerLeg_R = "right"}
testInjuries, testRolls, testClimbs = 0, 0, 0
function testPlayer:getCurrentSquare() return testSquares[F.key(math.floor(self.x), math.floor(self.y), self.z)] end
function testPlayer:getCurrentState() return self.state end
function testPlayer:getVariableBoolean(name)
    if name == "VaultOverRun" then return self.vaultRun == true end
    if name == "VaultOverSprint" then return self.vaultSprint == true end
    return self.animationStarted == true
end
function testPlayer:getVariableString(name) return self.outcome end
function testPlayer:isGodMod() return self.god == true end
function testPlayer:climbOverFence(direction) testClimbs = testClimbs + 1; self.climbDirection = direction end
function testPlayer:getBodyDamage()
    return {getBodyPart = function(self, leg)
        return {setScratched = function(self, scratch, noInfection)
            check(scratch and noInfection, "scratch is environmental")
            testInjuries = testInjuries + 1
        end}
    end}
end
function ZombRand(maximum) testRolls = testRolls + 1; return testRoll end
ISLogSystem = {logAction = function() end}
ISTimedActionQueue = {getTimedActionQueue = function() return {onCompleted = function() end} end,
    add = function(action) testQueuedVault = action end}

local originalSetInfo = ISBuildIsoEntity.setInfo
local orientations = {}
ISBuildIsoEntity.setInfo = function(self, square, north, sprite) orientations[#orientations + 1] = north end
C.installEdges()
for index = 0, 15 do
    ISBuildIsoEntity.setInfo({}, nil, false, "omhtt_barrier_01_" .. index)
    check(orientations[#orientations] == (math.floor(index / 2) % 2 == 1), "native hook aligns edge for sprite " .. index)
end
ISBuildIsoEntity.setInfo({}, nil, true, "vanilla_sprite")
check(orientations[#orientations] == true, "native hook preserves unrelated orientation")
ISBuildIsoEntity.setInfo = originalSetInfo

local function square(x, y)
    local sq = makeSquare(x, y, 0)
    function sq:HasStairs() return false end
    function sq:HasStairsBelow() return false end
    function sq:has() return false end
    function sq:getVehicleContainer() return self.vehicle end
    function sq:isPlayerAbleToHopWallTo() return not self.wall end
    return sq
end

local function complete(plan, outcome)
    testPlayer.state, testPlayer.animationStarted, testPlayer.outcome = "ClimbOverFenceState", true, outcome or "success"
    V.update(testPlayer)
    testPlayer.x, testPlayer.y = plan.toX + 0.5, plan.toY + 0.5
    V.update(testPlayer)
    testPlayer.state = "idle"
    V.update(testPlayer)
    V.update(testPlayer)
end

for heading = 0, 3 do
    local facing, x, y = heading * 4, 600 + heading * 5, 600
    for dx = -2, 2 do
        for dy = -2, 2 do square(x + dx, y + dy) end
    end
    local secondX, secondY = P.second({x = x, y = y}, facing)
    local parts = {}
    for i = 1, 2 do
        local sq = testSquares[F.key(x, y, 0)]
        if i == 2 then sq = testSquares[F.key(secondX, secondY, 0)] end
        local north = heading % 2 == 1
        local object = IsoThumpable.new(getCell(), sq, "omhtt_barrier_01_" .. (heading * 2 + i - 1), north)
        sq:AddSpecialObject(object)
        P.adoptBuild(object, testPlayer, x, y, facing, "OMHTTSpikeBarrier")
        parts[i] = object
    end
    local record = P.exact(parts[1])
    check(P.rotate(P.slot(parts[1]:getSquare())) == "BarrierRedeploy" and record.facing == facing,
        "debug rotation cannot desynchronize native edge")
    for partIndex = 1, 2 do
        local object = P.colliders(record)[partIndex]
        local sq = object:getSquare()
        for reverse = 0, 1 do
            testPlayer.x, testPlayer.y, testPlayer.z = sq.x + 0.5, sq.y + 0.5, 0
            if reverse == 1 then
                if heading % 2 == 1 then testPlayer.y = testPlayer.y - 1 else testPlayer.x = testPlayer.x - 1 end
            end
            testPlayer.state, testPlayer.god = "idle", false
            local plan = V.plan(testPlayer, object, record.id)
            local front = (reverse == 0) == (heading == 0 or heading == 3)
            check(plan and (plan.side == "front") == front, "both halves/front-rear geometry " .. heading .. "/" .. partIndex .. "/" .. reverse)
            check(B.face(record, testPlayer.x, testPlayer.y) == plan.side, "retaliation and vault risk share edge plane")
            local landing = testSquares[F.key(plan.toX, plan.toY, 0)]
            landing.free = false
            check(not V.plan(testPlayer, object, record.id), "blocked landing cannot queue")
            landing.free = true
            landing.moving = {testPlayer}
            check(not V.plan(testPlayer, object, record.id), "occupied landing cannot queue")
            landing.moving = {}
            testNativeGateBlocked = true
            check(not V.plan(testPlayer, object, record.id), "native landing gate retained")
            testNativeGateBlocked = false
            local beforeRolls, beforeInjuries = testRolls, testInjuries
            V.queue(object, testPlayer, record.id)
            check(testQueuedVault:isValid(), "native derived action valid before starting")
            testQueuedVault:perform()
            check(not V.plan(testPlayer, object, record.id), "concurrent crossing denied")
            testRoll = 0
            complete(plan)
            check(testInjuries == beforeInjuries + (front and 1 or 0), "one scratch only after successful front crossing")
            check(testRolls == beforeRolls + (front and 2 or 0), "rear performs no roll; front performs hazard and leg selection once")
            check(not object:isCanPassThrough() and not object:isHoppable(), "vault never opens collider")
        end
    end
end

local object = P.colliders(P.slot(testSquares[F.key(600, 600, 0)]).device)[1]
local id = P.exact(object).id
local function start()
    testPlayer.x, testPlayer.y, testPlayer.z, testPlayer.state, testPlayer.dead = 601.5, 600.5, 0, "idle", false
    V.queue(object, testPlayer, id)
    local plan = V.plan(testPlayer, object, id)
    testQueuedVault:perform()
    return plan
end
local before = testInjuries
testRoll = 4
complete(start())
check(testInjuries == before, "nonwinning front roll does not scratch")
testPlayer.god = true
testRoll = 0
complete(start())
check(testInjuries == before, "God Mode respects debug invulnerability")
testPlayer.god = false
complete(start(), "fallback")
check(testInjuries == before, "failed animation never scratches")
local interruptedPlan = start()
testPlayer.state, testPlayer.animationStarted, testPlayer.outcome = "ClimbOverFenceState", true, "success"
V.update(testPlayer)
testPlayer.x, testPlayer.y = interruptedPlan.toX + 0.5, interruptedPlan.toY + 0.5
testPlayer.state = "hitreaction"
V.update(testPlayer)
check(testInjuries == before, "hit reaction interrupt after slide does not count as completed vault")
start()
testMillis = testMillis + 1600
V.update(testPlayer)
check(testInjuries == before and V.plan(testPlayer, object, id), "rejected native entry clears without injury")
start()
testPlayer.dead = true
V.update(testPlayer)
check(testInjuries == before, "death cancels without injury")
testPlayer.dead = false
local function resetApproach()
    testPlayer.x, testPlayer.y, testPlayer.z, testPlayer.state = 601.2, 600.5, 0, "idle"
    testPlayer.dead, testPlayer.god = false, false
end
resetApproach()
function testPlayer:getDir() return IsoDirections.W end
local nativePlan = V.plan(testPlayer, object, id)
local nativeBefore = testClimbs
V.onContext(testPlayer, 0)
check(testClimbs == nativeBefore + 1 and testPlayer.climbDirection == IsoDirections.W, "native context event uses facing and enters low-fence state")
complete(nativePlan)
resetApproach()
function testPlayer:getDir() return IsoDirections.W end
function testPlayer:isPlayerMoving() return true end
function testPlayer:isIgnoreAutoVault() return self.ignoreVault == true end
function testPlayer:isSafeToClimbOver() return self.safe ~= false end
local automaticBefore = testClimbs
testPlayer.running = false
V.autoVault(testPlayer)
check(testClimbs == automaticBefore, "walking never auto-vaults")
testPlayer.running, testPlayer.ignoreVault = true, true
V.autoVault(testPlayer)
check(testClimbs == automaticBefore, "vanilla ignore-auto-vault is respected")
testPlayer.ignoreVault, testPlayer.safe = false, false
V.autoVault(testPlayer)
check(testClimbs == automaticBefore, "unsafe running landing rejected")
testPlayer.safe = true
testPlayer.x = 601.8
V.autoVault(testPlayer)
check(testClimbs == automaticBefore, "running farther from edge does not vault early")
testPlayer.x = 601.2
nativePlan = V.plan(testPlayer, object, id)
V.autoVault(testPlayer)
check(testClimbs == automaticBefore + 1 and testPlayer.running, "running approach preserves native run state")
complete(nativePlan)
resetApproach()
testPlayer.running, testPlayer.sprinting = false, true
nativePlan = V.plan(testPlayer, object, id)
V.autoVault(testPlayer)
check(testClimbs == automaticBefore + 2 and testPlayer.sprinting, "sprinting approach preserves native sprint state")
complete(nativePlan)
testPlayer.sprinting = false
function testPlayer:isPlayerMoving() return false end
resetApproach()
testPlayer.x, testPlayer.sprinting, testPlayer.pressed = 601.49, true, true
nativePlan = V.plan(testPlayer, object, id)
nativeBefore = testClimbs
V.autoVault(testPlayer)
check(testClimbs == nativeBefore + 1, "native half-tile feeler can vault while collision stops movement")
testPlayer.state, testPlayer.animationStarted = "ClimbOverFenceState", false
testPlayer.vaultSprint, testPlayer.outcome = true, "success"
V.update(testPlayer)
before = testInjuries
testRoll = 0
testPlayer.x, testPlayer.y = nativePlan.toX + 0.5, nativePlan.toY + 0.5
V.update(testPlayer)
check(testInjuries == before + 1, "sprint root-motion contact scratches without ClimbFenceStarted")
testPlayer.state, testPlayer.vaultSprint = "movement", false
V.update(testPlayer)
check(string.find(testLogs[#testLogs], "result=crossed", 1, true), "sprint root-motion completion is a crossing")
resetApproach()
testPlayer.running, testPlayer.sprinting = true, false
nativePlan = V.plan(testPlayer, object, id)
V.autoVault(testPlayer)
testPlayer.state, testPlayer.animationStarted = "ClimbOverFenceState", false
testPlayer.vaultRun, testPlayer.outcome = true, "success"
V.update(testPlayer)
before = testInjuries
testPlayer.x, testPlayer.y, testPlayer.state = nativePlan.toX + 0.5, nativePlan.toY + 0.5, "movement"
testPlayer.vaultRun = false
V.update(testPlayer)
check(testInjuries == before + 1, "run exit between samples settles one verified crossing contact")
V.update(testPlayer)
check(testInjuries == before + 1, "settled run contact cannot repeat")
testPlayer.running, testPlayer.pressed = false, false
for _, denominator in pairs({0, 1, 50}) do
    SandboxVars.OMHTurretsTraps.SpikeBarrierScratchChance = denominator
    local count, rolls = testInjuries, testRolls
    testRoll = 0
    local plan = start()
    testPlayer.state, testPlayer.animationStarted, testPlayer.outcome = "ClimbOverFenceState", true, "success"
    V.update(testPlayer)
    check(testInjuries == count, "no injury before actual edge contact")
    testPlayer.x, testPlayer.y = plan.toX + 0.5, plan.toY + 0.5
    V.update(testPlayer)
    check(testInjuries == count + (denominator > 0 and 1 or 0), "scratch applies at contact with configured denominator")
    V.update(testPlayer)
    testPlayer.state = "idle"
    V.update(testPlayer)
    check(testRolls == rolls + (denominator > 0 and 2 or 0), "one contact roll only; zero disables injury without disabling crossing")
end
SandboxVars.OMHTurretsTraps.SpikeBarrierScratchChance = nil
before = testInjuries
start()
P.retire(P.slot(object:getSquare(), id), nil)
V.update(testPlayer)
check(testInjuries == before and not V.plan(testPlayer, object, id), "removed barrier cancels without injury or replay")
