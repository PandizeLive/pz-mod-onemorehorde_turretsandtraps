return function(player)
    local W=require("OMHTT/ControlWorld")
    local P=require("OMHTT/ControlPower")
    local B=require("OMHTT/TurretBattery")
    local Action=require("OMHTT/ControlAction")
    local Sensor=require("OMHTT/ControlSensor")
    local fixture=ModData.getOrCreate("OMHTTNativeTriggers")
    if EXPECT_READ then
        local saved=W.records().records[fixture.lever]
        assert(saved and saved.latched==true and saved.controller==fixture.controller,"Lever latch/assignment did not survive restart")
        local laser=W.records().records[fixture.laser]
        assert(laser and require("OMHTT/ControlAccess").laserRange()==10 and laser.facing=="e","Laser Sandbox range/facing did not survive restart")
        print("[OMHTT-C381] native triggers fresh-process=latch/range/assignment preserved")
    end
    local oldCell,oldTime=getCell,getGameTime
    local cell,time=getCell(),getGameTime()
    local oldX,oldY,oldZ,oldSquare=player:getX(),player:getY(),player:getZ(),player:getSquare()
    local lookup={}
    local base=14000
    for x=base-1,base+12 do
        for y=999,1002 do
            local square=IsoGridSquare.new(cell,nil,x,y,0)
            square:getObjects():add(IsoObject.new(square,"floors_interior_tilesandwood_01_0","floor"))
            square:RecalcProperties()
            lookup[x .. ":" .. y]=square
        end
    end
    local square=lookup[base .. ":1000"]
    local place = require("OMHTT/ControlDefinitions")
    local checks = 0
    for _, family in pairs({"fixtures_bathroom_01_", "street_decoration_01_", "lighting_outdoor_01_"}) do
        local found = false
        for i = 0, 63 do
            local sprite = getSprite(family .. i)
            if sprite and sprite:getProperties():has(IsoPropertyType.BLOCKS_PLACEMENT) then
                local obstruction = IsoObject.new(square, family .. i, "native-obstruction")
                square:getObjects():add(obstruction); square:RecalcProperties()
                assert(not place.controller({square = square}), "Controller overlapped native obstruction " .. family .. i)
                square:getObjects():remove(obstruction); square:RecalcProperties()
                assert(place.controller({square = square}), "Removed native obstruction still blocks Controller")
                checks = checks + 1; found = true
                print("[OMHTT-C471] placement native-blocker=" .. family .. i .. " rejected=true removed=allowed")
                break
            end
        end
        assert(found, "No native BlocksPlacement evidence for " .. family)
    end
    assert(checks == 3, "Native obstruction family coverage missing")
    getCell=function() return {getGridSquare=function(_,x,y,z) return z==0 and lookup[x .. ":" .. y] or nil end} end
    local motion, clock = require("OMHTT/DefenseDisplacement"), require("OMHTT/ControlClock")
    local nativeNow, motionTime = clock.now, 1000
    clock.now = function() return motionTime end
    local actor = IsoZombie.new(cell)
    actor:setCurrent(square);actor:setX(base+.5);actor:setY(1000.5);actor:setZ(0)
    motion.start(actor,false,base-2,1000.5,.35)
    motionTime=1050;motion.update(actor)
    assert(actor:getNextX()>actor:getX() and math.abs(actor:getNextY()-actor:getY())<.0001,
        "Native tether pending movement must point away from its muzzle")
    motion.start(actor,true,base-2,1000.5,.75)
    motionTime=1100;motion.update(actor)
    assert(actor:getNextX()<actor:getX() and math.abs(actor:getNextY()-actor:getY())<.0001,
        "Native tether pending movement must point toward its muzzle")
    motion.clear(actor);clock.now=nativeNow
    print("[OMHTT-C471] native-tether pending-push=away pending-pull=toward world-position=unchanged")
    local hours=time:getWorldAgeHours()
    getGameTime=function() return {getWorldAgeHours=function() return hours end,getMinutesPerDay=function() return time:getMinutesPerDay() end} end
    player:setCurrent(square);player:setX(base+.5);player:setY(1000.5);player:setZ(0)
    local wallInfo=SpriteConfigManager.GetObjectInfo("WoodenWallLvl1")
    local wallSprite=wallInfo:getFace("w"):getTileInfo(0,0,0):getSpriteName()
    square:getObjects():add(IsoObject.new(square,wallSprite,"wall"));square:RecalcProperties()
    local function create(kind,sprite)
        local object=IsoThumpable.new(cell,square,sprite,false)
        square:getObjects():add(object);square:getSpecialObjects():add(object)
        local info=SpriteConfigManager.GetObjectInfo("OMHTTDeploy" .. kind)
        GameEntityFactory.CreateIsoObjectEntity(object,info:getScript():getParent(),true)
        local item=player:getInventory():AddItem(require("OMHTT/ControlDefinitions").types[kind])
        item:setCondition(37)
        local inputs=ArrayList.new();inputs:add(item)
        W.create({thumpable=object,character=player,facing="e",craftRecipeData={getAllConsumedItems=function() return inputs end}})
        assert(object:getHealth()==37,"New trigger placement healed exact condition")
        W.state(object).recoverAt=0
        return object
    end
    local queue = require("OMHTT/ControlAutoAssign")
    queue.reset()
    local controller=create("Controller","omhtt_turret_01_21")
    local battery=controller:getContainer():AddItem("Base.CarBattery1")
    battery:setCurrentUsesFloat(1)
    assert(P.refresh(controller),"Native Controller battery rejected")
    local lever=create("Lever","omhtt_turret_01_34")
    local laser=create("Laser","omhtt_turret_01_30")
    local ls,ss=W.state(lever),W.state(laser)
    local nativeGameTime = GameTime
    print("[OMHTT-C471] queue nativePaused=" .. tostring(GameTime.isGamePaused()) .. " fixtureJobs=" .. queue.last)
    GameTime = {isGamePaused = function() return false end}
    for _ = 1, 2000 do
        queue.tick()
        if queue.first > queue.last then break end
    end
    GameTime = nativeGameTime
    print("[OMHTT-C471] queue remaining=" .. (queue.last - queue.first + 1) .. " assigned=" .. tostring(ls.controller))
    assert(ls.controller==W.state(controller).id and ss.controller==ls.controller,"New trigger auto-assignment failed")
    assert(not lever:isThumpable() and not laser:isThumpable(),"Triggers must never be thump targets")
    local toggle=Action:new(player,lever,"Toggle",nil,nil,ls.id)
    local network=NetTimedAction.new();network:set(player,toggle)
    assert(toggle:complete() and ls.latched and ls.active and not toggle:complete(),"Native toggle authority/replay failed")
    local before=B.charge(battery)
    hours=hours+1
    W.updateInput(lever,true)
    assert(math.abs(before-B.charge(battery)-(1/48+.0001))<.000001,"Native fractional active drain changed")
    Sensor.step(laser,ss)
    assert(ss.powered and ss.beamLength>9.9,"Native beam geometry blocked unobstructed lane: " .. tostring(ss.beamLength))
    local actor=IsoZombie.new(cell)
    local near=lookup[(base+3) .. ":1000"]
    actor:setX(base+3.5);actor:setY(1000.5);actor:setZ(0);actor:setCurrent(near);actor:setCrawler(true)
    near:getMovingObjects():add(actor)
    Sensor.step(laser,ss)
    assert(ss.active,"Crawler must interrupt laser")
    near:getMovingObjects():remove(actor)
    actor:setY(1001.5)
    Sensor.step(laser,ss)
    assert(not ss.active,"Cleared beam remained active")
    assert(not Action:new(player,laser,"BeamRange",6,nil,ss.id):complete(),"Per-device range edits must be rejected")
    assert(require("OMHTT/ControlAccess").laserRange()==10,"Native default laser range must be ten tiles")
    assert(not Action:new(player,laser,"BeamRange",11,nil,ss.id):complete(),"Out-of-range edit accepted")
    local blocking=lookup[(base+4) .. ":1000"]
    local wall=IsoObject.new(blocking,wallSprite,"block")
    blocking:getObjects():add(wall);blocking:RecalcProperties()
    Sensor.step(laser,ss)
    assert(ss.beamLength<4 and not ss.active,"Wall must shorten beam without generating input")
    blocking:getObjects():remove(wall);blocking:RecalcProperties()
    local door=IsoDoor.new(cell,blocking,"fixtures_doors_01_1",false)
    blocking:getObjects():add(door);blocking:getSpecialObjects():add(door);blocking:RecalcProperties()
    Sensor.step(laser,ss)
    assert(ss.beamLength<4 and not ss.active,"Closed door must shorten beam without generating input")
    door:setOpen(true);blocking:RecalcProperties()
    Sensor.step(laser,ss)
    assert(ss.beamLength>5.9 and not ss.active,"Opening door must restore beam without generating input")
    blocking:getObjects():remove(door);blocking:getSpecialObjects():remove(door);blocking:RecalcProperties()
    W.removed(lever);W.bind(lever)
    assert(W.state(lever)==ls and ls.latched and not ls.active,"Reload must retain latch without replaying output before recovery")
    ls.recoverAt=0
    W.updateInput(lever,ls.latched)
    assert(ls.active,"Powered reload must reconcile current ON latch")
    local rate=getScriptManager():getCraftRecipe("Base.OMHTTCraftLaser"):getTime()
    assert(math.abs(rate*5-20*time:getMultiplierFromTimeDelta(1))<.001,"Laser crafting must take 20 normal-speed seconds")
    fixture.lever,fixture.laser,fixture.controller=ls.id,ss.id,W.state(controller).id
    print("[OMHTT-C381] native triggers craft/toggle/authority/fractional-power/crawler/range/wall/door/reload=passed")
    Sensor.remove(laser)
    getCell,getGameTime=oldCell,oldTime
    player:setCurrent(oldSquare);player:setX(oldX);player:setY(oldY);player:setZ(oldZ)
end
