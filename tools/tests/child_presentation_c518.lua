local V=require("OMHTT/TurretVolley")
local Effects=require("OMHTT/DefenseEffects")
local Clock=require("OMHTT/TurretClock")
local savedQueue,savedEmit,savedMode=V.queue,Effects.emit,testMode
testMode="server"
local captured={}
Effects.emit=function(command,facts) captured[#captured+1]={command=command,facts=facts} end
local cases={{name="potato-splitter",kind="splitter"},{name="potato-fragment",kind="fragment"},
    {name="ballista-fragment",kind="fragment",head="Ballista"}}
for i=1,#cases do
    local case=cases[i]
    V.queue,captured={},{}
    local group={kind=case.kind,stats={headKind=case.head,fragment=0},remaining=1,rays={},hits={}}
    V.ray({id="c518",shots=i},9000,9000,0,0,4,20,group,1)
    check(#captured==0,case.name..": unexpected launch")
    local ray=V.queue[1]
    check(ray.speed==nil,case.name..": unexpectedly has travel timing")
    ray.distance=4
    V.finish(ray)
    check(#captured==1 and captured[1].command=="Volley",case.name..": expected terminal volley")
    check(captured[1].facts.rays[1].firearm==true,case.name..": expected incorrect firearm visual")
end
V.queue,captured={},{}
V.ray({id="c518",shots=4},9000,9000,0,0,4,20,
    {kind="splitter",stats={headKind="Ballista"},remaining=1,rays={},hits={}},1)
check(#captured==1 and captured[1].command=="Launch" and captured[1].facts.projectile=="spear",
    "Ballista splitter already retains spear launch")
V.queue,captured={},{}
local options={stats={fragmentDamage=.25,fragmentRange=4},damage=20,fragmentReserved=5}
V.fragment({id="c518",shots=5},9000,9000,0,nil,nil,options)
check(#V.queue==5 and V.queue[1].group.due==Clock.now()+250,"Fragment retains explicit 250ms wait")
V.queue,Effects.emit,testMode=savedQueue,savedEmit,savedMode
local Aim=require("OMHTT/TurretAimView")
check(Aim.rotary(0,250,180,true)==Aim.rotary(0,350,180,true),"Rotary display freezes after 250ms prediction horizon")
check(Aim.rotary(45,100,180,true)-Aim.rotary(0,350,180,true)==18,"Next 250ms rotary snapshot with 100ms transit jumps display 18 degrees")
testPackAudit="C518: child tracer/timing defects reproduced; Ballista splitter already launches spear; Fragment 250ms wait; rotary freeze and 18-degree snapshot jump at 100ms transit reproduced. Diagnostic reproduction, not repair."
