-- Investigation only: these assertions reproduce released failures, not fixes.
local V=require("OMHTT/TurretVolley")
local Clock=require("OMHTT/TurretClock")
local Damage=require("OMHTT/Damage")
local Effects=require("OMHTT/DefenseEffects")
local View=require("OMHTT/PrototypeEffects")
local saved={mode=testMode,time=testMillis,clock=Clock.now,available=Damage.available,
    emit=Effects.emit,queue=V.queue,effects=View.effects}
testMode,testMillis="server",910000
Clock.now=function() return testMillis end
local square=makeSquare(12100,12100,0)
local victim=makeZombie(square,1)
local packets={}
Effects.emit=function(command,facts) packets[#packets+1]={command,facts} end
Damage.available=function() return false end
V.queue={}
local group={kind="splitter",stats={firearm=true},remaining=6,hits={}}
for i=1,6 do
    V.ray({id="c532",shots=1},12100.5,12100.5,0,0,30,.1,group,i)
    local ray=V.queue[i]
    ray.best,ray.bestDistance,ray.distance,ray.square=victim,1,1,square
    check(V.finish(ray)==true,"C532 firearm child waits behind busy damage victim")
end
check(#packets==0,"C532 no firearm child presentation emitted while damage admission is busy")
testMillis=911000
Damage.available=function() return true end
victim.health=0
for i=1,6 do check(V.finish(V.queue[i])==false,"C532 delayed child finishes after its victim dies") end
check(#packets==6,"C532 six late tracers emitted without dealing new damage")
testMode="client"
View.effects={}
for i=1,#packets do
    local packet=packets[i]
    check(packet[2].start==nil and packet[2].firedAt==nil,"C532 firearm Ray lacks original firing timestamp")
    View.receive(require("OMHTT/Foundation").MODULE,packet[1],packet[2])
end
check(#View.effects==6 and View.effects[1].start==911000,
    "C532 delayed firearm tracers begin fresh one second after original shot")
V.queue,View.effects,Effects.emit,Damage.available=saved.queue,saved.effects,saved.emit,saved.available

local B=require("OMHTT/ControlBuildReservation")
local P=require("OMHTT/ControlPokeFootprint")
local oldReserved,oldRequire,oldEntity=P.reserved,require,ISBuildIsoEntity
P.reserved=function(tile) return tile and tile:getX()==12101 and tile:getY()==12100 end
local arm=makeSquare(12101,12100,0)
local outside=makeSquare(12102,12100,0)
check(B.blocked(arm,false,true),"C532 center-to-arm wall currently blocked if hook works")
check(B.blocked(outside,false,true),"C532 allowed outer-end wall is incorrectly blocked if hook works")
P.reserved=oldReserved
require=function(name) if string.sub(name,1,16)=="BuildingObjects/" then return end;return oldRequire(name) end
ISBuildIsoEntity=nil
local ok=pcall(B.install)
check(not ok,"C532 early startup fails when native server building class is not loaded")
require,ISBuildIsoEntity=oldRequire,oldEntity

local Active=require("OMHTT/ActiveTime")
local oldGame,oldPaused,oldStamp=getGameTime,GameTime.isGamePaused,getTimestampMs
getGameTime=function() return {getWorldAgeHours=function() return 100 end,
    getMinutesPerDay=function() return 90 end,getMultiplier=function() return 0 end} end
GameTime.isGamePaused=function() return false end
getTimestampMs=function() return testMillis end
local visualClock,simulationClock=Active.new(),Active.new(true)
Active.step(visualClock);Active.step(simulationClock)
testMillis=testMillis+1000
check(Active.step(visualClock)==1000 and Active.step(simulationClock)==0,
    "C532 zero-rate multiplayer clock freezes simulation but not presentation time")
testMode="server"
local clicks=0
Effects.emit=function(command) if command=="Click" then clicks=clicks+1 end end
local W=require("OMHTT/TurretWorld")
local object={getSquare=function() return square end}
W.empty(object);testMillis=testMillis+1000;W.empty(object)
check(clicks==2,"C532 repeated empty requests still sound while game multiplier is zero")
local Audio=require("OMHTT/ControlAudio")
local oldWorld,oldPlaying=getWorld,Audio.playing
local starts,volume=0,nil
local emitter={playSound=function() starts=starts+1;return 1 end,setVolume=function(_,_,v) volume=v end,
    stopSound=function() end}
getWorld=function() return {getFreeEmitter=function() return emitter end} end
testMode="client"
Audio.playing={}
Audio.receive("OMHTTDeviceAudio","Play",{id="c532-reel",event="reel",x=12100,y=12100,z=0})
Audio.tick()
check(starts==1 and volume>0,"C532 reel audio starts and remains audible at zero multiplayer clock rate")
getWorld,Audio.playing=oldWorld,oldPlaying
getGameTime,GameTime.isGamePaused,getTimestampMs=oldGame,oldPaused,oldStamp
Effects.emit=saved.emit
testMode,testMillis,Clock.now=saved.mode,saved.time,saved.clock
testPackAudit="C532 reproduced: six no-damage late firearm tracers at +1000ms; outer-edge overblocking; absent-class startup error; zero-rate presentation/empty/reel audio. Synthetic contention and pause state, zero connected clients."
