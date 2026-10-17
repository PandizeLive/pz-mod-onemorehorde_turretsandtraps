local Ammo = require("OMHTT/TurretAmmo")
local Void = require("OMHTT/TurretVoid")
local G = require("OMHTT/Firearms")
local L = {}
local orders = setmetatable({}, {__mode = "k"})

---@param text string Serialized preference
---@return table types Exact tokens
function L.types(text)
    local result, start = {}, 1
    while start <= #text do
        local stop = string.find(text, "|", start, true) or (#text + 1)
        result[#result + 1] = string.sub(text, start, stop - 1)
        start = stop + 1
    end
    return result
end

---@param state table? Device settings
---@param head InventoryItem Installed head
---@return table types Cached priority tokens
function L.preference(state, head)
    local value = L.saved(state, head)
    local cached = orders[head]
    if not cached or cached.value ~= value then
        cached = {value = value, types = L.types(value)}
        orders[head] = cached
    end
    return cached.types
end

---@param state table Device settings
---@param head InventoryItem Installed head
---@return string order Saved preference
---@nodiscard
function L.saved(state, head)
    if not head or not state then return "" end
    if state.ammoOrders and state.ammoOrders[head:getFullType()] then return state.ammoOrders[head:getFullType()] end
    if head:getFullType() == "Base.OMHTTTurretLobber" then return state.ammoOrder or state.ammoPreferred or "" end
    return ""
end

---@param contents table Inventory snapshot
---@param state table Device settings
---@param totals table? Complete Void counts supplied by a paged reader
---@param compact boolean? Use bounded Void preview for routine Manage refresh
---@return table rows Ordered compatible types and source counts
function L.rows(contents, state, totals, compact)
    local head = contents.head
    if not head then return {} end
    local entries, keys = {}, {}
    ---@param fullType string Candidate identity
    ---@return table? row
    local function add(fullType)
        if entries[fullType] then return entries[fullType] end
        if not Ammo.accepts(head, fullType) then return nil end
        if not entries[fullType] then
            entries[fullType] = {type = fullType, physical = 0, virtual = 0}
            keys[#keys + 1] = fullType
        end
        return entries[fullType]
    end
    local preference = L.preference(state, head)
    for i = 1, #preference do add(preference[i]) end
    if contents.roundCounts then
        for fullType, count in pairs(contents.roundCounts) do
            local row = add(fullType)
            if row then
                row.physical = count
            end
        end
    else
        for i = 1, #contents.rounds do
            local row = add(contents.rounds[i]:getFullType())
            if row then
                row.physical = row.physical + 1
            end
        end
    end
    local data = Void.data(contents.void)
    if not compact and not totals and data and not data.summary then
        totals = Void.totals(data)
    end
    if totals then
        for fullType, count in pairs(totals) do
            local row = add(fullType)
            if row then
                row.virtual = count
            end
        end
    else
        if data and not data.summary then
            local savedCounts = Void.totals(data)
            for i = 1, #preference do
                local row = entries[preference[i]]
                if row then
                    row.virtual = savedCounts[row.type] or 0
                end
            end
        end
        if data and data.summary then
            for fullType, count in pairs(data.counts) do
                local row = add(fullType)
                if row then
                    row.virtual = count
                end
            end
        end
        local preview = Void.preview(contents.void, head)
        for i = 1, #preview do
            local row = add(preview[i].type)
            if row then
                row.virtual = preview[i].count
            end
        end
    end
    table.sort(keys)
    local result, seen = {}, {}
    for i = 1, #preference do
        local fullType = preference[i]
        if entries[fullType] and not seen[fullType] then
            result[#result + 1], seen[fullType] = entries[fullType], true
        end
    end
    for i = 1, #keys do
        if not seen[keys[i]] then
            result[#result + 1] = entries[keys[i]]
        end
    end
    return result
end

---@param contents table Inventory snapshot
---@param state table Device settings
---@return string? fullType Highest available priority
function L.select(contents, state)
    local head = contents.head
    if not head then return nil end
    if G.profile(head) then return G.ammoType(head) end
    local preference = L.preference(state, head)
    local data = Void.data(contents.void)
    local totals = data and (data.summary and data.counts or Void.totals(data)) or {}
    local physical, fallback = {}, nil
    for i = 1, #contents.rounds do
        local fullType = contents.rounds[i]:getFullType()
        if Ammo.accepts(head, fullType) then
            physical[fullType] = true
            if not fallback or fullType < fallback then
                fallback = fullType
            end
        end
    end
    for i = 1, #preference do
        local fullType = preference[i]
        if Ammo.accepts(head, fullType) and (physical[fullType] or (totals[fullType] or 0) > 0) then
            return fullType
        end
    end
    local preview = Void.preview(contents.void, head)
    if preview[1] and (not fallback or preview[1].type < fallback) then
        fallback = preview[1].type
    end
    return fallback
end

---@param value table Request including expected head and revision
---@param contents table Current inventory
---@param state table Authoritative settings
---@return boolean valid
function L.valid(value, contents, state)
    if type(value) ~= "table" or not contents.head or value.head ~= contents.head:getID()
        or value.previous ~= L.saved(state, contents.head) or type(value.order) ~= "string"
        or #value.order > 16384 then return false end
    local seen, count = {}, 0
    local types = L.types(value.order)
    for i = 1, #types do
        local fullType = types[i]
        if seen[fullType] or #fullType > 256 or not Ammo.accepts(contents.head, fullType) then return false end
        seen[fullType], count = true, count + 1
        if count > 256 then return false end
    end
    return count > 0 and not string.find(value.order, "||", 1, true)
        and string.sub(value.order, 1, 1) ~= "|" and string.sub(value.order, -1) ~= "|"
end

return L
