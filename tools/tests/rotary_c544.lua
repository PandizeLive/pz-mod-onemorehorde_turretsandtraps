-- Production observation -> motor/standby -> geometry -> damage admission.
-- Engine entities, network delivery and the damage sink are explicit adapters.
local Rotary = require("OMHTT/TurretRotary")
local Index = require("OMHTT/TurretRotaryContacts")
local Actors = require("OMHTT/DefenseActors")
local Reports = require("OMHTT/DefenseContactServer")
local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")
local M = require("OMHTT/TurretModules")
local Damage = require("OMHTT/Damage")
local Proc = require("OMHTT/TurretProc")
local Clock = require("OMHTT/TurretClock")
local Horde = require("OMHTT/DefenseHorde")
local Combat = require("OMHTT/PrototypeCombat")
local Policy = require("OMHTT/ControlCombat")
local Managed = require("OMHTT/ControlCycle")
local Authority = require("OMHTT/TurretAuthority")
local Audio = require("OMHTT/ControlAudio")
local Automation = require("OMHTT/TurretAutomation")
local Standby = require("OMHTT/TurretStandby")
local saved = {}
local function replace(object, key, value)
    saved[#saved + 1] = {object=object,key=key,value=object[key]}
    object[key] = value
end
local oldMode, oldMillis = testMode, testMillis
testMode, testMillis = "server", 4000000
replace(Horde,"allowed",function() return true end)
replace(Combat,"clearLane",function() return true end)
replace(Policy,"eligible",function(_, actor) return not actor:isDead() end)
replace(Proc,"available",function() return true end)
replace(Proc,"reserve",function() end)
replace(Proc,"release",function() end)
replace(Proc,"hit",function() end)
replace(Managed,"managed",function() return false end)
replace(Authority,"publish",function() end)
replace(Audio,"emit",function() end)
replace(Clock,"now",function() return testMillis end)
replace(Actors,"refresh",function() end)
replace(W,"valid",function(object) return object:getObjectIndex()>=0 end)
replace(W,"power",function() return {kind="fixture",cost=0} end)
replace(SandboxVars.OMHTurretsTraps,"TurretStandbyEnabled",true)
replace(SandboxVars.OMHTurretsTraps,"TurretWakeSeconds",1)
replace(SandboxVars.OMHTurretsTraps,"TurretAlertDelay",.25)
replace(SandboxVars.OMHTurretsTraps,"EnhancedFireMultiplier",4/3)
replace(Automation,"entries",{})
replace(Automation,"order",{})
replace(Automation,"cursor",1)
local realStep = Automation.step
replace(Automation,"step",function(entry,deadline)
    if entry.fixtureIdle then return true end
    return realStep(entry,deadline)
end)
local contentsByObject = {}
replace(W,"contents",function(object) return contentsByObject[object] end)
local requests, applied, pending, acknowledgements = 0, 0, {}, 0
local productionResolve=Damage.resolve
replace(Damage,"resolve",function(_,_,_,_,callback,observation)
    requests=requests+1
    check(observation.at<=testMillis and testMillis-observation.at<=250,"C544 damage retains fresh observation")
    pending[#pending+1]={due=testMillis+acknowledgements,callback=callback}
    return true
end)
local function drain(all)
    for i=#pending,1,-1 do
        if all or pending[i].due<=testMillis then
            pending[i].callback(.4);applied=applied+1;table.remove(pending,i)
        end
    end
end
local serial=0
local function fixture(kind,rapid,omni,count)
    local readyAt=testMillis
    testMillis=testMillis-500
    serial=serial+1
    local x,y=24000+serial*12,24000
    for dx=-4,4 do for dy=-4,4 do makeSquare(x+dx,y+dy,0) end end
    local origin=getCell():getGridSquare(x,y,0)
    local object=IsoObject.new(origin,"test","test");origin:AddTileObject(object)
    Authority.register(object,{schema=1,id="turret-c544-"..serial,powered=true,standby="asleep",baseFacing=0})
    local actor=makeZombie(getCell():getGridSquare(x+1,y,0),100)
    actor.owner={getOnlineID=function() return 88 end,isDead=function() return false end}
    actor.onlineId,actor.outfitId=24544+serial,24544+serial
    Actors.observe(actor)
    local contents={head=instanceItem("Base.OMHTTTurret"..kind),heads=1,powerLoad=0,active={MotionDetection=1,
        MotionDetectionEnhanced=1,Firing=1,FiringEnhanced=1,Detection360=omni and 1 or nil,RapidFire=rapid}}
    contentsByObject[object]=contents
    Automation.changed(object,contents.head)
    local entry=Automation.entries[object]
    entry.soundAt=math.huge
    Automation.order,Automation.cursor={entry},1
    for i=2,count do Automation.order[i]={fixtureIdle=true} end
    testMillis=readyAt
    return {object=object,entry=entry,actor=actor,x=x+.5,y=y+.5,sequence=0,contents=contents,state=T.state(object)}
end
local function report(f, x, y, lag, overrides)
    f.sequence=f.sequence+1
    local packet={id=f.actor.onlineId,outfit=f.actor.outfitId,sequence=f.sequence,x=x,y=y,z=0,age=0,
        observedAt=testMillis-lag,prone=false,down=false,landing=false}
    for key,value in pairs(overrides or {}) do packet[key]=value end
    Reports.command("OMHTT_ContactV1","Observe",f.actor.owner,{packet})
end
local function cleanup(f)
    drain(true)
    Index.remove(f.object);Actors.remove(f.actor);Automation.entries[f.object]=nil
    Standby.entries[f.object]=nil;contentsByObject[f.object]=nil
end
local lines={}
local cases=0
for _,count in pairs({1,4,8,12}) do
    for bearing=0,175,5 do
        testMillis=4000000+serial*40000
        local base=testMillis
        local f=fixture("RotaryBlades",0,true,count)
        local before=requests
        local wake,motor
        for time=0,30000,100 do
            testMillis=base+time
            report(f,f.x+math.cos(math.rad(bearing)),f.y-math.sin(math.rad(bearing)),100)
            Automation.tick();drain(false)
            if f.state.standby=="waking" and not wake then wake=time end
            if f.state.rotaryMoving and not motor then motor=time end
        end
        testMillis=base+30037
        report(f,f.x+math.cos(math.rad(bearing)),f.y-math.sin(math.rad(bearing)),100)
        local travel=Rotary.travelAt(f.entry,testMillis-100)
        local expected=math.floor((travel-bearing)/180)-math.floor(-bearing/180)
        local hits=requests-before
        check(hits==expected,"C544 all observed passes: entries="..count.." bearing="..bearing.." hits="..hits.." expected="..expected)
        check(wake==0 and motor==1300,"C544 scheduler wake entries="..count.." bearing="..bearing.." wake="..tostring(wake).." motor="..tostring(motor).." state="..tostring(f.state.standby))
        lines[#lines+1]=count..":"..bearing..":"..hits..":"..expected..":"..wake..":"..motor
        cleanup(f);cases=cases+1
    end
end
-- Real resolved 16-slot loadout: three automation modules plus13 Rapid Fire.
-- Delayed receipts must not suppress a later, distinct arm crossing.
acknowledgements=250
for _,kind in pairs({"RotaryBat","RotaryBlades"}) do
    for _,rapid in pairs({1,6,13}) do
        for _,lag in pairs({0,100,225}) do
            testMillis=testMillis+1000
            local base=testMillis
            local f=fixture(kind,rapid,true,64)
            local before=requests
            for time=0,10000,100 do
                testMillis=base+time
                report(f,f.x+1,f.y,lag)
                Automation.tick();drain(false)
            end
            testMillis=base+10037;report(f,f.x+1,f.y,lag)
            local travel=Rotary.travelAt(f.entry,testMillis-lag)
            check(requests-before==math.floor(travel/180),"C544 stacked modules preserve every pass with delayed acknowledgements")
            cleanup(f);cases=cases+1
        end
    end
end
check(requests==applied,"C544 each admitted hit completes once after draining receipts")
-- Cone reversals use the same resolved head definition and observation path.
for _,bearing in pairs({0,35,180,215}) do
    testMillis=testMillis+1000
    local base=testMillis
    local f=fixture("RotaryBat",13,false,12)
    f.state.rotaryManual=base+11000
    local before=requests
    for time=0,10000,100 do
        testMillis=base+time
        report(f,f.x+math.cos(math.rad(bearing)),f.y-math.sin(math.rad(bearing)),100)
        Automation.tick();drain(false)
    end
    testMillis=base+10037
    report(f,f.x+math.cos(math.rad(bearing)),f.y-math.sin(math.rad(bearing)),100)
    local travel=Rotary.travelAt(f.entry,testMillis-100)
    local relative=bearing>=180 and bearing-180 or bearing
    local expected=0
    for stroke=0,math.floor(travel/90) do
        local phase=relative+45
        if stroke%2==1 then phase=90-phase end
        if stroke*90+phase<=travel then expected=expected+1 end
    end
    check(requests-before==expected,"C544 cone bearing="..bearing.." hits="..(requests-before).." expected="..expected.." travel="..travel)
    cleanup(f);cases=cases+1
end
-- Construct one known motor interval, then feed movement through production report validation.
-- The first report is the baseline, so no contact can be backdated before it.
local function movement(from,to,blocked,expected)
    testMillis=testMillis+1000
    local f=fixture("RotaryBlades",0,true,12)
    f.state.rotaryManual=testMillis+1000
    f.state.rotaryMoving=true
    f.entry.travel=350;f.entry.rotaryAt=testMillis;f.entry.timeline={}
    Rotary.record(f.entry,350,350,0)
    local before=requests
    report(f,f.x+from,f.y,0)
    if blocked then Combat.clearLane=function() return false end end
    testMillis=testMillis+100
    report(f,f.x+to,f.y,0)
    check(requests-before==expected,"C544 observed movement "..from.." -> "..to.." blocked="..tostring(blocked))
    Combat.clearLane=function() return true end
    cleanup(f)
end
movement(2.1,1.7,false,1)
movement(1.7,2.1,false,1)
movement(2.4,2.2,false,0)
movement(2.1,1.7,true,0)
-- Native/SP observations share the listener without requiring an owner connection.
for _,mode in pairs({"server","sp"}) do
    testMillis=testMillis+1000
    local f=fixture("RotaryBat",0,true,12)
    f.actor.owner=nil
    f.object:getModData().OMHTTTurret=f.state
    testMode=mode
    local before=requests
    for i=1,60 do testMillis=testMillis+100;Actors.observe(f.actor);Automation.tick();drain(false) end
    check(requests>before,"C544 "..mode.." native unowned contact remains functional")
    testMode="server";cleanup(f)
end
-- One accepted observation reaches traps exactly once alongside the rotary listener.
testMillis=testMillis+1000
local mixed=fixture("RotaryBlades",0,true,1)
local Traps=require("OMHTT/DefenseContacts")
local oldHandler=Traps.handlers.barb
local contacts=0
Traps.handlers.barb=function(_,position)
    contacts=contacts+1
    check(Traps.current==position,"C544 trap handler retains its validated observation context")
end
Traps.watch("c544-mixed","barb",mixed.x+1,mixed.y,mixed.x+1,mixed.y,0)
report(mixed,mixed.x+1,mixed.y,0)
check(contacts==1 and Traps.current==nil,"C544 shared dispatch neither duplicates traps nor leaks context")
Traps.remove("c544-mixed");Traps.handlers.barb=oldHandler
cleanup(mixed)
-- Sending a snapshot later must not change the time represented by motor travel.
testMillis=testMillis+1000
local visual=fixture("RotaryBlades",0,true,1)
local sample=visual.state.aimAt
testMillis=testMillis+100
W.publishRuntime(visual.object,visual.state,visual.contents,testMillis)
check(visual.state.aimAt==sample,"C544 rotary snapshot retains the motor sample timestamp")
cleanup(visual)
-- A delayed contact owns the energy from its actual pass, not the later motor sample.
testMillis=testMillis+1000
local energyCase=fixture("RotaryBlades",0,true,1)
report(energyCase,energyCase.x+1,energyCase.y,0)
local paid={cost=.01}
energyCase.entry.timeline={{from=testMillis-100,at=testMillis-25,before=350,after=365,energy={[1]=paid}},
    {from=testMillis-25,at=testMillis,before=365,after=370,energy={[1]={cost=.02}}}}
energyCase.entry.contactFrames={[energyCase.actor]={id=energyCase.actor:getOnlineID(),player=energyCase.actor:getOwnerPlayer(),epoch=require("OMHTT/ActiveTime").epoch,at=testMillis-100,owner=energyCase.actor.owner,
    outfit=energyCase.actor.outfitId,x=energyCase.x+1,y=energyCase.y,z=0}}
local reserve=Proc.reserve
local captured
Proc.reserve=function(options) captured=options.siphon end
local stats=T.cycleConfig(energyCase.contents)
Rotary.contact(energyCase.entry,energyCase.actor,{at=testMillis,observedAt=testMillis,stats=stats,
    profile=M.profile(energyCase.state,energyCase.contents,false,stats)})
check(captured==paid,"C544 delayed contact keeps the original paid Siphon pass")
Proc.reserve=reserve;cleanup(energyCase)
local accelerated={}
Rotary.record(accelerated,0,0,0)
testMillis=testMillis+100
Rotary.record(accelerated,0,200,1000)
check(Rotary.travelAt(accelerated,testMillis-50)==100,"C544 accelerated motor travel stays on synchronized report timestamps")
-- Real report validation remains the entry point; no fresh report means no new damage.
testMillis=testMillis+1000
local f=fixture("RotaryBlades",13,true,12)
for i=0,30 do testMillis=testMillis+100;report(f,f.x+1,f.y,0);Automation.tick();drain(false) end
local before=requests
report(f,f.x+1,f.y,0,{sequence=f.sequence-1})
report(f,f.x+1,f.y,600)
report(f,f.x+1,f.y,0,{outfit=999999})
check(requests==before,"C544 duplicate, stale and wrong-identity frames never advance contacts")
for i=1,10 do testMillis=testMillis+100;Automation.tick() end
check(requests==before,"C544 missing reports cannot replay damage from stale coordinates")
local oldOwner=f.actor.owner
f.actor.owner={getOnlineID=function() return 89 end,isDead=function() return false end}
report(f,f.x+1,f.y,0)
check(requests==before,"C544 first new-owner report cannot replay an old owner's crossing")
f.actor.state="onground"
testMillis=testMillis+100;report(f,f.x+1,f.y,0,{prone=true,down=true})
check(requests==before,"C544 prone observation neither hits nor refreshes a target")
f.actor.state=nil
testMillis=testMillis+100;report(f,f.x+1,f.y,0)
check(requests==before,"C544 newly standing observation establishes a baseline without backdated damage")
local pause=GameTime.isGamePaused
GameTime.isGamePaused=function() return true end
local travel=f.entry.travel
for i=1,10 do testMillis=testMillis+100;report(f,f.x+1,f.y,0);Automation.tick() end
check(f.entry.travel==travel and requests==before,"C544 stable pause holds both motor and damage")
GameTime.isGamePaused=pause
-- Production clock does not advance during pause. Reset this wall-clock adapter accordingly.
f.entry.rotaryAt=testMillis;f.entry.gameAt=getGameTime():getWorldAgeHours()
testMillis=testMillis+100;report(f,f.x+1,f.y,0)
check(requests==before,"C544 resume does not replay contacts across a missing observation interval")
f.state.powered=false
testMillis=testMillis+100;report(f,f.x+1,f.y,0);Automation.tick()
check(requests==before,"C544 powered-off observation never damages")
Index.remove(f.object)
check(Index.entries[f.object]==nil,"C544 removal releases the local rotary index")
cleanup(f)
-- Spatial locality: distant actors do not run any rotary work.
testMillis=testMillis+1000
f=fixture("RotaryBlades",0,true,1)
local observe=Rotary.observe
local calls=0
Rotary.observe=function(...) calls=calls+1;return observe(...) end
local started=realMillis()
for i=1,10000 do Index.observe(f.actor,{x=f.x+1000,y=f.y+1000,z=0,at=testMillis},nil,true) end
local distantMs=realMillis()-started
check(calls==0,"C544 distant reports perform zero motor/contact evaluations")
Rotary.observe=observe
cleanup(f)
-- A crowded local packet is measured separately from distant-index rejection.
testMillis=testMillis+1000
local crowd=fixture("RotaryBlades",0,true,1)
local crowdActors={}
for i=1,32 do
    local actor=makeZombie(crowd.actor:getSquare(),100)
    actor.onlineId,actor.outfitId=28000+i,28000+i;actor.owner=crowd.actor.owner
    Actors.observe(actor);crowdActors[i]=actor
end
local packetTimes={}
for tick=1,40 do
    testMillis=testMillis+100
    local packet={}
    for i=1,#crowdActors do
        local actor=crowdActors[i]
        packet[i]={id=actor.onlineId,outfit=actor.outfitId,sequence=tick,x=crowd.x+1,y=crowd.y,z=0,age=0,
            observedAt=testMillis,prone=false,down=false,landing=false}
    end
    local began=realMillis()
    Reports.command("OMHTT_ContactV1","Observe",crowd.actor.owner,packet)
    packetTimes[#packetTimes+1]=realMillis()-began
    drain(false)
end
local movingPacketTimes={}
for tick=41,80 do
    testMillis=testMillis+100
    local packet={}
    for i=1,#crowdActors do
        local angle=math.rad(i*11+tick*6)
        local actor=crowdActors[i]
        packet[i]={id=actor.onlineId,outfit=actor.outfitId,sequence=tick,x=crowd.x+.8*math.cos(angle),
            y=crowd.y-.8*math.sin(angle),z=0,age=0,observedAt=testMillis-65,prone=false,down=false,landing=false}
    end
    local began=realMillis()
    Reports.command("OMHTT_ContactV1","Observe",crowd.actor.owner,packet)
    movingPacketTimes[#movingPacketTimes+1]=realMillis()-began
    drain(false)
end
table.sort(movingPacketTimes)
table.sort(packetTimes)
for i=1,#crowdActors do Actors.remove(crowdActors[i]) end
cleanup(crowd)
testRotaryC544="cases="..cases.." angleCases=144 zeroHitAngles=0 wakeMs=0 motorMs=1300 delayedReceipts=250ms distantReports=10000 distantMotorCalls=0 distantMs="..distantMs.." liveClients=0"
testRotaryC544=testRotaryC544.." crowdActors=32 packetP95Ms="..packetTimes[38].." packetMaxMs="..packetTimes[40]
testRotaryC544Cases=table.concat(lines,";")
print("C544 rotary: "..testRotaryC544)
do
local Heads=require("OMHTT/TurretHeads")
local customType="Base.OMHTTTurretTestRotary"
replace(Heads.definitions,customType,{key="TestRotary",rotary=true,damage=35,range=3,shove=0,fireSound="BaseballBatHit"})
local function scenario(kind,radius,a,b,nativeDown,reportedDown)
    testMillis=testMillis+1000
    local f=fixture(kind,0,true,12)
    f.entry.rotaryAt=testMillis
    f.entry.travel=360
    f.entry.timeline={}
    f.state.rotaryManual=testMillis+2000
    f.state.rotaryMoving=true
    Rotary.record(f.entry,360,360,0)
    if nativeDown then f.actor.state="onground" end
    local function deliver(angle)
        report(f,f.x+radius*math.cos(math.rad(angle)),f.y-radius*math.sin(math.rad(angle)),0,{down=reportedDown,prone=reportedDown})
    end
    deliver(a)
    local initial=requests
    testMillis=testMillis+100
    deliver(b)
    local result=requests-initial
    cleanup(f)
    return result
end
local function oracle(radius,a,b)
    local x0,y0=radius*math.cos(math.rad(a)),radius*math.sin(math.rad(a))
    local x1,y1=radius*math.cos(math.rad(b)),radius*math.sin(math.rad(b))
    local crossings=0
    local previous=y0
    for n=1,1000 do
        local t=n/1000
        local theta=math.rad(20*t)
        local side=(y0+(y1-y0)*t)*math.cos(theta)-(x0+(x1-x0)*t)*math.sin(theta)
        if (side>0)~=(previous>0) then crossings=crossings+1 end
        previous=side
    end
    return crossings
end
local function clockPhase(kind,offset)
    testMillis=testMillis+4000
    local f=fixture(kind,0,true,1)
    local base=testMillis
    local tick=base
    local savedNow=Clock.now
    Clock.now=function() return tick end
    f.entry.rotaryAt=base
    f.entry.travel=360
    f.entry.timeline={}
    f.state.rotaryManual=base+7000
    f.state.rotaryMoving=true
    Rotary.record(f.entry,360,360,0)
    local x=f.x+.5*math.cos(math.rad(10))
    local y=f.y-.5*math.sin(math.rad(10))
    report(f,x,y,0)
    local before=requests
    local uncovered=0
    for i=1,50 do
        tick=base+i*100
        testMillis=tick
        Automation.tick()
        testMillis=tick+offset
        report(f,x,y,65)
        if Rotary.travelAt(f.entry,testMillis-65)==nil then uncovered=uncovered+1 end
        drain(false)
    end
    tick=tick+100;testMillis=tick;Automation.tick()
    local delta=f.entry.travel-360
    local admitted=requests-before
    Clock.now=savedNow
    cleanup(f)
    return admitted,uncovered,delta
end

local paths=0
for _,kind in pairs({"RotaryBat","RotaryBlades","TestRotary"}) do
    for _,radius in pairs({.45,.65,1,1.5}) do
        for a=-9,35,4 do
            for b=-9,35,4 do
                if 2*radius*math.abs(math.sin(math.rad((a-b)/2)))<=.18 then
                    local hits=scenario(kind,radius,a,b,false,false)
                    check(hits==oracle(radius,a,b),"C546 moving crossing "..kind.."/"..radius.."/"..a.."/"..b.." hits="..hits)
                    paths=paths+1
                end
            end
        end
    end
    check(scenario(kind,.5,10,10,true,false)==1,"C546 authoritative observed standing "..kind)
    check(scenario(kind,.5,10,10,false,true)==0,"C546 authoritative observed down "..kind)
    for _,offset in pairs({15,85}) do
        local hits=clockPhase(kind,offset)
        check(hits==6,"C546 early and late reports both produce six hits "..kind.." offset="..offset.." hits="..hits)
    end
end
local S=require("OMHTT/TurretRotarySweep")
local omni={heading=0,omni=true,cone=360}
local function countGeometry(profile,first,last,x,y,dx,dy)
    local seen={}
    S.crossings(profile,first,last,x,y,dx,dy,function(arm,pass)
        local key=arm..":"..pass
        seen[key]=(seen[key] or 0)+1
    end)
    local n=0
    for _,count in pairs(seen) do n=n+count end
    return n
end
check(countGeometry(omni,0,20,.1,.1,-.2,-.2)==1,"C546 pivot traversal hits once")
local yaw=math.rad(10)
local ux,uy=math.cos(yaw),math.sin(yaw)
local vx,vy=.15*ux-math.rad(20)*uy,.15*uy+math.rad(20)*ux
check(countGeometry(omni,0,20,ux-vx/2,uy-vy/2,vx,vy)==1,"C546 grazing tangent contact")
check(countGeometry(omni,0,20,ux-vx/2+.01*uy,uy-vy/2-.01*ux,vx,vy)==0,"C546 near tangent outside blade")
check(countGeometry(omni,0,0,.1,.1,-.2,-.2)==0,"C546 stopped arms never hit")
local coasting={}
Rotary.record(coasting,350,350,0)
testMillis=testMillis+100
Rotary.record(coasting,350,360,100,.5)
check(Rotary.travelAt(coasting,testMillis-75)==355 and Rotary.travelAt(coasting,testMillis-25)==360,
    "C546 history holds the physical angle after reaching a stop between ticks")
local function deferredCase(reason)
    testMillis=testMillis+1000
    local f=fixture("RotaryBlades",0,true,1)
    local base=testMillis
    local active=base
    local previousClock=Clock.now
    Clock.now=function() return active end
    f.entry.rotaryAt=base
    f.entry.travel=350
    f.entry.timeline={}
    f.state.rotaryManual=base+5000
    f.state.rotaryMoving=true
    Rotary.record(f.entry,350,350,0)
    local prior=requests
    report(f,f.x+1,f.y,0)
    for i=1,2 do
        testMillis=base+i*100
        report(f,f.x+1,f.y,0)
    end
    check(requests==prior and f.entry.pendingContacts,"C546 two unevaluated reports are retained")
    if reason=="fallen" then
        testMillis=testMillis+1
        report(f,f.x+1,f.y,0,{down=true,prone=true})
    elseif reason=="handoff" then
        f.actor.ownerPlayer={getOnlineID=function() return 89 end}
    elseif reason=="pause" then
        local activeTime=require("OMHTT/ActiveTime")
        local pause=GameTime.isGamePaused
        GameTime.isGamePaused=function() return true end
        activeTime.pause()
        GameTime.isGamePaused=pause
        activeTime.pause()
    elseif reason=="expired" then
        testMillis=testMillis+251
    elseif reason=="power" then
        f.state.powered=false
    end
    testMillis=testMillis+10
    active=testMillis
    Automation.tick()
    local expected=reason=="valid" and 1 or 0
    check(requests==prior+expected,"C546 buffered "..reason.." expected "..expected.." got "..(requests-prior))
    Automation.tick()
    check(requests==prior+expected,"C546 buffered work consumed once")
    Clock.now=previousClock
    cleanup(f)
end
for _,reason in pairs({"valid","fallen","handoff","pause","expired","power"}) do deferredCase(reason) end
-- Apply a known strike through the real server damage path to a native-authority test actor.
for _,kind in pairs({"RotaryBat","RotaryBlades","TestRotary"}) do
    testMillis=testMillis+1000
    local f=fixture(kind,0,true,1)
    f.actor.owner=nil
    f.entry.rotaryAt=testMillis
    f.entry.travel=350
    f.entry.timeline={}
    f.state.rotaryManual=testMillis+2000
    f.state.rotaryMoving=true
    Rotary.record(f.entry,350,350,0)
    Actors.observe(f.actor)
    local fake=Damage.resolve
    Damage.resolve=productionResolve
    local initial=f.actor:getHealth()
    testMillis=testMillis+100
    Actors.observe(f.actor)
    local expectedLoss=T.cycleConfig(f.contents).damage/100
    check(math.abs(f.actor:getHealth()-(initial-expectedLoss))<.00001,"C546 "..kind.." actual health delta")
    Actors.observe(f.actor)
    check(math.abs(f.actor:getHealth()-(initial-expectedLoss))<.00001,"C546 "..kind.." duplicate cannot deduct twice")
    Damage.resolve=fake
    cleanup(f)
end

check(scenario("TestRotary",2.4,10,10,false,false)==1 and scenario("RotaryBlades",2.4,10,10,false,false)==0,
    "C546 custom reach is honored by detection and the hitbox")
check(paths==786,"C546 three-head moving matrix complete")
testRotaryC544=testRotaryC544.." correctedPaths="..paths.." stationaryPhaseChecks=6 movingPacketP95Ms="..movingPacketTimes[38].." movingPacketMaxMs="..movingPacketTimes[40]
end
for i=#saved,1,-1 do local item=saved[i];item.object[item.key]=item.value end
testMode,testMillis=oldMode,oldMillis
