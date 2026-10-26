local D=require("OMHTT/DefenseDisplacement")
local M=require("OMHTT/DefenseMotion")
local Clock=require("OMHTT/ControlClock")
local savedNow,savedMode=Clock.now,testMode
local now=1000
Clock.now=function() return now end
testMode="sp"
local square=makeSquare(14810,14810,0)
function square:isSolid() return false end
function square:isSolidTrans() return false end
local actor=makeZombie(square,1)
actor.x,actor.y=14810.5,14810.5
function actor:getX() return self.x end
function actor:getY() return self.y end
function actor:setNextX(x) self.nx=x end
function actor:setNextY(y) self.ny=y end
local function delta(a,b) return math.atan2(math.sin(a-b),math.cos(a-b)) end
for facing=0,345,15 do
    for bearing=0,315,45 do
        actor.angle=math.rad(facing)
        local start=actor.angle
        local dx,dy=math.cos(math.rad(bearing)),math.sin(math.rad(bearing))
        D.clear(actor)
        check(D.start(actor,actor.x+dx*3,actor.y+dy*3,.75),"Standing pull starts for every facing and trap bearing")
        check(actor.angle==start and not actor.stagger,"Pull start neither snaps facing nor enters native shove")
        for step=1,10 do
            local previous=actor.angle
            now=now+50;D.update(actor)
            check(math.abs(delta(actor.angle,previous))<=math.rad(9)+.00001,"Facing turns smoothly by at most nine degrees per 50ms")
            check(math.abs(delta(actor.angle,start))<=math.pi/4+.00001,"Nearest reaction needs no more than a 45 degree turn")
            check(math.abs((actor.nx-actor.x)*dy-(actor.ny-actor.y)*dx)<.00001
                and (actor.nx-actor.x)*dx+(actor.ny-actor.y)*dy>0,"Pull direction stays toward muzzle independently of facing")
        end
        check(actor:getBumpType()=="" and actor.x==14810.5,"Pull completes its reaction without teleporting actor")
    end
end
check(not M.request(actor,"push","obsolete",14808,14810.5,.35),"Obsolete outward shove requests are rejected")
check(not D.start(actor,actor.x,actor.y,1),"Coincident muzzle cannot produce invalid direction")
check(not D.start(actor,actor.x+2,actor.y,0),"Zero pull distance disables presentation and movement")
D.start(actor,actor.x+2,actor.y,.75)
actor:setBumpType("UnrelatedReaction")
actor.nx=nil;now=now+50;D.update(actor)
check(actor.nx==nil and actor:getBumpType()=="UnrelatedReaction","Another native reaction cancels pull without being cleared")
actor:setBumpType("")
D.start(actor,actor.x+2,actor.y,.75)
actor.climbing=true;actor.nx=nil;now=now+50;D.update(actor)
check(actor.nx==nil and actor:getBumpType()=="","Climbing cancels tether movement and its own reaction")
actor.climbing=false
D.start(actor,actor.x+2,actor.y,.75)
now=now+10000;actor.nx=nil;D.update(actor)
check(actor.nx==nil and actor:getBumpType()=="","Fast-forward expiry releases reaction without deferred travel")
testMode="client";actor.remote=true
check(not D.start(actor,actor.x+2,actor.y,.75),"Observer does not start authoritative pull")
check(D.present(actor,actor.x+2,actor.y)~=nil,"Observer can display no-root-motion reaction")
actor.nx=nil;now=now+50;D.update(actor)
check(actor.nx==nil,"Observer presentation never creates displacement")
now=now+501;D.update(actor)
check(actor:getBumpType()=="", "Remote visual expires with the owner pull duration")
D.clear(actor)
testMode="sp";actor.remote=false
actor:setDeferredMovementEnabled(true)
D.start(actor,actor.x+2,actor.y,.75)
now=now+50;D.update(actor)
check(not actor:isDeferredMovementEnabled(),"Tether excludes native animation displacement")
now=now+500;D.update(actor)
check(not actor:isDeferredMovementEnabled(),"Blend-out retains movement suppression")
now=now+151;D.update(actor)
check(actor:isDeferredMovementEnabled(),"Completed pull restores native animation movement")
actor:setDeferredMovementEnabled(false)
D.start(actor,actor.x+2,actor.y,.75)
D.clear(actor)
check(not actor:isDeferredMovementEnabled(),"Already-disabled native movement is preserved")
actor:setDeferredMovementEnabled(true)
actor.onlineId=15901;actor.outfitId=998;actor.remote=true;testMode="client"
M.created(actor)
local message={id=15901,outfit=998,serial=99001,x=actor.x+2,y=actor.y,distance=.75}
M.command("OMHTT_MotionV1","pull",message)
check(actor:getBumpType()=="","Nonowner rejects authoritative pull command")
M.command("OMHTT_MotionV1","visualPull",message)
check(actor:getBumpType()~="","Observer accepts matching presentation packet")
D.clear(actor)
M.command("OMHTT_MotionV1","visualPull",message)
check(actor:getBumpType()=="","Observer rejects duplicate pull serial")
message.serial=99002;message.outfit=999
M.command("OMHTT_MotionV1","visualPull",message)
check(actor:getBumpType()=="","Observer rejects recycled identity")
Clock.now,testMode=savedNow,savedMode
print("[C481] directional pulls, smooth rotation, interruption and observer authority passed")
