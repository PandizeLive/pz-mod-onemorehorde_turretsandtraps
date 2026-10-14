local Ammo = require("OMHTT/TurretAmmo")
local V = {TYPE = "Base.OMHTTModuleVoid", LIMIT = 9007199254740991}

---@param module InventoryItem? Exact storage owner
---@param create boolean? Initialize only for an authorized conversion
---@return table? data Persisted bounded-by-variant storage
function V.data(module, create)
    if not module or module:getFullType() ~= V.TYPE then return nil end
    local metadata = module:getModData()
    if metadata.OMHTTVoid == nil and create and not isClient() and not isServer() then
        metadata.OMHTTVoid = {schema = 1, revision = 0, groups = {}, debt = {}}
    end
    local data = metadata.OMHTTVoid
    if type(data) ~= "table" or data.schema ~= 1 or type(data.groups) ~= "table"
        or type(data.debt) ~= "table" or type(data.revision) ~= "number" then return nil end
    return data
end

---@param a table Descriptor
---@param b table Descriptor
---@return boolean equal
---@nodiscard
function V.same(a, b)
    return a.type == b.type and a.condition == b.condition and a.multiplier == b.multiplier
        and a.age == b.age and a.cooked == b.cooked and a.burnt == b.burnt
end

---@param module InventoryItem Module in the target turret
---@param item InventoryItem Physical source
---@param source ItemContainer Expected source
---@return boolean converted
function V.deposit(module, item, source)
    if isClient() or isServer() then return false end
    if not item or not source or item:getContainer() ~= source or not source:contains(item) or item:isFavorite() then return false end
    if not module or module:getFullType() ~= V.TYPE or module:getCondition() <= 0 then return false end
    local descriptor = Ammo.describe(item)
    if not descriptor then return false end
    local data = V.data(module, true)
    if not data or not descriptor then return false end
    local existing
    for i = 1, #data.groups do
        local group = data.groups[i]
        if V.same(group, descriptor) then
            existing = group
            break
        end
    end
    if existing and existing.count >= V.LIMIT then return false end
    source:Remove(item)
    if source:contains(item) then return false end
    if existing then
        existing.count = existing.count + 1
    else
        descriptor.count = 1
        data.groups[#data.groups + 1] = descriptor
    end
    data.revision = data.revision + 1
    return true
end

---@param module InventoryItem? Exact module
---@param head InventoryItem? Head compatibility filter
---@param fullType string? Selected payload
---@return number count
---@return table? first First compatible descriptor
function V.count(module, head, fullType)
    local data = V.data(module)
    if not data then return 0 end
    local count, first = 0, nil
    for i = 1, #data.groups do
        local group = data.groups[i]
        if group.count > 0 and (not head or Ammo.accepts(head, group.type)) and (not fullType or group.type == fullType) then
            count = math.min(V.LIMIT, count + group.count)
            if not first then
                first = group
            end
        end
    end
    return count, first
end

---@param module InventoryItem Exact module
---@param descriptor table Bound quality group
---@param amount number Validated integer debit
---@return boolean consumed
function V.spend(module, descriptor, amount)
    if isClient() or isServer() then return false end
    local data = V.data(module)
    if not data or type(amount) ~= "number" or amount < 0 or amount > V.LIMIT or amount ~= math.floor(amount) then return false end
    for i = 1, #data.groups do
        local group = data.groups[i]
        if group == descriptor then
            if group.count < amount then return false end
            group.count = group.count - amount
            if group.count == 0 then
                table.remove(data.groups, i)
            end
            data.revision = data.revision + 1
            return true
        end
    end
    return false
end

---@param module InventoryItem Exact storage owner
---@param descriptor table Selected stored quality group
---@param uses number Ready firing uses, already bounded by the magazine
---@param divisor number Conservation firing uses per round
---@return boolean committed
---@return number? cost Whole rounds consumed
function V.consume(module, descriptor, uses, divisor)
    if isClient() or isServer() then return false end
    local data = V.data(module)
    if not data or not descriptor or type(uses) ~= "number" or uses < 1 or uses > V.LIMIT
        or uses ~= math.floor(uses) or type(divisor) ~= "number" or divisor < 1 or divisor > V.LIMIT then return false end
    if type(descriptor.count) ~= "number" or uses > descriptor.count then return false end
    local previous = data.debt[descriptor.type] or 0
    if type(previous) ~= "number" or previous < 0 or previous >= 1 or previous ~= previous then return false end
    local debt = previous + uses / divisor
    local cost = math.floor(debt + .0000001)
    if not V.spend(module, descriptor, cost) then return false end
    data.debt[descriptor.type] = math.max(0, debt - cost)
    return true, cost
end

return V
