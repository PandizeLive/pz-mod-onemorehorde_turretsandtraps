local F = require("OMHTT/Foundation")
local B = {tiles = {}, nearby = {}, indexed = {}, count = 0, time = 0, session = tostring(getTimestampMs())}
OMHTT_BedSpikes = B
local ActiveTime = require("OMHTT/ActiveTime")
local clock = ActiveTime.new()
local removing = false
local enabled = nil
local facings = {e = 0, n = 1, w = 2, s = 3}

---@param name string Sandbox suffix
---@param fallback number Default
---@param minimum number Minimum
---@param maximum number Maximum
---@return number value
---@nodiscard
function B.option(name, fallback, minimum, maximum)
    local options = SandboxVars.OMHTurretsTraps
    local value = options and tonumber(options["Bed" .. name])
    if value == nil then
        value = fallback
    end
    return math.max(minimum, math.min(maximum, value))
end

---@return boolean enabled
---@nodiscard
function B.enabled()
    local options = SandboxVars.OMHTurretsTraps
    return not isClient() and not isServer() and options ~= nil and options.Enabled ~= false and options.BedSpikes ~= false
end

---@return nil
function B.initialize()
    if isClient() or isServer() then
        return
    end
    B.store = ModData.getOrCreate("OMHTTBedSpikes")
    if B.store.nextId == nil then
        B.store.nextId, B.store.records = 1, {}
    end
    B.tiles, B.nearby, B.indexed = {}, {}, {}
    B.count = 0
end

---@param record table Bed record
---@return number health
---@nodiscard
function B.maxHealth(record)
    if record.tier == "reinforced" then return B.option("ReinforcedHealth", 100, 6, 10000) end
    return B.option("Health", 50, 6, 10000)
end

---@param record table Bed record
---@param part number Part 0 or 1
---@return number x
---@return number y
---@nodiscard
function B.position(record, part)
    if record.facing % 2 == 0 then return record.x, record.y + part end
    return record.x + part, record.y
end

---@param object IsoObject? Candidate
---@return table? record
---@nodiscard
function B.record(object)
    if not B.store or not object or not object:hasModData() then return nil end
    local marker = object:getModData().OMHTTBed
    return marker and B.store.records[marker.id]
end

---@param record table Bed record
---@return table objects Currently loaded parts
---@nodiscard
function B.parts(record)
    local result = {}
    local square = getCell():getGridSquare(record.x, record.y, record.z)
    if square then
        local objects = square:getSpecialObjects()
        for i = 0, objects:size() - 1 do
            local object = objects:get(i)
            if B.record(object) == record then
                result[#result + 1] = object
            end
        end
    end
    return result
end

---@param record table Bed record
---@param delta number Add or remove index
---@return nil
function B.index(record, delta)
    B.count = B.count + delta
    local key = F.key(record.x, record.y, record.z)
    if delta > 0 then
        B.tiles[key] = record.id
    else
        B.tiles[key] = nil
    end
    for dx = -2, 2 do
        for dy = -2, 2 do
            local near = F.key(record.x + dx, record.y + dy, record.z)
            local count = (B.nearby[near] or 0) + delta
            if count > 0 then
                B.nearby[near] = count
            else
                B.nearby[near] = nil
            end
        end
    end
    B.indexed[record.id] = delta > 0 or nil
end

---@param record table Bed record
---@param object IsoThumpable Loaded part
---@return nil
function B.configure(record, object)
    object:setBlockAllTheSquare(false)
    object:setCanPassThrough(true)
    object:setIsHoppable(false)
    object:setIsThumpable(false)
    object:setIsDismantable(false)
    object:setMaxHealth(record.maxHealth)
    object:setHealth(record.health)
    local part = object:getModData().OMHTTBed.part
    local offset = record.deployed and 8 or 0
    if record.tier == "reinforced" then
        offset = 16
    end
    local index = 28 + offset + record.facing * 2 + part
    if record.single then index = 64 + record.facing + (record.tier == "reinforced" and 4 or 0) end
    object:setSprite("omhtt_barrier_01_" .. index)
    object:getSprite():getProperties():set("Bush", "true")
    object:getSquare():RecalcAllWithNeighbours(true)
    object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_MODIFY)
    if not B.indexed[record.id] then
        B.index(record, 1)
    end
end

---@param record table Bed record
---@return nil
function B.retire(record)
    local parts = B.parts(record)
    if B.indexed[record.id] then
        B.index(record, -1)
    end
    B.store.records[record.id] = nil
    removing = true
    for i = 1, #parts do parts[i]:getSquare():transmitRemoveItemFromSquare(parts[i]) end
    removing = false
end

---@param object IsoObject Removed world object
---@return nil
function B.removed(object)
    if removing then
        return
    end
    local record = B.record(object)
    if not record then
        return
    end
    if B.indexed[record.id] then B.index(record, -1) end
    B.store.records[record.id] = nil
end

---@param square IsoGridSquare Loaded square
---@return nil
function B.loaded(square)
    if not B.store then
        return
    end
    local objects = square:getSpecialObjects()
    for i = objects:size() - 1, 0, -1 do
        local object = objects:get(i)
        local marker = object:hasModData() and object:getModData().OMHTTBed
        if marker then
            local record = B.store.records[marker.id]
            if record then
                B.configure(record, object)
            else
                square:transmitRemoveItemFromSquare(object)
            end
        end
    end
end

---@param square IsoGridSquare? Candidate floor
---@return boolean clear
---@nodiscard
function B.clear(square)
    if not square or not square:getFloor() or square:HasStairs() or square:HasStairsBelow()
        or square:isVehicleIntersecting() or square:has(IsoFlagType.water) or square:getMovingObjects():size() > 0
        or square:isSolid() or square:isSolidTrans() then return false end
    local support = require("OMHTT/BarbSupport")
    local objects = square:getSpecialObjects()
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        local marker = object:hasModData() and object:getModData().OMHTTBarbFrame
        if (marker and marker.kind == "wire") or not marker and not support.kind(object, true) and not support.kind(object, false) then return false end
    end
    return true
end

---@param params table Native placement validation
---@return boolean valid
---@nodiscard
function B.onIsValid(params)
    if not B.enabled() or not B.store or not params.square or not params.tileInfo then return false end
    local facing = facings[params.facing]
    if facing == nil then return false end
    local record = {x = params.square:getX() - params.tileInfo:getX(), y = params.square:getY() - params.tileInfo:getY(),
        z = params.square:getZ(), facing = facing}
    for part = 0, 1 do
        local x, y = B.position(record, part)
        if not B.clear(getCell():getGridSquare(x, y, record.z)) then return false end
    end
    local x, y = B.position(record, 1)
    if getCell():getGridSquare(record.x, record.y, record.z):isSomethingTo(getCell():getGridSquare(x, y, record.z)) then return false end
    params.testCollisions = false
    return true
end

---@param params table Native one-tile placement validation
---@return boolean valid
function B.onSingleValid(params)
    if not B.enabled() or not B.store or not B.clear(params.square) then return false end
    params.testCollisions = false
    return true
end

---@param params table Native construction completion
---@return nil
function B.onCreate(params)
    if not B.enabled() then error("[OMHTT] Bed construction unavailable") end
    local object = params.thumpable
    if B.record(object) then
        return
    end
    local index = tonumber(string.match(object:getSpriteName(), "^omhtt_barrier_01_(%d+)$"))
    if not index or index < 28 or index > 71 or index > 51 and index < 64 then error("[OMHTT] Invalid bed sprite") end
    local single = index >= 64
    if single then index = (index >= 68 and 44 or 36) + (index % 4) * 2 end
    local part, facing = (index - 28) % 2, facings[params.facing]
    local square = object:getSquare()
    local x, y = square:getX(), square:getY()
    local record = {id = "bed-" .. B.store.nextId, x = x, y = y, z = square:getZ(), facing = facing,
        tier = index >= 44 and "reinforced" or "basic", deployed = index >= 36, single = single}
    B.store.nextId = B.store.nextId + 1
    record.maxHealth = B.maxHealth(record)
    record.health = record.maxHealth
    B.store.records[record.id] = record
    object:getModData().OMHTTBed = {id = record.id, part = part}
    B.configure(record, object)
end

---@return nil
function B.tick()
    local active = B.enabled()
    if active ~= enabled then
        B.session = tostring(getTimestampMs()) .. ":" .. tostring(active)
        enabled = active
    end
    B.time = B.time + ActiveTime.step(clock)

end

OMHTT_BedMenuAvailable = B.enabled
if isClient() or isServer() then return B end
Events.OnInitGlobalModData.Add(B.initialize)
Events.LoadGridsquare.Add(B.loaded)
Events.OnObjectAboutToBeRemoved.Add(B.removed)
Events.OnTick.Add(B.tick)
return B
