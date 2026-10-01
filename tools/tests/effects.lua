local E = require("OMHTT/PrototypeEffects")
local F = require("OMHTT/Foundation")
local oldSpecific, oldCell, oldWorld, oldElement = getSpecificPlayer, getCell, getWorld, ISUIElement
local visible, sounds, draws, last = true, {}, 0, nil
getSpecificPlayer = function() return {getZ = function() return 0 end} end
getCell = function() return {getGridSquare = function() return {isCanSee = function() return visible end} end} end
getNumActivePlayers = function() return 1 end
getPlayerScreenLeft = function() return 0 end
getPlayerScreenTop = function() return 0 end
getPlayerScreenWidth = function() return 1280 end
getPlayerScreenHeight = function() return 720 end
getWorld = function() return {getFreeEmitter = function(_, x,y,z)
    return {playSound = function(_, name) sounds[#sounds+1] = {name=name,x=x,y=y,z=z}; return #sounds end,
        setPitch = function(_, handle,pitch) check(pitch >= 0.95 and pitch <= 1.05, "Pitch stays within approved range"); sounds[handle].pitch=pitch end}
end} end
ISUIElement = {new = function()
    return {instantiate=function() end, setStencilRect=function() end, clearStencilRect=function() end,
        drawRect=function(_,x,y,w,h,a,r,g,b) draws=draws+1; last={x=x,y=y,w=w,r=r,g=g,b=b} end}
end}
testMillis = 1000
local target = {x=100,y=100,floor=false}
function target:getX() return self.x end
function target:getY() return self.y end
function target:getZ() return 0 end
function target:getSquare() return {} end
function target:isOnFloor() return self.floor end
local launch={id="flight",shot=1,x=100,y=100,z=0,fromX=98,fromY=100,start=testMillis,flight=500,target=target}
E.receive(F.MODULE,"Launch",launch); E.receive(F.MODULE,"Launch",launch)
E.render()
check(draws==1 and last.w>=4 and last.r==0.55 and last.g==0.32 and last.b==0.13, "Projectile is a visible brown primitive")
check(#sounds==1 and sounds[1].name=="OMHTTPotatoFire" and sounds[1].x==98, "Launch sound plays once at muzzle")
testMillis=1600; draws=0; E.render()
check(draws==1 and #sounds==1, "Visual flight cannot invent an impact before gameplay arrival")
target.x=101; target.floor=true
local px,py,pz=E.position(launch)
check(px==101 and py==100 and pz==0.06, "Impact follows hit zombie including fallen height")
E.receive(F.MODULE,"Impact",launch); E.receive(F.MODULE,"Impact",launch)
draws=0; E.render()
check(draws==6 and #sounds==2 and sounds[2].name=="OMHTTPotatoImpact", "Arrival emits one synchronized splat and sound")
check(last.x>98, "Splat is centered on current hit target rather than stale launch position")
visible=false; draws=0; E.render(); check(draws==0,"Hidden impact does not reveal zombies")
visible=true; testMillis=2050; E.render(); check(#E.effects==0,"Impacts expire")
for i=1,70 do E.receive(F.MODULE,"Impact",{id="cap",shot=i,x=1,y=1,z=0}) end
check(#E.effects==64,"Visual queue is bounded")
E.reset(); check(#E.effects==0,"Session reset clears transient effects")
getSpecificPlayer,getCell,getWorld,ISUIElement=oldSpecific,oldCell,oldWorld,oldElement
