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
local T=require("OMHTT/Turret")
local oldState,oldPlayer,oldCount=T.state,getSpecificPlayer,getNumActivePlayers
local oldEntries,oldOrder,oldCursor=V.entries,V.order,V.cursor
V.clear();V.entries,V.order,V.cursor={},{},1
local state={powered=true,standby="active",feedStatus="Empty"}
T.state=function() return state end
local playerX=7
getNumActivePlayers=function() return 1 end
getSpecificPlayer=function() return {getX=function() return playerX end,getY=function() return 8 end,getZ=function() return 0 end} end
local cell={addLamppost=function() adds=adds+1 end,removeLamppost=function() removes=removes+1 end,
    getGridSquare=function() return square end}
getCell=function() return cell end
IsoLightSource={new=function(x,y,z,r,g,b,radius)
    check(x==7 and y==8 and z==0 and radius==3,"Light uses native world coordinates")
    return {setR=function(self,n) self.r=n end,setG=function(self,n) self.g=n end,setB=function(self,n) self.b=n end,setActive=function(self,n) self.active=n end}
end}
instanceItem=function() return {setWorldAlpha=function(self,n) self.alpha=n end} end
Render3DItem=function() end
Draw.draw=function() end
Options.get=function() return true end
local entry={head={}}
V.track(object,entry);V.tick()
local light=V.lights[object].light
now=2250;V.tick();V.draw(object,entry,square,"Amber",true)
check(adds==1 and math.abs(light.r-.2)<.000001 and entry.indicator.alpha==.25,"Warning marker and independently updated light fade together")
now=2500;V.tick()
check(not light.active,"Warning dark interval")
state.feedStatus=nil;now=2550;V.tick()
check(light.active and light.g==.7 and adds==1,"Refill reuses steady green light without rendering")
state.standby="asleep";now=2600;V.tick()
check(light.active and light.r==.8 and light.g==.45,"Standby produces amber without rendering")
now=2900;V.tick()
check(V.lights[object]~=nil and removes==0,"Turning away does not expire loaded light")
playerX=100;now=3000;V.tick()
check(removes==1 and not V.lights[object],"Leaving local range removes world light")
playerX=7;now=3100;V.tick()
Options.get=function() return false end;now=3200;V.tick()
check(removes==2 and not V.lights[object],"Disabled marker preference removes light")
Options.get=function() return true end;now=3300;V.tick()
state.powered=false;now=3400;V.tick()
check(removes==3 and not V.lights[object],"Unpowered turret stays dark")
V.entries,V.order,V.cursor={},{},1
state.powered=true
local startAdds=adds
local devices={}
for i=1,160 do
    local device={index=0,getSquare=function() return square end,getObjectIndex=function(self) return self.index end}
    devices[i]=device
    V.track(device,{head={}})
end
now=3500;V.tick()
check(adds-startAdds==64,"C542 world-light work is bounded to64 loaded turrets per slice")
now=3600;V.tick();now=3700;V.tick()
check(adds-startAdds==160,"C542 fair lighting cursor reaches later turrets without repeated allocation")
for i=1,#devices do devices[i].index=-1 end
now=3800;V.tick();now=3900;V.tick();now=4000;V.tick()
check(#V.order==0 and removes==163,"C542 unloaded turrets release their native lights and tracking entries")
V.clear();V.entries,V.order,V.cursor=oldEntries,oldOrder,oldCursor
T.state,getSpecificPlayer,getNumActivePlayers=oldState,oldPlayer,oldCount
V.clear()
getTimestampMs, Effects.emit, getCell, IsoLightSource = saved.time, saved.emit, saved.cell, saved.light
Draw.draw, Render3DItem, instanceItem, Options.get = saved.draw, saved.render, saved.item, saved.options
