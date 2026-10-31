local F = require("OMHTT/Foundation")
local B = {tiles = {}, nearby = {}, indexed = {}, count = 0, time = 0, session = tostring(getTimestampMs())}
OMHTT_BedSpikes = B
local ActiveTime = require("OMHTT/ActiveTime")
local clock = ActiveTime.new(true)
local removing = false
local enabled = nil
local facings = {e = 0, n = 1, w = 2, s = 3}
local bindings = setmetatable({}, {__mode = "k"})
local persistedTiles = {}

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
    return options ~= nil and options.Enabled ~= false and options.BedSpikes ~= false
end

---@return nil
function B.initialize()
    if isServer() then
        require("OMHTT/DefenseContacts").clear("bed")
    end
    if isClient() then
        B.store = {nextId = 1, records = {}}
    else
        B.store = ModData.getOrCreate("OMHTTBedSpikes")
    end
    if B.store.nextId == nil then
        B.store.nextId, B.store.records = 1, {}
    end
    B.tiles, B.nearby, B.indexed = {}, {}, {}
    B.count = 0
    bindings, persistedTiles = setmetatable({}, {__mode = "k"}), {}
    for id, record in pairs(B.store.records) do
        persistedTiles[F.key(record.x, record.y, record.z)] = id
    end
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
    if not B.store or not object then return nil end
    if isServer() then
        local record = bindings[object]
        local square = object:getSquare()
        if record and B.store.records[record.id] == record and square
            and square:getX() == record.x and square:getY() == record.y and square:getZ() == record.z then return record end
        return nil
    end
    if not object:hasModData() then return nil end
    local marker = object:getModData().OMHTTBed
    if isClient() then
        local view = marker and marker.view
        if not view then return nil end
        local record = B.store.records[view.id]
        if not record then
            record = {}
            B.store.records[view.id] = record
        end
        for key, value in pairs(view) do
            record[key] = value
        end
        return record
    end
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
    if isServer() then
        local contacts = require("OMHTT/DefenseContacts")
        if delta > 0 then
            contacts.watch("bed:" .. record.id, "bed", record.x - 2, record.y - 2, record.x + 2, record.y + 2, record.z)
        else
            contacts.remove("bed:" .. record.id)
        end
    end
end

---@param record table Bed record
---@param object IsoThumpable Loaded part
---@return nil
function B.configure(record, object)
    if not isClient() and (not record.displayName or record.displayTier ~= record.tier) then
        require("OMHTT/DefenseNames").ensure(record, "Bed", getText(record.tier == "reinforced" and "UI_OMHTT_ReinforcedBedSpikes" or "UI_OMHTT_BedSpikes"))
        record.displayTier = record.tier
    end
    if isClient() then return end
    if isServer() then
        bindings[object] = record
        persistedTiles[F.key(record.x, record.y, record.z)] = record.id
        local view = {}
        for key, value in pairs(record) do
            view[key] = value
        end
        object:getModData().OMHTTBed = {id = record.id, part = record.part or 0, view = view}
    end
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
    if isClient() then return end
    local parts = B.parts(record)
    if B.indexed[record.id] then
        B.index(record, -1)
    end
    B.store.records[record.id] = nil
    persistedTiles[F.key(record.x, record.y, record.z)] = nil
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
    persistedTiles[F.key(record.x, record.y, record.z)] = nil
    bindings[object] = nil
end

---@param square IsoGridSquare Loaded square
---@return nil
function B.loaded(square)
    if not B.store then
        return
    end
    local objects = square:getSpecialObjects()
    if isServer() then
        local id = persistedTiles[F.key(square:getX(), square:getY(), square:getZ())]
        local record = id and B.store.records[id]
        if not record then return end
        for i = 0, objects:size() - 1 do
            local object = objects:get(i)
            local sprite = object:getSpriteName()
            local index = sprite and tonumber(string.match(sprite, "^omhtt_barrier_01_(%d+)$"))
            if instanceof(object, "IsoThumpable") and index and (index >= 28 and index <= 51 or index >= 64 and index <= 71) then
                B.configure(record, object)
                return
            end
        end
        return
    end
    for i = objects:size() - 1, 0, -1 do
        local object = objects:get(i)
        local marker = object:hasModData() and object:getModData().OMHTTBed
        if marker then
            local record = isClient() and B.record(object) or B.store.records[marker.id]
            if record then
                if isClient() then
                    B.store.records[record.id] = record
                    if not B.indexed[record.id] then
                        B.index(record, 1)
                    end
                else
                    B.configure(record, object)
                end
            elseif not isClient() then
                square:transmitRemoveItemFromSquare(object)
            end
        end
    end
end

---@param square IsoGridSquare? Candidate floor
---@return boolean clear
---@nodiscard
function B.clear(square)
    if require("OMHTT/ControlPokeFootprint").reserved(square) then return false end
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
    if isClient() then return end
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
    if isServer() and persistedTiles[F.key(x, y, square:getZ())] then
        error("[OMHTT] Duplicate bed placement")
    end
    local record = {id = "bed-" .. B.store.nextId, owner = params.character and params.character:getUsername(), x = x, y = y, z = square:getZ(), facing = facing,
        tier = index >= 44 and "reinforced" or "basic", deployed = index >= 36, single = single, part = part}
    B.store.nextId = B.store.nextId + 1
    local portableType = record.tier == "reinforced" and "Base.OMHTTTrapBedSpikesReinforced" or "Base.OMHTTTrapBedSpikes"
    require("OMHTT/DefenseNames").restore(record, params.craftRecipeData and params.craftRecipeData:getAllConsumedItems(),
        single and 1 or part + 1, portableType)
    record.maxHealth = B.maxHealth(record)
    record.health = require("OMHTT/DefenseNames").health(record, record.maxHealth)
    B.store.records[record.id] = record
    require("OMHTT/DefenseXP").register(record.id, record.owner, record.x, record.y, record.z)
    object:getModData().OMHTTBed = {id = record.id, part = part}
    B.configure(record, object)
end

---@return nil
function B.tick()
    local active = B.enabled()
    if active ~= enabled then
        if enabled ~= nil then B.session = tostring(getTimestampMs()) .. ":" .. tostring(active) end
        enabled = active
    end
    B.time = B.time + ActiveTime.step(clock)

end

OMHTT_BedMenuAvailable = B.enabled
Events.OnInitGlobalModData.Add(B.initialize)
Events.LoadGridsquare.Add(B.loaded)
Events.OnObjectAdded.Add(function(object)
    if isClient() and object:getSquare() then B.loaded(object:getSquare()) end
end)
Events.OnObjectAboutToBeRemoved.Add(B.removed)
Events.OnTick.Add(B.tick)
return B
