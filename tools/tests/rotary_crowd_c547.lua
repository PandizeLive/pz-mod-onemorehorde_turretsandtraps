-- Optional performance probe. Run after the regular Kahlua suite in its own JVM.
local Actors = require("OMHTT/DefenseActors")
local Reports = require("OMHTT/DefenseContactServer")
local Server = require("OMHTT/DefenseCombatServer")
local Client = require("OMHTT/DefenseCombatClient")
local Protocol = require("OMHTT/DefenseCombatProtocol")
local Damage = require("OMHTT/Damage")
local Automation = require("OMHTT/TurretAutomation")
local Authority = require("OMHTT/TurretAuthority")
local Index = require("OMHTT/TurretRotaryContacts")
local Standby = require("OMHTT/TurretStandby")
local Clock = require("OMHTT/TurretClock")
local World = require("OMHTT/TurretWorld")
local T = require("OMHTT/Turret")
local originalResolve, originalRequest = Damage.resolve, Damage.request
local diagnostics = require("OMHTT/Diagnostics")
local originalMeasure = diagnostics.measure
local owner = {getOnlineID=function() return 94 end, isDead=function() return false end}
local contents, clients, outgoing, incoming = {}, {}, {}, {}
local originalCell = getCell
local directions = {{0,-1},{0,1},{-1,0},{1,0},{-1,-1},{1,1},{-1,1},{1,-1}}
local warmup, samples = 24, 120
local rows, serial = {}, 0
local function noop() end

testMode, testMillis = "server", 94000000
SandboxVars.OMHTurretsTraps.EnhancedFireMultiplier = 4/3
SandboxVars.OMHTurretsTraps.TurretStandbyEnabled = false
Clock.now = function() return testMillis end
Actors.refresh = noop
World.contents = function(obj) return contents[obj] end
World.valid = function(obj) return obj:getObjectIndex() >= 0 end
World.power = function() return {kind="fixture",cost=0} end
Authority.publish = noop
require("OMHTT/ControlAudio").emit = noop
require("OMHTT/DefenseEffects").emit = noop
require("OMHTT/DefenseHorde").sound = noop
require("OMHTT/DefenseMotion").request = function() return false end
require("OMHTT/ControlCycle").managed = function() return false end
OneMoreHordeDefenseIntegration = nil
getSpecificPlayer = function(i) if i == 0 then return owner end end
getCell = function()
    if testMode ~= "client" then return originalCell() end
    return {getZombieList=function() return {size=function() return #clients end,
        get=function(_,i) return clients[i+1] end} end,
        getGridSquare=function(_,x,y,z) return originalCell():getGridSquare(x,y,z) end}
end
sendServerCommand = function(_,module,command,payload)
    if module == Protocol.MODULE then outgoing[#outgoing+1] = {command,nativeRoundTrip(payload)} end
end
sendClientCommand = function(_,module,command,payload)
    if module == Protocol.MODULE then incoming[#incoming+1] = {command,nativeRoundTrip(payload)} end
end
local function q(values,p)
    table.sort(values)
    return values[math.ceil(#values*p)]
end
local function point(id,tick)
    local angle = math.rad(id*11.137 + tick*6.027)
    local radius = .31 + (id%7)*.035
    return radius*math.cos(angle), radius*math.sin(angle)
end
local function run(count,transport,servicePasses)
    servicePasses = servicePasses or 1
    serial=serial+1
    local base=94000000+serial*100000
    testMillis=base-500
    local x,y=41000+serial*12,41000
    for dx=-3,3 do for dy=-3,3 do makeSquare(x+dx,y+dy,0) end end
    Automation.entries,Automation.order,Automation.cursor={},{},1
    local devices,sourceMap,actors,slot={}, {}, {}, {}
    local frameHits, attempts, successes, failures, measured = {}, 0, 0, {}, false
    local succeededByActor={}
    outgoing,incoming,clients={},{},{}
    Client.reset()
    for n=1,count do
        local d=directions[n]
        local square=getCell():getGridSquare(x+d[1],y+d[2],0)
        local obj=IsoObject.new(square,"test","test")
        square:AddTileObject(obj)
        local name="turret-c547-"..serial.."-"..n
        local heading=17.37+n*11.83
        Authority.register(obj,{schema=1,id=name,powered=true,standby="active",facingDegrees=heading})
        local head=instanceItem("Base.OMHTTTurretRotaryBlades")
        contents[obj]={head=head,heads=1,powerLoad=0,active={MotionDetection=1,MotionDetectionEnhanced=1,
            Firing=1,FiringEnhanced=1,Detection360=1}}
        Automation.changed(obj,head)
        local entry=Automation.entries[obj]
        entry.soundAt=math.huge
        devices[n]={object=obj,entry=entry,heading=heading,expected=0,missed=0,extra=0,applied=0,admitted=0}
        sourceMap[name]=n
    end
    local center=getCell():getGridSquare(x,y,0)
    for i=1,32 do
        local id=12000+serial*40+i
        local function actor()
            local z=makeZombie(center,1000)
            z.onlineId,z.outfitId,z.owner=id,id,owner
            z.isOnDeathDone=function() return false end
            return z
        end
        local z=actor()
        local mirror=actor()
        Actors.remove(mirror)
        clients[i],actors[i],slot[z],succeededByActor[z]=mirror,z,i,0
        testMode="client";Client.created(mirror);testMode="server"
        Server.created(z);Actors.observe(z)
    end
    local expiredDispatch, failedImmediately, queueMs, wireSends, warmSuccess = 0,0,{},0,0
    local maxOutstanding, outstanding = 0,0
    diagnostics.measure=function(name,value,component)
        if measured and name=="damage-queue" then queueMs[#queueMs+1]=value end
        return originalMeasure(name,value,component)
    end
    Damage.request=function(z,amount,source,kind,callback,expires,observation)
        if measured and expires and expires<GameTime.getServerTimeMills() then expiredDispatch=expiredDispatch+1 end
        return originalRequest(z,amount,source,kind,callback,expires,observation)
    end
    Damage.resolve=function(z,amount,source,kind,callback,obs)
        local n=sourceMap[source]
        check(n and slot[z] and kind=="rotary" and math.abs(amount-.4)<1e-7,"unexpected rotary damage source or amount")
        local key=n*100+slot[z]
        local record=measured
        if record then
            frameHits[key]=(frameHits[key] or 0)+1
            attempts=attempts+1
            devices[n].admitted=devices[n].admitted+1
        end
        outstanding=outstanding+1
        if measured then maxOutstanding=math.max(maxOutstanding,outstanding) end
        local function result(loss,reason)
            outstanding=outstanding-1
            if loss>0 then
                succeededByActor[z]=succeededByActor[z]+1
                if record then successes=successes+1;devices[n].applied=devices[n].applied+1 else warmSuccess=warmSuccess+1 end
            elseif record then failures[reason]=(failures[reason] or 0)+1 end
            callback(loss,reason)
        end
        if transport then
            local accepted=originalResolve(z,amount,source,kind,result,obs)
            if record and not accepted then failedImmediately=failedImmediately+1 end
            return accepted
        end
        result(amount,"applied")
        return true
    end
    local function replies()
        for i=1,#incoming do Server.command(Protocol.MODULE,incoming[i][1],owner,incoming[i][2]) end
        incoming={}
        for pass=1,servicePasses do Damage.tick() end
        Server.tick()
    end
    local function deliver()
        testMode="client"
        Client.expire()
        if measured then wireSends=wireSends+#outgoing end
        for i=1,#outgoing do Client.command(Protocol.MODULE,outgoing[i][1],outgoing[i][2]) end
        outgoing={}
        testMode="server"
    end
    local packets,serverTimes={},{}
    local expected=0
    for tick=0,warmup+samples do
        testMillis=base+tick*100
        measured=tick>warmup
        frameHits={}
        local frames={}
        for i=1,32 do
            local east,north=point(i,tick)
            local xx,yy=x+.5+east,y+.5-north
            local square=getCell():getGridSquare(math.floor(xx),math.floor(yy),0)
            actors[i].square,clients[i].square=square,square
            frames[i]={id=actors[i].onlineId,outfit=actors[i].outfitId,x=xx,y=yy,z=0,
                age=0,observedAt=testMillis-65,sequence=tick+1,prone=false,down=false,landing=false}
        end
        local started=realMillis()
        if transport then replies() end
        local packetStart=realMillis()
        Reports.command("OMHTT_ContactV1","Observe",owner,frames)
        local packetEnd=realMillis()
        Automation.tick()
        local stop=realMillis()
        if measured then
            packets[#packets+1]=packetEnd-packetStart
            serverTimes[#serverTimes+1]=stop-started
        end
        for n=1,count do
            local d,device=directions[n],devices[n]
            local travel=device.entry.travel
            if measured then
                check(device.entry.hasTarget and math.abs(travel-device.prior-20)<1e-6,"motor cadence")
                for i=1,32 do
                    local x0,y0=point(i,tick-1)
                    local x1,y1=point(i,tick)
                    -- Target bearing advances less than the motor over this bounded path.
                    local b0=math.deg(math.atan2(y0+d[2],x0-d[1]))
                    local b1=math.deg(math.atan2(y1+d[2],x1-d[1]))
                    local delta=(b1-b0+540)%360-180
                    local phase=device.prior-13+device.heading-b0
                    local want=math.floor((phase+20-delta)/180)-math.floor(phase/180)
                    check(want==0 or want==1,"reference crossing interval")
                    local got=frameHits[n*100+i] or 0
                    expected=expected+want
                    device.expected=device.expected+want
                    device.missed=device.missed+math.max(0,want-got)
                    device.extra=device.extra+math.max(0,got-want)
                end
            end
            device.prior=travel
        end
        testMillis=testMillis+50
        if transport then deliver() end
    end
    measured=false
    for i=1,60 do
        testMillis=testMillis+50
        if transport then replies() end
        testMillis=testMillis+50
        if transport then deliver() end
    end
    local missed,extra,rejected,byDevice,reasonText=0,0,0,{},{}
    for n=1,count do
        local d=devices[n]
        missed,extra=missed+d.missed,extra+d.extra
        byDevice[n]=d.expected.."/"..d.admitted.."/"..d.applied.."/"..d.missed.."/"..d.extra
        Index.remove(d.object);Standby.entries[d.object]=nil;contents[d.object]=nil
    end
    for reason,value in pairs(failures) do rejected=rejected+value;reasonText[#reasonText+1]=reason.."="..value end
    check(successes+rejected==attempts and #incoming==0 and #outgoing==0,"unsettled attempts")
    for i=1,32 do
        if transport then
            local hp=1000-succeededByActor[actors[i]]*.4
            check(math.abs(actors[i].health-hp)<1e-6 and math.abs(clients[i].health-hp)<1e-6,"end health")
        end
        Actors.remove(actors[i])
    end
    table.sort(reasonText)
    rows[#rows+1]=table.concat({transport and (servicePasses==1 and "wire" or "wire4x") or "contact",count,expected,attempts,successes,missed,extra,
        q(packets,.5),q(packets,.95),q(packets,1),q(serverTimes,.95),table.concat(byDevice,","),table.concat(reasonText,","),expiredDispatch,failedImmediately,maxOutstanding,
        #queueMs>0 and q(queueMs,.95) or 0,wireSends,warmSuccess},"|")
end
for _,transport in pairs({false,true}) do
    for _,count in pairs({1,2,4,6,8}) do run(count,transport) end
end
run(8,true,4)
testPackAudit="C547\n"..table.concat(rows,"\n").."\nEND C547"
