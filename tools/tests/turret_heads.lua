local H = require("OMHTT/TurretHeads")
local S = require("OMHTT/TurretStats")
local T = require("OMHTT/Turret")
local M = require("OMHTT/TurretModules")
local savedSettings = SandboxVars.OMHTurretsTraps
SandboxVars.OMHTurretsTraps = {TurretStandbyEnabled = false}
local function head(name)
    local data = {}
    return {getFullType = function() return "Base.OMHTTTurret" .. name end,
        getCondition = function() return 100 end, getModData = function() return data end}
end
local ballista, bat, blades = head("Ballista"), head("RotaryBat"), head("RotaryBlades")
local stats = S.resolve({head = ballista, active = {}, powerLoad = 0})
check(stats.damage == 240 and stats.range == 24 and stats.cooldown == 6000 and stats.reload == 6000, "Ballista base combat contract")
check(math.abs(stats.batteryPercent - .025) < .0000001 and stats.magazine == 5, "Ballista calibrated power and built-in five-spear magazine")
check(H.accuracy(stats, 0) == 75 and H.accuracy(stats, 12) == 60 and H.accuracy(stats, 24) == 45, "Ballista accuracy uses true near/mid/far endpoints")
check(H.accuracy(stats, 50) == 45, "Accuracy endpoint clamps without extrapolation")
stats = S.resolve({head = ballista, active = {Conservation = 2, Splitter = 2, Piercing = 2, Magazine = 2}, powerLoad = 3})
check(stats.conservation == 2.5 and stats.splitter == 2 and stats.piercing == 2 and stats.magazine == 9, "Ballista uses existing projectile module accounting")
check(math.abs(stats.batteryPercent - .1) < .000001, "Ballista additive module power")
for _, item in pairs({bat, blades}) do
    stats = S.resolve({head = item, active = {}, powerLoad = 0})
    check(stats.rotary and stats.magazine == 0 and stats.motorSpeed == 150 and math.abs(100 / stats.motorPower - (item == blades and 3 or 6)) < .0001, "Rotary 25RPM: Bat six hours, Blades three hours")
    check(not H.supports(item, "Splitter") and not H.supports(item, "Accuracy") and not H.supports(item, "Filter"), "Physical heads reject meaningless projectile/priority effects")
    check(H.supports(item, "Regulator") and H.supports(item, "Detection360"), "Physical heads retain useful modules")
end
stats = S.resolve({head = bat, active = {RapidFire = 1, Regulator = 1}, powerLoad = 2})
check(stats.motorSpeed == 210 and math.abs(stats.motorPower - 56) < .00001, "First Rapid Fire and rarity drain scale once; Regulator divides paid power")
local profile = M.profile({baseFacing = 0}, {head = bat, active = {}}, false)
check(profile.rotary and profile.cone == 90 and profile.range == 2, "Rotary placement-locked dual sector profile")
for degrees = -180, 180 do
    local allowed = math.abs(degrees) <= 45 or math.abs(degrees) >= 135
    local arm = H.crossing(degrees, 0, 180, false)
    if degrees ~= -22 and degrees ~= 158 then
        check((arm ~= nil) == allowed, "Both sectors exclude side hits: " .. degrees)
    end
end
local a, pass = H.crossing(0, 0, 45, false)
check(a == 1 and pass == 0, "Forward arm crosses sector center")
check(H.crossing(0, 45, 60, false) == nil, "Crossing endpoint cannot hit twice")
local edgeArm, edgePass = H.crossing(45, 89, 90, false)
check(edgeArm == 1 and edgePass == 0, "Stroke endpoint belongs to the completed paid pass")
check(H.crossing(180, 0, 45, false) == 2, "Rear arm is independently physical")
check(H.crossing(90, 0, 90, false) == nil and H.crossing(90, 0, 90, true) == 1, "Only 360 permits side contact")
check(H.motion(90, false) == 45 and H.motion(180, false) == -45, "Oscillation reverses at agreed endpoints")
check(H.motion(360, true) == 0, "Continuous revolution closes at 2.4 seconds")
local total = 0
for i = 1, 240 do
    if H.crossing(0, (i - 1) * 1.5, i * 1.5, false) then total = total + 1 end
end
check(total == 4, "25RPM-equivalent oscillation crosses sector center four times in 2.4s")
local consumed = require("OMHTT/TurretConservation")
local debt, paid = {}, 0
for i = 1, 6 do paid = paid + consumed.consume(debt, 1, 3) end
check(paid == 2, "Six conserved spear uses consume two real spears, no recovery duplication")
local R = require("OMHTT/TurretRotary")
local W = require("OMHTT/TurretWorld")
local Clock = require("OMHTT/TurretClock")
local Combat = require("OMHTT/PrototypeCombat")
local Effects = require("OMHTT/PrototypeEffects")
local oldValid, oldContents, oldNear = W.valid, W.contents, W.near
local oldCell, oldGameTime, oldClock, oldLane, oldSound = getCell, getGameTime, Clock.now, Combat.clearLane, Effects.sound
local oldInstance, oldRandom = instanceof, ZombRand
local now, age, soundCount = 0, 0, 0
local state = {schema = 1, id = "rotary-test", baseFacing = 0, powered = true}
local actors = {}
local origin = {getX = function() return 0 end, getY = function() return 0 end, getZ = function() return 0 end}
function origin:getMovingObjects()
    return {size = function() return #actors end, get = function(_, n) return actors[n + 1] end}
end
local object = {getSquare = function() return origin end, hasModData = function() return true end,
    getModData = function() return {OMHTTTurret = state} end}
local battery = {charge = 1, getCondition = function() return 100 end, getModData = function() return data end}
battery.data = {}
function battery:getModData() return self.data end
function battery:getCurrentUsesFloat() return self.charge end
function battery:setCurrentUsesFloat(value) self.charge = value end
function origin:hasGridPower() return false end
function origin:haveElectricity() return false end
local contents = {head = bat, heads = 1, battery = battery, active = {Firing = 1, MotionDetection = 1}, powerLoad = 0}
local data = {}
local zombie = {health = 10, kind = "IsoZombie", getX = function() return 1.5 end, getY = function() return .5 end,
    getSquare = function() return origin end, getModData = function() return data end,
    getCurrentStateName = function() return "idle" end, isProne = function() return false end,
    isKnockedDown = function() return false end, isStaggerBack = function() return false end, isBumpFall = function() return false end}
function zombie:isDead() return self.health <= 0 end
function zombie:isOnFloor() return self.grounded == true end
function zombie:isRagdoll() return self.ragdoll == true end
function zombie:isGettingUp() return self.gettingUp == true end
function zombie:getHealth() return self.health end
function zombie:setHealth(value) self.health = value end
function zombie:Kill() self.health = 0 end
function instanceof(item, kind) return item.kind == kind end
ZombRand = function(limit) return limit - 1 end
Clock.now = function() return now end
getGameTime = function() return {getWorldAgeHours = function() return age end, getMinutesPerDay = function() return 60 end} end
getCell = function() return {getGridSquare = function(_, x, y) if x == 0 and y == 0 then return origin end end} end
W.valid, W.near = function() return true end, function() return true end
W.contents = function() return contents end
Combat.clearLane = function() return true end
Effects.sound = function() soundCount = soundCount + 1 end
actors[1] = zombie
local entry = {object = object}
zombie.grounded = true
R.contact(entry, zombie, {})
check(not entry.hasTarget and zombie.health == 10, "Grounded actor cannot activate rotary or take an arm hit")
zombie.grounded, zombie.gettingUp = false, true
R.contact(entry, zombie, {})
check(zombie.health == 10, "Getting-up zombie remains excluded until standing")
zombie.gettingUp = false
R.step(entry, getTimestampMs() + 100)
check(entry.hasTarget and not state.rotaryMoving, "Bounded idle scan discovers a target without attacking")
for i = 1, 120 do
    now, age = i * 10, i * 10 / 150000
    R.step(entry, getTimestampMs() + 100)
end
check(zombie.health < 10 and zombie.health > 8, "Real rotary scheduler delivers contact damage without per-frame stacking")
check(battery.charge < 1 and battery.charge > .99 and soundCount > 0, "Moving rotary consumes game-time power and emits impact sound")
local health = zombie.health
state.powered = false
now, age = now + 1000, age + .1
R.step(entry, getTimestampMs() + 100)
check(not state.rotaryMoving and zombie.health == health, "Power off cancels pending contact")
local charge = battery.charge
now, age = now + 100000, age + 12
R.step(entry, getTimestampMs() + 100)
check(battery.charge == charge, "Powered-off sleep/time skip has no drain")
state.powered = true
R.step(entry, getTimestampMs() + 100)
now = now + 10; R.step(entry, getTimestampMs() + 100)
health = zombie.health
now, age = now + 100000, age + 12
R.step(entry, getTimestampMs() + 100)
check(zombie.health == health, "Exhaustion discards unobserved contact")
check(battery.charge == 0 and not state.rotaryMoving, "Long running time skip exhausts battery without burst attacks")
battery.charge = 1
contents.active.FiringImprovised = 1
SandboxVars.OMHTurretsTraps.ImprovisedFiringFailure = 100
now = now + 1000
R.step(entry, getTimestampMs() + 100)
check(not state.rotaryMoving and battery.charge == 1 and entry.retryAt > now, "Makeshift failure blocks motor startup without power spend")
contents.active.FiringImprovised = nil
SandboxVars.OMHTurretsTraps.ImprovisedFiringFailure = nil
state.powered = false
R.step(entry, getTimestampMs() + 100)
local oldTime, oldParts = getTimestampMs, BodyPartType
ZombRand = function() return 0 end
getTimestampMs = function() return now end
BodyPartType = {ForeArm_L = 2, ForeArm_R = 3, UpperLeg_L = 11, UpperLeg_R = 12,
    ToIndex = function(value) return value end, FromIndex = function(value) return value end}
local injuryData, damage, pain, cuts = {}, 0, 0, 0
local part = {AddDamage = function(_, n) damage = damage + n end,
    getAdditionalPain = function() return pain end, setAdditionalPain = function(_, n) pain = n end,
    setCut = function() cuts = cuts + 1 end}
local player = {god = false, noclip = false, ghost = false, dead = false}
function player:getUsername() return "rotary-victim" end
function player:getPlayerNum() return 0 end
function player:getBodyPartClothingDefense() return 0 end
function player:isGodMod() return self.god end
function player:isNoClip() return self.noclip end
function player:isGhostMode() return self.ghost end
function player:isDead() return self.dead end
function player:getModData() return injuryData end
function player:getBodyDamage() return {getBodyPart = function() return part end} end
for _, flag in pairs({"god", "noclip", "ghost", "dead"}) do
    player[flag] = true
    R.injure(player, false, now)
    player[flag] = false
end
check(damage == 0 and cuts == 0, "Rotary injury exempts dead and protected players")
R.injure(player, false, now)
now = now + 1000
R.injure(player, true, now)
check(damage == 4 and pain == 0 and cuts == 0, "Bat injury and cross-head guard")
now = now + 1000
R.injure(player, true, now)
check(cuts == 1 and damage == 12, "Reduced blade damage and rolled cut resume after shared injury guard")
getTimestampMs, BodyPartType = oldTime, oldParts
W.valid, W.contents, W.near = oldValid, oldContents, oldNear
getCell, getGameTime, Clock.now, Combat.clearLane, Effects.sound = oldCell, oldGameTime, oldClock, oldLane, oldSound
instanceof, ZombRand = oldInstance, oldRandom
SandboxVars.OMHTurretsTraps = savedSettings
