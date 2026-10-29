-- Real production Lua and native table serialization; actors and transport are doubles.
local S,C,P=require("OMHTT/DefenseCombatServer"),require("OMHTT/DefenseCombatClient"),require("OMHTT/DefenseCombatProtocol")
local saved={mode=testMode,server=sendServerCommand,client=sendClientCommand,player=getSpecificPlayer,core=OneMoreHordeDefenseIntegration}
OneMoreHordeDefenseIntegration=nil
local a={getOnlineID=function() return 7 end,isDead=function() return false end}
local b={getOnlineID=function() return 8 end,isDead=function() return false end}
local localPlayer=a
getSpecificPlayer=function(i) if i==0 then return localPlayer end end
local outbound,inbound,completed={},{},{}
sendServerCommand=function(player,module,command,message) outbound[#outbound+1]={player=player,command=command,message=nativeRoundTrip(message)} end
sendClientCommand=function(player,module,command,message) inbound[#inbound+1]={player=player,command=command,message=nativeRoundTrip(message)} end
local id=18000
local function actor(identity)
 local z={id=identity,health=1,owner=a,data={}}
 function z:getOnlineID() return self.id end
 function z:getPersistentOutfitID() return self.outfit or self.id end
 function z:getOwnerPlayer() return self.owner end
 function z:getOwner() return self.owner end
 function z:isDead() return self.health<=0 end
 function z:isInvulnerable() return self.invulnerable==true end
 function z:isReanimatedForGrappleOnly() return self.corpseProxy==true end
 function z:isRemoteZombie() return self.remote==true end
 function z:getHealth() return self.health end
 function z:setHealth(h) self.health=h end
 function z:getX() return 10 end
 function z:getY() return 10 end
 function z:getZ() return 0 end
 function z:getSquare() return {} end
 function z:getModData() return self.data end
 function z:Kill() self.health=0;self.kills=(self.kills or 0)+1 end
 function z:die() self.deathDone=true end
 function z:isOnDeathDone() return self.deathDone==true end
 return z
end
local function pair()
 id=id+1;testMillis=testMillis+10;localPlayer=a
 outbound,inbound={},{}
 local server,client=actor(id),actor(id)
 testMode="client";C.created(client);testMode="server";S.created(server)
 return server,client
end
local function done(loss,reason) completed[#completed+1]={loss=loss,reason=reason} end
local function receiveClient(packet)
 packet=packet or table.remove(outbound,1);check(packet~=nil,"server packet exists")
 testMode="client";C.command(P.MODULE,packet.command,packet.message);testMode="server";return packet
end
local function receiveServer(sender)
 local packet=table.remove(inbound,1);check(packet~=nil,"client packet exists")
 S.command(P.MODULE,packet.command,sender or packet.player,packet.message);return packet
end
local server,client=pair()
check(S.request(server,.3,"turret-1","firearm",done),"admitted")
check(not S.request(server,.3,"turret-2","firearm",done),"one in-flight operation per victim")
client.health=.8
local apply=receiveClient()
if testPackets then testPackets[#testPackets+1]=apply.message end
check(math.abs(client.health-.5)<.00001,"relative hit preserves intervening player damage")
local receipt=receiveServer(b)
check(server.health==1,"another player cannot settle the hit")
S.command(P.MODULE,receipt.command,a,receipt.message)
local count=#completed
receiveClient(apply);receiveServer()
check(math.abs(server.health-.5)<.00001 and #completed==count,"duplicate Apply and receipt settle once")

server,client=pair();S.request(server,.3,"wire-1","barbs",done)
client.remote=true;receiveClient();receiveServer()
check(client.health==1 and completed[#completed].reason=="not-owner","remote replica refuses application")

server,client=pair();S.request(server,.3,"wire-1","barbs",done)
local delayed=table.remove(outbound,1)
server.owner=b;client.remote=true;S.tick()
receiveClient();receiveServer() -- Status overtakes Apply: cancellation barrier.
receiveClient(delayed);inbound={}
check(client.health==1,"overtaken Apply cannot damage former owner")
local replacement=actor(client.id);replacement.owner=b
localPlayer=b;testMode="client";C.created(replacement);testMode="server"
receiveClient();receiveServer()
check(math.abs(server.health-.7)<.00001 and math.abs(replacement.health-.7)<.00001,"unapplied handoff applies exactly once")

server,client=pair();S.request(server,.3,"wire-2","barbs",done);receiveClient()
server.owner=b;receiveServer()
replacement=actor(client.id);replacement.owner=b;replacement.health=.6
localPlayer=b;testMode="client";C.created(replacement);testMode="server"
local reconciliation=receiveClient();receiveServer()
check(server.health==.6 and replacement.health==.6,"applied handoff does not subtract again or heal")
count=#completed;receiveClient(reconciliation);receiveServer()
check(#completed==count,"duplicate reconciliation cannot complete twice")

server,client=pair();S.request(server,.3,"lost-ack","firearm",done);receiveClient()
inbound={}
testMode="client";C.created(actor(client.id));testMode="server"
server.owner=b;S.tick();receiveClient();receiveServer()
replacement=actor(client.id);replacement.owner=b
localPlayer=b;testMode="client";C.created(replacement);testMode="server"
receiveClient();receiveServer()
check(math.abs(replacement.health-.7)<.00001 and math.abs(server.health-.7)<.00001,"receipt survives native unload and lost acknowledgement without another subtraction")

server,client=pair();S.request(server,2,"turret-lethal","firearm",done)
receiveClient()
check(client.health==P.EPSILON and not client:isDead(),"client reserves terminal damage")
receiveServer()
check(server.kills==1 and server.deathDone and completed[#completed].loss==1,"server alone finishes native death")

server,client=pair();S.request(server,.3,"wire-corpse","barbs",done)
client.corpseProxy=true;receiveClient();receiveServer()
check(client.health==1 and completed[#completed].reason=="dead","dragged corpse proxy rejects damage")
server.corpseProxy=true
check(not S.request(server,.3,"wire-corpse","barbs",done),"server also rejects corpse proxy")

server,client=pair();S.request(server,.3,"late","firearm",done)
testMillis=testMillis+P.TIMEOUT+1;receiveClient();receiveServer()
check(client.health==1 and server.health==1,"expired packet cannot apply after timeout")

server,client=pair();S.request(server,.3,"recycle","firearm",done)
testMillis=testMillis+1;replacement=actor(client.id)
testMode="client";C.created(replacement);testMode="server"
receiveClient();receiveServer()
check(replacement.health==1 and completed[#completed].reason=="identity","same ID/outfit recycled after dispatch is not hit")

server,client=pair();server.outfit=123;client.outfit=123+32768
S.request(server,.3,"hat","firearm",done);receiveClient();receiveServer()
check(math.abs(server.health-.7)<.00001,"fallen hat bit does not invalidate live identity")

server,client=pair();S.request(server,.3,"disconnect","firearm",done);receiveClient()
server.owner=nil;receiveServer()
check(math.abs(server.health-.7)<.00001,"confirmed result settles if owner disconnects")

server,client=pair();check(not S.request(server,0/0,"bad","firearm",done),"NaN rejected")
server.invulnerable=true;check(not S.request(server,.3,"bad","firearm",done),"invulnerable victim rejected")
server.invulnerable=false
local event={};local owner={};local marks=0
OneMoreHordeDefenseIntegration={API_VERSION=1,authorize=function() return true,owner,event end,
 beginDamage=function() marks=marks+1;return true end,endDamage=function() end}
S.request(server,.3,"horde","firearm",done)
check(marks==1,"server authorizes Horde assistance before damage dispatch")
event={};receiveClient();receiveServer()
check(completed[#completed].reason=="ownership-uncertain","changed Horde event cannot receive old attribution")
OneMoreHordeDefenseIntegration=nil

if __modules["OMHTT/Damage"] then
 local damage=require("OMHTT/Damage")
 server,client=pair();local total=0
 local function add(loss) total=total+loss end
 check(damage.resolve(server,.2,"first","firearm",add) and damage.resolve(server,.3,"second","splitter",add),"concurrent hits admitted")
 check(#outbound==1,"one relative operation in flight")
 receiveClient();receiveServer();damage.tick();receiveClient();receiveServer()
 check(math.abs(total-.5)<.00001 and math.abs(client.health-.5)<.00001,"queued hits preserve both amounts")
 local hit,volley=require("OMHTT/TurretHit"),require("OMHTT/TurretVolley")
 server,client=pair();local reservation={pending=1,rayBudget=0,procJobs=0,procFields=0};local callbacks=0
 hit.resolve(server,.2,"retained","fragment",reservation,function() callbacks=callbacks+1 end);volley.done(reservation)
 check(reservation.pending==1 and callbacks==0,"pending damage retains effect reservation")
 receiveClient();receiveServer()
 check(reservation.pending==0 and callbacks==1,"confirmed hit releases reservation once")
 server,client=pair();local staleReason
 damage.resolve(server,.2,"first","firearm",function() end)
 damage.resolve(server,.1,"wire-stale","barbs",function(_,reason) staleReason=reason end)
 testMillis=testMillis+501;receiveClient();receiveServer();damage.tick()
 check(staleReason=="cancelled" and #outbound==0,"stale queued contact does not burst after another shot settles")
end

local held={}
for i=1,P.MAX_PENDING do
 server,client=pair();held[i]=server
 check(S.request(server,.1,"capacity","firearm",done),"bounded pending admission")
end
local extra=actor(19000)
check(not S.request(extra,.1,"capacity","firearm",done),"pending capacity enforced")
testMillis=testMillis+P.TIMEOUT+1
for i=1,9 do S.tick() end
check(S.request(extra,.1,"capacity","firearm",done),"timeout frees pending capacity")
S.created(extra)
testMode,sendServerCommand,sendClientCommand,getSpecificPlayer,OneMoreHordeDefenseIntegration=saved.mode,saved.server,saved.client,saved.player,saved.core
scenarioResult="FAULT_PATH_PASS duplicate, reordering, handoff, corpse, expiry, recycling, death, consent, capacity"
