-- Divergent native-owner/server positions replayed through production reports/router/runtimes.
local S,C=require("OMHTT/DefenseContactServer"),require("OMHTT/DefenseContactClient")
local A,R=require("OMHTT/DefenseActors"),require("OMHTT/DefenseContacts")
local D=require("OMHTT/Damage")
local saved={time=testMillis,settings=SandboxVars.OMHTurretsTraps,handlers=R.handlers,tiles=R.tiles,sources=R.sources,count=R.count,
 checks=C.checks,resolve=D.resolve,send=sendClientCommand,serverSend=sendServerCommand}
testMode="server";testMillis=8000000
SandboxVars.OMHTurretsTraps={Enabled=true,TurretsEnabled=true}
R.handlers,R.tiles,R.sources,R.count={},{},{},0
local owner={getOnlineID=function() return 91 end,isDead=function() return false end,isLocalPlayer=function() return true end}
local square=makeSquare(8100,8100,0);makeSquare(8101,8100,0);makeSquare(8099,8100,0)
local zombie=makeZombie(square,1);zombie.owner=owner;zombie.onlineId=8100;zombie.outfitId=81
A.observe(zombie)
local packets={}
local grants, grantPackets, maxGrantBatch = {}, 0, 0
sendServerCommand=function(player,module,command,frames)
 if module=="OMHTT_ContactV1" then
  check(command=="Permits" and #frames<=32,"C515 consent responses are bounded batches")
  grantPackets=grantPackets+1;maxGrantBatch=math.max(maxGrantBatch,#frames)
  for i=1,#frames do grants[#grants+1]=nativeRoundTrip(frames[i]) end
 else saved.serverSend(player,module,command,frames) end
end
sendClientCommand=function(p,module,command,frames) packets[#packets+1]={p,module,command,nativeRoundTrip(frames)} end
C.checks={test=function() return true end}
local calls=0
R.handlers.poke=function() calls=calls+1 end
R.watch("probe","poke",8100,8100,8100,8100,0)
local function emit()
 testMode="client";C.update(zombie);C.flush();testMode="server"
 local packet=table.remove(packets,1)
 if packet then S.command(packet[2],packet[3],packet[1],packet[4]) end
 return packet
end
local packet=emit()
testPackets[#testPackets+1]=packet[4]
check(calls==1,"owner first contact immediately reaches server handler")
check(#grants==1 and grants[1].allowed and grants[1].expires-grants[1].issuedAt==400,
 "C515 accepted approach receives bounded server consent")
local Horde=require("OMHTT/DefenseHorde")
local allowed=Horde.allowed
Horde.allowed=function() return false end
S.command(packet[2],packet[3],owner,packet[4])
check(calls==1 and #grants==2 and grants[2].allowed==false,"C515 Horde denial revokes consent without damage")
S.command(packet[2],packet[3],owner,packet[4])
check(#grants==2,"C515 repeated denial does not spam revocations")
Horde.allowed=allowed
S.command(packet[2],packet[3],owner,packet[4]);check(calls==1,"duplicate owner frame is ignored")
for i=1,20 do emit() end
check(calls==1,"unchanged native frames do not flood reports")
testMillis=testMillis+100;emit();check(calls==2,"occupied contact reports at bounded cadence")
local frame=nativeRoundTrip(packet[4][1]);frame.sequence=frame.sequence+1000;frame.observedAt=testMillis
S.command("OMHTT_ContactV1","Observe",{isDead=function() return false end},{frame})
check(calls==2,"foreign owner cannot report contact")
frame.observedAt=testMillis-501;S.command("OMHTT_ContactV1","Observe",owner,{frame})
check(calls==2,"late contact report rejected using synchronized clock")
frame.observedAt=testMillis;frame.x=8200;S.command("OMHTT_ContactV1","Observe",owner,{frame})
check(calls==2,"remote invented contact rejected")
frame.x=8100.5;frame.z=1;S.command("OMHTT_ContactV1","Observe",owner,{frame})
check(calls==2,"another floor cannot report a contact")
frame.z=0;frame.outfit=82;S.command("OMHTT_ContactV1","Observe",owner,{frame})
check(calls==2,"recycled outfit cannot report a contact")
frame.outfit=81
testMillis=testMillis+1;S.created(zombie)
S.command("OMHTT_ContactV1","Observe",owner,{frame})
check(calls==2,"old report cannot activate a recycled native instance")
frame.observedAt=testMillis
frame.x=8100.5;zombie.corpseProxy=true
S.command("OMHTT_ContactV1","Observe",owner,{frame});testMillis=testMillis+100;emit()
check(calls==2 and #packets==0,"corpse dragging blocked on both sides")
zombie.corpseProxy=false

local P,W,Audio=require("OMHTT/ControlPoke"),require("OMHTT/ControlWorld"),require("OMHTT/ControlAudio")
local ps={visual=P.visual,state=W.state,publish=W.publish,audio=Audio.emit,time=P.time}
local object={getSquare=function() return square end,getHealth=function() return 200 end,getObjectIndex=function() return 0 end}
local state={id="c508-poke",kind="Poke",x=8100,y=8100,z=0}
P.visual=function(_,s,raised) s.active=raised end;W.state=function(o) return o==object and state end;W.publish=function() end;Audio.emit=function() end
local hits=0
D.resolve=function() hits=hits+1;return true end
R.handlers.poke=P.contact;P.register(object,state);P.time=0
P.step(object,state)
check(hits==0,"stale server occupancy cannot trigger client-owned Poke")
testMillis=testMillis+100;emit()
check(hits==1 and state.active,"validated owner entry strikes in first cycle")
local oldAt,scans=A.at,0
A.at=function(value) scans=scans+1;return oldAt(value) end
testMillis=testMillis+100;emit();check(hits==1,"same strike never hits same actor twice")
check(scans==0,"reported Poke contact does not rescan its crowded tile")
A.at=oldAt
zombie.getX=function() return 8101.5 end;testMillis=testMillis+100;emit()
zombie.getX=function() return 8100.5 end -- Server replica remains behind after owner has left.
P.time=1600;P.step(object,state);A.observe(zombie)
check(hits==1,"server's stale in-tile replica cannot repeat after owner exit")
P.entries[object],P.objects["8100:8100:0"]=nil,nil;R.remove(object);R.remove("probe")
P.visual,W.state,W.publish,Audio.emit,P.time=ps.visual,ps.state,ps.publish,ps.audio,ps.time

local B=require("OMHTT/BedSpikes")
local bs={count=B.count,store=B.store,tiles=B.tiles,nearby=B.nearby,parts=B.parts,time=B.time}
local record={id="c508-bed",tier="normal",health=50,x=8100,y=8100,z=0}
B.count,B.store,B.tiles,B.nearby=1,{records={[record.id]=record}},{["8100:8100:0"]=record.id},{["8100:8100:0"]=true}
B.parts=function() return {{}} end
R.handlers.bed=B.zombie;R.watch(record,"bed",8100,8100,8100,8100,0)
hits=0;testMillis=testMillis+100;emit()
zombie.state="bumped";zombie.bump="OMHTTBedTrip";zombie.variables.OMHTTBedLanded=true
testMillis=testMillis+1;emit()
check(hits==1,"owner landing marker damages despite server state still bumped and floor false")
testMillis=testMillis+100;emit();check(hits==1,"landed actor is not repeatedly damaged")
zombie.corpseProxy=true;testMillis=testMillis+100;emit();check(hits==1,"carried corpse cannot produce another landing")
zombie.corpseProxy=false;zombie.bump="";zombie.variables.OMHTTBedLanded=false
R.remove(record);B.count,B.store,B.tiles,B.nearby,B.parts,B.time=bs.count,bs.store,bs.tiles,bs.nearby,bs.parts,bs.time

local B=require("OMHTT/BarbSections")
local bs={order=B.order,nearby=B.nearby,nodes=B.nodes,resolve=B.resolve,time=B.time}
local record={id="c508-wire",kind="wire",x=8100,y=8100,z=0,paired=false}
B.order={record.id};B.nodes={[record.id]={record=record}};B.nearby={["8100:8100:0"]={[record.id]=true}}
B.resolve=function() return {},{},{health=50},"active" end
local M=require("OMHTT/DefenseMotion");local oldMotion=M.request;M.request=function() return true end
R.handlers.barb=B.zombie;R.watch(record,"barb",8100,8100,8100,8100,0)
hits=0;B.time=0;testMillis=testMillis+100;emit()
check(hits==1,"owner wire entry reaches real geometry and damage runtime immediately")
zombie.getX=function() return 8101.5 end;testMillis=testMillis+100;emit()
zombie.getX=function() return 8100.5 end;B.time=3000;A.observe(zombie)
check(hits==1,"wire does not repeat from stale server coordinates after owner exit")
R.remove(record);B.order,B.nearby,B.nodes,B.resolve,B.time=bs.order,bs.nearby,bs.nodes,bs.resolve,bs.time;M.request=oldMotion

local crowd,seen={},{}
local reports,maxBatch,accepted=0,0,0
R.handlers.poke=function(actor) seen[actor]=true;accepted=accepted+1 end
R.watch("crowd","poke",8100,8100,8100,8100,0)
for i=1,1000 do
 local actor=makeZombie(square,1);actor.owner=owner;actor.onlineId=20000+i;actor.outfitId=20000+i
 A.observe(actor);crowd[i]=actor
end
testMillis=testMillis+1001
local started=realMillis()
for frame=1,60 do
 testMillis=testMillis+17;testMode="client"
 for i=1,#crowd do C.update(crowd[i]) end
 C.flush();testMode="server"
 for i=1,#packets do
  local packet=packets[i];reports=reports+#packet[4];maxBatch=math.max(maxBatch,#packet[4])
  if frame==1 and i==1 then testPackets[#testPackets+1]=packet[4] end
  S.command(packet[2],packet[3],owner,packet[4])
 end
 packets={}
end
local reached=0
for _ in pairs(seen) do reached=reached+1 end
check(reached==1000 and maxBatch<=32 and accepted==reports,"bounded crowd reports reach every contact without rate starvation")
check(maxGrantBatch==32 and grantPackets<reports/2,"C515 crowded consent uses batches instead of one packet per actor")
testContactStress="actors=1000 ticks=60 reached="..reached.." reports="..reports.." accepted="..accepted.." maxPacket="..maxBatch.." replayMs="..(realMillis()-started)
R.remove("crowd")

R.handlers,R.tiles,R.sources,R.count=saved.handlers,saved.tiles,saved.sources,saved.count
C.checks,D.resolve,sendClientCommand=saved.checks,saved.resolve,saved.send
sendServerCommand=saved.serverSend
SandboxVars.OMHTurretsTraps=saved.settings;testMillis=saved.time;testMode=contactSavedMode
testContactPath="Owner entry/exit, wire/Poke stale replica, Bed landing, corpse, duplicate and forged reports passed (test doubles)."
