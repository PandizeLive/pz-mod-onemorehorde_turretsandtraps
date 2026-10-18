local A = require("OMHTT/ControlAccess")
local C = require("OMHTT/ControlDefinitions")
local W = require("OMHTT/TurretWorld")
local T = require("OMHTT/Turret")
local M = require("OMHTT/TurretModules")
local Aim = require("OMHTT/TurretAim")
local Action = require("OMHTT/ControlAction")
local Authority = require("OMHTT/TurretAuthority")
local saved = {mode=testMode,state=A.state,near=A.near,range=A.range,tstate=T.state,valid=W.valid,
    refresh=W.refresh,contents=W.contents,power=W.power,publish=Authority.publish,time=testMillis}
testMode="server"
local square=makeSquare(2100,2100,0)
local player={getUsername=function() return "facing-owner" end,isDead=function() return false end,getAccessLevel=function() return "None" end}
local host={state={id="facing-host",kind="Controller",owner="facing-owner",powered=true,links={}},health=100}
function host:getObjectIndex() return 0 end
function host:getHealth() return self.health end
local turret={state={id="facing-target",kind="Turret",owner="facing-owner",controller="facing-host",links={}},
    record={schema=1,id="facing-turret",baseFacing=4,facing=4,aimDegrees=90,powered=false,shots=0},health=100}
function turret:getHealth() return self.health end
function turret:getSquare() return square end
function turret:getObjectIndex() return 0 end
A.state=function(object) return object and object.state end
A.near=function(p,object) return object==host and not p.away end
A.range=function(first,second) return second==turret and not turret.distant end
T.state=function(object) return object and object.record end
W.valid=function(object) return object==turret end
W.refresh=function(object)
    require("OMHTT/TurretAutomation").changed(object)
end
local head={getCondition=function() return 100 end,getFullType=function() return T.HEAD end}
local contents={head=head,active={}}
W.contents=function() return contents end
W.power=function() return true end
local publishes=0
Authority.publish=function() publishes=publishes+1 end
local function action(angle,sourceId,targetId)
    return Action:new(player,host,"SetFacing",angle,turret,sourceId or host.state.id,targetId or turret.state.id)
end
check(action(143.25):complete(),"Assigned Controller accepts exact world direction")
check(turret.record.facingDegrees==143.25 and turret.record.aimDegrees==90 and turret.record.facingPending,
    "OFF direction is saved without moving the head")
check(turret.record.baseFacing==4 and turret.record.shots==0,"Facing preserves base placement and does not fire")
local payload=Authority.copy(turret.record)
payload=nativeRoundTrip(payload)
check(payload.facingDegrees==143.25 and payload.facingPending,"Direction survives native table serialization")
check(M.profile(turret.record,contents).heading==143.25,"Firing and detection profiles use saved direction")
contents.active.Detection360=1
check(M.profile(turret.record,contents).cone==360,"360 module preserves full coverage")
contents.active.Detection360=nil
for _,value in pairs({-1,360,math.huge,0/0,"90",{}}) do
    check(not action(value):isValid(),"Malformed direction rejected")
end
check(not action(10,"wrong"):isValid() and not action(10,nil,"wrong"):isValid(),"Exact host and target identities validated")
host.state.powered=false
check(not action(10):isValid(),"Offline Controller cannot change facing")
host.state.powered=true
turret.state.controller="different"
check(not action(10):isValid(),"Unassigned turret cannot receive Controller direction")
turret.state.controller=host.state.id
turret.distant=true
check(not action(10):isValid(),"Controller range enforced")
turret.distant=nil
player.away=true
check(not action(10):isValid(),"Operator must remain near Controller")
player.away=nil
turret.state.owner="someone-else"
check(not action(10):isValid(),"Read-only device permission cannot change facing")
turret.state.owner="facing-owner"
local once=action(135)
check(once:complete() and not once:complete(),"Replayed timed action cannot reapply facing")
Aim.face(turret,contents)
Aim.turnFacing(turret,Aim.entries[turret],testMillis+100)
check(not Aim.entries[turret] and turret.record.aimDegrees==90 and turret.record.facingPending,"OFF head never turns")
turret.record.powered=true
Aim.face(turret,contents)
local turn=Aim.entries[turret]
Aim.turnFacing(turret,turn,testMillis+100)
check(turret.record.aimDegrees>90 and turret.record.aimDegrees<135,"Powered turn respects native configured speed")
check(W.fire(nil,turret,nil,true)=="Turning","Signal cannot fire during direction movement")
local clock=testMillis+100
for i=1,100 do
    clock=clock+100
    if Aim.entries[turret] then Aim.turnFacing(turret,Aim.entries[turret],clock) end
end
check(not turret.record.facingPending and turret.record.aimDegrees==135 and turret.record.shots==0,"Bounded turn completes without an implicit shot")
check(turret.record.facing==6 and turret.record.baseFacing==4,"Fallback head sprite follows selected direction without rotating base identity")
check(publishes>=3,"Authoritative selection and completion publish state")
local plate=IsoThumpable.new(getCell(),square,"test-plate",false)
plate:setIsThumpable(true)
C.passive(plate,"Plate")
check(not plate:isThumpable() and plate:isCanPassThrough() and not plate:isBlockAllTheSquare(),"Passive plate flags prevent blocking and thumping")
plate:setIsThumpable(true)
C.passive(plate,"Controller")
check(plate:isThumpable(),"Controller retains ordinary thump behavior")
local U=require("OMHTT/ControlClient")
testMode="client"
plate.state={kind="Plate",links={}}
U.passive(plate)
check(not plate:isThumpable(),"Client-loaded existing plate receives the same native flags")
testMode="server"
local source={links={"facing-target"}}
check(C.linked(source,turret.state) and not C.linked(source,{id="other"}),"Link action follows actual selected receiver membership")
check(not C.linked(nil,turret.state),"No source is never a link")
A.state,A.near,A.range,T.state=saved.state,saved.near,saved.range,saved.tstate
W.valid,W.refresh,W.contents,W.power,Authority.publish=saved.valid,saved.refresh,saved.contents,saved.power,saved.publish
Aim.entries[turret],Aim.queued[turret]=nil,nil
for i=#Aim.order,1,-1 do if Aim.order[i]==turret then table.remove(Aim.order,i) end end
local auto=require("OMHTT/TurretAutomation")
auto.entries[turret]=nil
for i=#auto.order,1,-1 do if auto.order[i].object==turret then table.remove(auto.order,i) end end
testMode,testMillis=saved.mode,saved.time
