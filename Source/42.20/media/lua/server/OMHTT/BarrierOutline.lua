if isClient() then return end
local F = require("OMHTT/Foundation")
local G = require("OMHTT/BarrierGeometry")
local D = require("OMHTT/Diagnostics")
local O = {generation = 0}
local store, footprint = nil, nil
local removing = {}
local desired, byOwner = {}, {}
local dirty = true

---@param registry table Authority ledger
---@param api table Footprint API
---@return nil
function O.initialize(registry, api)
    store, footprint = registry, api
    desired, byOwner, removing, dirty = {}, {}, {}, true
end

---@return nil
function O.changed()
    O.generation = O.generation + 1
    dirty = true
end

---@return table records Persistent outline geometry, including unloaded neighbors
---@nodiscard
function O.records()
    local records = {}
    if not store then return records end
    for _, slot in pairs(store.tiles) do
        if slot.device and slot.device.kind == "barrier" and slot.device.collisionModel == "outline-v1" then
            records[#records + 1] = slot.device
        end
    end
    return records
end

---@param record table Placement candidate
---@return string? reason Native edge collision conflict
---@nodiscard
function O.canBuild(record)
    local records = O.records()
    local fronts = G.shape(record)
    for i = 1, #records do
        local other = G.shape(records[i])
        for j = 1, #fronts do
            for k = 1, #other do
                if fronts[j].key == other[k].key then return "Occupied" end
            end
        end
    end
    local edges = G.outline(record, records)
    for i = 1, #edges do
        local edge = edges[i]
        local square = getCell():getGridSquare(edge.x, edge.y, edge.z)
        if not square or not square:getFloor() or square:HasStairs() or square:HasStairsBelow()
            or square:isVehicleIntersecting() or square:has(IsoFlagType.water) then return "Blocked" end
        local special = square:getSpecialObjects()
        for j = 0, special:size() - 1 do
            if not footprint.exact(special:get(j)) then return "Blocked" end
        end
        local objects = square:getObjects()
        for j = 0, objects:size() - 1 do
            local object = objects:get(j)
            if not footprint.exact(object) then
                local props = object:getProperties()
                if props and (props:has(IsoFlagType.solid) or props:has(IsoFlagType.solidtrans)
                    or props:has(edge.north and IsoFlagType.collideN or IsoFlagType.collideW)
                    or props:has(edge.north and IsoFlagType.WallN or IsoFlagType.WallW)) then return "Blocked" end
            end
        end
    end
    return nil
end

---@return nil
local function rebuild()
    if not dirty then return end
    desired, byOwner, dirty = {}, {}, false
    local records = O.records()
    for i = 1, #records do
        local record = records[i]
        local edges = G.outline(record, records)
        for j = 1, #edges do
            local edge = edges[j]
            local previous = desired[edge.key]
            if not previous or record.id < previous.id then
                edge.id, edge.anchor, edge.facing = record.id, record.slotKey or F.key(record.x, record.y, record.z), record.facing
                desired[edge.key] = edge
            end
        end
    end
    for key, edge in pairs(desired) do
        if not byOwner[edge.id] then
            byOwner[edge.id] = {}
        end
        byOwner[edge.id][#byOwner[edge.id] + 1] = edge
    end
end

---@param object IsoObject Candidate collider, including a destroyed native edge
---@return table? record Private owner resolved from native position/name, never public modData
local function owner(object)
    if not store or not instanceof(object, "IsoThumpable") then return nil end
    local square = object:getSquare()
    if not square then return nil end
    rebuild()
    local key = F.key(square:getX(), square:getY(), square:getZ()) .. (object:getNorth() and ":N" or ":W")
    local edge = desired[key]
    if not edge or object:getName() ~= F.PREFIX .. edge.id .. ":" .. key then return nil end
    local slot = store.tiles[edge.anchor]
    return slot and slot.device
end

---@param object IsoObject Candidate collider
---@return table? record Exact live owner
---@nodiscard
function O.exact(object)
    if object:getObjectIndex() < 0 or object:getHealth() <= 0 then return nil end
    return owner(object)
end

---@param record table Owner
---@return table edges Loaded exact colliders
---@nodiscard
function O.objects(record)
    rebuild()
    local found = {}
    local edges = byOwner[record.id]
    if not edges then return found end
    for i = 1, #edges do
        local edge = edges[i]
        local square = getCell():getGridSquare(edge.x, edge.y, edge.z)
        if square then
            local objects = square:getSpecialObjects()
            for j = 0, objects:size() - 1 do
                local object = objects:get(j)
                if object:getName() == F.PREFIX .. record.id .. ":" .. edge.key and object:getNorth() == edge.north then
                    found[#found + 1] = object
                end
            end
        end
    end
    ---@param a IsoThumpable First collider
    ---@param b IsoThumpable Second collider
    ---@return boolean before Fronts precede caps
    table.sort(found, function(a, b)
        local sa, sb = a:getSquare(), b:getSquare()
        local left = desired[F.key(sa:getX(), sa:getY(), sa:getZ()) .. (a:getNorth() and ":N" or ":W")]
        local right = desired[F.key(sb:getX(), sb:getY(), sb:getZ()) .. (b:getNorth() and ":N" or ":W")]
        if left.role ~= right.role then return left.role == "front" end
        return left.key < right.key
    end)
    return found
end

---@param square IsoGridSquare Loaded square
---@return nil
function O.reconcile(square)
    if not store then return end
    rebuild()
    local objects = square:getSpecialObjects()
    local found = {}
    for i = objects:size() - 1, 0, -1 do
        local object = objects:get(i)
        local name = object:getName() or ""
        local key = string.sub(name, 1, #F.PREFIX) == F.PREFIX and string.match(name, ":(%d+:%d+:%-?%d+:[NW])$")
        if key then
            local edge = desired[key]
            if not edge or name ~= F.PREFIX .. edge.id .. ":" .. key or found[key]
                or edge.x ~= square:getX() or edge.y ~= square:getY() or edge.z ~= square:getZ()
                or object:getNorth() ~= edge.north then
                removing[object] = true
                square:transmitRemoveItemFromSquare(object)
                removing[object] = nil
                square:RecalcAllWithNeighbours(true)
            else
                found[key] = object
                if object:getModData().OMHTTEdge ~= edge then
                    object:getModData().OMHTTEdge = edge
                    if isServer() then
                        object:transmitModData()
                    end
                end
            end
        end
    end
    local base = F.key(square:getX(), square:getY(), square:getZ())
    local nEdge, wEdge = desired[base .. ":N"], desired[base .. ":W"]
    local both = nEdge and wEdge
        and (found[nEdge.key] or footprint.parts(store.tiles[nEdge.anchor].device))
        and (found[wEdge.key] or footprint.parts(store.tiles[wEdge.anchor].device))
    for _, suffix in pairs({":N", ":W"}) do
        local edge = desired[base .. suffix]
        local sprite = "omhtt_barrier_01_16"
        if suffix == ":W" then
            sprite = "omhtt_barrier_01_17"
        end
        if both then
            sprite = "omhtt_barrier_01_18"
            if suffix == ":W" then
                sprite = "omhtt_barrier_01_19"
            end
        end
        if edge and found[edge.key] and found[edge.key]:getSpriteName() ~= sprite then
            found[edge.key]:setSpriteFromName(sprite)
            found[edge.key]:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_MODIFY)
            square:RecalcAllWithNeighbours(true)
            if isServer() then
                found[edge.key]:transmitUpdatedSpriteToClients()
            end
        end
        if edge and not found[edge.key] then
            local record = store.tiles[edge.anchor].device
            if footprint.parts(record) then
                local object = IsoThumpable.new(square:getCell(), square, sprite, edge.north)
                object:setName(F.PREFIX .. edge.id .. ":" .. edge.key)
                object:setBlockAllTheSquare(false)
                object:setCanPassThrough(false)
                object:setIsHoppable(false)
                object:setIsThumpable(true)
                object:setIsDismantable(false)
                object:setBreakSound("BreakObject")
                object:setMaxHealth(record.maxHealth)
                object:setHealth(record.condition)
                object:getModData().OMHTTEdge = edge
                square:AddSpecialObject(object)
                square:RecalcAllWithNeighbours(true)
                square:setSquareChanged()
                object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_ADD)
                if isServer() then
                    object:transmitCompleteItemToClients()
                end
                D.emit("barrier-outline-edge", {id = edge.id, key = edge.key, role = edge.role,
                    facing = edge.facing, north = edge.north, hp = record.condition})
            end
        end
    end
end

---@param record table Owner whose topology may have changed
---@return nil
function O.refresh(record)
    local fronts, caps = G.shape(record)
    for _, list in pairs({fronts, caps}) do
        for i = 1, #list do
            local edge = list[i]
            local square = getCell():getGridSquare(edge.x, edge.y, edge.z)
            if square then
                O.reconcile(square)
            end
        end
    end
end

---@param object IsoObject Native removal target
---@return boolean handled Collider-specific removal
function O.onRemoved(object)
    if removing[object] then return true end
    local record = owner(object)
    if not record then return false end
    local slot = store.tiles[record.slotKey or F.key(record.x, record.y, record.z)]
    footprint.retire(slot, object)
    return true
end

return O
