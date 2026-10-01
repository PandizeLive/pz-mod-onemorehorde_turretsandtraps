local G = {}
G.PROFILES = {
    ["Base.Pistol"] = {reload = 2.7, rack = 1.2, muzzle = 0.0823, yaw = 0},
    ["Base.Shotgun"] = {reload = 0.833, rack = 0.6, muzzle = 0.2801, yaw = 0},
    ["Base.HuntingRifle"] = {reload = 0.590, rack = 1.2, muzzle = 0.3468, yaw = 0},
}
G.AMMO = {["Base.Bullets9mm"] = true, ["Base.ShotgunShells"] = true, ["Base.308Bullets"] = true}

---@param head InventoryItem? Candidate
---@return table? profile Supported mechanism
---@nodiscard
function G.profile(head)
    return head and G.PROFILES[head:getFullType()]
end

---@return boolean enabled
---@nodiscard
function G.enabled()
    return SandboxVars.OMHTurretsTraps.FirearmTurrets ~= false
end

---@param gun HandWeapon Supported firearm
---@return string fullType Matching loose ammunition
---@nodiscard
function G.ammoType(gun)
    return gun:getAmmoType():getItemKey()
end

---@param gun HandWeapon Supported firearm
---@return number rounds Magazine plus chamber
---@nodiscard
function G.loaded(gun)
    local chamber = 0
    if gun:isRoundChambered() then chamber = 1 end
    return gun:getCurrentAmmoCount() + chamber
end

---@param gun HandWeapon Supported firearm
---@return table state Persisted mechanical deadlines
function G.state(gun)
    local data = gun:getModData()
    if not data.OMHTTGunCycle then data.OMHTTGunCycle = {schema = 1, nextShot = 0} end
    return data.OMHTTGunCycle
end

---@param gun HandWeapon Supported firearm
---@return nil
function G.cancelLoading(gun)
    local state = G.state(gun)
    state.reloadReady, state.rackReady = nil, nil
end

---@param contents table Exact inventory summary
---@param stats table Effective weapon values
---@param now number Milliseconds
---@param operate boolean Powered world mechanism may move rounds
---@return table cycle Real magazine state
---@return string status
function G.update(contents, stats, now, operate)
    local gun = contents.head
    local state = G.state(gun)
    state.loaded = G.loaded(gun)
    if not G.enabled() then return state, "Disabled" end
    if gun:getCondition() <= 0 then return state, "NoHead" end
    if gun:isJammed() then return state, "Jammed" end
    if gun:getMagazineType() and not gun:isContainsClip() then return state, "NoMagazine" end
    if state.cooldownDuration and state.cooldownDuration ~= stats.cooldown and state.nextShot > now then
        state.nextShot = now + math.min(1, (state.nextShot - now) / state.cooldownDuration) * stats.cooldown
    end
    state.cooldownDuration = stats.cooldown
    if state.loaded == 0 then
        state.rackReady = nil
        if contents.reserve == 0 then state.reloadReady = nil; return state, "Empty" end
        if not operate then return state, "Reloading" end
        local amount = math.min(gun:getMaxAmmo(), contents.reserve)
        local duration = stats.reload
        if not gun:getMagazineType() then duration = duration * amount end
        if not state.reloadReady then state.reloadReady = now + duration end
        if state.reloadDuration and state.reloadDuration > 0 and state.reloadDuration ~= duration and state.reloadReady > now then
            state.reloadReady = now + math.min(1, (state.reloadReady - now) / state.reloadDuration) * duration
        end
        state.reloadDuration = duration
        if now < state.reloadReady then return state, "Reloading" end
        local container, count = gun:getContainer(), 0
        for i = 1, #contents.rounds do
            if count >= amount then break end
            local round = contents.rounds[i]
            if container:contains(round) and round:getFullType() == G.ammoType(gun) then
                container:Remove(round)
                count = count + 1
            end
        end
        gun:setCurrentAmmoCount(count)
        state.reloadReady = nil
        contents.reserve = contents.reserve - count
        state.loaded = G.loaded(gun)
        if count == 0 then return state, "Empty" end
    end
    if gun:haveChamber() and not gun:isRoundChambered() then
        if not operate then return state, "Racking" end
        if not state.rackReady then state.rackReady = now + stats.rack end
        if now < state.rackReady then return state, "Racking" end
        gun:setSpentRoundChambered(false)
        gun:setRoundChambered(true)
        gun:setCurrentAmmoCount(gun:getCurrentAmmoCount() - 1)
        state.rackReady = nil
    end
    state.loaded = G.loaded(gun)
    if now < state.nextShot then return state, "Cooling" end
    return state, "Ready"
end

---@param contents table Current inventory
---@param stats table Effective values
---@param now number Milliseconds
---@return boolean consumed
function G.consume(contents, stats, now)
    local gun = contents.head
    local cycle, status = G.update(contents, stats, now, false)
    if status ~= "Ready" then return false end
    if gun:haveChamber() then
        gun:setRoundChambered(false)
        gun:setSpentRoundChambered(gun:isRackAfterShoot())
        if not gun:isRackAfterShoot() and gun:getCurrentAmmoCount() > 0 then
            gun:setCurrentAmmoCount(gun:getCurrentAmmoCount() - 1)
            gun:setRoundChambered(true)
        end
    else
        gun:setCurrentAmmoCount(gun:getCurrentAmmoCount() - 1)
    end
    cycle.nextShot, cycle.cooldownDuration = now + stats.cooldown, stats.cooldown
    if gun:isRackAfterShoot() then cycle.rackReady = now + stats.rack end
    cycle.loaded = G.loaded(gun)
    return true
end

return G
