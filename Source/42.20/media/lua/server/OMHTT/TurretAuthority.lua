if isClient() then return end
local A = {}
local bindings = setmetatable({}, {__mode = "k"})
local live = setmetatable({}, {__mode = "v"})
local used = setmetatable({}, {__mode = "k"})
local tiles = {}
local store

---@param x number Tile coordinate
---@param y number Tile coordinate
---@param z number Floor
---@return string key
---@nodiscard
local function tileKey(x, y, z)
    return x .. ":" .. y .. ":" .. z
end

---@return table records Server-only persistent records
local function records()
    if store then return store end
    store = ModData.getOrCreate("OMHTTProductionTurretsV1")
    if store.schema == nil then
        store.schema, store.world, store.packed = 1, {}, {}
    end
    if store.schema ~= 1 or type(store.world) ~= "table" or type(store.packed) ~= "table" then
        error("[OMHTT] Invalid production turret authority store")
    end
    for id, entry in pairs(store.world) do
        tiles[tileKey(entry.x, entry.y, entry.z)] = id
    end
    return store
end

---@param source table Scalar turret controls
---@return table copy Independent snapshot without runtime references
---@nodiscard
function A.copy(source)
    local result = {}
    for key, value in pairs(source) do
        local kind = type(value)
        if type(key) == "string" and (kind == "boolean" or kind == "string"
            or (kind == "number" and value == value and math.abs(value) < math.huge)) then
            result[key] = value
        end
    end
    if type(source.ammoOrders) == "table" then
        result.ammoOrders = {}
        for head, order in pairs(source.ammoOrders) do
            if type(head) == "string" and #head <= 256 and type(order) == "string" and #order <= 16384 then
                result.ammoOrders[head] = order
            end
        end
    end
    return result
end

---@param object IsoObject Bound turret
---@return table? state Private authoritative controls
---@nodiscard
function A.state(object)
    local entry = bindings[object]
    if not entry or records().world[entry.state.id] ~= entry then return nil end
    return entry.state
end

---@param object IsoObject Bound turret
---@param broadcast boolean? False when the native creation packet will carry the snapshot
---@return nil
function A.publish(object, broadcast)
    local state = A.state(object)
    if not state then return end
    object:getModData().OMHTTTurret = A.copy(state)
    if isServer() and broadcast ~= false then
        object:transmitModData()
    end
end

---@param object IsoObject Newly created turret
---@param state table Server-created controls
---@return boolean registered
function A.register(object, state)
    local square = object:getSquare()
    local data = records()
    if not square or data.world[state.id] or bindings[object] then return false end
    local key = tileKey(square:getX(), square:getY(), square:getZ())
    if tiles[key] then return false end
    local entry = {state = A.copy(state), x = square:getX(), y = square:getY(), z = square:getZ()}
    data.world[state.id], bindings[object] = entry, entry
    live[state.id] = object
    tiles[key] = state.id
    object:getModData().OMHTTTurret = A.copy(entry.state)
    return true
end

---@param object IsoObject Loaded native object
---@return boolean bound
function A.bind(object)
    if A.state(object) then return true end
    if not object:getContainer() or object:getContainer():getType() ~= "OMHTTTurret" then return false end
    local square = object:getSquare()
    if not square then return false end
    local data = records()
    local id = tiles[tileKey(square:getX(), square:getY(), square:getZ())]
    local entry = id and data.world[id]
    if not entry then return false end
    local other = live[id]
    if other and other ~= object then
        if other:getSquare() == square and other:getObjectIndex() >= 0 then return false end
        bindings[other] = nil
    end
    bindings[object] = entry
    live[id] = object
    object:getModData().OMHTTTurret = A.copy(entry.state)
    return true
end

---@param square IsoGridSquare Fully loaded native tile
---@return nil
function A.reconcile(square)
    local data = records()
    local key = tileKey(square:getX(), square:getY(), square:getZ())
    local id = tiles[key]
    if not id then return end
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        local container = object:getContainer()
        if container and container:getType() == "OMHTTTurret" then
            A.bind(object)
            return
        end
    end
    local old = live[id]
    if old then
        bindings[old] = nil
    end
    live[id], data.world[id], tiles[key] = nil, nil, nil
end

---@param item InventoryItem Consumed base
---@return table? state Trusted packed controls; public item metadata is never imported
---@nodiscard
function A.packed(item)
    return records().packed[tostring(item:getID())]
end

---@param item InventoryItem Consumed base
---@return boolean available
---@nodiscard
function A.available(item)
    return not used[item] and records().world["turret-" .. item:getID()] == nil
end

---@param item InventoryItem Successfully deployed base
---@return nil
function A.deployed(item)
    used[item] = true
    records().packed[tostring(item:getID())] = nil
end

---@param object IsoObject Retired turret
---@param item InventoryItem? Recovered base, absent on destruction
---@return boolean retired
function A.retire(object, item)
    local state = A.state(object)
    if not state then return false end
    local data = records()
    local entry = bindings[object]
    if item then
        data.packed[tostring(item:getID())] = A.copy(state)
        item:getModData().OMHTTTurret = A.copy(state)
    end
    data.world[state.id], bindings[object] = nil, nil
    live[state.id] = nil
    tiles[tileKey(entry.x, entry.y, entry.z)] = nil
    object:getModData().OMHTTTurret = nil
    return true
end

return A
