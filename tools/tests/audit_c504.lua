-- Diagnostic reproductions against unchanged 0.2.70.6; not acceptance tests.
local savedMode, savedMillis = testMode, testMillis
local savedSettings = SandboxVars.OMHTurretsTraps
testMode, testMillis = "server", 2000000
SandboxVars.OMHTurretsTraps = {Enabled=true, TurretsEnabled=true, PokeCycleSeconds=1.5}
local H = require("OMHTT/DefenseHorde")
local savedAllowed = H.allowed
H.allowed = function() return true end

do
    local A = require("OMHTT/TurretAutomation")
    local Combat = require("OMHTT/PrototypeCombat")
    local oldLane = Combat.clearLane
    Combat.clearLane = function() return true end
    local origin = makeSquare(7000,7000,0)
    for x=6976,7024 do
        for y=6976,7024 do makeSquare(x,y,0) end
    end
    origin = testSquares["7000:7000:0"]
    local target = makeZombie(testSquares["7005:7000:0"],1)
    local results = {}
    for _, range in pairs({9,24}) do
        local job = A.scan(origin,{range=range,cone=360,priority="Closest"})
        local slices = 1
        while not A.advance(job,64,testMillis+100) do
            slices = slices+1
            check(slices < 100,"C504 incremental search terminates")
        end
        check(job.best==target,"C504 range scan eventually selects eligible target")
        results[range]=slices
    end
    check(results[9]==6 and results[24]==38,"C504 full-area scan takes 6/38 visits at 9/24 tiles")
    Combat.clearLane = oldLane
    print("C504 search slices: range9="..results[9].." range24="..results[24])
end

do
    local P = require("OMHTT/ControlPoke")
    local W = require("OMHTT/ControlWorld")
    local D = require("OMHTT/Damage")
    local Audio = require("OMHTT/ControlAudio")
    local oldVisual, oldState, oldPublish, oldResolve, oldAudio = P.visual,W.state,W.publish,D.resolve,Audio.emit
    local actual, predicted = makeSquare(7100,7100,0),makeSquare(7101,7100,0)
    local target = makeZombie(predicted,1)
    target.getX=function() return 7100.5 end
    target.getY=function() return 7100.5 end
    check(math.floor(target:getX())==actual:getX() and target:getSquare()==predicted,
        "C504 fixture preserves native real-coordinate/predicted-square distinction")
    local object={getSquare=function() return actual end,getHealth=function() return 200 end}
    local state={id="c504-poke",kind="Poke"}
    local hits=0
    P.visual=function(_,s,raised) s.active=raised end
    W.state=function() return state end
    W.publish=function() end
    D.resolve=function() hits=hits+1; return true end
    Audio.emit=function() end
    P.time=0
    P.step(object,state)
    check(not state.active and hits==0,"C504 native predicted bucket misses actor whose real coordinates occupy Poke")
    actual.moving,predicted.moving={target},{}
    P.time=100
    P.step(object,state)
    check(state.active and hits==0,"C504 first detected Poke contact waits for strike")
    actual.moving={}
    P.time=300
    P.step(object,state)
    check(hits==0,"C504 crossing ends before delayed strike and receives no damage")
    P.entries[object]=nil
    P.visual,W.state,W.publish,D.resolve,Audio.emit=oldVisual,oldState,oldPublish,oldResolve,oldAudio
end

do
    local B = require("OMHTT/BedSpikes")
    local D = require("OMHTT/Damage")
    local XP = require("OMHTT/DefenseXP")
    local Actor = require("OMHTT/DefenseActorState")
    local saved = {count=B.count,store=B.store,tiles=B.tiles,nearby=B.nearby,
        parts=B.parts,retire=B.retire,resolve=D.resolve,register=XP.register}
    local actual,predicted=makeSquare(7150,7150,0),makeSquare(7151,7150,0)
    local target=makeZombie(predicted,1)
    target.getX=function() return 7150.5 end
    target.getY=function() return 7150.5 end
    target.owner={}
    local record={id="c504-bed",health=6,tier="normal",x=7150,y=7150,z=0}
    B.count,B.store=1,{records={[record.id]=record}}
    B.tiles={ ["7150:7150:0"]=record.id }
    B.nearby={ ["7150:7150:0"]=true,["7151:7150:0"]=true }
    B.parts=function() return {{}} end
    B.retire=function() end
    XP.register=function() end
    local hits=0
    D.resolve=function() hits=hits+1; return true end
    target.state="walktoward"
    B.zombie(target)
    target.state="getup"
    B.zombie(target)
    check(hits==0,"C504 bed landing at real spike coordinates misses when square points ahead")
    Actor.created(target)
    target.square=actual
    target.state="walktoward"
    B.zombie(target)
    target.state="getup"
    B.zombie(target)
    check(hits==1,"C504 same bed landing hits when square and real coordinates agree")
    B.count,B.store,B.tiles,B.nearby=saved.count,saved.store,saved.tiles,saved.nearby
    B.parts,B.retire,D.resolve,XP.register=saved.parts,saved.retire,saved.resolve,saved.register
end

do
    local Combat = require("OMHTT/PrototypeCombat")
    local oldLane,oldHit=Combat.clearLane,Combat.hit
    local origin,targetSquare=makeSquare(7200,7200,0),makeSquare(7204,7200,0)
    local target=makeZombie(targetSquare,1)
    local applied=0
    Combat.clearLane=function() return true end
    Combat.hit=function() applied=applied+1; return {} end
    local shot={origin=origin,target=target,record={id="c504",shots=1},
        facts={x=7203,y=7200.5,z=0},options={range=9}}
    Combat.arrive(shot)
    check(applied==1,"C504 projectile accepts target 1.5 tiles beyond launch endpoint")
    local E=require("OMHTT/DefenseEffects")
    local oldSend=E.send
    local wire
    E.send=function(_,_,message) wire=message end
    E.emit("Launch",{id="c504",shot=1,x=7203,y=7200.5,z=0,target=target})
    check(wire.target==nil and wire.x==7203,"C504 MP launch has fixed endpoint and no target identity")
    E.send,Combat.clearLane,Combat.hit=oldSend,oldLane,oldHit
end

H.allowed=savedAllowed
testMode,testMillis,SandboxVars.OMHTurretsTraps=savedMode,savedMillis,savedSettings
testPackAudit="C504 search latency, predicted-square Poke/Bed misses, delayed crossing and detached projectile endpoint reproduced"
