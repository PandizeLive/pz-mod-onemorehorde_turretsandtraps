local C = require("OMHTT/ControlWorld")
local A = require("OMHTT/ControlAccess")
local Action = require("OMHTT/ControlAction")
local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")
local savedMode, savedFaction = testMode, Faction
local oldState, oldContents, oldConfig = T.state, T.contents, T.cycleConfig
local oldPower, oldFire = W.applyPower, W.fire
local oldTime = testMillis
local auto = require("OMHTT/TurretAutomation")
testMode = "server"
Faction = {getPlayerFaction = function(player) return player.faction end}
local root = makeSquare(1910, 1910, 0)
function root:canReachTo() return true end
local owner = {name = "controls-test"}
function owner:getUsername() return self.name end
function owner:getAccessLevel() return "None" end
function owner:isDead() return false end
function owner:getSquare() return root end
function owner:getX() return 1910.5 end
function owner:getY() return 1910.5 end
local stranger = setmetatable({name = "outsider"}, {__index = owner})
local made = {}
local function device(kind, x, y)
    local square = x == 1910 and y == 1910 and root or makeSquare(x, y, 0)
    local object = {square = square, data = {}, health = 100, index = 0, turret = {powered = false}}
    function object:getSquare() return self.square end
    function object:getSpriteName() return "control-test-" .. kind end
    function object:getX() return self.square:getX() end
    function object:getY() return self.square:getY() end
    function object:getZ() return self.square:getZ() end
    function object:getObjectIndex() return self.index end
    function object:getHealth() return self.health end
    function object:getContainer() return {} end
    function object:hasModData() return true end
    function object:getModData() return self.data end
    function object:transmitModData() self.transmissions = (self.transmissions or 0) + 1 end
    local state = C.register(object, owner, kind)
    state.recoverAt = testMillis - 1
    made[#made + 1] = object
    return object, state
end
T.state = function(object) return object and object.turret end
T.contents = function() return {head = {getFullType = function() return T.HEAD end}, active = {Firing = 1}} end
T.cycleConfig = function() return {rotary = false} end
W.applyPower = function(object, value) object.turret.powered = value; return true end
W.fire = function(player, object, target, signal)
    check(signal == true and player == nil, "Controller uses server signal path")
    object.shots = (object.shots or 0) + 1
    return "Fired"
end
local controller, host = device("Controller", 1910, 1910)
host.powered = true
local plate, input = device("Plate", 1910, 1910)
local button, buttonState = device("Button", 1910, 1910)
local target, output = device("Turret", 1915, 1910)
check(not A.authorized(stranger, plate) and A.authorized(stranger, plate, true), "Private write/public read")
check(not Action:new(stranger, plate, "Name", "stolen", nil, input.id):complete(), "Stranger cannot rename")
check(not Action:new(owner, plate, "Name", "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", nil, input.id):complete(), "Bounded device names")
check(not Action:new(owner, plate, "Access", "Faction", nil, input.id):complete() and input.access == "Private", "Missing faction leaves private policy unchanged")
check(Action:new(owner, plate, "Access", "Public", nil, input.id):complete(), "Owner can share")
check(A.authorized(stranger, plate) and not Action:new(stranger, plate, "Access", "Private", nil, input.id):complete(), "Public write cannot seize policy")
local faction = {getName = function() return "Testing" end, getOwner = function() return "controls-test" end, getPlayers = function() return {contains = function() return false end} end}
owner.faction, stranger.faction = faction, faction
check(Action:new(owner, plate, "Access", "Faction", nil, input.id):complete() and A.authorized(stranger, plate), "Current faction can write")
faction.getOwner = function() return "new-owner" end
check(not A.authorized(stranger, plate), "Disbanded/recreated faction cannot inherit access")
check(Action:new(owner, controller, "Assign", true, target, host.id, output.id):complete(), "Explicit assignment")
check(Action:new(owner, controller, "Remote", nil, target, host.id, output.id):complete() and A.authorized(owner, target), "Scoped remote session")
check(not Action:new(stranger, controller, "Remote", nil, target, host.id, output.id):complete() or not A.authorized(stranger, target), "Read session cannot grant writes")
host.powered = false
check(not A.authorized(owner, target), "Controller outage blocks remote mutation")
host.powered = true
local second, secondState = device("Turret", 1916, 1910)
secondState.controller = host.id
A.session(owner, controller, second)
check(A.authorized(owner, target) and A.authorized(owner, second), "Multiple open Manage windows do not replace each other's scope")
testMillis = testMillis + 16000
check(not A.authorized(owner, target), "Remote session expires")
testMillis = oldTime
check(C.link(plate, target, true), "Plate links directly within range")
input.active = true
C.receiver(target, testMillis)
check(target.turret.powered and target.shots == 1, "Held plate powers and fires receiver")
C.receiver(target, testMillis)
check(target.shots == 1, "Same update cannot duplicate held request")
input.active = false
C.receiver(target, testMillis)
check(not target.turret.powered, "Release turns off real power switch")
check(C.link(button, target, true), "Button links to same output")
local pulse = Action:new(stranger, button, "Pulse", nil, nil, buttonState.id)
check(pulse:complete() and not pulse:complete() and target.shots == 2, "Anyone presses one non-replayable pulse")
testMillis = testMillis + 100
C.receiver(target, testMillis)
check(not target.turret.powered and target.shots == 2, "Pulse ends without repeated or queued firing")
input.active, input.recoverAt = true, testMillis + 1000
local linked, active = C.input(target, testMillis)
check(linked and not active, "One-second recovery prevents stale activation")
input.recoverAt = testMillis - 1
C.removed(plate)
linked, active = C.input(target, testMillis)
check(linked and not active, "Unloaded input fails off")
C.bind(plate)
check(not C.state(plate).active and C.state(plate).recoverAt > testMillis, "Reload reconstructs occupancy after grace period")
local limited, limitedState = device("Plate", 1910, 1910)
for i = 1, 32 do
    local receiver = device("Turret", 1915, 1911)
    check(C.link(limited, receiver, true), "Thirty-two outputs allowed")
end
local overflow = device("Turret", 1915, 1911)
check(not C.link(limited, overflow, true) and #limitedState.links == 32, "Thirty-third output rejected")
local distant = device("Turret", 1931, 1910)
check(not C.link(button, distant, true), "Twenty-tile link boundary")
local replacement, replacementState = device("Controller", 1910, 1910)
replacementState.powered = true
check(Action:new(owner, replacement, "Assign", true, target, replacementState.id, output.id):complete() and output.controller == replacementState.id, "Authorized reassignment replaces stale controller")
check(not Action:new(owner, controller, "Assign", false, target, host.id, output.id):complete(), "Old controller cannot unassign new controller")
for i = 1, 32 do
    local packed, packedState = device("Turret", 1915, 1912)
    packedState.controller, packedState.placed = replacementState.id, false
end
check(Action:new(owner, replacement, "Assign", true, second, replacementState.id, secondState.id):complete(), "Packed records do not exhaust controller assignments")
local isolated, isolatedState = device("Plate", 1911, 1913)
C.removed(isolated)
isolated.data.OMHTTControl = nil
C.bind(isolated)
check(C.state(isolated) == isolatedState and isolatedState.owner == owner.name, "Private location index recovers erased public ownership hint")
A.session(owner, replacement, target)
C.removed(button)
check(not Action:new(stranger, target, "ClearInputs", nil, nil, output.id):complete(), "Stranger cannot clear receiver links")
check(Action:new(owner, target, "ClearInputs", nil, nil, output.id):complete(), "Authorized receiver can remove unloaded or destroyed input links")
local stillLinked = C.input(target, testMillis)
check(not stillLinked and not target.turret.powered and #input.links == 0 and #buttonState.links == 0, "Clearing inputs remains off and restores manual operation")
local savedController = output.controller
C.removed(target)
replacementState.placed = false
local redeployed = C.register(target, owner, "Turret", output)
check(redeployed.controller == nil and redeployed.owner == owner.name, "Redeployment clears destroyed controller assignment without losing ownership")
for i = 1, #made do C.removed(made[i]) end
T.state, T.contents, T.cycleConfig = oldState, oldContents, oldConfig
W.applyPower, W.fire = oldPower, oldFire
Faction, testMode, testMillis = savedFaction, savedMode, oldTime
