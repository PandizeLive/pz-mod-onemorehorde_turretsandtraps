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
    if isClient() or not record.displayIdentity then return end
    registry().packed[tostring(item:getID())] = {identity = record.displayIdentity, name = record.name}
    item:getModData().OMHTTDisplayName = record.displayName
end

---@param record table New private state
---@param items ArrayList? Native recipe inputs
---@return nil
function N.restore(record, items)
    if isClient() or not items then return end
    local data = registry()
    for i = 0, items:size() - 1 do
        local key = tostring(items:get(i):getID())
        local packed = data.packed[key]
        if packed then
            if type(packed) == "string" then
                packed = {identity = packed}
            end
            local entry = data.entries[packed.identity]
            record.displayIdentity = packed.identity
            record.displayNumber, record.displayName = entry.number, entry.label
            record.name = packed.name
            data.packed[key] = nil
            return
        end
    end
end

return N
