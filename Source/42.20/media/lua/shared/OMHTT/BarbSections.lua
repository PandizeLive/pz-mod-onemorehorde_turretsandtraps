local F = require("OMHTT/Foundation")
local S = require("OMHTT/BarbSupport")
local C = require("OMHTT/BarbContact")
local B = {nodes = {}, order = {}, nearby = {}, time = 0, cursor = 1, session = tostring(getTimestampMs())}
OMHTT_BarbSections = B
B.policy = {fixedWindowFrame = true}
local ActiveTime = require("OMHTT/ActiveTime")
local clock = ActiveTime.new()
local moving = false
local geometry = {}
local resolvedObjects = {}
local wireFacings = {e = 0, n = 1, w = 2, s = 3}
local wireBindings = setmetatable({}, {__mode = "k"})
local wireTiles = {}

---@param record table Authoritative wire
---@param part number Zero-based half
---@return string key Tile identity
---@nodiscard
local function wireKey(record, part)
    return F.key(record.x + part * (record.facing % 2), record.y + part * (1 - record.facing % 2), record.z)
end

---@param object IsoObject Exact native half
---@param record table Private wire record
---@return nil
local function bindWire(object, record)
    record.revision = record.revision or 1
    wireBindings[object] = record
    wireTiles[wireKey(record, 0)], wireTiles[wireKey(record, 1)] = record.id, record.id
    local view = {}
    for key, value in pairs(record) do
        view[key] = value
    end
    object:getModData().OMHTTBarbFrame = {id = record.id, kind = "wire", paired = true, view = view}
end

---@param name string Setting suffix
---@param fallback number Default
---@param minimum number Lower bound
---@param maximum number Upper bound
---@return number value
---@nodiscard
function B.option(name, fallback, minimum, maximum)
    local options = SandboxVars.OMHTurretsTraps
    local value = options and tonumber(options["Barb" .. name])
    if value == nil then
        value = fallback
    end
    return math.max(minimum, math.min(maximum, value))
end

---@return boolean enabled
---@nodiscard
function B.enabled(kind)
    if (isClient() or isServer()) and kind ~= "wire" then return false end
    local options = SandboxVars.OMHTurretsTraps
    return options ~= nil and options.Enabled ~= false and options[kind == "wire" and "BarbWire" or "BarbSections"] ~= false
end

---@return boolean enabled
function B.wireEnabled() return B.enabled("wire") end

---@return nil
function B.initialize()
    if isClient() then
        B.store = {nextId = 1, wires = {}}
    else
        B.store = ModData.getOrCreate("OMHTTBarbs")
    end
    if B.store.nextId == nil then
        B.store.nextId = 1
    end
    if not B.store.wires then B.store.wires = {} end
    if not B.store.retiredTiles then B.store.retiredTiles = {} end
    B.nodes, B.order, B.nearby = {}, {}, {}
    B.cursor = 1
    resolvedObjects = {}
    wireBindings, wireTiles = setmetatable({}, {__mode = "k"}), {}
    for id, record in pairs(B.store.wires) do
        wireTiles[wireKey(record, 0)], wireTiles[wireKey(record, 1)] = id, id
    end
end

---@param record table Frame marker
---@param adding boolean Add or remove local index
---@return nil
function B.index(record, adding)
    resolvedObjects[record.id] = nil
    resolvedObjects[record.id .. ":0"], resolvedObjects[record.id .. ":1"] = nil, nil
    local width = record.paired and record.facing % 2 == 1 and 2 or 1
    local height = record.paired and record.facing % 2 == 0 and 2 or 1
    for dx = -1, width do
        for dy = -1, height do
            local key = F.key(record.x + dx, record.y + dy, record.z)
            local bucket = B.nearby[key]
            if adding then
                if not bucket then
                    bucket = {}
                    B.nearby[key] = bucket
                end
                bucket[record.id] = true
            elseif bucket then
                bucket[record.id] = nil
                local empty = true
                for _ in pairs(bucket) do
                    empty = false
                    break
                end
                if empty then
                    B.nearby[key] = nil
                end
            end
        end
    end
    if adding then
        B.order[#B.order + 1] = record.id
        B.nodes[record.id] = {record = record, slot = #B.order}
    else
        local node = B.nodes[record.id]
        if not node then return end
        local last = B.order[#B.order]
        B.order[node.slot] = last
        B.order[#B.order] = nil
        if last ~= record.id then
            B.nodes[last].slot = node.slot
        end
        B.nodes[record.id] = nil
    end
end

---@param object IsoObject? Frame
---@return table? record
---@nodiscard
function B.record(object)
    if isServer() then
        local record = object and wireBindings[object]
        local square = object and object:getSquare()
        if record and B.store and B.store.wires[record.id] == record and square
            and wireTiles[F.key(square:getX(), square:getY(), square:getZ())] == record.id then return record end
        return nil
    end
    local marker = object and object:hasModData() and object:getModData().OMHTTBarbFrame
    if isClient() then
        local view = marker and marker.view
        if not view or not view.paired or not B.store then return nil end
        local record = B.store.wires[view.id]
        if not record then
            record = {}
            B.store.wires[view.id] = record
        end
        if not record.revision or view.revision >= record.revision then
            for key, value in pairs(view) do
                record[key] = value
            end
        end
        return record
    end
    if marker and marker.paired then return B.store and B.store.wires[marker.id] end
    return marker or nil
end

---@param record table Wire identity
---@param part number Zero-based half
---@return IsoObject? object
---@return string status
function B.wirePart(record, part)
    local x, y = record.x, record.y
    if part == 1 then
        if record.facing % 2 == 0 then y = y + 1 else x = x + 1 end
    end
    local square = getCell():getGridSquare(x, y, record.z)
    if not square then return nil, "unloaded" end
    local key = record.id .. ":" .. part
    local cached = resolvedObjects[key]
    if cached and cached:getSquare() == square and cached:getObjectIndex() >= 0 and B.record(cached) == record then return cached, "active" end
    resolvedObjects[key] = nil
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        local marker = object:hasModData() and object:getModData().OMHTTBarbFrame
        if (isServer() and B.record(object) == record) or (not isServer() and marker and marker.id == record.id) then
            resolvedObjects[key] = object
            return object, "active"
        end
    end
    return nil, "missing"
end

---@param record table Changed authoritative wire
---@return nil
function B.publishWire(record)
    if not isServer() or not record.paired or B.store.wires[record.id] ~= record then return end
    record.revision = (record.revision or 1) + 1
    for part = 0, 1 do
        local object = B.wirePart(record, part)
        if object then
            bindWire(object, record)
            object:transmitModData()
        end
    end
end

---@param record table Frame marker
---@return IsoObject? frame
---@return IsoObject? host Exact support even when inactive
---@return table? attachment Durable host state
---@return string status
---@nodiscard
function B.resolve(record)
    if record.paired then
        if B.store.wires[record.id] ~= record then return nil, nil, nil, "missing" end
        local first, firstStatus = B.wirePart(record, 0)
        local second, secondStatus = B.wirePart(record, 1)
        if firstStatus == "unloaded" or secondStatus == "unloaded" then return first, second, record, "unloaded" end
        return first, second, record, first and second and record.health > 0 and "active" or "missing"
    end
    local square = getCell():getGridSquare(record.x, record.y, record.z)
    if not square then return nil, nil, nil, "unloaded" end
    local cached = resolvedObjects[record.id]
    local frame, host = cached and cached.frame, cached and cached.host
    local valid = frame and host and frame:getSquare() == square and host:getSquare() == square
        and frame:getObjectIndex() >= 0 and host:getObjectIndex() >= 0 and B.record(frame) == record
        and (record.kind == "wire" or S.attachment(host, record.north, record.side) == record.id)
    if not valid then
        frame, host = nil, nil
        local objects = square:getObjects()
        for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        local marker = B.record(object)
        if marker and marker.id == record.id then
            frame = object
        end
        if record.kind ~= "wire" and S.attachment(object, record.north, record.side) == record.id then
            host = object
        end
    end
        if record.kind == "wire" then host = frame end
        resolvedObjects[record.id] = frame and host and {frame = frame, host = host} or nil
    end
    if record.kind == "wire" then
        return frame, frame, frame and B.record(frame), frame and record.health > 0 and "active" or "missing"
    end
    if not frame or not host then return frame, host, nil, "missing" end
    local attachment = host:getModData().OMHTTBarbs[S.faceKey(record.north, record.side)]
    if (not attachment.shared and attachment.health <= 0) or not S.active(host, record.north, B.policy)
        or not S.edge(host, record.north, record.side, geometry) then return frame, host, attachment, "inactive" end
    return frame, host, attachment, "active"
end

---@param record table Frame marker
---@return nil
---@param removing IsoObject? Object already being removed by the engine
function B.retire(record, removing)
    if isClient() then return end
    if record.paired then
        local first, second = B.wirePart(record, 0), B.wirePart(record, 1)
        if isServer() then
            for part = 0, 1 do
                local x = record.x + part * (record.facing % 2)
                local y = record.y + part * (1 - record.facing % 2)
                if not getCell():getGridSquare(x, y, record.z) then
                    B.store.retiredTiles[wireKey(record, part)] = "omhtt_barrier_01_"
                        .. (record.facing + (part == 0 and 60 or 72))
                end
            end
        end
        if B.nodes[record.id] then B.index(record, false) end
        B.store.wires[record.id] = nil
        wireTiles[wireKey(record, 0)], wireTiles[wireKey(record, 1)] = nil, nil
        moving = true
        if first and first ~= removing then first:getSquare():transmitRemoveItemFromSquare(first) end
        if second and second ~= removing then second:getSquare():transmitRemoveItemFromSquare(second) end
        moving = false
        return
    end
    local frame, host = B.resolve(record)
    if host and record.kind ~= "wire" then
        S.unbind(host, record.north, record.side, record.id)
    end
    if B.nodes[record.id] then
        B.index(record, false)
    end
    if frame then
        frame:getSquare():transmitRemoveItemFromSquare(frame)
    end
end

---@param record table Frame marker
---@param frame IsoThumpable Marker object
---@param host IsoObject Backing object
---@return nil
function B.visual(record, frame, host)
    if record.kind == "wire" then return end
    if not S.edge(host, record.north, record.side, geometry) then return end
    local index = geometry.north and 52 or 54
    if geometry.x > record.x then
        index = 56
    end
    if geometry.y > record.y then
        index = 58
    end
    if geometry.side < 0 then
        index = index + 1
    end
    local name = "omhtt_barrier_01_" .. index
    if frame:getSpriteName() ~= name then
        frame:setSprite(name)
        frame:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_MODIFY)
    end
end

---@param square IsoGridSquare Loaded square
---@return nil
function B.loaded(square)
    if not B.store then return end
    local objects = square:getObjects()
    if isServer() then
        local key = F.key(square:getX(), square:getY(), square:getZ())
        local retiredSprite = B.store.retiredTiles[key]
        if retiredSprite then
            moving = true
            for i = objects:size() - 1, 0, -1 do
                local object = objects:get(i)
                if instanceof(object, "IsoThumpable") and object:getSpriteName() == retiredSprite then
                    square:transmitRemoveItemFromSquare(object)
                end
            end
            moving = false
            B.store.retiredTiles[key] = nil
        end
        local id = wireTiles[key]
        local record = id and B.store.wires[id]
        if not record then return end
        local part = F.key(square:getX(), square:getY(), square:getZ()) == wireKey(record, 0) and 0 or 1
        local expected = "omhtt_barrier_01_" .. (record.facing + (part == 0 and 60 or 72))
        for i = 0, objects:size() - 1 do
            local object = objects:get(i)
            if instanceof(object, "IsoThumpable") and object:getSpriteName() == expected then
                bindWire(object, record)
                if not B.nodes[id] then
                    B.index(record, true)
                end
                return
            end
        end
        return
    end
    for i = objects:size() - 1, 0, -1 do
        local object = objects:get(i)
        local record = B.record(object)
        local marker = object:hasModData() and object:getModData().OMHTTBarbFrame
        if marker and marker.paired and not record and not isClient() then square:transmitRemoveItemFromSquare(object) end
        if record and not B.nodes[record.id] then
            B.index(record, true)
        end
    end
end

---@param object IsoObject Removed world object
---@return nil
function B.removed(object)
    if moving then return end
    local record = B.record(object)
    if not record then return end
    if record.paired then B.retire(record, object); return end
    local _, host = B.resolve(record)
    if host and record.kind ~= "wire" then
        S.unbind(host, record.north, record.side, record.id)
    end
    if B.nodes[record.id] then
        B.index(record, false)
    end
end

---@param params table Native construction preview
---@return boolean valid
---@nodiscard
function B.onIsValid(params)
    if not B.enabled() or not B.store or not params.square then return false end
    local floor = params.square
    if not floor:getFloor() or floor:HasStairs() or floor:HasStairsBelow() or floor:isVehicleIntersecting()
        or floor:has(IsoFlagType.water) or floor:isSolid() or floor:isSolidTrans() then return false end
    local x, y, north, side = C.edge(floor:getX(), floor:getY(), params.facing)
    if not x then return false end
    local square = getCell():getGridSquare(x, y, floor:getZ())
    local host = S.find(square, north)
    if not host or S.attachment(host, north, side) or not S.active(host, north, B.policy)
        or not S.edge(host, north, side, geometry) then return false end
    if (instanceof(host, "IsoDoor") or (instanceof(host, "IsoThumpable") and host:isDoor())) and host:IsOpen() then return false end
    params.testCollisions = false
    return true
end

---@param params table Native completed construction
---@return table? result Native replacement object
function B.onCreate(params)
    if isClient() then return end
    if not B.enabled() or not B.store then error("[OMHTT] Barb construction unavailable") end
    local original = params.thumpable
    if B.record(original) then return end
    local old = original:getSquare()
    local x, y, north, side = C.edge(old:getX(), old:getY(), params.facing)
    local square = x and getCell():getGridSquare(x, y, old:getZ())
    local host = S.find(square, north)
    local id = "barb-" .. B.store.nextId
    if not host or not S.bind(host, north, side, id, B.policy) then error("[OMHTT] Barb backing changed before construction") end
    B.store.nextId = B.store.nextId + 1
    local record = {id = id, x = x, y = y, z = square:getZ(), north = north, side = side}
    local frame = IsoThumpable.new(square:getCell(), square, "omhtt_barrier_01_52", north)
    frame:getModData().OMHTTBarbFrame = record
    original:getModData().OMHTTBarbFrame = record
    frame:setBlockAllTheSquare(false)
    frame:setCanPassThrough(true)
    frame:setIsHoppable(false)
    frame:setIsThumpable(false)
    frame:setIsDismantable(false)
    moving = true
    square:AddSpecialObject(frame)
    old:transmitRemoveItemFromSquare(original)
    moving = false
    if not B.nodes[id] then
        B.index(record, true)
    end
    B.visual(record, frame, host)
    return {replaceObject = true, object = frame}
end

---@param params table Native two-tile wire preview
---@return boolean valid
function B.onWireValid(params)
    if not B.wireEnabled() or not B.store or not params.square or not params.tileInfo then return false end
    local facing = wireFacings[params.facing]
    if facing == nil then return false end
    local x, y, z = params.square:getX() - params.tileInfo:getX(), params.square:getY() - params.tileInfo:getY(), params.square:getZ()
    local first = getCell():getGridSquare(x, y, z)
    local second = getCell():getGridSquare(x + (facing % 2), y + (1 - facing % 2), z)
    local Beds = require("OMHTT/BedSpikes")
    if not Beds.clear(first) or not Beds.clear(second) or first:isSomethingTo(second) then return false end
    params.testCollisions = false
    return true
end

---@param params table Native wire construction completion
---@return nil
function B.onWireCreate(params)
    if isClient() then return end
    if not B.wireEnabled() or not B.store then error("[OMHTT] Wire construction unavailable") end
    local object = params.thumpable
    if B.record(object) then return end
    local square = object:getSquare()
    local index = tonumber(string.match(object:getSpriteName(), "^omhtt_barrier_01_(%d+)$"))
    if not index or (index < 60 or index > 63) and (index < 72 or index > 75) then error("[OMHTT] Invalid wire sprite") end
    local part = index >= 72 and 1 or 0
    local facing = index >= 72 and index - 72 or index - 60
    local x, y = square:getX() - part * (facing % 2), square:getY() - part * (1 - facing % 2)
    local record
    if part == 1 then
        local first = getCell():getGridSquare(x, y, square:getZ())
        local objects = first and first:getObjects()
        if objects then
            for i = objects:size() - 1, 0, -1 do
                local candidate = B.record(objects:get(i))
                if candidate and candidate.paired and candidate.facing == facing and candidate.x == x and candidate.y == y then record = candidate; break end
            end
        end
        if not record then error("[OMHTT] Wire anchor missing during construction") end
    else
        if isServer() and wireTiles[F.key(x, y, square:getZ())] then
            error("[OMHTT] Duplicate wire placement")
        end
        record = {id = "barb-" .. B.store.nextId, kind = "wire", x = x, y = y,
            z = square:getZ(), health = 50, shared = false, paired = true, facing = facing, revision = 1}
        B.store.nextId = B.store.nextId + 1
        B.store.wires[record.id] = record
    end
    object:getModData().OMHTTBarbFrame = {id = record.id, kind = "wire", paired = true}
    if isServer() then
        bindWire(object, record)
    end
    object:setBlockAllTheSquare(false)
    object:setCanPassThrough(true)
    object:setIsHoppable(false)
    object:setIsThumpable(false)
    object:setIsDismantable(false)
    if part == 1 and not B.nodes[record.id] then B.index(record, true) end
end

---@param actor IsoGameCharacter Updated actor
---@param bucket table? Already located nearby hazards
---@return table? selected One touching hazard, shared by damage and movement
---@return table? attachment Durable state
function B.contact(actor, bucket)
    local square = actor:getSquare()
    if #B.order == 0 or not square then return nil end
    bucket = bucket or B.nearby[F.key(square:getX(), square:getY(), square:getZ())]
    if not bucket then return nil end
    local selected, source = nil, nil
    local x, y, z = actor:getX(), actor:getY(), actor:getZ()
    for id in pairs(bucket) do
        local node = B.nodes[id]
        local wire = node and node.record.kind == "wire"
        local touchingWire = false
        if wire and math.floor(z) == node.record.z then
            local dx, dy = math.floor(x) - node.record.x, math.floor(y) - node.record.y
            touchingWire = dx == 0 and dy == 0 or node.record.paired and
                (node.record.facing % 2 == 0 and dx == 0 and dy == 1 or node.record.facing % 2 == 1 and dx == 1 and dy == 0)
        end
        if node and B.enabled(node.record.kind) and (not wire or touchingWire) then
            local record = node.record
            local _, host, attachment, status = B.resolve(record)
            local touching = false
            if status == "active" then
                if record.kind == "wire" then
                    touching = true
                else
                    touching = S.edge(host, record.north, record.side, geometry)
                        and C.touching(geometry, x, y, z, actor:getWidth())
                end
            end
            if touching and (not selected or id < selected.id) then selected, source = record, attachment end
        end
    end
    return selected, source
end

---@return nil
function B.tick()
    if isClient() then return end
    B.time = B.time + ActiveTime.step(clock)
    for _ = 1, math.min(4, #B.order) do
        if B.cursor > #B.order then
            B.cursor = 1
        end
        local node = B.nodes[B.order[B.cursor]]
        if not node then break end
        local frame, host, _, status = B.resolve(node.record)
        if status == "unloaded" then
            B.index(node.record, false)
        elseif status ~= "active" then
            B.retire(node.record)
        else
            B.visual(node.record, frame, host)
            B.cursor = B.cursor + 1
        end
    end
end

OMHTT_BarbMenuAvailable = function() return B.enabled() end
OMHTT_BarbWireMenuAvailable = B.wireEnabled
Events.OnInitGlobalModData.Add(B.initialize)
Events.LoadGridsquare.Add(B.loaded)
Events.OnObjectAboutToBeRemoved.Add(B.removed)
Events.OnTick.Add(B.tick)
return B
