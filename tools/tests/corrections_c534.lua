local V=require("OMHTT/TurretVolley")
local Clock=require("OMHTT/TurretClock")
local Damage=require("OMHTT/Damage")
local Effects=require("OMHTT/DefenseEffects")
local View=require("OMHTT/PrototypeEffects")
local Active=require("OMHTT/ActiveTime")
local saved={mode=testMode,time=testMillis,clock=Clock.now,available=Damage.available,
    emit=Effects.emit,queue=V.queue,effects=View.effects,game=getGameTime,paused=GameTime.isGamePaused,
    world=getWorld,sound=View.sound,players=getNumActivePlayers,player=getSpecificPlayer,zero=Active.zeroRate}
testMode,testMillis="server",910000
Clock.now=function() return testMillis end
local square=makeSquare(12100,12100,0)
local victim=makeZombie(square,1)
local packets={}
Effects.emit=function(command,facts) facts.packet="c534-"..facts.id..":"..facts.shot; packets[#packets+1]={command,facts} end
Damage.available=function() return false end
for _,count in pairs({1,2,5,6,16}) do
    V.queue,packets={},{}
    victim.health=1
    local group={kind="splitter",stats={firearm=true},remaining=count,hits={}}
    for i=1,count do
        V.ray({id="c534-"..count,shots=1},12100.5,12100.5,0,0,30,.1,group,i)
        local ray=V.queue[i]
        ray.best,ray.bestDistance,ray.distance,ray.square=victim,1,1,square
        check(V.finish(ray)==true,"C534 damage still waits for admission")
    end
    check(#packets==count,"C534 busy victim does not hold firearm presentation")
    testMode="client"
    View.effects={}
    for i=1,#packets do View.receive(require("OMHTT/Foundation").MODULE,packets[i][1],packets[i][2]) end
    check(#View.effects==count,"C534 stacked burst displays at contact time")
    testMillis=testMillis+1000
    View.effects={}
    for i=1,#packets do View.receive(require("OMHTT/Foundation").MODULE,packets[i][1],packets[i][2]) end
    check(#View.effects==0,"C534 old firearm burst cannot restart after ammo depletion")
    testMode="server"
    victim.health=0
    Damage.available=function() return true end
    for i=1,count do check(V.finish(V.queue[i])==false,"C534 dead victim settles without new damage") end
    check(#packets==count,"C534 damage settlement never duplicates traces")
    Damage.available=function() return false end
end

local P=require("OMHTT/ControlPokeFootprint")
local B=require("OMHTT/ControlBuildReservation")
local originalCenter,originalReserved=P.center,P.reserved
local center=makeSquare(12200,12200,0)
for x=12198,12202 do for y=12198,12202 do makeSquare(x,y,0) end end
center=testSquares["12200:12200:0"]
P.center=function(tile) return tile==center end
for _,edge in pairs({{0,0,true},{0,1,true},{0,0,false},{1,0,false}}) do
    check(B.blocked(testSquares[(12200+edge[1])..":"..(12200+edge[2])..":0"],edge[3],true),
        "C534 inner center-to-arm wall blocked")
end
for _,edge in pairs({{0,-1,true},{0,2,true},{-1,0,false},{2,0,false}}) do
    check(not B.blocked(testSquares[(12200+edge[1])..":"..(12200+edge[2])..":0"],edge[3],true),
        "C534 outer stabilizer-end wall allowed")
end
for _,offset in pairs(P.offsets) do
    check(B.blocked(testSquares[(12200+offset[1])..":"..(12200+offset[2])..":0"],false,false),
        "C534 furniture cannot occupy any assembly tile")
end
P.center,P.reserved=originalCenter,originalReserved
local entity,wall=ISBuildIsoEntity,ISWoodenWall
ISBuildIsoEntity,ISWoodenWall=nil,nil
for i=1,#Events.OnGameBoot.handlers do
    check(Events.OnGameBoot.handlers[i]~=B.install,"C534 menu boot must not install absent building classes")
end
local found=0
for _,event in pairs({Events.OnGameStart,Events.OnServerStarted}) do
    for i=1,#event.handlers do if event.handlers[i]==B.install then found=found+1 end end
end
check(found==2,"C534 client/SP and dedicated gameplay install the build gate")
ISBuildIsoEntity,ISWoodenWall=entity,wall

testMode="client"
local starts,volume=0,nil
local emitter={playSound=function() starts=starts+1;return 1 end,setVolume=function(_,_,v) volume=v end,stopSound=function() end}
getWorld=function() return {getFreeEmitter=function() return emitter end} end
local distance=0
getNumActivePlayers=function() return 1 end
getSpecificPlayer=function() return {getX=function() return distance end,getY=function() return 0 end,getZ=function() return 0 end} end
for _,d in pairs({0,4,8,20,30}) do
    distance=d
    for _,sound in pairs({"OMHTTTriggerClick","NativeGunClick"}) do
        starts,volume=0,nil
        View.receive(require("OMHTT/Foundation").MODULE,"Click",{sound=sound,warning=true,x=0,y=0,z=0})
        check(starts==(d<8 and 1 or 0),"C534 warning cutoff covers empty and native misfire")
        if d==4 then check(volume<=.25,"C534 warning softens before cutoff") end
    end
end
starts=0
View.receive(require("OMHTT/Foundation").MODULE,"Click",{sound="RotaryMovement",x=0,y=0,z=0})
check(starts==1,"C534 ordinary movement/fragment/reload sounds retain native range")

local multiplier,hours=0,100
getGameTime=function() return {getTrueMultiplier=function() return 1 end,getWorldAgeHours=function() return hours end,
    getMinutesPerDay=function() return 90 end,getMultiplier=function() return multiplier end, getTrueMultiplier=function() return multiplier end,} end
GameTime.isGamePaused=function() return false end
local presentation,simulation=Active.new(),Active.new(true)
Active.step(presentation);Active.step(simulation)
testMillis=testMillis+1000
check(Active.paused() and Active.step(presentation)==0 and Active.step(simulation)==0,
    "C534 zero multiplier freezes presentation and simulation")
Active.pause()
multiplier=1
check(Active.paused(),"C534 cached stopped tick covers native clock rewrites")
Active.pause()
check(not Active.paused() and Active.step(presentation)==0,"C534 resume discards paused wall interval")
check(Active.step(simulation)==0,"C534 simulation discards paused interval")
testMillis=testMillis+100
hours=hours+100/225000
check(Active.step(presentation)==100 and math.abs(Active.step(simulation)-100)<.001,"C534 resumed clocks advance normally")
multiplier=0
local clicks=0
Effects.emit=function(command) if command=="Click" then clicks=clicks+1 end end
require("OMHTT/TurretWorld").empty({getSquare=function() return square end})
check(clicks==0,"C534 empty turret stays silent during zero-rate pause")
local Audio=require("OMHTT/ControlAudio")
local playing=Audio.playing
Audio.playing={}
starts=0
Audio.receive("OMHTTDeviceAudio","Play",{id="c534",event="reel",x=0,y=0,z=0})
check(starts==0,"C534 paused tether cannot start reel audio")
Audio.playing.c534={emitter=emitter,handle=1,expires=Audio.time+5000}
Audio.tick()
check(volume==0,"C534 existing reel mutes during zero-rate pause")
multiplier=1
Active.pause();Audio.tick()
check(volume>0,"C534 existing reel restores volume after resume")
Audio.playing=playing
getGameTime,GameTime.isGamePaused,Active.zeroRate=saved.game,saved.paused,saved.zero
getWorld,View.sound,getNumActivePlayers,getSpecificPlayer=saved.world,saved.sound,saved.players,saved.player
testMode,testMillis,Clock.now=saved.mode,saved.time,saved.clock
V.queue,View.effects,Effects.emit,Damage.available=saved.queue,saved.effects,saved.emit,saved.available
testPackAudit="C534 1/2/5/6/16 busy-target bursts, stale packet suppression, four-direction wall edges, audio distances 0/4/8/20/30 and pause/resume passed. Test doubles; zero connected clients."
