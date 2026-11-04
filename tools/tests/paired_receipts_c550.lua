local P = require("OMHTT/DefenseCombatProtocol")
local Server = require("OMHTT/DefenseCombatServer")
local Client = require("OMHTT/DefenseCombatClient")
local Damage = require("OMHTT/Damage")
local Actors = require("OMHTT/DefenseActors")
local Barrier = require("OMHTT/BarrierRetaliation")
local beforeChecks = testAssertions
check(P.ordered ~= nil, "C550 requires the candidate overlay")
testMode, testMillis = "server", 99800000
local function owner(id)
    return {getOnlineID=function() return id end, isDead=function() return false end}
end
local a,b = owner(75),owner(76)
local activeOwner = a
getSpecificPlayer = function(i) if i==0 then return activeOwner end end
local outbound,inbound = {},{}
sendServerCommand = function(player,module,cmd,data)
    if module==P.MODULE then
        outbound[#outbound+1]={at=testMillis,player=player,cmd=cmd,data=networkRoundTrip(data)}
    end
end
sendClientCommand = function(player,module,cmd,data)
    if module==P.MODULE then inbound[#inbound+1]={player=player,cmd=cmd,data=networkRoundTrip(data)} end
end
local sq = makeSquare(45222,45111,0)
local id,results,xp = 20500,{},{}
local client,server
local function zombie(h)
    local z=makeZombie(sq,h)
    z.onlineId,z.outfitId,z.owner=id,id,activeOwner
    function z:Kill() self.kills=self.kills+1;self.health=0 end
    function z:die() self.deathDone=true end
    function z:isOnDeathDone() return self.deathDone==true end
    return z
end
local horde=require("C474Horde")
local enabled={defensesEnabled=true,difficultySelectionConfirmed=true}
local event, lethalMarks, view, notices
__modules.OMH_RunFlags={DEFENSE_USED="defense-used"}
__modules.OMH_DifficultyRuntime={applyIntegrityFlag=function() end,
    getEventClassificationSnapshot=function() return {integrityFlags={["defense-used"]=true}} end}
OneMoreHordePhase3HordeEngine={defenseContext=function() return "active",enabled,event end}
OneMoreHordeDefenseIntegration=horde
local begin=horde.beginDamage
horde.beginDamage=function(z,source,kind,lethal)
    if lethal then lethalMarks[#lethalMarks+1]=source end
    return begin(z,source,kind,lethal)
end
OMHTS_DefenseCredit={API_VERSION=1,zombieFinisher=function(z,ownerId,hordeEvent,source)
    xp[#xp+1]={z=z,event=hordeEvent,source=source}
end}
require("OMHTT/DamagePresentation").present=function(f)
    view[#view+1]={at=testMillis,source=f.source,token=f.token,lost=f.lost}
end
require("OMHTT/DamageNotice").send=function(f)
    if f then notices[#notices+1]={source=f.source,token=f.token,lost=f.lost} end
end
local function fresh()
    testMillis=testMillis+1000
    results,xp,outbound,inbound,lethalMarks,view,notices={},{},{},{},{},{},{}
    id=id+1; activeOwner=a; event={}; enabled.defensesEnabled=true
    server,client=zombie(1),zombie(1)
    testMode="client";Client.created(client);testMode="server";Server.created(server)
end
local function deliver(packet)
    packet=packet or table.remove(outbound,1)
    check(packet~=nil,"server message exists")
    testMode="client";Client.command(P.MODULE,packet.cmd,packet.data);testMode="server"
    return packet
end
local function ack()
    local p=table.remove(inbound,1)
    check(p~=nil,"client reply exists")
    Server.command(P.MODULE,p.cmd,p.player,p.data)
    return p
end
local function submit(label,amount,kind,obs)
    check(Damage.resolve(server,amount,label,kind,function(loss,reason)
        results[#results+1]={source=label,loss=loss,reason=reason}
    end,obs),"admission "..label)
end
local function group(first,second,old)
    fresh()
    submit("lead",.1,"firearm")
    submit("first",first,old==1 and "rotary" or "firearm",old==1 and {at=testMillis-350} or nil)
    submit("second",second,old==2 and "rotary" or "barbs",old==2 and {at=testMillis-350} or nil)
    check(#outbound==1 and outbound[1].cmd=="Apply","idle hit departs immediately")
    deliver();ack();Damage.tick()
    check(#outbound==1 and outbound[1].cmd=="ApplyPair","two waiting hits share one message")
    return outbound[1]
end
local function expect(i,loss,reason)
    check(math.abs(results[i].loss-loss)<.00001 and results[i].reason==reason,"callback "..i.." "..reason)
end
local function replacement(h)
    activeOwner=b;local m=zombie(h)
    testMode="client";Client.created(m);testMode="server"
    return m
end

-- C555 replay uses the same transport, health, presentation and Horde fixtures.
if receiptDispatchCandidate ~= nil then
    local trace = {}
    local function replay(label, age, previousAge, receiptAt, tickAt, lastLeg)
        fresh()
        Damage.tick()
        submit("prior-martyrdom", .1, "martyrdom")
        local base = testMillis + previousAge
        testMillis = base
        submit("turret-rotary", .2, "rotary", {at=base-age})
        testMillis = base + receiptAt - 40
        deliver()
        testMillis = base + receiptAt
        local previous = ack()
        Server.command(P.MODULE, previous.cmd, previous.player, previous.data)
        check(#outbound == (receiptDispatchCandidate and 1 or 0), "send occurs in the expected phase")
        testMillis = base + tickAt
        Damage.tick()
        check(#outbound == 1, "duplicate ack and next tick do not resend")
        local sent = outbound[1].at
        testMillis = sent + lastLeg
        deliver()
        check(view[2].source == "turret-rotary" and view[2].at == testMillis, "rotary label displays on owner application")
        local display = view[2].at - (base-age)
        check(display == age + (receiptDispatchCandidate and receiptAt or tickAt) + lastLeg, "replayed display time")
        testMillis = testMillis + lastLeg
        ack()
        expect(1,.1,"applied")
        expect(2,.2,"applied")
        check(#results==2 and #notices==2 and #view==2 and math.abs(server.health-.7)<.00001
            and math.abs(client.health-.7)<.00001, "each hit settles and displays once")
        trace[#trace+1] = label.." "..(sent-base).." "..display
    end
    replay("67",107,3,157,194,72)
    replay("62",96,38,121,185,64)

    local function burst(n)
        fresh()
        Damage.tick()
        for i=1,n do
            id=id+1
            server,client=zombie(1),zombie(1)
            testMode="client";Client.created(client);testMode="server";Server.created(server)
            submit("lead-"..i,.1,"firearm")
            submit("next-"..i,.1,"firearm")
        end
        for i=1,n do deliver() end
    end
    local function drain(n)
        for i=1,n do deliver();ack() end
        check(#results==2*n and #notices==2*n and #view==2*n,"every burst victim served once")
    end
    burst(40)
    for i=1,40 do ack() end
    check(#outbound==(receiptDispatchCandidate and 32 or 0),"a receipt burst shares the 32-start budget")
    Damage.tick()
    if not receiptDispatchCandidate then Damage.tick() end
    check(#outbound==40,"remaining victims resume at next available tick")
    for i=1,40 do check(outbound[i].data.source=="next-"..i,"FIFO for distinct victims") end
    drain(40)

    burst(40)
    local first=table.remove(inbound,1)
    for i=2,33 do ack() end
    Damage.tick()
    check(#outbound==32,"tick starts 32 ready victims")
    for i=34,40 do ack() end
    table.insert(inbound,1,first);ack()
    check(#outbound==32,"receipts cannot reuse a spent tick budget")
    Damage.tick()
    drain(40)

    burst(2)
    inbound[1],inbound[2]=inbound[2],inbound[1]
    ack()
    check(#outbound==0,"later victim cannot skip earlier lane")
    ack();Damage.tick()
    check(outbound[1].data.source=="next-1" and outbound[2].data.source=="next-2","older victim retains priority")
    drain(2)

    burst(3)
    local send=sendServerCommand
    sendServerCommand=function(...)
        send(...)
        testMillis=testMillis+3
    end
    for i=1,3 do ack() end
    check(#outbound==(receiptDispatchCandidate and 1 or 0),"receipt dispatch yields after slow work")
    sendServerCommand=send
    Damage.tick()
    drain(3)

    burst(1)
    local clock=require("OMHTT/ActiveTime")
    local paused=clock.paused
    clock.paused=function() return true end
    ack()
    check(#outbound==0,"receipt does not start work while paused")
    clock.paused=paused
    Damage.tick()
    drain(1)

    fresh()
    Damage.tick()
    submit("lead",.1,"firearm")
    submit("paired-first",.1,"barbs")
    submit("paired-second",.1,"barbs")
    submit("last",.1,"firearm")
    deliver();ack();Damage.tick();deliver()
    local announce=triggerEvent
    local announced=0
    triggerEvent=function(name,...)
        if name=="OnOMHTTDamage" then
            announced=announced+1
            check(#outbound==0,"both paired hits announce before sending the next hit")
        end
        announce(name,...)
    end
    ack()
    triggerEvent=announce
    check(announced==2 and #results==3 and #outbound==(receiptDispatchCandidate and 1 or 0),"pair fully settled")
    Damage.tick();deliver();ack()
    check(#results==4 and #notices==4 and #view==4 and math.abs(server.health-.6)<.00001,"paired lane drains in order")
    receiptDispatchTrace=table.concat(trace,"|")
end

local p=group(.2,.3)
deliver();local receipt=ack()
expect(2,.2,"applied");expect(3,.3,"applied")
check(results[2].source=="first" and results[3].source=="second","FIFO callbacks")
deliver(p);ack();Server.command(P.MODULE,receipt.cmd,a,receipt.data)
check(#results==3 and math.abs(server.health-.4)<.00001 and math.abs(client.health-.4)<.00001,"duplicate pair and ack are idempotent")
check(#view==3 and #notices==3 and view[2].token~=view[3].token and view[2].token==notices[2].token
    and view[3].token==notices[3].token,"per-hit owner and observer indicator tokens")

group(.2,.3,1);testMillis=testMillis+151;deliver();ack()
expect(2,0,"expired");expect(3,.3,"applied")
check(math.abs(server.health-.6)<.00001 and math.abs(client.health-.6)<.00001,"first expiry isolates second hit")
group(.2,.3,2);testMillis=testMillis+151;deliver();ack()
expect(2,.2,"applied");expect(3,0,"expired")
check(math.abs(server.health-.7)<.00001 and math.abs(client.health-.7)<.00001,"second expiry isolates first hit")

group(.2,.3,2);local withheld=table.remove(outbound,1)
testMillis=testMillis+P.TIMEOUT/2+1;Server.tick();deliver();ack()
expect(2,.2,"applied");expect(3,0,"expired")
deliver(withheld);ack()
check(#results==3 and math.abs(client.health-.7)<.00001,"lost Apply can retry only still-valid members")
fresh();submit("lead",.1,"firearm");submit("first",.1,"barbs");submit("second",.1,"barbs")
deliver();ack();Damage.tick();testMillis=testMillis+501;deliver();ack()
expect(2,0,"expired");expect(3,0,"expired")
check(math.abs(client.health-.9)<.00001 and #view==1,"fully expired pair has no health or visual effect")

for lethal=1,2 do
    group(lethal==1 and 2 or .2,2)
    deliver()
    check(client.health==P.EPSILON and not client:isDead(),"only server may finish death")
    -- Native health may already reflect the owner's lethal reservation before the receipt.
    server.health=P.EPSILON
    ack()
    local source=lethal==1 and "first" or "second"
    check(#xp==1 and xp[1].event==event and xp[1].source==source and xp[1].z==server,"XP credited to actual finisher")
    check(#lethalMarks==1 and lethalMarks[1]==source and server.kills==1 and server.deathDone
        and horde.consumeDeath(server,event) and not horde.consumeDeath(server,event),"one native death and one real Horde finisher")
    if lethal==1 then expect(2,.9,"applied");expect(3,0,"dead")
    else expect(2,.2,"applied");expect(3,.7,"applied") end
end

group(.2,.3);deliver()
local valid=inbound[1]
local notify=triggerEvent
local duplicateAtCallback=0
triggerEvent=function(name,...)
    if name=="OnOMHTTDamage" and duplicateAtCallback==0 then
        duplicateAtCallback=1
        Server.command(P.MODULE,valid.cmd,a,valid.data)
    end
    notify(name,...)
end
local fake=nativeRoundTrip(valid.data);fake.after=.8
Server.command(P.MODULE,"Applied",a,fake)
Server.command(P.MODULE,"Applied",b,valid.data)
fake=nativeRoundTrip(valid.data);fake.appliedAt=testMillis+1000
Server.command(P.MODULE,"Applied",a,fake)
check(#results==1 and math.abs(server.health-.9)<.00001,"forged outcome, time and sender rejected")
ack();check(#results==3 and duplicateAtCallback==1 and #notices==3,"reentrant duplicate cannot double settle")
triggerEvent=notify

p=group(.2,.3);deliver();inbound={}
testMillis=testMillis+P.TIMEOUT/2+1;Server.tick();Server.tick()
check(#outbound==1 and outbound[1].data.receipt==p.data.receipt,"one bounded resend retains original nonce")
deliver();ack();expect(2,.2,"applied");expect(3,.3,"applied")
check(math.abs(server.health-.4)<.00001 and math.abs(client.health-.4)<.00001 and #view==3,"lost ack on unchanged owner cannot repeat damage or UI")

p=group(.2,.3);deliver();inbound={}
server.owner=b;Server.tick()
deliver();ack()
client=replacement(.35)
check(outbound[1].cmd=="Reconcile","lost pair response reconciles once after handoff")
local rec=deliver();ack();deliver(rec);ack()
check(#results==3 and server.health==.35 and client.health==.35,"reconciliation neither doubles damage nor heals")

p=group(.2,.3,2);testMillis=testMillis+151;deliver();inbound={}
server.owner=b;Server.tick();deliver();ack();client=replacement(.55);deliver();ack()
expect(2,.2,"applied");expect(3,0,"expired")
check(server.health==.55 and client.health==.55,"handoff preserves lower health when second hit expired")

p=group(.2,.3);table.remove(outbound,1)
server.owner=b;client.remote=true;Server.tick()
deliver();ack()
deliver(p);inbound={}
client=replacement(.9)
check(outbound[1].cmd=="ApplyPair","old owner confirms unapplied before redispatch")
deliver();ack()
check(#results==3 and math.abs(server.health-.4)<.00001 and math.abs(client.health-.4)<.00001,"unapplied handoff applies each hit once")

group(.2,.3);deliver();server.owner=nil;ack()
expect(2,.2,"applied");expect(3,.3,"applied")
check(math.abs(server.health-.4)<.00001,"applied pair settles after owner disconnects")

group(.2,2);deliver();event={};ack()
expect(2,0,"ownership-uncertain");expect(3,0,"ownership-uncertain")
check(#xp==0 and server.kills==0 and #lethalMarks==0,"changed run receives neither XP nor kill")
fresh();enabled.defensesEnabled=false
check(not Damage.resolve(server,.1,"denied","barbs") and #outbound==0,"disabled run cannot start an owner operation")
enabled.defensesEnabled=true

-- Native location and ownership are revalidated for both lookup paths.
OneMoreHordeDefenseIntegration=nil
SandboxVars.OMHTurretsTraps={Enabled=true}
local barrierRecord={id="fixture-barrier",x=sq.x,y=sq.y,z=0,width=2,facing=0,tier="normal"}
local obj=IsoObject.new(sq,"fixture","barrier")
obj.getHealth=function() return 80 end
obj.data.OMHTTEdge={x=sq.x,y=sq.y,tx=sq.x,ty=sq.y+1,nx=1,ny=0,role="front"}
sq.objects={obj}
require("OMHTT/BarrierFootprint").exact=function(o) if o==obj then return barrierRecord end end
local calls,reads,member=0,0,nil
Damage.resolve=function(z) check(z==member,"wrong barrier victim");calls=calls+1;return true end
Actors.at=function(tile)
    reads=reads+1
    local found=member and member:getSquare()==tile
    return {size=function() return found and 1 or 0 end,get=function() return member end}
end
fresh();OneMoreHordeDefenseIntegration=nil
member=server;Actors.observe(server,true);server.state="thump"
local msg={id=server.onlineId,outfit=server.outfitId,barrier=barrierRecord.id,x=sq.x,y=sq.y,z=0,index=0,token="left"}
local function strike(player)
    testMillis=testMillis+250
    Barrier.command("OMHTT_BarrierContact","Strike",player or a,msg)
end
strike();check(calls==1 and reads==0,"warm index avoids square reads")
strike();check(calls==1,"same marker cannot repeat")
Actors.online[msg.id]=nil;msg.token="right"
strike();check(calls==2 and reads>0,"cold index resolves valid attacker")
local recycled=zombie(1);recycled.outfitId=999
Actors.observe(recycled,true);msg.token="left"
strike();check(calls==3,"recycled ID falls back to correct attacker")
msg.token="right";strike(b);check(calls==3,"wrong owner rejected")
msg.outfit=999;Actors.online[msg.id]=nil;strike();check(calls==3,"wrong outfit rejected")
msg.outfit=server.outfitId;Actors.observe(server,true)
local floor=server.getZ;server.getZ=function() return 1 end
strike();check(calls==3,"other floor rejected");server.getZ=floor
msg.barrier="forged";strike();check(calls==3,"forged collider rejected");msg.barrier=barrierRecord.id
obj.data.OMHTTEdge.nx=-1
strike();check(calls==3,"safe rear cannot retaliate")
testPackAudit="C550 focused checks "..(testAssertions-beforeChecks).." PASS"
