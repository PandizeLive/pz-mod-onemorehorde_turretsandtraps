local N = {}
local store

---@return table registry
local function registry()
    if not store then
        store = ModData.getOrCreate("OMHTTDefenseNamesV1")
        if not store.entries then
            store.entries, store.labels, store.counters, store.packed = {}, {}, {}, {}
        end
    end
    return store
end

---@param record table Persistent defense
---@param family string Numbering family
---@param base string Automatic label
---@return nil
function N.ensure(record, family, base)
    if isClient() then return end
    local data = registry()
    local identity = record.displayIdentity or family .. ":" .. record.id
    local entry = data.entries[identity]
    if not entry then
        data.counters[family] = (data.counters[family] or 0) + 1
        entry = {number = data.counters[family]}
        data.entries[identity] = entry
    end
    local custom = record.name and string.trim(record.name)
    local stem = custom and custom ~= "" and custom or base .. " #" .. entry.number
    if entry.stem == stem then
        record.displayIdentity, record.displayNumber, record.displayName = identity, entry.number, entry.label
        if custom and custom ~= "" then
            record.name = entry.label
        end
        return
    end
    if entry.key and data.labels[entry.key] == identity then
        data.labels[entry.key] = nil
    end
    local label, suffix = stem, 1
    local key = string.lower(string.gsub(label, "%s+", " "))
    while data.labels[key] and data.labels[key] ~= identity do
        suffix = suffix + 1
        local ending = " #" .. suffix
        label = string.sub(stem, 1, 48 - #ending) .. ending
        key = string.lower(string.gsub(label, "%s+", " "))
    end
    entry.key, entry.stem, entry.label = key, stem, label
    data.labels[key] = identity
    record.displayIdentity, record.displayNumber, record.displayName = identity, entry.number, label
    if custom and custom ~= "" then
        record.name = label
    end
end

---@param record table Private defense state
---@param item InventoryItem Recovered item
---@return nil
function N.pack(record, item)
    if isClient() then return end
    local health = record.condition or record.health
    local maximum = record.maxHealth or (record.kind == "wire" and 50)
    registry().packed[tostring(item:getID())] = {identity = record.displayIdentity, name = record.name,
        health = health, maxHealth = maximum, itemType = item:getFullType(), owner = record.owner}
    if health and maximum then
        item:setCondition(health > 0 and math.max(1, math.floor(health / maximum * item:getConditionMax())) or 0)
    end
    item:getModData().OMHTTDisplayName = record.displayName
end

---@param record table New private state
---@param items ArrayList? Native recipe inputs
---@param ordinal number? Exact portable input position for independent Bed tiles
---@param fullType string? Portable item family
---@return nil
function N.restore(record, items, ordinal, fullType)
    if isClient() or not items then return end
    local data = registry()
    local count = 0
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        if fullType and item:getFullType() == fullType then
            count = count + 1
        end
        local key = tostring(items:get(i):getID())
        local packed = data.packed[key]
        local selected = not fullType or (item:getFullType() == fullType and count == ordinal)
        if selected and packed then
            if type(packed) == "string" then
                packed = {identity = packed}
            end
            if packed.itemType and packed.itemType ~= items:get(i):getFullType() then return end
            local entry = packed.identity and data.entries[packed.identity]
            if entry then
                record.displayIdentity = packed.identity
                record.displayNumber, record.displayName = entry.number, entry.label
                record.name = packed.name
            end
            record.recoveredHealth = packed.health
            if packed.owner then
                record.owner = packed.owner
            end
            data.packed[key] = nil
            return
        end
        if fullType and selected then
            record.recoveredFraction = item:getCondition() / item:getConditionMax()
            return
        end
    end
end

---@param record table Newly deployed authoritative record
---@param maximum number Deployment maximum
---@return number health Exact carried health, clamped only if the maximum changed
function N.health(record, maximum)
    local health = record.recoveredHealth
    if health == nil and record.recoveredFraction ~= nil then
        health = record.recoveredFraction * maximum
    end
    record.recoveredHealth = nil
    record.recoveredFraction = nil
    if health == nil then return maximum end
    return math.max(0, math.min(maximum, health))
end

return N
