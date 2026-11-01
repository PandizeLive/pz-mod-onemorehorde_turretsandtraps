local Rotary = require("OMHTT/TurretRotary")
local Actors = require("OMHTT/DefenseActors")
local Damage = require("OMHTT/Damage")
local Proc = require("OMHTT/TurretProc")
local Clock = require("OMHTT/TurretClock")
local Horde = require("OMHTT/DefenseHorde")
local Policy = require("OMHTT/ControlCombat")
local Combat = require("OMHTT/PrototypeCombat")
local saved = {mode=testMode,time=testMillis,resolve=Damage.resolve,hit=Proc.hit,release=Proc.release,
    available=Proc.available,reserve=Proc.reserve,clock=Clock.now,allowed=Horde.allowed,lane=Combat.clearLane,eligible=Policy.eligible}
testMode,testMillis="server",2000000
local origin=makeSquare(20542,20542,0)
local inside=makeSquare(20543,20542,0)
local object=IsoObject.new(origin,"test","test")
origin:AddTileObject(object)
local state={schema=1,id="turret-c542",powered=true,standby="active"}
check(require("OMHTT/TurretAuthority").register(object,state),"C542 authoritative test turret")
local actor=makeZombie(inside,1)
actor.owner={getOnlineID=function() return 88 end,isDead=function() return false end}
actor.onlineId,actor.outfitId=22542,22542
Actors.observe(actor)
Horde.allowed,Combat.clearLane,Policy.eligible=function() return true end,function() return true end,function() return true end
Proc.available,Proc.reserve,Proc.release=function() return true end,function() end,function() end
Clock.now=function() return testMillis end
local applied,requests,pending=0,0,nil
Proc.hit=function() applied=applied+1 end
Damage.resolve=function(_,_,_,_,callback,observation)
    requests=requests+1;pending=callback
    check(observation.at<=testMillis and testMillis-observation.at<=250,"C542 admitted contact retains its current observation time")
    return true
end
local profile={range=2,omni=true,heading=0,cone=360}
local job={at=testMillis,moving=true,before=359,after=361,profile=profile,detection=profile,
    stats={damage=20,critChance=0,initialBlow=0,execute=0,knockdown=0}}
local entry={object=object,hits={{},{}},soundAt=math.huge}
for _,age in pairs({0,75,150,225,250}) do
    local observed=testMillis-age
    entry.hits,entry.contactFrames,entry.pendingHits={{},{}},nil,nil
    entry.timeline={{from=observed-100,at=observed,before=359,after=361}}
    Actors.report(actor,{x=20543.5,y=20542.5,z=0,at=observed})
    job.at=testMillis-300
    local before=requests
    Rotary.contact(entry,actor,job)
    check(requests==before+1,"C542 fresh contact survives a scan spanning multiple100ms ticks")
    Rotary.contact(entry,actor,job)
    check(requests==before+1,"C542 pending damage cannot duplicate a crossing")
    pending(0)
    Rotary.contact(entry,actor,job)
    check(requests==before+2,"C542 rejected contact can retry within original freshness window")
    pending(.2)
    Rotary.contact(entry,actor,job)
    check(requests==before+2,"C542 confirmed contact cannot repeat")
end
check(applied==5,"C542 each admitted crossing rewards its modules once")
entry.hits,entry.contactFrames={{},{}},nil
testMillis=testMillis+251
local before=requests
Rotary.contact(entry,actor,job)
check(requests==before,"C542 expired owner observation is never retried")
actor.state="onground"
Actors.report(actor,{x=20543.5,y=20542.5,z=0,at=testMillis})
Rotary.contact(entry,actor,job)
check(requests==before,"C542 rotary still excludes prone targets")
actor.state=nil
local T=require("OMHTT/Turret")
local World=require("OMHTT/TurretWorld")
local Modules=require("OMHTT/TurretModules")
local Standby=require("OMHTT/TurretStandby")
local Managed=require("OMHTT/ControlCycle")
local preserve={contents=World.contents,valid=World.valid,standby=Standby.step,detects=Modules.detects,managed=Managed.managed}
local head={getCondition=function() return 100 end}
local contents={head=head,active={MotionDetection={},Firing={}}}
local stats={rotary=true,range=3,headKind="CustomRotary",motorSpeed=180,cone=180}
World.contents=function() return contents end
World.valid=function() return true end
Standby.step,Modules.detects=function() return true end,function() return true end
Managed.managed=function() return false end
local scan={object=object,rotaryContents=contents,rotaryStats=stats,rotaryHead=head,rotaryAt=testMillis,
    gameAt=getGameTime():getWorldAgeHours(),travel=0,checkedTravel=0,hits={{},{}}}
Rotary.step(scan,testMillis+100)
check(scan.rotaryJob and scan.rotaryJob.radius==3,"C542 custom rotary range defines the bounded scan footprint")
World.contents,World.valid,Standby.step,Modules.detects,Managed.managed=
    preserve.contents,preserve.valid,preserve.standby,preserve.detects,preserve.managed
for _,cone in pairs({90,180,270}) do
    local bearing=cone/2-1
    profile.omni,profile.cone=false,cone
    local observed=testMillis
    local phase=bearing+cone/2
    entry.hits,entry.contactFrames,entry.pendingHits={{},{}},nil,nil
    entry.timeline={{from=observed-100,at=observed,before=phase-1,after=phase+1}}
    local x=20542.5+math.cos(math.rad(bearing))
    local y=20542.5-math.sin(math.rad(bearing))
    makeSquare(math.floor(x),math.floor(y),0)
    Actors.report(actor,{x=x,y=y,z=0,at=observed})
    before=requests
    Rotary.contact(entry,actor,job)
    check(requests==before+1,"C542 rotary contact follows configured cone rather than fixed45-degree sector")
    pending(.2)
end
Damage.resolve,Proc.hit,Proc.release=saved.resolve,saved.hit,saved.release
Proc.available,Proc.reserve,Clock.now=saved.available,saved.reserve,saved.clock
Horde.allowed,Combat.clearLane,Policy.eligible=saved.allowed,saved.lane,saved.eligible

local S=require("OMHTT/TetherServer")
local Lane=require("OMHTT/TetherLane")
local Mount=require("OMHTT/TetherMount")
local W=require("OMHTT/ControlWorld")
local Audio=require("OMHTT/ControlAudio")
local Active=require("OMHTT/ActiveTime")
local old={mount=Mount.resolve,supported=Mount.supported,publish=S.publish,input=W.input,
    world=W.publish,audio=Audio.emit,eligible=Policy.eligible,paused=Active.paused,time=S.time}
for x=20541,20550 do for y=20541,20544 do
    local tile=makeSquare(x,y,0)
    tile.isSolid=function() return false end
    tile.isSolidTrans=function() return false end
end end
local floor=getCell():getGridSquare(20542,20542,0)
local trap={getObjectIndex=function() return 0 end,getSquare=function() return floor end,
    getHealth=function() return 100 end,setHealth=function() end,sync=function() end}
Mount.resolve=function() return {x=20542.5,y=20542.5,z=0,dx=1,dy=0},trap end
Mount.supported=function() return true end
S.publish,W.publish=function() end,function() end
W.input=function() return false,false,false end
Policy.eligible=function(_,victim) return victim==actor end
local sounds=0
Audio.emit=function() sounds=sounds+1 end
Active.paused=function() return false end
S.time=0
local controls={id="control-542",kind="Tether",x=20542,y=20542,z=0,facing="e",recoverAt=0}
local tether=S.entry(trap,controls)
Actors.remove(actor)
actor.square=getCell():getGridSquare(20543,20542,0)
Actors.observe(actor)
local off={x=20543.5,y=20543.1,z=0,at=testMillis}
S.contact(actor,off)
check(tether.cycle.phase=="idle","C542 off-lane approach does not fire")
Actors.report(actor,{x=20543.5,y=20542.5,z=0,at=testMillis})
S.contact(actor,{x=20543.5,y=20542.5,z=0,at=testMillis})
check(tether.cycle.phase=="out","C542 in-lane report in the same packet is not suppressed by off-lane scan")
check(sounds==1,"C542 batch contact launches once")
local oldFloor=actor.isOnFloor
actor.isOnFloor=function() return true end
actor.state=nil
check(select(2,Lane.cast(tether.cycle,0,3))==actor,"C542 standing owner state overrides stale server floor flag")
actor.state="onground"
check(select(2,Lane.cast(tether.cycle,0,3))==nil,"C542 landed actor does not block the dart lane")
actor.state=nil;actor.isOnFloor=oldFloor
local distance,phase=tether.cycle.distance,tether.cycle.phase
Active.paused=function() return true end
S.time=1;S.step(trap,controls,true);S.contact(actor,{x=20543.5,y=20542.5,z=0})
check(tether.cycle.distance==distance and tether.cycle.phase==phase and sounds==1,"C542 direct Tether signals freeze under a stable pause")
Active.paused=function() return false end
tether.cycle.phase,tether.cycle.resetLeft="reset",3
S.contact(actor,{x=20543.5,y=20542.5,z=0})
check(tether.cycle.phase=="reset" and sounds==1,"C542 contact never bypasses reset")
S.cancel(trap)
Mount.resolve,Mount.supported,S.publish,W.input,W.publish,Audio.emit,Policy.eligible,Active.paused,S.time=
    old.mount,old.supported,old.publish,old.input,old.world,old.audio,old.eligible,old.paused,old.time
Actors.remove(actor)
local Renderer=require("OMHTT/TurretRenderer")
local StateView=require("OMHTT/TurretStateView")
local T=require("OMHTT/Turret")
local Options=require("OMHTT/ControlOptions")
local visualOld={entries=Renderer.entries,hybrid=T.hybrid,player=getSpecificPlayer,draw=StateView.draw,
    options=Options.get,paused=Active.paused,indicator=SandboxVars.OMHTurretsTraps.TurretStateIndicator}
testMode="client"
local visualSquare=makeSquare(21542,21542,0)
visualSquare.isCanSee=function() return false end
visualSquare.isCouldSee=function(self) return not self.occluded end
local visualObject=IsoObject.new(visualSquare,"test","test")
visualSquare:AddTileObject(visualObject)
local controls={schema=1,powered=true,standby="active",aimAt=testMillis,rotaryTravel=0,rotaryMoving=true,rotarySpeed=180}
visualObject:getModData().OMHTTTurret=controls
local visual={head={},profile={stats={rotary=true},heading=0,omni=true,cone=90},visualHeading=0,aimSample={}}
Renderer.entries={[visualObject]=visual}
T.hybrid=function() return true end
getSpecificPlayer=function() return {getX=function() return 21542 end,getY=function() return 21542 end,getZ=function() return 0 end} end
Options.get=function() return true end
SandboxVars.OMHTurretsTraps.TurretStateIndicator=true
local markers=0
StateView.draw=function() markers=markers+1 end
Renderer.render(0)
check(markers==1,"C542 marker renders behind player when geometry remains visible")
visualSquare.occluded=true;Renderer.render(0)
check(markers==1,"C542 marker does not reveal a turret through a wall")
Active.paused=function() return false end
Renderer.animate(testMillis)
testMillis=testMillis+10;Renderer.animate(testMillis)
local stopped=visual.visualHeading
Active.paused=function() return true end
for i=1,100 do testMillis=testMillis+100;Renderer.animate(testMillis) end
check(visual.visualHeading==stopped,"C542 rotary prediction freezes throughout stable multiplayer pause")
Active.paused=function() return false end
Renderer.animate(testMillis)
check(visual.visualHeading==stopped,"C542 resume waits for fresh motor snapshot instead of extrapolating across pause")
controls.aimAt=testMillis;controls.rotaryTravel=20
testMillis=testMillis+10;Renderer.animate(testMillis)
check(math.abs((visual.visualHeading-stopped+540)%360-180)<=2.701,"C542 fresh resume snapshot preserves bounded correction")
Renderer.entries,T.hybrid,getSpecificPlayer,StateView.draw,Options.get,Active.paused=
    visualOld.entries,visualOld.hybrid,visualOld.player,visualOld.draw,visualOld.options,visualOld.paused
SandboxVars.OMHTurretsTraps.TurretStateIndicator=visualOld.indicator
testMode,testMillis=saved.mode,saved.time
testResults[#testResults+1]="C542: fresh rotary contacts across aged scans, pending/rejected/applied outcomes, Tether packet order/stance/reset/stable pause; no connected-client proof"
