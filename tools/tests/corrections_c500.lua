local V = require("OMHTT/TurretStateView")
local W = require("OMHTT/TurretWorld")
local Effects = require("OMHTT/DefenseEffects")
local Draw = require("OMHTT/ControlModelDraw")
local Options = require("OMHTT/ControlOptions")
local saved = {time = getTimestampMs, emit = Effects.emit, cell = getCell, light = IsoLightSource,
    draw = Draw.draw, render = Render3DItem, item = instanceItem, options = Options.get}
local now, clicks, adds, removes = 1000, 0, 0, 0
getTimestampMs = function() return now end
Effects.emit = function(command, args)
    check(command == "Click" and args.sound == "OMHTTTriggerClick", "Empty uses the existing makeshift click")
    clicks = clicks + 1
end
local square = {getX = function() return 7 end, getY = function() return 8 end, getZ = function() return 0 end}
local object = {getSquare = function() return square end, getObjectIndex = function() return 0 end}
for i = 1, 100 do check(W.empty(object) == "Empty", "Empty attempts do not fire a shot") end
check(clicks == 1, "Concurrent automatic/manual attempts share one click limiter")
now = 1999; W.empty(object); check(clicks == 1, "No early repeated click")
now = 2000; W.empty(object); check(clicks == 2, "One click per real second")
do
    local T = require("OMHTT/Turret")
    local oldState, oldContents, oldConfig, oldCycle = T.state, T.contents, T.cycleConfig, T.cycle
    local oldNear, oldPower, oldMode = W.near, W.power, testMode
    local state, status, powered = {powered=true}, "Empty", true
    testMode = "sp"
    object.getContainer = function() return {} end
    local head = {getFullType=function() return T.HEAD end, getCondition=function() return 100 end}
    T.state = function() return state end
    T.contents = function() return {head=head, heads=1, ammo=0, active={}} end
    T.cycleConfig = function() return {} end
    T.cycle = function() return {}, status end
    W.near = function() return true end
    W.power = function() return powered end
    now = 4000
    check(W.fire({}, object) == "Empty" and clicks == 3, "Powered empty firing attempt clicks")
    now = 5000; status = "Reloading"
    check(W.fire({}, object) == "Reloading" and clicks == 3, "Ordinary reload does not dry-click")
    status, powered = "Empty", false
    check(W.fire({}, object) == "NoPower" and clicks == 3, "Unpowered empty turret stays quiet")
    state.powered = false
    check(W.fire({}, object) == "Off" and clicks == 3, "Disabled empty turret stays quiet")
    T.state, T.contents, T.cycleConfig, T.cycle = oldState, oldContents, oldConfig, oldCycle
    W.near, W.power, testMode = oldNear, oldPower, oldMode
    now = 2000
end
check(V.strength(1000, 1000) == 1 and V.strength(1250, 1000) == .25,
    "Warning snaps on then fades smoothly")
check(V.strength(1500, 1000) == 0 and V.strength(1999, 1000) == 0 and V.strength(2000, 1000) == 1,
    "Warning pauses dark and restarts each second")
local cell = {addLamppost = function() adds = adds + 1 end,
    removeLamppost = function() removes = removes + 1 end}
getCell = function() return cell end
IsoLightSource = {new = function(x,y,z,r,g,b,radius)
    check(x == 7 and y == 8 and z == 0 and radius == 3, "Warning light uses actual native world coordinates")
    return {r=r,g=g,b=b, setR=function(self,n) self.r=n end, setG=function(self,n) self.g=n end,
        setB=function(self,n) self.b=n end, setActive=function(self,n) self.active=n end}
end}
instanceItem = function() return {setWorldAlpha=function(self,n) self.alpha=n end} end
Render3DItem = function() end
Draw.draw = function() end
Options.get = function() return true end
local entry = {}
V.clear()
V.draw(object, entry, square, "Green", true, true)
local light = V.lights[object].light
now = 2250
V.draw(object, entry, square, "Green", true, true); V.tick()
check(adds == 1 and math.abs(light.r - .2) < .000001 and entry.indicator.alpha == .25,
    "One reused native light fades in sync with the marker")
now = 2500
V.draw(object, entry, square, "Green", true, true); V.tick()
check(not light.active and light.r == 0, "Pause extinguishes world lighting")
V.draw(object, entry, square, "Green", false, true)
check(removes == 0 and adds == 1 and V.lights[object].light == light and light.active and light.g == .7 and light.r == .1,
    "Refilling reuses the same native light as steady active green")
now = 2550
V.draw(object, entry, square, "Amber", false, true); V.tick()
check(light.active and light.r == .8 and light.g == .45 and entry.indicator.alpha == 1,
    "Asleep and waking cast steady amber world light")
now = 2600
V.draw(object, entry, square, "Amber", false, true); V.tick()
check(light.r == .8 and adds == 1, "Steady amber does not inherit the empty fade")
V.draw(object, entry, square, "Amber", true, false)
check(adds == 1 and removes == 1, "Distant indicators remove local world lights")
V.draw(object, entry, square, "Amber", true, true)
now = 2850; V.tick()
check(removes == 2 and V.lights[object] == nil, "Unseen or unloaded marker lights expire promptly")
V.draw(object, entry, square, "Amber", true, true)
Options.get = function() return false end
now = 2950; V.tick()
check(removes == 3 and V.lights[object] == nil, "Player marker preference also removes world lights")
Options.get = function() return true end
V.draw(object, entry, square, "Green", false, true)
V.draw(object, entry, square, "Dark", false, true)
check(removes == 4 and V.lights[object] == nil, "Disabled and unpowered turrets extinguish world lighting")
V.clear()
getTimestampMs, Effects.emit, getCell, IsoLightSource = saved.time, saved.emit, saved.cell, saved.light
Draw.draw, Render3DItem, instanceItem, Options.get = saved.draw, saved.render, saved.item, saved.options
