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
    check(type(object)=="table", "C545 missing fixture dependency: "..key)
    saved[#saved + 1] = {object=object,key=key,value=object[key]}
    object[key] = value
end
local oldMode, oldMillis = testMode, testMillis
testMode, testMillis = "server", 4000000
replace(Horde,"allowed",function() return true end)
-- Use the production line trace.
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
    local x,y=35000+serial*12,35000
    for dx=-4,4 do for dy=-4,4 do makeSquare(x+dx,y+dy,0) end end
    local origin=getCell():getGridSquare(x,y,0)
    local object=IsoObject.new(origin,"test","test");origin:AddTileObject(object)
    Authority.register(object,{schema=1,id="turret-c545-"..serial,powered=true,standby="asleep",baseFacing=0})
    local actor=makeZombie(getCell():getGridSquare(x+1,y,0),100)
    actor.owner={getOnlineID=function() return 88 end,isDead=function() return false end}
    actor.onlineId,actor.outfitId=27545+serial,27545+serial
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

local function scenario(radius, beginBearing, endBearing, nativeDown, reportedDown)
    testMillis=testMillis+4000
    local f=fixture("RotaryBlades",0,true,12)
    check(f.entry and f.state, "C545 missing turret entry or state")
    f.entry.rotaryAt=testMillis
    f.entry.travel=360
    f.entry.timeline={}
    f.state.rotaryManual=testMillis+2000
    f.state.rotaryMoving=true
    Rotary.record(f.entry,360,360,0)
    local function deliver(angle)
        report(f, f.x+radius*math.cos(math.rad(angle)), f.y-radius*math.sin(math.rad(angle)),0,
            {prone=reportedDown,down=reportedDown})
    end
    if nativeDown then f.actor.state="onground" end
    deliver(beginBearing)
    local c0=f.entry.contactFrames and f.entry.contactFrames[f.actor]
    if not nativeDown then check(c0 and math.abs(c0.x-f.x-radius*math.cos(math.rad(beginBearing)))<.00001 and math.abs(c0.y-f.y+radius*math.sin(math.rad(beginBearing)))<.00001 and c0.at==testMillis,"C545 missing first validated position") end
    local first=requests
    testMillis=testMillis+100
    deliver(endBearing)
    local hits=requests-first
    local delta=f.entry.travel-360
    local c1=f.entry.contactFrames and f.entry.contactFrames[f.actor]
    if not nativeDown then check(c1 and math.abs(c1.x-f.x-radius*math.cos(math.rad(endBearing)))<.00001 and math.abs(c1.y-f.y+radius*math.sin(math.rad(endBearing)))<.00001 and c1.at==testMillis and math.abs(delta-20)<.00001,"C545 missing last validated position or motor travel") end
    cleanup(f)
    return hits,delta
end
local static,travel=scenario(.5,10,10,false,false)
local moving=scenario(.5,18,2,false,false)
local reverse=scenario(.5,2,18,false,false)
-- Independent oracle for a straight target path and a uniform 20-degree sweep.
-- The side of the rotating radial line changes sign when the arm passes the point.
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
local missExample,extraExample
local misses,falseHits,tested,expected,found=0,0,0,0,0
for _,radius in pairs({.45,.65,1,1.5}) do
    for a=-9,35,4 do
        for b=-9,35,4 do
            local distance=2*radius*math.abs(math.sin(math.rad((a-b)/2)))
            if distance<=.18 then
                local want=oracle(radius,a,b)
                local got=scenario(radius,a,b,false,false)
                if want>got and not missExample then missExample=radius.."/"..a.."/"..b.."/"..got.."/"..want end
                if want<got and not extraExample then extraExample=radius.."/"..a.."/"..b.."/"..got.."/"..want end
                tested=tested+1
                expected,found=expected+want,found+got
                misses=misses+math.max(0,want-got)
                falseHits=falseHits+math.max(0,got-want)
            end
        end
    end
end
testPackAudit=("C545 moving-contact comparison: stationary="..static.." moving18to2="..moving.." moving2to18="..reverse.." travel="..travel.." cases="..tested.." expected="..expected.." admissions="..found.." missed="..misses.." spurious="..falseHits.." missedExample="..tostring(missExample).." extraExample="..tostring(extraExample))
local mismatch1=scenario(.5,10,10,true,false)
local mismatch2=scenario(.5,10,10,false,true)
testPackAudit=testPackAudit..(" C545 stance disagreement: ownerStandingNativeDown="..mismatch1.." ownerDownNativeStanding="..mismatch2)

-- Offset report callbacks from the motor tick. Both clients report every 100 ms
-- with identical transit time and a stationary standing target.
local function clockPhase(offset)
    testMillis=testMillis+4000
    local f=fixture("RotaryBlades",0,true,1)
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
    local delta=f.entry.travel-360
    local admitted=requests-before
    Clock.now=savedNow
    cleanup(f)
    return admitted,uncovered,delta
end
local inHistory,noGaps,travelA=clockPhase(15)
local afterHistory,gaps,travelB=clockPhase(85)
testPackAudit=testPackAudit.." phase15ms="..inHistory.." phase85ms="..afterHistory.." unsupported="..noGaps.."/"..gaps.." travel="..travelA.."/"..travelB
check(tested==262 and expected==126 and found==130 and misses==21 and falseHits==25,
    "C545 released moving-target comparison")
check(static==1 and mismatch1==0 and mismatch2==1,"C545 released stance disagreement with standing control")
check(inHistory==6 and afterHistory==0 and noGaps==0 and gaps==50 and travelA==1000 and travelB==1000,
    "C545 equal travel and latency produce different admissions by report phase")
for i=#saved,1,-1 do local item=saved[i];item.object[item.key]=item.value end
testMode,testMillis=oldMode,oldMillis