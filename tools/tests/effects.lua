local E = require("OMHTT/PrototypeEffects")
local F = require("OMHTT/Foundation")
local oldSpecific, oldCell, oldWorld, oldElement = getSpecificPlayer, getCell, getWorld, ISUIElement
local oldTextureGetter = ISUITextureGetter
ISUITextureGetter = {checkGetTexture = function(texture) check(texture == nil, "Native line resolves nil texture"); return texture end}
local visible, sounds, draws, last, lines = true, {}, 0, nil, 0
getSpecificPlayer = function() return {getZ = function() return 0 end} end
getCell = function() return {getGridSquare = function() return {isCanSee = function() return visible end} end} end
getNumActivePlayers = function() return 1 end
getPlayerScreenLeft = function() return 0 end
getPlayerScreenTop = function() return 0 end
getPlayerScreenWidth = function() return 1280 end
getPlayerScreenHeight = function() return 720 end
getWorld = function() return {getFreeEmitter = function(_, x,y,z)
    return {playSound = function(_, name) sounds[#sounds+1] = {name=name,x=x,y=y,z=z}; return #sounds end,
        setVolume = function(_,handle,gain) sounds[handle].gain=gain end,
        setPitch = function() error("Playback must use native clip pitch without the emitter setter") end}
end} end
ISUIElement = {new = function()
    return {instantiate=function() end, setStencilRect=function() end, clearStencilRect=function() end,
        drawRect=function(_,x,y,w,h,a,r,g,b) draws=draws+1; last={x=x,y=y,w=w,r=r,g=g,b=b} end,
        drawLine=testNativeDrawLine,
        javaObject={DrawLine=function(_,texture,x,y,x2,y2,thickness,r,g,b,a)
            check(texture == nil and thickness >= 1 and a >= 0 and a <= 1 and b == .65,
                "Tracer supplies native texture, thickness and all RGBA arguments")
            lines=lines+1
        end}}
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
check(sounds[1].gain==.35, "Potato playback uses its independent default gain")
check(#sounds==1 and sounds[1].name=="OMHTTPotatoFire" and math.abs(sounds[1].x-98.4224)<0.000001, "Launch sound plays once at muzzle")
check(math.abs(E.effects[1].fromX - 98.4224)<0.000001 and E.effects[1].fromY==100,
    "Projectile starts at scaled barrel tip rather than head pivot")
check(E.effects[1].start==launch.start and E.effects[1].flight==launch.flight and launch.fromX==98,
    "Muzzle offset changes only presentation, preserving flight deadline and original launch facts")
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
for heading=0,315,45 do
    local dx,dy=math.cos(heading*math.pi/180),-math.sin(heading*math.pi/180)
    E.receive(F.MODULE,"Launch",{id="heading",shot=heading,x=10+dx*4,y=10+dy*4,z=0,fromX=10,fromY=10,flight=200})
    local e=E.effects[#E.effects]
    check(math.abs(e.fromX-(10+dx*0.4224))<0.000001 and math.abs(e.fromY-(10+dy*0.4224))<0.000001,
        "Muzzle offset follows cardinal and diagonal firing headings")
end
E.receive(F.MODULE,"Launch",{id="close",shot=1,x=10.1,y=10,z=0,fromX=10,fromY=10,flight=50})
check(math.abs(E.effects[#E.effects].fromX-10.05)<0.000001,"Nearby target cannot be overshot by muzzle offset")
E.receive(F.MODULE,"Launch",{id="zero",shot=1,x=10,y=10,z=0,fromX=10,fromY=10,flight=50})
check(E.effects[#E.effects].fromX==10 and E.effects[#E.effects].fromY==10,"Zero-length visual shot remains finite")
E.reset()
E.receive(F.MODULE,"Launch",{id="gun",shot=1,x=14,y=10,z=0,fromX=10,fromY=10,
    firearm=true,sound="M9Shoot",muzzleForward=.12345,muzzleHeight=.4166667,flight=100})
E.render()
check(lines == 1 and E.effects[1].muzzleHeight == .4166667, "Firearm tracer uses gun muzzle height")
testMillis=testMillis+100
E.render()
check(#E.effects==0 and lines==1,"Firearm tracer expires without potato splash")
local D = require("OMHTT/Diagnostics")
local oldDefer, oldControls, oldDiagnostic = D.defer, SandboxVars.OMHTurretsTraps.TurretTestControls,
    SandboxVars.OMHTurretsTraps.TurretDiagnosticLogging
local timing = nil
SandboxVars.OMHTurretsTraps.TurretTestControls = true
SandboxVars.OMHTurretsTraps.TurretDiagnosticLogging = true
D.defer = function(event, fields) if event == "potato-audio" then timing = fields end end
getWorld = function() return {getFreeEmitter = function()
    testMillis = testMillis + 2
    return {playSound = function() testMillis = testMillis + 300; return 1 end,
        setPitch = function() error("Runtime pitch setter reintroduced") end,
        setVolume = function() testMillis = testMillis + 5 end}
end} end
E.sound("OMHTTPotatoFire", 1, 1, 0)
check(timing and timing.audioMs == 307 and timing.emitterMs == 2 and timing.playMs == 300
    and timing.pitchMs == nil and timing.volumeMs == 5, "Native clip playback avoids setter and retains stage telemetry")
timing = nil
SandboxVars.OMHTurretsTraps.TurretDiagnosticLogging = false
E.sound("OMHTTPotatoImpact", 1, 1, 0)
check(timing == nil, "Disabled turret diagnostics create no per-sound telemetry")
D.defer = oldDefer
SandboxVars.OMHTurretsTraps.TurretTestControls = oldControls
SandboxVars.OMHTurretsTraps.TurretDiagnosticLogging = oldDiagnostic
getSpecificPlayer,getCell,getWorld,ISUIElement=oldSpecific,oldCell,oldWorld,oldElement
ISUITextureGetter = oldTextureGetter
