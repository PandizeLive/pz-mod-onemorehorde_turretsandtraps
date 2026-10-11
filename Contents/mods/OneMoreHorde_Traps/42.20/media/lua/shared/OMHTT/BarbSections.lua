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
    local options = SandboxVars.OMHTurretsTraps
    return not isClient() and not isServer() and options ~= nil and options.Enabled ~= false and options[kind == "wire" and "BarbWire" or "BarbSections"] ~= false
end

---@return boolean enabled
function B.wireEnabled() return B.enabled("wire") end

---@return nil
function B.initialize()
    if isClient() or isServer() then return end
    B.store = ModData.getOrCreate("OMHTTBarbs")
    if B.store.nextId == nil then
        B.store.nextId = 1
    end
    B.nodes, B.order, B.nearby = {}, {}, {}
    B.cursor = 1
end

---@param record table Frame marker
---@param adding boolean Add or remove local index
---@return nil
function B.index(record, adding)
    for dx = -1, 1 do
        for dy = -1, 1 do
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
    return object and object:hasModData() and object:getModData().OMHTTBarbFrame or nil
end

---@param record table Frame marker
---@return IsoObject? frame
---@return IsoObject? host Exact support even when inactive
---@return table? attachment Durable host state
---@return string status
---@nodiscard
function B.resolve(record)
    local square = getCell():getGridSquare(record.x, record.y, record.z)
    if not square then return nil, nil, nil, "unloaded" end
    local objects, frame, host = square:getObjects(), nil, nil
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
function B.retire(record)
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
    for i = 0, objects:size() - 1 do
        local record = B.record(objects:get(i))
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

---@param params table Native one-tile wire preview
---@return boolean valid
function B.onWireValid(params)
    if not B.wireEnabled() or not B.store or not require("OMHTT/BedSpikes").clear(params.square) then return false end
    params.testCollisions = false
    return true
end

---@param params table Native wire construction completion
---@return nil
function B.onWireCreate(params)
    if not B.wireEnabled() or not B.store then error("[OMHTT] Wire construction unavailable") end
    local object = params.thumpable
    if B.record(object) then return end
    local square = object:getSquare()
    local record = {id = "barb-" .. B.store.nextId, kind = "wire", x = square:getX(), y = square:getY(),
        z = square:getZ(), health = 50, shared = false}
    B.store.nextId = B.store.nextId + 1
    object:getModData().OMHTTBarbFrame = record
    object:setBlockAllTheSquare(false)
    object:setCanPassThrough(true)
    object:setIsHoppable(false)
    object:setIsThumpable(false)
    object:setIsDismantable(false)
    B.index(record, true)
end

---@param actor IsoGameCharacter Updated actor
---@return table? selected One touching hazard, shared by damage and movement
---@return table? attachment Durable state
function B.contact(actor)
    local square = actor:getSquare()
    if #B.order == 0 or not square then return nil end
    local bucket = B.nearby[F.key(square:getX(), square:getY(), square:getZ())]
    if not bucket then return nil end
    local selected, source = nil, nil
    for id in pairs(bucket) do
        local node = B.nodes[id]
        if node and B.enabled(node.record.kind) then
            local record = node.record
            local _, host, attachment, status = B.resolve(record)
            local touching = false
            if status == "active" then
                if record.kind == "wire" then
                    touching = math.floor(actor:getX()) == record.x and math.floor(actor:getY()) == record.y
                        and math.floor(actor:getZ()) == record.z
                else
                    touching = S.edge(host, record.north, record.side, geometry)
                        and C.touching(geometry, actor:getX(), actor:getY(), actor:getZ(), actor:getWidth())
                end
            end
            if touching and (not selected or id < selected.id) then selected, source = record, attachment end
        end
    end
    return selected, source
end

---@return nil
function B.tick()
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
if isClient() or isServer() then return B end
Events.OnInitGlobalModData.Add(B.initialize)
Events.LoadGridsquare.Add(B.loaded)
Events.OnObjectAboutToBeRemoved.Add(B.removed)
Events.OnTick.Add(B.tick)
return B
