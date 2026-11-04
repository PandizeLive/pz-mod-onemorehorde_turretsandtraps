-- Controlled production-path regressions; native engine/connected rendering are separate gates.
local V = require("OMHTT/TurretVolley")
local Effects = require("OMHTT/DefenseEffects")
local Clock = require("OMHTT/TurretClock")
local Aim = require("OMHTT/TurretAimView")
local Cycle = require("OMHTT/TetherCycle")
local Ammo = require("OMHTT/TurretAmmo")
local saved = {mode=testMode,clock=Clock.now,emit=Effects.emit,queue=V.queue,serial=V.serial}
local now,captured = 500000,{}
testMode="server"
Clock.now=function() return now end
Effects.emit=function(command,facts) captured[#captured+1]={command=command,facts=nativeRoundTrip(facts)} end
for _,case in pairs({{family="potato"},{head="Ballista",family="spear"}}) do
    for _,kind in pairs({"splitter","fragment"}) do
        V.queue,captured={},{}
        local group={kind=kind,stats={headKind=case.head,fragment=0},remaining=1,rays={},hits={}}
        V.ray({id="c526",shots=1},9600.5,9600.5,0,0,4,.2,group,1)
        local ray=V.queue[1]
        check(#captured==1 and captured[1].command=="Launch" and captured[1].facts.projectile==case.family,
            "C526 physical children launch their original family: "..kind.."/"..case.family)
        check(ray.speed and captured[1].facts.flight==4000/ray.speed and captured[1].facts.ammoType,
            "C526 physical children have flight time and ammunition identity")
        if kind=="fragment" then check(captured[1].facts.muzzle==0,"C526 Fragment starts at impact, without muzzle displacement") end
        ray.distance=4
        check(V.finish(ray)==true and #captured==1,"C526 physical child cannot finish before arrival")
        now=now+4000/ray.speed+1
        check(V.finish(ray)==false and captured[2].command=="Impact" and not captured[2].facts.firearm,
            "C526 physical child ends at arrival without a firearm tracer")
    end
end
V.queue,captured={},{}
V.fragment({id="c526",shots=2},9604.5,9600.5,0,nil,nil,
    {stats={fragmentDamage=.25,fragmentRange=4},damage=.2,fragmentReserved=5})
check(#V.queue==5 and not V.queue[1].group.due and #captured==5,"C526 Fragment has no artificial startup wait")
V.queue,captured={},{}
V.ray({id="c526",shots=3},9600.5,9600.5,0,0,10,.2,
    {kind="piercing",stats={headKind="Ballista"},hits={},fromX=9606.5,fromY=9600.5},1)
check(captured[1].facts.fromX==9606.5 and math.abs(captured[1].facts.flight-4000/24)<.001,
    "C526 piercing continues from impact with only remaining flight")
check(math.abs(now-V.queue[1].flightStart-250)<.001,"C526 piercing collision clock includes already travelled distance")
V.queue,captured={},{}
V.ray({id="c526",shots=4},9600,9600,0,0,4,.2,
    {kind="fragment",stats={headKind="Arc"},hits={}},1)
check(not V.queue[1].speed and #captured==0,"C526 Arc Fragment remains electrical, not a physical missile")
V.queue[1].distance=4;V.finish(V.queue[1])
check(captured[1].command=="Arc","C526 Arc Fragment emits the electrical effect")
V.queue,captured={},{}
V.ray({id="c526",shots=5},9600,9600,0,0,4,.2,
    {kind="fragment",stats={firearm=true},hits={},remaining=1,rays={}},1)
V.queue[1].distance=4;V.finish(V.queue[1])
check(captured[1].command=="Ray" and captured[1].facts.firearm,"C526 firearms retain tracers")

check(Aim.rotary(0,350,180,true)>Aim.rotary(0,250,180,true),"C526 rotary prediction advances through delayed snapshots")
for _,transit in pairs({0,100,200,350}) do
    local sample,last={},nil
    for time=0,1500,10 do
        local snapshot=math.floor(time/250)*250
        local travel=snapshot*.18
        local value=Aim.motor(sample,travel,time-snapshot+transit,180,true,nil,time+1000)
        if last then check(value>last and math.abs(value-last-1.8)<.001,
            "C526 rotary stays continuous across 250ms snapshots and transit") end
        last=value
    end
end
check(Aim.rotary(0,2000,180,true)==135,"C526 lost rotary packets stop bounded extrapolation")
check(Aim.rotary(30,300,180,true,40)==40 and Aim.rotary(30,300,180,false)==30,
    "C526 rotary respects stroke endpoint and stopped state")
local Heads=require("OMHTT/TurretHeads")
for _,omni in pairs({false,true}) do
    local sample,previous={},nil
    for time=0,2500,10 do
        local snapshot=math.floor(time/250)*250
        local value=Aim.motor(sample,snapshot*.18,time-snapshot+150,180,true,nil,time+10000)
        local heading=Heads.motion(value,omni,90)
        if previous then check(math.abs((heading-previous+540)%360-180)<=1.801,
            "C526 rotary cone reversals and 360 wrap remain continuous") end
        previous=heading
    end
end
local stopped={}
Aim.motor(stopped,70,100,180,true,90,10000)
for time=10010,11000,10 do
    local value=Aim.motor(stopped,90,0,180,false,90,time)
    check(value<=90,"C526 stopped rotary cannot overshoot its endpoint")
end
check(math.abs(stopped.motorValue-90)<.001,"C526 rotary settles at the authoritative stop")
local resumed=Aim.motor(stopped,90,10,180,true,nil,11010)
check(resumed>90 and resumed<92,"C526 restart resumes without a new sweep jump")
local tether={phase="out",x=0,y=0,dx=1,dy=0,distance=1,range=20,speed=8,returnSpeed=6,limit=20}
local x1=Cycle.position(tether,.25)
local x2=Cycle.position(tether,.35)
check(math.abs(x2-x1-.8)<.001,"C526 delayed tether snapshots do not freeze at 250ms")
check(Cycle.position(tether,2)==7,"C526 missing tether packets have a finite prediction horizon")
tether.limit=2
check(Cycle.position(tether,.7)==2,"C526 tether never predicts through confirmed obstruction")
tether.phase="back";tether.distance=5
check(math.abs(Cycle.position(tether,.35)-2.9)<.001,"C526 return has the same continuous timing")
local bomb={getFullType=function() return "Base.OMHTTAmmoMakeshiftBomb" end,getActualWeight=function() return 1 end}
check(Ammo.fastTransfer(bomb) and Ammo.transferWeight(bomb)==.1 and bomb:getActualWeight()==1,
    "C526 Makeshift Bomb batches quickly without changing inventory weight")
local other={getFullType=function() return "Base.PipeBomb" end,getActualWeight=function() return 1 end}
check(not Ammo.fastTransfer(other) and Ammo.transferWeight(other)==1,"C526 heavier native explosives retain their existing transfer policy")
local action={item=bomb,character={hasTrait=function() return false end,isWearingAwkwardGloves=function() return false end}}
local oldTraits=CharacterTrait
CharacterTrait={DEXTROUS="Dextrous",ALL_THUMBS="AllThumbs"}
check(require("OMHTT/TurretTransferAction").getDuration(action)==5,"C526 server Makeshift Bomb loading duration is five native ticks")
action.character.hasTrait=function(_,trait) return trait==CharacterTrait.DEXTROUS end
check(require("OMHTT/TurretTransferAction").getDuration(action)==2.5,"C526 bomb speed preserves Dexterous")
CharacterTrait=oldTraits

-- Every arm, diagonal overlap, objects, safehouses, unloading, persistence and release.
local P=require("OMHTT/ControlPokeFootprint")
local Access=require("OMHTT/ControlAccess")
local oldState,oldSafe,oldProperties=Access.state,SafeHouse,IsoPropertyType
Access.state=function(object) return object:getModData().OMHTTControl end
SafeHouse={isSafeHouse=function(square) return square.protected==true end}
IsoPropertyType=IsoPropertyType or {BLOCKS_PLACEMENT="BLOCKS_PLACEMENT"}
local function floor(x,y)
    local square=makeSquare(x,y,0)
    square.TreatAsSolidFloor=function(self) return self.floor end
    square.isSolid=function(self) return self.solid==true end
    square.isSolidTrans=function() return false end
    square.getProperties=function(self) return {has=function() return self.fixture==true end} end
    square.isSomethingTo=function(self,other) return self.blocked or other.blocked end
    return square
end
for x=9700,9710 do for y=9700,9710 do floor(x,y) end end
local center=testSquares["9705:9705:0"]
local player={getUsername=function() return "c526" end}
check(P.valid(center,nil,player),"C526 clear cross is placeable")
for i=1,#P.offsets do
    local offset=P.offsets[i]
    local tile=testSquares[(9705+offset[1])..":"..(9705+offset[2])..":0"]
    tile.protected=true;check(not P.valid(center,nil,player),"C526 each footprint tile checks safehouse access");tile.protected=nil
    tile.fixture=true;check(not P.valid(center,nil,player),"C526 each footprint tile rejects fixtures");tile.fixture=nil
    tile.floor=false;check(not P.valid(center,nil,player),"C526 each footprint tile requires ground");tile.floor=true
    tile.blocked=true;check(not P.valid(center,nil,player),"C526 cross cannot span a wall");tile.blocked=false
    local blocker=IsoObject.new(tile,"test","test")
    blocker:getModData().OMHTTBed={};tile:AddTileObject(blocker)
    check(not P.valid(center,nil,player),"C526 existing floor hazards block every cross tile")
    tile.objects={}
end
local placed=IsoObject.new(center,"test","Poke")
placed:getModData().OMHTTControl={kind="Poke",pokeFootprint=1}
center:AddTileObject(placed)
for i=1,#P.offsets do
    local offset=P.offsets[i]
    local tile=testSquares[(9705+offset[1])..":"..(9705+offset[2])..":0"]
    check(P.reserved(tile) and not require("OMHTT/BedSpikes").clear(tile),"C526 arm reservations reject Bed/Wire placement")
end
check(not P.valid(testSquares["9706:9706:0"]),"C526 diagonal crosses cannot share arms")
check(P.valid(testSquares["9708:9705:0"]),"C526 non-overlapping adjacent cross remains allowed")
placed.data=nativeRoundTrip(placed.data)
check(P.reserved(testSquares["9704:9705:0"]),"C526 footprint survives native table serialization")
center.objects={}
check(P.valid(center,nil,player),"C526 pickup releases all five reservations without orphan objects")
placed.data.OMHTTControl.pokeFootprint=nil;center:AddTileObject(placed)
check(not P.reserved(testSquares["9704:9705:0"]),"C526 old Poke installations do not silently claim neighboring tiles")
center.objects={}
Access.state,SafeHouse,IsoPropertyType=oldState,oldSafe,oldProperties
local settings=SandboxVars.OMHTurretsTraps
local health=settings.SpikeBarrierHealth
settings.SpikeBarrierHealth=nil
local Foundation=require("OMHTT/Foundation")
check(Foundation.barrierHealth()==80 and Foundation.barrierHealth({tier="reinforced"})==160,
    "C526 approved new default Barrier durability is 80/160")
settings.SpikeBarrierHealth=123
check(Foundation.barrierHealth()==123,"C526 saved custom Barrier health remains authoritative")
settings.SpikeBarrierHealth=health
testMode,Clock.now,Effects.emit,V.queue,V.serial=saved.mode,saved.clock,saved.emit,saved.queue,saved.serial
testPackAudit="C526: physical child travel/families, immediate Fragment, piercing continuation, rotary/tether transit, bomb timing, five-tile reservations and durability passed; connected clients=0"
