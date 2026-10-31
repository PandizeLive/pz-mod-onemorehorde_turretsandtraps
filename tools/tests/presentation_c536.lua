local View=require("OMHTT/PrototypeEffects")
local Clock=require("OMHTT/TurretClock")
local Active=require("OMHTT/ActiveTime")
local Actors=require("OMHTT/DefenseActors")
local Aim=require("OMHTT/TurretAim")
local V=require("OMHTT/TurretVolley")
local Effects=require("OMHTT/DefenseEffects")
local F=require("OMHTT/Foundation")
local C=require("OMHTT/DefenseCombatClient")
local saved={mode=testMode,time=testMillis,effects=View.effects,clock=Clock.now,paused=Active.paused,
    queue=V.queue,emit=Effects.emit,packets=sendClientCommand,player=getSpecificPlayer}
testMode="client"
Active.paused=function() return false end
Clock.now=function() return testMillis end
-- First arrival under latency is different from retransmission after display.
for _,age in pairs({0,100,249,250,350,750}) do
    for _,count in pairs({1,2,5,6,16}) do
        testMillis=950000+age
        View.effects={}
        local packets={}
        for i=1,count do
            local id="c536-"..age.."-"..count.."-"..i
            local facts={id=id,shot="splitter",packet=id,x=13010,y=13000,z=0,
                fromX=13000,fromY=13000,firearm=true,silent=true,firedAt=950000}
            packets[i]=nativeRoundTrip(facts)
            View.receive(F.MODULE,"Ray",packets[i])
        end
        check(#View.effects==count,"C536 delayed first-arrival Splitters remain visible")
        View.effects={}
        testMillis=testMillis+1000
        for i=1,count do View.receive(F.MODULE,"Ray",packets[i]) end
        check(#View.effects==0,"C536 retransmitted burst cannot restart after empty")
    end
end
-- Native creation occurs before OnlineID assignment, with no OnZombieUpdate.
testMillis=960000
local square=makeSquare(13000,13000,0)
local target=makeZombie(square,1)
target.outfitId=123
C.created(target)
target.onlineId=23001
check(C.find(23001,123)==target,"C536 delayed native ID resolves without an update callback")
target.onlineId=-1
check(C.find(23001,123)==nil,"C536 unloaded ID never resolves stale actor")
target.onlineId=23001
C.created(target)
testMillis=testMillis+100
C.observe(target)
local replies={}
sendClientCommand=function(_,_,command,facts) replies[#replies+1]={command,facts} end
getSpecificPlayer=function(i) if i==0 then return {getOnlineID=function() return 7 end,isDead=function() return false end} end end
local P=require("OMHTT/DefenseCombatProtocol")
C.command(P.MODULE,"Apply",{token="c536-life",receipt="c536-receipt",sequence=1,id=23001,outfit=123,
    owner=7,issuedAt=960000,expiresAt=961000,x=13000.5,y=13000.5,z=0,amount=.2})
check(#replies==1 and replies[1][1]=="Applied" and math.abs(target.health-.8)<.00001,
    "C536 delayed observation preserves actual creation time")
-- Use real validated report handling, not a position-function replacement.
testMode="server"
testMillis=970000
target=makeZombie(makeSquare(13000,13003,0),1)
target.onlineId,target.outfitId=23002,124
target.owner={getOnlineID=function() return 7 end}
makeSquare(13003,13000,0)
Actors.observe(target)
Actors.report(target,{x=13003.5,y=13000.5,z=0,at=testMillis})
local object={getSquare=function() return square end}
check(Aim.angle(object,target)==0,"C536 aim uses validated owner coordinates")
local Modules=require("OMHTT/TurretModules")
local profile={range=10,cone=30,heading=0}
check(Modules.inside(square,target,profile),"C536 firing eligibility shares validated aim")
makeSquare(13001,13000,0); makeSquare(13002,13000,0)
local Combat=require("OMHTT/PrototypeCombat")
local options={target=target,profile=profile,range=10,interval=1000,damage=.2,managed=true,
    resolve=function(_,_,_,_,shot) return {x=shot.aimX,y=shot.aimY} end}
local state={id="c536-primary",kind="potato",ammo=1,shots=0}
local fired,facts=Combat.fire(state,object,nil,options)
check(fired=="Fired" and facts.x==13003.5 and facts.y==13000.5 and state.aimDegrees==0,
    "C536 primary commit snapshots the same validated direction")
local packets={}
Effects.emit=function(command,facts) packets[#packets+1]={command,facts} end
V.queue={}
V.split({id="c536-potato",shots=1},square,target,nil,{damage=.2,stats={splitter=6,splitterDamage=1,range=10,headKind="Potato"}})
check(#packets==6 and #V.queue==6,"C536 physical Splitter preserves all launches")
for i=1,6 do check(V.queue[i].dx>.7,"C536 Potato fan follows validated aim") end
local impact={x=13003.5,y=13000.5,z=0,fromX=13000.5,fromY=13000.5,firearm=true,silent=true,
    id="c536-batch",shot=1,packet="c536-batch"}
V.queue,packets={},{}
V.split({id="c536-batch",shots=1},square,target,nil,{damage=.2,stats={splitter=6,splitterDamage=1,range=10,firearm=true}},impact)
check(#packets==0 and #impact.rays==6,"C536 six firearm sides share the primary packet")
testMode="client"
View.effects={}
testMillis=testMillis+350
View.receive(F.MODULE,"GunShot",nativeRoundTrip(impact))
check(#View.effects==7,"C536 delayed primary and six Splitters arrive together")
View.effects={}
View.receive(F.MODULE,"GunShot",nativeRoundTrip(impact))
check(#View.effects==0,"C536 atomic burst retransmission does not replay children")
for x=13100,13105 do local tile=makeSquare(x,13100,0);tile.isCanSee=function() return true end end
testSquares["13103:13100:0"].blocked=true
local trace=View.visibleTrace({fromX=13100.5,fromY=13100.5,x=13105.5,y=13100.5,z=0},0)
check(trace and trace.x<13103,"C536 commitment trace stops before a wall")
testMode="server"
testMillis=testMillis+251
check(Aim.angle(object,target)==270,"C536 expired report cannot retain obsolete aim")
target.owner=nil
Actors.remove(target)
C.reset()
check(C.find(23001,123)==nil,"C536 disconnect releases indexed and pending actors")
View.effects,Clock.now,Active.paused=saved.effects,saved.clock,saved.paused
V.queue,Effects.emit=saved.queue,saved.emit
sendClientCommand,getSpecificPlayer=saved.packets,saved.player
testMode,testMillis=saved.mode,saved.time
