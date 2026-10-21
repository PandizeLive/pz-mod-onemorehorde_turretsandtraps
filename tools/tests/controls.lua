local C = require("OMHTT/ControlWorld")
local A = require("OMHTT/ControlAccess")
local Action = require("OMHTT/ControlAction")
local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")
local savedMode, savedFaction = testMode, Faction
local oldState, oldContents, oldConfig = T.state, T.contents, T.cycleConfig
local oldPower, oldFire, oldWorldContents, oldWorldPower = W.applyPower, W.fire, W.contents, W.power
local oldTime = testMillis
local Power = require("OMHTT/ControlPower")
local oldTriggerPower = Power.trigger
Power.trigger = function() return true end
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
    local object = {kind = "IsoThumpable", square = square, data = {}, health = 100, index = 0, turret = {powered = false}}
    function object:setCanPassThrough(value) self.passThrough = value end
    function object:setBlockAllTheSquare(value) self.blockAll = value end
    function object:setIsThumpable(value) self.thumpable = value end
    function object:getSquare() return self.square end
    function object:getSpriteName() return self.sprite or "control-test-" .. kind end
    function object:setSpriteFromName(value) self.sprite=value end
    function object:getSpriteConfig() return {isValid=function() return true end,getTileInfo=function() return {getSpriteName=function() return object:getSpriteName() end} end} end
    function object:transmitUpdatedSpriteToClients() self.spriteSends=(self.spriteSends or 0)+1 end
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
local testHead = {getFullType = function() return T.HEAD end, getCondition = function() return 10 end}
T.contents = function() return {head = testHead, heads = 1, ammo = 20, active = {Firing = 1}} end
W.contents = T.contents
W.power = function() return {kind="test"} end
T.cycleConfig = function() return {rotary = false} end
W.applyPower = function(object, value) object.turret.powered = value; return true end
W.fire = function(player, object, target, signal)
    check(signal == true and player == nil, "Controller uses server signal path")
    object.shots = (object.shots or 0) + 1
    return "Fired"
end
local controller, host = device("Controller", 1910, 1910)
host.powered = true
check(not Action:new(owner,controller,"Name","custom",nil,host.id):complete(), "Controllers cannot be renamed")
local plate, input = device("Plate", 1910, 1910)
local oldOccupied = C.occupied
local raised, raisedLocation = plate:getSpriteName(), input.location
local occupied = true
C.occupied = function() return occupied end
C.updatePlate(plate, testMillis)
local pressed, sends = plate:getSpriteName(), plate.spriteSends
check(input.active and raised ~= pressed and C.locations[input.location][input.id], "Pressed plate changes native sprite and private location index")
check(not C.locations[raisedLocation][input.id], "Old plate appearance no longer binds identity")
C.updatePlate(plate, testMillis)
check(plate.spriteSends == sends, "Held plate sends no repeated sprite updates")
occupied = false
C.updatePlate(plate, testMillis)
check(not input.active and plate:getSpriteName() == raised and plate.spriteSends == sends + 1, "Plate rises with one release update")
C.occupied = oldOccupied
local button, buttonState = device("Button", 1910, 1910)
check(buttonState.displayName == "Button #1", "Fresh world first Button is numbered one")
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
check(require("OMHTT/ControlRemote").request(owner, controller, target) and A.authorized(owner, target), "Scoped remote session")
check(not require("OMHTT/ControlRemote").request(stranger, controller, target) or not A.authorized(stranger, target), "Read session cannot grant writes")
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
target.turret.facingPending = true
C.pulse(target)
check(target.turret.powered and target.shots == 2 and require("OMHTT/ControlCycle").pending[target], "Button holds one explicit shot through a pending direction turn")
target.turret.facingPending = nil
testMillis = testMillis + 100
C.receiver(target, testMillis)
check(target.shots == 3 and not require("OMHTT/ControlCycle").pending[target] and not target.turret.powered, "Aligned button fires once and ends temporary turning power")
testMillis = testMillis + 100
C.receiver(target, testMillis)
check(not target.turret.powered and target.shots == 3, "Pending turn cannot leave automatic fire powered")
local Cycles = require("OMHTT/ControlCycle")
local Clock = require("OMHTT/TurretClock")
local clockBefore, fireBefore = Clock.now, W.fire
local activeTime = testMillis
Clock.now = function() return activeTime end
for _, mode in pairs({"sp", "server"}) do
    testMode = mode
    local outcome, attempts, committed = "Reloading", 0, 0
    W.fire = function()
        attempts = attempts + 1
        if outcome == "Fired" then committed = committed + 1 end
        return outcome
    end
    C.pulse(target)
    local request = Cycles.pending[target]
    check(request and target.turret.powered, "Pulse retains a reload in "..mode)
    for i=1,100 do C.pulse(target) end
    check(Cycles.pending[target] == request and attempts == 1, "Repeated pulses cannot grow or reset pending work in "..mode)
    activeTime, testMillis = activeTime + 500, testMillis + 500
    outcome = "Aiming"
    C.receiver(target,testMillis)
    check(Cycles.pending[target] == request and target.turret.powered, "Reload-to-aim transition retains power in "..mode)
    outcome = "Fired"
    C.receiver(target,testMillis)
    C.receiver(target,testMillis+100)
    check(committed == 1 and not Cycles.pending[target] and not target.turret.powered, "Completed pulse commits once then powers off in "..mode)
    testMillis = testMillis + 200
    outcome, input.active = "Reloading", true
    C.receiver(target,testMillis)
    input.active = false
    C.receiver(target,testMillis+100)
    check(Cycles.pending[target] and target.turret.powered, "Plate release retains the current reload in "..mode)
    outcome = "Fired"
    C.receiver(target,testMillis+200)
    check(committed == 2 and not target.turret.powered, "Released plate finishes exactly one cycle in "..mode)
    C.pulse(target)
    outcome = "Reloading"
    C.pulse(target)
    Cycles.manualOff(target)
    W.applyPower(target,false)
    input.active = true
    C.receiver(target,testMillis+300)
    check(not Cycles.pending[target] and not target.turret.powered, "Manual Off cancels and suppresses a held input in "..mode)
    input.active = false
    C.receiver(target,testMillis+400)
    C.pulse(target)
    check(Cycles.pending[target] ~= nil, "A fresh press can rearm after manual Off in "..mode)
    outcome = "Empty"
    C.receiver(target,testMillis+500)
    check(not Cycles.pending[target] and not target.turret.powered, "Empty supply safely cancels in "..mode)
    outcome = "Reloading"
    C.pulse(target)
    activeTime = Cycles.pending[target].expires + 1
    C.receiver(target,testMillis+600)
    check(not Cycles.pending[target] and not target.turret.powered, "Stalled requests have a bounded lifetime in "..mode)
    C.pulse(target)
    C.link(plate, target, false)
    C.link(button, target, false)
    C.receiver(target,testMillis+700)
    check(not Cycles.pending[target] and not target.turret.powered, "Removing the final link cancels pending work in "..mode)
    C.link(plate, target, true)
    C.link(button, target, true)
    local normalConfig = T.cycleConfig
    T.cycleConfig = function() return {rotary = true} end
    outcome = "Fired"
    target.turret.rotaryMoving, target.turret.rotaryManual = true, activeTime + 500
    C.pulse(target)
    check(Cycles.pending[target] and Cycles.pending[target].finishing and target.turret.powered, "Rotary retains power during its accepted pass in "..mode)
    local rotaryShots = committed
    C.receiver(target,testMillis+800)
    check(committed == rotaryShots and target.turret.powered, "Rotary completion cannot schedule another shot in "..mode)
    target.turret.rotaryMoving = false
    activeTime = activeTime + 501
    C.receiver(target,testMillis+900)
    check(not Cycles.pending[target] and not target.turret.powered, "Rotary stops after its current pass in "..mode)
    T.cycleConfig = normalConfig
end
Clock.now, W.fire, testMode = clockBefore, fireBefore, "server"
target.shots = 2
input.active, input.recoverAt = true, testMillis + 1000
local linked, active = C.input(target, testMillis)
check(linked and not active, "One-second recovery prevents stale activation")
input.recoverAt = testMillis - 1
C.removed(plate)
linked, active = C.input(target, testMillis)
check(linked and not active, "Unloaded input fails off")
local sameSpriteFloor = setmetatable({kind="IsoObject"},{__index=plate})
C.bind(sameSpriteFloor)
check(C.state(sameSpriteFloor)==nil,"Ordinary floor sharing the plate sprite cannot inherit its saved identity")
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
host.powered = true
local remoteButton, remoteState = device("Button", 1920, 1910)
check(C.autoAssign(remoteButton, owner) and remoteState.controller == host.id and #remoteState.links == 0,
    "Placed inputs join the accessible Controller without inventing receiver links")
check(not A.near(owner, remoteButton) and require("OMHTT/ControlRemote").request(owner, controller, remoteButton),
    "Controller issues a remote session without standing beside the input")
check(Action:new(owner,remoteButton,"Link",true,target,remoteState.id,redeployed.id):complete(),
    "Assigned input links to a receiver through server-authorized remote control")
host.powered = false
check(not Action:new(owner,remoteButton,"Link",false,target,remoteState.id,redeployed.id):complete(),
    "Controller power loss revokes remote link changes")
host.powered = true
local restricted, restrictedState = device("Controller", 1919, 1910)
restrictedState.owner = "other-owner"
local nextInput, nextState = device("Plate", 1920, 1910)
check(C.autoAssign(nextInput,owner) and nextState.controller == host.id, "Auto-assignment skips a closer private Controller")
restrictedState.access = "Public"
local nearestInput, nearestState = device("Button",1920,1910)
check(C.autoAssign(nearestInput,owner) and nearestState.controller == restrictedState.id,
    "Auto-assignment chooses the nearest permitted Controller even before its power is available")
check(not C.autoAssign(remoteButton,owner) and remoteState.controller == host.id,
    "Automatic assignment preserves an existing Controller selection")
restrictedState.placed = false
local outOfRange, outOfRangeState = device("Plate",1931,1910)
check(not C.autoAssign(outOfRange,owner) and not outOfRangeState.controller, "Auto-assignment keeps the 20-tile boundary")
local denied, deniedState = device("Button",1920,1910)
check(not C.autoAssign(denied,stranger) and not deniedState.controller, "Auto-assignment cannot claim another player's device")
local records = C.records().records
for i = 1, 30 do records["c315-fill-"..i] = {id="c315-fill-"..i,placed=true,kind="Plate",controller=host.id} end
check(not C.autoAssign(denied,owner), "Auto-assignment honors the 32-input limit")
for i = 1, 30 do records["c315-fill-"..i] = nil end
local retired, retiredState = device("Button", 1911, 1910)
local retirementTarget, retirementState = device("Turret", 1912, 1910)
check(C.link(retired, retirementTarget, true), "Retirement fixture connects")
C.removed(retired)
C.publish(retirementTarget)
check(C.input(retirementTarget,testMillis) and #retirementTarget:getModData().OMHTTControl.inputs == 1,
    "Temporary unload preserves the named inactive input")
C.bind(retired)
C.retire(retired)
C.removed(retired)
check(not C.input(retirementTarget,testMillis) and #retirementTarget:getModData().OMHTTControl.inputs == 0 and #retiredState.links == 0,
    "Permanently retired trigger clears authority and published input together")
retiredState.placed = true
C.bind(retired)
check(not C.input(retirementTarget,testMillis), "Replaced trigger does not silently restore retired links")
check(C.link(retired, retirementTarget, true), "Fresh relink remains available")
C.retire(retirementTarget)
check(#retiredState.links == 0, "Packing a receiver clears the source endpoint too")
local unlinkedTarget, unlinkedState = device("Turret", 1913, 1910)
C.incoming[unlinkedState.id] = {}
unlinkedTarget.turret.powered = true
C.retire(unlinkedTarget)
check(unlinkedTarget.turret.powered, "Empty incoming index does not change an unlinked turret's packed power state")
for i = 1, #made do C.removed(made[i]) end
T.state, T.contents, T.cycleConfig = oldState, oldContents, oldConfig
W.applyPower, W.fire, W.contents, W.power = oldPower, oldFire, oldWorldContents, oldWorldPower
Faction, testMode, testMillis = savedFaction, savedMode, oldTime

Power.trigger = oldTriggerPower
