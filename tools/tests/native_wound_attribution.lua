local W = {}
local marker = "[OMHTT-XPProbe]"
local observedPlayer
local damageEvents = 0

---@param player IsoGameCharacter Victim
---@param reason string Native damage reason
---@param amount number Native input
---@return nil
local function observe(player, reason, amount)
    if player ~= observedPlayer then return end
    damageEvents = damageEvents + 1
end

---@param body BodyDamage Native body
---@param scratch number Scratch timer
---@param cut number Cut timer
---@param bleed number Bleeding timer
---@param bandage boolean Whether to suppress open wounds
---@return BodyPart
local function configure(body, scratch, cut, bleed, bandage)
    body:RestoreToFullHealth()
    local part = body:getBodyPart(BodyPartType.ForeArm_L)
    if scratch > 0 then
        part:setScratched(true, true)
    end
    if cut > 0 then
        part:setCut(true, true)
    end
    part:setScratchTime(scratch)
    part:setCutTime(cut)
    part:setBleedingTime(bleed)
    part:setBandaged(bandage, 10)
    return part
end

---@param body BodyDamage Native body
---@param label string Case identifier
---@param scratch number Scratch timer
---@param cut number Cut timer
---@param bleed number Bleeding timer
---@param bandage boolean Whether bandaged
---@return nil
local function measure(body, label, scratch, cut, bleed, bandage)
    local part = configure(body, scratch, cut, bleed, bandage)
    local before = body:getOverallBodyHealth()
    local count = damageEvents
    local scale = part:getDamageScaler() * getGameTime():getMultiplier()
    local prediction = 0
    if not bandage then
        if scratch > 0 then
            prediction = prediction + .9375 * scale * BodyPartType.getDamageModifyer(part:getIndex())
        end
        if cut > 0 then
            prediction = prediction + 1.875 * scale * BodyPartType.getDamageModifyer(part:getIndex())
        end
        prediction = prediction + .2857143 * scale * bleed / 10
    end
    part:DamageUpdate()
    body:calculateOverallHealth()
    local loss = before - body:getOverallBodyHealth()
    local callbacks = damageEvents - count
    assert(math.abs(loss - prediction) < .0001, "Isolated wound predictor differs from native health loss")
    if bleed == 0 or bandage then
        assert(callbacks == 0, "Unexpected event for silent/suppressed wound damage")
    else
        assert(callbacks == 1, "Expected one bleeding callback")
    end
    print(marker .. " woundCase=" .. label .. " multiplier=" .. getGameTime():getMultiplier()
        .. " loss=" .. loss .. " predicted=" .. prediction .. " callbacks=" .. callbacks)
end

---@param player IsoPlayer Native fixture player
---@return table
function W.run(player)
    observedPlayer = player
    Events.OnPlayerGetDamage.Add(observe)
    local body = player:getBodyDamage()
    local time = getGameTime()
    local originalEffectiveMultiplier = time:getMultiplier()
    time:setMultiplier(1)
    local originalMultiplier = originalEffectiveMultiplier / time:getMultiplier()
    for index = 1, 2 do
        time:setMultiplier(index == 1 and 1 or 5)
        measure(body, "scratch", 10, 0, 0, false)
        measure(body, "cut", 0, 10, 0, false)
        measure(body, "bleeding", 0, 0, 10, false)
        measure(body, "mixed", 10, 10, 10, false)
        measure(body, "bandaged", 10, 10, 10, true)
    end
    time:setMultiplier(originalMultiplier)
    assert(math.abs(time:getMultiplier() - originalEffectiveMultiplier) < .000001,
        "Probe did not restore the original effective game multiplier")
    local part = configure(body, 10, 10, 10, false)
    part:setCutTime(100)
    part:setCut(true, true)
    local replacementCut = part:getCutTime()
    assert(replacementCut > 0 and replacementCut < 100, "Cut no longer replaces the old timer")
    part:setScratchTime(100)
    part:setScratched(true, true)
    local replacementScratch = part:getScratchTime()
    assert(replacementScratch > 0 and replacementScratch < 100, "Scratch no longer replaces the old timer")
    print(marker .. " woundReplacement=true oldCut=100 newCut=" .. replacementCut
        .. " oldScratch=100 newScratch=" .. replacementScratch)

    part = configure(body, 10, 10, 10, false)
    local minimum, maximum = 1000000, -1
    for index = 1, 64 do
        part:generateBleeding()
        local value = part:getBleedingTime()
        minimum = math.min(minimum, value)
        maximum = math.max(maximum, value)
        assert(part:getScratchTime() == 10 and part:getCutTime() == 10, "Bleeding generation changed the source timers")
    end
    assert(maximum > minimum, "Expected rerolled aggregate bleeding from unchanged wound timers")
    print(marker .. " woundAggregateRerolled=true samples=64 scratch=10 cut=10 minimum="
        .. minimum .. " maximum=" .. maximum)

    part = configure(body, 10, 0, 0, false)
    part:AddDamage(20)
    body:calculateOverallHealth()
    local before = body:getOverallBodyHealth()
    local count = damageEvents
    body:AddGeneralHealth(1)
    local healedPart = part:getHealth()
    part:DamageUpdate()
    local injuredPart = part:getHealth()
    body:calculateOverallHealth()
    assert(body:getOverallBodyHealth() > before and injuredPart < healedPart and damageEvents == count,
        "Expected silent wound damage hidden by net healing")
    print(marker .. " netHealingHidesWound=true overallBefore=" .. before .. " overallAfter="
        .. body:getOverallBodyHealth() .. " actualLimbLoss=" .. (healedPart - injuredPart) .. " callbacks=0")
    Events.OnPlayerGetDamage.Remove(observe)
    return {body = body, owner = player}
end

return W
