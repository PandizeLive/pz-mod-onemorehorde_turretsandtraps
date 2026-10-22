local E = {}
E.cached = setmetatable({}, {__mode = 'kv'})
local tiers = {['Base.OMHTTModuleExpansionImprovised'] = 1, ['Base.OMHTTModuleExpansionSmall'] = 2,
    ['Base.OMHTTModuleExpansionMedium'] = 3, ['Base.OMHTTModuleExpansionLarge'] = 4}

---@param key string Setting suffix
---@param fallback number Default
---@param maximum number Bound
---@return number value
function E.option(key, fallback, maximum)
    local settings = SandboxVars.OMHTurretsTraps or {}
    local value = settings[key] or settings['Traps' .. key] or fallback
    if type(value) ~= 'number' or value ~= value then
        value = fallback
    end
    return math.max(0, math.min(maximum, value))
end

---@param item InventoryItem? Kit
---@return number tier
function E.tier(item)
    if not item then return 0 end
    return tiers[item:getFullType()] or 0
end

---@param object IsoObject? Controller
---@return InventoryItem? installed
function E.item(object)
    local state = object and require('OMHTT/ControlAccess').state(object)
    local storage = object and object:getContainer()
    if not state or not storage or not state.expansionId then
        if object then
            E.cached[object] = nil
        end
        return nil
    end
    local item = E.cached[object]
    if item and item:getID() == state.expansionId and item:getContainer() == storage then
        return item
    end
    item = storage:getItemWithID(state.expansionId)
    E.cached[object] = item
    return item
end

---@param object IsoObject? Controller
---@return number tier Server-owned grade; clients need not wait for inventory replication
function E.grade(object)
    if isClient() then
        local state = object and require('OMHTT/ControlAccess').state(object)
        local tier = state and state.expansionTier
        if type(tier) == 'number' and tier == tier then
            return math.floor(math.max(0, math.min(4, tier)))
        end
    end
    return E.tier(E.item(object))
end

---@param object IsoObject? Controller
---@param tier number? Hypothetical replacement grade
---@return number capacity
function E.capacity(object, tier)
    if tier == nil then
        tier = E.grade(object)
    end
    return E.option('ControllerCapacity', 100, 5000) + tier * E.option('ControllerKitCapacity', 100, 1000)
end

---@param object IsoObject Controller
---@param item InventoryItem Item leaving storage
---@return boolean allowed
function E.canRemove(object, item)
    if E.item(object) ~= item then return true end
    return object:getContainer():getCapacityWeight() - item:getUnequippedWeight() <= E.capacity(object, 0)
end

---@param object IsoObject Controller
---@return nil
function E.refresh(object)
    if isClient() then return end
    local state = require('OMHTT/ControlAccess').state(object)
    if not state or state.kind ~= 'Controller' then return end
    local item = E.item(object)
    state.expansionTier = E.tier(item)
    local storage = object:getContainer()
    if storage then
        -- Native ordinary containers clamp their reported capacity to 100.
        -- Controller transfers and UI enforce the larger authoritative allowance.
        storage:setCapacity(math.min(100, math.floor(E.capacity(object, state.expansionTier))))
    end
    if not item then state.expansionId = nil end
end

return E
