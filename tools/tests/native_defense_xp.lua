local marker = "[OMHTT-XPProbe]"
local actors = {}
local observations = {}
local bleeding = {}
local nativeComplete = false
LuaEventManager.AddEvent("OnOMHTTXPProbeNative")

---@param callback function Isolated Java fixture; invoked on the native game thread
---@return nil
local function nativeFixture(callback)
    callback()
    nativeComplete = true
end

Events.OnOMHTTXPProbeNative.Add(nativeFixture)

---@return nil
local function pumpNativeFixture()
    if not OMHTT_XPProbe or nativeComplete then return end
    LuaEventManager.RunQueuedEvents()
end

Events.OnTickEvenPaused.Add(pumpNativeFixture)

---@param target IsoGameCharacter Victim
---@param kind string Damage reason
---@param amount number Native amount
---@param ... unknown Additional native arguments
---@return nil
local function playerDamage(target, kind, amount, ...)
    if kind ~= "BLEEDING" or not actors[target] then return end
    bleeding[#bleeding + 1] = {target = target, kind = kind, amount = amount, extra = select("#", ...)}
end

---@param kind string Native callback
---@param target IsoGameCharacter Victim
---@param amount number? Native input
---@return nil
local function observe(kind, target, amount)
    if not actors[target] then return end
    observations[#observations + 1] = {kind = kind, health = target:getHealth(), amount = amount}
    print(marker .. " event=" .. kind .. " health=" .. target:getHealth() .. " input=" .. tostring(amount))
end

---@param target IsoZombie Victim
---@param attacker IsoGameCharacter Attacker
---@param part BodyPartType Native visual body part
---@param weapon HandWeapon Weapon
---@return nil
local function beforeZombie(target, attacker, part, weapon)
    observe("OnHitZombie", target)
end

---@param attacker IsoGameCharacter Attacker
---@param target IsoGameCharacter Victim
---@param weapon HandWeapon Weapon
---@param damage number Native input
---@return nil
local function beforeWeapon(attacker, target, weapon, damage)
    observe("OnWeaponHitCharacter", target, damage)
end

---@param attacker IsoGameCharacter Attacker
---@param weapon HandWeapon Weapon
---@param target IsoGameCharacter Victim
---@param damage number Native input
---@return nil
local function afterWeapon(attacker, weapon, target, damage)
    observe("OnWeaponHitXp", target, damage)
end

---@param target IsoZombie Victim
---@return nil
local function dead(target)
    observe("OnZombieDead", target)
end

---@return nil
local function run()
    local cell = getCell()
    local square = IsoGridSquare.new(cell, nil, 72, 72, 0)
    local chunk = IsoChunk.new(cell)
    chunk:assignLoadID()
    chunk:setSquare(0, 0, 0, square)
    local player = IsoPlayer.new(cell)
    player:setCurrent(square)
    player:setX(72.2)
    player:setY(72.2)
    local zombie = IsoZombie.new(cell)
    zombie:setCurrent(square)
    zombie:setX(72.7)
    zombie:setY(72.2)
    zombie:setHealth(1)
    actors[zombie] = true
    local weapon = instanceItem("Base.Hammer")
    assert(weapon, "Native hammer missing")
    weapon:setSplatBloodOnNoDeath(false)
    weapon:setKnockBackOnNoDeath(false)
    player:getInventory():AddItem(weapon)
    player:setPrimaryHandItem(weapon)
    Events.OnHitZombie.Add(beforeZombie)
    Events.OnWeaponHitCharacter.Add(beforeWeapon)
    Events.OnWeaponHitXp.Add(afterWeapon)
    Events.OnZombieDead.Add(dead)
    local before = zombie:getHealth()
    zombie:Hit(weapon, player, .2, true, 1, true)
    assert(zombie:getHealth() == before, "Ignored hit changed health")
    assert(#observations == 2 and observations[2].amount > 0, "Ignored-hit callback shape changed")
    print(marker .. " ignored input=" .. observations[2].amount .. " loss=0")
    observations = {}
    zombie:Hit(weapon, player, .2, false, 1, true)
    local after = zombie:getHealth()
    assert(after < before and #observations == 2, "Native hit/observation mismatch")
    assert(observations[1].health == before and observations[2].health == before, "Hit events no longer precede loss")
    print(marker .. " direct input=.2 loss=" .. (before - after) .. " postXpFromDirectHit=false")
    observations = {}
    zombie:Hit(weapon, player, .2, false, 1, true)
    assert(observations[1].health == after, "Sequential hit did not expose preceding result")
    print(marker .. " sequential before=" .. after .. " after=" .. zombie:getHealth())
    local body = player:getBodyDamage()
    body:RestoreToFullHealth()
    local part = body:getBodyPart(BodyPartType.ForeArm_L)
    local overall = body:getOverallBodyHealth()
    part:AddDamage(20)
    local stale = body:getOverallBodyHealth()
    body:calculateOverallHealth()
    print(marker .. " bodypart requested=20 partLoss=" .. (100 - part:getHealth())
        .. " overallBefore=" .. overall .. " overallBeforeRecalculation=" .. stale
        .. " overallAfter=" .. body:getOverallBodyHealth())
    assert(math.abs(100 - part:getHealth() - 20) < .0001, "Body part damage did not apply")
    assert(overall - body:getOverallBodyHealth() < 20, "Limb damage unexpectedly equals overall loss")
    part:AddDamage(1000)
    assert(part:getHealth() == 0, "Body part overkill not clamped")
    body:RestoreToFullHealth()
    actors[player] = true
    Events.OnPlayerGetDamage.Add(playerDamage)
    local left = body:getBodyPart(BodyPartType.ForeArm_L)
    local right = body:getBodyPart(BodyPartType.ForeArm_R)
    left:setBleedingTime(10)
    right:setBleedingTime(10)
    left:DamageUpdate()
    right:DamageUpdate()
    body:calculateOverallHealth()
    assert(#bleeding == 2, "Expected two native wound callbacks")
    assert(bleeding[1].target == bleeding[2].target and bleeding[1].kind == bleeding[2].kind
        and bleeding[1].amount == bleeding[2].amount, "Equal wounds produced different callback data")
    assert(bleeding[1].extra == 0 and bleeding[2].extra == 0, "Native wound callback gained source information")
    print(marker .. " bleeding twoDifferentLimbs=true identicalCallbacks=true extraArguments=0"
        .. " overallLoss=" .. (100 - body:getOverallBodyHealth()))
    local wounds = require("WoundProbe").run(player)
    OMHTT_XPProbe = {player = player, zombie = zombie, weapon = weapon, observations = observations, wounds = wounds}
    print(marker .. " completed=true game=" .. getCore():getVersionNumber() .. " clients=0 liveAttributionProven=false")
end

Events.OnServerStarted.Add(run)
