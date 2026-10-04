local Clock = require("OMHTT/TurretClock")
local G = {servicing = {}}
G.PROFILES = {
    ["Base.Pistol"] = {reload = 2.7, rack = 1.2, muzzle = 0.0823, yaw = 0, roll = -90},
    ["Base.Shotgun"] = {reload = 0.833, rack = 0.6, muzzle = 0.2801, yaw = 0, roll = -90},
    ["Base.HuntingRifle"] = {reload = 0.590, rack = 1.2, muzzle = 0.3468, yaw = 0, roll = -90},
}
G.AMMO = {["Base.Bullets9mm"] = true, ["Base.ShotgunShells"] = true, ["Base.308Bullets"] = true}

---@param head InventoryItem? Candidate
---@return table? profile Supported mechanism
---@nodiscard
function G.profile(head)
    if not head then return nil end
    local fullType = head:getFullType()
    if G.PROFILES[fullType] then return G.PROFILES[fullType] end
    if not instanceof(head, "HandWeapon") or not head:isRanged() or not head:getAmmoType()
        or head:getMaxAmmo() < 1 or head:getAmmoPerShoot() ~= 1 or head:getMaxDamage() <= 0 then return nil end
    local mechanism = tostring(head:getWeaponReloadType())
    local reloads = {handgun = 2.7, boltaction = 2.7, shotgun = 0.833, revolver = 0.95,
        boltactionnomag = 0.590, doublebarrelshotgun = 2.5, doublebarrelshotgunsawn = 2.5, leveraction = 1}
    local reload = reloads[mechanism]
    if not reload then return nil end
    local rack = 1.2
    if mechanism == "shotgun" then rack = 0.6 end
    local muzzle = 0.25
    local modelName = head:getStaticModel()
    local model = modelName and getScriptManager():getModelScript(modelName)
    local attachment = model and model:getAttachmentById("muzzle")
    if attachment then muzzle = math.max(0.02, math.min(1, attachment:getOffset():length())) end
    local profile = {reload = reload, rack = rack, muzzle = muzzle, yaw = 0, roll = -90, mechanism = mechanism}
    G.PROFILES[fullType] = profile
    G.AMMO[head:getAmmoType():getItemKey()] = true
    return profile
end

---@return nil
function G.registerAmmunition()
    local scripts = getScriptManager():getAllItems()
    for i = 0, scripts:size() - 1 do
        local item = scripts:get(i)
        if item:isRanged() and item:getAmmoType() then
            G.AMMO[item:getAmmoType():getItemKey()] = true
        end
    end
end

Events.OnGameStart.Add(G.registerAmmunition)

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
    Clock.restore(state, now)
    state.loaded = G.loaded(gun)
    if gun:getModData().OMHTTPowerOff then return state, "Off" end
    if G.servicing[gun] then return state, "Servicing" end
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
        if not gun:haveChamber() then gun:setSpentRoundCount(0) end
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
        gun:setSpentRoundCount(gun:getSpentRoundCount() + 1)
    end
    cycle.nextShot, cycle.cooldownDuration = now + stats.cooldown, stats.cooldown
    if gun:isRackAfterShoot() then cycle.rackReady = now + stats.rack end
    cycle.loaded = G.loaded(gun)
    return true
end

---@param player IsoPlayer Operator
---@param storage ItemContainer Current turret inventory
---@param gun HandWeapon Expected installed gun
---@param magazine InventoryItem? Insert item, or eject when nil
---@param token table Active action identity
---@return string? reason
function G.magazineRejection(player, storage, gun, magazine, token)
    local T = require("OMHTT/Turret")
    local contents = T.contents(storage)
    if contents.head ~= gun then return "TransferMissing" end
    if not G.profile(gun) or not gun:getMagazineType() then return "WrongMagazine" end
    if G.servicing[gun] and G.servicing[gun] ~= token then return "TransferPending" end
    if magazine then
        local source = magazine:getContainer()
        if not source or not source:isInCharacterInventory(player) or not source:contains(magazine) then return "TransferCarried" end
        if magazine:getFullType() ~= gun:getMagazineType() then return "WrongMagazine" end
        if gun:isContainsClip() then return "MagazineFull" end
        if magazine:isFavorite() then return "TransferFavorite" end
        if magazine:getCurrentAmmoCount() > gun:getMaxAmmo()
            or contents.reserveAll + G.loaded(gun) + magazine:getCurrentAmmoCount() > T.cycleConfig(contents).ammo then return "TransferFull" end
    elseif not gun:isContainsClip() then
        return "NoMagazine"
    end
    return nil
end

---@param player IsoPlayer Validated operator
---@param storage ItemContainer Current turret inventory
---@param gun HandWeapon Expected installed gun
---@param magazine InventoryItem? Insert item, or eject when nil
---@param token table Active action identity
---@return InventoryItem? magazine Transferred native magazine
function G.transferMagazine(player, storage, gun, magazine, token)
    if G.magazineRejection(player, storage, gun, magazine, token) then return nil end
    if magazine then
        magazine:getContainer():Remove(magazine)
        player:removeFromHands(magazine)
        gun:setCurrentAmmoCount(magazine:getCurrentAmmoCount())
        gun:setContainsClip(true)
    else
        magazine = instanceItem(gun:getMagazineType())
        magazine:setCurrentAmmoCount(gun:getCurrentAmmoCount())
        player:getInventory():AddItem(magazine)
        gun:setContainsClip(false)
        gun:setCurrentAmmoCount(0)
    end
    G.cancelLoading(gun)
    return magazine
end

return G
