local L = require("OMHTT/LootDefinitions")
local T = require("OMHTT/Turret")
local M = require("OMHTT/TurretModules")
local P = {TYPE = "Base.OMHTTModulePack", COUNT = 3}
local names, weights, entries = {}, {}, {}
for name in pairs(L.WEIGHTS) do
    names[#names + 1] = name
end
table.sort(names)

---@return table entries Weighted eligible modules
---@return number total
---@nodiscard
function P.pool()
    local changed = P.total == nil
    for i = 1, #names do
        local name = names[i]
        local weight = L.WEIGHTS[name] * M.option("LootRate" .. name, L.DEFAULTS.items[name], 0, 20)
        if weights[i] ~= weight then
            weights[i], changed = weight, true
        end
    end
    if not changed then return entries, P.total end
    entries = {}
    local total = 0
    for i = 1, #names do
        local name, weight = names[i], weights[i]
        if weight > 0 then
            total = total + weight
            entries[#entries + 1] = {name = name, ceiling = total}
        end
    end
    P.total = total
    return entries, total
end

---@param entries table Weighted modules
---@param total number Total weight
---@param roll number Random fraction in [0,1)
---@return string name
---@nodiscard
function P.pick(entries, total, roll)
    local target = math.min(roll, .999999999) * total
    for i = 1, #entries do
        if target < entries[i].ceiling then return entries[i].name end
    end
    return entries[#entries].name
end

---@param player IsoPlayer Operator
---@param pack InventoryItem Exact carried pack
---@return table? rewards Granted items, or nil without consuming the pack
function P.open(player, pack)
    if isClient() or isServer() or not T.enabled() or player:isDead() then return nil end
    local inventory = player:getInventory()
    if pack:getFullType() ~= P.TYPE or pack:getContainer() ~= inventory or not inventory:contains(pack) then return nil end
    local data = pack:getModData()
    if data.OMHTTPackOpened then return nil end
    local names = data.OMHTTPackRewards
    if not names then
        local entries, total = P.pool()
        if total <= 0 then return nil end
        names = {}
        for i = 1, P.COUNT do
            names[i] = P.pick(entries, total, ZombRandFloat(0, 1))
        end
        data.OMHTTPackRewards = names
    end
    if #names ~= P.COUNT then return nil end
    local rewards = {}
    for i = 1, P.COUNT do
        if not T.TYPES[names[i]] then return nil end
        rewards[i] = instanceItem(T.TYPES[names[i]])
        if not rewards[i] then return nil end
    end
    for i = 1, P.COUNT do
        inventory:AddItem(rewards[i])
        if not inventory:contains(rewards[i]) then
            for n = 1, i do
                inventory:Remove(rewards[n])
            end
            return nil
        end
    end
    inventory:Remove(pack)
    if inventory:contains(pack) then
        for i = 1, P.COUNT do
            inventory:Remove(rewards[i])
        end
        return nil
    end
    data.OMHTTPackOpened = true
    return rewards
end

---@param zombie IsoZombie Newly killed zombie after native inventory generation
---@return nil
function P.onDeath(zombie)
    if isClient() or isServer() or not T.enabled() or SandboxVars.OMHTurretsTraps.PotatoTurret == false then return end
    local data = zombie:getModData()
    if data.OMHTTPackRolled then return end
    data.OMHTTPackRolled = true
    local chance = M.option("PackZombieChance", 15, 0, 100)
    if chance <= 0 or M.option("ModuleLootRate", L.DEFAULTS.global, 0, 20) <= 0 then return end
    if P.total == nil then
        P.pool()
    end
    if P.total <= 0 then return end
    if ZombRand(10000) >= chance * 100 then return end
    local inventory = zombie:getInventory()
    if inventory then
        inventory:AddItem(P.TYPE)
    end
end

return P
