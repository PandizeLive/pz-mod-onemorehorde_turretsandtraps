local function run(ctx)
    local W=require("OMHTT/ControlWorld")
    local R=require("OMHTT/DefenseContacts")
    local Reports=require("OMHTT/DefenseContactServer")
    local P=require("OMHTT/ControlPoke")
    local Audio=require("OMHTT/ControlAudio")
    local Effects=require("OMHTT/DefenseEffects")
    local old={state=W.state,publish=W.publish,visual=P.visual,audio=Audio.emit,contact=Effects.contact,time=P.time}
    W.publish,P.visual,Audio.emit,Effects.contact=function() end,function() end,function() end,function() end
    local state={id="c509-poke",kind="Poke",x=9001,y=9000,z=0}
    local data={OMHTTBed={view={}}}
    local object={health=200,getSquare=function() return ctx.square end,getObjectIndex=function() return 0 end,
        getHealth=function(self) return self.health end,setHealth=function(self,n) self.health=n end,
        sync=function() end,transmitModData=function() end,getModData=function() return data end}
    W.state=function(value) if value==object then return state end return old.state(value) end
    local sequence=0
    local function report(actor,landing)
        sequence=sequence+1; testMillis=testMillis+1
        Reports.command("OMHTT_ContactV1","Observe",ctx.owner,{{id=actor:getOnlineID(),outfit=actor:getPersistentOutfitID(),
            x=actor:getX(),y=actor:getY(),z=0,age=0,observedAt=testMillis,sequence=sequence,
            prone=landing==true,down=landing==true,landing=landing==true}})
    end
    P.time=0;P.register(object,state)
    local server,client=ctx.pair()
    report(server);ctx.settle()
    check(math.abs(client.health-9.55)<.00001 and object.health==199,"C509 Poke owner report -> damage -> confirmed wear")
    report(server);ctx.settle()
    check(math.abs(client.health-9.55)<.00001,"C509 same Poke stroke has no repeated damage")
    P.entries[object],P.objects["9001:9000:0"]=nil,nil;R.remove(object)
    P.visual,P.time=old.visual,old.time

    local B=require("OMHTT/BedSpikes")
    local bs={count=B.count,store=B.store,tiles=B.tiles,nearby=B.nearby,parts=B.parts,time=B.time}
    B.parts=function() return {object} end
    for _,tier in pairs({"normal","reinforced"}) do
        local record={id="c509-bed-"..tier,tier=tier,health=100,x=9001,y=9000,z=0}
        B.count,B.store,B.tiles,B.nearby=1,{records={[record.id]=record}},{["9001:9000:0"]=record.id},{["9001:9000:0"]=true}
        R.watch(record,"bed",9001,9000,9001,9000,0)
        server,client=ctx.pair();report(server);report(server,true);ctx.settle()
        check(math.abs(client.health-(tier=="normal" and 9.8 or 9.5))<.00001 and record.health==94,
            "C509 "..tier.." Bed landing report settles damage and wear once")
        R.remove(record)
    end
    B.count,B.store,B.tiles,B.nearby,B.parts,B.time=bs.count,bs.store,bs.tiles,bs.nearby,bs.parts,bs.time

    local Barbs=require("OMHTT/BarbSections")
    local Support=require("OMHTT/BarbSupport")
    local saved={order=Barbs.order,nodes=Barbs.nodes,nearby=Barbs.nearby,resolve=Barbs.resolve,
        publish=Barbs.publishWire,edge=Support.edge,publishSupport=Support.publish}
    Barbs.publishWire,Support.publish=function() end,function() end
    -- Native support discovery is covered separately; retain real face contact geometry here.
    Support.edge=function(_,north,side,geometry)
        geometry.x,geometry.y,geometry.z,geometry.north,geometry.side,geometry.contact=9001.25,9000,0,false,1,true
        return geometry
    end
    for _,kind in pairs({"wire","panel"}) do
        local record={id="c509-"..kind,kind=kind,x=9001,y=9000,z=0,paired=false,north=false,side=1}
        local attachment={health=50}
        Barbs.order,Barbs.nodes,Barbs.nearby={record.id},{[record.id]={record=record}},{["9001:9000:0"]={[record.id]=true}}
        Barbs.resolve=function() return object,object,attachment,"active" end
        R.watch(record,"barb",9001,9000,9001,9000,0)
        server,client=ctx.pair();report(server);ctx.settle()
        check(math.abs(client.health-9.9)<.00001 and attachment.health==49,"C509 "..kind.." contact confirms damage and wear")
        R.remove(record)
    end
    Barbs.order,Barbs.nodes,Barbs.nearby,Barbs.resolve,Barbs.publishWire=saved.order,saved.nodes,saved.nearby,saved.resolve,saved.publish
    Support.edge,Support.publish=saved.edge,saved.publishSupport

    local E=require("OMHTT/TurretProc")
    local field={id="c509-tack",x=9001.5,y=9000.5,z=0,radius=1,starts=0,expires=testMillis+10000,damage=10,source="turret-c509"}
    E.fields[field.id]=field;E.fieldCount=1;E.index(field,true)
    server,client=ctx.pair();report(server);ctx.settle()
    check(math.abs(client.health-9.9)<.00001,"C509 Tack report applies damage through owner")
    E.index(field,false);E.fields[field.id]=nil;E.fieldCount=0

    local Barrier=require("OMHTT/BarrierRetaliation")
    local Footprint=require("OMHTT/BarrierFootprint")
    local exact,face=Footprint.exact,Barrier.face
    Footprint.exact=function(value) if value==object then return {id="c509-barrier",tier="normal"} end end
    Barrier.face=function() return "front" end
    ctx.square.objects={object}
    server,client=ctx.pair();server.state="thump"
    local message={id=server:getOnlineID(),outfit=server:getPersistentOutfitID(),barrier="c509-barrier",
        x=9001,y=9000,z=0,index=0,token="left"}
    Barrier.command("OMHTT_BarrierContact","Strike",ctx.owner,message);ctx.settle()
    check(client.health<10,"C509 Spike Barrier marker confirms owner damage")
    local health=client.health
    Barrier.command("OMHTT_BarrierContact","Strike",ctx.owner,message);ctx.settle()
    check(client.health==health,"C509 Spike Barrier duplicate marker cannot damage twice")
    local observer = require("OMHTT/BarrierContact")
    local views = require("OMHTT/BarrierView")
    local view, send, localPlayer = views.exact, sendClientCommand, ctx.owner.isLocalPlayer
    views.exact = Footprint.exact
    ctx.owner.isLocalPlayer = function() return true end
    local reports = 0
    sendClientCommand = function(player, module, command, payload)
        if module == "OMHTT_BarrierContact" then
            reports = reports + 1
            testMode = "server"
            Barrier.command(module, command, player, nativeRoundTrip(payload))
            testMode = "client"
        else
            send(player, module, command, payload)
        end
    end
    server, client = ctx.pair()
    server.state, client.state, client.thumpTarget = "thump", "ThumpState", object
    testMode = "client"
    observer.update(client)
    check(client.variables.ThumpType == "OMHTTBarrierClaw", "C512 client selects barrier strike animation")
    client.variables.OMHTTBarrierStrike = "left"
    observer.update(client)
    testMode = "server"
    ctx.settle()
    check(reports == 1 and client.health < 10, "C512 client marker reaches server and confirms owner damage")
    health = client.health
    testMode = "client"
    observer.update(client)
    testMode = "server"
    ctx.settle()
    check(reports == 1 and client.health == health, "C512 unchanged client marker cannot repeat damage")
    testMillis = testMillis + 250
    testMode = "client"
    client.variables.OMHTTBarrierStrike = "right"
    observer.update(client)
    testMode = "server"
    ctx.settle()
    check(reports == 2 and client.health < health, "C512 alternating client marker confirms next strike")
    testMode = "client"
    client.thumpTarget = nil
    observer.update(client)
    check(client.variables.ThumpType == "Door" and client.variables.OMHTTBarrierStrike == nil, "C512 leaving barrier restores native animation")
    testMode = "server"
    views.exact, sendClientCommand, ctx.owner.isLocalPlayer = view, send, localPlayer
    Footprint.exact,Barrier.face=exact,face
    ctx.square.objects={}

    local Tether=require("OMHTT/TetherServer")
    local Cycle=require("OMHTT/TetherCycle")
    local Lane=require("OMHTT/TetherLane")
    local Mount=require("OMHTT/TetherMount")
    local savedTether={cast=Lane.cast,supported=Mount.supported,publish=Tether.publish,input=W.input,time=Tether.time}
    Mount.supported=function() return true end
    Tether.publish=function() end
    W.input=function() return false,false,false end
    server,client=ctx.pair()
    Lane.cast=function() return .5,server,"zombie" end
    local cycle=Cycle.new(9000.5,9000.5,0,1,0,{range=6,speed=30,returnSpeed=4,resetTime=3,holdTime=.75})
    local entry={object=object,state={id="c509-tether",recoverAt=0},cycle=cycle,mount={},
        support={getObjectIndex=function() return 0 end},time=0,sent=0,scan=10000}
    cycle.entry=entry;Tether.entries[object]=entry;Cycle.start(cycle,true,false)
    Tether.time=50;Tether.step(object,entry.state);ctx.settle()
    check(math.abs(client.health-9.7)<.00001,"C509 Tether impact settles separately")
    Tether.time=850;Tether.step(object,entry.state);ctx.settle()
    check(math.abs(client.health-9.55)<.00001,"C509 Tether pull settles once through owner")
    Tether.entries[object]=nil
    Lane.cast,Mount.supported,Tether.publish,W.input,Tether.time=savedTether.cast,savedTether.supported,savedTether.publish,savedTether.input,savedTether.time
    W.state,W.publish,P.visual,Audio.emit,Effects.contact=old.state,old.publish,old.visual,old.audio,old.contact
    testResults[#testResults+1]="C509 traps: Poke, both Bed tiers, wire, panel, Tack, Spike Barrier and Tether impact/pull through serialized owner damage PASS"
end
return run
