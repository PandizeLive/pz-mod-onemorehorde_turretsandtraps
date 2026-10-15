local H = {}

---@param source IsoObject? Native sound source
---@param x number World X
---@param y number World Y
---@param z number Floor
---@param radius number Native attraction radius
---@param volume number Native attraction strength
---@return boolean emitted
function H.sound(source, x, y, z, radius, volume)
    if isClient() or radius <= 0 then return false end
    local core = rawget(_G, "OneMoreHordeDefenseIntegration")
    if core and (core.API_VERSION ~= 1 or not core.worldSoundAllowed or not core.worldSoundAllowed()) then return false end
    addSound(source, x, y, z, radius, volume)
    return true
end

---@param zombie IsoZombie Candidate
---@return table? lease Exact authorized run, held only on the server
function H.capture(zombie)
    if isClient() or not zombie then return nil end
    local core = rawget(_G, "OneMoreHordeDefenseIntegration")
    if core and core.API_VERSION == 1 then
        local allowed, owner, event = core.authorize(zombie)
        if not allowed then return nil end
        return {core = core, owner = owner, event = event}
    end
    if H.allowed(zombie) then return {} end
end

---@param zombie IsoZombie Candidate
---@param lease table? Original authorization
---@return boolean valid Same receiving run and consent
function H.matches(zombie, lease)
    if not lease then return false end
    local current = H.capture(zombie)
    return current ~= nil and current.core == lease.core and current.owner == lease.owner and current.event == lease.event
end

---@param zombie IsoZombie Authorized candidate
---@param lease table Original receiving run
---@param source string Server device identity
---@param kind string Effect family
---@return boolean marked Assistance classified before an asynchronous effect can reach its owner
function H.mark(zombie, lease, source, kind)
    if not H.matches(zombie, lease) then return false end
    if not lease.core then return true end
    local allowed, token = lease.core.beginDamage(zombie, source, kind, false)
    if allowed then lease.core.endDamage(zombie, token) end
    return allowed
end

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
---@param lethal boolean? Confirmed terminal result from an asynchronous owner receipt
---@return boolean allowed
---@return table|nil core
---@return table|nil token
function H.beginDamage(zombie, amount, source, kind, lethal)
    if isClient() or not zombie then return false end
    local core = rawget(_G, "OneMoreHordeDefenseIntegration")
    if core and core.API_VERSION == 1 then
        local allowed, token = core.beginDamage(zombie, source, kind, lethal == true or zombie:getHealth() - amount < 0.000001)
        return allowed, core, token
    end
    return H.allowed(zombie)
end

return H
