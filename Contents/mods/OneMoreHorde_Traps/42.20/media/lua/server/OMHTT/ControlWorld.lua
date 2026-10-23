if isClient() then return end
local existing = rawget(_G, "OMHTT_ControlWorld")
if existing then return existing end
local A = require("OMHTT/ControlAccess")
local C = require("OMHTT/ControlDefinitions")
local Battery = require("OMHTT/TurretBattery")
local Names = require("OMHTT/DefenseNames")
local Targeting = require("OMHTT/ControlTargeting")
local W = {objects = {}, bindings = setmetatable({}, {__mode = "k"}), cursor = 1, order = {}, indexed = {}, incoming = {}, batteries = {}, batteryScan = {}, locations = {}, plates = setmetatable({}, {__mode = "k"}), actorSquares = setmetatable({}, {__mode = "k"}), dirty = {}, dirtySet = {}}
OMHTT_ControlWorld = W
local store

---@return table records
function W.records()
    if not store then
        store = ModData.getOrCreate("OMHTTControlsV1")
        if not store.records then
            store.records, store.packed = {}, {}
        end
        local ids = {}
        for id in pairs(store.records) do
            ids[#ids + 1] = id
        end
        table.sort(ids)
        for i = 1, #ids do
            W.name(store.records[ids[i]])
        end
        for id, state in pairs(store.records) do
            if state.placed and state.location then
                W.locations[state.location] = W.locations[state.location] or {}
                W.locations[state.location][id] = true
            end
            for i = #(state.links or {}), 1, -1 do
                local target = state.links[i]
                local receiver = store.records[target]
                if state.placed and receiver and receiver.placed then
                    W.incoming[target] = W.incoming[target] or {}
                    W.incoming[target][id] = true
                else
                    table.remove(state.links, i)
                end
            end
        end
    end
    return store
end

---@param state table Private control state
---@return nil
function W.name(state)
    if state.kind == "Controller" then return end
    local base
    if state.kind == "Turret" then
        base = state.headType and state.headType ~= "Base" and getItemNameFromFullType(state.headType) or getText("UI_OMHTT_TurretBase")
    else
        base = getText("UI_OMHTT_Control" .. state.kind)
    end
    Names.ensure(state, state.kind, base)
    state.number = state.displayNumber
end

---@param source table State
---@return table copy
function W.copy(source)
    local copy = {}
    for key, value in pairs(source) do
        if type(value) == "string" or type(value) == "number" or type(value) == "boolean" then
            copy[key] = value
        end
    end
    if source.organization then
        copy.organization = require("OMHTT/ControlGroups").copy(source)
    end
    copy.links = {}
    for i = 1, #(source.links or {}) do
        copy.links[i] = source.links[i]
    end
    return copy
end

---@param object IsoObject Device
---@return table? state
function W.state(object)
    return W.bindings[object]
end

---@param object IsoObject Device
---@return nil
function W.publish(object)
    local state = W.state(object)
    if not state then return end
    local view = W.copy(state)
    if Targeting.supported(state.kind) then
        local host = state.controller and W.records().records[state.controller]
        view.targetingEffective = Targeting.resolve(state, host)
    end
    if state.kind == "Turret" or state.kind == "Tether" then
        view.inputs = {}
        for id in pairs(W.incoming[state.id] or {}) do
            local source = W.records().records[id]
            if source and source.placed then
                view.inputs[#view.inputs + 1] = {id = id, name = source.displayName or source.name, kind = source.kind,
                    x = source.x, y = source.y, z = source.z}
            end
        end
        table.sort(view.inputs, function(a, b) return a.id < b.id end)
    end
    object:getModData().OMHTTControl = view
    if isServer() then
        object:transmitModData()
    end
end

---@param object IsoObject Controller
---@param state table Private record
---@return nil
function W.controllerSprite(object, state)
    if state.kind ~= "Controller" then return end
    local turrets = getActivatedMods():contains("OneMoreHorde_Turrets")
    local sheet, first = turrets and "omhtt_turret_01_" or "omhtt_barrier_01_", turrets and 21 or 76
    local current = object:getSpriteName() or ""
    local desired
    for facing = 0, 3 do
        if current == sheet .. (first + facing) then
            desired = current
            break
        end
    end
    if not desired then
        local facing = tonumber(string.match(current, "^appliances_radio_01_(%d+)$")) or 16
        desired = sheet .. (first + math.max(0, math.min(3, facing - 16)))
    end
    local changed = current ~= desired
    if changed then
        local old = W.locations[state.location]
        if old then
            old[state.id] = nil
        end
        object:setSpriteFromName(desired)
        state.sprite = desired
        state.location = state.x .. ":" .. state.y .. ":" .. state.z .. ":" .. desired
        W.locations[state.location] = W.locations[state.location] or {}
        W.locations[state.location][state.id] = true
    end
    local config = object:getSpriteConfig()
    if not config or not config:isValid() or config:getTileInfo():getSpriteName() ~= desired then
        local info = SpriteConfigManager.GetObjectInfo("OMHTTDeployController")
        if not info then error("[OMHTT] Missing Controller sprite definition") end
        if config then
            GameEntityFactory.RemoveComponentType(object, ComponentType.SpriteConfig)
        end
        GameEntityFactory.AddComponent(object, ComponentType.SpriteConfig:CreateComponentFromScript(info:getScript()))
    end
    if changed and isServer() then
        object:transmitUpdatedSpriteToClients()
    end
end

---@param object IsoThumpable Momentary Button
---@param state table Private record
---@return nil
function W.buttonSprite(object, state)
    if state.kind ~= "Button" then return end
    local current = object:getSpriteName() or ""
    local facing = tonumber(string.match(current, "^appliances_radio_01_(%d+)$"))
    if not facing or facing < 0 or facing > 3 then return end
    local desired = "lighting_indoor_01_" .. facing
    local old = W.locations[state.location]
    if old then
        old[state.id] = nil
    end
    object:setSpriteFromName(desired)
    state.sprite = desired
    state.location = state.x .. ":" .. state.y .. ":" .. state.z .. ":" .. desired
    W.locations[state.location] = W.locations[state.location] or {}
    W.locations[state.location][state.id] = true
    local info = SpriteConfigManager.GetObjectInfo("OMHTTDeploySwitchButton")
    if not info then error("[OMHTT] Missing Button sprite definition") end
    if object:getSpriteConfig() then
        GameEntityFactory.RemoveComponentType(object, ComponentType.SpriteConfig)
    end
    GameEntityFactory.AddComponent(object, ComponentType.SpriteConfig:CreateComponentFromScript(info:getScript()))
    if isServer() then
        object:transmitUpdatedSpriteToClients()
    end
end

---@param object IsoObject New device
---@param player IsoPlayer Placer
---@param kind string Device family
---@param previous table? Preserved ownership
---@return table state
function W.register(object, player, kind, previous)
    local records = W.records()
    records.serial = (records.serial or 0) + 1
    local id = previous and previous.id or "control-" .. records.serial
    local state = previous and W.copy(previous) or {id = id, kind = kind, owner = player:getUsername(), access = "Private", links = {}}
    state.links = {}
    state.x, state.y, state.z = object:getX(), object:getY(), object:getZ()
    state.sprite = object:getSpriteName()
    state.location = state.x .. ":" .. state.y .. ":" .. state.z .. ":" .. state.sprite
    state.placed = true
    W.name(state)
    if state.controller then
        local host, count = records.records[state.controller], 0
        for _, assigned in pairs(records.records) do
            if assigned.id ~= state.id and assigned.placed and assigned.controller == state.controller
                and C.defense(assigned.kind) == C.defense(state.kind) then
                count = count + 1
            end
        end
        if not host or not host.placed or host.z ~= state.z or count >= 32 then
            state.controller = nil
        end
    end
    W.locations[state.location] = W.locations[state.location] or {}
    W.locations[state.location][id] = true
    state.recoverAt = require("OMHTT/ControlClock").now() + 1000
    state.active, state.powered, state.triggerHours = false, false, nil
    if kind == "Lever" then state.latched = false end
    if kind == "Laser" then state.beamRange, state.beamLength = state.beamRange or 10, 0 end
    state.checkedHours, state.pulseHoldUntil, state.facingPulse = nil, nil, nil
    W.records().records[id], W.objects[id], W.bindings[object] = state, object, state
    if not W.indexed[id] then
        W.order[#W.order + 1], W.indexed[id] = id, true
    end
    W.controllerSprite(object, state)
    W.buttonSprite(object, state)
    W.indexPlate(object, state)
    W.publish(object)
    return state
end

---@param object IsoObject Loaded device
---@return nil
function W.bind(object)
    if not instanceof(object, "IsoThumpable") or W.state(object) then return end
    local records = W.records().records
    local hint = object:hasModData() and object:getModData().OMHTTControl
    local square = object:getSquare()
    if not square then return end
    local location = square:getX() .. ":" .. square:getY() .. ":" .. square:getZ() .. ":" .. tostring(object:getSpriteName())
    local state = type(hint) == "table" and records[hint.id]
    if not state or not state.placed or state.location ~= location then
        state = nil
        for id in pairs(W.locations[location] or {}) do
            if state then return end
            state = records[id]
        end
    end
    if not state or not state.placed or state.location ~= location then return end
    local other = W.objects[state.id]
    if other and other ~= object and other:getObjectIndex() >= 0 then return end
    W.objects[state.id], W.bindings[object] = object, state
    state.active, state.powered, state.triggerHours, state.beamLength = false, false, nil, 0
    state.recoverAt = require("OMHTT/ControlClock").now() + 1000
    state.checkedHours, state.pulseHoldUntil, state.facingPulse = nil, nil, nil
    if not W.indexed[state.id] then
        W.order[#W.order + 1], W.indexed[state.id] = state.id, true
    end
    if state.kind == "Controller" and object:getContainer() then
        object:getContainer():setAcceptItemFunction("OMHTTControlAccept")
    end
    W.controllerSprite(object, state)
    W.buttonSprite(object, state)
    W.indexPlate(object, state)
    W.publish(object)
end

---@param square IsoGridSquare Loaded square
---@return nil
function W.square(square)
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        W.bind(objects:get(i))
    end
end

---@param object IsoObject Loaded input
---@param state table Private record
---@return nil
function W.indexPlate(object, state)
    if state.kind == "Plate" then
        W.plateSprite(object, state, true)
    end
    C.passive(object, state.kind)
    if state.kind ~= "Plate" then return end
    local square = object:getSquare()
    W.plates[square] = W.plates[square] or {}
    W.plates[square][object] = true
end

---@param object IsoThumpable Pressure plate
---@param state table Authoritative plate state
---@param configure boolean Refresh placement component on load
---@return nil
function W.plateSprite(object, state, configure)
    local turrets = getActivatedMods():contains("OneMoreHorde_Turrets")
    local sheet, first = turrets and "omhtt_turret_01_" or "omhtt_barrier_01_", turrets and 25 or 80
    local desired = sheet .. (first + (state.pressed and 4 or 0))
    if object:getSpriteName() ~= desired then
        local old = W.locations[state.location]
        if old then
            old[state.id] = nil
        end
        object:setSpriteFromName(desired)
        state.sprite = desired
        state.location = state.x .. ":" .. state.y .. ":" .. state.z .. ":" .. desired
        W.locations[state.location] = W.locations[state.location] or {}
        W.locations[state.location][state.id] = true
        if isServer() then
            object:transmitUpdatedSpriteToClients()
        end
    end
    if not configure then return end
    local config = object:getSpriteConfig()
    if not config or not config:isValid() or config:getTileInfo():getSpriteName() ~= sheet .. first then
        local info = SpriteConfigManager.GetObjectInfo("OMHTTDeployInsetPlate")
        if not info then error("[OMHTT] Missing pressure plate sprite definition") end
        if config then
            GameEntityFactory.RemoveComponentType(object, ComponentType.SpriteConfig)
        end
        GameEntityFactory.AddComponent(object, ComponentType.SpriteConfig:CreateComponentFromScript(info:getScript()))
    end
end

---@param object IsoObject Pressure plate
---@param now number Timestamp
---@return nil
function W.updateInput(object, desired, available)
    local state = W.state(object)
    if not state then return end
    local powered = require("OMHTT/ControlPower").trigger(object) and available ~= false
    local active = powered and desired == true and require("OMHTT/ControlClock").now() >= state.recoverAt
    if active == state.active and powered == state.powered then return end
    if state.active ~= active then
        local event = state.kind == "Laser" and (active and "detected" or "cleared") or "switch"
        if state.kind == "Laser" or state.kind == "Plate" then
            require("OMHTT/ControlAudio").emit(object, event)
        end
    end
    state.active, state.powered = active, powered
    W.publish(object)
    for i = 1, #state.links do
        local id = state.links[i]
        W.queueDirty(id)
    end
end

function W.updatePlate(object, now)
    now = require("OMHTT/ControlClock").now()
    local state = W.state(object)
    if not state then return end
    local pressed = now >= state.recoverAt and W.occupied(object)
    if pressed ~= state.pressed then
        state.pressed = pressed
        W.plateSprite(object, state, false)
    end
    W.updateInput(object, pressed)
end

---@param actor IsoGameCharacter Moving player or zombie
---@return nil
function W.actor(actor)
    require("OMHTT/ControlSensor").actor(actor)
    local previous = W.actorSquares[actor]
    local square = actor:getSquare()
    if actor:isDead() then
        square = nil
    end
    if square == previous then return end
    local current = square and W.plates[square]
    if not previous and not current then return end
    W.actorSquares[actor] = current and square or nil
    local now = getTimestampMs()
    for object in pairs(previous and W.plates[previous] or {}) do
        W.updatePlate(object, now)
    end
    for object in pairs(current or {}) do
        W.updatePlate(object, now)
    end
end

---@param controller IsoObject Controller
---@param object IsoObject Device
---@param player IsoPlayer Authorized operator
---@param enabled boolean Assign or release
---@return boolean assigned
function W.assign(controller, object, player, enabled)
    local host, state = W.state(controller), W.state(object)
    if not host or host.kind ~= "Controller" or not state or state.kind == "Controller"
        or controller:getHealth() <= 0 or object:getHealth() <= 0 or not A.range(controller, object)
        or not A.write(player, host) or not A.write(player, state) then return false end
    if not enabled and state.controller ~= host.id then return false end
    if enabled then
        local count = 0
        for _, other in pairs(W.records().records) do
            if other.placed and other.id ~= state.id and other.controller == host.id
                and C.defense(other.kind) == C.defense(state.kind) then
                count = count + 1
            end
        end
        if count >= 32 then return false end
    end
    if C.inputs[state.kind] then require("OMHTT/ControlPower").trigger(object) end
    state.controller = enabled and host.id or nil
    if C.inputs[state.kind] then W.updateInput(object, state.kind == "Lever" and state.latched or false) end
    if enabled and state.kind == "Turret" then
        W.number(object, require("OMHTT/Turret").contents(object:getContainer()).head)
    end
    W.publish(object)
    return true
end

---@param object IsoObject Newly placed input
---@param player IsoPlayer Placer
---@return boolean assigned
function W.autoAssign(object, player)
    local state = W.state(object)
    if not state or state.controller or state.kind == "Controller" or not C.types[state.kind] then return false end
    local candidates = {}
    for id, controller in pairs(W.objects) do
        local host = W.state(controller)
        if host and host.kind == "Controller" and host.placed and controller:getHealth() > 0
            and A.range(controller, object) and A.write(player, host) then
            candidates[#candidates + 1] = {object = controller, id = id,
                distance = (host.x - state.x) ^ 2 + (host.y - state.y) ^ 2}
        end
    end
    table.sort(candidates, function(a, b)
        if a.distance == b.distance then return a.id < b.id end
        return a.distance < b.distance
    end)
    for i = 1, #candidates do
        if W.assign(candidates[i].object, object, player, true) then return true end
    end
    return false
end

---@param params table Native construction transaction
---@return table? result
function W.create(params)
    local object, player = params.thumpable, params.character
    local consumed = params.craftRecipeData and params.craftRecipeData:getAllConsumedItems()
    local source, kind
    if consumed then
        for i = 0, consumed:size() - 1 do
            for key, fullType in pairs(C.types) do
                if consumed:get(i):getFullType() == fullType then
                    source, kind = consumed:get(i), key
                end
            end
        end
    end
    if not source or W.records().packed[tostring(source:getID())] == false then
        object:getSquare():transmitRemoveItemFromSquare(object)
        return {objectAlreadyTransmitted = true}
    end
    local previous = W.records().packed[tostring(source:getID())]
    local state = W.register(object, player, kind, previous)
    W.records().packed[tostring(source:getID())] = false
    state.itemType = source:getFullType()
    if kind == "Lever" or kind == "Laser" then state.facing = params.facing end
    object:setName(getText("UI_OMHTT_Control" .. kind))
    local health = kind == "Poke" and require("OMHTT/ControlPoke").option("Health", 200, 1, 10000) or 100
    state.maxHealth = health
    object:setMaxHealth(health)
    local restoredHealth = previous and previous.carriedHealth
    if restoredHealth == nil then
        restoredHealth = source:getCondition() / source:getConditionMax() * health
    end
    object:setHealth(math.max(0, math.min(health, restoredHealth)))
    state.carriedHealth = nil
    object:setCanPassThrough(true)
    object:setBlockAllTheSquare(false)
    if kind == "Controller" or kind == "Poke" then
        local container = ItemContainer.new(kind == "Poke" and "OMHTTPoke" or "OMHTTController", object:getSquare(), object)
        container:setCapacity(100)
        container:setAcceptItemFunction(kind == "Poke" and "OMHTTPokeReject" or "OMHTTControlAccept")
        container:setExplored(true)
        object:setContainer(container)
        local inventory = source:getInventory()
        while inventory:getItems():size() > 0 do
            local item = inventory:getItems():get(0)
            inventory:Remove(item)
            container:AddItem(item)
        end
    end
    local parent = source:getContainer()
    if parent then
        player:removeFromHands(source)
        parent:Remove(source)
        if isServer() then
            sendRemoveItemFromContainer(parent, source)
        end
    end
    for key in pairs(object:getBuildMaterials()) do
        object:getBuildMaterials()[key] = nil
    end
    require("OMHTT/ControlExpansion").refresh(object)
    W.autoAssign(object, player)
    W.publish(object)
end

---@param object IsoObject Controller
---@param elapsed number In-game hours
---@return boolean powered
function W.power(object, elapsed)
    require("OMHTT/ControlExpansion").refresh(object)
    return require("OMHTT/ControlPower").idle(object, elapsed)
end

---@param object IsoObject Pressure plate
---@return boolean occupied
function W.occupied(object)
    local moving = object:getSquare():getMovingObjects()
    local state = W.state(object)
    local trigger = state and state.trigger or "Both"
    for i = 0, moving:size() - 1 do
        local actor = moving:get(i)
        local eligible = (trigger ~= "Zombies" and instanceof(actor, "IsoPlayer"))
            or (trigger ~= "Players" and instanceof(actor, "IsoZombie"))
        if eligible and not actor:isDead() then return true end
    end
    return false
end

---@param target IsoObject Receiver
---@param now number Active wall-clock milliseconds
---@return boolean linked
---@return boolean on
function W.input(target, now)
    now = require("OMHTT/ControlClock").now()
    local targetState = W.state(target)
    if not targetState then return false, false end
    local linked, on, valid = false, false, false
    local lever, leverOn, other = false, true, false
    for id in pairs(W.incoming[targetState.id] or {}) do
        local source, state = W.objects[id], W.records().records[id]
        if state and state.placed then
            linked = true
            local usable = source and source:getObjectIndex() >= 0 and A.range(source, target)
                and source:getHealth() > 0 and now >= state.recoverAt
            valid = valid or usable == true
            local active = usable and (state.active == true or (state.pulseUntil and now <= state.pulseUntil)) and require("OMHTT/ControlPower").trigger(source)
            if state.kind == "Lever" then
                lever, leverOn = true, leverOn and active == true
            else
                other, on = true, on or active == true
            end
        end
    end
    return linked, (not lever or leverOn) and (on or (lever and not other)), valid, not lever or leverOn
end

---@param object IsoObject Removed device
---@return nil
function W.removed(object)
    require("OMHTT/ControlSensor").remove(object)
    require("OMHTT/ControlPoke").entries[object] = nil
    local state = W.state(object)
    if state and state.kind == "Tether" then
        require("OMHTT/TetherServer").cancel(object)
    end
    if not state then return end
    local plates = W.plates[object:getSquare()]
    if plates then
        plates[object] = nil
        local occupied = false
        for _ in pairs(plates) do
            occupied = true
            break
        end
        if not occupied then
            W.plates[object:getSquare()] = nil
        end
    end
    require("OMHTT/ControlCycle").cancel(object)
    require("OMHTT/ControlCycle").blocked[object] = nil
    state.active, state.powered, state.triggerHours, state.pulseUntil = false, false, nil, nil
    W.objects[state.id], W.bindings[object] = nil, nil
    W.batteries[object], W.batteryScan[object] = nil, nil
end

---@param object IsoObject Permanently removed or packed device
---@return nil
function W.retire(object)
    local state = W.state(object)
    if not state then return end
    state.placed = false
    if (state.kind == "Turret" or state.kind == "Tether") and W.input(object, getTimestampMs()) then
        W.clearInputs(object)
    end
    for i = 1, #state.links do
        local id = state.links[i]
        if W.incoming[id] then
            W.incoming[id][state.id] = nil
        end
        local target = W.objects[id]
        if target then
            local linked = W.input(target, getTimestampMs())
            if not linked and W.state(target).kind == "Tether" then
                W.receiver(target, getTimestampMs())
            elseif not linked then
                require("OMHTT/ControlCycle").cancel(target)
                require("OMHTT/TurretWorld").applyPower(target, false)
            else
                W.receiver(target, getTimestampMs())
            end
            W.publish(target)
        end
    end
    state.links = {}
    local locations = W.locations[state.location]
    if locations then
        locations[state.id] = nil
    end
end

---@param object IsoObject Native removal event
---@return nil
function W.deleted(object)
    W.retire(object)
    W.removed(object)
end

---@param id string Receiver identity
---@return nil
function W.queueDirty(id)
    if W.dirtyQueue ~= W.dirty then
        W.dirtyQueue, W.dirtyHead, W.dirtyLast = W.dirty, 1, #W.dirty
    end
    if W.dirtySet[id] then return end
    W.dirtySet[id] = true
    W.dirtyLast = W.dirtyLast + 1
    W.dirty[W.dirtyLast] = id
end

---@param now number Update time
---@param deadline number Shared soft deadline
---@return nil
function W.flushDirty(now, deadline)
    if W.dirtyQueue ~= W.dirty then
        W.dirtyQueue, W.dirtyHead, W.dirtyLast = W.dirty, 1, #W.dirty
    end
    for i = 1, 32 do
        if W.dirtyHead > W.dirtyLast or getTimestampMs() >= deadline then break end
        local id = W.dirty[W.dirtyHead]
        W.dirty[W.dirtyHead] = nil
        W.dirtyHead = W.dirtyHead + 1
        if id then
            W.dirtySet[id] = nil
            local receiver = W.objects[id]
            if receiver then
                W.receiver(receiver, now)
            end
        end
    end
    if W.dirtyHead > W.dirtyLast then
        W.dirty, W.dirtyHead, W.dirtyLast = {}, 1, 0
        W.dirtyQueue = W.dirty
    end
end

---@return nil
function W.tick()
    require("OMHTT/ControlPoke").advance()
    if GameTime.isGamePaused() then return end
    local now = getTimestampMs()
    if W.due and now < W.due then return end
    W.due = now + 100
    require("OMHTT/ControlPower").flush()
    local deadline = now + 2
    local hours = getGameTime():getWorldAgeHours()
    W.routineFirst = not W.routineFirst
    if not W.routineFirst then
        W.flushDirty(now, deadline)
    end
    for iteration = 1, math.min(64, #W.order) do
        if #W.order == 0 then break end
        if getTimestampMs() >= deadline then break end
        if W.cursor > #W.order then
            W.cursor = 1
        end
        local id = W.order[W.cursor]
        W.cursor = W.cursor + 1
        local object, state = W.objects[id], W.records().records[id]
        local square = object and object:getSquare()
        local loaded = state and square and getCell():getGridSquare(state.x, state.y, state.z) == square
        if loaded and state and object:getObjectIndex() >= 0 and (object:getHealth() > 0 or state.kind == "Poke" or state.kind == "Tether") then
            if state.kind == "Controller" and (not state.powerDue or now >= state.powerDue) then
                state.powerDue = now + 1000
                require("OMHTT/ControlPower").refresh(object)
            elseif state.kind == "Poke" then
                require("OMHTT/ControlPoke").step(object, state)
            elseif state.kind == "Plate" then
                W.updatePlate(object, now)
            elseif state.kind == "Lever" then
                W.updateInput(object, state.latched, require("OMHTT/ControlMount").resolve(state.x, state.y, state.z, state.facing) ~= nil)
            elseif state.kind == "Laser" then
                require("OMHTT/ControlSensor").step(object, state)
            elseif state.kind == "Button" then
                W.updateInput(object, false)
            elseif state.kind == "Turret" or state.kind == "Tether" then
                W.receiver(object, now)
            end
        else
            if object then
                W.removed(object)
            end
            W.indexed[id] = nil
            table.remove(W.order, W.cursor - 1)
            W.cursor = W.cursor - 1
        end
    end
    if W.routineFirst then
        W.flushDirty(now, deadline)
    end
end

---@param object IsoObject Loaded turret
---@param player IsoPlayer? Placer
---@return nil
function W.turret(object, player, packed)
    W.bind(object)
    if not W.state(object) and player then
        local previous = packed and W.records().packed[tostring(packed:getID())]
        W.register(object, player, "Turret", type(previous) == "table" and previous or nil)
        if packed then
            W.records().packed[tostring(packed:getID())] = false
        end
    end
end

---@param object IsoObject Placed turret
---@param item InventoryItem Recovered exact container
---@return nil
function W.packTurret(object, item)
    local state = W.state(object)
    if not state then return end
    W.retire(object)
    W.records().packed[tostring(item:getID())] = W.copy(state)
    item:getModData().OMHTTControl = W.copy(state)
    W.removed(object)
end

---@param object IsoObject Placed turret
---@param headItem InventoryItem? Current head
---@return nil
function W.number(object, headItem)
    local state = W.state(object)
    if not state then return end
    local head = headItem and headItem:getFullType() or "Base"
    if state.headType == head and state.displayNumber then return end
    state.headType = head
    W.name(state)
    W.publish(object)
end

---@param object IsoObject Linked turret
---@param now number Timestamp
---@return nil
function W.receiver(object, now)
    local state = W.state(object)
    if state and state.kind == "Tether" then
        require("OMHTT/TetherServer").step(object, state)
        return
    end
    local linked, on, valid = W.input(object, now)
    local cycle = require("OMHTT/ControlCycle")
    if not linked then
        if cycle.pending[object] then
            cycle.cancel(object)
            require("OMHTT/TurretWorld").applyPower(object, false)
        end
        return
    end
    cycle.step(object, on, valid)

end

---@param object IsoObject Authorized linked receiver
---@return string result
function W.fireSignal(object)
    local auto = require("OMHTT/TurretAutomation").entries[object]
    local target = auto and auto.target
    if target and target:isDead() then
        target = nil
    end
    return require("OMHTT/TurretWorld").fire(nil, object, target, true)
end

---@param object IsoObject Button's linked output
---@return nil
function W.pulse(object)
    local linked, on, valid, leverAllowed = W.input(object, getTimestampMs())
    if linked and not leverAllowed then return end
    local control = W.state(object)
    if control and control.kind == "Tether" then
        require("OMHTT/TetherServer").step(object, control, true)
        return
    end
    if not control or control.kind ~= "Turret" or require("OMHTT/ControlClock").now() < control.recoverAt then return end
    local cycle = require("OMHTT/ControlCycle")
    cycle.blocked[object] = nil
    if cycle.request(object) then
        local _, on, valid = W.input(object, getTimestampMs())
        cycle.step(object, on, valid)
    end

end

---@param player IsoPlayer Operator
---@param object IsoObject Controller, plate or button
---@return boolean pickedUp
function W.pickup(player, object)
    local state = W.state(object)
    if not state or not A.near(player, object) or not A.write(player, state) or not state.itemType then return false end
    local item = instanceItem(state.itemType)
    if not item then return false end
    state.carriedHealth = object:getHealth()
    item:setCondition(state.carriedHealth > 0 and math.max(1, math.floor(state.carriedHealth / (state.maxHealth or 100) * item:getConditionMax())) or 0)
    local storage = object:getContainer()
    if storage then
        local destination = item:getInventory()
        while storage:getItems():size() > 0 do
            local child = storage:getItems():get(0)
            storage:Remove(child)
            destination:AddItem(child)
        end
    end
    local heavy = not player:getInventory():hasRoomFor(player, item)
    if heavy then
        forceDropHeavyItems(player)
    end
    if player:getInventory():AddItem(item) ~= item then
        if storage then
            local destination = item:getInventory()
            while destination:getItems():size() > 0 do
                local child = destination:getItems():get(0)
                destination:Remove(child)
                storage:AddItem(child)
            end
        end
        return false
    end
    W.retire(object)
    W.records().packed[tostring(item:getID())] = W.copy(state)
    item:getModData().OMHTTControl = W.copy(state)
    W.removed(object)
    object:getSquare():transmitRemoveItemFromSquare(object)
    if isServer() then
        sendAddItemToContainer(player:getInventory(), item)
    end
    if heavy then
        player:setPrimaryHandItem(item)
        player:setSecondaryHandItem(item)
        if isServer() then
            sendEquip(player)
        end
    end
    return true
end

---@param object IsoObject Authorized receiver
---@return nil
function W.clearInputs(object)
    local state = W.state(object)
    for id in pairs(W.incoming[state.id] or {}) do
        local source = W.records().records[id]
        if source then
            for i = #source.links, 1, -1 do
                if source.links[i] == state.id then
                    table.remove(source.links, i)
                end
            end
            if W.objects[id] then
                W.publish(W.objects[id])
            end
        end
    end
    W.incoming[state.id] = nil
    W.publish(object)
    if state.kind == "Tether" then return end
    require("OMHTT/ControlCycle").cancel(object)
    state.pulseHoldUntil, state.facingPulse = nil, nil
    local T = require("OMHTT/Turret")
    if T.state(object) then
        require("OMHTT/TurretWorld").applyPower(object, false)
    end
end

---@param source IsoObject Input
---@param target IsoObject Receiver
---@param enabled boolean Add or remove
---@return boolean changed
function W.link(source, target, enabled)
    local from, to = W.state(source), W.state(target)
    if not from or not to or not A.range(source, target) or (to.kind ~= "Turret" and to.kind ~= "Tether")
        or not C.inputs[from.kind] then return false end
    local incoming, index, count = W.incoming[to.id] or {}, nil, 0
    for _ in pairs(incoming) do count = count + 1 end
    for i = 1, #from.links do
        if from.links[i] == to.id then
            index = i
        end
    end
    if enabled then
        if index then return true end
        if #from.links >= 32 or count >= 32 then return false end
        from.links[#from.links + 1], incoming[from.id] = to.id, true
    elseif index then
        table.remove(from.links, index)
        incoming[from.id] = nil
    end
    W.incoming[to.id] = incoming
    W.publish(source)
    W.receiver(target, getTimestampMs())
    W.publish(target)
    return true
end

Events.LoadGridsquare.Add(W.square)
Events.OnObjectAdded.Add(W.bind)
Events.OnObjectAboutToBeRemoved.Add(W.deleted)
Events.OnTick.Add(W.tick)
Events.OnZombieUpdate.Add(W.actor)
Events.OnPlayerUpdate.Add(W.actor)
return W
