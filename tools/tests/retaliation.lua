local F = require("OMHTT/Foundation")
local S = require("OMHTT/FoundationServer")
local B = require("OMHTT/BarrierRetaliation")
local D = require("OMHTT/Damage")
testMode = "sp"
testData = nil
testSquares = {}
testMillis = testMillis + 10000
testPlayer.x, testPlayer.y, testPlayer.z = 100.5, 100.5, 0
local origin = makeSquare(100, 100, 0)
local square = makeSquare(100, 101, 0)
makeSquare(100, 102, 0)
local otherSquare = makeSquare(101, 101, 0)
S.initialize()
B.reset()
S.onCommand(F.MODULE, "PlaceBarrier", testPlayer,
    {version = F.VERSION, request = 2000, epoch = 0, x = 100, y = 101, z = 0})
local barrier = square.objects[1]
local a, b, bystander = makeZombie(origin, 2), makeZombie(origin, 2), makeZombie(origin, 2)
a.thumpTarget, b.thumpTarget = barrier, barrier
a.state, b.state = "ThumpState", "ThumpState"
B.update(a)
B.update(b)
check(a.health == 2 and a.variables.ThumpType == B.TYPE and b.variables.ThumpType == B.TYPE,
    "exact barrier attackers attach without contact damage")
a.variables[B.TOKEN] = "left"
B.update(a)
check(math.abs(a.health - 1.9) < 0.00001 and b.health == 2 and bystander.health == 2,
    "one native strike marker damages only its attacker by 0.10")
for i = 1, 20 do B.update(a) end
barrier.health = 80
testMillis = testMillis + 10000
B.update(a)
check(math.abs(a.health - 1.9) < 0.00001, "time passage, HP loss and repeated polling cannot invent another strike")
b.variables[B.TOKEN] = "left"
B.update(b)
a.variables[B.TOKEN] = "right"
B.update(a)
check(math.abs(a.health - 1.8) < 0.00001 and math.abs(b.health - 1.9) < 0.00001,
    "alternating strikes and separate attackers have independent deduplication")
SandboxVars.OMHTurretsTraps.SpikeBarrierDamage = 25
a.variables[B.TOKEN] = "left"
B.update(a)
check(math.abs(a.health - 1.55) < 0.00001, "configured 25-damage strike uses native 0.25 health")
SandboxVars.OMHTurretsTraps.SpikeBarrierDamage = 0
a.variables[B.TOKEN] = "right"
B.update(a)
check(math.abs(a.health - 1.55) < 0.00001, "zero retaliation still consumes its strike")
SandboxVars.OMHTurretsTraps.SpikeBarrierDamage = nil

a.thumpTarget = IsoThumpable.new(getCell(), otherSquare, F.SPRITE, false)
a.thumpTarget:setHealth(100)
a.variables[B.TOKEN] = "left"
B.update(a)
check(a.variables.ThumpType == "Door" and a.data.OMHTTBarrierStrike == nil and a.health > 1.54,
    "switching to unrelated object restores vanilla animation and discards stale strike")
a.thumpTarget = barrier
B.update(a)
a.variables[B.TOKEN] = "left"
testMode = "server"
B.update(a)
check(a.health > 1.54 and D.apply(a, 1, "test", "barrier", nil, nil) == 0, "dedicated combat path fails closed")
testMode = "client"
B.update(a)
check(a.health > 1.54, "MP client cannot retaliate independently")
testMode = "sp"
a.state = "WalkTowardState"
B.update(a)
check(a.variables.ThumpType == "Door" and a.data.OMHTTBarrierStrike == nil, "interrupted attack discards marker")
a.state = "ThumpState"
B.update(a)
a.variables[B.TOKEN] = "left"
testMillis = testMillis + 1000
B.reset()
B.update(a)
check(a.health > 1.54 and a.variables[B.TOKEN] == nil, "new session consumes no saved stale marker")
a.variables[B.TOKEN] = "right"
square:transmitRemoveItemFromSquare(barrier)
B.update(a)
check(a.health > 1.54 and a.data.OMHTTBarrierStrike == nil, "removed barrier cannot deal delayed damage")

for _, sample in pairs({{1.8, 4}, {2.1, 5}, {3.5, 7}}) do
    local victim = makeZombie(origin, sample[1])
    for i = 1, sample[2] do D.apply(victim, 0.5, "potato-test", "potato", nil, nil) end
    check(victim:isDead() and victim.kills == 1, "fixed potato calibration and one native kill for starting HP " .. sample[1])
    check(D.apply(victim, 0.5, "potato-test", "potato", nil, nil) == 0 and victim.kills == 1,
        "dead victim cannot repeat damage/death")
end
local victim = makeZombie(origin, 2)
for i = 1, 9 do D.apply(victim, 0.2, "barrier-test", "barrier", nil, nil) end
check(not victim:isDead(), "normal reference survives nine 20-damage strikes")
D.apply(victim, 0.2, "barrier-test", "barrier", nil, nil)
check(victim:isDead() and victim.kills == 1, "tenth 20-damage strike kills without floating-point sliver")
local popup = nil
PixelStrikeIndicator = {Config = {showDamageDealt = true, showOrdinaryHits = true, scale = 100},
    spawn = function(target, value, kind, viewer) popup = {value = value, target = target, kind = kind} end}
local displayed = makeZombie(origin, 2)
D.apply(displayed, 0.2, "barrier-test", "barrier", nil, nil)
check(math.abs(popup.value - 20) < 0.00001 and popup.target == displayed, "optional indicator receives actual damage times configured scale")
popup = nil
D.apply(displayed, 0.001, "potato-test", "splash", nil, nil)
check(popup == nil, "tiny splash does not spam indicator")
PixelStrikeIndicator.Config.showDamageDealt = false
D.apply(displayed, 0.2, "barrier-test", "barrier", nil, nil)
check(popup == nil, "indicator opt-out preserved")
PixelStrikeIndicator = nil
check(D.apply(displayed, 0.2, "barrier-test", "barrier", nil, nil) > 0, "damage works without optional indicator")
