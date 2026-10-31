local Ammo = require("OMHTT/TurretAmmo")
local Void = require("OMHTT/TurretVoid")
local G = require("OMHTT/Firearms")
local L = {}
local orders = setmetatable({}, {__mode = "k"})
local heads = {potato = "Base.OMHTTTurretPotato", spear = "Base.OMHTTTurretBallista",
    bomb = "Base.OMHTTTurretLobber", scrap = "Base.OMHTTTurretScrapshot"}

---@param fullType string Ammunition identity
---@return string? platform Exact compatibility family
function L.platform(fullType)
    local family = Ammo.family(fullType)
    if family == "round" then return "round:" .. fullType end
    if heads[family] then return family end
end

---@param head InventoryItem Installed head
---@return string? platform
function L.headPlatform(head)
    if not head then return nil end
    if G.profile(head) then return "round:" .. G.ammoType(head) end
    for family, fullType in pairs(heads) do
        if head:getFullType() == fullType then return family end
    end
end

---@param state table Device settings
---@param platform string Compatibility family
---@return string order Platform preference with legacy fallback
function L.groupSaved(state, platform)
    local saved = state.ammoOrders
    if saved and saved["@" .. platform] then return saved["@" .. platform] end
    if saved and heads[platform] and saved[heads[platform]] then return saved[heads[platform]] end
    if platform == "bomb" then return state.ammoOrder or state.ammoPreferred or "" end
    return ""
end

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
    local platform = L.headPlatform(head)
    if platform then
        local saved = L.groupSaved(state, platform)
        if saved ~= "" then return saved end
    end
    if state.ammoOrders and state.ammoOrders[head:getFullType()] then return state.ammoOrders[head:getFullType()] end
    if head:getFullType() == "Base.OMHTTTurretLobber" then return state.ammoOrder or state.ammoPreferred or "" end
    return ""
end

---@param contents table All physical ammunition
---@param state table Device settings
---@param totals table? Complete paged Void totals
---@return table groups Platform groups with ordered types
function L.groups(contents, state, totals)
    local entries, platforms = {}, {}
    ---@param fullType string Ammo identity
    ---@return table? row
    local function add(fullType)
        local platform = L.platform(fullType)
        if not platform then return nil end
        local group = entries[platform]
        if not group then
            group = {platform = platform, previous = L.groupSaved(state, platform), entries = {}, rows = {}}
            entries[platform], platforms[#platforms + 1] = group, platform
        end
        if not group.entries[fullType] then
            group.entries[fullType] = {type = fullType, platform = platform, physical = 0, virtual = 0}
        end
        return group.entries[fullType]
    end
    for fullType, count in pairs(contents.roundCounts) do
        local row = add(fullType)
        if row then
            row.physical = count
        end
    end
    local data = Void.data(contents.void)
    if not totals and data then
        totals = data.summary and data.counts or Void.totals(data)
    end
    if totals then
        for fullType, count in pairs(totals) do
            local row = add(fullType)
            if row then
                row.virtual = count
            end
        end
    end
    for _, value in pairs(state.ammoOrders or {}) do
        local types = L.types(value)
        for i = 1, #types do
            add(types[i])
        end
    end
    table.sort(platforms)
    local result = {}
    for i = 1, #platforms do
        local group = entries[platforms[i]]
        local preference, seen, keys = L.types(group.previous), {}, {}
        for j = 1, #preference do
            local row = add(preference[j])
            if row and row.platform == group.platform and not seen[row.type] then
                group.rows[#group.rows + 1], seen[row.type] = row, true
            end
        end
        for fullType in pairs(group.entries) do
            if not seen[fullType] then
                keys[#keys + 1] = fullType
            end
        end
        table.sort(keys)
        for j = 1, #keys do
            group.rows[#group.rows + 1] = group.entries[keys[j]]
        end
        result[#result + 1] = group
    end
    return result
end

---@param value table Platform mutation
---@param state table Authoritative settings
---@return boolean valid
function L.validGroup(value, state)
    if type(value) ~= "table" or type(value.platform) ~= "string" or #value.platform > 240
        or type(value.order) ~= "string" or #value.order > 16384
        or value.previous ~= L.groupSaved(state, value.platform) then return false end
    local types, seen = L.types(value.order), {}
    if #types == 0 or #types > 256 or string.sub(value.order, -1) == "|" then return false end
    for i = 1, #types do
        local fullType = types[i]
        if seen[fullType] or #fullType > 256 or L.platform(fullType) ~= value.platform then return false end
        seen[fullType] = true
    end
    return true
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
