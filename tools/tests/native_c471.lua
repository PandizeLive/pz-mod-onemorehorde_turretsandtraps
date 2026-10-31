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
    print("[OMHTT-C471] native-conditional spawnOverride=74 actualLoss=74 execute=18 boundary=pass damagedBaseline=retained")
end
