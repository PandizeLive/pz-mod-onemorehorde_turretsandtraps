-- Production Lua with native table serialization. Transport/world objects are doubles.
local savedMode, savedMillis, savedSettings = testMode, testMillis, SandboxVars.OMHTurretsTraps
local Actors = require("OMHTT/DefenseActors")
local Contacts = require("OMHTT/DefenseContacts")
local Damage = require("OMHTT/Damage")
local Clock = require("OMHTT/TurretClock")
local oldClock = Clock.now
testMode, testMillis = "server", 3000000
Clock.now = function() return testMillis end
SandboxVars.OMHTurretsTraps = {Enabled=true,TurretsEnabled=true,PokeCycleSeconds=1.5}

do
    local A = require("OMHTT/TurretAutomation")
    local Combat = require("OMHTT/PrototypeCombat")
    local oldLane = Combat.clearLane
    Combat.clearLane = function() return true end
    local origin = makeSquare(7000,7000,0)
    local actual, predicted = makeSquare(7005,7000,0), makeSquare(7030,7000,0)
    local target = makeZombie(predicted,1)
    target.getX = function() return 7005.5 end
    target.getY = function() return 7000.5 end
    Actors.observe(target)
    local result = {}
    for _, range in pairs({9,24,7809}) do
        local job = A.scan(origin,{range=range,cone=360,heading=0,priority="Closest"})
        local visits = 1
        while not A.advance(job,128,testMillis+100) do visits=visits+1; check(visits<100,"C505 range query terminates") end
        check(job.best==target,"C505 actual-position candidate survives out-of-range predicted membership")
        result[range]=visits
    end
    check(result[9]==result[24],"C505 Range no longer multiplies empty-tile acquisition work")
    Combat.clearLane = oldLane
end

do
    local P, W = require("OMHTT/ControlPoke"), require("OMHTT/ControlWorld")
    local Audio = require("OMHTT/ControlAudio")
    local old = {visual=P.visual,state=W.state,publish=W.publish,resolve=Damage.resolve,audio=Audio.emit}
    local actual,predicted=makeSquare(7100,7100,0),makeSquare(7109,7100,0)
    local target=makeZombie(predicted,1)
    target.getX=function() return 7100.5 end
    target.getY=function() return 7100.5 end
    Actors.observe(target)
    local object={getSquare=function() return actual end,getHealth=function() return 200 end,getObjectIndex=function() return 0 end}
    local state={id="c505-poke",kind="Poke",x=7100,y=7100,z=0}
    local hits=0
    P.visual=function(_,s,raised) s.active=raised end
    W.state=function(value) return value==object and state end
    W.publish=function() end
    Damage.resolve=function() hits=hits+1;return true end
    Audio.emit=function() end
    P.time=0
    P.step(object,state)
    check(hits==1 and state.active,"C505 first actual contact strikes immediately despite wrong predicted square")
    P.time=100;P.step(object,state)
    check(hits==1,"C505 raised spikes preserve per-cycle damage protection")
    target.getX=function() return 7101.5 end
    makeSquare(7099,7100,0);makeSquare(7101,7100,0)
    Actors.observe(target)
    P.time=1600
    P.register(object,state)
    Contacts.observe(target,{x=7101.1,y=7100.5,z=0,at=testMillis+100},
        {x=7099.9,y=7100.5,z=0,at=testMillis})
    check(hits==2,"C505 recent clear crossing is detected even when both native samples are outside")
    P.time=3200
    Contacts.observe(target,{x=7101.1,y=7100.5,z=0,at=testMillis+500},
        {x=7099.9,y=7100.5,z=0,at=testMillis})
    check(hits==2,"C505 stale movement gap cannot invent historical damage")
    actual.blocked=true
    Contacts.observe(target,{x=7101.1,y=7100.5,z=0,at=testMillis+100},
        {x=7099.9,y=7100.5,z=0,at=testMillis})
    check(hits==2,"C505 crossing geometry cannot damage through a blocked edge")
    actual.blocked=false
    P.time=5000
    target.getX=function() return 7100.5 end
    P.step(object,state)
    local second=makeZombie(predicted,1)
    second.getX=function() return 7100.5 end
    second.getY=function() return 7100.5 end
    Actors.observe(second)
    P.time=5050;P.step(object,state);P.step(object,state)
    check(hits==4,"C505 later actor batch joins the rising strike once without waiting another cycle")
    P.entries[object],P.objects["7100:7100:0"]=nil,nil
    Contacts.remove(object)
    P.visual,W.state,W.publish,Damage.resolve,Audio.emit=old.visual,old.state,old.publish,old.resolve,old.audio
end

do
    local B=require("OMHTT/BedSpikes")
    local XP=require("OMHTT/DefenseXP")
    local Audio=require("OMHTT/DefenseEffects")
    local old={count=B.count,store=B.store,tiles=B.tiles,nearby=B.nearby,parts=B.parts,retire=B.retire,
        damage=Damage.resolve,register=XP.register,contact=Audio.contact}
    local actual,predicted=makeSquare(7150,7150,0),makeSquare(7151,7150,0)
    local target=makeZombie(predicted,1)
    target.getX=function() return 7150.5 end
    target.getY=function() return 7150.5 end
    target.owner={}
    local record={id="c505-bed",health=12,tier="normal",x=7150,y=7150,z=0}
    B.count,B.store=1,{records={[record.id]=record}}
    B.tiles={ ["7150:7150:0"]=record.id };B.nearby={ ["7150:7150:0"]=true }
    B.parts=function() return {{setHealth=function() end,getModData=function() return {OMHTTBed={view={}}} end,
        transmitModData=function() end,sync=function() end}} end
    B.retire=function() end;XP.register=function() end;Audio.contact=function() end
    local hits, reject=0,true
    Damage.resolve=function(_,_,_,_,callback) hits=hits+1;callback(reject and 0 or .2,"not-owner");return true end
    target.state="walktoward";B.zombie(target)
    local beforeTime=B.time
    B.time=B.time+10000 -- Simulation acceleration must not discard recent observed contact.
    target.state="getup";B.zombie(target)
    check(hits==1 and record.health==12,"C505 real landing requests damage without wearing on rejection")
    reject=false;testMillis=testMillis+1000;B.zombie(target)
    check(hits==2 and record.health==6,"C505 still-landed victim retries once after owner rejection")
    B.zombie(target)
    check(hits==2,"C505 confirmed landing never repeatedly damages stationary prone actor")
    B.count,B.store,B.tiles,B.nearby,B.parts,B.retire=old.count,old.store,old.tiles,old.nearby,old.parts,old.retire
    Damage.resolve,XP.register,Audio.contact=old.damage,old.register,old.contact
    B.time=beforeTime
end

do
    local P = require("OMHTT/DefenseCombatProtocol")
    check(P.outfit(12345)==P.outfit(12345+32768),"C505 fallen hat bit is not actor identity")
    check(P.outfit(-2147471303)==P.outfit(-2147471303+32768),"C505 signed native outfit identity remains signed")
    check(P.outfit(12345)~=P.outfit(12346),"C505 other identity bits remain protected")
    local C = require("OMHTT/DefenseCombatClient")
    local E = require("OMHTT/DefenseEffects")
    local V = require("OMHTT/PrototypeEffects")
    local target=makeZombie(makeSquare(7204,7200,0),1)
    target.onlineId,target.outfitId=101,12345
    testMode="client";C.created(target);testMode="server"
    local oldSend,wire=E.send,nil
    E.send=function(_,_,facts) wire=nativeRoundTrip(facts) end
    E.emit("Launch",{id="c505-projectile",shot=1,x=7203,y=7200.5,z=0,target=target,fromX=7200,fromY=7200,flight=500})
    check(wire.target==nil and wire.targetId==101 and wire.targetOutfit==12345,"C505 wire carries stable identity without actor userdata")
    testMode="client"
    V.receive(require("OMHTT/Foundation").MODULE,"Launch",wire)
    local effect=V.effects[#V.effects]
    local x=V.position(effect)
    check(x==target:getX(),"C505 observer projectile follows moving native target within actual hit tolerance")
    target.outfitId=12346
    x=V.position(effect)
    check(x==wire.x,"C505 recycled identity cannot redirect an old projectile")
    V.receive(require("OMHTT/Foundation").MODULE,"Impact",{id="c505-order",shot=1,packet=9505002,x=7203,y=7200.5,z=0,silent=true})
    V.effects={}
    V.receive(require("OMHTT/Foundation").MODULE,"Launch",{id="c505-order",shot=1,packet=9505001,x=7203,y=7200.5,z=0,
        fromX=7200,fromY=7200,flight=500,silent=true})
    check(#V.effects==0,"C505 expired impact cannot be resurrected by a delayed launch packet")
    E.send=oldSend;testMode="server"
end

do
    local V=require("OMHTT/TurretPackObserverView")
    local old={specific=getSpecificPlayer,count=getNumActivePlayers,byid=getPlayerByOnlineID,element=ISUIElement,item=instanceItem}
    local actor=makeZombie(makeSquare(7300,7300,0),1)
    actor.isInvisible=function() return actor.invisible==true end
    local viewer=makeZombie(makeSquare(7301,7300,0),1)
    local visible,draws=true,0
    actor.square.isCanSee=function() return visible end
    getSpecificPlayer=function() return viewer end;getNumActivePlayers=function() return 1 end
    getPlayerByOnlineID=function(id) return id==200 and actor end
    instanceItem=function(name) check(name=="Base.OMHTTModulePack","C505 observer uses real pack art");return {getTex=function() return {} end} end
    ISUIElement={new=function() return {instantiate=function() end,setStencilRect=function() end,clearStencilRect=function() end,
        drawTextureScaled=function(_,_,_,_,w,h) check(w==24 and h==24,"C505 pack marker remains miniature");draws=draws+1 end} end}
    testMode="client"
    V.receive("OMHTT_PackView","Opening",{player=200,serial=1,active=true})
    V.render();check(draws==1,"C505 nearby observer draws one pack marker")
    visible=false;V.render();check(draws==1,"C505 obstructed opener is not revealed")
    visible=true
    V.receive("OMHTT_PackView","Opening",{player=200,serial=2,active=false})
    testMillis=testMillis+2100;V.render()
    V.receive("OMHTT_PackView","Opening",{player=200,serial=1,active=true})
    V.render();check(draws==1 and V.entries[200]==nil,"C505 late start cannot resurrect expired stop")
    V.receive("OMHTT_PackView","Opening",{player=200,serial=3,active=true})
    V.render();check(draws==2,"C505 subsequent genuine opening is visible")
    actor.invisible=true;V.render();check(draws==2,"C505 invisible player cannot leak a pack marker")
    actor.invisible=false
    viewer.getX=function() return 7310.5 end
    V.render();check(draws==2,"C505 range exit hides icon immediately without waiting for server stop")
    getSpecificPlayer,getNumActivePlayers,getPlayerByOnlineID,ISUIElement,instanceItem=old.specific,old.count,old.byid,old.element,old.item
    testMode="server"
end

do
    local S=require("OMHTT/TurretPackObservers")
    local oldOnline,oldSend=getOnlinePlayers,sendServerCommand
    local opener=makeZombie(makeSquare(7400,7400,0),1)
    local viewer=makeZombie(makeSquare(7401,7400,0),1)
    opener.onlineId=201
    local online, packets=true,{}
    getOnlinePlayers=function() return {size=function() return online and 2 or 1 end,
        get=function(_,i) return i==0 and viewer or opener end,
        contains=function(_,p) return p==viewer or (online and p==opener) end} end
    sendServerCommand=function(_,_,_,facts) packets[#packets+1]=nativeRoundTrip(facts) end
    local first={character=opener,isValid=function() return true end}
    local second={character=opener,isValid=function() return true end}
    S.start(first);S.start(second);S.stop(first)
    check(S.count==1 and S.active[opener].action==second and packets[#packets].active,
        "C505 old action cancellation cannot hide a replacement pack opening")
    opener.health=0;testMillis=testMillis+250;S.tick()
    check(S.count==0 and not packets[#packets].active,"C505 opener death ends remote pack display")
    opener.health=1;S.start(second);online=false;testMillis=testMillis+250;S.tick()
    check(S.count==0 and not packets[#packets].active,"C505 opener disconnect clears nearby observer")
    local before=#packets;testMillis=testMillis+5000;S.tick()
    check(#packets==before,"C505 no observer traffic when no packs are being opened")
    getOnlinePlayers,sendServerCommand=oldOnline,oldSend
end

do
    local saved={}
    local fields={"buckets","bucketOrder","nodes","order","cleanup","cursor","due","generation","listeners","last"}
    for i=1,#fields do saved[fields[i]]=Actors[fields[i]] end
    Actors.buckets,Actors.bucketOrder,Actors.nodes,Actors.order,Actors.listeners={},{},{},{},{}
    Actors.cursor,Actors.cleanup,Actors.generation,Actors.due=0,1,1,0
    local oldCell,cell=getCell,getCell()
    local square=makeSquare(7500,7500,0)
    local actors, samples={},0
    for i=1,2500 do actors[i]=makeZombie(square,1) end
    getCell=function() return {getGridSquare=function(_,x,y,z) return cell:getGridSquare(x,y,z) end,
        getZombieList=function() return {size=function() return #actors end,get=function(_,i) return actors[i+1] end} end} end
    Actors.listeners[1]=function() samples=samples+1 end
    Actors.refresh();check(samples==1024,"C505 dense actor refresh respects per-slice count limit")
    Actors.refresh();check(samples==2048,"C505 actor cursor advances fairly rather than restarting")
    Actors.refresh();check(samples==2500,"C505 final actor batch completes without loss")
    local jobs={}
    for i=1,16 do jobs[i]={search=Actors.query(7500.5,7500.5,0,24),seen={}} end
    local rounds=0
    while rounds<30 do
        local all=true
        for i=1,16 do
            local job=jobs[i]
            for _=1,128 do local actor=Actors.advance(job.search);if actor and instanceof(actor,"IsoZombie") then job.seen[actor]=true end end
            if not job.search.done then all=false end
        end
        rounds=rounds+1;if all then break end
    end
    for i=1,16 do
        local count=0;for _ in pairs(jobs[i].seen) do count=count+1 end
        check(jobs[i].search.done and count==2500,"C505 every dense concurrent query completes with every actor")
    end
    check(rounds<=21,"C505 dense queries remain bounded and fair across turrets")
    for i=1,#fields do Actors[fields[i]]=saved[fields[i]] end
    getCell=oldCell;testSquares["7500:7500:0"]=nil
end

testMode,testMillis,SandboxVars.OMHTurretsTraps=savedMode,savedMillis,savedSettings
Clock.now=oldClock
print("[OMHTT-C505] predicted-membership=divergent quick-crossing=pass range-scaling=pass bed-retry=pass projectile-identity=pass observer-render=pass")
