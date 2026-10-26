local H = {}
OMHTT_TargetHealth = H
local baselines = setmetatable({}, {__mode = "k"})
local pending = setmetatable({}, {__mode = "k"})

---@param actor IsoGameCharacter Candidate
---@return number health Comparable current health
function H.current(actor)
    if instanceof(actor, "IsoPlayer") then return actor:getBodyDamage():getOverallBodyHealth() / 100 end
    return actor:getHealth()
end

---@param zombie IsoZombie Newly created zombie
---@return nil
function H.created(zombie)
    if isClient() then return end
    if not isServer() and zombie:hasModData()
        and (tonumber(zombie:getModData().OMHTTInitialHealth) or 0) > 0 then return end
    -- Native spawners can replace health AFTER OnZombieCreate returns.
    -- Finalize at the first update or pre-damage observation, not at spawn notification.
    pending[zombie] = true
    baselines[zombie] = nil
    if not isServer() then
        zombie:getModData().OMHTTInitialHealth = zombie:getHealth()
    end
end

---@param zombie IsoZombie First simulation update or pre-hit victim
---@return nil
function H.settle(zombie)
    if isClient() or not pending[zombie] then return end
    pending[zombie] = nil
    local health = zombie:getHealth()
    if health <= 0 then return end
    baselines[zombie] = health
    if not isServer() then
        zombie:getModData().OMHTTInitialHealth = health
    end
end

---@param zombie IsoZombie Candidate
---@return number health Recorded baseline, zero when unknown
function H.maximum(zombie)
    if instanceof(zombie, "IsoPlayer") then return 1 end
    H.settle(zombie)
    if isServer() then
        local maximum = baselines[zombie]
        if not maximum then return 0 end
        maximum = math.max(maximum, zombie:getHealth())
        baselines[zombie] = maximum
        return maximum
    end
    local data = zombie:getModData()
    local horde = tonumber(data.OMHToughnessInitialHealth)
    if horde and horde > 0 then return horde end
    local maximum = tonumber(data.OMHTTInitialHealth) or 0
    if maximum > 0 and zombie:getHealth() > maximum then
        maximum = zombie:getHealth()
        data.OMHTTInitialHealth = maximum
    end
    return maximum
end

Events.OnZombieCreate.Add(H.created)
Events.OnZombieUpdate.Add(H.settle)
Events.OnHitZombie.Add(H.settle)
return H
