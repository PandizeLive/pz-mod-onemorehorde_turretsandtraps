local A = require("OMHTT/ControlAccess")
local W = require("OMHTT/ControlWorld")
local Q = require("OMHTT/ControlAutoAssign")
local Panel = require("OMHTT/ControlPanel")
local Clock = require("OMHTT/ControlClock")
local Motion = require("OMHTT/DefenseDisplacement")
local saved = {state=A.state,range=A.range,objects=W.objects,order=W.order,assign=W.assign,mode=testMode,now=Clock.now}
testMode="sp"
A.state=function(object) return object and object.state end
A.range=function(host,object) return math.abs(host.state.x-object.state.x)<=10 end
W.objects,W.order={},{}
local player={getUsername=function() return "owner471" end,isDead=function() return false end}
local function device(id,kind,x,owner)
    local object={state={id=id,kind=kind,x=x,y=0,owner=owner or "owner471",placed=true},
        getHealth=function() return 100 end,getObjectIndex=function() return 0 end}
    W.objects[id]=object;W.order[#W.order+1]=id
    return object
end
local far=device("far","Controller",6)
local near=device("near","Controller",2)
local foreign=device("foreign","Controller",0,"outsider")
foreign.state.policy="public"
local turret=device("turret","Turret",0)
local already=device("already","Laser",0);already.state.controller="far"
local foreignDevice=device("foreign-device","Turret",0,"outsider")
local calls=0
W.assign=function(host,object,who,enabled)
    calls=calls+1
    check(who==player and enabled and A.visible(host,object),"Autoassignment respects host ownership")
    if host.full then return false end
    object.state.controller=host.state.id
    return true
end
local function drain()
    for i=1,2000 do Q.tick();if Q.first>Q.last then return end end
    error("Placement assignment queue failed to finish")
end
Q.reset();Q.add(turret,player)
check(turret.state.controller==nil,"Placement discovery defers to bounded ticks")
drain()
check(turret.state.controller=="near","New turret selects nearest own Controller, ignoring foreign public Controller")
turret.state.controller=nil;near.full=true
Q.add(turret,player);drain()
check(turret.state.controller=="far","A full nearer Controller allows the next eligible Controller")
near.full=nil;turret.state.controller=nil
Q.add(near,player);drain()
check(turret.state.controller=="near" and already.state.controller=="far" and foreignDevice.state.controller==nil,
    "New Controller adopts own unassigned devices without stealing or foreign discovery")
local many={}
for i=1,120 do many[i]=device("many"..i,"Button",1) end
Q.add(near,player);Q.tick()
check(Q.first<=Q.last,"A placement sweep cannot scan 120 devices in one tick")
drain()
check(many[120].state.controller=="near","Bounded queue eventually assigns the final candidate")
local panel={object=near,selected=turret,checking={[foreignDevice]=true},scanSelection={},
    devices={items={{item=near},{item=turret},{item=foreignDevice}},selected=2}}
Panel.prunePrivateEntries(panel)
check(#panel.devices.items==2 and panel.devices.count==2 and panel.scanSelection[foreignDevice]==nil,
    "Cached foreign rows cannot leak names or counts")
turret.state.owner="outsider"
Panel.prunePrivateEntries(panel)
check(panel.devices.count==1 and panel.devices.selected==0,"Ownership changes evict stale rows")
Q.reset();W.objects,W.order,W.assign=saved.objects,saved.order,saved.assign
A.state,A.range=saved.state,saved.range

local now=1000
Clock.now=function() return now end
local square=makeSquare(14710,14710,0)
function square:isSolid() return false end
function square:isSolidTrans() return false end
local nextSquare=makeSquare(14711,14710,0)
function nextSquare:isSolid() return false end
function nextSquare:isSolidTrans() return false end
local actor=makeZombie(square,1)
actor.x,actor.y=14710.5,14710.5
function actor:getX() return self.x end
function actor:getY() return self.y end
function actor:setNextX(x) self.nx=x end
function actor:setNextY(y) self.ny=y end
function actor:isClimbing() return false end
function actor:isCrawling() return false end
Motion.start(actor,false,14708,14710.5,.35);now=1050;Motion.update(actor)
check(actor.nx>actor.x and actor.ny==actor.y and actor.x==14710.5,
    "Tether pushes away along its lane using pending native movement")
Motion.start(actor,true,14708,14710.5,.75);now=1100;Motion.update(actor)
check(actor.nx<actor.x and actor.ny==actor.y,"Tether pulls toward the same muzzle")
actor.x=14710.99;actor.nx=nil;nextSquare.blocked=true
Motion.start(actor,false,14708,14710.5,.35);now=1150;Motion.update(actor)
check(actor.nx==nil,"Tether refuses a blocked tile crossing")
nextSquare.blocked=false;actor.x=14710.5;actor.nx=nil
Motion.start(actor,false,14708,14710.5,.35);now=2000;Motion.update(actor)
check(actor.nx==nil,"Expired game-time motion does not teleport after fast-forward")
actor.owner={};testMode="server"
Motion.start(actor,false,14708,14710.5,.35);now=2050;Motion.update(actor)
check(actor.nx==nil,"Server cannot displace a client-owned actor")
testMode="client";actor.remote=true
Motion.start(actor,false,14708,14710.5,.35);now=2100;Motion.update(actor)
check(actor.nx==nil,"Observer clients cannot displace remotely simulated actors")
Motion.clear(actor);Clock.now=saved.now;testMode=saved.mode
print("[C471] queue ownership/privacy and tether direction/collision/clock/authority passed")

local Manage = {transfer = testC471ManageTransfer}
local Expansion = require("OMHTT/TurretExpansionAction")
local oldNew,oldQueue=Expansion.new,ISTimedActionQueue.add
local incoming,queued
Expansion.new=function(_,player,object,item,replaced,id,controller,final)
    incoming=item
    return {rejection=function() return nil end,projection=function() return {},0 end}
end
ISTimedActionQueue.add=function(action) queued=(queued or 0)+1 end
local large={getFullType=function() return "Base.OMHTTModuleCapacityLarge" end}
local other={getFullType=function() return "Base.OMHTTModuleCapacitySmall" end}
local menu={feedback=function(self,count,reason) self.reason=reason end}
Manage.transfer(menu,{large,large},true,"capacity",{})
check(incoming==large and queued==1,"A homogeneous dragged kit stack schedules one exact atomic replacement")
Manage.transfer(menu,{large,other},true,"capacity",{})
check(menu.reason=="SwapSelection" and queued==1,"Mixed replacement selection cannot choose an arbitrary kit")
Expansion.new,ISTimedActionQueue.add=oldNew,oldQueue

local Health = require("OMHTT/TargetHealth")
local oldMode=testMode;testMode="sp"
local healed=makeZombie(square,1)
healed.health=3.7
check(Health.maximum(healed)==3.7,"Native reload or healing above known maximum expands the established baseline")
healed.health=.5
check(Health.maximum(healed)==3.7,"Subsequent damage cannot reduce that baseline")
testMode=oldMode
