local Ammo = require("OMHTT/TurretAmmo")
local State = require("OMHTT/TurretItemState")
local V = {TYPE = "Base.OMHTTModuleVoid", LIMIT = 9007199254740991}
local countCache = setmetatable({}, {__mode = "k"})
local descriptionCache = setmetatable({}, {__mode = "k"})
local previewCache = setmetatable({}, {__mode = "k"})

---@param module InventoryItem? Storage module
---@param head InventoryItem? Compatibility filter
---@return table rows At most twenty type counts
---@return number types Total compatible types
function V.preview(module, head)
    local data = V.data(module)
    if not data then return {}, 0 end
    if data.summary then
        if head and data.previewHead == head:getFullType() then return data.compatible or {}, data.compatibleTypes or 0 end
        if head then
            local rows = {}
            for i = 1, #(data.preview or {}) do
                local row = data.preview[i]
                if Ammo.accepts(head, row.type) then rows[#rows + 1] = row end
            end
            return rows, #rows
        end
        return data.preview or {}, data.typeCount or 0
    end
    local cache = previewCache[data]
    local key = head and head:getFullType() or "*"
    if not cache or cache.revision ~= data.revision then
        cache = {revision = data.revision, views = {}}
        previewCache[data] = cache
    end
    if cache.views[key] then return cache.views[key].rows, cache.views[key].count end
    local keys, totals = {}, V.totals(data)
    for fullType, count in pairs(totals) do
        if count > 0 and (not head or Ammo.accepts(head, fullType)) then keys[#keys + 1] = fullType end
    end
    table.sort(keys)
    local rows = {}
    for i = 1, math.min(20, #keys) do rows[i] = {type = keys[i], count = totals[keys[i]]} end
    cache.views[key] = {rows = rows, count = #keys}
    return rows, #keys
end

---@param module InventoryItem? Storage module
---@param head InventoryItem? Compatibility filter
---@param rich boolean? Rich tooltip
---@return string description
function V.description(module, head, rich)
    local data = V.data(module)
    local key = (head and head:getFullType() or "*") .. tostring(rich)
    local cached = data and descriptionCache[data]
    if cached and cached.revision == data.revision and cached[key] then return cached[key] end
    local rows, types = V.preview(module, head)
    local lines = {}
    for i = 1, #rows do
        local script = getScriptManager():getItem(rows[i].type)
        lines[#lines + 1] = (script and script:getDisplayName() or rows[i].type) .. ": " .. tostring(rows[i].count)
    end
    if types > #rows then lines[#lines + 1] = getText("UI_OMHTT_VoidMore", types - #rows) end
    if #lines == 0 then lines[1] = getText("UI_OMHTT_VoidEmpty") end
    local text = table.concat(lines, rich and " <LINE> " or "\n")
    if data then
        if not cached or cached.revision ~= data.revision then
            cached = {revision = data.revision}
            descriptionCache[data] = cached
        end
        cached[key] = text
    end
    return text
end

---@param data table Authoritative storage
---@return table totals Counts indexed by ammunition type
function V.totals(data)
    if data.totals then return data.totals end
    data.totals, data.families, data.total = {}, {}, 0
    for i = 1, #data.groups do
        local group = data.groups[i]
        local family = Ammo.family(group.type)
        data.totals[group.type] = (data.totals[group.type] or 0) + group.count
        data.total = data.total + group.count
        if family then
            data.families[family] = (data.families[family] or 0) + group.count
        end
    end
    return data.totals
end

---@param data table Authoritative storage
---@param fullType string Ammunition identity
---@param amount number Signed committed count change
---@return nil
function V.changed(data, fullType, amount)
    local totals = V.totals(data)
    totals[fullType] = (totals[fullType] or 0) + amount
    if totals[fullType] == 0 then
        totals[fullType] = nil
    end
    local family = Ammo.family(fullType)
    if family then
        data.families[family] = (data.families[family] or 0) + amount
    end
    data.total = data.total + amount
end

---@param module InventoryItem Exact module
---@param data table? Private ledger
---@return table? view Small fixed-shape inventory metadata
function V.summary(module, data)
    if not data then return nil end
    local totals = V.totals(data)
    local head
    local source = module:getContainer()
    if source then
        local items = source:getItems()
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            if require("OMHTT/Turret").kind(item) == "head" then
                head = item
                break
            end
        end
    end
    local G = require("OMHTT/Firearms")
    local selected = G.profile(head) and G.ammoType(head)
    local counts = {}
    for fullType in pairs(Ammo.bombs) do counts[fullType] = totals[fullType] or 0 end
    if selected then
        counts[selected] = totals[selected] or 0
    end
    local compatibleRows = V.preview(module, head)
    for i = 1, #compatibleRows do counts[compatibleRows[i].type] = compatibleRows[i].count end
    if head and source and source:getParent() then
        local state = require("OMHTT/Turret").state(source:getParent())
        local Order = require("OMHTT/TurretLoadOrder")
        local types = Order.types(Order.saved(state, head))
        for i = 1, #types do
            local fullType = types[i]
            counts[fullType] = totals[fullType] or 0
        end
    end
    local families, first = {}, {}
    for family, count in pairs(data.families) do families[family] = count end
    for fullType in pairs(totals) do
        local family = Ammo.family(fullType)
        if family and not first[family] then
            first[family] = fullType
        end
    end
    local preview, typeCount = V.preview(module)
    local compatible, compatibleTypes = V.preview(module, head)
    return {schema = 1, revision = data.revision, groups = {}, debt = {}, summary = true,
        total = data.total, families = families, counts = counts, first = first,
        preview = preview, typeCount = typeCount, compatible = compatible, compatibleTypes = compatibleTypes,
        previewHead = head and head:getFullType()}
end

---@param module InventoryItem? Exact storage owner
---@param create boolean? Initialize only for an authorized conversion
---@return table? data Persisted bounded-by-variant storage
function V.data(module, create)
    if not module or module:getFullType() ~= V.TYPE then return nil end
    local initial
    if create and not isClient() then
        initial = {schema = 1, revision = 0, groups = {}, debt = {}}
    end
    local data = State.get(module, "void", initial)
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
    if isClient() then return false end
    if not item or not source or item:getContainer() ~= source or not source:contains(item) or item:isFavorite() then return false end
    if not module or module:getFullType() ~= V.TYPE or module:getCondition() <= 0 then return false end
    local descriptor = Ammo.describe(item)
    if not descriptor then return false end
    local data = V.data(module, true)
    if not data or not descriptor then return false end
    V.totals(data)
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
    V.changed(data, descriptor.type, 1)
    if isServer() then
        sendRemoveItemFromContainer(source, item)
    end
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
    if data.summary then
        if fullType then return data.counts[fullType] or 0 end
        if not head then return data.total end
        local G = require("OMHTT/Firearms")
        if G.profile(head) then return data.counts[G.ammoType(head)] or 0 end
        local families = { ["Base.OMHTTTurretPotato"] = "potato", ["Base.OMHTTTurretBallista"] = "spear",
            ["Base.OMHTTTurretLobber"] = "bomb", ["Base.OMHTTTurretScrapshot"] = "scrap" }
        local family = families[head:getFullType()]
        local count = data.families[family] or 0
        return count, count > 0 and {type = data.first[family], count = count} or nil
    end
    local cache = countCache[data]
    if not cache or cache.revision ~= data.revision then
        cache = {revision = data.revision, values = {}}
        countCache[data] = cache
    end
    local key = (head and head:getFullType() or "*") .. "|" .. (fullType or "*")
    local cached = cache.values[key]
    if cached and (not head or not cached.first or Ammo.accepts(head, cached.first.type)) then
        return cached.count, cached.first
    end
    local count, first = 0, nil
    for i = 1, #data.groups do
        local group = data.groups[i]
        if group.count > 0 and (not head or Ammo.accepts(head, group.type)) and (not fullType or group.type == fullType) then
            count = math.min(V.LIMIT, count + group.count)
            first = first or group
        end
    end
    cache.values[key] = {count = count, first = first}
    return count, first
end

---@param module InventoryItem Exact module
---@param descriptor table Bound quality group
---@param amount number Validated integer debit
---@return boolean consumed
function V.spend(module, descriptor, amount)
    if isClient() then return false end
    local data = V.data(module)
    if not data or type(amount) ~= "number" or amount < 0 or amount > V.LIMIT or amount ~= math.floor(amount) then return false end
    V.totals(data)
    for i = 1, #data.groups do
        local group = data.groups[i]
        if group == descriptor then
            if group.count < amount then return false end
            group.count = group.count - amount
            if group.count == 0 then
                table.remove(data.groups, i)
            end
            data.revision = data.revision + 1
            V.changed(data, group.type, -amount)
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
    if isClient() then return false end
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
