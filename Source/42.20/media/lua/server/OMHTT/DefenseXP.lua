if isClient() then return end

local X = {}
local owners

---@return table registry Server-owned source identities; retained for delayed effects
local function registry()
    if not owners then
        owners = ModData.getOrCreate("OMHTT_DefenseOwners_v1")
    end
    return owners
end

---@param id string Persistent device identity
---@param owner string|nil Registered owner, never inferred from a nearby player
---@return nil
function X.register(id, owner, x, y, z)
    if type(id) ~= "string" or type(owner) ~= "string" or owner == "" then return end
    local entry = registry()[id]
    if type(entry) ~= "table" then
        entry = {}
        registry()[id] = entry
    end
    entry.owner = owner
    if x ~= nil then
        entry.x, entry.y, entry.z = x, y, z
    end
end

---@param id string Device identity
---@return string|nil owner
function X.owner(id)
    local entry = registry()[id]
    return entry and entry.owner
end

---@param player IsoPlayer Authenticated contact recipient
---@param source string Server-known passive defense
---@return boolean near
function X.contact(player, source)
    if player:isDead() or player:isGodMod() or player:isNoClip() or player:isGhostMode() then return false end
    local entry
    local beds = rawget(_G, "OMHTT_BedSpikes")
    local barbs = rawget(_G, "OMHTT_BarbSections")
    if beds and beds.store then
        entry = beds.store.records[source]
    end
    if not entry and barbs and barbs.store then
        entry = barbs.store.panels[source] or barbs.store.wires[source]
    end
    if not entry and string.sub(source, 1, 5) == "test-" and getActivatedMods():contains("OneMoreHorde_Traps") then
        local known = registry()[source]
        if known and known.x then
            local square = getCell():getGridSquare(known.x, known.y, known.z)
            local slot = square and require("OMHTT/BarrierFootprint").slot(square, source)
            entry = slot and slot.device
        end
    end
    if not entry and getActivatedMods():contains("OneMoreHorde_Turrets") then
        local field = require("OMHTT/TurretProc").contact(player)
        return field ~= nil and field.source == source
    end
    if not entry or not entry.x then return false end
    return math.floor(player:getZ()) == entry.z
        and math.abs(player:getX() - entry.x - .5) <= 2
        and math.abs(player:getY() - entry.y - .5) <= 2
end

---@param zombie IsoZombie Lethal victim before native Kill
---@param source string Server-authorized device
---@param horde boolean Active authorized Horde target
---@return nil
function X.lethal(zombie, source, horde)
    local credit = rawget(_G, "OMHTS_DefenseCredit")
    if not credit or credit.API_VERSION ~= 1 then return end
    credit.zombieFinisher(zombie, X.owner(source), horde, source)
end

---@param player IsoPlayer Before an independently applied defense injury
---@return nil
function X.beforeInjury(player)
    local credit = rawget(_G, "OMHTS_DefenseCredit")
    if not credit or credit.API_VERSION ~= 1 then return end
    credit.cancelPending(player)
end

---@param player IsoPlayer Confirmed injury recipient
---@param source string|nil Authoritative source
---@return nil
function X.injury(player, source)
    if type(source) ~= "string" then return end
    local credit = rawget(_G, "OMHTS_DefenseCredit")
    if not credit or credit.API_VERSION ~= 1 then return end
    credit.playerInjury(player, X.owner(source), source)
end

return X
