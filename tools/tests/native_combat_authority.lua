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
    print("[OMHTT-Smoke] native-server-combat ownerless=relative death=once invulnerable=preserved sentinel=nonzero clients=0")
end
