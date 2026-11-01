local Rotary=require("OMHTT/TurretRotary")
local Actors=require("OMHTT/DefenseActors")
local T=require("OMHTT/Turret")
local W=require("OMHTT/TurretWorld")
local M=require("OMHTT/TurretModules")
local Damage=require("OMHTT/Damage")
local Proc=require("OMHTT/TurretProc")
local Clock=require("OMHTT/TurretClock")
local Horde=require("OMHTT/DefenseHorde")
local Combat=require("OMHTT/PrototypeCombat")
local Policy=require("OMHTT/ControlCombat")
local Managed=require("OMHTT/ControlCycle")
local Authority=require("OMHTT/TurretAuthority")
local Audio=require("OMHTT/ControlAudio")
local Heads=require("OMHTT/TurretHeads")
local Automation=require("OMHTT/TurretAutomation")
__modules["OMHTT/TurretRotary"]=Rotary
testMode,testMillis="server",3000000
Horde.allowed,Combat.clearLane,Policy.eligible=function() return true end,function() return true end,function() return true end
Proc.available,Proc.reserve,Proc.release,Proc.hit=function() return true end,function() end,function() end,function() end
W.valid,M.detects=function() return true end,function() return true end
Managed.managed=function() return false end
Authority.publish,Audio.emit=function() end,function() end
Clock.now=function() return testMillis end
Actors.refresh=function() end
W.power=function() return {kind="fixture",cost=0} end
SandboxVars.OMHTurretsTraps.TurretStandbyEnabled=true
SandboxVars.OMHTurretsTraps.TurretWakeSeconds=1
SandboxVars.OMHTurretsTraps.TurretAlertDelay=.25
SandboxVars.OMHTurretsTraps.EnhancedDetectionInterval=.1
local realStep=Automation.step
-- Other scheduler entries cost no time; this is the most favorable budget case.
Automation.step=function(entry,deadline)
 if entry.fixtureIdle then return true end
 return realStep(entry,deadline)
end
local lines={}
local results={}
for case=1,144 do
 local radius=2
 local count=({1,4,8,12})[math.floor((case-1)/36)+1]
 local bearing=((case-1)%36)*5
 local base=3000000+case*100000
 testMillis=base
 local x,y=22000+case*30,22000
 for dx=-radius,radius do for dy=-radius,radius do makeSquare(x+dx,y+dy,0) end end
 local origin=getCell():getGridSquare(x,y,0)
 local inside=getCell():getGridSquare(x+1,y,0)
 local object=IsoObject.new(origin,"test","test");origin:AddTileObject(object)
 check(Authority.register(object,{schema=1,id="turret-c543-"..case,powered=true,standby="asleep",baseFacing=0}),"C543 registered isolated rotary replay")
 local state=Authority.state(object)
 local actor=makeZombie(inside,100)
 actor.owner={getOnlineID=function() return 88 end,isDead=function() return false end}
 actor.onlineId,actor.outfitId=23543+case,23543+case
 Actors.observe(actor)
 local head=instanceItem("Base.OMHTTTurretRotaryBlades")
 local contents={head=head,active={MotionDetection=1,MotionDetectionEnhanced=1,Firing=1,FiringEnhanced=1,Detection360=1}}
 local stats={rotary=true,range=radius,headKind="RotaryBlades",motorSpeed=200,motorPower=0,generatorFuel=0,
  damage=40,critChance=0,initialBlow=0,execute=0,knockdown=0,siphon=0}
 W.contents=function() return contents end
 T.cycleConfig=function() return stats end
 local entry={object=object,soundAt=math.huge,rotaryKind=true}
 Automation.order,Automation.cursor={entry},1
 for i=2,count do Automation.order[i]={fixtureIdle=true} end
 local hits,expected,wake,motor,previous=0,0,nil,nil,0
 Damage.resolve=function(_,_,_,_,callback) hits=hits+1;callback(.4);return true end
 for time=0,30000,100 do
  testMillis=base+time
  Actors.report(actor,{x=x+.5+math.cos(math.rad(bearing)),y=y+.5-math.sin(math.rad(bearing)),z=0,at=testMillis-100})
  Automation.tick()
  if state.standby=="waking" and not wake then wake=time end
  if state.rotaryMoving and not motor then motor=time end
  local travel=entry.travel or 0
  if Heads.crossing(bearing,previous,travel,true,360) then expected=expected+1 end
  previous=travel
 end
 results[case]={count=count,hits=hits,expected=expected,wake=wake,motor=motor}
 lines[#lines+1]="entries="..count.." bearing="..bearing.." applied="..hits.." crossings="..expected.." wakeMs="..tostring(wake).." motorMs="..tostring(motor)
 Actors.remove(actor)
end
for i=1,72 do check(results[i].hits>=results[i].expected-1,"C543 baseline validates sweep-count fixture") end
local missed=false
for i=109,144 do if results[i].hits<results[i].expected*.8 then missed=true end end
check(missed,"C543 real four-entry scheduler leaves rotary contact gaps: "..table.concat(lines,"; "))
check(results[109].wake>results[1].wake,"C543 scheduler delays detection before the configured wake duration starts")
testPackAudit=table.concat(lines,"; ")
