local View = require("OMHTT/TurretArcView")
local Tether = require("OMHTT/TetherView")
local Clock = require("OMHTT/TurretClock")
local Draw = require("OMHTT/ControlModelDraw")
local Effects = require("OMHTT/DefenseEffects")
local saved = {clock = Clock.now, accept = Effects.accept, player = getSpecificPlayer,
    light = IsoLightSource, cell = getCell, item = instanceItem, draw = Draw.draw, timestamp = getTimestampMs}
local now, draws, visible = 1000, {}, true
Clock.now = function() return now end
getTimestampMs = Clock.now
Effects.accept = function() return true end
getSpecificPlayer = function() return {getX = function() return 0 end,
    getY = function() return 0 end, getZ = function() return 0 end} end
local tile = {isCanSee = function() return visible end}
getCell = function() return {getGridSquare = function() return tile end, addLamppost=function() end, removeLamppost=function() end} end
IsoLightSource = {new=function() return {setR=function() end,setG=function() end,setB=function() end,setActive=function() end} end}
instanceItem = function(name)
    return {name = name, setWorldScale = function(self, value) self.scale = value end,
        setWorldAlpha = function(self, value) self.alpha = value end}
end
Draw.draw = function(item, square, x, y, z)
    draws[#draws + 1] = {name = item.name, alpha = item.alpha, z = z, scale = item.scale}
end
View.bursts, View.cursor, View.model = {}, 1, nil
local module = require("OMHTT/Foundation").MODULE
View.receive(module, "Arc", {fromX = 0, fromY = 0, x = 3, y = 0, z = 0})
View.render(0)
check(#draws > 0 and draws[1].name == "Base.OMHTTTurretArcVisual" and draws[1].alpha == 1,
    "Arc uses its electrical model at full flash opacity")
check(draws[1].z >= .26 and draws[1].z <= .34, "Arc height has no legacy camera compensation")
now, draws = 1205, {}
View.render(0)
check(#draws > 0 and math.abs(draws[1].alpha - .25) < .000001, "Arc fades through native alpha halfway into decay")
visible, draws = false, {}
View.render(0)
check(#draws == 0, "Fading electricity still obeys tile visibility")
visible, now, draws = true, 1330, {}
View.render(0)
check(#draws == 0 and View.bursts[1] == nil, "Arc expires only after reaching zero opacity")
View.receive(module, "Arc", {fromX = 0, fromY = 0, x = 3, y = 0, z = math.huge})
check(View.cursor == 2, "Infinite effect floor is rejected")
for i = 1, 64 do View.receive(module, "Arc", {fromX = 0, fromY = 0, x = 9, y = 0, z = 0}) end
View.render(0)
check(#draws == 192, "Thicker fading effects retain the existing draw budget")
Tether.states, Tether.visuals = {}, {}
Tether.states["control-1"] = {phase = "out", z = 0, x = .08, y = .5, dx = 1, dy = 0,
    height = .3, distance = 1, range = 6, speed = 30, returnSpeed = 4}
Tether.received["control-1"], Tether.simulated["control-1"], draws = now, now, {}
Tether.render(0)
check(#draws > 1 and draws[1].z == .3, "Nail shares the wall panel's .3 launch height")
check(math.abs(draws[2].z - .3) < .025, "Cable begins at the same mount with bounded sag")
Tether.states["control-1"].phase, Tether.states["control-1"].height = "back", .025
draws = {}
Tether.render(0)
check(draws[1].z == .025, "Retracting nail reaches floor height without a floating offset")
View.bursts, View.cursor, View.model = {}, 1, nil
Tether.states, Tether.visuals, Tether.received, Tether.from = {}, {}, {}, {}
Clock.now, Effects.accept, getSpecificPlayer = saved.clock, saved.accept, saved.player
getCell, instanceItem, Draw.draw, getTimestampMs = saved.cell, saved.item, saved.draw, saved.timestamp

local Benefits = require("OMHTT/TurretBenefits")
local oldText = getText
getText = function(key, a, b) return key .. ":" .. tostring(a) .. ":" .. tostring(b) end
local tip = Benefits.battery({}, {modulePower = 3, regulator = 1.25})
check(string.find(tip, "UI_OMHTT_BatteryModuleTotal:3:", 1, true)
    and string.find(tip, "UI_OMHTT_BatteryRegulatedTotal:2.4:20", 1, true),
    "Battery tooltip distinguishes added module load and effective Regulator total")
tip = Benefits.battery({}, {modulePower = 1, regulator = 1})
check(not string.find(tip, "UI_OMHTT_BatteryRegulatedTotal", 1, true), "No imaginary Regulator reduction")
getText = oldText
print("[OMHTT-C427] native-path effect opacity, mount heights, draw bounds and battery totals checked")

require("OMHTT/TurretArcLight").clear()
IsoLightSource = saved.light
