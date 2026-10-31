-- Production damage producers and V2 transport. World, actors and network timing are doubles.
local S = require("OMHTT/DefenseCombatServer")
local C = require("OMHTT/DefenseCombatClient")
local P = require("OMHTT/DefenseCombatProtocol")
local D = require("OMHTT/Damage")
local T = require("OMHTT/Turret")
local Stats = require("OMHTT/TurretStats")
local Heads = require("OMHTT/TurretHeads")
local V = require("OMHTT/TurretVolley")
local Arc = require("OMHTT/TurretArc")
local Proc = require("OMHTT/TurretProc")
local Actors = require("OMHTT/DefenseActors")
local Clock = require("OMHTT/TurretClock")
local Effects = require("OMHTT/DefenseEffects")
local Horde = require("OMHTT/DefenseHorde")
local Motion = require("OMHTT/DefenseMotion")
local old = {mode=testMode, time=testMillis, settings=SandboxVars.OMHTurretsTraps,
    server=sendServerCommand, client=sendClientCommand, player=getSpecificPlayer,
    clock=Clock.now, effects=Effects.emit, sound=Horde.sound, motion=Motion.request,
    random=ZombRand, core=OneMoreHordeDefenseIntegration, squares=testSquares}
testMode, testMillis, testSquares = "server", 9000000, {}
SandboxVars.OMHTurretsTraps = {Enabled=true, TurretsEnabled=true, FirearmAccuracyMultiplier=3}
OneMoreHordeDefenseIntegration = nil
Clock.now = function() return testMillis end
Effects.emit, Horde.sound = function() end, function() end
Motion.request = function() return true end
ZombRand = function() return 0 end
local owner = {getOnlineID=function() return 309 end, isDead=function() return false end}
getSpecificPlayer = function(i) if i == 0 then return owner end end
local out, incoming, receipts, applied = {}, {}, {}, 0
sendServerCommand = function(player, module, command, message)
    if module == P.MODULE then out[#out+1] = {command=command, message=nativeRoundTrip(message)} end
end
sendClientCommand = function(player, module, command, message)
    if module == P.MODULE then incoming[#incoming+1] = {command=command, message=nativeRoundTrip(message)} end
end
local function settle()
    for _ = 1, 200 do
        if #V.queue > 0 then V.tick() end
        if #Arc.jobs > 0 then Arc.tick() end
        if #out == 0 and #incoming == 0 then D.tick() end
        if #out == 0 and #incoming == 0 and #V.queue == 0 and #Arc.jobs == 0 then return end
        testMillis = testMillis + 50
        local batch = out; out = {}
        testMode="client"; C.expire(); testMode="server"
        for i = 1, #batch do
            testMode = "client"; C.command(P.MODULE, batch[i].command, batch[i].message); testMode = "server"
        end
        testMillis = testMillis + 50
        batch = incoming; incoming = {}
        for i = 1, #batch do
            local packet = batch[i]
            S.command(P.MODULE, packet.command, owner, packet.message)
            S.command(P.MODULE, packet.command, owner, packet.message)
            receipts[#receipts+1] = packet
            applied = applied + 1
        end
        D.tick()
    end
    error("C509 transport did not drain")
end
for x=8996,9010 do for y=8996,9005 do makeSquare(x,y,0) end end
local origin = testSquares["9000:9000:0"]
local targetSquare = testSquares["9001:9000:0"]
local objectData={}
local object = {getSquare=function() return origin end, getObjectIndex=function() return 0 end,
    getModData=function() return objectData end, transmitModData=function() end}
require("OMHTT/TurretAuthority").register(object,{schema=1,id="turret-c509",powered=true})
local serial = 30000
local previous
local function pair(health,where,keep)
    if previous and not keep then Actors.remove(previous) end
    serial = serial + 1; testMillis = testMillis + 10
    local square=where or targetSquare
    square.moving = {}
    local server = makeZombie(square, health or 10)
    server.owner, server.onlineId, server.outfitId = owner, serial, serial
    function server:getWidth() return .3 end
    function server:Kill() self.health=0; self.kills=self.kills+1 end
    function server:die() self.deathDone=true end
    function server:isOnDeathDone() return self.deathDone == true end
    local client = makeZombie(square, health or 10)
    Actors.remove(client)
    client.owner, client.onlineId, client.outfitId = owner, serial, serial
    square.moving = {server}
    testMode="client"; C.created(client); testMode="server"; S.created(server)
    Actors.observe(server)
    previous=server
    return server, client
end
local function head(name)
    local h = {name=name, data={}, condition=100}
    function h:getFullType() return string.find(self.name,"Base.",1,true) and self.name or "Base.OMHTTTurret"..self.name end
    function h:getModData() return self.data end
    function h:getCondition() return self.condition end
    function h:setCondition(n) self.condition=n end
    function h:getMinDamage() return .6 end
    function h:getMaxDamage() return 1 end
    function h:getMaxRange() return 15 end
    function h:getRecoilDelay() return 12 end
    function h:getFireMode() return "Single" end
    function h:getCyclicRateMultiplier() return 0 end
    function h:getMinSightRange() return 2 end
    function h:getMaxSightRange() return 10 end
    function h:getCriticalChance() return 20 end
    function h:getCriticalDamageMultiplier() return 4 end
    function h:getHitChance() return 50 end
    function h:getAimingPerkHitChanceModifier() return 4 end
    function h:getConditionLowerChance() return 0 end
    function h:getSoundRadius() return 100 end
    function h:getSoundVolume() return 30 end
    function h:getSwingSound() return "M9Shoot" end
    function h:getProjectileCount() return self.name == "Base.Shotgun" and 8 or 1 end
    function h:isTwoHandWeapon() return false end
    function h:getFireModePossibilities() return nil end
    function h:getCurrentAmmoCount() return 10 end
    function h:isRoundChambered() return true end
    function h:getAmmoType() return {getItemKey=function() return "Base.Bullets9mm" end} end
    function h:getMaxAmmo() return 15 end
    function h:haveChamber() return true end
    function h:isRackAfterShoot() return false end
    function h:getMagazineType() return "Base.9mmClip" end
    return h
end
local families = {"Potato","Ballista","Scrapshot","Arc","Lobber","RotaryBat","RotaryBlades","Base.Pistol","Base.Shotgun","Base.HuntingRifle"}
local checks = 0
local coverage={"Head\tModule\tProof"}
for n=1,#families do
    local name, h = families[n], head(families[n])
    for module in pairs(T.MODULES) do
        -- Every compatibility decision and effective stat calculation, including inactive exclusions.
        local supported = Heads.supports(h,module)
        local active = supported and {[module]=1} or {}
        local stats = Stats.resolve({head=h,active=active,powerLoad=supported and 1 or 0})
        check(stats.damage >= 0 and stats.damage == stats.damage and stats.range > 0, "C509 valid "..name.." / "..module)
        checks=checks+1
    end
    local cases={"none"}
    for module in pairs(T.MODULES) do
        if Heads.supports(h,module) then cases[#cases+1]=module end
    end
    for _, module in pairs(cases) do
        local active = module == "none" and {} or {[module]=1}
        local stats = Stats.resolve({head=h,active=active,powerLoad=0})
        local victim, client = pair(module == "Execute" and .1 or 10)
        local before = victim.health
        local options = {stats=stats,damage=stats.damage/100,weapon=h,object=object,critical=false,
            knockdown=0,splash=0,radius=0,impactReady=true,range=stats.range,critMultiplier=stats.critMultiplier}
        local record = {id="turret-c509",shots=serial}
        V.reset(); check(V.reserve(options),"C509 root admitted")
        if name == "Potato" then
            require("OMHTT/PrototypeCombat").hit(record,origin,victim,nil,options)
        elseif name == "Ballista" then
            require("OMHTT/TurretBallista").hit(record,origin,victim,nil,options)
        elseif stats.firearm then
            require("OMHTT/FirearmCombat").hit(record,origin,victim,nil,options)
        elseif name == "Scrapshot" then
            options.scrapId=tostring(serial);options.scrapEligibility={};options.scrapEffects={};options.scrapInjury={}
            require("OMHTT/TurretScrapshot").hit({id=record.id,shot=serial,z=0,damage=options.damage/8,
                group={options=options,stats=stats,primary=true}},victim)
            V.release(options)
        elseif name == "Arc" then
            local job={options=options,seen={},hits=0,damage=options.damage,branch=0,z=0,x=9000.5,y=9000.5,
                anchors={},id=record.id,shot=serial,key=tostring(serial)}
            require("OMHTT/TurretArc").hit(job,victim)
            V.release(options)
        elseif name == "Lobber" then
            local job={landed=true,due=0,x=victim:getX(),y=victim:getY(),z=0,radius=1,children=0,
                scanX=0,scanY=0,index=0,eligible=true,seen={},stats=stats,damage=options.damage,
                shared={x=origin.x,y=origin.y,z=0,remaining=1},source=record.id,shot=serial,id=tostring(serial)}
            require("OMHTT/TurretOrdnance").step(job)
            V.release(options)
        else
            -- Physical contact uses its own reservation rather than the projectile root.
            V.release(options)
            local state={id=record.id,powered=true}
            object.getModData=function() return {OMHTTTurret=state} end
            local job={stats=stats,profile={range=2,heading=0,omni=true,cone=360},detection={range=2,heading=0,cone=360},
                moving=true,at=testMillis,before=-1,after=1}
            Actors.report(victim,{x=victim:getX(),y=victim:getY(),z=victim:getZ(),at=testMillis})
            require("OMHTT/TurretRotary").contact({object=object,hits={{},{}},soundAt=testMillis+1000},victim,job)
        end
        check(client.health == before, "C509 "..name.." waits for owner application")
        check(#out > 0, "C509 "..name.." dispatches "..module)
        settle()
        check(client.health < before and math.abs(victim.health-client.health)<.0011, "C509 "..name.." settles "..module.." server="..victim.health.." client="..client.health.." victim="..serial.." receipt="..receipts[#receipts].message.id.." command="..receipts[#receipts].command)
        check(V.reserved == 0 and Proc.reservedJobs == 0 and Proc.reservedFields == 0, "C509 reservations drain "..name.." / "..module)
        for id,field in pairs(Proc.fields) do Proc.index(field,false) end
        Proc.fields,Proc.fieldOrder,Proc.buckets,Proc.fieldCount,Proc.jobs={},{},{},0,{}
        testResults[#testResults+1] = "C509 "..name.." / "..module..": serialized Apply/Applied + duplicate receipt PASS"
        coverage[#coverage+1]=name.."\t"..module.."\tHit handler + serialized V2 + duplicate receipt (world/transport doubles)"
    end
end
check(checks == #families*36,"C509 complete module catalog count")
do
    local victim,client=pair(.2)
    local stats=Stats.resolve({head=head("Scrapshot"),active={Piercing=1,Siphon=1},powerLoad=0})
    local energy={kills=0,closed=false,synergy=false}
    local options={stats=stats,siphon=energy,scrapId="c509-siphon",scrapEligibility={},scrapEffects={[victim]=true},scrapInjury={}}
    V.reserve(options)
    local group={options=options,stats=stats,primary=true}
    require("OMHTT/TurretScrapshot").hit({id="turret-c509",shot=1,z=0,damage=.3,group=group},victim)
    group.penetrated=true -- The ray advances before the owner's acknowledgement arrives.
    V.release(options);settle()
    check(victim:isDead() and energy.kills==1,"C509 late primary Scrapshot pellet retains Siphon eligibility after piercing advances")
end
do
    local victim,client=pair()
    local stats=Stats.resolve({active={Piercing=1},powerLoad=0})
    local options={stats=stats,damage=1,splash=.2,radius=1}
    V.reserve(options)
    local group={kind="piercing",options=options,stats=stats,hits={},left=2}
    local ray={id="turret-c509",shot=1,x=9000.5,y=9000.5,z=0,dx=1,dy=0,range=6,
        distance=1,bestDistance=1,square=targetSquare,best=victim,damage=1,group=group}
    local combat=require("OMHTT/PrototypeCombat")
    local savedSplash,splash=combat.splash,nil
    combat.splash=function(_,_,_,_,_,value) splash=value.splash end
    V.finish(ray);settle()
    check(math.abs(splash-.2)<.00001,"C509 piercing splash uses the confirmed hit's damage, not the next ray's reduced damage")
    combat.splash=savedSplash;V.release(options)
end
require("tests/C509Traps")({pair=pair,settle=settle,owner=owner,square=targetSquare,origin=origin})
for _,synergy in pairs({false,true}) do
    local targets={}
    for i=1,9 do
        local server,client=pair(10,testSquares[(9000+i)..":9000:0"],i>1)
        targets[i]={server,client}
    end
    local stats=Stats.resolve({head=head("Arc"),active={Splitter=1,Piercing=1,Fragment=1,InitialBlow=1,Synergy=synergy and 1 or nil},powerLoad=0})
    local options={object=object,weapon=head("Arc"),stats=stats,damage=.2,critical=false,range=stats.range}
    check(V.reserve(options),"C509 combined Arc admitted")
    Arc.launch({id="turret-c509",shots=serial},origin,targets[1][1],nil,options)
    settle()
    local hit=0
    for i=1,#targets do
        local server,client=targets[i][1],targets[i][2]
        if client.health<10 then hit=hit+1 end
        check(math.abs(server.health-client.health)<.0011,"C509 Arc chain owner/server agreement")
        Actors.remove(server);server:getSquare().moving={}
    end
    check(hit==9 and V.reserved==0 and Proc.reservedJobs==0 and Proc.reservedFields==0,
        "C509 Arc Splitter/Piercing/Fragment/Initial Blow completes and releases with synergy="..tostring(synergy))
end
local cycle, world = require("OMHTT/ControlCycle"), require("OMHTT/TurretWorld")
local savedWorld={valid=world.valid,contents=world.contents,power=world.power}
world.valid=function() return true end
world.power=function() return {kind="battery"} end
world.contents=function() return {head=head("Arc"),heads=1,active={Firing=1},ammo=0} end
check(cycle.request(object),"C509 trigger accepts ammo-free Arc with zero physical ammunition")
cycle.cancel(object)
world.contents=function() return {head=head("Potato"),heads=1,active={Firing=1},ammo=0} end
check(not cycle.request(object),"C509 empty Potato still cannot start a triggered shot")
world.valid,world.contents,world.power=savedWorld.valid,savedWorld.contents,savedWorld.power
local crowd, losses, rejected, reasons = {}, 0, 0, ""
for i=1,P.MAX_PENDING+1 do
    local server, client=pair()
    crowd[i]={server,client}
    D.resolve(server,.1,"turret-c509-crowd","firearm",function(loss,reason)
        losses=losses+loss
        if loss==0 then rejected=rejected+1;reasons=reasons.." "..tostring(reason) end
    end)
end
settle()
check(rejected==0 and math.abs(losses-(P.MAX_PENDING+1)*.1)<.00001,
    "C509 global in-flight capacity queues admitted damage instead of dropping it; rejected="..rejected..reasons)
-- A crowded field can legitimately apply more than 512 hits during receipt retention.
local victim,client=pair(100)
local total=0
local firstPacket
for i=1,600 do
    D.resolve(victim,.01,"turret-c509-throughput","tack",function(loss) total=total+loss end)
    local packet=table.remove(out,1)
    firstPacket=firstPacket or packet
    check(packet~=nil,"C509 sustained contact admission")
    testMode="client"; C.command(P.MODULE,packet.command,packet.message); C.expire(); testMode="server"
    local receipt=table.remove(incoming,1)
    S.command(P.MODULE,receipt.command,owner,receipt.message)
    testMillis=testMillis+10
end
check(math.abs(total-6)<.00001,"C509 receipt retention must not lose ordinary sustained contact damage; total="..total)
testMode="client";C.command(P.MODULE,firstPacket.command,firstPacket.message);testMode="server"
check(math.abs(client.health-94)<.00001,"C509 superseded receipt still rejects an old duplicate Apply")
incoming={}
for i=1,600 do
    local server,client=pair()
    local loss=0
    D.resolve(server,.1,"turret-c509-distinct","firearm",function(value) loss=value end)
    local packet=table.remove(out,1)
    testMode="client";C.command(P.MODULE,packet.command,packet.message);C.expire();testMode="server"
    local receipt=table.remove(incoming,1)
    S.command(P.MODULE,receipt.command,owner,receipt.message)
    check(math.abs(loss-.1)<.00001,"C509 distinct crowded victims retain safe receipt capacity")
end
testResults[#testResults+1]="C509 compatibility/stat cells="..checks.."; transport receipts="..applied
testC509Summary="heads=10 catalogCells="..checks.." singleModuleHitCases="..(#coverage-1).." allTrapDamagePaths=pass arcCombined=2 capacity=129 sustainedHits=600 distinctVictims=600 liveClients=0"
testC509Matrix=table.concat(coverage,"\n").."\n"
testMode,testMillis, SandboxVars.OMHTurretsTraps=old.mode,old.time,old.settings
sendServerCommand,sendClientCommand,getSpecificPlayer=old.server,old.client,old.player
Clock.now,Effects.emit,Horde.sound,Motion.request=old.clock,old.effects,old.sound,old.motion
ZombRand,OneMoreHordeDefenseIntegration,testSquares=old.random,old.core,old.squares
