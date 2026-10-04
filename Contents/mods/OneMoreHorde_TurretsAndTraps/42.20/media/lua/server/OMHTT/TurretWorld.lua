if isClient() then return end
local T = require("OMHTT/Turret")
local F = require("OMHTT/Foundation")
local D = require("OMHTT/Diagnostics")
local Cycle = require("OMHTT/TurretCycle")
local M = require("OMHTT/TurretModules")
local G = require("OMHTT/Firearms")
local Audio = require("OMHTT/TurretReloadAudio")
OMHTT_TurretWorld = {}
local W = OMHTT_TurretWorld
local facings = {e = 0, n = 4, w = 8, s = 12}
local generators = {}
local feeders, feederOrder, feederCursor = {}, {}, 1
local snapshots, refreshQueue = {}, {}

---@param object IsoThumpable Managed turret
---@return nil
function W.clearBuildRefund(object)
    local materials = object:getBuildMaterials()
    for fullType in pairs(materials) do
        materials[fullType] = nil
    end
end

---@param object IsoObject Candidate device
---@return boolean valid
---@nodiscard
function W.valid(object)
    return not isClient() and not isServer() and T.enabled() and T.state(object) ~= nil
        and object:getObjectIndex() >= 0 and object:getSquare() ~= nil and object:getHealth() > 0
end

---@param player IsoPlayer Operator
---@param object IsoObject Device
---@return boolean ready
---@nodiscard
function W.near(player, object)
    if not W.valid(object) or player:isDead() then return false end
    local square = object:getSquare()
    if player:getZ() ~= square:getZ() then return false end
    local origin = player:getSquare()
    if not origin then return false end
    if origin == square then return true end
    if math.abs(origin:getX() - square:getX()) > 1 or math.abs(origin:getY() - square:getY()) > 1 then return false end
    local dx, dy = player:getX() - square:getX() - 0.5, player:getY() - square:getY() - 0.5
    return dx * dx + dy * dy <= 4 and origin:canReachTo(square)
end

---@param params table Native placement test
---@return boolean valid
---@nodiscard
function W.onIsValid(params)
    if isClient() or isServer() or not T.enabled() or not params.square then return false end
    local square = params.square
    if not square:TreatAsSolidFloor() or square:isSolid() or square:isSolidTrans() then return false end
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        if T.state(object) or (object:hasModData() and (object:getModData().OMHTT or object:getModData().OMHTTEdge)) then return false end
    end
    return true
end

---@param object IsoThumpable Device
---@return nil
function W.refresh(object)
    snapshots[object] = nil
    local state = T.state(object)
    if not state or not object:getContainer() then return end
    local contents = T.contents(object:getContainer())
    if contents.head and not feeders[object] then
        feeders[object] = true
        feederOrder[#feederOrder + 1] = object
    end
    if Audio.entries[object] and Audio.entries[object].head ~= contents.head then Audio.stop(object) end
    if contents.head then contents.head:getModData().OMHTTPowerOff = not T.isOn(state) end
    state.baseFacing = state.baseFacing or state.facing
    local hybrid = T.hybrid()
    local sprite = T.sprite(state.baseFacing or state.facing, false)
    getSprite(sprite):getProperties():unset(IsoFlagType.FloorOverlay)
    if contents.head and not G.profile(contents.head) and not hybrid then sprite = T.sprite(state.facing, true) end
    if object:getSpriteName() ~= sprite then
        object:setSprite(sprite)
        object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_MODIFY)
    end
    local config = object:getSpriteConfig()
    if not config or not config:isValid() or config:getTileInfo():getSpriteName() ~= sprite then
        local entity = "OMHTTDeployTurret"
        if contents.head and not G.profile(contents.head) and not hybrid then entity = "OMHTTPotatoVisual" .. math.floor(F.normalizeFacing(state.facing) / 4) end
        local info = SpriteConfigManager.GetObjectInfo(entity)
        if not info then error("[OMHTT] Missing turret visual entity " .. entity) end
        if config then GameEntityFactory.RemoveComponentType(object, ComponentType.SpriteConfig) end
        GameEntityFactory.AddComponent(object, ComponentType.SpriteConfig:CreateComponentFromScript(info:getScript()))
        if not object:getSpriteConfig():isValid() then error("[OMHTT] Invalid turret sprite " .. sprite) end
    end
    if state.depthPolicy ~= "cube-depth-v2" then
        object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_MODIFY)
        state.depthPolicy = "cube-depth-v2"
    end
    state.condition = object:getHealth()
    T.cycle(contents, getTimestampMs())
    triggerEvent("OnOMHTTTurretChanged", object, contents.head)
end

---@param object IsoObject Turret
---@param configuration boolean Head/module/control change
---@return nil
function W.queueRefresh(object, configuration)
    snapshots[object] = nil
    refreshQueue[object] = configuration or refreshQueue[object] or false
end

---@param object IsoObject Turret
---@return table contents Bounded-lived inventory snapshot
function W.contents(object)
    local storage, now = object:getContainer(), getTimestampMs()
    local count = storage:getItems():size()
    local entry = snapshots[object]
    if not entry or entry.count ~= count or now >= entry.expires or now < entry.created then
        entry = {count = count, created = now, expires = now + 200, contents = T.contents(storage)}
        snapshots[object] = entry
    end
    local contents = entry.contents
    if G.profile(contents.head) then contents.ammo = contents.reserve + G.loaded(contents.head) end
    return contents
end

---@param player IsoPlayer Operator
---@param object IsoObject Turret
---@param enabled boolean Switch value
---@return boolean changed
function W.setPower(player, object, enabled)
    if not W.near(player, object) then return false end
    local state = T.state(object)
    state.powered, state.automatic = enabled, nil
    require("OMHTT/TurretAim").entries[object] = nil
    local search = require("OMHTT/TurretSearch").pending[object]
    if search then search.cancelled = true end
    local auto = require("OMHTT/TurretAutomation").entries[object]
    if auto then auto.target, auto.job, auto.status = nil, nil, "inactive" end
    local head = T.contents(object:getContainer()).head
    Audio.stop(object)
    if head then
        head:getModData().OMHTTPowerOff = not enabled
        if G.profile(head) then
            G.cancelLoading(head)
        else
            local cycle = head:getModData().OMHTTCycle
            if cycle then cycle.reloadReady, cycle.pending = nil, nil end
        end
    end
    W.refresh(object)
    D.emit("turret-power-toggle", {id = state.id, enabled = enabled})
    return true
end

---@param params table Native construction callback
---@return nil
function W.onCreate(params)
    if isClient() or isServer() then return end
    local object, player, data = params.thumpable, params.character, params.craftRecipeData
    if T.state(object) then return end
    D.emit("turret-placement", {cheat = player:isBuildCheat(), x = object:getX(), y = object:getY(),
        playerX = player:getX(), playerY = player:getY(), distance = math.sqrt((object:getX() - player:getX()) ^ 2 + (object:getY() - player:getY()) ^ 2)})
    local source = nil
    if data then
        local items = data:getAllConsumedItems()
        for i = 0, items:size() - 1 do
            if items:get(i):getFullType() == T.BASE then source = items:get(i) end
        end
    end
    if source and source:getModData().OMHTTDeployed then source = nil end
    if not source then
        if not player:isBuildCheat() then
            object:getSquare():transmitRemoveItemFromSquare(object)
            D.emit("turret-deploy-rejected", {reason = "missing-exact-item"})
            return
        end
        source = instanceItem(T.BASE)
        T.configure(source:getInventory())
    end
    local previous = source:getModData().OMHTTTurret
    local health = T.option("Health", 100, 1, 10000)
    local state = {schema = 1, id = "turret-" .. source:getID(), kind = "potato", facing = facings[params.facing],
        condition = math.max(1, math.floor(source:getCondition() / source:getConditionMax() * health)),
        maxHealth = health, shots = 0, nextShot = 0, revision = 1}
    if previous then
        for key, value in pairs(previous) do state[key] = value end
        state.facing = facings[params.facing]
        state.id = "turret-" .. source:getID()
    end
    object:getModData().OMHTTTurret = state
    W.clearBuildRefund(object)
    source:getModData().OMHTTDeployed = true
    object:setName(getText("UI_OMHTT_TurretBase"))
    object:setMaxHealth(state.maxHealth)
    object:setHealth(state.condition)
    state.baseFacing = state.facing
    state.aimDegrees = state.baseFacing * 22.5
    object:setBlockAllTheSquare(true)
    object:setCanPassThrough(true)
    object:setIsThumpable(true)
    local container = ItemContainer.new(T.CONTAINER, object:getSquare(), object)
    T.configure(container)
    object:setContainer(container)
    T.moveContents(source:getInventory(), container)
    if source:getContainer() then
        player:removeFromHands(source)
        source:getContainer():Remove(source)
    end
    W.refresh(object)
    object:getSquare():RecalcAllWithNeighbours(true)
    D.emit("turret-deployed", {id = state.id, facing = state.facing, health = state.condition,
        ammo = T.contents(container).ammo, items = container:getItems():size(), x = object:getX(), y = object:getY()})
end

---@param player IsoPlayer Operator
---@param object IsoThumpable Damaged base
---@param id string Expected identity
---@return boolean repaired
function W.repair(player, object, id)
    if not W.near(player, object) or T.state(object).id ~= id then return false end
    if object:getHealth() >= object:getMaxHealth() then return false end
    object:setHealth(object:getMaxHealth())
    local state = T.state(object)
    state.condition = object:getHealth()
    state.revision = state.revision + 1
    W.refresh(object)
    D.emit("turret-repaired", {id = id, health = state.condition})
    return true
end

---@param player IsoPlayer Operator
---@param object IsoThumpable Device
---@param id string Expected identity
---@return boolean applied
function W.pickup(player, object, id)
    if not W.near(player, object) or T.state(object).id ~= id then return false end
    local item = instanceItem(T.BASE)
    local state = T.state(object)
    if state.depthPolicy ~= "cube-depth-v2" then
        object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_MODIFY)
        state.depthPolicy = "cube-depth-v2"
    end
    state.condition = object:getHealth()
    local copied = {}
    for key, value in pairs(state) do copied[key] = value end
    item:getModData().OMHTTTurret = copied
    item:setCondition(math.max(1, math.floor(state.condition / state.maxHealth * item:getConditionMax())))
    T.configure(item:getInventory())
    local contents = object:getContainer()
    local weight = item:getActualWeight() + T.contents(contents).weight
    item:setActualWeight(weight)
    local room = player:getInventory():hasRoomFor(player, item)
    item:setActualWeight(instanceItem(T.BASE):getActualWeight())
    if not room then
        player:setHaloNote(getText("UI_OMHTT_PickupNoRoom"), 255, 170, 80, 180)
        return false
    end
    T.moveContents(contents, item:getInventory())
    object:getModData().OMHTTTurret = nil
    object:getSquare():transmitRemoveItemFromSquare(object)
    player:getInventory():AddItem(item)
    D.emit("turret-picked-up", {id = id, items = item:getInventory():getItems():size(), weight = weight,
        shots = copied.shots, nextShot = copied.nextShot})
    return true
end

---@param object IsoObject Loaded object
---@return nil
function W.loaded(object)
    if instanceof(object, "IsoGenerator") then generators[object] = true end
    if T.state(object) and object:getContainer() then
        W.clearBuildRefund(object)
        object:setBlockAllTheSquare(true)
        object:setCanPassThrough(true)
        object:setIsThumpable(true)
        object:getSquare():RecalcAllWithNeighbours(true)
        T.configure(object:getContainer())
        W.refresh(object)
        D.emit("turret-restored", {id = T.state(object).id, health = object:getHealth(), items = object:getContainer():getItems():size()})
    end
end

---@param square IsoGridSquare Loaded tile
---@return nil
function W.squareLoaded(square)
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do W.loaded(objects:get(i)) end
end

---@param object IsoObject Removed object
---@return nil
function W.removed(object)
    Audio.stop(object)
    generators[object] = nil
    local state = T.state(object)
    if not state then return end
    local square = object:getSquare()
    if not square then return end
    local container = object:getContainer()
    local remaining = 0
    if container then
        local items = container:getItems()
        remaining = items:size()
        for i = items:size() - 1, 0, -1 do
            local item = items:get(i)
            container:Remove(item)
            square:AddWorldInventoryItem(item, 0.5, 0.5, 0)
        end
    end
    object:getModData().OMHTTTurret = nil
    for i = 1, 2 do
        square:AddWorldInventoryItem("Base.ScrapMetal", 0.35 + i * 0.1, 0.5, 0)
    end
    D.emit("turret-destroyed", {id = state.id, fallbackItemsDropped = remaining, scrap = 2})
end

---@param object IsoObject Turret
---@param contents table Inventory summary
---@return table? source Power transaction
---@nodiscard
function W.power(object, contents)
    if SandboxVars.OMHTurretsTraps.PotatoRequirePower == false then return {kind = "disabled", cost = 0} end
    local square = object:getSquare()
    if square:hasGridPower() and square:getRoom() then return {kind = "grid", cost = 0} end
    if square:haveElectricity() then
        local cost = T.option("GeneratorFuelPerShot", 0.001, 0, 1)
        for generator in pairs(generators) do
            local origin = generator:getSquare()
            if not origin or generator:getObjectIndex() < 0 then
                generators[generator] = nil
            elseif generator:isActivated() and generator:isConnected() and generator:getFuel() >= cost
                and IsoGenerator.isPoweringSquare(origin:getX(), origin:getY(), origin:getZ(), square:getX(), square:getY(), square:getZ()) then
                return {kind = "generator", generator = generator, cost = cost}
            end
        end
    end
    local battery = contents.battery
    local cost = T.option("BatteryPercentPerShot", 0.1, 0, 100) / 100
    if battery and battery:getCondition() > 0 and battery:getCurrentUsesFloat() > 0
        and battery:getCurrentUsesFloat() + 0.0000001 >= cost then
        return {kind = "battery", battery = battery, cost = cost}
    end
    return nil
end

---@param player IsoPlayer Operator
---@param object IsoThumpable Exact turret
---@param target IsoZombie? Detected target for autonomous shot
---@return string result
function W.fire(player, object, target)
    local started = getTimestampMs()
    if not T.isOn(T.state(object)) then return "Off" end
    if player then
        if not W.near(player, object) then return "Unavailable" end
    elseif not target or not W.valid(object) then
        return "Unavailable"
    end
    local contents = T.contents(object:getContainer())
    if not player and (not M.detects(T.state(object), contents) or not contents.active.Firing) then return "Unavailable" end
    if contents.heads ~= 1 or contents.head:getCondition() <= 0 then return "NoHead" end
    if contents.ammo == 0 then return "Empty" end
    local power = W.power(object, contents)
    if not power then return "NoPower" end
    local cycle, status = T.cycle(contents, getTimestampMs())
    if status ~= "Ready" then return status end
    local state = T.state(object)
    state.ammo = contents.ammo
    local stats = T.cycleConfig(contents)
    if player and not target then return require("OMHTT/TurretSearch").request(player, object) end
    local fireStarted = getTimestampMs()
    local options = {range = stats.range, interval = stats.cooldown,
        damage = stats.damage / 100, knockdown = stats.knockdown, critChance = stats.critChance, critMultiplier = stats.critMultiplier,
        splash = stats.damage * T.option("SplashPercent", 25, 0, 100) / 10000, radius = T.option("SplashRadius", 1.5, 0, 3), managed = true,
        profile = M.profile(state, contents), target = target, projectileSpeed = T.option("ProjectileSpeed", 20, 5, 100)}
    if G.profile(contents.head) then
        options.projectileSpeed, options.splash, options.radius = nil, 0, 0
        options.resolve = require("OMHTT/FirearmCombat").hit
        options.weapon, options.stats, options.object = contents.head, stats, object
    end
    ---@param selected IsoZombie Chosen target
    ---@return boolean aligned
    function options.align(selected)
        return require("OMHTT/TurretAim").request(object, selected, player)
    end
    ---@return boolean committed
    function options.commit()
        if not W.valid(object) or not object:getContainer():contains(contents.head) then return false end
        if not G.profile(contents.head) and not object:getContainer():contains(contents.round) then return false end
        if player and not W.near(player, object) then return false end
        if not player and (not M.detects(state, contents) or not contents.active.Firing) then return false end
        if G.profile(contents.head) and not G.consume(contents, stats, getTimestampMs()) then return false end
        if power.kind == "battery" then
            power.battery:setCurrentUsesFloat(math.max(0, power.battery:getCurrentUsesFloat() - power.cost))
        elseif power.kind == "generator" then
            power.generator:setFuel(math.max(0, power.generator:getFuel() - power.cost))
        end
        if not G.profile(contents.head) then
            object:getContainer():Remove(contents.round)
            Cycle.consume(cycle, contents.ammo - 1, stats, getTimestampMs())
        end
        D.defer("turret-resource-spent", {id = state.id, head = contents.head:getID(), power = power.kind, cost = power.cost})
        return true
    end
    local Combat = require("OMHTT/PrototypeCombat")
    local result, impact = Combat.fire(state, object, player, options)
    local committedAt = getTimestampMs()
    if result == "Fired" and not T.hybrid() then W.refresh(object) end
    local refreshedAt = getTimestampMs()
    if impact then
        if stats.suppressed then
            local replacement = require("OMHTT/TurretSounds").suppressed(contents.head)
            if replacement then
                impact.sound = replacement
            else
                impact.gain = math.max(M.option("SuppressionVolumeFloor", 10, 1, 100) / 100, stats.hearingMultiplier)
            end
        end
        if not stats.firearm then
            local square = object:getSquare()
            local radius = math.ceil(M.option("PotatoHearingRadius", 8, 0, 200) * stats.hearingMultiplier)
            if radius > 0 then addSound(object, square:getX(), square:getY(), square:getZ(), radius, 10) end
            D.defer("turret-hearing", {id = state.id, radius = radius, suppressed = stats.suppressed})
        end
        local command = "Launch"
        if impact.firearm then command = "GunShot" end
        triggerEvent("OnServerCommand", F.MODULE, command, impact)
    end
    local effectsAt = getTimestampMs()
    D.defer("turret-fire-result", {id = state.id, result = result, ammo = state.ammo, power = power.kind, automatic = player == nil,
        loaded = cycle.loaded, reloadReady = cycle.reloadReady, nextShot = cycle.nextShot, fireMs = effectsAt - started,
        prepareMs = fireStarted - started, combatMs = committedAt - fireStarted,
        refreshMs = refreshedAt - committedAt, effectsMs = effectsAt - refreshedAt})
    return result
end

---@return nil
function W.feedTick()
    if isClient() or isServer() then return end
    local now = getTimestampMs()
    local deadline = now + 1
    local changed = 0
    for object, configuration in pairs(refreshQueue) do
        refreshQueue[object] = nil
        if W.valid(object) then
            if configuration then W.refresh(object) end
        else
            snapshots[object] = nil
        end
        changed = changed + 1
        if changed >= 4 or getTimestampMs() >= deadline then break end
    end
    for i = 1, math.min(4, #feederOrder) do
        if #feederOrder == 0 or getTimestampMs() >= deadline then return end
        if feederCursor > #feederOrder then feederCursor = 1 end
        local object = feederOrder[feederCursor]
        local square = object:getSquare()
        if not square or object:getObjectIndex() < 0 or not T.state(object)
            or getCell():getGridSquare(square:getX(), square:getY(), square:getZ()) ~= square then
            Audio.stop(object)
            feeders[object], snapshots[object] = nil, nil
            table.remove(feederOrder, feederCursor)
        else
            local state = T.state(object)
            if not state.feedCheck or now >= state.feedCheck then
                state.feedCheck = now + 100
                local contents = W.contents(object)
                if contents.head then
                    local stats = T.cycleConfig(contents)
                    if W.valid(object) and T.isOn(state) and W.power(object, contents) then
                        local cycle, status
                        if G.profile(contents.head) then
                            cycle, status = G.update(contents, stats, now, true)
                        else
                            cycle, status = T.cycle(contents, now)
                        end
                        Audio.update(object, contents.head, cycle, status, stats, now)
                        if state.feedStatus ~= status then
                            D.defer("turret-cycle", {id = state.id, head = contents.head:getFullType(), status = status})
                            state.feedStatus = status
                        end
                    else
                        Audio.stop(object)
                        if G.profile(contents.head) then G.cancelLoading(contents.head) end
                    end
                else
                    Audio.stop(object)
                    feeders[object], snapshots[object] = nil, nil
                    table.remove(feederOrder, feederCursor)
                    feederCursor = feederCursor - 1
                end
            end
            feederCursor = feederCursor + 1
        end
    end
end

Events.OnTick.Add(W.feedTick)
Events.LoadGridsquare.Add(W.squareLoaded)
Events.OnObjectAdded.Add(W.loaded)
Events.OnObjectAboutToBeRemoved.Add(W.removed)
return W
