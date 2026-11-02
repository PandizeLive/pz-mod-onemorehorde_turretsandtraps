local function mod(name) return require("OMHTT/"..name) end
local Actors, Reports, Contacts = mod("DefenseActors"), mod("DefenseContactServer"), mod("DefenseContacts")
local Damage, Server, Client = mod("Damage"), mod("DefenseCombatServer"), mod("DefenseCombatClient")
local Protocol, Clock, Authority = mod("DefenseCombatProtocol"), mod("TurretClock"), mod("TurretAuthority")
local World, T, Auto, Scheduler = mod("TurretWorld"), mod("Turret"), mod("TurretAutomation"), mod("TurretScheduler")
local Control, Poke, Bed, Barb = mod("ControlWorld"), mod("ControlPoke"), mod("BedSpikes"), mod("BarbSections")
local Tether, Proc = mod("TetherServer"), mod("TurretProc")
local function noop() end
local function yes() return true end
local function fixed(v) return function() return v end end
local legMs=stressLeg or 50
local baseX,baseY = 42000,42000
local function square(x,y) return getCell():getGridSquare(baseX+x,baseY+y,0) end
testMode,testMillis,testRoll="server",98000000,0
SandboxVars.OMHTurretsTraps={Enabled=true,TurretStandbyEnabled=false}
mod("ControlRarity").refresh(SandboxVars.OMHTurretsTraps)
Clock.now=function() return testMillis end
mod("ControlClock").now=Clock.now
OneMoreHordeDefenseIntegration=nil
local owners,actors,mirrors={}, {}, {}
for i=1,2 do owners[i]={getOnlineID=fixed(i+90),isDead=fixed(false)} end
local currentOwner=owners[1]
-- Favor hits and repeat the same target choices to stress damage delivery.
ZombRand=fixed(0)
getSpecificPlayer=function(i) if i==0 then return currentOwner end end
local serverCell=getCell()
serverCell.getZombieList=function() return {size=fixed(#actors),get=function(_,i) return actors[i+1] end} end
getCell=function()
    if testMode=="server" then return serverCell end
    return {getGridSquare=serverCell.getGridSquare,getZombieList=function()
        return {size=fixed(#mirrors),get=function(_,i) return mirrors[i+1] end}
    end}
end
for x=-6,20 do for y=-4,33 do
    local sq=makeSquare(baseX+x,baseY+y,0)
    sq.isSolid,sq.isSolidTrans=fixed(false),fixed(false)
end end
local stats, families, outstanding, peak, reasons = {}, {},0,0,{}
local function register(id,kind)
    families[id]=kind
    stats[kind]=stats[kind] or {attempt=0,applied=0,instances={},shots=0,latency={}}
end
local outgoing,incoming,packets,permits,reported={}, {},0,0,0
local effects=0
sendServerCommand=function(owner,module,command,data)
    if module==Protocol.MODULE then
        outgoing[#outgoing+1]={at=testMillis+legMs,owner=owner,command=command,data=nativeRoundTrip(data)}
        packets=packets+1
    elseif module=="OMHTT_ContactV1" and command=="Permits" then
        permits=permits+#nativeRoundTrip(data)
    else
        nativeRoundTrip(data)
        effects=effects+1
    end
end
sendClientCommand=function(owner,module,command,data)
    if module==Protocol.MODULE then
        incoming[#incoming+1]={at=testMillis+legMs,owner=owner,command=command,data=nativeRoundTrip(data)}
        packets=packets+1
    end
end
local function deliver(list,client)
    while list[1] and list[1].at<=testMillis do
        local p=table.remove(list,1)
        currentOwner=p.owner
        if client then
            testMode="client"
            Client.command(Protocol.MODULE,p.command,p.data)
            testMode="server"
        else Server.command(Protocol.MODULE,p.command,p.owner,p.data) end
    end
end
local request=Damage.resolve
local hp,ownerHitTime,arrivals={},{},{}
Damage.resolve=function(z,amount,id,kind,cb,observation)
    local family=families[id]
    check(family,"untracked damage "..tostring(id).." "..kind)
    local row=stats[family]
    row.attempt=row.attempt+1
    outstanding=outstanding+1
    peak=math.max(peak,outstanding)
    local sent=testMillis
    if stressTrace then
        local lifetime=Protocol.contact(kind) and 500 or Protocol.TIMEOUT
        local at=kind=="rotary" and observation and observation.at or sent
        arrivals[#arrivals+1]=table.concat({z:getOnlineID(),sent,math.min(sent,at)+lifetime},",")
    end
    return request(z,amount,id,kind,function(loss,reason)
        outstanding=outstanding-1
        if loss>0 then
            row.applied=row.applied+1
            row.instances[id]=true
            row.latency[#row.latency+1]=testMillis-sent
            row.ownerLatency=row.ownerLatency or {}
            check(ownerHitTime[z] and ownerHitTime[z]>=sent,"missing owner health application")
            row.ownerLatency[#row.ownerLatency+1]=ownerHitTime[z]-sent
            hp[z]=(hp[z] or 0)+loss
        else reasons[reason or "unspecified"]=(reasons[reason or "unspecified"] or 0)+1 end
        if cb then cb(loss,reason) end
    end,observation)
end
local function objectAt(x,y,id)
    local sq=square(x,y)
    local o=IsoObject.new(sq,"fixture",id)
    sq:AddTileObject(o)
    o.health=10000
    o.getHealth=function(self) return self.health end
    o.setHealth=function(self,h) self.health=h end
    o.sync=noop
    o.getContainer=fixed(nil)
    return o
end
local objects,barriers,tethers,plates={}, {}, {}, {}
local fixtureStates={}
Control.state=function(o) return fixtureStates[o] end
local function stateFor(o,id,kind)
    local sq=o:getSquare()
    local s={id=id,kind=kind,x=sq:getX(),y=sq:getY(),z=0,recoverAt=0,placed=true,links={},facing="w"}
    fixtureStates[o],Control.objects[id],Control.records().records[id]=s,o,s
    return s
end
Control.publish,Control.plateSprite,Poke.visual=noop,noop,noop
mod("ControlPower").trigger=yes
mod("ControlPower").flush=noop
mod("ControlAudio").emit=noop
for i=1,2 do
    local p=owners[i]
    local observerSquare=makeSquare(baseX-40,baseY+i,0)
    p.kind,p.getX,p.getY,p.getZ,p.getSquare="IsoPlayer",fixed(baseX-39.5),fixed(baseY+i+.5),fixed(0),fixed(observerSquare)
    p.getUsername=fixed("observer-"..i)
    p.getWidth=fixed(.3)
    p.isGodMod,p.isNoClip,p.isGhostMode=fixed(false),fixed(false),fixed(false)
end
getOnlinePlayers=function() return {size=fixed(2),get=function(_,i) return owners[i+1] end} end
mod("DefenseHorde").sound=noop
mod("DefenseMotion").request=fixed(false)
mod("TetherMount").supported=yes
mod("TetherMount").resolve=function(x,y,z)
    return {x=x+.5,y=y+.5,z=z,dx=-1,dy=0,north=false},{getObjectIndex=fixed(0)}
end
Tether.publish=noop
Bed.parts=function(r) return {objects[r.id]} end
Barb.resolve=function(r) return objects[r.id],objects[r.id],r.attachment,"active" end
Barb.publishWire,mod("BarbSupport").publish=noop,noop
mod("BarbSupport").edge=function(o,north,side,g)
    local sq=o:getSquare()
    g.x,g.y,g.z,g.north,g.side,g.contact=sq:getX(),sq:getY(),0,false,1,true
    return g
end
mod("BarrierFootprint").exact=function(o) return barriers[o] end
local function addHazard(lane,kind,x)
    local y=(lane-1)*3
    local id=kind.."-"..lane
    register(id,kind)
    local o=objectAt(x,y,id)
    objects[id]=o
    local r=stateFor(o,id,kind)
    local key=mod("Foundation").key(r.x,r.y,0)
    if kind=="Poke" then Poke.register(o,r)
    elseif kind=="Bed" or kind=="BedReinforced" then
        r.tier=kind=="Bed" and "normal" or "reinforced"
        r.health=10000
        o.data.OMHTTBed={view={}}
        Bed.count=Bed.count+1
        Bed.store.records[id],Bed.tiles[key],Bed.nearby[key]=r,id,true
        Contacts.watch(r,"bed",r.x,r.y,r.x,r.y,0)
    elseif kind=="Wire" or kind=="Panel" then
        r.kind=kind=="Wire" and "wire" or "panel"
        r.paired,r.north,r.side=kind=="Wire",false,1
        r.attachment={health=10000}
        Barb.order[#Barb.order+1]=id
        Barb.nodes[id],Barb.nearby[key]={record=r},{[id]=true}
        Contacts.watch(r,"barb",r.x,r.y,r.x,r.y,0)
    elseif kind=="Barrier" or kind=="BarrierReinforced" then
        r.tier=kind=="Barrier" and "normal" or "reinforced"
        r.facing,r.width=0,2
        o.data.OMHTTEdge={x=r.x,y=r.y,tx=r.x,ty=r.y+1,nx=1,ny=0,role="front"}
        barriers[o]=r
    elseif kind=="Tack" then
        local field={id=id,source=id,x=r.x+.5,y=r.y+.5,z=0,radius=.65,starts=testMillis,expires=testMillis+90000,damage=10}
        Proc.fields[id],Proc.fieldCount=field,Proc.fieldCount+1
        Proc.index(field,true)
    elseif kind=="Tether" then
        tethers[lane]=o
        Tether.entry(o,r)
    end
end
for lane=1,10 do
    for i,kind in pairs({"Poke","Bed","BedReinforced","Wire","Panel","Barrier","BarrierReinforced","Tack","Tether"}) do
        addHazard(lane,kind,({0,3,4,5,7,8,9,10,12})[i])
    end
end
for i=1,2 do
local o=objectAt(2,(i-1)*3,"plate-"..i)
    local s=stateFor(o,"plate-"..i,"Plate")
    local target=fixtureStates[tethers[i]]
    s.links[1]=target.id
    Control.incoming[target.id]={[s.id]=true}
    plates[i]={object=o,changes=0}
end
Control.order,Control.cursor={},1
for id,o in pairs(objects) do
    local kind=fixtureStates[o].kind
    if kind=="Poke" or kind=="Tether" then Control.order[#Control.order+1]=id end
end
for i=1,2 do Control.order[#Control.order+1]=fixtureStates[plates[i].object].id end
table.sort(Control.order)
Client.reset()
for i=1,100 do
    local sq=square(0,3*math.floor((i-1)/10))
    local function actor()
        local z=makeZombie(sq,1000)
        z.onlineId,z.outfitId,z.owner=18000+i,18000+i,owners[1+(i-1)%2]
        z.isOnDeathDone=fixed(false)
        z.getWidth=fixed(.3)
        z.getX=function(self) return self.xx or self.square:getX()+.5 end
        z.getY=function(self) return self.yy or self.square:getY()+.5 end
        return z
    end
    local z,m=actor(),actor()
    Actors.remove(m)
    actors[i],mirrors[i]=z,m
    local set=m.setHealth
    m.setHealth=function(self,v) ownerHitTime[z]=testMillis;set(self,v) end
    currentOwner=z.owner
    testMode="client";Client.created(m);testMode="server"
    Server.created(z);Actors.observe(z)
    sq.moving={}
end
local snapshots,byStorage,heads={}, {}, {}
World.contents=function(o) return snapshots[o] end
T.contents=function(c) return byStorage[c] end
World.valid=yes
World.power=fixed({kind="fixture",cost=0})
World.queueRefresh,Authority.publish,mod("TurretItemState").publish=noop,noop,noop
T.cycle=function(c,now) return c.cycle,now>=c.cycle.nextShot and "Ready" or "Cooling" end
local Feed=mod("TurretFeed")
Feed.consume=function(c,s,cycle,now) cycle.nextShot=now+s.cooldown; return true,1 end
Feed.descriptor=function(c) if c.payloadType then return {type=c.payloadType,multiplier=1} end end
Auto.entries,Auto.order,Auto.cursor={}, {},1
local function addHead(name,itemType,x,y,gun,payload)
    local o=objectAt(x,y,name)
    local item=instanceItem("Base."..itemType)
    local active={Firing=1,MotionDetection=1,FiringEnhanced=1,MotionDetectionEnhanced=1,Detection360=1}
    if gun then
        local auto=gun=="auto"
        local profiles=mod("Firearms").PROFILES
        local p=profiles["Base."..itemType] or {reload=2.7,rack=1.2}
        profiles["Base."..itemType]=p
        p.muzzle=p.muzzle or .25
        item.getMinDamage,item.getMaxDamage=fixed(1),fixed(2.75)
        item.getRecoilDelay,item.getMaxAmmo,item.getMaxRange=fixed(25),fixed(30),fixed(25)
        item.getHitChance,item.getAimingPerkHitChanceModifier=fixed(50),fixed(7)
        item.getProjectileCount=fixed(gun=="shotgun" and 6 or 1)
        item.getCriticalChance,item.getCriticalDamageMultiplier=fixed(20),fixed(4)
        item.getCyclicRateMultiplier,item.getFireMode=fixed(1),fixed(auto and "Auto" or "Single")
        item.isRackAfterShoot,item.isTwoHandWeapon=fixed(false),fixed(gun~="pistol")
        item.getMagazineType,item.getScriptItem=fixed("Base.556Clip"),fixed(item)
        item.getFireModePossibilities=fixed(nil)
        item.getWeaponReloadType=fixed(gun=="shotgun" and "shotgun" or "boltaction")
        item.getConditionLowerChance,item.getSoundRadius,item.getSoundVolume=fixed(0),fixed(100),fixed(30)
        item.getSwingSound,item.getCurrentAmmoCount,item.isRoundChambered=fixed("fixture"),fixed(29),yes
    end
    if name=="M16" then active.Splitter=6 end
    local c={head=item,heads=1,powerLoad=0,active=active,ammo=100,round=item,payloadType=payload,
        cycle={loaded=30,nextShot=0}}
    local storage={contains=yes}
    o.getContainer=fixed(storage)
    snapshots[o],byStorage[storage]=c,c
    check(Authority.register(o,{id=name,kind="potato",powered=true,schema=1,standby="active",facingDegrees=0,aimDegrees=0,baseFacing=0,shots=0,nextShot=0}),"register "..name)
    register(name,name)
    Auto.changed(o,item)
    heads[#heads+1]={name=name,object=o}
end
addHead("RotaryBat","OMHTTTurretRotaryBat",4,11)
addHead("RotaryBlades","OMHTTTurretRotaryBlades",4,14)
addHead("Potato","OMHTTTurretPotato",4,17)
addHead("Ballista","OMHTTTurretBallista",5,17)
addHead("Arc","OMHTTTurretArc",6,17)
addHead("Scrapshot","OMHTTTurretScrapshot",7,17)
addHead("LobberMakeshift","OMHTTTurretLobber",1,14,nil,"Base.OMHTTAmmoMakeshiftBomb")
addHead("LobberAerosol","OMHTTTurretLobber",1,17,nil,"Base.Aerosolbomb")
addHead("LobberPipe","OMHTTTurretLobber",1,20,nil,"Base.PipeBomb")
addHead("M16","AssaultRifle",2,14,"auto")
addHead("M4","M4",2,17,"auto")
addHead("Pistol","Pistol",2,20,"pistol")
addHead("Shotgun","Shotgun",3,14,"shotgun")
addHead("HuntingRifle","HuntingRifle",3,17,"rifle")
local timings={server={},reports={},barriers={},devices={},transport={},client={}}
local function sample(name,t) timings[name][#timings[name]+1]=realMillis()-t end
local function pct(v,p) if #v==0 then return 0 end; table.sort(v); return v[math.ceil(#v*p)] end
local starting=testMillis
Poke.time,Tether.time=starting,starting
for i=1,10 do Tether.entries[tethers[i]].time=starting end
testTime=100
mod("ActiveTime").step(Poke.clock)
mod("ActiveTime").step(Tether.clock)
local marker={}
local barrierReads,barrierMessages,inBarrier=0,0,false
local near=Actors.at
Actors.at=function(sq)
    if inBarrier then barrierReads=barrierReads+1 end
    return near(sq)
end
local wire=mod("BarrierRetaliation")
local function scan(tick,frames)
    for i=1,100 do
        local lane=math.floor((i-1)/10)
        local function path(t)
            local phase=((i-1)%10*2.4+t*.16)%24
            return .08+math.min(phase,24-phase)
        end
        local x=path(tick-legMs/50)
        local live=path(tick)
        local xx,yy=baseX+live,baseY+lane*3+.5
        local sq=square(math.floor(live),lane*3)
        local z,m=actors[i],mirrors[i]
        z.xx,z.yy,z.square,m.xx,m.yy,m.square=xx,yy,sq,xx,yy,sq
        local bed=math.floor(x)==3 or math.floor(x)==4
        local down=bed and x%1>.45 and x%1<.86
        frames[1+(i-1)%2][#frames[1+(i-1)%2]+1]={id=z.onlineId,outfit=z.outfitId,x=baseX+x,y=yy,z=0,age=0,
            observedAt=testMillis-legMs,sequence=tick+1,prone=down,down=down,landing=down and not z.floor}
        z.floor,m.floor=down,down
    end
end
local function sendFrames(frames)
    for n=1,2 do
        for j=1,#frames[n],32 do
            local packet={}
            for k=j,math.min(#frames[n],j+31) do packet[#packet+1]=frames[n][k] end
            Reports.command("OMHTT_ContactV1","Observe",owners[n],nativeRoundTrip(packet))
            reported=reported+#packet
        end
    end
end
local barrierPackets={}
local function strikes(tick)
    for i=1,100 do
        local z=actors[i]
        local x=z.square:getX()-baseX
        if (x==8 or x==9) and (tick+i)%6==0 then
            local kind=x==8 and "Barrier" or "BarrierReinforced"
            local id=kind.."-"..(math.floor((i-1)/10)+1)
            marker[i]=not marker[i]
            barrierPackets[#barrierPackets+1]={at=testMillis+legMs,owner=z.owner,data=nativeRoundTrip({id=z.onlineId,outfit=z.outfitId,barrier=id,
                x=z.square:getX(),y=z.square:getY(),z=0,index=0,token=marker[i] and "left" or "right"})}
        end
    end
end
local jobs={}
for i=1,#Scheduler.workers do
    local w=Scheduler.workers[i]
    -- Fixtures cover active combat workers; no stale devices from the preceding validation suite.
    if w.name=="A.tick" or w.name=="Aim.tick" or w.name=="TurretVolley.tick" or w.name=="TurretArc.tick" or w.name=="Ordnance.tick" or string.find(w.name,"Flight") then
        jobs[#jobs+1]=w
    end
end
Scheduler.workers,Scheduler.cursor=jobs,1
local updates=Control.updateInput
Control.updateInput=function(o,...)
    local s=fixtureStates[o]
    local old=s and s.active
    updates(o,...)
    for i=1,2 do
        if o==plates[i].object and s.active~=old then plates[i].changes=plates[i].changes+1 end
    end
end
local workNames={}
for i=1,#jobs do workNames[i]=jobs[i].name end
local budgetStart
local function now() return testMillis+math.floor(realMillis()-budgetStart) end
local function beginBudget() budgetStart=realMillis(); getTimestampMs=now end
local function endBudget() getTimestampMs=Clock.now end
for tick=1,400 do
    testMillis=starting+tick*50
    testTime=100+tick*50/150000
    local frames={{},{}}
    if tick%2==0 then scan(tick,frames) end
    local started=realMillis()
    beginBudget()
    deliver(incoming,false)
    Damage.tick();Server.tick()
    sample("transport",started)
    Bed.time,Barb.time=testMillis,testMillis
    local t=realMillis()
    if tick%2==0 then sendFrames(frames) end
    sample("reports",t)
    t=realMillis()
    if tick%2==0 then strikes(tick) end
    while barrierPackets[1] and barrierPackets[1].at<=testMillis do
        local p=table.remove(barrierPackets,1)
        inBarrier=true
        barrierMessages=barrierMessages+1
        wire.command("OMHTT_BarrierContact","Strike",p.owner,p.data)
        inBarrier=false
    end
    sample("barriers",t)
    t=realMillis()
    Control.tick()
    Tether.advance()
    Scheduler.tick()
    sample("devices",t)
    endBudget()
    sample("server",started)
    t=realMillis()
    deliver(outgoing,true)
    sample("client",t)
end
local tail={flights=#mod("PrototypeCombat").pending,rays=#mod("TurretVolley").queue,ordnance=#mod("TurretOrdnance").jobs,damage=outstanding}
for tick=1,200 do
    testMillis=testMillis+50
    deliver(incoming,false);Damage.tick();Server.tick();deliver(outgoing,true)
end
check(outstanding==0 and #outgoing==0 and #incoming==0,"damage did not settle")
for i=1,100 do
    local z=actors[i]
    check(math.abs(z.health-(1000-(hp[z] or 0)))<.00001 and math.abs(z.health-mirrors[i].health)<.00001,"health mismatch "..i)
end
for i=1,#heads do local h=heads[i];stats[h.name].shots=T.state(h.object).shots end
local rows={"workers "..table.concat(workNames,","),"barriers "..barrierMessages.." "..barrierReads}
for name,n in pairs(tail) do rows[#rows+1]="cutoff "..name.." "..n end

for kind,row in pairs(stats) do
    local n=0
    for id in pairs(row.instances) do n=n+1 end
    check(row.applied>0 and (not objects[kind.."-1"] or n==10),"incomplete hit coverage "..kind.." "..n)
    rows[#rows+1]=string.format("family %s %d %d %d %d %.0f %.0f %.0f",kind,row.shots,row.attempt,row.applied,n,pct(row.latency,.5),pct(row.latency,.95),pct(row.ownerLatency,.95))
end
for kind,v in pairs(timings) do rows[#rows+1]=string.format("ms %s %.2f %.2f %.2f",kind,pct(v,.5),pct(v,.95),pct(v,1)) end
for kind,n in pairs(reasons) do rows[#rows+1]="failure "..kind.." "..n end
check(plates[1].changes>2 and plates[2].changes>2,"inactive pressure plate")
rows[#rows+1]="traffic "..reported.." "..permits.." "..packets.." peak "..peak.." plates "..plates[1].changes.." "..plates[2].changes.." observerPackets "..effects
if stressTrace then rows[#rows+1]="arrivals "..table.concat(arrivals," ") end
table.sort(rows)
testPackAudit="C549\n"..table.concat(rows,"\n").."\nEND C549"
