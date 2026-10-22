---@param player IsoPlayer Native fixture
---@return nil
return function(player)
    local E = require("OMHTT/NativeTurretProc")
    local V = require("OMHTT/NativeTurretVolley")
    local T = require("OMHTT/Turret")
    local Stats = require("OMHTT/TurretStats")
    local store = instanceItem(T.BASE):getInventory()
    local synergy = store:AddItem(T.TYPES.Synergy)
    store:AddItem(T.TYPES.Martyrdom)
    store:AddItem(T.TYPES.Tack)
    local contents = T.contents(store)
    local stats = Stats.resolve(contents)
    assert(contents.modules == 3 and math.abs(contents.powerLoad - 3.5) < .00001 and stats.synergy and stats.tack == 1 and stats.martyrdom == 1.5,
        "Native proc modules did not resolve")
    assert(synergy:getWeight() == instanceItem(T.TYPES.Conservation):getWeight(), "Module encumbrance drift")
    local beforeRegulator = stats.batteryPercent
    local regulator = store:AddItem(T.TYPES.Regulator)
    local regulated = Stats.resolve(T.contents(store))
    assert(math.abs(regulator:getActualWeight() - .2) < .00001 and math.abs(regulated.batteryPercent * 1.25 - beforeRegulator) < .0000001,
        "Native Regulator weight or battery reduction failed")
    assert(regulated.generatorFuel == stats.generatorFuel, "Regulator changed generator consumption")
    regulator:setCondition(0)
    assert(Stats.resolve(T.contents(store)).batteryPercent == beforeRegulator, "Broken Regulator still works")
    local parts = {BodyPartType.ForeArm_L, BodyPartType.ForeArm_R, BodyPartType.UpperLeg_L, BodyPartType.UpperLeg_R}
    local before, after = 0, 0
    player:setGodMod(false)
    -- Reused native save caches may restore the previous probe's recovery timer.
    -- Start this isolated two-hit throttle check outside that saved timer.
    E.injuryAt[player:getPlayerNum()] = nil
    for i = 1, #parts do before = before + player:getBodyDamage():getBodyPart(parts[i]):getHealth() end
    local nativeServer = isServer
    isServer = function() return false end
    local injury = {}
    E.injure(player, injury)
    E.injure(player, injury)
    isServer = nativeServer
    for i = 1, #parts do
        local part = player:getBodyDamage():getBodyPart(parts[i])
        after = after + part:getHealth()
        assert(not part:scratched() and not part:isCut() and not part:bleeding(), "Blunt injury added a wound")
    end
    assert(math.abs(before - after - 4) < .0001, "Native injury throttle or local body damage failed")
    E.injuryAt[player:getPlayerNum()] = nil
    local shot = {stats = stats, damage = .1, managed = true}
    assert(V.reserve(shot), "Native admission rejected")
    local zombie = IsoZombie.new(getCell())
    zombie:setHealth(1)
    E.hit(zombie, true, 100.5, 100.5, 0, {id = "native-proc"}, nil, shot)
    local id = zombie:getModData().OMHTTTackField
    assert(id and E.fields[id] and E.fieldCount > 0, "Native Tack trigger failed")
    E.save()
    E.load()
    assert(E.fields[id] and E.fields[id].expires > require("OMHTT/TurretClock").now(), "Native ModData field reload failed")
    -- Native fixture has finished its admitted shot; load resets runtime reservations.
    V.reset()
    E.fields, E.fieldOrder, E.buckets, E.fieldCount = {}, {}, {}, 0
    E.save()
    print("[OMHTT-Proc] native modules=3 damage=4 wounds=none injuryGuard=passed fieldSave=passed")
end
