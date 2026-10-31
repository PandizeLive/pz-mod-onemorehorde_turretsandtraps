local R=require("OMHTT/TurretRenderer")
local T=require("OMHTT/Turret")
local saved={mode=testMode,time=testMillis,entries=R.entries}
testMode,testMillis="client",500000
local square=makeSquare(9800,9800,0)
local object=IsoObject.new(square,"test","test")
square:AddTileObject(object)
local state={schema=1,powered=true,standby="active",aimDegrees=0,rotaryTravel=0,rotarySpeed=180,rotaryMoving=false,aimAt=testMillis-1500}
object:getModData().OMHTTTurret=state
local visual={profile={stats={rotary=true},heading=0,omni=true,cone=90},visualHeading=0}
R.entries={[object]=visual}
R.animate(testMillis)
check(visual.aimSample.motorValue==0,"C528 idle renderer uses the same motor timeline")
for time=0,4000,10 do
    testMillis=501000+time
    local snapshot=math.floor(time/250)*250
    state.rotaryMoving,state.rotaryTravel,state.aimAt=true,snapshot*.18,501000+snapshot
    R.animate(testMillis)
end
state.rotaryMoving,state.rotaryTravel,state.aimDegrees,state.aimAt=false,720,0,testMillis
local peak,at=0,0
local previous=visual.visualHeading
for elapsed=10,1500,10 do
    testMillis=505000+elapsed
    R.animate(testMillis)
    local turn=math.abs((visual.visualHeading-previous+540)%360-180)
    if turn>peak then peak,at=turn,elapsed end
    previous=visual.visualHeading
end
check(peak<.001,"C528 stopped renderer holds beyond the old fallback boundary")
testPackAudit="C528 actual renderer holds after stop: peak "..tostring(peak).." degrees per10ms at "..tostring(at).."ms after stop; no live rendering claim"
testMode,testMillis,R.entries=saved.mode,saved.time,saved.entries

local Rotary=require("OMHTT/TurretRotary")
local Actors=require("OMHTT/DefenseActors")
local Horde=require("OMHTT/DefenseHorde")
local Combat=require("OMHTT/PrototypeCombat")
local Policy=require("OMHTT/ControlCombat")
local Damage=require("OMHTT/Damage")
local Proc=require("OMHTT/TurretProc")
local Clock=require("OMHTT/TurretClock")
local old={allowed=Horde.allowed,lane=Combat.clearLane,eligible=Policy.eligible,resolve=Damage.resolve,
    available=Proc.available,reserve=Proc.reserve,clock=Clock.now}
testMode,testMillis="server",600000
local outside=makeSquare(9805,9800,0)
local inside=makeSquare(9801,9800,0)
local actor=makeZombie(outside,1)
actor.owner={getOnlineID=function() return 88 end,isDead=function() return false end}
actor.onlineId,actor.outfitId=22000,22000
Actors.observe(actor)
Actors.report(actor,{x=9801.5,y=9800.5,z=0,at=testMillis})
check(Actors.square(actor)==inside and actor:getX()==9805.5,"C528 fresh owner position differs from native replica")
Horde.allowed,Combat.clearLane,Policy.eligible=function() return true end,function() return true end,function() return true end
Proc.available,Proc.reserve=function() return true end,function() end
Clock.now=function() return testMillis end
local hits=0
Damage.resolve=function() hits=hits+1;return true end
local entry={object=object,hits={{},{}},soundAt=math.huge}
state.id="turret-c527"
check(require("OMHTT/TurretAuthority").register(object,state),"C528 server fixture has authoritative turret controls")
local profile={range=2,omni=true,heading=0,cone=360}
local job={at=testMillis,moving=true,before=359,after=361,profile=profile,detection=profile,
    stats={damage=20,critChance=0,initialBlow=0,execute=0}}
Rotary.contact(entry,actor,job)
check(hits==1,"C528 rotary hits using fresh owner position before native coordinates catch up")
actor.square=inside
Rotary.contact(entry,actor,job)
check(hits==1,"C528 native coordinate catch-up cannot duplicate the same crossing")
job.before,job.after=719,721
testMillis=testMillis+251;job.at=testMillis
Rotary.contact(entry,actor,job)
check(hits==1,"C528 expired owner positions cannot create late rotary hits")
Actors.report(actor,{x=9805.5,y=9800.5,z=0,at=testMillis})
Rotary.contact(entry,actor,job)
check(hits==1,"C528 owner already outside reach overrides stale native position inside")
Actors.report(actor,{x=9801.5,y=9800.5,z=0,at=testMillis})
local priorOwner=actor.owner
actor.owner={getOnlineID=function() return 89 end,isDead=function() return false end}
Rotary.contact(entry,actor,job)
check(hits==1,"C528 ownership handoff invalidates old position evidence")
actor.owner=priorOwner
Actors.report(actor,{x=9801.5,y=9800.5,z=0,at=testMillis})
actor.state="onground"
Rotary.contact(entry,actor,job)
check(hits==1,"C528 remote prone targets remain excluded")

local Conditional=require("OMHTT/TurretConditionalHit")
local Motion=require("OMHTT/DefenseMotion")
local motion,hit,release,random=Motion.request,Proc.hit,Proc.release,ZombRand
local pending,released,reactions=nil,0,0
actor.state=nil
Motion.request=function() reactions=reactions+1;return true end
Proc.hit=function() end
Proc.release=function() released=released+1 end
ZombRand=function() return 0 end
job.stats.knockdown=100
Damage.resolve=function(_,_,_,_,callback,observation)
    pending=callback
    check(observation.at==testMillis,"C528 validated timestamp reaches the damage transaction")
    return true
end
Rotary.contact(entry,actor,job)
check(pending~=nil,"C528 living actor without an animation name still receives a rotary hit")
testMillis=testMillis+100
pending(.2)
check(released==1 and reactions==1,"C528 asynchronous reaction callback completes and releases proc reservation with nil animation name")
local impact={impactReady=true,stats={impact=100}}
check(not Conditional.impact(actor,square,impact),"C528 shared impact guard prevents repeated stagger locking")
for _,stance in pairs({"onground","getup","falldown","staggerback","hitwhilestaggered"}) do
    actor.state=stance
    impact.impactReady=true
    check(not Conditional.impact(actor,square,impact),"C528 native owner stance excludes invalid impact reactions")
end
actor.state=nil
testMillis=testMillis+6000
impact.impactReady=true
check(Conditional.impact(actor,square,impact),"C528 impact recovery resumes without requiring an animation-name string")
Motion.request,Proc.hit,Proc.release,ZombRand=motion,hit,release,random
Horde.allowed,Combat.clearLane,Policy.eligible,Damage.resolve=old.allowed,old.lane,old.eligible,old.resolve
Proc.available,Proc.reserve,Clock.now=old.available,old.reserve,old.clock
testMode,testMillis=saved.mode,saved.time
testPackAudit=testPackAudit.."; validated owner crossing accepted without native-coordinate wait"

testMode="client"
R.entries={[object]=visual}
object:getModData().OMHTTTurret=state
for _,omni in pairs({true,false}) do
    visual.profile.omni,visual.profile.cone=omni,90
    visual.aimSample={}
    local previousHeading
    for time=0,5000,10 do
        testMillis=700000+time
        local snapshot=math.floor(time/250)*250
        state.rotaryTravel,state.rotaryMoving,state.aimAt=snapshot*.18,true,testMillis-(time-snapshot)-150
        R.animate(testMillis)
        if previousHeading then
            check(math.abs((visual.visualHeading-previousHeading+540)%360-180)<=2.701,
                "C528 actual renderer bounds turns through cone reversal and full rotations")
        end
        previousHeading=visual.visualHeading
    end
    local last=visual.visualHeading
    for time=10,2000,10 do
        testMillis=705000+time
        R.animate(testMillis)
        check(math.abs((visual.visualHeading-last+540)%360-180)<=2.701,"C528 missing packets never switch to stale interpolation")
        last=visual.visualHeading
    end
    local held=visual.visualHeading
    testMillis=708000;R.animate(testMillis)
    check(math.abs((visual.visualHeading-held+540)%360-180)<.001,"C528 missing packets converge to a finite prediction endpoint")
    state.rotaryMoving=false;state.aimAt=testMillis;state.rotaryTravel=900
    last=visual.visualHeading
    for time=10,2000,10 do
        testMillis=708000+time;R.animate(testMillis)
        check(math.abs((visual.visualHeading-last+540)%360-180)<=2.701,"C528 delayed stop reconciles without a violent turn")
        last=visual.visualHeading
    end
    local stopped=visual.visualHeading
    for time=10,500,10 do
        testMillis=710000+time
        state.rotaryMoving=true;state.aimAt=testMillis;state.rotaryTravel=900+time*.18
        R.animate(testMillis)
        check(math.abs((visual.visualHeading-last+540)%360-180)<=2.701,"C528 restart retains bounded renderer timeline")
        last=visual.visualHeading
    end
    check(math.abs((last-stopped+540)%360-180)>1,"C528 restart resumes visible rotation")
end
testMode,testMillis,R.entries=saved.mode,saved.time,saved.entries
