local Cursor=require("OMHTT/TurretFacingCursor")
local A=require("OMHTT/ControlAccess")
local U=require("OMHTT/ControlClient")
local Range=require("OMHTT/TurretRange")
local R=require("OMHTT/ControlRemote")
local saved={state=A.state,write=A.write,valid=R.valid,cell=getCell,command=U.command,focus=Range.focus}
A.state=function(object) return object and object.state end
A.write=function(player,state) return not player.denied end
R.valid=function(player,host,target) return not player.away and not host.offline end
local square=makeSquare(2200,2200,0)
local selected=makeSquare(2201,2199,0)
local host={state={id="cursor-host",kind="Controller"}}
local turret={state={id="cursor-target",kind="Turret"},getX=function() return 2200 end,getY=function() return 2200 end,getZ=function() return 0 end}
local player={getPlayerNum=function() return 0 end}
local panel={player=player,object=host,selected=turret,nameEntry={commit=function() end}}
function panel:setVisible(value) self.visible=value end
function panel:bringToTop() self.raised=true end
local drag,requested,focusCount
focusCount=0
Range.focus=function(index,source,object,enabled) focusCount=focusCount+(enabled and 1 or -1) end
getCell=function() return {
    getGridSquare=function(_,x,y,z) if x==2201 and y==2199 and z==0 then return selected end end,
    setDrag=function(_,value,index) local old=drag;drag=value;if old then old:deactivate() end end,
    getDrag=function() return drag end} end
U.command=function(p,h,command,value,target) requested={command=command,value=value,target=target} end
local cursor=Cursor.start(panel)
check(cursor==drag and panel.visible==false and focusCount==1,"Facing cursor hides menu and selects exact turret")
check(cursor.nSprite==1 and cursor.isThumpable==true and cursor.isFloor==false,"Native building cursor init/reset executes after deferred class load")
function cursor:getFloorCursorSprite() return {RenderGhostTileColor=function() end} end
cursor:render(2201,2199,0,selected)
check(Range.preview[0].heading==45,"World preview follows selected 45-degree direction")
cursor:create(2201,2199,0,false,nil)
check(requested.command=="SetFacing" and requested.value==45 and requested.target==turret,"World click sends direction only")
check(not drag and not panel.cursor and not Range.preview[0] and panel.visible and focusCount==0,"Selection cleans cursor and restores menu")
requested=nil
cursor=Cursor.start(panel)
getCell():setDrag(nil,0)
check(not requested and panel.visible and not Range.preview[0],"Native cancel sends no mutation")
cursor=Cursor.start(panel)
host.state.id="replacement"
cursor:create(2201,2199,0,false,nil)
check(not requested,"Replaced controller cannot receive stale picker command")
player.denied=true
check(not Cursor.start(panel),"Read-only access cannot start direction picker")
A.state,A.write,R.valid,getCell,U.command,Range.focus=saved.state,saved.write,saved.valid,saved.cell,saved.command,saved.focus
ISBuildingObject=testFacingBuilding
testFacingBuilding=nil
