local T = require("OMHTT/Turret")
local M = require("OMHTT/TurretModules")
local Actors = require("OMHTT/DefenseActors")
local O = require("OMHTT/TurretOrdnance")
local V = require("OMHTT/TurretVolley")
local Damage = require("OMHTT/Damage")
local Clock = require("OMHTT/TurretClock")
local old = {mode=testMode, settings=SandboxVars.OMHTurretsTraps, time=Clock.now, random=ZombRand,
    jobs=O.jobs, reserved=O.reserved, serial=O.serial, damage=Damage.resolve, millis=testMillis}
testMode, SandboxVars.OMHTurretsTraps = "sp", {}
local now = 15000000
Clock.now = function() return now end
ZombRand = function() return 0 end
local contents = {head={getFullType=function() return "Base.OMHTTTurretLobber" end},active={MotionDetection=1,Detection360=1},powerLoad=0}
local stats = T.cycleConfig(contents)
check(stats.minimumRange==0,"C540 Lobber has no minimum firing distance")
for x=17992,18026 do for y=17992,18008 do makeSquare(x,y,0) end end
local origin = testSquares["18000:18000:0"]
local target = makeZombie(origin,100)
target.onlineId, target.outfitId = 32500, 540
local x = 18000.5
target.getX = function() return x end
Actors.observe(target)
local profile = M.profile({},contents,true,stats)
for _,mode in pairs({"sp","server"}) do
    testMode = mode
    target.owner = mode=="server" and {getOnlineID=function() return 7 end} or nil
    for _,distance in pairs({0,.1,1,5,6,18,19}) do
        x=18000.5+distance
        target.square=testSquares[math.floor(x)..":18000:0"]
        testMillis=now
        Actors.report(target,{x=x,y=18000.5,z=0,at=testMillis})
        check(M.inside(origin,target,profile)==(distance<=18),"C540 effective acquisition "..mode.." distance="..distance)
    end
end
testMode,target.owner="sp",nil
origin.moving={}
for _,ammo in pairs({"Base.OMHTTAmmoMakeshiftBomb","Base.Aerosolbomb","Base.PipeBomb"}) do
    for _,distance in pairs({0,.1,1,5}) do
        x=18000.5+distance
        target.square.moving={}
        target.square=testSquares[math.floor(x)..":18000:0"]
        target.square.moving={target}
        Actors.observe(target)
        O.jobs,O.reserved={},0
        local hits=0
        Damage.resolve=function(victim,amount,source,kind,callback)
            check(victim==target and amount>0 and kind=="grenade","C540 close blast applies positive damage")
            hits=hits+1
            callback(amount)
            return true
        end
        local options={stats=stats,damage=1.5,critical=false,managed=true,impactReady=false,ammoDescriptor={type=ammo}}
        check(V.reserve(options),"C540 close blast admitted")
        O.launch({id="turret-c540",shots=1},origin,target,nil,options)
        V.done(options)
        local job=O.jobs[1]
        check(math.abs(job.range-distance)<.00001,"C540 no hidden six-tile landing clamp")
        for i=1,100 do
            O.step(job)
            if job.landed then break end
            now=now+25
        end
        check(job.landed and math.abs(job.x-x)<.00001,"C540 close projectile lands at intended contact")
        now=job.due-1
        check(O.step(job)==nil and hits==0,"C540 close blast preserves landing fuse")
        now=job.due
        local done=false
        for i=1,1500 do
            if O.step(job)==true then done=true;break end
        end
        check(done and hits==1,"C540 close blast damages exactly once "..ammo.." distance="..distance)
    end
end
Actors.remove(target)
target.square.moving={}
O.jobs,O.reserved,O.serial=old.jobs,old.reserved,old.serial
Damage.resolve,Clock.now,ZombRand=old.damage,old.time,old.random
testMode,SandboxVars.OMHTurretsTraps,testMillis=old.mode,old.settings,old.millis
