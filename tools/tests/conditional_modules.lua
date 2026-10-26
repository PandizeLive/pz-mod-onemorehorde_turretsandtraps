local S = require("OMHTT/TurretStats")
local C = require("OMHTT/TurretConditionalHit")
local I = require("OMHTT/TurretImpactCycle")
local V = require("OMHTT/TurretVolley")
local Damage = require("OMHTT/Damage")
local savedSettings, savedRoll = SandboxVars.OMHTurretsTraps, testRoll
SandboxVars.OMHTurretsTraps, testRoll = {}, 0
for n = 0, 16 do
    local stats = S.resolve({active = {InitialBlow = n, Execute = n, Impact = n}})
    check(math.abs(stats.initialBlow - (n > 0 and .5 + (n - 1) * .2 or 0)) < .000001, "Initial Blow remains uncapped and additive")
    check(math.abs(stats.execute - (n == 0 and 0 or (.18 + (n - 1) * .02))) < .000001, "Execute uses approved first-plus-extra HP threshold")
    check(stats.impact == (n == 0 and 0 or 60 + (n - 1) * 2), "Impact uses approved first-plus-extra chance")
end
SandboxVars.OMHTurretsTraps.ExecuteFirst = 10
SandboxVars.OMHTurretsTraps.ExecuteBonus = 1
check(S.resolve({active = {Execute = 16}}).execute == .25, "Saved Execute tuning remains effective")
SandboxVars.OMHTurretsTraps.ExecuteFirst = 0
SandboxVars.OMHTurretsTraps.ExecuteBonus = 0
check(S.resolve({active = {Execute = 16}}).execute == 0, "Explicit zero Execute tuning stays disabled")
SandboxVars.OMHTurretsTraps = {}
local square = makeSquare(1500, 1500, 0)
local zombie = makeZombie(square, 10)
local stats = S.resolve({active = {InitialBlow = 16, Execute = 1, Impact = 1}})
zombie.health = 9
local eligibility = C.snapshot(zombie, stats)
check(C.damage(zombie, .1, eligibility) == .45, "Exact 90 percent HP grants 4.5x primary damage at sixteen copies")
zombie.health = 8.9999999
check(C.snapshot(zombie, stats).bonus == 4.5, "Native float rounding preserves the Initial Blow boundary")
zombie.health = 8.99
check(C.damage(zombie, .1, C.snapshot(zombie, stats)) == .1, "Below 90 percent receives ordinary damage")
check(C.damage(zombie, .1, eligibility) == .45, "Shotgun eligibility remains fixed for allocated pellets")
zombie.health = 1.80000001
check(C.snapshot(zombie, stats).execute, "Native float rounding preserves the Execute boundary")
zombie.health = 1.801
check(not C.snapshot(zombie, stats).execute, "Above threshold cannot execute")
zombie.health = 1.8
local amount = C.damage(zombie, .01, C.snapshot(zombie, stats))
check(amount == 1.8, "Exact Execute threshold removes actual remaining HP, not magic damage")
Damage.apply(zombie, amount, "test", "firearm", nil, nil)
Damage.apply(zombie, amount, "test", "firearm", nil, nil)
check(zombie.kills == 1, "Execution cannot double-kill or double-award")
zombie = makeZombie(square, 10)
zombie.data.OMHTTInitialHealth = nil
check(not C.snapshot(zombie, stats).execute and C.snapshot(zombie, stats).bonus == 1, "Unknown historical HP does not invent conditional eligibility")
zombie.data.OMHToughnessInitialHealth = 100
check(C.snapshot(zombie, stats).execute, "Horde Night baseline determines the real percentage")
local cycle = {}
I.observe(cycle, 7)
check(cycle.impactReady, "Initially loaded head grants one first-shot entitlement")
I.consume(cycle)
I.observe(cycle, 6); I.observe(cycle, 7)
check(not cycle.impactReady, "Top-ups cannot rearm Impact")
cycle = nativeRoundTrip(cycle)
I.observe(cycle, 7)
check(not cycle.impactReady, "Save roundtrip and repeated head observation preserve spent state")
I.observe(cycle, 0); I.observe(cycle, 7)
check(cycle.impactReady, "Reload after completely empty supply rearms Impact")
local options = {impactReady = true, stats = stats}
check(C.impact(zombie, square, options) and zombie.stagger and not zombie.knocked, "Impact requests a standing stagger without knockdown")
zombie.stagger = false
options.impactReady = true
check(not C.impact(zombie, square, options), "Other turrets share the victim recovery guard")
zombie.data.OMHTTImpactGuard = nil
zombie.state = "ZombieGetUpState"
options.impactReady = true
check(not C.impact(zombie, square, options), "Getting-up zombie cannot be stagger-locked")
zombie.state = "idle"; zombie.knocked = true
options.impactReady = true
check(not C.impact(zombie, square, options), "Existing knockdown wins over Impact")
local origin = makeSquare(1600, 1600, 0)
for x = 1601, 1607 do makeSquare(x, 1600, 0) end
local primary = makeZombie(testSquares["1601:1600:0"], 10)
local a = makeZombie(testSquares["1602:1600:0"], 10)
local b = makeZombie(testSquares["1603:1600:0"], 10)
local c = makeZombie(testSquares["1604:1600:0"], 10)
for _, victim in pairs({primary, a, b, c}) do function victim:getWidth() return .3 end end
local piercingStats = S.resolve({active = {}})
piercingStats.knockdown = 0
piercingStats.piercing, piercingStats.pierceRetention, piercingStats.range = 2, .7, 6
local shot = {stats = piercingStats, damage = 1}
V.reset(); V.reserve(shot)
check(V.reserved == 1, "Piercing reserves one incremental ray, not one queue entry per copy")
V.pierce({id = "pierce", shots = 1}, origin, primary, nil, shot, primary.square, primary:getX(), primary:getY())
for _ = 1, 100 do if #V.queue > 0 then V.tick() end end
check(#V.queue == 0 and V.reserved == 0, "Piercing drains within the bounded effect scheduler")
check(math.abs(a.health - 9.3) < .000001 and math.abs(b.health - 9.51) < .000001 and c.health == 10,
    "Piercing hits two aligned extra victims with 70/49 percent damage")
check(primary.health == 10 and not a.knocked and not b.knocked, "Piercing cannot re-hit origin victim or inherit control effects")
V.reserve(shot)
testSquares["1602:1600:0"].blocked = true
V.pierce({id = "wall", shots = 2}, origin, primary, nil, shot, primary.square, primary:getX(), primary:getY())
for _ = 1, 100 do if #V.queue > 0 then V.tick() end end
check(math.abs(a.health - 9.3) < .000001, "Piercing cannot bypass a solid edge after the primary hit")
V.reset()
SandboxVars.OMHTurretsTraps, testRoll = savedSettings, savedRoll
