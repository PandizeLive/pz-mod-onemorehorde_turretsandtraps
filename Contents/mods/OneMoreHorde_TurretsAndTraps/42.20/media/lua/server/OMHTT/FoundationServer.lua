if isClient() then return end

local Foundation = require("OMHTT/Foundation")
local Combat = require("OMHTT/PrototypeCombat")
local Footprint = require("OMHTT/BarrierFootprint")
local Diagnostics = require("OMHTT/Diagnostics")

---@class OMHTTFoundationServer
local Server = {}
local store = nil
local keys = {}
local cursor = 1
local stats = {ticks = 0, visits = 0, peak = 0}

---@return nil
function Server.initialize()
    store = ModData.getOrCreate(Foundation.STORE)
    if store.schema == nil then
        store.schema = 1
        store.nextId = 1
        store.tileCount = 0
        store.tiles = {}
    end
    if store.schema ~= 1 or type(store.tiles) ~= "table" then
        error("[OMHTT] Unsupported foundation save schema; refusing mutations")
    end
    keys = {}
    cursor = 1
    stats = {ticks = 0, visits = 0, peak = 0}
    Footprint.initialize(store, keys)
    for key, slot in pairs(store.tiles) do
        keys[#keys + 1] = key
        local x, y, z = string.match(key, "^([^:]+):([^:]+):([^:]+)$")
        slot.x, slot.y, slot.z = tonumber(x), tonumber(y), tonumber(z)
        if slot.device and slot.device.kind == nil then
            local record = slot.device
            record.kind = "foundation"
            record.ammo = 0
            record.shots = 0
            record.nextShot = 0
            record.facing = 0
            record.observedLoss = 0
        end
        if slot.device then
            local record = slot.device
            record.facing = Foundation.normalizeFacing(record.facing)
            if record.kind == "barrier" then
                record.x, record.y, record.z = slot.x, slot.y, slot.z
            end
            if record.cooldownClock ~= "realtime-ms-v1" then
                record.nextShot = 0
                record.cooldownClock = "realtime-ms-v1"
                Diagnostics.emit("combat-migration", {id = record.id, facing = record.facing,
                    cooldownClock = record.cooldownClock})
            end
        end
    end
    print("[OMHTT] server-ready version=" .. Foundation.VERSION .. " game=" .. getCore():getVersionNumber())
    Diagnostics.emit("authority-ready", {game = getCore():getVersionNumber(), schema = store.schema,
        slots = #keys, nextId = store.nextId, controls = SandboxVars.OMHTurretsTraps.FoundationTestControls})
end

---@param object IsoObject Exact prototype object
---@param record table Authoritative marker state
---@return boolean changed
local function refreshVisual(object, record)
    local desired = Foundation.spriteFor(record.kind, record.facing)
    if object:getSpriteName() == desired then return false end
    object:setSprite(desired)
    object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_MODIFY)
    object:transmitUpdatedSpriteToClients()
    Diagnostics.emit("visual-refresh", {id = record.id, kind = record.kind, facing = record.facing, sprite = desired})
    return true
end

---@param player IsoPlayer Requesting player
---@param command string Command name
---@param args table Request arguments
---@param status string Translation suffix
---@param square IsoGridSquare? Requested loaded tile
---@param slot table? Persistent tile slot
---@return nil
local function reply(player, command, args, status, square, slot)
    local result = {
        version = Foundation.VERSION,
        game = getCore():getVersionNumber(),
        command = command,
        request = args.request,
        status = status,
        playerNum = player:getPlayerNum(),
        x = args.x, y = args.y, z = args.z,
        epoch = 0,
        id = "", condition = -1, revision = 0, count = 0,
        kind = "none", ammo = 0, shots = 0, nextShot = 0, facing = 0,
        peakVisits = stats.peak,
        stateIncluded = square ~= nil,
    }
    if slot then
        result.epoch = slot.epoch
        if slot.device then
            local record = slot.device
            result.id = record.id
            result.condition = record.condition
            result.revision = record.revision
            result.kind = record.kind
            result.ammo = record.ammo
            result.shots = record.shots
            result.nextShot = record.nextShot
            result.facing = record.facing
            if square then
                local object, count = Foundation.find(square, record.id)
                result.count = count
            end
        end
    end
    print("[OMHTT] command=" .. command .. " status=" .. status .. " id=" .. result.id
        .. " condition=" .. result.condition .. " revision=" .. result.revision
        .. " count=" .. result.count .. " tile=" .. Foundation.key(args.x, args.y, args.z))
    Diagnostics.emit("authority-result", {request = args.request, command = command, status = status,
        tile = Foundation.key(args.x, args.y, args.z), playerX = player:getX(), playerY = player:getY(),
        playerZ = player:getZ(), dx = player:getX() - args.x - 0.5, dy = player:getY() - args.y - 0.5,
        requestedId = tostring(args.id), expectedEpoch = tostring(args.epoch), actualEpoch = result.epoch,
        id = result.id, revision = result.revision, ammo = result.ammo, shots = result.shots,
        nextShot = result.nextShot, facing = result.facing, stateIncluded = result.stateIncluded})
    if isClient() then
        error("[OMHTT] Server reply attempted on client")
    elseif isServer() then
        sendServerCommand(player, Foundation.MODULE, "Result", result)
    else
        triggerEvent("OnServerCommand", Foundation.MODULE, "Result", result)
    end
end

---@param square IsoGridSquare Loaded tile
---@param reason string? Reconciliation origin; omitted by the engine load event
---@return nil
function Server.reconcile(square, reason)
    if not store then return end
    if reason == nil then
        reason = "load"
    end
    if Footprint.cleanRetired(square) then return end
    local slot = Footprint.slot(square)
    if not slot or not slot.device then return end
    local record = slot.device
    if record.kind == "barrier" then
        Footprint.sync(slot, reason)
        return
    end
    local object, count = Foundation.find(square, record.id)
    if count ~= 1 then
        print("[OMHTT] reconcile-conflict id=" .. record.id .. " matches=" .. count .. "; preserved without respawn")
        return
    end
    local marker = object:getModData().OMHTT
    refreshVisual(object, record)
    if marker.condition ~= record.condition or marker.revision ~= record.revision or marker.testOwner ~= record.testOwner
        or marker.kind ~= record.kind or marker.ammo ~= record.ammo or marker.shots ~= record.shots
        or marker.nextShot ~= record.nextShot or marker.facing ~= record.facing then
        Foundation.writeMarker(object, record)
        object:transmitModData()
    end
    print("[OMHTT] reconciled origin=" .. reason .. " id=" .. record.id .. " condition=" .. record.condition .. " revision=" .. record.revision)
    Diagnostics.object(object, "reconcile-" .. reason)
end

---@return nil
function Server.tick()
    if not store or #keys == 0 then return end
    local visited = 0
    for i = 1, math.min(4, #keys) do
        if cursor > #keys then cursor = 1 end
        local slot = store.tiles[keys[cursor]]
        cursor = cursor + 1
        visited = visited + 1
        if slot.device and slot.device.kind == "barrier" then
            Footprint.sync(slot)
        end
    end
    stats.ticks = stats.ticks + 1
    stats.visits = stats.visits + visited
    stats.peak = math.max(stats.peak, visited)
    if stats.ticks % 600 == 0 then
        Diagnostics.emit("scheduler", {ticks = stats.ticks, visits = stats.visits, peak = stats.peak, slots = #keys})
    end
end

---@param object IsoObject Object being removed by the engine
---@return nil
function Server.onRemoved(object)
    if not store then return end
    local square = object:getSquare()
    if not square then return end
    local slot = Footprint.slot(square)
    if not slot or not slot.device or not Foundation.matches(object, slot.device.id) then return end
    if slot.device.kind == "barrier" then
        Footprint.retire(slot, object)
        return
    end
    print("[OMHTT] retired id=" .. slot.device.id)
    Diagnostics.object(object, "native-remove")
    slot.device = nil
    slot.epoch = slot.epoch + 1
end

---@param module string Command namespace
---@param command string Requested action
---@param player IsoPlayer Engine-bound sender
---@param args table? Serializable request
---@return nil
function Server.onCommand(module, command, player, args)
    if module ~= Foundation.MODULE then return end
    if command ~= "Inspect" and command ~= "Place" and command ~= "Condition" and command ~= "Remove"
        and command ~= "PlaceBarrier" and command ~= "PlacePotato" and command ~= "Fire"
        and command ~= "Refill" and command ~= "Aim" and command ~= "RotateBarrier" then return end
    if not store or not player or type(args) ~= "table" then return end
    Diagnostics.emit("authority-request", {command = command, request = tostring(args.request),
        x = tostring(args.x), y = tostring(args.y), z = tostring(args.z), version = tostring(args.version),
        id = tostring(args.id), revision = tostring(args.revision), epoch = tostring(args.epoch),
        playerX = player:getX(), playerY = player:getY(), playerZ = player:getZ()})
    if not Foundation.isInteger(args.x, 0, 1000000) or not Foundation.isInteger(args.y, 0, 1000000)
        or not Foundation.isInteger(args.z, -32, 31) or not Foundation.isInteger(args.request, 1, 1000000000) then return end
    if not Foundation.canUse(player) then
        reply(player, command, args, "Denied")
        return
    end
    if args.version ~= Foundation.VERSION then
        reply(player, command, args, "VersionMismatch")
        return
    end
    if math.floor(player:getZ()) ~= args.z or math.abs(player:getX() - args.x - 0.5) > 2
        or math.abs(player:getY() - args.y - 0.5) > 2 then
        reply(player, command, args, "TooFar")
        return
    end
    local square = getCell():getGridSquare(args.x, args.y, args.z)
    if not square or not square:getFloor() then
        reply(player, command, args, "Unavailable")
        return
    end
    local key = Foundation.key(args.x, args.y, args.z)
    local slot = Footprint.slot(square)
    if command == "Inspect" then
        Server.reconcile(square, "inspect")
        reply(player, command, args, "Inspected", square, slot)
        return
    end
    local epoch = 0
    if slot then
        epoch = slot.epoch
    end
    if args.epoch ~= epoch then
        reply(player, command, args, "Stale", square, slot)
        return
    end
    if command == "PlaceBarrier" then
        local status, placedSlot = Footprint.place(square, player)
        reply(player, command, args, status, square, placedSlot)
        return
    end
    if command == "Place" or command == "PlacePotato" then
        if (slot and (slot.device or slot.anchor or slot.retired)) or Foundation.countPrototypes(square) > 0 then
            reply(player, command, args, "Occupied", square, slot)
            return
        end
        if not square:isFree(false) then
            reply(player, command, args, "Blocked", square, slot)
            return
        end
        if not slot then
            if store.tileCount >= Foundation.MAX_TILES then
                reply(player, command, args, "Limit", square)
                return
            end
            slot = {epoch = 0, x = args.x, y = args.y, z = args.z}
            store.tiles[key] = slot
            keys[#keys + 1] = key
            store.tileCount = store.tileCount + 1
        end
        local record = {
            id = "test-" .. tostring(store.nextId),
            condition = 100,
            revision = 1,
            testOwner = player:getUsername(),
            kind = "foundation", ammo = 0, shots = 0, nextShot = 0, facing = 0, observedLoss = 0,
        }
        store.nextId = store.nextId + 1
        Diagnostics.emit("placement-stage", {request = args.request, stage = "construct", kind = command, id = record.id})
        local object = nil
        if command == "PlacePotato" then
            record.kind = "potato"
            record.ammo = 4
        end
        object = IsoObject.new(square, Foundation.spriteFor(record.kind, record.facing), Foundation.PREFIX .. record.id)
        object:setOutlineOnMouseover(true)
        Diagnostics.emit("placement-stage", {request = args.request, stage = "attach", id = record.id, kind = record.kind})
        Foundation.writeMarker(object, record)
        square:AddTileObject(object)
        slot.device = record
        slot.epoch = slot.epoch + 1
        refreshVisual(object, record)
        square:setSquareChanged()
        object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_ADD)
        object:transmitCompleteItemToClients()
        Diagnostics.object(object, "placed")
        reply(player, command, args, "Placed", square, slot)
        return
    end
    local record = slot and slot.device
    if not record or args.id ~= record.id or args.revision ~= record.revision then
        reply(player, command, args, "Stale", square, slot)
        return
    end
    local object, count = Foundation.find(square, record.id)
    if count ~= 1 then
        reply(player, command, args, "Conflict", square, slot)
        return
    end
    if record.kind == "barrier" then
        local status = "WrongDevice"
        if command == "RotateBarrier" then
            status = Footprint.rotate(slot)
        elseif command == "Remove" then
            if not Footprint.parts(record) then
                status = "Unavailable"
            else
                Footprint.retire(slot, nil)
                status = "Removed"
            end
        elseif command == "Condition" then
            if args.condition ~= 37 then return end
            if isServer() then
                status = "MPCombatDeferred"
            elseif not Footprint.sync(slot) then
                status = "Unavailable"
            else
                record.condition = 37
                record.revision = record.revision + 1
                slot.epoch = slot.epoch + 1
                local parts = Footprint.parts(record)
                for i = 1, #parts do
                    parts[i]:setHealth(37)
                    Foundation.writeMarker(parts[i], record)
                    parts[i]:transmitModData()
                end
                status = "Changed"
            end
        end
        reply(player, command, args, status, square, Footprint.slot(square))
        return
    end
    if command == "Condition" then
        if args.condition ~= 37 then return end
        record.condition = 37
        record.revision = record.revision + 1
        slot.epoch = slot.epoch + 1
        Foundation.writeMarker(object, record)
        object:transmitModData()
        reply(player, command, args, "Changed", square, slot)
    elseif command == "RotateBarrier" then
        reply(player, command, args, "WrongBarrier", square, slot)
    elseif command == "Fire" or command == "Refill" or command == "Aim" then
        if record.kind ~= "potato" then
            reply(player, command, args, "WrongDevice", square, slot)
            return
        end
        local status = "Refilled"
        local impact = nil
        if command == "Fire" then
            status, impact = Combat.fire(record, object, player)
            if status ~= "Fired" then
                reply(player, command, args, status, square, slot)
                return
            end
        elseif command == "Refill" then
            record.ammo = 4
        else
            status = "Aimed"
            record.facing = (record.facing + 1) % 16
            refreshVisual(object, record)
        end
        record.revision = record.revision + 1
        slot.epoch = slot.epoch + 1
        Foundation.writeMarker(object, record)
        object:transmitModData()
        object:transmitUpdatedSpriteToClients()
        if impact then
            triggerEvent("OnServerCommand", Foundation.MODULE, "Impact", impact)
        end
        reply(player, command, args, status, square, slot)
    elseif command == "Remove" then
        Diagnostics.object(object, "remove-request")
        square:transmitRemoveItemFromSquare(object)
        if object:getObjectIndex() ~= -1 then
            reply(player, command, args, "Conflict", square, slot)
            return
        end
        if slot.device then
            slot.device = nil
            slot.epoch = slot.epoch + 1
        end
        reply(player, command, args, "Removed", square, slot)
    end
end

Events.OnInitGlobalModData.Add(Server.initialize)
Events.LoadGridsquare.Add(Server.reconcile)
Events.OnObjectAboutToBeRemoved.Add(Server.onRemoved)
Events.OnClientCommand.Add(Server.onCommand)
Events.OnTick.Add(Server.tick)

return Server
