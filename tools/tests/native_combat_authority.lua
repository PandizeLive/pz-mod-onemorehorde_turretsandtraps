-- Real native actors on a stock dedicated server. No client transport is simulated by this probe.
return function()
    local loot = require("OMHTT/ModuleLoot")
    local items = ProceduralDistributions.list[loot.POOLS[1]].items
    local found = 0
    for i = 1, #items, 2 do
        if items[i] == "Base.OMHTTModuleFiring" and items[i + 1] > 0 then found = found + 1 end
    end
    assert(found == 1, "Dedicated server did not register module loot exactly once during native startup")
    print("[OMHTT-Smoke] native-server-module-loot startup=registered count=once clients=0")
    local D = require("OMHTT/Damage")
    local P = require("OMHTT/DefenseCombatProtocol")
    local zombie = IsoZombie.new(getCell())
    assert(zombie:getOwner() == nil and zombie:getOwnerPlayer() == nil, "Synthetic zombie unexpectedly owned")
    assert(type(zombie:getOnlineID()) == "number" and type(zombie:getPersistentOutfitID()) == "number", "Combat identity API unavailable")
    zombie:setHealth(1)
    local calls, loss = 0, 0
    local function completed(lost, reason)
        assert(reason == "applied", "Native ownerless damage failed")
        calls, loss = calls + 1, lost
    end
    assert(D.request(zombie, .25, "native-probe", "combat", completed), "Native ownerless request rejected")
    assert(calls == 1 and math.abs(loss - .25) < .00001 and math.abs(zombie:getHealth() - .75) < .00001,
        "Native damage/callback disagrees")
    assert(not D.request(zombie, 0/0, "native-probe", "combat", completed), "Nonfinite native damage accepted")
    zombie:setInvulnerable(true)
    assert(not D.request(zombie, .25, "native-probe", "combat", completed) and calls == 1,
        "Native invulnerable target damaged")
    zombie:setInvulnerable(false)
    local deaths = 0
    local function died(actor)
        if actor == zombie then deaths = deaths + 1 end
    end
    Events.OnZombieDead.Add(died)
    assert(D.request(zombie, 1, "native-probe", "combat", completed), "Native terminal request failed")
    Events.OnZombieDead.Remove(died)
    assert(zombie:isDead() and deaths == 1 and calls == 2 and math.abs(loss - .75) < .00001,
        "Native terminal event or actual loss incorrect")
    assert(not D.request(zombie, 1, "native-probe", "combat", completed), "Dead actor accepted another hit")
    local reserved = IsoZombie.new(getCell())
    reserved:setHealth(P.EPSILON)
    assert(not reserved:isDead() and math.floor(reserved:getHealth() * 1000) >= 1,
        "Native float sentinel dies during thousandth-health conversion")
    reserved:setHealth(0)
    local square = IsoGridSquare.new(getCell(), nil, 9, 9, 0)
    local terminal = IsoZombie.new(getCell())
    terminal:setX(9.5); terminal:setY(9.5); terminal:setZ(0); terminal:setCurrent(square)
    square:getMovingObjects():add(terminal)
    local packs = require("OMHTT/TurretModulePack")
    local settings = SandboxVars.OMHTurretsTraps
    local oldChance, oldRate = settings.PackZombieChance, settings.ModuleLootRate
    settings.PackZombieChance, settings.ModuleLootRate = 100, 1
    terminal:Kill(nil, false)
    settings.PackZombieChance, settings.ModuleLootRate = oldChance, oldRate
    local pack, count = nil, 0
    local inventory = terminal:getInventory():getItems()
    for i = 0, inventory:size() - 1 do
        if inventory:get(i):getFullType() == packs.TYPE then
            pack, count = inventory:get(i), count + 1
        end
    end
    assert(pack and count == 1, "Production death hook did not create exactly one module pack")
    assert(not terminal:isOnDeathDone() and square:getDeadBodys():isEmpty(),
        "Native Kill now completes corpse creation; re-review server death path")
    terminal:die()
    assert(terminal:isOnDeathDone() and square:getDeadBodys():size() == 1,
        "Native death completion did not create exactly one body")
    local body = square:getDeadBodys():get(0)
    assert(body:getContainer():contains(pack), "Native corpse lost pre-death inventory")
    assert(not square:getMovingObjects():contains(terminal), "Corpse completion left a live moving actor")
    terminal:die()
    assert(square:getDeadBodys():size() == 1, "Repeated native completion duplicated the corpse")
    local finished = IsoZombie.new(getCell())
    finished:setX(9.5); finished:setY(9.5); finished:setZ(0); finished:setCurrent(square)
    square:getMovingObjects():add(finished)
    finished:getModData().OMHTTPackRolled = true
    finished:setHealth(.01)
    assert(D.request(finished, .35, "native-probe", "combat"), "Production final hit was rejected")
    assert(finished:isOnDeathDone() and square:getDeadBodys():size() == 2,
        "Production damage stopped at zero health without completing native death")
    local light = IsoLightSource.new(9, 9, 0, .8, .45, .05, 3)
    getCell():addLamppost(light)
    light:setR(.2); light:setG(.1125); light:setB(.0125); light:setActive(false)
    getCell():removeLamppost(light)
    local marker = instanceItem("Base.OMHTTTurretStateAmberVisual")
    marker:setWorldAlpha(.25)
    assert(math.abs(marker:getWorldAlpha() - .25) < .001, "Native marker alpha is not mutable")
    print("[OMHTT-C500] native-death Kill=event-only die=corpse-once loot=retained clients=0")
    print("[OMHTT-Smoke] native-server-combat ownerless=relative death=once invulnerable=preserved sentinel=nonzero clients=0")
end
