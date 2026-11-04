-- Item modData is a replicated view. MP authority lives only in server GlobalModData.
local S = {}
local store
local names = {cycle = "OMHTTCycle", gun = "OMHTTGunCycle", feed = "OMHTTFeedRounds", void = "OMHTTVoid", battery = "OMHTTBatteryDrain"}

---@param value any Persistable value
---@return any copy Detached snapshot
---@nodiscard
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do
        result[key] = copy(child)
    end
    return result
end

---@param item InventoryItem Exact native storage owner
---@return table entry Server-private persisted item record
local function entry(item)
    if not store then
        store = ModData.getOrCreate("OMHTTItemAuthorityV1")
        if store.schema == nil then
            store.schema, store.items = 1, {}
        end
        if store.schema ~= 1 or type(store.items) ~= "table" then
            error("[OMHTT] Invalid item authority store")
        end
    end
    local key = tostring(item:getID())
    local result = store.items[key]
    if result and result.type ~= item:getFullType() then
        error("[OMHTT] Item identity reused with a different type")
    end
    if not result then
        result = {type = item:getFullType()}
        store.items[key] = result
    end
    return result
end

---@param item InventoryItem Exact head/module
---@param kind string Internal state family
---@param initial table? Trusted initial state
---@return table|number|nil state
function S.get(item, kind, initial)
    local name = names[kind]
    if not name then error("[OMHTT] Unknown item state family") end
    if not isServer() then
        local data = item:getModData()
        if data[name] == nil and initial and not isClient() then
            data[name] = copy(initial)
        end
        return data[name]
    end
    local record = entry(item)
    if record[kind] == nil and initial then
        record[kind] = copy(initial)
    end
    return record[kind]
end

---@param item InventoryItem Exact head/module
---@param kind string Internal state family
---@param value table|number|nil Trusted new state
---@return boolean changed Authority-only write
function S.set(item, kind, value)
    if isClient() then return false end
    if not names[kind] then error("[OMHTT] Unknown item state family") end
    if isServer() then
        entry(item)[kind] = value
    else
        item:getModData()[names[kind]] = value
    end
    return true
end

---@param item InventoryItem Exact head/module
---@param player IsoPlayer? Operator when one exists
---@return nil
function S.publish(item, player)
    if not isServer() then return end
    local record, data = entry(item), item:getModData()
    for kind, name in pairs(names) do
        if kind == "void" then
            data[name] = require("OMHTT/TurretVoid").summary(item, record[kind])
        else
            data[name] = copy(record[kind])
        end
    end
    local container = item:getContainer()
    local parent = container and container:getParent()
    local square = parent and parent:getSquare()
    local recipients = getOnlinePlayers()
    local sentOperator = false
    local metadataRecipient = player
    for i = 0, recipients:size() - 1 do
        local recipient = recipients:get(i)
        if square and math.abs(recipient:getX() - square:getX()) <= 100
            and math.abs(recipient:getY() - square:getY()) <= 100 then
            if not metadataRecipient then
                metadataRecipient = recipient
            end
            if instanceof(item, "HandWeapon") then
                syncHandWeaponFields(recipient, item)
            end
            if recipient == player then
                sentOperator = true
            end
        end
    end
    if player and not sentOperator and instanceof(item, "HandWeapon") then
        syncHandWeaponFields(player, item)
    end
    if metadataRecipient then
        syncItemModData(metadataRecipient, item)
    end
end

return S
