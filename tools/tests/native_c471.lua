return function()
    local Health = require("OMHTT/TargetHealth")
    local Conditional = require("OMHTT/TurretConditionalHit")
    local Stats = require("OMHTT/TurretStats")
    local Damage = require("OMHTT/Damage")
    local saved = SandboxVars.OMHTurretsTraps
    SandboxVars.OMHTurretsTraps = {}
    local stats = Stats.resolve({active = {InitialBlow = 12, Execute = 1}})
    local target = IsoZombie.new(getCell())
    -- Reproduce the installed GlobalObject.addZombiesInOutfit ordering on a real actor.
    target:setHealth(3.7)
    target:getModData().OMHTTInitialHealth = nil
    triggerEvent("OnZombieCreate", target)
    local early = target:getModData().OMHTTInitialHealth
    target:setHealth(1)
    assert(target:getHealth() / early < .9, "Fixture must reproduce the old healthy-target failure")
    local snapshot = Conditional.snapshot(target, stats)
    assert(math.abs(Conditional.damage(target, .2, snapshot) - .74) < .000001, "Native Initial Blow must apply after final spawn health")
    local lost = Damage.apply(target, Conditional.damage(target, .2, snapshot), "turret-c471", "arc")
    assert(math.abs(lost - .74) < .000001 and math.abs(target:getHealth() - .26) < .000001,
        "Native applied Arc loss, rather than UI base damage, must be 74")
    assert(Conditional.snapshot(target, stats).bonus == 1, "Second hit must not reset baseline")
    target:setHealth(.1801)
    assert(not Conditional.snapshot(target, stats).execute, "Above 18 percent must survive Execute classification")
    target:setHealth(.18)
    snapshot = Conditional.snapshot(target, stats)
    assert(snapshot.execute and math.abs(Conditional.damage(target, .01, snapshot) - target:getHealth()) < .000001,
        "Execute must finish actual remaining native health at 18 percent")
    -- Native modData survives the ordinary character binary save/load path.
    OMHTT_C471HealthZombie = target
    target:setHealth(.1)
    assert(math.abs(Health.maximum(target) - 1) < .000001, "Damage must not replace maximum health")
    target:setHealth(3.7)
    target:getModData().OMHTTInitialHealth = nil
    triggerEvent("OnZombieCreate", target)
    target:setHealth(1)
    triggerEvent("OnHitZombie", target, nil, nil, nil)
    target:setHealth(.5)
    assert(Health.maximum(target) == 1 and Conditional.snapshot(target, stats).bonus == 1,
        "A native weapon pre-hit event freezes the baseline before damage")
    SandboxVars.OMHTurretsTraps = saved
    local Motion = require("OMHTT/DefenseMotion")
    local previousMotion, previousServer = Motion.request, isServer
    local requests = 0
    Motion.request = function(_, kind)
        assert(kind == "stagger", "Native Impact requested wrong reaction")
        requests = requests + 1
        return true
    end
    local origin = {getX=function() return 0 end, getY=function() return 0 end}
    for _, server in pairs({false, true}) do
        isServer = function() return server end
        local actor = IsoZombie.new(getCell())
        actor:setHealth(1)
        assert(Conditional.impact(actor, origin, {impactReady=true, stats={impact=100}}), "Native Impact must accept an unnamed standing actor")
        assert(not Conditional.impact(actor, origin, {impactReady=true, stats={impact=100}}), "Native Impact recovery guard failed")
        print("[OMHTT-C528] native-impact server=" .. tostring(server) .. " animation=" .. tostring(actor:getCurrentStateName()) .. " accepted=true repeat=blocked")
    end
    assert(requests == 2, "Native Impact duplicate reaction")
    Motion.request, isServer = previousMotion, previousServer
    local Reservation = require("OMHTT/ControlBuildReservation")
    local Footprint = require("OMHTT/ControlPokeFootprint")
    Reservation.install()
    assert(ISBuildIsoEntity.omhttReservation, "Native build hook was not installed")
    local reserved = Footprint.reserved
    Footprint.reserved = function(square) return square ~= nil end
    -- Real native entry points, with reservation rejection before their
    -- downstream crafting state/material requirements can be accessed.
    local nativeSquare = IsoGridSquare.new(getCell(), nil, 10600, 9800, 0)
    assert(not ISBuildIsoEntity.isValidPerSquare({north=true}, nativeSquare, nil, true, false, false),
        "Native entity placement allowed a reserved stabilizer")
    assert(not ISWoodenWall.isValid({north=true}, nativeSquare), "Native wall placement allowed a stabilizer")
    local savedWorld, savedCell, savedServer = getWorld, getCell, isServer
    local lookup = {getGridSquare=function() return nativeSquare end}
    getWorld = function() return {getCell=function() return lookup end} end
    getCell = function() return lookup end
    isServer = function() return false end
    local cursor = {north=true, character={isBuildCheat=function() return false end},
        getFace=function() return {} end, getOpenFace=function() return nil end,
        buildPanelLogic={performCurrentRecipe=function() error("Reserved construction consumed materials") end}}
    cursor.isValid = function(self, square) return ISBuildIsoEntity.isValidPerSquare(self, square, nil, true, false, false) end
    assert(ISBuildIsoEntity.create(cursor, 10600, 9800, 0, true, "wall") == false,
        "Native entity completion bypassed reservation validation")
    assert(ISWoodenWall.create(cursor, 10600, 9800, 0, true, "wall") == false,
        "Native legacy completion bypassed reservation validation")
    getWorld, getCell, isServer = savedWorld, savedCell, savedServer
    Footprint.reserved = reserved
    print("[OMHTT-C531] native-build entity=blocked legacy=blocked completion=blocked materials=untouched hooks=installed")

    local V = require("OMHTT/NativeTurretVolley")
    local Actors = require("OMHTT/DefenseActors")
    local Effects = require("OMHTT/DefenseEffects")
    local Clock = require("OMHTT/TurretClock")
    local Budget = require("OMHTT/TurretScheduler")
    local Combat = require("OMHTT/PrototypeCombat")
    local backup = {cell=getCell, server=isServer, occupants=Actors.occupants, emit=Effects.emit,
        now=Clock.now, limit=Budget.limit, lane=Combat.clearLane}
    local squares, now, impacts = {}, 0, 0
    for x=15100,15110 do squares[x]=IsoGridSquare.new(savedCell(), nil, x, 15100, 0) end
    getCell = function() return {getGridSquare=function(_,x,y,z) if y==15100 and z==0 then return squares[x] end end} end
    isServer = function() return false end
    Clock.now = function() return now end
    Budget.limit = function() return math.huge end
    Combat.clearLane = function() return true end
    Effects.emit = function(command) if command=="Impact" then impacts=impacts+1 end end
    for _,count in pairs({1,2,4,5,6,8,16}) do
        local actor=IsoZombie.new(savedCell())
        actor:setCurrent(squares[15105]);actor:setX(15105.5);actor:setY(15100.5);actor:setZ(0);actor:setHealth(10)
        Actors.occupants=function(square)
            return {size=function() return square==squares[15105] and 1 or 0 end,get=function() return actor end}
        end
        V.reset();now=0;impacts=0
        local group={kind="splitter",stats={firearm=false,fragment=0},hits={},remaining=count}
        for i=1,count do V.ray({id="turret-c531-native",shots=count},15100.5,15100.5,0,0,10,.1,group,i) end
        for elapsed=0,245,5 do now=elapsed;V.tick() end
        assert(actor:getHealth()==10 and impacts==0,"Native child damaged or popped before contact")
        now=250;V.tick()
        assert(math.abs(actor:getHealth()-(10-count*.1))<.0001 and impacts==count,
            "Native stacked contact did not apply exact health loss and impacts")
    end
    V.reset()
    getCell,isServer,Actors.occupants,Effects.emit,Clock.now,Budget.limit,Combat.clearLane=
        backup.cell,backup.server,backup.occupants,backup.emit,backup.now,backup.limit,backup.lane
    print("[OMHTT-C531] native-projectile stacks=1,2,4,5,6,8,16 contactMs=250 earlyDamage=0 health=exact impacts=once")
    print("[OMHTT-C471] native-conditional spawnOverride=74 actualLoss=74 execute=18 boundary=pass damagedBaseline=retained")
end
