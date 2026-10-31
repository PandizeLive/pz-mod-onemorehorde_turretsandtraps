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
    for _,count in pairs({1,2,4,8,16}) do
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
testPackAudit="C529 production Splitter scheduling measurement; no connected rendering or fix claim: "..table.concat(measurements,"; ")
