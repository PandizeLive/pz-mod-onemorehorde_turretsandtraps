if isClient() then return end

local F = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local Sprites = require("OMHTT/BarrierSprites")
local Outline = require("OMHTT/BarrierOutline")
local Footprint = {}
local store, keys = nil, nil
local migrationWarnings = {}

---@param record table Barrier state
---@param square IsoGridSquare Part location
---@return string name Sprite identity
local function partSprite(record, square)
    if record.placementSource ~= "construction" then return F.spriteFor("barrier", record.facing) end
    return Sprites.name(record, square)
end

---@param registry table Persistent authority ledger
---@param schedule table Bounded tile schedule
---@return nil
function Footprint.initialize(registry, schedule)
    store, keys = registry, schedule
    migrationWarnings = {}
    Outline.initialize(registry, Footprint)
end

---@param square IsoGridSquare Selected tile
---@param id string? Exact barrier identity at a shared corner
---@return table? slot Canonical device slot, or this empty tile
---@nodiscard
function Footprint.slot(square, id)
    if not store then return nil end
    local base = F.key(square:getX(), square:getY(), square:getZ())
    local candidates = {base, base .. ":N", base .. ":W"}
    local empty = nil
    for i = 1, #candidates do
        local slot = store.tiles[candidates[i]]
        if slot and slot.anchor then
            slot = store.tiles[slot.anchor]
        end
        if slot and slot.device and (id == nil or slot.device.id == id) then return slot end
        if slot and not slot.device then
            empty = slot
        end
    end
    if id then
        local objects = square:getSpecialObjects()
        for i = 0, objects:size() - 1 do
            local object = objects:get(i)
            local edge = object:hasModData() and object:getModData().OMHTTEdge
            if edge and edge.id == id then
                local slot = store.tiles[edge.anchor]
                if slot and slot.device and slot.device.id == id then return slot end
            end
        end
    end
    return empty
end

---@param square IsoGridSquare Candidate tile
---@param facing number New edge orientation
---@return string? failure Placement rejection
---@nodiscard
function Footprint.canBuildPart(square, facing)
    if not square or not square:getFloor() then return "Blocked" end
    local reserved = store.tiles[Footprint.edgeKey(square:getX(), square:getY(), square:getZ(), facing)]
    if reserved and (reserved.device or reserved.anchor) then return "Occupied" end
    if square:HasStairs() or square:HasStairsBelow() or square:isVehicleIntersecting()
        or square:has(IsoFlagType.water) or square:getMovingObjects():size() > 0 then return "Blocked" end
    local north = facing == 4 or facing == 12
    local special = square:getSpecialObjects()
    for i = 0, special:size() - 1 do
        local object = special:get(i)
        local record = Footprint.exact(object)
        if not record or (record.collisionModel ~= "edge-v1" and record.collisionModel ~= "outline-v1") then return "Blocked" end
        if record.collisionModel == "edge-v1" and object:getNorth() == north then return "Occupied" end
    end
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        if not Footprint.exact(object) then
            local properties = object:getProperties()
            if properties and (properties:has(IsoFlagType.solid) or properties:has(IsoFlagType.solidtrans)
                or properties:has(IsoFlagType.collideN) or properties:has(IsoFlagType.collideW)
                or properties:has(IsoFlagType.WallN) or properties:has(IsoFlagType.WallW)) then return "Blocked" end
        end
    end
    if special:size() == 0 and not square:isFree(false) then return "Blocked" end
    local slot = Footprint.slot(square)
    if slot and slot.device then
        local record = slot.device
        if (record.collisionModel ~= "outline-v1" and record.collisionModel ~= "edge-v1")
            or (record.facing == 4 or record.facing == 12) == north then return "Occupied" end
    end
    return nil
end

---@param x number Tile X
---@param y number Tile Y
---@param z number Floor
---@param facing number Cardinal facing
---@return string key Edge ledger key
---@nodiscard
function Footprint.edgeKey(x, y, z, facing)
    local suffix = ":W"
    if facing == 4 or facing == 12 then
        suffix = ":N"
    end
    return F.key(x, y, z) .. suffix
end

---@param record table Barrier record
---@param facing number Desired facing
---@return number x Secondary tile X
---@return number y Secondary tile Y
---@nodiscard
function Footprint.second(record, facing)
    local nx, ny = F.barrierDirection(facing)
    return record.x - ny, record.y + nx
end

---@param x number Tile X
---@param y number Tile Y
---@param z number Tile Z
---@param edgeKey string? Separate edge reservation
---@return table slot Existing or newly reserved ledger slot
local function reserve(x, y, z, edgeKey)
    local key = edgeKey or F.key(x, y, z)
    local slot = store.tiles[key]
    if not slot then
        slot = {epoch = 0, x = x, y = y, z = z}
        store.tiles[key] = slot
        keys[#keys + 1] = key
        store.tileCount = store.tileCount + 1
    end
    return slot
end

---@param square IsoGridSquare? Candidate tile
---@return string? failure Placement rejection, or nil
---@nodiscard
local function available(square)
    if not square or not square:getFloor() then return "Unavailable" end
    if not F.isInteger(square:getX(), 0, 1000000) or not F.isInteger(square:getY(), 0, 1000000) then return "Unavailable" end
    local slot = Footprint.slot(square)
    if (slot and (slot.device or slot.anchor or slot.retired)) or F.countPrototypes(square) > 0 then return "Occupied" end
    if not square:isFree(false) then return "Blocked" end
    if square:getMovingObjects():size() > 0 then return "Blocked" end
    return nil
end

---@param square IsoGridSquare Loaded part tile
---@param record table Canonical record
---@return IsoThumpable object Created part
local function createPart(square, record)
    local north = record.collisionModel == "edge-v1" and (record.facing == 4 or record.facing == 12)
    local object = IsoThumpable.new(getCell(), square, partSprite(record, square), north)
    object:setName(F.PREFIX .. record.id)
    object:setBlockAllTheSquare(record.collisionModel ~= "edge-v1")
    object:setCanPassThrough(false)
    object:setIsHoppable(false)
    object:setIsThumpable(true)
    object:setMaxHealth(record.maxHealth or 100)
    object:setHealth(record.condition)
    object:setBreakSound("BreakObject")
    object:setIsDismantable(false)
    object:setOutlineOnMouseover(true)
    F.writeMarker(object, record)
    if record.placementSource == "construction" then
        Sprites.ensure(object, record, "create")
    end
    square:AddSpecialObject(object)
    square:RecalcAllWithNeighbours(true)
    square:setSquareChanged()
    object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_ADD)
    object:transmitCompleteItemToClients()
    Diagnostics.object(object, "placed-barrier-part")
    return object
end

---@param record table Barrier record
---@return table? parts All exact loaded parts, otherwise nil
---@nodiscard
function Footprint.parts(record)
    local parts = {}
    local width = 1
    if record.width == 2 then
        width = 2
    end
    for i = 1, width do
        local x, y = record.x, record.y
        if i == 2 then
            x, y = Footprint.second(record, record.facing)
        end
        local square = getCell():getGridSquare(x, y, record.z)
        if not square then return nil end
        local object, count = F.find(square, record.id)
        if count ~= 1 or not instanceof(object, "IsoThumpable") or object:getObjectIndex() < 0 then return nil end
        parts[i] = object
    end
    return parts
end

---@param object IsoObject Candidate thump target
---@return table? record Exact authoritative barrier
---@nodiscard
function Footprint.exact(object)
    if not store or not instanceof(object, "IsoThumpable") then return nil end
    if object:hasModData() and object:getModData().OMHTTEdge then return Outline.exact(object) end
    local square = object:getSquare()
    if not square or object:getObjectIndex() < 0 or object:getHealth() <= 0 then return nil end
    if not object:hasModData() then return nil end
    local marker = object:getModData().OMHTT
    if not marker then return nil end
    local slot = Footprint.slot(square, marker.id)
    if not slot or not slot.device or slot.device.kind ~= "barrier" then return nil end
    local record = slot.device
    local exact, count = F.find(square, record.id)
    if count ~= 1 or exact ~= object then return nil end
    return record
end

---@param square IsoGridSquare Primary tile
---@param player IsoPlayer Requester
---@return string status
---@return table? slot Canonical slot
function Footprint.place(square, player)
    local record = {id = "test-" .. tostring(store.nextId), kind = "barrier", condition = F.barrierHealth(), maxHealth = F.barrierHealth(), revision = 1,
        testOwner = player:getUsername(), ammo = 0, shots = 0, nextShot = 0, facing = 0, observedLoss = 0,
        cooldownClock = "realtime-ms-v1", width = 2, x = square:getX(), y = square:getY(), z = square:getZ()}
    local x, y = Footprint.second(record, record.facing)
    local second = getCell():getGridSquare(x, y, record.z)
    local failure = available(square) or available(second)
    if failure then return failure, Footprint.slot(square) end
    local needed = 0
    if not store.tiles[F.key(record.x, record.y, record.z)] then
        needed = needed + 1
    end
    if not store.tiles[F.key(x, y, record.z)] then
        needed = needed + 1
    end
    if store.tileCount + needed > F.MAX_TILES then return "Limit", Footprint.slot(square) end
    local slot, other = reserve(record.x, record.y, record.z), reserve(x, y, record.z)
    slot.device = record
    slot.epoch = math.max(slot.epoch, other.epoch) + 1
    other.anchor = F.key(record.x, record.y, record.z)
    other.epoch = slot.epoch
    store.nextId = store.nextId + 1
    createPart(square, record)
    createPart(second, record)
    Diagnostics.emit("barrier-footprint", {id = record.id, action = "place", x = record.x, y = record.y,
        secondX = x, secondY = y, facing = record.facing, width = 2})
    return "Placed", slot
end

---@param x number Primary tile X
---@param y number Primary tile Y
---@param z number Level
---@param facing number Cardinal facing
---@return string? failure Placement rejection before native material consumption
---@nodiscard
function Footprint.canBuild(x, y, z, facing)
    if not store then return "Unavailable" end
    local secondX, secondY = Footprint.second({x = x, y = y}, facing)
    local first = getCell():getGridSquare(x, y, z)
    local second = getCell():getGridSquare(secondX, secondY, z)
    local failure = Footprint.canBuildPart(first, facing) or Footprint.canBuildPart(second, facing)
    if failure then return failure end
    failure = Outline.canBuild({id = "candidate", x = x, y = y, z = z, facing = facing})
    if failure then return failure end
    return nil
end

---@param object IsoThumpable Part created by the native construction recipe
---@param player IsoPlayer Builder
---@param x number Primary tile X
---@param y number Primary tile Y
---@param facing number Cardinal heading
---@param entity string Native construction recipe identity
---@return table record Persistent shared state
function Footprint.adoptBuild(object, player, x, y, facing, entity)
    local square = object:getSquare()
    local z = square:getZ()
    local anchor = Footprint.edgeKey(x, y, z, facing)
    local secondX, secondY = Footprint.second({x = x, y = y}, facing)
    local slot = store.tiles[anchor]
    if not slot or not slot.device then
        slot = reserve(x, y, z, anchor)
        local other = reserve(secondX, secondY, z, Footprint.edgeKey(secondX, secondY, z, facing))
        slot.device = {id = "test-" .. tostring(store.nextId), kind = "barrier", condition = F.barrierHealth(), maxHealth = F.barrierHealth(), revision = 1,
            testOwner = player:getUsername(), builderUsername = player:getUsername(), placementSource = "construction",
            constructionEntity = entity, collisionModel = "outline-v1", slotKey = anchor,
            ammo = 0, shots = 0, nextShot = 0, facing = facing, observedLoss = 0,
            cooldownClock = "realtime-ms-v1", width = 2, x = x, y = y, z = z}
        slot.epoch = math.max(slot.epoch, other.epoch) + 1
        other.anchor, other.epoch = anchor, slot.epoch
        store.nextId = store.nextId + 1
    end
    local record = slot.device
    if entity == "OMHTTDeployReinforcedBarrier" and not record.tier then
        record.tier = "reinforced"
        record.maxHealth = F.barrierHealth(record)
        record.condition = record.maxHealth
    end
    if record.kind ~= "barrier" or record.placementSource ~= "construction" or record.facing ~= facing
        or record.builderUsername ~= player:getUsername() or Sprites.entity(record) ~= entity then
        error("[OMHTT] Native construction callback conflicts with existing device at " .. anchor)
    end
    local existing, count = F.find(square, record.id)
    if count > 0 then
        if count == 1 and existing == object then return record end
        error("[OMHTT] Native construction callback duplicates device " .. record.id)
    end
    object:setName(F.PREFIX .. record.id)
    object:setSpriteFromName(partSprite(record, square))
    object:setBlockAllTheSquare(false)
    object:setCanPassThrough(true)
    object:setIsHoppable(false)
    object:setIsThumpable(false)
    object:setMaxHealth(record.maxHealth or 100)
    object:setHealth(record.condition)
    object:setBreakSound("BreakObject")
    object:setIsDismantable(false)
    object:setOutlineOnMouseover(true)
    F.writeMarker(object, record)
    square:RecalcAllWithNeighbours(true)
    square:setSquareChanged()
    object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_ADD)
    Outline.changed()
    if Footprint.parts(record) then
        Outline.refresh(record)
    end
    local spriteConfig = object:getSpriteConfig()
    Diagnostics.emit("construction-part", {id = record.id, x = square:getX(), y = square:getY(), z = z,
        anchorX = x, anchorY = y, facing = facing, complete = Footprint.parts(record) ~= nil,
        builder = player:getUsername(), buildCheat = player:isBuildCheat(), condition = record.condition, recipe = entity,
        sprite = object:getSpriteName(), nativeConfigValid = spriteConfig and spriteConfig:isValid(),
        collisionModel = record.collisionModel, north = object:getNorth()})
    return record
end

---@param slot table Canonical slot
---@param excluding IsoObject? Native removal already in progress
---@return nil
function Footprint.retire(slot, excluding)
    local record = slot.device
    if not record then return end
    if record.collisionModel == "outline-v1" then
        slot.outlineRetired = record
        Outline.changed()
    end
    local width = 1
    if record.width == 2 then
        width = 2
    end
    local pending = {}
    local retiredEpoch = slot.epoch + 1
    for i = 1, width do
        local x, y = record.x, record.y
        if i == 2 then
            x, y = Footprint.second(record, record.facing)
        end
        local key = F.key(x, y, record.z)
        if record.slotKey then
            key = Footprint.edgeKey(x, y, record.z, record.facing)
        end
        local partSlot = store.tiles[key]
        partSlot.device, partSlot.anchor = nil, nil
        partSlot.epoch = math.max(partSlot.epoch + 1, retiredEpoch)
        partSlot.retired = record.id
        pending[#pending + 1] = partSlot
    end
    -- Native multi-tile removal can include the sibling. Never nest world removal in its callback.
    if excluding then
        Diagnostics.emit("barrier-footprint", {id = record.id, action = "retire-deferred", width = width})
        return
    end
    if record.collisionModel == "outline-v1" then
        Outline.refresh(record)
        slot.outlineRetired = nil
    end
    for i = 1, #pending do
        local partSlot = pending[i]
        local square = getCell():getGridSquare(partSlot.x, partSlot.y, partSlot.z)
        if square then
            local object, count = F.find(square, record.id)
            if count == 1 then
                if object ~= excluding then
                    square:transmitRemoveItemFromSquare(object)
                    square:RecalcAllWithNeighbours(true)
                end
                partSlot.retired = nil
            elseif count == 0 then
                partSlot.retired = nil
            end
        end
    end
    Diagnostics.emit("barrier-footprint", {id = record.id, action = "retire", width = width})
end

---@param square IsoGridSquare Newly loaded tile
---@return boolean handled Retired part cleanup handled
function Footprint.cleanRetired(square)
    local base = F.key(square:getX(), square:getY(), square:getZ())
    local candidates = {base, base .. ":N", base .. ":W"}
    for i = 1, #candidates do
        local slot = store.tiles[candidates[i]]
        if slot and slot.outlineRetired then
            Outline.refresh(slot.outlineRetired)
            slot.outlineRetired = nil
        end
        if slot and slot.retired then
            local object, count = F.find(square, slot.retired)
            if count == 1 then
                square:transmitRemoveItemFromSquare(object)
                square:RecalcAllWithNeighbours(true)
                Diagnostics.emit("barrier-retired-part", {id = slot.retired, x = slot.x, y = slot.y})
                slot.retired = nil
            elseif count == 0 then
                slot.retired = nil
            end
        end
    end
    return false
end

---@param record table Legacy barrier
---@param slot table Canonical slot
---@return nil
local function expandLegacy(record, slot)
    if record.width == 2 then return end
    local x, y = Footprint.second(record, record.facing)
    local square = getCell():getGridSquare(x, y, record.z)
    local failure = available(square)
    if failure then
        if migrationWarnings[record.id] ~= failure then
            Diagnostics.emit("barrier-expansion-deferred", {id = record.id, reason = failure, x = x, y = y})
            migrationWarnings[record.id] = failure
        end
        return
    end
    local other = reserve(x, y, record.z)
    other.anchor = F.key(record.x, record.y, record.z)
    record.width = 2
    record.revision = record.revision + 1
    slot.epoch = math.max(slot.epoch, other.epoch) + 1
    other.epoch = slot.epoch
    createPart(square, record)
    Diagnostics.emit("barrier-footprint", {id = record.id, action = "expand", width = 2, secondX = x, secondY = y})
end

---@param slot table Canonical barrier slot
---@param reason string? Reconciliation origin
---@return boolean complete All parts loaded and unambiguous
function Footprint.sync(slot, reason)
    local record = slot.device
    local parts = Footprint.parts(record)
    if not parts then return false end
    if record.collisionModel == "edge-v1" then
        record.collisionModel = "outline-v1"
        record.revision = record.revision + 1
        Outline.changed()
        Diagnostics.emit("barrier-outline-migrate", {id = record.id, facing = record.facing})
    end
    local colliders = record.collisionModel == "outline-v1" and Outline.objects(record) or {}
    local healthObjects = {}
    for i = 1, #parts do healthObjects[#healthObjects + 1] = parts[i] end
    for i = 1, #colliders do healthObjects[#healthObjects + 1] = colliders[i] end
    local loss = 0
    for i = 1, #healthObjects do
        loss = loss + math.max(0, record.condition - healthObjects[i]:getHealth())
    end
    if loss > 0 then
        record.condition = math.max(0, record.condition - loss)
        record.observedLoss = record.observedLoss + loss
        record.revision = record.revision + 1
        slot.epoch = slot.epoch + 1
        Diagnostics.emit("barrier-health", {id = record.id, hp = record.condition, loss = loss, parts = #parts})
    end
    if record.condition <= 0 then
        Footprint.retire(slot, nil)
        return false
    end
    local oldMaximum = record.maxHealth or 100
    local maximum = F.barrierHealth(record)
    if oldMaximum ~= maximum or record.maxHealth == nil then
        record.condition = math.max(1, math.floor(record.condition * maximum / oldMaximum + 0.5))
        record.condition = math.min(maximum, record.condition)
        record.maxHealth = maximum
        record.revision = record.revision + 1
        slot.epoch = slot.epoch + 1
        Diagnostics.emit("barrier-settings", {id = record.id, previousMax = oldMaximum,
            max = maximum, hp = record.condition, damage = F.barrierDamage(record)})
    end
    local width = record.width
    expandLegacy(record, slot)
    if width ~= record.width then
        parts = Footprint.parts(record)
    end
    for i = 1, #parts do
        local object = parts[i]
        if record.collisionModel == "outline-v1" then
            local changed = object:isBlockAllTheSquare() or not object:isCanPassThrough() or object:isThumpable()
            if changed then
                object:setBlockAllTheSquare(false)
                object:setCanPassThrough(true)
                object:setIsThumpable(false)
                object:getSquare():RecalcAllWithNeighbours(true)
            end
        end
        local marker = object:getModData().OMHTT
        local desired = partSprite(record, object:getSquare())
        local visualChanged = false
        if record.placementSource == "construction" then
            visualChanged = Sprites.ensure(object, record, reason)
        elseif object:getSpriteName() ~= desired then
            object:setSprite(desired)
            visualChanged = true
        end
        if visualChanged then
            object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_MODIFY)
            object:transmitUpdatedSpriteToClients()
        end
        if object:getMaxHealth() ~= record.maxHealth then
            object:setMaxHealth(record.maxHealth)
        end
        if object:getHealth() ~= record.condition then
            object:setHealth(record.condition)
        end
        if marker.revision ~= record.revision or marker.condition ~= record.condition or marker.width ~= record.width
            or marker.facing ~= record.facing then
            F.writeMarker(object, record)
            object:transmitModData()
        end
    end
    if record.collisionModel == "outline-v1" then
        for i = 1, #colliders do
            if colliders[i]:getMaxHealth() ~= record.maxHealth then colliders[i]:setMaxHealth(record.maxHealth) end
            if colliders[i]:getHealth() ~= record.condition then colliders[i]:setHealth(record.condition) end
        end
        local now = getTimestampMs()
        if reason or slot.outlineGeneration ~= Outline.generation or not slot.outlineCheck or now >= slot.outlineCheck then
            Outline.refresh(record)
            slot.outlineGeneration, slot.outlineCheck = Outline.generation, now + 1000
        end
    end
    return true
end

---@param slot table Canonical slot
---@return string status
function Footprint.rotate(slot)
    if not Footprint.sync(slot) then return "Unavailable" end
    local record = slot.device
    if record.collisionModel == "edge-v1" or record.collisionModel == "outline-v1" then return "BarrierRedeploy" end
    local facing = (record.facing + 4) % 16
    local x, y = Footprint.second(record, facing)
    local square = getCell():getGridSquare(x, y, record.z)
    local failure = available(square)
    if failure then return failure end
    local oldX, oldY = Footprint.second(record, record.facing)
    if record.width == 2 then
        local oldSquare = getCell():getGridSquare(oldX, oldY, record.z)
        local oldPart = F.find(oldSquare, record.id)
        local oldSlot = store.tiles[F.key(oldX, oldY, record.z)]
        oldSlot.anchor = nil
        oldSlot.epoch = math.max(oldSlot.epoch, slot.epoch) + 1
        oldSquare:transmitRemoveItemFromSquare(oldPart)
        oldSquare:RecalcAllWithNeighbours(true)
    end
    record.facing, record.width = facing, 2
    record.revision = record.revision + 1
    local other = reserve(x, y, record.z)
    slot.epoch = math.max(slot.epoch, other.epoch) + 1
    other.anchor = F.key(record.x, record.y, record.z)
    other.epoch = slot.epoch
    createPart(square, record)
    Footprint.sync(slot)
    Diagnostics.emit("barrier-footprint", {id = record.id, action = "rotate", facing = facing, secondX = x, secondY = y})
    return "BarrierRotated"
end

---@param record table Owner
---@return table objects All health-bearing pieces
---@nodiscard
function Footprint.healthObjects(record)
    local objects = Footprint.parts(record) or {}
    if record.collisionModel == "outline-v1" then
        local colliders = Outline.objects(record)
        for i = 1, #colliders do
            objects[#objects + 1] = colliders[i]
        end
    end
    return objects
end

---@param record table Owner
---@return table? objects Vaultable native edges
---@nodiscard
function Footprint.colliders(record)
    if record.collisionModel == "outline-v1" then return Outline.objects(record) end
    return Footprint.parts(record)
end

return Footprint
