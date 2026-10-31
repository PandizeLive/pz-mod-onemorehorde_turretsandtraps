local S = {}
local bindings = setmetatable({}, {__mode = "k"})

---@return nil
function S.reset()
    bindings = setmetatable({}, {__mode = "k"})
end

---@param object IsoObject Exact support
---@param north boolean Support axis
---@param side number Exposed face
---@return table? record Private server attachment or detached local view
function S.record(object, north, side)
    if not object then return nil end
    local entries = isServer() and bindings[object] or nil
    if not isServer() and object:hasModData() then
        entries = object:getModData().OMHTTBarbs
    end
    return entries and entries[S.faceKey(north, side)]
end

---@param object IsoObject Bound support
---@return nil
function S.publish(object)
    if not isServer() then return end
    local view = {}
    for key, record in pairs(bindings[object] or {}) do
        local copy = {}
        for field, value in pairs(record) do copy[field] = value end
        view[key] = copy
    end
    object:getModData().OMHTTBarbs = view
    object:transmitModData()
end

---@param object IsoObject Exact native support validated against the private frame registry
---@param record table Persistent private attachment
---@return nil
function S.restore(object, record)
    if not isServer() then return end
    local entries = bindings[object]
    if not entries then
        entries = {}
        bindings[object] = entries
    end
    entries[S.faceKey(record.north, record.side)] = record
end

---@param object IsoObject Candidate support
---@param north boolean Selected backing edge
---@param nativeOnly boolean? Private ledger restoration ignores public markers
---@return string? kind
---@nodiscard
function S.kind(object, north, nativeOnly)
    if not object or not object:getSquare() or object:getObjectIndex() < 0 then return nil end
    if object:hasModData() and not nativeOnly and not (isServer() and bindings[object]) then
        local data = object:getModData()
        if data.OMHTTBed or data.OMHTTBarbFrame or data.OMHTT or data.OMHTTEdge or data.OMHTTTurret then return nil end
    end
    if instanceof(object, "IsoDoor") then
        if object:getNorth() == north then return "door" end
        return nil
    end
    if instanceof(object, "IsoWindow") then
        if object:getNorth() == north then return "window" end
        return nil
    end
    local properties = object:getProperties()
    if instanceof(object, "IsoThumpable") then
        if object:isDoor() then return object:getNorth() == north and "constructed-door" or nil end
        if object:isWindow() then return object:getNorth() == north and "constructed-window" or nil end
        if object:isHoppable() or object:isTallHoppable() then return object:getNorth() == north and "constructed-fence" or nil end
        if properties and (properties:has(north and IsoFlagType.collideN or IsoFlagType.collideW)
            or properties:has(north and IsoFlagType.WallN or IsoFlagType.WallW)) then
            return "constructed-wall"
        end
        return nil
    end
    if not properties then return nil end
    if properties:has(north and IsoFlagType.HoppableN or IsoFlagType.HoppableW)
        or properties:has(north and IsoFlagType.TallHoppableN or IsoFlagType.TallHoppableW) then
        return "map-fence"
    end
    if properties:has(north and IsoFlagType.collideN or IsoFlagType.collideW)
        and properties:has(north and IsoFlagType.WallN or IsoFlagType.WallW) then
        return "map-wall"
    end
    return nil
end

---@param object IsoObject Candidate support
---@param north boolean Selected backing edge
---@param policy table Explicit fixedWindowFrame choice
---@return boolean active
---@return string reason
---@nodiscard
function S.active(object, north, policy)
    local kind = S.kind(object, north)
    if not kind then return false, "unsupported" end
    if kind == "map-wall" or kind == "map-fence" then
        return true, "native-lifetime"
    end
    if kind == "window" and policy.fixedWindowFrame then return true, "window-frame" end
    if object:isDestroyed() or object:getHealth() <= 0 then return false, "broken" end
    if kind == "door" or kind == "constructed-door" then
        return true, "door"
    end
    if kind == "window" then
        if object:isSmashed() then return false, "broken" end
        return true, "window"
    end
    if kind == "constructed-window" then
        return true, "window"
    end
    return true, kind
end

---@param north boolean Backing axis
---@param side number Exposed side sign
---@return string key
---@nodiscard
function S.faceKey(north, side)
    return (north and "n" or "w") .. tostring(side)
end

---@param object IsoObject Exact backing
---@param north boolean Backing axis
---@param side number Exposed side sign
---@return string? id Existing attachment
---@nodiscard
function S.attachment(object, north, side)
    local record = S.record(object, north, side)
    return record and record.id
end

---@param object IsoObject Support
---@param north boolean Backing axis
---@param policy table Explicit fixedWindowFrame choice
---@return boolean shared Native finite damageable health
---@nodiscard
function S.sharedHealth(object, north, policy)
    local kind = S.kind(object, north)
    if not kind or kind == "map-wall" or kind == "map-fence" then return false end
    if kind == "window" and policy.fixedWindowFrame then return false end
    if instanceof(object, "IsoThumpable") and not object:isThumpable() then return false end
    local health = object:getHealth()
    return health > 0 and health < math.huge
end

---@param object IsoObject Support
---@param north boolean Original backing axis
---@param side number Original exposed side sign
---@param result table Reused output geometry
---@return boolean located
function S.edge(object, north, side, result)
    local kind = S.kind(object, north)
    if not kind then return false end
    local square = object:getSquare()
    result.x, result.y, result.z = square:getX(), square:getY(), square:getZ()
    result.north, result.side, result.contact = north, side, true
    if kind ~= "door" and kind ~= "constructed-door" then return true end
    local properties = object:getProperties()
    if properties and properties:has(IsoPropertyType.DOUBLE_DOOR) then return false end
    if properties and properties:has(IsoPropertyType.GARAGE_DOOR) then
        result.contact = not object:IsOpen()
        return true
    end
    local direction = object:getSpriteEdge(false)
    if direction == IsoDirections.N then
        result.north = true
    elseif direction == IsoDirections.W then
        result.north = false
    elseif direction == IsoDirections.E then
        result.north, result.x = false, result.x + 1
    elseif direction == IsoDirections.S then
        result.north, result.y = true, result.y + 1
    else
        return false
    end
    if object:IsOpen() and (direction == IsoDirections.N or direction == IsoDirections.W) then
        result.side = -side
    end
    return true
end

---@param square IsoGridSquare? Loaded backing square
---@param north boolean Selected edge
---@param nativeOnly boolean? Private ledger restoration
---@return IsoObject? host Exact primary support, even when currently open
---@nodiscard
function S.find(square, north, nativeOnly)
    if not square then return nil end
    local objects = square:getObjects()
    local backing = nil
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        local kind = S.kind(object, north, nativeOnly)
        if kind == "door" or kind == "window" or kind == "constructed-door" or kind == "constructed-window" then
            return object
        end
        if kind and not backing then
            backing = object
        end
    end
    return backing
end

---@param object IsoObject Exact selected support
---@param north boolean Backing axis
---@param side number Exposed side sign
---@param id string Unique attachment identity
---@param policy table Explicit lifecycle choices
---@return boolean bound
function S.bind(object, north, side, id, policy)
    if isClient() or type(id) ~= "string" or id == "" or (side ~= -1 and side ~= 1)
        or not S.active(object, north, policy) or S.attachment(object, north, side) then return false end
    local edge = {}
    if not S.edge(object, north, side, edge) or not edge.contact then return false end
    local data = object:getModData()
    if not data.OMHTTBarbs then
        data.OMHTTBarbs = {}
    end
    local record = {id = id, north = north, side = side, shared = S.sharedHealth(object, north, policy)}
    if not record.shared then
        record.health = 50
    end
    if isServer() then
        S.restore(object, record)
        S.publish(object)
    else
        data.OMHTTBarbs[S.faceKey(north, side)] = record
    end
    return true
end

---@param record table Bound attachment
---@param damage number Actual health lost by the victim
---@return boolean broken
function S.wear(record, damage)
    if record.shared or damage <= 0 then return false end
    record.health = math.max(0, record.health - 1)
    return record.health == 0
end

---@param record table Bound attachment
---@return boolean repaired
function S.repair(record)
    if record.shared or record.health <= 0 or record.health >= 50 then return false end
    record.health = 50
    return true
end

---@param object IsoObject Exact selected support
---@param north boolean Backing axis
---@param side number Exposed side sign
---@param id string Expected attachment identity
---@return boolean removed
function S.unbind(object, north, side, id)
    if isClient() or not id or S.attachment(object, north, side) ~= id then return false end
    if isServer() then
        bindings[object][S.faceKey(north, side)] = nil
        S.publish(object)
    else
        object:getModData().OMHTTBarbs[S.faceKey(north, side)] = nil
    end
    return true
end

---@param square IsoGridSquare? Loaded backing square
---@param north boolean Backing axis
---@param side number Exposed side sign
---@param id string Expected attachment identity
---@param policy table Explicit lifecycle choices
---@return IsoObject? host Active exact attachment
---@return string status Active, unloaded, missing or inactive
---@nodiscard
function S.resolve(square, north, side, id, policy)
    if not square then return nil, "unloaded" end
    if not id then return nil, "missing" end
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        if S.attachment(object, north, side) == id then
            local record = S.record(object, north, side)
            if not record.shared and record.health <= 0 then return nil, "worn-out" end
            if S.active(object, north, policy) then return object, "active" end
            return nil, "inactive"
        end
    end
    return nil, "missing"
end

return S
