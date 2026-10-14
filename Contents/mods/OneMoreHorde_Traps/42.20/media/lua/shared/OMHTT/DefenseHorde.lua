local H = {}

---@param zombie IsoZombie Candidate
---@return boolean allowed
---@nodiscard
function H.allowed(zombie)
    if isClient() or not zombie then return false end
    local core = rawget(_G, "OneMoreHordeDefenseIntegration")
    if core and core.API_VERSION == 1 then
        return core.authorize(zombie)
    end
    -- Unrecognized Horde targets cannot certify consent.
    local data = zombie:getModData()
    return data.OMHEventId == nil and data.OMHModTag == nil
end

---@param zombie IsoZombie Victim
---@param amount number Native damage
---@param source string Device identity
---@param kind string Effect family
---@return boolean allowed
---@return table|nil core
---@return table|nil token
function H.beginDamage(zombie, amount, source, kind)
    if isClient() or not zombie then return false end
    local core = rawget(_G, "OneMoreHordeDefenseIntegration")
    if core and core.API_VERSION == 1 then
        local allowed, token = core.beginDamage(zombie, source, kind, zombie:getHealth() - amount < 0.000001)
        return allowed, core, token
    end
    return H.allowed(zombie)
end

return H
