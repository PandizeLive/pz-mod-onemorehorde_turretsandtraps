-- C401 regressions for the C400 findings; simulated costs are not FPS measurements.
local W = require('OMHTT/ControlWorld')
local Poke = require('OMHTT/ControlPoke')
local Power = require('OMHTT/ControlPower')
local old = {order=W.order,objects=W.objects,dirty=W.dirty,dirtySet=W.dirtySet,cursor=W.cursor,due=W.due,
    receiver=W.receiver,advance=Poke.advance,flush=Power.flush,paused=GameTime.isGamePaused,
    clock=getTimestampMs,time=getGameTime,mode=testMode,records=W.records,updateInput=W.updateInput,routineFirst=W.routineFirst}
local clock, dispatched, ordinary = 0, 0, 0
testMode = 'sp'
getTimestampMs = function() return clock end
getGameTime = function() return {getWorldAgeHours=function() return 1 end} end
GameTime.isGamePaused = function() return false end
Poke.advance, Power.flush = function() end, function() end
local square=makeSquare(7000,7000,0)
local device={getSquare=function() return square end,getObjectIndex=function() return 0 end,getHealth=function() return 100 end}
W.records=function() return {records={ordinary={kind='Button',x=7000,y=7000,z=0}}} end
W.updateInput=function() ordinary=ordinary+1;clock=clock+2 end
W.order,W.objects,W.dirty,W.dirtySet,W.cursor,W.due = {'ordinary'}, {urgent={},ordinary=device}, {}, {}, 1, nil
W.routineFirst=nil
W.receiver = function() dispatched=dispatched+1; clock=clock+2 end
for i=1,100 do
    clock=i*100
    W.queueDirty('urgent')
    W.tick()
end
check(ordinary==50 and dispatched==50, 'C401 both queues progress under sustained budget-exhausting work')
local fifo={}
W.receiver=function(o) fifo[#fifo+1]=o.id end
W.dirty,W.dirtySet={},{}
for i=1,3 do W.objects['fifo'..i]={id=i};W.queueDirty('fifo'..i) end
W.flushDirty(clock,clock+10)
check(#fifo==3 and fifo[1]==1 and fifo[3]==3,'Dirty work retains FIFO order')
check(W.dirtyLast==0,'Drained dirty queue releases storage')
W.order,W.objects,W.dirty,W.dirtySet,W.cursor,W.due=old.order,old.objects,old.dirty,old.dirtySet,old.cursor,old.due
W.receiver,Poke.advance,Power.flush,GameTime.isGamePaused=old.receiver,old.advance,old.flush,old.paused
getTimestampMs,getGameTime,testMode=old.clock,old.time,old.mode
W.records,W.updateInput,W.routineFirst=old.records,old.updateInput,old.routineFirst

local D=require('OMHTT/ControlDiscovery')
local A=require('OMHTT/ControlAccess')
local U=require('OMHTT/ControlClient')
local Panel=require('OMHTT/ControlPanel')
local saved={objects=D.objects,add=D.add,state=A.state,radius=A.radius,range=A.range,name=U.name,cell=getCell,list=D.list,listIndex=D.listIndex,listSize=D.listSize}
D.objects={}
D.list,D.listIndex,D.listSize={},{},0
D.add=function() end
A.state=function(o) return o.state end
A.radius=function() return 10 end
A.range=function() return false end
U.name=function(o) return o.state.id end
getCell=function() return {getGridSquare=function() return nil end} end
local square={getX=function() return 0 end,getY=function() return 0 end,getZ=function() return 0 end}
local host={state={id='host',kind='Controller',owner='performance-owner'},getSquare=function() return square end}
for i=1,256 do
    local o={state={id='known-'..i,kind='Turret',owner='performance-owner'},getObjectIndex=function() return 0 end}
    D.objects[o]=true
    D.track(o)
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
check(earlyFound and lateFound, 'Both assigned out-of-range devices appear after bounded cache traversal')
D.remove(late)
check(D.listIndex[late]==nil and D.listSize==255,'Removed cache entry releases its index')
D.objects,D.add,A.state,A.radius,A.range,U.name,getCell=saved.objects,saved.add,saved.state,saved.radius,saved.range,saved.name,saved.cell
D.list,D.listIndex,D.listSize=saved.list,saved.listIndex,saved.listSize
local Graph=require('OMHTT/ControlGraph')
local Groups=require('OMHTT/ControlGroupUI')
local Stats=require('OMHTT/ControlGraphStats')
local before={state=A.state,name=U.name,layout=Groups.layout,step=Stats.step,text=getTextManager}
local measures=0
A.state=function(o) return o.state end
U.name=function(o) return o.name or 'WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW' end
Groups.layout=function(g) g.contentHeight=0;g.groups={} end
Stats.step=function() end
getTextManager=function() return {getFontHeight=function() return 18 end,MeasureStringX=function(_,font,text) measures=measures+1;return #text*8 end} end
local results={}
for _,count in pairs({64,256}) do
    local graph={width=300,height=500,refreshDue=-1,defenses={},getScrollHeight=function() return 0 end,
        getYScroll=function() return 0 end,setScrollHeight=function() end,setYScroll=function() end}
    local owner={object=host,graph=graph,devices={items={}},lineHeight=18}
    graph.owner=owner
    for i=1,count do
        owner.devices.items[i]={item={state={id='graph-'..i,kind='Button',owner='performance-owner',number=i,links={}}}}
    end
    measures=0
    Graph.refreshForPanel(owner)
    results[count]=measures
    check(#graph.triggers==count,'Graph builds every row')
    local rows=graph.triggers
    graph.refreshDue=-1
    measures=0
    Graph.refreshForPanel(owner)
    check(graph.triggers==rows and measures==0,'Unchanged refresh retains layout without text measurements')
    graph.width=400
    Graph.refreshForPanel(owner)
    check(graph.triggers~=rows and measures>0,'Resize invalidates labels and layout')
    rows=graph.triggers
    owner.devices.items[1].item.name='Renamed'
    graph.refreshDue=-1
    Graph.refreshForPanel(owner)
    check(graph.triggers~=rows and graph.triggers[1].title=='Renamed','Rename invalidates cached title')
    rows=graph.triggers
    owner.devices.items[1].item.state.links={'new-link'}
    graph.refreshDue=-1
    Graph.refreshForPanel(owner)
    check(graph.triggers~=rows,'Connection change rebuilds edges')
    rows=graph.triggers
    local object=owner.devices.items[1].item
    object.state={id=object.state.id,kind=object.state.kind,owner=object.state.owner,number=object.state.number,links=object.state.links,powered=true}
    graph.refreshDue=-1
    measures=0
    Graph.refreshForPanel(owner)
    check(graph.triggers==rows and rows[1].state==object.state and measures==0,'Replicated live state refreshes without structural rebuild')
    graph.refreshDue=0
    Graph.refreshForPanel(owner)
    check(graph.triggers~=rows,'Explicit group/collapse refresh rebuilds layout')
end
check(results[256]<1000,'Shared long labels are measured once per layout')
A.state,U.name,Groups.layout,Stats.step,getTextManager=before.state,before.name,before.layout,before.step,before.text
testPackAudit='C401: dirty=50 routine=50 FIFO=pass assignedLate=visible unchangedGraphMeasurements=0 initialMeasurements64='..results[64]..' initialMeasurements256='..results[256]..'; no FPS claim'
testC401Audit=testPackAudit

-- Kahlua assigns aliased table targets in reverse order: exercise the last slot explicitly.
local cacheBefore={list=D.list,index=D.listIndex,size=D.listSize}
D.list,D.listIndex,D.listSize={},{},0
local first,last={},{}
D.track(first);D.track(last)
D.drop(2)
check(D.list[2]==nil and D.listIndex[last]==nil and D.listSize==1,'Last cache slot removal releases storage')
D.drop(1)
check(D.list[1]==nil and D.listIndex[first]==nil and D.listSize==0,'Final cache slot removal releases storage')
D.list,D.listIndex,D.listSize=cacheBefore.list,cacheBefore.index,cacheBefore.size
