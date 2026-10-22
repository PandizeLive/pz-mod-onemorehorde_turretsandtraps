return function(player, controller)
    local C = require("OMHTT/ControlCombat")
    local H = require("OMHTT/TurretPlayerHit")
    local I = require("OMHTT/DefenseInjury")
    local server, name, god, safety = isServer, player:getUsername(), player:isGodMod(), player:getSafety():isEnabled()
    local options = getServerOptions()
    local pvp, safetySystem = options:getBoolean("PVP"), options:getBoolean("SafetySystem")
    options:putOption("PVP", "true")
    options:putOption("SafetySystem", "true")
    player:setUsername("native-target-outsider")
    player:setGodMod(false)
    player:getSafety():setEnabled(false)
    assert(getPlayerFromUsername("native-missing-owner") == nil, "Native username lookup must fail closed for missing owners")
    assert(C.eligible(controller, player), "Native player acquisition/faction/safety/zone APIs failed")
    options:putOption("PVP", "false")
    assert(not C.eligible(controller, player), "Native PvP-off must block targeting")
    options:putOption("PVP", "true")
    player:getSafety():setEnabled(true)
    assert(not C.eligible(controller, player), "Native offline-owner safety must protect safe victim")
    player:getSafety():setEnabled(false)
    local source = C.source(controller)
    local part = player:getBodyDamage():getBodyPart(BodyPartType.ForeArm_L)
    local index = BodyPartType.ToIndex(BodyPartType.ForeArm_L)
    local defense = player:getBodyPartClothingDefense(index, false, true)
    assert(type(defense) == "number" and BodyPartType.FromIndex(index) == BodyPartType.ForeArm_L, "Native limb/clothing API failed")
    -- Exercise native injury mutation via the SP branch, not a connected-client claim.
    local health = part:getHealth()
    isServer = function() return false end
    I.turret(player, index, 4, "none")
    assert(math.abs(part:getHealth() - (health - 4)) < .001, "Native fixed limb damage differs from selected value")
    part:SetHealth(health)
    isServer = server
    local sent, send = {}, sendServerCommand
    sendServerCommand = function(target, module, command, message)
        sent[#sent + 1] = {target = target, module = module, command = command, message = message}
    end
    local root = {playerSource = source, playerEvent = "native:targeting:" .. tostring(getTimestampMs())}
    for i = 1, 12 do H.hit(player, root, "Scrapshot", 1 / 8) end
    assert(#sent == 8 and root.playerBudget[player:getUsername()].used == 32, "Native player volley cap failed")
    local total, wounds = 0, 0
    for i = 1, #sent do
        local packet = sent[i]
        assert(packet.target == player and packet.module == "OMHTT_InjuryV1" and packet.command == "turret", "Wrong injury destination")
        total = total + packet.message.amount
        if packet.message.wound ~= "none" then wounds = wounds + 1 end
        local limb = BodyPartType.FromIndex(packet.message.part)
        assert(limb == BodyPartType.ForeArm_L or limb == BodyPartType.ForeArm_R
            or limb == BodyPartType.UpperLeg_L or limb == BodyPartType.UpperLeg_R, "Invalid native wound limb")
    end
    assert(total <= 32 and wounds <= 1, "Native injury budget/wound roll exceeded")
    sendServerCommand = send
    options:putOption("PVP", tostring(pvp))
    options:putOption("SafetySystem", tostring(safetySystem))
    player:setUsername(name)
    player:setGodMod(god)
    player:getSafety():setEnabled(safety)
    print("[OMHTT-C389] native-player targeting=passed pvp=passed safety=passed clothing=passed limb-damage=passed volley-cap=passed connected-clients=0")
end
