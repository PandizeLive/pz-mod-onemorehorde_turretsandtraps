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
check(visual.aimSample.target==0,"C527 idle renderer seeds old fallback travel")
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
check(peak>10,"C527 reproduced stopped renderer restarting stale interpolation")
testPackAudit="C527 reproduced actual renderer stop handoff: peak "..tostring(peak).." degrees per10ms at "..tostring(at).."ms after stop; no live rendering claim"
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
check(Actors.square(actor)==inside and actor:getX()==9805.5,"C527 fresh owner position differs from native replica")
Horde.allowed,Combat.clearLane,Policy.eligible=function() return true end,function() return true end,function() return true end
Proc.available,Proc.reserve=function() return true end,function() end
Clock.now=function() return testMillis end
local hits=0
Damage.resolve=function() hits=hits+1;return true end
local entry={object=object,hits={{},{}},soundAt=math.huge}
state.id="turret-c527"
check(require("OMHTT/TurretAuthority").register(object,state),"C527 server fixture has authoritative turret controls")
local profile={range=2,omni=true,heading=0,cone=360}
local job={at=testMillis,moving=true,before=359,after=361,profile=profile,detection=profile,
    stats={damage=20,critChance=0,initialBlow=0,execute=0}}
Rotary.contact(entry,actor,job)
check(hits==0,"C527 rotary ignores fresh contact when old native coordinates are out of range")
actor.square=inside
Rotary.contact(entry,actor,job)
check(hits==1,"C527 identical crossing only hits once native coordinates catch up")
Horde.allowed,Combat.clearLane,Policy.eligible,Damage.resolve=old.allowed,old.lane,old.eligible,old.resolve
Proc.available,Proc.reserve,Clock.now=old.available,old.reserve,old.clock
testMode,testMillis=saved.mode,saved.time
testPackAudit=testPackAudit.."; stale-native position rejection reproduced with fresh owner report"
