local H = {}
local baselines = setmetatable({}, {__mode = "k"})

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
    if isServer() then baselines[zombie] = zombie:getHealth(); return end
    local data = zombie:getModData()
    if not data.OMHTTInitialHealth then data.OMHTTInitialHealth = zombie:getHealth() end
end

---@param zombie IsoZombie Candidate
---@return number health Recorded baseline, zero when unknown
function H.maximum(zombie)
    if instanceof(zombie, "IsoPlayer") then return 1 end
    if isServer() then
        local maximum = math.max(baselines[zombie] or 0, zombie:getHealth())
        baselines[zombie] = maximum
        return maximum
    end
    local data = zombie:getModData()
    return tonumber(data.OMHToughnessInitialHealth) or tonumber(data.OMHTTInitialHealth) or 0
end

Events.OnZombieCreate.Add(H.created)
return H
