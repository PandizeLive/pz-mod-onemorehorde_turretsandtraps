-- Investigation only: measure current production scheduling, not corrected behavior.
local V=require("OMHTT/TurretVolley")
local Clock=require("OMHTT/TurretClock")
local Budget=require("OMHTT/TurretScheduler")
local Effects=require("OMHTT/DefenseEffects")
local Combat=require("OMHTT/PrototypeCombat")
local Actors=require("OMHTT/DefenseActors")
local saved={mode=testMode,time=testMillis,clock=Clock.now,limit=Budget.limit,emit=Effects.emit,lane=Combat.clearLane,
    queue=V.queue,cursor=V.cursor,occupants=Actors.occupants}
local measurements={}
testMode="server"
Clock.now=function() return testMillis end
Budget.limit=function() return math.huge end
Combat.clearLane=function() return true end
local empty={size=function() return 0 end}
Actors.occupants=function() return empty end
for x=10100,10135 do for y=10100,10135 do makeSquare(x,y,0) end end
for _,range in pairs({10,30}) do
    for _,count in pairs({1,2,4,5,6,8,16}) do
        for _,physical in pairs({false,true}) do
            testMillis=800000
            local impactAt,launches=nil,0
            Effects.emit=function(command)
                if command=="Launch" then launches=launches+1 else impactAt=testMillis-800000 end
            end
            V.queue,V.cursor={},1
            local group={kind="splitter",stats={firearm=not physical},hits={},remaining=count,rays={}}
            for i=1,count do V.ray({id="c529",shots=1},10100.5,10100.5,0,0,range,.2,group,i) end
            local ticks=0
            while #V.queue>0 and ticks<100 do
                V.tick();ticks=ticks+1;testMillis=testMillis+100
            end
            check(#V.queue==0 and impactAt~=nil,"C529 empty-ray scheduler measurement completes")
            measurements[#measurements+1]="count="..count.." range="..range.." physical="..tostring(physical).." lastVisualMs="..impactAt.." launches="..launches.." ticks="..ticks
        end
    end
end
testMode,testMillis,Clock.now,Budget.limit,Effects.emit,Combat.clearLane=saved.mode,saved.time,saved.clock,saved.limit,saved.emit,saved.lane
V.queue,V.cursor,Actors.occupants=saved.queue,saved.cursor,saved.occupants
local Projectile=require("OMHTT/PrototypeEffects")
local Damage=require("OMHTT/Damage")
local kept={effects=Projectile.effects,players=getNumActivePlayers,available=Damage.available}
testMode,testMillis="client",900000
Clock.now=function() return testMillis end
getNumActivePlayers=function() return 0 end
Projectile.effects={}
Projectile.receive(require("OMHTT/Foundation").MODULE,"Launch",{id="c530",shot=1,
    fromX=10100.5,fromY=10100.5,x=10110.5,y=10100.5,z=0,flight=500,sentAt=testMillis,
    projectile="potato",ammoType="Base.Potato",silent=true,muzzle=0})
testMillis=testMillis+750
Projectile.render()
check(#Projectile.effects==1 and Projectile.effects[1].phase=="Launch",
    "C530 expired flight retains launch phase250ms after arrival until impact message")
Projectile.receive(require("OMHTT/Foundation").MODULE,"Impact",{id="c530",shot=1,x=10110.5,y=10100.5,z=0,projectile="potato",silent=true})
check(Projectile.effects[1].phase=="Impact","C530 received impact ends the held launch immediately")
testMode="server"
Damage.available=function() return false end
local ray={best=makeZombie(testSquares["10110:10100:0"],1),group={kind="fragment"}}
check(V.finish(ray)==true and ray.waitingDamage==true,"C530 busy victim defers physical child completion before impact emission")
Projectile.effects,getNumActivePlayers,Damage.available=kept.effects,kept.players,kept.available
testMode,testMillis,Clock.now=saved.mode,saved.time,saved.clock
testPackAudit="C529 production Splitter scheduling measurement; no connected rendering or fix claim: "..table.concat(measurements,"; ")
