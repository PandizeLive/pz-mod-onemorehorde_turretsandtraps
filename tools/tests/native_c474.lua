return function()
    local Motion=require("OMHTT/DefenseMotion")
    local D=require("OMHTT/DefenseDisplacement")
    local Clock=require("OMHTT/ControlClock")
    local cell=getCell()
    local actor=IsoZombie.new(cell)
    local square=IsoGridSquare.new(cell,nil,14710,14710,0)
    actor:setCurrent(square);actor:setHealth(1)
    actor:setX(14710.5);actor:setY(14710.5);actor:setZ(0)
    actor:setStaggerBack(false);actor:setBumpType("")
    local savedCell,savedNow=getCell,Clock.now
    local now=1000
    getCell=function() return {getGridSquare=function() return square end} end
    Clock.now=function() return now end
    local count=0
    local function delta(a,b) return math.atan2(math.sin(a-b),math.cos(a-b)) end
    for facing=0,330,30 do
        for bearing=0,315,45 do
            D.clear(actor)
            actor:setDirectionAngle(facing)
            local start=actor:getDirectionAngleRadians()
            local dx,dy=math.cos(math.rad(bearing)),math.sin(math.rad(bearing))
            assert(D.start(actor,14710.5+dx*3,14710.5+dy*3,.75),"Native pull failed")
            assert(not actor:isDeferredMovementEnabled(),"Native animation movement remains enabled")
            assert(not actor:isStaggerBack(),"Pull entered competing native shove")
            for step=1,10 do
                local previous=actor:getDirectionAngleRadians()
                now=now+50;D.update(actor)
                local angle=actor:getDirectionAngleRadians()
                assert(math.abs(delta(angle,previous))<=math.rad(9)+.00001,"Native facing snapped")
                assert(math.abs(delta(angle,start))<=math.pi/4+.00001,"Native turn exceeded nearest quarter")
                local x,y=actor:getNextX()-actor:getX(),actor:getNextY()-actor:getY()
                assert(x*dx+y*dy>0 and math.abs(x*dy-y*dx)<.001,"Native pull diverged from muzzle")
                count=count+1
            end
            assert(actor:getBumpType()=="" and actor:getX()==14710.5,"Native reaction failed to clean up or teleported")
            now=now+151;D.update(actor)
            assert(actor:isDeferredMovementEnabled(),"Native movement was not restored after blend-out")
        end
    end
    assert(not Motion.request(actor,"push","c481-tether",14708,14710.5,.35),"Obsolete push accepted")
    D.clear(actor);Clock.now=savedNow;getCell=savedCell
    print("[OMHTT-C481] native-pull steps="..count.." rotation=smooth-max45 direction=muzzle no-native-shove=true rendered=false")
end
