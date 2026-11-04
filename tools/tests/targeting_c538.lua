local Actors=require("OMHTT/DefenseActors")
local Policy=require("OMHTT/ControlCombat")
local M=require("OMHTT/TurretModules")
local Auto=require("OMHTT/TurretAutomation")
local R=require("OMHTT/TurretRenderer")
local Proc=require("OMHTT/TurretProc")
local Damage=require("OMHTT/Damage")
local S=require("OMHTT/DefenseCombatServer")
local C=require("OMHTT/DefenseCombatClient")
local E=require("OMHTT/PrototypeEffects")
local Ammo=require("OMHTT/TurretAmmo")
local old={mode=testMode,time=testMillis,settings=SandboxVars.OMHTurretsTraps,entries=R.entries,
    request=S.request,cell=getCell,traits=CharacterTrait,player=getSpecificPlayer,item=instanceItem,
    effects=E.effects,models=E.models,draw=require("OMHTT/ControlModelDraw").draw,core=OneMoreHordeDefenseIntegration}
testMode,testMillis="server",14000000
OneMoreHordeDefenseIntegration=nil
SandboxVars.OMHTurretsTraps={Enabled=true,TurretsEnabled=true,IdleSweepSpeed=30}
for x=16000,16025 do makeSquare(x,16000,0) end
local origin=testSquares["16000:16000:0"]
local actor=makeZombie(testSquares["16012:16000:0"],10)
actor.getWidth=function() return .3 end
actor.onlineId,actor.outfitId,actor.owner=32001,123,{getOnlineID=function() return 7 end}
Actors.observe(actor)
check(not Policy.eligible(nil,actor),"C538 target requires current owner confirmation")
local contents={active={MotionDetection=1,Detection360=1}}
local stats={range=18,minimumRange=6,headKind="Lobber"}
local profile=M.profile({},contents,true,stats)
for _,distance in pairs({5,6,8,12,18,19}) do
    actor.square=testSquares[(16000+distance)..":16000:0"]
    Actors.report(actor,{x=actor:getX(),y=actor:getY(),z=0,at=testMillis})
    local job=Auto.scan(origin,profile)
    while not Auto.advance(job,128,getTimestampMs()+1000) do end
    check((job.best==actor)==(distance>=6 and distance<=18),"C538 actual Lobber acquisition "..distance)
end
testMillis=testMillis+251
check(not Policy.eligible(nil,actor),"C538 expired observation cannot start another shot")
local Volley=require("OMHTT/TurretVolley")
local function childRay()
    return {scanning=true,square=actor.square,objectIndex=0,x=16000.5,y=16000.5,dx=1,dy=0,range=20,
        group={kind="fragment",hits={}}}
end
local ray=childRay()
for i=1,Actors.occupants(ray.square,ray):size() do Volley.step(ray) end
check(ray.best==nil,"C538 child projectile ignores unconfirmed actor")
Actors.report(actor,{x=actor:getX(),y=actor:getY(),z=0,at=testMillis})
ray=childRay()
for i=1,Actors.occupants(ray.square,ray):size() do Volley.step(ray) end
check(ray.best==actor,"C538 child projectile accepts confirmed actor")
check(Policy.eligible(nil,actor),"C538 renewed observation restores acquisition")
S.request=function(_,_,_,_,done) done(0,"missing");return true end
check(Damage.resolve(actor,.1,"turret-c538","direct"),"C538 rejection fixture dispatches")
testMillis=testMillis+2000
check(not Damage.available(actor),"C538 missing actor cannot recover on timer alone")
Actors.report(actor,{x=actor:getX(),y=actor:getY(),z=0,at=testMillis})
check(Damage.available(actor),"C538 confirmed reappearance unlocks failed actor")
S.request=old.request
actor.square=testSquares["16002:16000:0"]
Actors.report(actor,{x=16000.5,y=16000.5,z=0,at=testMillis})
check(Proc.inside(origin,actor,16000.5,16000.5,1),"C538 proc uses owner position inside radius")
actor.square=origin
Actors.report(actor,{x=16002.5,y=16000.5,z=0,at=testMillis})
check(not Proc.inside(origin,actor,16000.5,16000.5,1),"C538 proc rejects owner position outside radius")
local state={schema=1,facing=0,aimDegrees=0,on=true,standby="active",aimScanning=true}
local object={hasModData=function() return true end,getModData=function() return {OMHTTTurret=state} end}
local entry={head={},hasDetector=true,profile={heading=0,cone=90,omni=false,stats={}},lastFrame=testMillis}
R.entries={[object]=entry}
testMode="client"
R.animate(testMillis);R.animate(testMillis+1000)
check(entry.visualHeading~=0 and state.aimDegrees==0,"C538 multiplayer idle sweep is cosmetic")
state.aimScanning=false
R.animate(testMillis+1100);R.animate(testMillis+1600)
check(entry.visualHeading==0,"C538 idle animation yields to authoritative aim")
CharacterTrait={DEXTROUS="Dextrous",ALL_THUMBS="AllThumbs"}
Ammo.overrides["Base.SpearCrafted"]="spear"
for _,case in pairs({{"Base.ScrapMetal",1,25},{"Base.SpearCrafted",2,12.5}}) do
    local item={getFullType=function() return case[1] end,getActualWeight=function() return case[2] end}
    local action={item=item,character={hasTrait=function() return false end,isWearingAwkwardGloves=function() return false end}}
    check(Ammo.fastTransfer(item) and item:getActualWeight()==case[2],"C538 heavy ammo batches without changing weight")
    local transfer=require("OMHTT/TurretTransferAction")
    check(transfer.getDuration(action)==case[3],"C538 native per-item duration "..case[1])
    action.ids={}
    for i=1,20 do action.ids[i]=i end
    check(transfer.getDuration(action)==20*case[3],"C538 counted batch cannot bypass per-item loading time")
    action.character.hasTrait=function(_,trait) return trait==CharacterTrait.DEXTROUS end
    check(transfer.getDuration(action)==10*case[3],"C538 counted batch preserves Dexterous")
end
-- A native-list reconciliation recovers actors whose creation was missed.
check(type(C.reconcile)=="function","C538 client reconciles native actor lifecycle")
C.reset()
local actors={}
for i=1,300 do
    local z=makeZombie(origin,1);z.onlineId,z.outfitId=32100+i,100+i
    actors[i]=z
end
getCell=function() return {getZombieList=function() return {size=function() return #actors end,get=function(_,i) return actors[i+1] end} end} end
C.reconcile()
check(C.find(32400,400)==nil,"C538 registry reconciliation obeys per-tick bound")
testMillis=testMillis+100;C.reconcile();testMillis=testMillis+100;C.reconcile()
check(C.find(32400,400)==actors[300],"C538 registry discovers native actor without create event")
actors[300].onlineId=-1
check(C.find(32400,400)==nil,"C538 registry rejects unloaded recycled identity")
getCell=old.cell
-- Actual native-model draw routing, independent of UI-line presentation.
check(type(E.renderSpears)=="function","C538 native spear uses opaque world rendering")
getSpecificPlayer=function() return {getZ=function() return 0 end} end
local draws=0
instanceItem=function(kind) check(kind=="Base.SpearCrafted","C538 original native spear identity");return {} end
require("OMHTT/ControlModelDraw").draw=function(model,square,x,y,z,rx,ry,rz)
    draws=draws+1;check(x>16000.5 and x<16002.5 and y==16000.5 and rz==0,"C538 spear follows original trajectory")
end
local clock=require("OMHTT/TurretClock")
local oldClock=clock.now;clock.now=function() return testMillis end
for x=16000,16003 do testSquares[x..":16000:0"].isCanSee=function() return true end end
E.effects={{projectile="spear",phase="Launch",fromX=16000.5,fromY=16000.5,x=16002.5,y=16000.5,z=0,
    flight=1000,start=testMillis-500,muzzleHeight=.4,ammoType="Base.SpearCrafted"}}
E.models={};E.renderSpears(0)
check(draws==1,"C538 primary and child spear family renders native model")
E.effects[1].phase="Impact";E.renderSpears(0)
check(draws==1,"C538 spear stops drawing at contact")
clock.now=oldClock
Actors.remove(actor)
for i=1,#actors do Actors.remove(actors[i]) end
C.reset()
Ammo.overrides["Base.SpearCrafted"]=nil
testMode,testMillis,SandboxVars.OMHTurretsTraps=old.mode,old.time,old.settings
R.entries,getCell,CharacterTrait=old.entries,old.cell,old.traits
getSpecificPlayer,instanceItem,E.effects,E.models=old.player,old.item,old.effects,old.models
require("OMHTT/ControlModelDraw").draw=old.draw
OneMoreHordeDefenseIntegration=old.core
