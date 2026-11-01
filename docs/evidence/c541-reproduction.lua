local T=require("OMHTT/Turret")
local savedMode,savedTime=testMode,testMillis
local square=makeSquare(19800,19800,0)
local object=IsoObject.new(square,"test","test")
square:AddTileObject(object)
local state={schema=1,powered=true,standby="active"}
object:getModData().OMHTTTurret=state
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
local outside=makeSquare(19805,19800,0)
local inside=makeSquare(19801,19800,0)
local actor=makeZombie(outside,1)
actor.owner={getOnlineID=function() return 88 end,isDead=function() return false end}
actor.onlineId,actor.outfitId=22541,22541
Actors.observe(actor)
Actors.report(actor,{x=19801.5,y=19800.5,z=0,at=testMillis})
check(Actors.square(actor)==inside and actor:getX()==19805.5,"C528 fresh owner position differs from native replica")
Horde.allowed,Combat.clearLane,Policy.eligible=function() return true end,function() return true end,function() return true end
Proc.available,Proc.reserve=function() return true end,function() end
Clock.now=function() return testMillis end
local hits=0
Damage.resolve=function() hits=hits+1;return true end
local entry={object=object,hits={{},{}},soundAt=math.huge}
state.id="turret-c541"
check(require("OMHTT/TurretAuthority").register(object,state),"C528 server fixture has authoritative turret controls")
local profile={range=2,omni=true,heading=0,cone=360}
local job={at=testMillis,moving=true,before=359,after=361,profile=profile,detection=profile,
    stats={damage=20,critChance=0,initialBlow=0,execute=0}}

entry.timeline={{from=testMillis-100,at=testMillis,before=359,after=361}}
job.at=testMillis-200
Rotary.contact(entry,actor,job)
check(hits==0 and entry.contactFrames==nil,"C541 old scan discards fresh owner contact before examining timestamp")
job.at=testMillis
Rotary.contact(entry,actor,job)
check(hits==1,"C541 same fresh contact hits when only scan creation time changes")
entry.hits={{},{}}
entry.contactFrames=nil
local rejected=0
Damage.resolve=function(_,_,_,_,callback)
    rejected=rejected+1
    callback(0)
    return false
end
Rotary.contact(entry,actor,job)
check(rejected==1,"C541 damage admission rejects first valid crossing")
Damage.resolve=function() hits=hits+1;return true end
Rotary.contact(entry,actor,job)
check(hits==1,"C541 rejected damage still consumes owner observation and arm pass")
entry.contactFrames=nil
Rotary.contact(entry,actor,job)
check(hits==1,"C541 clearing observation alone cannot recover consumed failed pass")
entry.hits={{},{}}
entry.contactFrames=nil
Rotary.contact(entry,actor,job)
check(hits==2,"C541 identical contact admitted after both consumed markers cleared")
Horde.allowed,Combat.clearLane,Policy.eligible,Damage.resolve=old.allowed,old.lane,old.eligible,old.resolve
Proc.available,Proc.reserve,Clock.now=old.available,old.reserve,old.clock
testMode,testMillis=savedMode,savedTime
do
    local V=require("OMHTT/TurretStateView")
    local Options=require("OMHTT/ControlOptions")
    local keep={time=getTimestampMs,cell=getCell,light=IsoLightSource,item=instanceItem,render=Render3DItem,options=Options.get}
    local now,removed=1000,0
    local cell={addLamppost=function() end,removeLamppost=function() removed=removed+1 end}
    getTimestampMs=function() return now end
    getCell=function() return cell end
    IsoLightSource={new=function()
        return {setR=function() end,setG=function() end,setB=function() end,setActive=function() end}
    end}
    instanceItem=function() return {setWorldAlpha=function() end} end
    Render3DItem=function() end
    Options.get=function() return true end
    local oldIndicator=SandboxVars.OMHTurretsTraps.TurretStateIndicator
    SandboxVars.OMHTurretsTraps.TurretStateIndicator=true
    V.clear()
    local baseline=removed
    V.draw(object,{},square,"Green",false,true)
    check(V.lights[object]~=nil,"C541 powered visible marker creates world light")
    now=1201
    V.tick()
    check(V.lights[object]==nil and removed==baseline+1,"C541 skipping facing-gated draw removes still-loaded powered light after201ms")
    getTimestampMs,getCell,IsoLightSource,instanceItem,Render3DItem,Options.get=keep.time,keep.cell,keep.light,keep.item,keep.render,keep.options
    SandboxVars.OMHTurretsTraps.TurretStateIndicator=oldIndicator
end
testPackAudit="C541 investigation: eight failure assertions plus two fixture checks. Old scan drops fresh owner sample; failed admission consumes crossing; skipped draw expires loaded light. Not fixes or connected-client proof."


