local W=require("OMHTT/ControlWorld")
local P=require("OMHTT/ControlPower")
local B=require("OMHTT/TurretBattery")
local D=require("OMHTT/ControlConsumption")
local originalSettings=SandboxVars.OMHTurretsTraps
SandboxVars.OMHTurretsTraps={TrapsTriggerLaserConsumption=.2}
check(D.rate("Laser")==.2,"Traps-only consumption tuning is effective")
SandboxVars.OMHTurretsTraps.TriggerLaserConsumption=0
check(D.rate("Laser")==0,"Combined canonical zero overrides Traps-only fallback")
SandboxVars.OMHTurretsTraps=originalSettings
local Beam=require("OMHTT/ControlBeam")
local A=require("OMHTT/ControlAccess")
local Action=require("OMHTT/ControlAction")
local saved={mode=testMode,cell=getCell,time=getGameTime,state=W.state,publish=W.publish,objects=W.objects,charge=B.charge,spend=B.spend,
    authorized=A.authorized,write=A.write,pulse=W.pulse,records=W.records,incoming=W.incoming}
local hours=0
getGameTime=function() return {getWorldAgeHours=function() return hours end,getMinutesPerDay=function() return 60 end} end
testMode="server"
local states={}
local square={getX=function() return 10 end,getY=function() return 10 end,getZ=function() return 0 end,
    haveElectricity=function(self) return self.mains==true end,hasGridPower=function() return false end,getRoom=function() return nil end}
getCell=function() return {getGridSquare=function() return square end} end
local items={}
local box={getItems=function() return {size=function() return #items end,get=function(_,i) return items[i+1] end} end,
    getItemWithID=function(_,id) for i=1,#items do if items[i].id==id then return items[i] end end end}
local function device(kind,id)
    local o={getSquare=function() return square end,getObjectIndex=function() return 0 end,getHealth=function() return 100 end,
        getContainer=function() return box end}
    states[o]={kind=kind,id=id,placed=true,x=10,y=10,z=0,links={},recoverAt=0,beamRange=10}
    return o
end
local controller=device("Controller","c")
local lever=device("Lever","l")
local plate=device("Plate","p")
local laser=device("Laser","s")
local button=device("Button","b")
for _,o in pairs({lever,plate,laser,button}) do states[o].controller="c" end
W.objects={c=controller,l=lever,p=plate,s=laser,b=button}
W.state=function(o) return states[o] end
W.publish=function() end
B.charge=function(i) return i.charge end
B.spend=function(i,c) local n=math.min(c,i.charge);i.charge=i.charge-n;return n end
local function battery(id,charge)
    local b={id=id,charge=charge,getContainer=function() return box end,getCondition=function() return 100 end,
        getFullType=function() return "Base.CarBattery1" end,getID=function(self) return self.id end}
    items[#items+1]=b
    return b
end
local first=battery(1,.000002)
local second=battery(2,1)
check(P.trigger(button,.000001),"Button uses powered assigned bank")
check(math.abs(first.charge-.000001)<1e-10,"Button debits exact millionth charge")
check(P.trigger(button,.000003),"Input cost spans sequential spare batteries")
check(first.charge==0 and math.abs(second.charge-.999998)<1e-9,"Spare pays only remaining cost")
W.updateInput(lever,true)
check(states[lever].active and states[lever].powered,"ON Lever supplies held signal")
local before=second.charge
hours=1
W.updateInput(lever,false)
check(math.abs(before-second.charge-(1/48+.0001))<1e-9,"Prior ON interval paid once with independent Controller idle")
before=second.charge
W.updateInput(lever,false)
check(second.charge==before,"Same clock interval cannot double-charge")
hours=2
W.updateInput(lever,false)
check(math.abs(before-second.charge-1/48)<1e-9,"Inactive Lever adds zero draw")
square.mains=true
before=second.charge
hours=3
W.updateInput(laser,false)
hours=4
W.updateInput(laser,false)
check(second.charge==before and states[laser].powered,"Mains powers scanning without bank debit")
square.mains=false
states[lever].latched=true
states[lever].controller=nil
W.updateInput(lever,true)
check(not states[lever].active and states[lever].latched,"Unassignment suppresses signal without changing latch")
states[lever].controller="c"
W.updateInput(lever,true)
check(states[lever].active,"Restoration reconciles held latch")
local records={}
for o,s in pairs(states) do records[s.id]=s end
W.records=function() return {records=records} end
local target=device("Turret","t")
W.incoming={t={l=true,p=true}}
W.updateInput(plate,true)
states[lever].controller=nil
local linked,on,valid=W.input(target,testMillis)
check(linked and on and valid,"Another powered OR input preserves ON")
states[plate].controller=nil
linked,on,valid=W.input(target,testMillis)
check(linked and not on and valid,"Supply loss preserves links and validity for admitted receiver work")
A.authorized=function() return true end
A.write=function() return true end
local shots=0
W.pulse=function() shots=shots+1 end
states[button].links={"t","t"};W.objects.t=target
states[button].controller=nil
check(not Action:new({},button,"Pulse",nil,nil,"b"):complete() and shots==0,"Unpowered Button cannot enqueue/replay pulse")
states[lever].controller=nil
check(Action:new({},lever,"Toggle",nil,nil,"l"):complete() and not states[lever].latched,"Unpowered switch can still change saved latch")
local rating=D.rating("Button");check(rating=="Minimal","Button explicitly per-use Minimal")
check(D.rating("Plate")=="Minimal" and D.rating("Laser")=="VeryLow","Hourly bands normalize day length")
getGameTime=function() return {getMinutesPerDay=function() return 30 end} end
check(D.rating("Laser")=="Low","Faster game day changes real-hour rate")
local beam={x=0,y=0,z=0,dx=1,dy=0,length=10}
check(Beam.cross(beam,5,-1,5,1),"Fast crossing swept across beam")
check(Beam.cross(beam,5,.1,5,.1),"Stationary actor footprint interrupts")
check(not Beam.cross(beam,11,-1,11,1),"Actors beyond beam cannot interrupt")
check(not Beam.cross(beam,5,1,6,1),"Parallel motion outside width stays clear")
beam.dx,beam.dy=0,-1
check(Beam.cross(beam,-1,-5,1,-5),"North-facing swept crossing")
W.state,W.publish,W.objects,W.records,W.incoming=saved.state,saved.publish,saved.objects,saved.records,saved.incoming
A.authorized,A.write=saved.authorized,saved.write
B.charge,B.spend=saved.charge,saved.spend
W.pulse=saved.pulse
getCell,getGameTime,testMode=saved.cell,saved.time,saved.mode
print("[OMHTT-C381] trigger supply/cost/latch/OR/tooltip/sweep checks passed")
