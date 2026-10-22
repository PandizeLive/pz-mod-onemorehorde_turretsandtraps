-- Audit-only reproductions against installed-source behavior; not FPS measurements.
local W = require('OMHTT/ControlWorld')
local Poke = require('OMHTT/ControlPoke')
local Power = require('OMHTT/ControlPower')
local old = {order=W.order,objects=W.objects,dirty=W.dirty,dirtySet=W.dirtySet,cursor=W.cursor,due=W.due,
    receiver=W.receiver,advance=Poke.advance,flush=Power.flush,paused=GameTime.isGamePaused,
    clock=getTimestampMs,time=getGameTime,mode=testMode}
local clock, dispatched = 0, 0
testMode = 'sp'
getTimestampMs = function() return clock end
getGameTime = function() return {getWorldAgeHours=function() return 1 end} end
GameTime.isGamePaused = function() return false end
Poke.advance, Power.flush = function() end, function() end
W.order,W.objects,W.dirty,W.dirtySet,W.cursor,W.due = {'ordinary'}, {urgent={}}, {}, {}, 1, nil
W.receiver = function() dispatched=dispatched+1; clock=clock+2 end
for i=1,100 do
    clock=i*100
    W.dirty[1],W.dirtySet.urgent='urgent',true
    W.tick()
end
local starved = W.cursor == 1
check(starved and dispatched==100, 'C400 reproduces routine starvation with a continuous two-millisecond dirty workload')
print('C400 scheduler: updates=100 dirtyDispatches='..dispatched..' ordinaryDispatches=0 simulatedReceiverCostMs=2')
W.order,W.objects,W.dirty,W.dirtySet,W.cursor,W.due=old.order,old.objects,old.dirty,old.dirtySet,old.cursor,old.due
W.receiver,Poke.advance,Power.flush,GameTime.isGamePaused=old.receiver,old.advance,old.flush,old.paused
getTimestampMs,getGameTime,testMode=old.clock,old.time,old.mode

local D=require('OMHTT/ControlDiscovery')
local A=require('OMHTT/ControlAccess')
local U=require('OMHTT/ControlClient')
local Panel=require('OMHTT/ControlPanel')
local saved={objects=D.objects,add=D.add,state=A.state,radius=A.radius,range=A.range,name=U.name,cell=getCell}
D.objects={}
D.add=function() end
A.state=function(o) return o.state end
A.radius=function() return 10 end
A.range=function() return false end
U.name=function(o) return o.state.id end
getCell=function() return {getGridSquare=function() return nil end} end
local square={getX=function() return 0 end,getY=function() return 0 end,getZ=function() return 0 end}
local host={state={id='host',kind='Controller'},getSquare=function() return square end}
for i=1,256 do
    local o={state={id='known-'..i,kind='Turret'},getObjectIndex=function() return 0 end}
    D.objects[o]=true
end
local early,late,n=nil,nil,0
for o in pairs(D.objects) do
    n=n+1
    if n==1 then early=o end
    if n==200 then late=o end
end
early.state.controller,late.state.controller='host','host'
local panel={object=host,devices={itemheight=20,setScrollHeight=function() end}}
for pass=1,2 do
    repeat Panel.scan(panel) until not panel.scanIndex
end
local earlyFound,lateFound=false,false
for i=1,#panel.devices.items do
    earlyFound=earlyFound or panel.devices.items[i].item==early
    lateFound=lateFound or panel.devices.items[i].item==late
end
check(earlyFound and not lateFound, 'C400 reproduces cached assigned out-of-range device omission after two complete scans')
print('C400 cache: known=256 fullScans=2 assignedEarlyPresent=true assignedLatePresent=false')
D.objects,D.add,A.state,A.radius,A.range,U.name,getCell=saved.objects,saved.add,saved.state,saved.radius,saved.range,saved.name,saved.cell
local Graph=require('OMHTT/ControlGraph')
local Groups=require('OMHTT/ControlGroupUI')
local Stats=require('OMHTT/ControlGraphStats')
local before={state=A.state,name=U.name,layout=Groups.layout,step=Stats.step,text=getTextManager}
local measures=0
A.state=function(o) return o.state end
U.name=function() return 'WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW' end
Groups.layout=function(g) g.contentHeight=0 end
Stats.step=function() end
getTextManager=function() return {MeasureStringX=function(_,font,text) measures=measures+1;return #text*8 end} end
local results={}
for _,count in pairs({64,256}) do
    local graph={width=300,height=500,refreshDue=-1,defenses={},getScrollHeight=function() return 0 end,
        getYScroll=function() return 0 end,setScrollHeight=function() end,setYScroll=function() end}
    local owner={object=host,graph=graph,devices={items={}},lineHeight=18}
    for i=1,count do
        owner.devices.items[i]={item={state={id='graph-'..i,kind='Button',number=i,links={}}}}
    end
    measures=0
    Graph.refreshForPanel(owner)
    results[count]=measures
    check(#graph.triggers==count,'C400 graph fixture builds every row, including offscreen rows')
end
check(results[256]>=results[64]*3,'C400 graph text measurement work scales with total rows')
A.state,U.name,Groups.layout,Stats.step,getTextManager=before.state,before.name,before.layout,before.step,before.text
testPackAudit='C400: dirtyUpdates=100 ordinaryDispatches=0 simulatedReceiverCostMs=2; knownDevices=256 fullScans=2 assignedLateMissing=true; graphWidth=300 nameLength=48 textMeasures64='..results[64]..' textMeasures256='..results[256]..'; no FPS claim'
