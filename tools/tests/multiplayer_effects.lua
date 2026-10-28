local Motion = require("OMHTT/DefenseMotion")
local Movement = require("OMHTT/BarbMovement")
local Tack = require("OMHTT/TurretTackView")
local Clock = require("OMHTT/TurretClock")
local Bed = require("OMHTT/BedSpikes")
local Injury = require("OMHTT/DefenseInjury")
local oldMode, oldCore = testMode, OneMoreHordeDefenseIntegration
local oldServer, oldClient, oldSpecific = sendServerCommand, sendClientCommand, getSpecificPlayer
local oldNow, oldApply = Clock.now, Movement.apply
local oldWall = getTimestampMs
local oldParts, oldRandom = BodyPartType, ZombRand
local oldOnline = getOnlinePlayers
getOnlinePlayers = function() return {size = function() return 0 end} end
local time, sent, replies, slows = 10000, {}, {}, 0
Clock.now = function() return time end
getTimestampMs = function() return time end
Movement.apply = function(_, divisor) check(divisor == 2, "Wire slowdown is a divisor"); slows = slows + 1 end
sendServerCommand = function(player, module, command, data) sent[#sent + 1] = {player, module, command, nativeRoundTrip(data)} end
sendClientCommand = function(player, module, command, data) replies[#replies + 1] = {player, module, command, data} end
OneMoreHordeDefenseIntegration = nil
local player = {getOnlineID = function() return 41 end, isLocalPlayer = function() return true end,
    isDead = function() return false end, isGodMod = function() return false end,
    isNoClip = function() return false end, isGhostMode = function() return false end,
    getX = function(self) return self.x or 0 end, getY = function() return 0 end}
getSpecificPlayer = function(index) return index == 1 and player or nil end
testMode = "server"
local square = makeSquare(905, 905, 0)
local zombie = makeZombie(square, 2)
zombie.onlineId, zombie.outfitId, zombie.owner = 7001, 9001, player
function zombie:getBumpType() return self.bump or "" end
function zombie:setBumpType(value) self.bump = value end
check(Motion.request(zombie, "trip", "bed-test"), "Server admits authorized trip")
check(zombie.bump == nil and #sent == 1, "Server sends motion to native owner without simulating it twice")
local message = sent[1]
testMode = "client"
Motion.created(zombie)
Motion.command(message[2], message[3], message[4])
check(zombie.bump == "OMHTTBedTrip", "Native owner runs the forward-collapse reaction")
zombie.bump = ""
Motion.command(message[2], message[3], message[4])
check(zombie.bump == "", "Duplicate motion serial cannot replay a trip")
zombie.onlineId = 7002
Motion.command(message[2], message[3], {id = 7001, outfit = 9001, serial = message[4].serial + 1, x = 0, y = 0})
check(zombie.bump == "", "Recycled native ID cannot receive an older actor's reaction")
zombie.onlineId = 7001
local touching = true
Motion.checks.test = function(_, source) return touching and source == "wire-test" end
Motion.command("OMHTT_MotionV1", "slow", {id = 7001, outfit = 9001, serial = message[4].serial + 2, x = 2, y = 0, source = "wire-test"})
Motion.update(zombie)
check(slows == 1, "Authorized owner slows while touching exact active source")
touching = false
Motion.update(zombie)
check(slows == 1, "Leaving contact restores normal movement immediately, before lease expiry")
Motion.checks.test = nil

local oldRemote = zombie.isRemoteZombie
zombie.isRemoteZombie = function() return true end
Motion.command("OMHTT_MotionV1", "visualTrip", {id = 7001, outfit = 9001, serial = message[4].serial + 3, x = 0, y = 0})
check(zombie.bump == "OMHTTBedTrip", "Remote observer receives custom forward-collapse animation absent from native zombie packets")
zombie.bump = ""
Motion.command("OMHTT_MotionV1", "trip", {id = 7001, outfit = 9001, serial = message[4].serial + 4, x = 0, y = 0})
check(zombie.bump == "", "Observer cannot execute an owner-only gameplay reaction")
zombie.isRemoteZombie = oldRemote

local Effects = require("OMHTT/DefenseEffects")
local near = {getX = function() return 10 end, getY = function() return 10 end}
local far = {getX = function() return 200 end, getY = function() return 200 end}
getOnlinePlayers = function() return {size = function() return 2 end, get = function(_, i) return i == 0 and near or far end} end
testMode = "server"
local effectStart = #sent
Effects.emit("Click", {x = 10, y = 10, z = 0, sound = "test", target = zombie})
check(#sent == effectStart + 1 and sent[#sent][1] == near and sent[#sent][4].target == nil,
    "Presentation targets only nearby recipients and excludes native victim references")
testMode = "client"
local effect = sent[#sent][4]
check(Effects.accept(effect) and not Effects.accept(effect), "Split-screen duplicate delivery plays one presentation event")
local observer = {getX = function() return 11 end, getY = function() return 10 end}
getOnlinePlayers = function() return {size = function() return 3 end,
    get = function(_, i) return ({near, observer, far})[i + 1] end} end
testMode = "server"
effectStart = #sent
Effects.emit("Launch", {id = "observer-test", shot = 1, fromX = 10, fromY = 10, x = 15, y = 10,
    z = 0, flight = 500, target = zombie})
check(#sent == effectStart + 2 and sent[effectStart + 1][1] == near and sent[effectStart + 2][1] == observer,
    "C494 projectile launch reaches shooter-side and independent nearby observer recipients")
check(sent[effectStart + 1][4].packet == sent[effectStart + 2][4].packet
    and sent[effectStart + 2][4].target == nil and sent[effectStart + 2][4].flight == 500,
    "C494 all observer recipients receive the same serial and plain projectile facts")
getOnlinePlayers = oldOnline

testMode = "server"
local before = #sent
OneMoreHordeDefenseIntegration = {API_VERSION = 1, authorize = function() return false end}
check(not Motion.request(zombie, "knock", "unconsented") and #sent == before,
    "Unconsenting Horde receives neither reaction nor slowdown message")
OneMoreHordeDefenseIntegration = nil

testMode = "client"
Tack.receive("OMHTT_TackView", "Fields", {{id = "field-test", x = 905.5, y = 905.5, z = 0,
    radius = 1.5, startsIn = 500, remaining = 2000, source = "tack-test"}})
check(Tack.fieldCount == 1 and Tack.contact(zombie) == nil, "Tack replication preserves deployment delay")
time = time + 500
check(Tack.contact(zombie).id == "field-test", "Late join snapshot becomes contact-active on its local clock")
Tack.update(player)
check(#replies == 1 and replies[1][1] == player, "Second split-screen player can request nearby tack fields")
Tack.update(player)
check(#replies == 1, "Stationary player does not poll the field snapshot every update")
player.x, time = 45, time + 5001
Tack.update(player)
check(#replies == 2 and Tack.fieldCount == 0, "Moving into a new area requests its fields and expires missed removals")

Bed.initialize()
local object = IsoThumpable.new(getCell(), square, "omhtt_barrier_01_64", false)
square:AddSpecialObject(object)
object:getModData().OMHTTBed = {id = "replicated-bed", view = {id = "replicated-bed", x = 905, y = 905, z = 0, facing = 0, single = true, health = 50}}
Bed.loaded(square)
local record = Bed.record(object)
check(#Bed.parts(record) == 1 and Bed.count == 1, "Client indexes a newly replicated independent spike tile")
object:getModData().OMHTTBed.view = {id = "replicated-bed", x = 905, y = 905, z = 0, facing = 0, single = true, health = 44}
check(Bed.record(object) == record and record.health == 44 and #Bed.parts(record) == 1,
    "Replacing network metadata keeps canonical contact identity and updated durability")
Bed.removed(object)
check(Bed.count == 0, "Network removal clears the client hazard index")

BodyPartType = {ForeArm_L = "arm", ForeArm_R = "arm", UpperLeg_L = "upper", UpperLeg_R = "upper", LowerLeg_L = "lower", LowerLeg_R = "lower"}
ZombRand = function() return 2 end
local injured, cuts, total = nil, 0, 0
function player:getBodyDamage() return {getBodyPart = function(_, part)
    injured = part
    return {AddDamage = function(_, amount) total = total + amount end, getAdditionalPain = function() return 0 end,
        setAdditionalPain = function() end, setCut = function() cuts = cuts + 1 end}
end} end
testMode = "server"
before = #sent
Injury.request(player, "rotaryBruise", 2000)
Injury.request(player, "cut", 2000)
check(#sent == before + 1, "Bat and blade share their two-second injury guard")
testMode = "client"
message = sent[#sent]
Injury.receive(message[2], message[3], message[4])
Injury.receive(message[2], message[3], message[4])
check(total == 2 and injured == "upper" and cuts == 0, "Authenticated split-screen victim gets one SP-equivalent rotary bruise")

testMode, OneMoreHordeDefenseIntegration = oldMode, oldCore
sendServerCommand, sendClientCommand, getSpecificPlayer = oldServer, oldClient, oldSpecific
Clock.now, Movement.apply, BodyPartType, ZombRand = oldNow, oldApply, oldParts, oldRandom
getTimestampMs = oldWall
testMultiplayerAudit = "authorityAndOwnerProtocol=pass contactAndPresentation=pass liveDedicated=zero-client-probe liveListen=pending liveTwoClient=pending"

local Battery = require("OMHTT/TurretBattery")
local quantized = {charge = 1, data = {}}
function quantized:getModData() return self.data end
function quantized:getCurrentUsesFloat() return self.charge end
function quantized:setCurrentUsesFloat(value) self.charge = math.floor(value * 100 + .5) / 100 end
testMode = "sp"
for i = 1, 10000 do Battery.spend(quantized, .0000045) end
check(math.abs(Battery.charge(quantized) - .955) < .00000001 and quantized.charge < 1,
    "Ten thousand sub-use shots retain exact drain instead of rounding every shot to free power")
quantized.data = nativeRoundTrip(quantized.data)
check(math.abs(Battery.charge(quantized) - .955) < .00000001, "Fractional charge remainder survives native table serialization")
Battery.spend(quantized, 1)
check(Battery.charge(quantized) == 0 and quantized.charge == 0, "Final fraction cannot produce negative charge or endless zero-use power")
testMode = oldMode
