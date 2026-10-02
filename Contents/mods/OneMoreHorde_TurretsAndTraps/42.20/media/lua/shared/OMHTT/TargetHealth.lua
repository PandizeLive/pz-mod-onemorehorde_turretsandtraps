local H = {}

---@param zombie IsoZombie Newly created zombie
---@return nil
function H.created(zombie)
    if isClient() or isServer() then return end
    local data = zombie:getModData()
    if not data.OMHTTInitialHealth then data.OMHTTInitialHealth = zombie:getHealth() end
end

---@param zombie IsoZombie Candidate
---@return number health Recorded baseline, zero when unknown
function H.maximum(zombie)
    local data = zombie:getModData()
    return tonumber(data.OMHToughnessInitialHealth) or tonumber(data.OMHTTInitialHealth) or 0
end

Events.OnZombieCreate.Add(H.created)
return H
