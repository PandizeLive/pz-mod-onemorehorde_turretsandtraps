local V=require("OMHTT/TurretVolley")
local Clock=require("OMHTT/TurretClock")
local Budget=require("OMHTT/TurretScheduler")
local Effects=require("OMHTT/DefenseEffects")
local Combat=require("OMHTT/PrototypeCombat")
local Actors=require("OMHTT/DefenseActors")
local Damage=require("OMHTT/Damage")
local saved={mode=testMode,time=testMillis,clock=Clock.now,limit=Budget.limit,emit=Effects.emit,lane=Combat.clearLane,
    queue=V.queue,cursor=V.cursor,occupants=Actors.occupants,available=Damage.available}
testMode="sp"
Clock.now=function() return testMillis end
Budget.limit=function() return math.huge end
Combat.clearLane=function() return true end
for x=11100,11135 do for y=11100,11135 do makeSquare(x,y,0) end end
local empty={size=function() return 0 end}
Actors.occupants=function() return empty end
local measurements={}
for _,count in pairs({1,2,4,5,6,8,16}) do
    testMillis=810000
    local last,first,events=0,nil,0
    Effects.emit=function(command)
        if command=="Ray" then
            first=first or testMillis-810000;last=testMillis-810000;events=events+1
        end
    end
    V.queue,V.cursor={},1
    local group={kind="splitter",stats={firearm=true},hits={},remaining=count,rays={}}
    for i=1,count do V.ray({id="c531",shots=1},11100.5,11100.5,0,0,30,.2,group,i) end
    local ticks=0
    while #V.queue>0 and ticks<100 do V.tick();ticks=ticks+1;testMillis=testMillis+100 end
    check(events==count,"C531 stacked firearm sides emit once each without a full-group gate")
    check(last==0,"C531 stacked empty firearm rays finish within one bounded work slice")
    measurements[#measurements+1]=count..":"..first.."/"..last
end
-- Production traversal and damage: stacked physical rays must hit at contact,
-- not at maximum range, and must not deal damage before their flight arrives.
local HealthHit=require("OMHTT/TurretHit")
local savedHit=HealthHit.resolve
local actualHits=0
HealthHit.resolve=function(actor,amount)
    actualHits=actualHits+1
    actor:setHealth(actor:getHealth()-amount)
    return true
end
for _,count in pairs({1,2,4,5,6,8,16}) do
    testMillis=815000
    local contactSquare=testSquares["11105:11100:0"]
    local victim=makeZombie(contactSquare,10)
    function victim:getWidth() return .3 end
    Actors.occupants=function(square)
        return square==contactSquare and {size=function() return 1 end,get=function() return victim end} or empty
    end
    V.queue,V.cursor={},1
    actualHits=0
    local group={kind="splitter",stats={firearm=false,fragment=0},hits={},remaining=count,rays={}}
    for i=1,count do V.ray({id="c531-contact",shots=count},11100.5,11100.5,0,0,10,.1,group,i) end
    for elapsed=0,245,5 do testMillis=815000+elapsed;V.tick() end
    check(actualHits==0,"C531 stacked physical rays never damage before their contact time")
    testMillis=815250;V.tick()
    check(actualHits==count and math.abs(victim.health-(10-count*.1))<.00001,
        "C531 all stacked physical rays resolve exactly at the actual target distance")
end
HealthHit.resolve=savedHit
Actors.occupants=function() return empty end
-- Tile-boundary stepping preserves negative and diagonal travel and wall stops.
for _,angle in pairs({0,math.pi/2,math.pi,-math.pi/2,math.pi/4,-math.pi*3/4}) do
    V.queue={}
    V.ray({id="c531-dda",shots=1},11115.5,11115.5,0,angle,8,.1,{kind="splitter",stats={firearm=true},hits={}},1)
    local trace=V.queue[1]
    local steps=0
    while not V.step(trace) and steps<64 do steps=steps+1 end
    check(steps<64 and math.abs(trace.distance-8)<.00001,"C531 DDA reaches exact range in every tested direction")
end
V.queue={}
V.ray({id="c531-wall",shots=1},11100.5,11100.5,0,0,10,.1,{kind="splitter",stats={firearm=true},hits={}},1)
local wallRay=V.queue[1]
Combat.clearLane=function(_,to) return to:getX()<11103 end
for i=1,64 do if V.step(wallRay) then break end end
check(wallRay.distance<2.5 and wallRay.distance>2.499,"C531 DDA ends at the wall edge without passing through")
Combat.clearLane=function() return true end
local clockFn, realLimit = getTimestampMs, Budget.limit
getTimestampMs = realMillis
Budget.limit = saved.limit
local deadlineResults = {}
for _,count in pairs({1,2,4,5,6,8,16}) do
    local peak, slices = 0, 0
    V.queue,V.cursor={},1
    for i=1,count do V.ray({id="c531-budget",shots=count},11100.5,11100.5,0,0,30,.1,
        {kind="splitter",stats={firearm=true},hits={}},i) end
    while #V.queue>0 and slices<1000 do
        local started=realMillis();V.tick();peak=math.max(peak,realMillis()-started);slices=slices+1
    end
    check(#V.queue==0,"C531 real one-millisecond work deadline drains stacked rays")
    deadlineResults[#deadlineResults+1]=count..":"..slices.." slices/"..string.format("%.3f",peak).."ms peak"
end
getTimestampMs,Budget.limit=clockFn,realLimit
testContactBudget=table.concat(deadlineResults,", ")
-- Terminal contact presentation is independent of damage admission contention.
local impactCount=0
Effects.emit=function(command) if command=="Impact" then impactCount=impactCount+1 end end
V.queue={}
V.ray({id="c531",shots=2},11100.5,11100.5,0,0,10,.2,{kind="fragment",stats={},hits={},remaining=1,rays={}},1)
local ray=V.queue[1]
ray.distance,ray.bestDistance,ray.best=5,5,makeZombie(testSquares["11105:11100:0"],1)
testMillis=testMillis+250
Damage.available=function() return false end
check(V.finish(ray)==true and impactCount==1,"C531 physical contact emits impact even when damage admission is busy")
check(V.finish(ray)==true and impactCount==1,"C531 waiting damage never repeats contact impact")
Damage.available=saved.available

local Projectile=require("OMHTT/PrototypeEffects")
local oldEffects,oldPlayers=Projectile.effects,getNumActivePlayers
getNumActivePlayers=function() return 0 end
testMode="client"
for _,count in pairs({1,2,4,5,6,8,16}) do
    for _,transit in pairs({0,50,150,250}) do
        Projectile.reset()
        testMillis=820000
        local square=testSquares["11105:11100:0"]
        local zombie=makeZombie(square,1)
        function zombie:getWidth() return .3 end
        zombie.onlineId,zombie.outfitId=31000,31000
        square.moving={zombie}
        for i=1,count do
            Projectile.receive(require("OMHTT/Foundation").MODULE,"Launch",{id="c531-"..count.."-"..transit,shot=i,
                fromX=11100.5,fromY=11100.5,x=11110.5,y=11100.5,z=0,flight=500,sentAt=testMillis-transit,
                projectile="potato",contactFlight=true,ammoType="Base.Potato",silent=true,muzzle=0})
        end
        local contact=820000+math.max(0,250-transit)
        testMillis=contact
        Projectile.render()
        check(#Projectile.effects==count,"C531 stack retains all child contact effects")
        for i=1,count do
            local effect=Projectile.effects[i]
            check(effect.phase=="Impact" and math.abs(effect.x-zombie:getX())<.001,
                "C531 production render pops at actual occupied contact distance with delayed launch packets")
            local start=effect.start
            testMillis=contact+200
            Projectile.receive(require("OMHTT/Foundation").MODULE,"Impact",{id=effect.id,shot=effect.shot,
                packet=900000+count*100+transit+i,x=effect.x,y=effect.y,z=0,projectile="potato",silent=true})
            check(effect.start==start,"C531 delayed authoritative impact cannot replay predicted pop")
        end
        check(zombie.health==1,"C531 client presentation never mutates target health")
        square.moving={}
    end
end
-- A Fragment cannot pop against the zombie it came from.
Projectile.reset();testMillis=830000
local square=testSquares["11100:11100:0"]
local parent=makeZombie(square,1);parent.onlineId,parent.outfitId=32000,32000;square.moving={parent}
function parent:getWidth() return .3 end
Projectile.receive(require("OMHTT/Foundation").MODULE,"Launch",{id="c531-excluded",shot=1,fromX=11100.5,fromY=11100.5,
    x=11110.5,y=11100.5,z=0,flight=500,sentAt=testMillis,projectile="potato",contactFlight=true,
    excludeId=32000,excludeOutfit=32000,silent=true,muzzle=0})
testMillis=testMillis+50;Projectile.render()
check(Projectile.effects[1].phase=="Launch","C531 Fragment origin exclusion survives local prediction")
square.moving={}
for elapsed=10,450,10 do testMillis=830050+elapsed;Projectile.render() end
check(Projectile.effects[1].phase=="Impact","C531 empty maximum-range endpoint ends without a hold")
Projectile.effects,getNumActivePlayers=oldEffects,oldPlayers

local Contact=require("OMHTT/TurretContactView")
local turret=IsoObject.new(testSquares["11100:11100:0"],"test","test")
function turret:getHealth() return 100 end
turret:getSquare():AddTileObject(turret)
Contact.changed(turret,2)
local nearby=makeZombie(testSquares["11102:11100:0"],1)
check(Contact.near(nearby),"C531 standalone turret requests fresh positions without any trap nearby")
Contact.remove(turret)
check(not Contact.near(nearby),"C531 removed turret no longer requests position traffic")

local R=require("OMHTT/TurretRotary")
testMode="server"
local history={}
testMillis=840000;R.record(history,0,18,100)
testMillis=840100;R.record(history,18,36,100)
check(math.abs(R.travelAt(history,839950)-9)<.0001 and math.abs(R.travelAt(history,840050)-27)<.0001,
    "C531 motor history samples the observation timestamp rather than current render travel")
check(R.travelAt(history,839899)==nil,"C531 unsupported historical contact time cannot invent a sweep")
local rapid={}
for i=1,100 do testMillis=839000+i*10;R.record(rapid,i-1,i,10) end
check(R.travelAt(rapid,839750)~=nil,"C531 high tick rates retain the full accepted contact history")
local T=require("OMHTT/Turret")
local Horde=require("OMHTT/DefenseHorde")
local Policy=require("OMHTT/ControlCombat")
local Proc=require("OMHTT/TurretProc")
local restore={allowed=Horde.allowed,eligible=Policy.eligible,resolve=Damage.resolve,available=Proc.available,reserve=Proc.reserve}
Horde.allowed,Policy.eligible,Proc.available=function() return true end,function() return true end,function() return true end
Proc.reserve=function() end
local hits=0
Damage.resolve=function(_,_,_,_,_,observation) hits=hits+1;check(observation.at==840000,"C531 damage retains actual observation time");return true end
local state={schema=1,id="turret-c531",powered=true,standby="active"}
turret:getModData().OMHTTTurret=state
require("OMHTT/TurretAuthority").register(turret,state)
local actor=makeZombie(testSquares["11101:11100:0"],1)
actor.owner={getOnlineID=function() return 88 end,isDead=function() return false end}
actor.onlineId,actor.outfitId=33000,33000
Actors.observe(actor)
Actors.report(actor,{x=11101.5,y=11100.5,z=0,at=840000})
local entry={object=turret,hits={{},{}},soundAt=math.huge}
testMillis=840000;R.record(entry,350,370,100)
testMillis=840150;R.record(entry,370,400,150)
local profile={range=2,omni=true,heading=0,cone=360}
local job={at=testMillis,moving=true,before=380,after=400,profile=profile,detection=profile,stats={damage=20,critChance=0,initialBlow=0,execute=0}}
R.contact(entry,actor,job)
check(hits==1,"C531 delayed report hits its historical blade crossing rather than missing against current travel")
R.contact(entry,actor,job)
check(hits==1,"C531 replayed observation cannot repeat historical blade damage")
Actors.report(actor,{x=11100.5,y=11101.5,z=0,at=840100})
R.contact(entry,actor,job)
check(hits==1,"C531 target moving away from the historical blade does not inherit an earlier hit")
actor.owner={getOnlineID=function() return 89 end,isDead=function() return false end}
R.contact(entry,actor,job)
check(hits==1,"C531 owner handoff invalidates the old historical observation")
testMillis=840500
R.contact(entry,actor,job)
check(hits==1,"C531 expired sweep cannot replay historical damage")
Horde.allowed,Policy.eligible,Damage.resolve,Proc.available,Proc.reserve=restore.allowed,restore.eligible,restore.resolve,restore.available,restore.reserve

local Reservation=require("OMHTT/ControlBuildReservation")
local Footprint=require("OMHTT/ControlPokeFootprint")
local originalReserved=Footprint.reserved
local reserved=testSquares["11100:11100:0"]
Footprint.reserved=function(tile) return tile==reserved end
local oldEntity,oldWall=ISBuildIsoEntity,ISWoodenWall
local calls=0
ISBuildIsoEntity={isValidPerSquare=function() calls=calls+1;return true end}
ISWoodenWall={isValid=function() calls=calls+1;return true end,create=function() calls=calls+1;return true end}
Reservation.install()
check(not ISBuildIsoEntity.isValidPerSquare({north=true},reserved,nil,true,false,false),"C531 native entity preview/server validation reject reserved tile")
check(not ISWoodenWall.isValid({north=true},reserved),"C531 legacy wall preview rejects stabilizer")
check(not ISWoodenWall.create({},11100,11100,0,true,"wall") and calls==0,"C531 late legacy creation fails before material consumption")
check(not Reservation.blocked(testSquares["11102:11100:0"],true,true),"C531 nearby unrelated construction remains available")
check(Reservation.blocked(testSquares["11101:11100:0"],false,true),"C531 opposite edge cannot cross reserved stabilizer")
ISBuildIsoEntity,ISWoodenWall,Footprint.reserved=oldEntity,oldWall,originalReserved

local View=require("OMHTT/ControlTriggerView")
local Access=require("OMHTT/ControlAccess")
local accessState=Access.state
Access.state=function() error("C531 disconnect attempted a server-only access lookup") end
View.entries,View.pending={[turret]={}},{[turret]=testMillis+1000}
testMode="sp"
View.tick();View.render(0)
check(not View.entries[turret] and not View.pending[turret],"C531 disconnect clears trigger views before server-only access")
Access.state=accessState

testMode,testMillis,Clock.now,Budget.limit,Effects.emit,Combat.clearLane=saved.mode,saved.time,saved.clock,saved.limit,saved.emit,saved.lane
V.queue,V.cursor,Actors.occupants=saved.queue,saved.cursor,saved.occupants
testPackAudit="C531 stacked firearm first/last ms "..table.concat(measurements,", ").."; child contact timing, delayed confirmations, source exclusion, standalone reports and build gates passed; GPU/connected clients untested"
testContactTiming=testPackAudit
