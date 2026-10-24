local S = require("OMHTT/TurretSiphon")
local B = require("OMHTT/TurretBattery")
local T = require("OMHTT/Turret")
local C = require("OMHTT/ControlWorld")
local old = {mode=testMode, state=T.state, control=C.state}
testMode="sp"
local savedRand = ZombRand
ZombRand = function() return 0 end
local battery={id=314001,charge=.5,data={}}
function battery:getID() return self.id end
function battery:getFullType() return "Base.CarBattery1" end
function battery:getModData() return self.data end
function battery:getCurrentUsesFloat() return self.charge end
function battery:setCurrentUsesFloat(value) self.charge=math.floor(value*100+.000001)/100 end
local object={state={id="siphon314"},control={id="siphon314"},health=100}
function object:getObjectIndex() return 0 end
function object:getHealth() return self.health end
function object:getContainer() return {getItemById=function(_,id) if id==battery.id then return battery end end} end
T.state=function(o) return o.state end
C.state=function(o) return o.control end
C.objects.siphon314=object
local stats={siphon=2,synergy=false}
local power={kind="battery",battery=battery}
local square=makeSquare(2314,2314,0)
local function victim()
    return makeZombie(square,0)
end
local function reset()
    battery.charge,battery.data=.5,{}
end
local shot=S.capture(object,power,stats,.001234)
local dead=victim()
S.hit(dead,shot,false)
check(math.abs(B.charge(battery)-.502468)<.0000001,"Siphon restores the exact fractional debit through native-use rounding")
S.hit(dead,shot,false)
check(shot.kills==1,"Repeated confirmed-death callbacks cannot duplicate a refund")
S.hit(victim(),shot,false)
check(shot.kills==2 and math.abs(B.charge(battery)-.504936)<.0000001,"Each distinct direct kill earns its refund")
S.hit(victim(),shot,true)
check(shot.kills==2,"Module-created secondary kill requires Synergy")
shot.synergy=true
S.hit(victim(),shot,true)
check(shot.kills==3,"Synergy admits a secondary kill against the same paid root")
B.detach(battery)
local before=B.charge(battery)
S.hit(victim(),shot,false)
check(B.charge(battery)==before,"Removing and reinstalling the same battery invalidates old refunds")
check(not S.capture(object,{kind="generator"},stats,.1) and not S.capture(object,{kind="disabled"},stats,.1),"External and disabled power produce no battery refund ledger")
reset()
shot=S.capture(object,power,{siphon=4,synergy=true},.5)
S.hit(victim(),shot,false)
check(B.charge(battery)==1,"Stacked refunds cap at full charge")
reset()
shot=S.capture(object,power,stats,.01)
object.health=0
S.hit(victim(),shot,false)
check(B.charge(battery)==.5,"Destroyed turret cannot refund its detached contents")
object.health=100
for _,count in pairs({1,2,6,30,120}) do
    reset()
    local entry={object=object}
    local paid
    for i=1,count do
        local windows=S.motor(entry,power,stats,.03/count,(i-1)*90/count,i*90/count,false)
        if i==1 then
            paid=windows[0]
            S.hit(victim(),paid,false)
            S.hit(victim(),paid,false)
        end
    end
    S.stop(entry)
    check(math.abs(paid.cost-.03)<.00000001 and math.abs(B.charge(battery)-.62)<.00000001,
        "Two arms share one actual-cost pass independent of update partition count")
end
reset()
local entry={object=object}
local windows=S.motor(entry,power,stats,.007,0,21,false)
S.hit(victim(),windows[0],false)
check(B.charge(battery)==.5,"Open rotary swing defers refund until its actual cost is known")
S.stop(entry)
check(math.abs(B.charge(battery)-.514)<.0000001,"Interrupted swing refunds only energy already paid")
reset()
entry={object=object}
windows=S.motor(entry,power,stats,.03,0,90,false)
S.hit(victim(),windows[0],false)
check(math.abs(B.charge(battery)-.56)<.0000001,"Delayed server kill confirmation settles a closed rotary pass")
S.stop(entry)
local resolved=require("OMHTT/TurretStats").resolve({active={Siphon=3}})
check(resolved.siphon==3,"Siphon retains 2x first and adds .5x per extra copy")
local Heads=require("OMHTT/TurretHeads")
local blade={getFullType=function() return "Base.OMHTTTurretRotaryBlades" end}
check(Heads.supports(blade,"Synergy") and Heads.supports(blade,"Siphon")
    and not Heads.supports(blade,"Splitter") and not Heads.supports(blade,"Fragment"),
    "Rotary Synergy and Siphon do not unlock projectile-only modules")
-- Deterministic boundaries: one roll for all copies and no reroll after failure.
reset()
shot=S.capture(object,power,{siphon=4,synergy=false},.01)
local rolls=0
ZombRand=function(limit) check(limit==100,"Siphon uses percentage roll"); rolls=rolls+1; return 45 end
dead=victim()
S.hit(dead,shot,false)
S.hit(dead,shot,false)
check(rolls==1 and shot.kills==0 and B.charge(battery)==.5,"45 fails once; duplicate callback cannot reroll")
ZombRand=function() rolls=rolls+1; return 44 end
S.hit(victim(),shot,false)
check(rolls==2 and shot.kills==1 and math.abs(B.charge(battery)-.54)<.0000001,"44 succeeds once for the whole four-times stack")
S.hit(victim(),shot,true)
check(rolls==2,"Ineligible secondary kills do not roll")
check(not S.capture(object,{kind="controller",battery=battery},stats,.1),"Controller charge is never refundable")
ZombRand=savedRand
C.objects.siphon314=nil
T.state,C.state,testMode=old.state,old.control,old.mode
