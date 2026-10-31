-- Production paths, divergent replicas and controlled transport. No live/rendered claim.
local Actors = require("OMHTT/DefenseActors")
local ContactServer = require("OMHTT/DefenseContactServer")
local Discovery = require("OMHTT/ControlDiscovery")
local Sensor = require("OMHTT/ControlSensor")
local W = require("OMHTT/ControlWorld")
local Cycle = require("OMHTT/TetherCycle")
local View = require("OMHTT/TetherView")
local Aim = require("OMHTT/TurretAimView")
local savedMode,savedTime = testMode,testMillis
testMode,testMillis = "server",21000000
local origin,entered = makeSquare(8503,8500,0),makeSquare(8504,8500,0)
local owner = {getOnlineID=function() return 73 end,isDead=function() return false end,isLocalPlayer=function() return true end}
local zombie = makeZombie(origin,1)
zombie.owner,zombie.onlineId,zombie.outfitId = owner,21900,21900
Actors.observe(zombie)
local report = {id=21900,outfit=21900,sequence=1,x=8504.5,y=8500.5,z=0,
    age=0,observedAt=testMillis,prone=false,down=false,landing=false}
ContactServer.observe(owner,report,testMillis)
check(Actors.square(zombie)==entered,"C517 spatial membership consumes validated owner entry before native replica catches up")
check(zombie:getX()==8503.5,"C517 fresh spatial membership never teleports the native actor")
local occupants = Actors.at(entered)
check(occupants:size()==1 and occupants:get(0)==zombie,"C517 pressure/tether shared occupancy sees the reported tile")
check(Actors.at(origin):size()==0,"C517 stale server tile no longer contains the reported actor")
local object = IsoThumpable.new(getCell(),entered,"omhtt_barrier_01_85",false)
object:setHealth(200);entered:AddSpecialObject(object)
local oldState = W.state
W.state = function(candidate) if candidate==object then return {trigger="Zombies"} end return oldState(candidate) end
check(W.occupied(object),"C517 pressure plate responds to owner entry without another native position packet")
zombie.owner = {getOnlineID=function() return 74 end}
check(Actors.square(zombie)==origin,"C517 owner handoff invalidates fresh spatial overlay immediately")
zombie.owner=owner;report.sequence=2
ContactServer.observe(owner,report,testMillis)
testMillis=testMillis+251
check(Actors.square(zombie)==origin,"C517 missing report expiry returns to native coordinates")
Actors.observe(zombie,true)
local staleOccupants=Actors.at(origin)
check(staleOccupants:size()==1 and staleOccupants:get(0)==zombie,"C517 expiry fixture retains the stale native occupant")
local stalePlate=IsoThumpable.new(getCell(),origin,"omhtt_barrier_01_85",false)
W.state=function(candidate) if candidate==stalePlate then return {trigger="Zombies"} end return oldState(candidate) end
check(not W.occupied(stalePlate),"C517 expired owner report cannot reactivate a plate using stale native occupancy")
W.state=oldState
Actors.remove(zombie)

-- Laser first observation on the beam must work, with native position still one tile behind.
local oldSensor = {entries=Sensor.entries,tiles=Sensor.tiles,positions=Sensor.positions,count=Sensor.count}
local oldBeam = require("OMHTT/ControlBeam").length
local oldUpdate,oldReceiver = W.updateInput,W.receiver
local receiver,signals = {},0
local input = {kind="Laser",powered=true,active=false,links={"c517-target"}}
local beam = {x=8504.5,y=8499,z=0,dx=0,dy=1,length=4}
Sensor.entries,Sensor.tiles,Sensor.positions,Sensor.count = {[object]=beam},{["8504:8500:0"]={[object]=true}},{},1
W.state=function(candidate) if candidate==object then return input end return oldState(candidate) end
W.updateInput=function(candidate,on) if candidate==object then input.active=on end end
W.objects["c517-target"]=receiver
W.receiver=function(candidate) if candidate==receiver then signals=signals+1 end end
require("OMHTT/ControlBeam").length=function(_,length) return length end
Actors.observe(zombie);report.sequence=3;report.observedAt=testMillis
ContactServer.observe(owner,report,testMillis)
Sensor.actor(zombie)
check(signals==1,"C517 first reported laser contact triggers immediately instead of waiting for another movement sample")
zombie.corpseProxy=true
Sensor.actor(zombie)
check(signals==1,"C517 dragged corpse cannot activate laser")
zombie.corpseProxy=false
Sensor.entries,Sensor.tiles,Sensor.positions,Sensor.count=oldSensor.entries,oldSensor.tiles,oldSensor.positions,oldSensor.count
require("OMHTT/ControlBeam").length=oldBeam
W.state,W.updateInput,W.receiver=oldState,oldUpdate,oldReceiver
W.objects["c517-target"]=nil
Actors.remove(zombie)

-- Object arrives before mod data: use existing bounded discovery retry, not a second world scan.
testMode="client"
local Barbs = require("OMHTT/BarbSections")
local oldStore = Barbs.store
Barbs.store = Barbs.store or {wires={},panels={}}
Discovery.add(object)
check(Discovery.pending[object]~=nil,"C517 newly streamed object waits for metadata")
local record={id="c517-wire",kind="wire",paired=false,x=8504,y=8500,z=0,health=50,facing=0}
object:getModData().OMHTTBarbFrame={id=record.id,kind="wire",view=record}
testMillis=testMillis+251
Discovery.tick()
check(Barbs.nodes[record.id]~=nil,"C517 delayed wire metadata is indexed without reloading or touching the trap")
check(Discovery.pending[object]==nil,"C517 indexed passive trap leaves retry queue")
Barbs.index(record,false);Barbs.store=oldStore
object:getModData().OMHTTBarbFrame=nil
for _,kind in ipairs({"Plate","Laser","Tether"}) do
    object:getModData().OMHTTControl={id="c517-"..kind,kind=kind,x=8504,y=8500,z=0,facing="e"}
    Discovery.add(object)
    local ContactClient=require("OMHTT/DefenseContactClient")
    check(ContactClient.checks.controls(zombie),"C517 "..kind.." alone requests fresh owner contact, without a nearby Poke/Wire")
    Discovery.remove(object)
end
object:getModData().OMHTTControl=nil

-- Capture actual renderer draw calls, including moving-victim attachment and retraction.
local Clock = require("OMHTT/ControlClock")
local Draw = require("OMHTT/ControlModelDraw")
local Combat = require("OMHTT/DefenseCombatClient")
local saved={clock=Clock.now,draw=Draw.draw,player=getSpecificPlayer,item=instanceItem,cell=getCell}
local simulated,drawn = 1000,nil
Clock.now=function() return simulated end
getSpecificPlayer=function() return zombie end
local tile={isCanSee=function() return true end}
getCell=function() return {getGridSquare=function() return tile end} end
instanceItem=function(name) return {name=name,setWorldScale=function() end} end
Draw.draw=function(item,_,x,y) if item.name=="Base.OMHTTTrapTetherNailVisual" then drawn={x=x,y=y} end end
Combat.created(zombie)
local cycle=Cycle.new(8503.5,8500.5,0,1,0,{range=6,speed=30,returnSpeed=4,resetTime=3,holdTime=.75})
Cycle.start(cycle,true,false)
local message=Cycle.snapshot(cycle,"control-517",1,"517")
message.sentAt=testMillis
View.receive("OMHTTTether","State",nativeRoundTrip(message))
simulated=1050;View.render(0)
check(drawn and drawn.x>8504.9,"C517 outbound dart continues before a second server snapshot")
simulated=1150;View.render(0)
check(drawn.x>8507.9,"C517 outbound dart does not pause at the old 100ms interpolation boundary")
cycle.phase,cycle.distance="hold",1
message=Cycle.snapshot(cycle,"control-517",2,"517")
message.targetId,message.targetOutfit=21900,21900
message.targetPlayer=false
message.attachX,message.attachY=8504.5,8500.5
View.receive("OMHTTTether","State",nativeRoundTrip(message))
zombie.getX=function() return 8505.1 end
zombie.getY=function() return 8501.2 end
View.render(0)
check(drawn.x==8505.1 and drawn.y==8501.2,"C517 embedded nail follows current victim on both axes")
cycle.phase,cycle.backTime="back",.1
cycle.distance=.6
message=Cycle.snapshot(cycle,"control-517",3,"517")
message.attachX,message.attachY=8505.1,8501.2
View.receive("OMHTTTether","State",nativeRoundTrip(message))
simulated=1200;View.render(0)
check(drawn.x>8503.5 and drawn.x<8505.1 and drawn.y>8500.5 and drawn.y<8501.2,
    "C517 return retracts from victim endpoint rather than snapping to old firing axis")
message.serial=4;message.sentAt=math.huge
check(not Cycle.accept(nil,message),"C517 infinite timestamp rejected")
message.sentAt=testMillis;message.phase="out";message.limit=.2
local x=Cycle.position(message,.25)
check(x<=message.x+.2,"C517 prediction cannot cross server-known first obstruction")
View.states[message.id],View.received[message.id],View.simulated[message.id],View.visuals[message.id]=nil,nil,nil,nil
Clock.now,Draw.draw,getSpecificPlayer,instanceItem,getCell=saved.clock,saved.draw,saved.player,saved.item,saved.cell

local sample={}
local value=Aim.follow(sample,0,90,1000,90)
value=Aim.follow(sample,value,90,1050,90)
check(math.abs(value-4.5)<.00001,"C517 live selected-target turn advances at server speed without a second network interpolation wait")
value=Aim.follow(sample,value,0,1100,90)
check(value==0,"C517 visible target reversal turns smoothly without waiting for heading replication")
value=Aim.follow({},359,1,1000,90)
check(value==359,"C517 first target sample preserves current heading")
check(Aim.rotary(100,100,150,true,nil)==115,"C517 rotary advances through packet interval at confirmed motor speed")
check(Aim.rotary(100,400,150,true,120)==120,"C517 rotary prediction stops at confirmed stroke boundary")
check(Aim.rotary(100,400,150,false,nil)==100,"C517 stopped motor never invents motion")

local Projectile = require("OMHTT/PrototypeEffects")
local TurretClock = require("OMHTT/TurretClock")
local oldClock = TurretClock.now
TurretClock.now=function() return 10000 end
Projectile.receive(require("OMHTT/Foundation").MODULE,"Launch",{id="c517-projectile",shot=1,
    fromX=1,fromY=1,x=3,y=1,z=0,flight=500,sentAt=testMillis-100,silent=true})
check(Projectile.effects[#Projectile.effects].start==9900,"C517 projectile travel accounts for transit instead of restarting full flight on receipt")
TurretClock.now=oldClock

local Renderer = require("OMHTT/TurretRenderer")
local oldEntries=Renderer.entries
local visual={profile={stats={rotary=false}},visualHeading=0}
Renderer.entries={[object]=visual}
object:getModData().OMHTTTurret={schema=1,powered=true,aimDegrees=0,aimTargetId=21900,
    aimTargetOutfit=21900,aimTargetPlayer=false,aimAt=testMillis,aimSpeed=90}
Renderer.animate(testMillis)
testMillis=testMillis+50
Renderer.animate(testMillis)
check(math.abs(visual.visualHeading-355.5)<.00001,"C517 actual renderer follows selected moving target between unchanged server heading packets")
check(object:getModData().OMHTTTurret.aimDegrees==0,"C517 local aim never overwrites server heading")
Renderer.entries=oldEntries
object:getModData().OMHTTTurret=nil

-- Actual tether schedule: contact wakes an idle trap before its old scan is due.
testMode="server"
local Tether = require("OMHTT/TetherServer")
local Lane = require("OMHTT/TetherLane")
local Mount = require("OMHTT/TetherMount")
local CombatPolicy = require("OMHTT/ControlCombat")
local Audio = require("OMHTT/ControlAudio")
local Active = require("OMHTT/ActiveTime")
local old={mount=Mount.resolve,supported=Mount.supported,cast=Lane.cast,publish=Tether.publish,
    input=W.input,publishWorld=W.publish,eligible=CombatPolicy.eligible,audio=Audio.emit,active=Active.step,
    running=Tether.running,cursor=Tether.cursor,time=Tether.time}
Tether.running,Tether.cursor,Tether.time={},1,0
Mount.resolve=function() return {x=8504.5,y=8500.5,z=0,dx=1,dy=0},object end
Mount.supported=function() return true end
Lane.cast=function(_,from,to) if to>=3 then return (3-from)/(to-from),zombie,"zombie" end end
Tether.publish=function() end
W.input=function() return false,false,false end
W.publish=function() end
CombatPolicy.eligible=function() return true end
Audio.emit=function() end
Active.step=function() return 16 end
local state={id="control-518",kind="Tether",x=8504,y=8500,z=0,facing="e",recoverAt=0}
local entry=Tether.entry(object,state)
entry.scan=200
Tether.contact(zombie,{x=8505.5,y=8500.5,z=0})
check(entry.cycle.phase=="out","C517 owner contact launches tether before 200ms poll")
Tether.advance()
check(entry.cycle.distance>.47 and entry.cycle.distance<.49,"C517 active dart advances after 16ms, independently of 100ms device scheduler")
Tether.cancel(object)
check(#Tether.running==0 and Tether.entries[object]==nil,"C517 cancel removes active work and contact index")
local oldStep,seen = Tether.step,{}
Tether.step=function(candidate) seen[candidate]=true end
for i=1,128 do
    local device={getObjectIndex=function() return 0 end,getSquare=function() return entered end}
    Tether.schedule({object=device,state={}},true)
end
Tether.advance()
local reached=0;for _ in pairs(seen) do reached=reached+1 end
check(reached==64,"C517 active-flight scheduler bounds work to 64 entries per slice")
Tether.advance()
reached=0;for _ in pairs(seen) do reached=reached+1 end
check(reached==128,"C517 active-flight scheduler reaches later traps fairly")
for i=#Tether.running,1,-1 do Tether.schedule(Tether.running[i],false) end
Tether.step=oldStep
Mount.resolve,Mount.supported,Lane.cast,Tether.publish=old.mount,old.supported,old.cast,old.publish
W.input,W.publish,CombatPolicy.eligible,Audio.emit,Active.step=old.input,old.publishWorld,old.eligible,old.audio,old.active
Tether.running,Tether.cursor,Tether.time=old.running,old.cursor,old.time

local priorDue,priorReceiver = W.due,W.receiver
local callbacks=0
W.due=testMillis+100
W.objects["c517-dirty"]=object
W.receiver=function(candidate) if candidate==object then callbacks=callbacks+1 end end
W.queueDirty("c517-dirty")
W.tick()
check(callbacks==1,"C517 changed input dispatches before routine scan deadline")
W.objects["c517-dirty"]=nil
W.due,W.receiver=priorDue,priorReceiver

testMode,testMillis=savedMode,savedTime
testResults[#testResults+1]="C517: fresh pressure/laser/tether occupancy, cold metadata retry, first-contact controls, continuous dart draw/attachment/return and local selected-target aiming passed; connected/rendered acceptance pending"
