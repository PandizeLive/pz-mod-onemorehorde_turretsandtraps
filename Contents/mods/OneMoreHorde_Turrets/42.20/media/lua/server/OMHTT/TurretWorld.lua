local Budget = require("OMHTT/TurretScheduler")
local Clock = require("OMHTT/TurretClock")
if isClient() then return end
local T = require("OMHTT/Turret")
local F = require("OMHTT/Foundation")
local D = require("OMHTT/Diagnostics")
local Cycle = require("OMHTT/TurretCycle")
local M = require("OMHTT/TurretModules")
local G = require("OMHTT/Firearms")
local Audio = require("OMHTT/TurretReloadAudio")
local Authority = require("OMHTT/TurretAuthority")
OMHTT_TurretWorld = {}
local W = OMHTT_TurretWorld
local facings = {e = 0, n = 4, w = 8, s = 12}
local generators = {}
local feeders, feederOrder, feederCursor = {}, {}, 1
local snapshots, refreshQueue = {}, {}
local presentations = setmetatable({}, {__mode = "k"})

---@param object IsoObject Server-owned turret
---@param state table Authoritative controls
---@param contents table Inventory snapshot
---@param now number Active clock
---@return nil
function W.publishRuntime(object, state, contents, now)
    if not isServer() then return end
    local view = presentations[object]
    if not view then
        view = {due = 0, batteryDue = 0}
        presentations[object] = view
    end
    if now >= view.due then
        view.due = now + 250
        local source = W.power(object, contents)
        state.powerSource = source and source.kind or "none"
        local heading = math.floor((state.aimDegrees or 0) / 2)
        if view.heading ~= heading or view.shots ~= state.shots or view.moving ~= state.rotaryMoving
            or view.status ~= state.feedStatus or view.loaded ~= state.feedLoaded or view.powerSource ~= state.powerSource then
            view.powerSource = state.powerSource
            view.heading, view.shots, view.moving = heading, state.shots, state.rotaryMoving
            view.status, view.loaded = state.feedStatus, state.feedLoaded
            Authority.publish(object)
        end
    end
    if now >= view.batteryDue then
        view.batteryDue = now + 1000
        local battery = contents.battery
        if battery and view.charge ~= require("OMHTT/TurretBattery").charge(battery) then
            view.charge = require("OMHTT/TurretBattery").charge(battery)
            sendItemStats(battery)
            require("OMHTT/TurretItemState").publish(battery)
        end
    end
end

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
    return not isClient() and T.enabled() and T.state(object) ~= nil
        and object:getObjectIndex() >= 0 and object:getSquare() ~= nil and object:getHealth() > 0
end

---@param player IsoPlayer Operator
---@param object IsoObject Device
---@return boolean ready
---@nodiscard
function W.near(player, object)
    if not player or not W.valid(object) or player:isDead() then return false end
    return require("OMHTT/ControlAccess").authorized(player, object)
end

---@param object IsoThumpable Device
---@return nil
function W.refresh(object)
    snapshots[object] = nil
    local state = T.state(object)
    if not state or not object:getContainer() then return end
    local contents = T.contents(object:getContainer())
    require("OMHTT/ControlWorld").number(object, contents.head)
    if isServer() and contents.void then require("OMHTT/TurretItemState").publish(contents.void) end
    if contents.head and not feeders[object] then
        feeders[object] = true
        feederOrder[#feederOrder + 1] = object
    end
    if Audio.entries[object] and Audio.entries[object].head ~= contents.head then Audio.stop(object) end
    if contents.head then contents.head:getModData().OMHTTPowerOff = not T.isOn(state) end
    state.baseFacing = state.baseFacing or state.facing
    local hybrid = isServer() or T.hybrid()
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
    if not isServer() then
        T.cycle(contents, Clock.now())
    end
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
    if G.profile(contents.head) then contents.ammo = contents.reserve + G.loaded(contents.head) + (contents.virtualAmmo or 0) end
    return contents
end

---@param player IsoPlayer Operator
---@param object IsoObject Turret
---@param enabled boolean Switch value
---@return boolean changed
function W.setPower(player, object, enabled)
    if not W.near(player, object) then return false end
    if enabled then
        local linked, on = require("OMHTT/ControlWorld").input(object, getTimestampMs())
        if linked then
            if not on then return false end
            local cycle = require("OMHTT/ControlCycle")
            cycle.blocked[object] = nil
            return cycle.request(object) or T.isOn(T.state(object))
        end
    end
    if not enabled then
        require("OMHTT/ControlCycle").manualOff(object)
    end
    return W.applyPower(object, enabled, player)
end

---@param object IsoObject Authorized turret
---@param degrees number Validated world heading
---@return boolean changed
function W.setFacing(object, degrees)
    if not W.valid(object) or type(degrees) ~= "number" or not (degrees >= 0 and degrees < 360) then return false end
    local state = T.state(object)
    state.facingDegrees, state.facingPending = degrees, true
    local control = require("OMHTT/ControlWorld").state(object)
    if control and control.facingPulse then
        control.facingPulse, control.facingPulseTail, control.pulseHoldUntil = nil, nil, nil
    end
    require("OMHTT/TurretAim").entries[object] = nil
    local search = require("OMHTT/TurretSearch").pending[object]
    if search then
        search.cancelled = true
    end
    W.refresh(object)
    Authority.publish(object)
    return true
end

---@param object IsoObject Turret
---@param enabled boolean Actual power switch
---@param player IsoPlayer? Operator; nil for authoritative signals
---@return boolean changed
function W.applyPower(object, enabled, player)
    if isClient() or type(enabled) ~= "boolean" or not W.valid(object) then return false end
    local state = T.state(object)
    state.powered, state.automatic = enabled, nil
    if not enabled then
        state.lureRepeat = false
        require("OMHTT/ControlCycle").cancel(object)
    end
    state.rotaryManual, state.rotaryMoving = nil, false
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
            local cycle = require("OMHTT/TurretItemState").get(head, "cycle")
            if cycle then cycle.reloadReady, cycle.pending = nil, nil end
        end
    end
    W.refresh(object)
    if isServer() then
        if head then
            require("OMHTT/TurretItemState").publish(head, player)
        end
        Authority.publish(object)
    end
    D.emit("turret-power-toggle", {id = state.id, enabled = enabled})
    return true
end

---@param params table Native construction callback
---@return table? result Native transmission instruction
function W.onCreate(params)
    if isClient() then return end
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
    if source and ((isServer() and not Authority.available(source))
        or (not isServer() and source:getModData().OMHTTDeployed)) then
        object:getSquare():transmitRemoveItemFromSquare(object)
        return {objectAlreadyTransmitted = true}
    end
    if not source then
        if not player:isBuildCheat() then
            object:getSquare():transmitRemoveItemFromSquare(object)
            D.emit("turret-deploy-rejected", {reason = "missing-exact-item"})
            return {objectAlreadyTransmitted = true}
        end
        source = instanceItem(T.BASE)
        T.configure(source:getInventory())
    end
    local previous = source:getModData().OMHTTTurret
    if isServer() then
        previous = Authority.packed(source)
    end
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
    if isServer() then
        if not Authority.register(object, state) then
            object:getSquare():transmitRemoveItemFromSquare(object)
            return {objectAlreadyTransmitted = true}
        end
        state = Authority.state(object)
        Authority.deployed(source)
    end
    W.clearBuildRefund(object)
    source:getModData().OMHTTDeployed = true
    object:setName(getText("UI_OMHTT_TurretBase"))
    object:setMaxHealth(state.maxHealth)
    object:setHealth(state.condition)
    state.baseFacing = state.facing
    state.facingDegrees, state.facingPending = nil, nil
    state.aimDegrees = state.baseFacing * 22.5
    object:setBlockAllTheSquare(true)
    object:setCanPassThrough(true)
    object:setIsThumpable(true)
    local container = ItemContainer.new(T.CONTAINER, object:getSquare(), object)
    T.configure(container)
    object:setContainer(container)
    require("OMHTT/ControlWorld").turret(object, player, source)
    T.moveContents(source:getInventory(), container)
    if source:getContainer() then
        local sourceContainer = source:getContainer()
        player:removeFromHands(source)
        sourceContainer:Remove(source)
        if isServer() then
            sendRemoveItemFromContainer(sourceContainer, source)
        end
    end
    W.refresh(object)
    if isServer() then
        Authority.publish(object, false)
    end
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
    if object:getHealth() >= object:getMaxHealth()
        or not require("OMHTT/ControlRepair").consume(player, "Turret") then return false end
    object:setHealth(object:getMaxHealth())
    local state = T.state(object)
    state.condition = object:getHealth()
    state.revision = state.revision + 1
    W.refresh(object)
    if isServer() then
        object:sync()
        Authority.publish(object)
    end
    D.emit("turret-repaired", {id = id, health = state.condition})
    return true
end

---@param player IsoPlayer Operator
---@param object IsoThumpable Device
---@param id string Expected identity
---@return boolean applied
function W.pickup(player, object, id)
    if not W.near(player, object) or T.state(object).id ~= id then return false end
    if not require("OMHTT/ControlAccess").near(player, object) then return false end
    local item = instanceItem(T.BASE)
    if not item then return false end
    local state = T.state(object)
    if state.depthPolicy ~= "cube-depth-v2" then
        object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_MODIFY)
        state.depthPolicy = "cube-depth-v2"
    end
    state.condition = object:getHealth()
    local copied = {}
    for key, value in pairs(state) do copied[key] = value end
    copied.rotaryManual, copied.rotaryMoving, copied.lureRepeat = nil, false, false
    item:getModData().OMHTTTurret = copied
    item:setCondition(math.max(1, math.floor(state.condition / state.maxHealth * item:getConditionMax())))
    T.configure(item:getInventory())
    local contents = object:getContainer()
    local weight = item:getActualWeight() + T.contents(contents).weight
    item:setActualWeight(weight)
    local room = player:getInventory():hasRoomFor(player, item)
    item:setActualWeight(instanceItem(T.BASE):getActualWeight())
    if not room then forceDropHeavyItems(player) end
    if player:getInventory():AddItem(item) ~= item then return false end
    state.lureRepeat = false
    local battery = T.contents(contents).battery
    if battery then
        require("OMHTT/TurretBattery").detach(battery)
    end
    T.moveContents(contents, item:getInventory())
    require("OMHTT/ControlWorld").packTurret(object, item)
    if isServer() then
        Authority.retire(object, item)
    end
    object:getModData().OMHTTTurret = nil
    object:getSquare():transmitRemoveItemFromSquare(object)
    if isServer() then
        sendAddItemToContainer(player:getInventory(), item)
    end
    if not room then
        player:setPrimaryHandItem(item)
        player:setSecondaryHandItem(item)
        if isServer() then sendEquip(player) end
    end
    D.emit("turret-picked-up", {id = id, items = item:getInventory():getItems():size(), weight = weight,
        shots = copied.shots, nextShot = copied.nextShot})
    return true
end

---@param object IsoObject Loaded object
---@return nil
function W.loaded(object)
    if instanceof(object, "IsoGenerator") then generators[object] = true end
    if isServer() then
        Authority.bind(object)
    end
    if T.state(object) and object:getContainer() then
        require("OMHTT/ControlWorld").turret(object)
        W.clearBuildRefund(object)
        object:setBlockAllTheSquare(true)
        object:setCanPassThrough(true)
        object:setIsThumpable(true)
        object:getSquare():RecalcAllWithNeighbours(true)
        T.configure(object:getContainer())
        W.refresh(object)
        if isServer() then
            Authority.publish(object, false)
        end
        D.emit("turret-restored", {id = T.state(object).id, health = object:getHealth(), items = object:getContainer():getItems():size()})
    end
end

---@param square IsoGridSquare Loaded tile
---@return nil
function W.squareLoaded(square)
    if isServer() then
        Authority.reconcile(square)
    end
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
            if G.profile(item) then require("OMHTT/FirearmFeed").drop(item, square) end
            container:Remove(item)
            square:AddWorldInventoryItem(item, 0.5, 0.5, 0)
        end
    end
    object:getModData().OMHTTTurret = nil
    if isServer() then
        Authority.retire(object)
    end
    for i = 1, 2 do
        square:AddWorldInventoryItem("Base.ScrapMetal", 0.35 + i * 0.1, 0.5, 0)
    end
    D.emit("turret-destroyed", {id = state.id, fallbackItemsDropped = remaining, scrap = 2})
end

---@param object IsoObject Turret
---@param contents table Inventory summary
---@return table? source Power transaction
---@nodiscard
---@param resolved table? Already resolved operation stats
function W.power(object, contents, resolved)
    if SandboxVars.OMHTurretsTraps.PotatoRequirePower == false then return {kind = "disabled", cost = 0} end
    local square = object:getSquare()
    local stats = resolved or T.cycleConfig(contents)
    if contents.active.Grid and square:hasGridPower() and square:getRoom() then return {kind = "grid", cost = 0} end
    if contents.active.Grid and square:haveElectricity() then
        local cost = stats.generatorFuel
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
    local cost = stats.batteryPercent / 100
    if battery and battery:getCondition() > 0 and require("OMHTT/TurretBattery").charge(battery) > 0
        and require("OMHTT/TurretBattery").charge(battery) + 0.0000001 >= cost then
        return {kind = "battery", battery = battery, cost = cost}
    end
    return require("OMHTT/ControlPower").fallback(object, cost)
end

---@param player IsoPlayer Operator
---@param object IsoThumpable Exact turret
---@param target IsoZombie? Detected target for autonomous shot
---@return string result
function W.fire(player, object, target, signal)
    if isClient() then return "Unavailable" end
    local started = getTimestampMs()
    if not player and not require("OMHTT/ControlCycle").canFire(object) then return "Off" end
    if not T.isOn(T.state(object)) then return "Off" end
    if T.state(object).facingPending then return "Turning" end
    if player then
        if not W.near(player, object) then return "Unavailable" end
    elseif (not target and not signal) or not W.valid(object) then
        return "Unavailable"
    end
    local contents = T.contents(object:getContainer())
    if not player and SandboxVars.OMHTurretsTraps.AutomationEnabled == false then return "Unavailable" end
    local forward = not target and contents.active.Firing and (signal or not contents.active.MotionDetection)
    if not player and ((not forward and not M.detects(T.state(object), contents)) or not contents.active.Firing) then return "Unavailable" end
    if contents.heads ~= 1 or contents.head:getCondition() <= 0 then return "NoHead" end
    if require("OMHTT/TurretHeads").get(contents.head) and T.cycleConfig(contents).rotary then
        return require("OMHTT/TurretRotary").start(player, object, signal)
    end
    if not player and target and not require("OMHTT/TurretStandby").step(object, contents, target) then return "Waking" end
    if contents.ammo == 0 then return "Empty" end
    local stats = T.cycleConfig(contents)
    local cycle, status = T.cycle(contents, Clock.now(), stats)
    if status ~= "Ready" then return status end
    stats = T.cycleConfig(contents)
    local power = W.power(object, contents, stats)
    if not power then return "NoPower" end
    local state = T.state(object)
    state.ammo = contents.ammo
    if player and not target and not forward then return require("OMHTT/TurretSearch").request(player, object) end
    local Volley = require("OMHTT/TurretVolley")
    if not Volley.available(stats) then return "Unavailable" end
    local fireStarted = getTimestampMs()
    local options = {object = object, playerSource = require("OMHTT/ControlCombat").source(object), source = state.id, stats = stats, weapon = contents.head, range = stats.range, interval = stats.cooldown,
        damage = stats.damage / 100, knockdown = stats.knockdown, critChance = stats.critChance, critMultiplier = stats.critMultiplier,
        splash = stats.damage * T.option("SplashPercent", 25, 0, 100) / 10000, radius = T.option("SplashRadius", 1.5, 0, 3), managed = true,
        profile = M.profile(state, contents, player == nil, stats), target = target, forward = forward, projectileSpeed = T.option("ProjectileSpeed", 20, 5, 100)}
    if G.profile(contents.head) then
        options.projectileSpeed, options.splash, options.radius = nil, 0, 0
        options.resolve = require("OMHTT/FirearmCombat").hit
        options.weapon, options.stats, options.object = contents.head, stats, object
    end
    if stats.headKind == "Ballista" then
        options.projectileSpeed, options.splash, options.radius = 24, 0, 0
        options.projectile = "spear"
        options.resolve = require("OMHTT/TurretBallista").hit
    end
    if stats.headKind == "Lobber" or stats.headKind == "Scrapshot" then
        options.projectileSpeed, options.splash, options.radius = nil, 0, 0
        options.resolve = require("OMHTT/TurretOrdnance").launch
        if not require("OMHTT/TurretOrdnance").available(stats) then return "Unavailable" end
    end
    options.playerKind = require("OMHTT/TurretPlayerHit").kind(options)
    options.playerBudget = {}
    options.playerEvent = state.id .. ":" .. tostring(state.shots + 1)
    local descriptor = require("OMHTT/TurretFeed").descriptor(contents, cycle)
    if descriptor then
        options.ammoDescriptor = descriptor
        options.damage = options.damage * descriptor.multiplier
    end
    ---@param selected IsoZombie Chosen target
    ---@return boolean aligned
    function options.align(selected)
        return require("OMHTT/TurretAim").request(object, selected, player)
    end
    ---@return boolean committed
    function options.commit()
        if not W.valid(object) or not T.isOn(T.state(object)) or not object:getContainer():contains(contents.head) then return false end
        if not G.profile(contents.head) and not cycle.virtual and not object:getContainer():contains(contents.round) then return false end
        if player and not W.near(player, object) then return false end
        if not player and ((not forward and not M.detects(state, contents)) or not contents.active.Firing) then return false end
        if not player and contents.active.FiringImprovised
            and ZombRand(10000) < M.option("ImprovisedFiringFailure", 15, 0, 100) * 100 then
            cycle.nextShot, cycle.cooldownDuration = Clock.now() + stats.cooldown, stats.cooldown
            options.failure = "Misfire"
            local square = object:getSquare()
            local sound = "OMHTTTriggerClick"
            if G.profile(contents.head) then
                local nativeSound = contents.head:getClickSound()
                if nativeSound and nativeSound ~= "" then sound = nativeSound end
            end
            require("OMHTT/DefenseEffects").emit("Click", {sound = sound,
                x = square:getX() + .5, y = square:getY() + .5, z = square:getZ()})
            return false
        end
        power = W.power(object, contents, stats)
        if not power then return false end
        options.ammoCost = math.min(cycle.loaded, 1 + stats.splitter)
        options.impactReady = cycle.impactReady == true
        local committed, charged = require("OMHTT/TurretFeed").consume(contents, stats, cycle, Clock.now())
        if not committed then return false end
        options.ammoCost = charged
        if power.kind == "battery" then
            local spent = require("OMHTT/TurretBattery").spend(power.battery, power.cost)
            options.siphon = require("OMHTT/TurretSiphon").capture(object, power, stats, spent)
        elseif power.kind == "controller" then
            require("OMHTT/ControlPower").spend(power)
        elseif power.kind == "generator" then
            power.generator:setFuel(math.max(0, power.generator:getFuel() - power.cost))
            require("OMHTT/TurretPowerSync").changed(power.generator)
        end
        D.defer("turret-resource-spent", {id = state.id, head = contents.head:getID(), power = power.kind, cost = power.cost})
        return true
    end
    local Combat = require("OMHTT/PrototypeCombat")
    local result, impact
    if forward then
        result, impact = require("OMHTT/TurretForward").fire(state, object, player, options)
    else
        result, impact = Combat.fire(state, object, player, options)
    end
    if result == "Fired" then
        if stats.headKind == "Lobber" or stats.headKind == "Scrapshot" then
            Volley.done(options)
        else
            Volley.split(state, object:getSquare(), target, player, options, impact)
        end
    end
    local committedAt = getTimestampMs()
    if result == "Fired" then
        if isServer() then
            require("OMHTT/TurretItemState").publish(contents.head, player)
            W.queueRefresh(object, false)
        elseif not T.hybrid() then
            W.refresh(object)
        end
    end
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
            local radius = require("OMHTT/TurretStats").hearingRadius(contents.head, stats)
            require("OMHTT/DefenseHorde").sound(object, square:getX(), square:getY(), square:getZ(), radius, 10)
            D.defer("turret-hearing", {id = state.id, radius = radius, suppressed = stats.suppressed})
        end
        local command = "Launch"
        if impact.firearm then command = "GunShot" end
        require("OMHTT/DefenseEffects").emit(command, impact)
    end
    local effectsAt = getTimestampMs()
    D.defer("turret-fire-result", {id = state.id, result = result, ammo = state.ammo, power = power.kind, automatic = player == nil,
        loaded = cycle.loaded, reloadReady = cycle.reloadReady, nextShot = cycle.nextShot, fireMs = effectsAt - started,
        prepareMs = fireStarted - started, combatMs = committedAt - fireStarted,
        refreshMs = refreshedAt - committedAt, effectsMs = effectsAt - refreshedAt})
    if result == "Fired" or result == "Misfire" then
        require("OMHTT/ControlCycle").fired(object)
    end
    return result
end

---@return nil
function W.feedTick()
    if isClient() then return end
    local now = Clock.now()
    local deadline = Budget.limit(1)
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
                    if W.valid(object) and T.isOn(state) and W.power(object, contents, stats) then
                        if state.facingPending then
                            require("OMHTT/TurretAim").face(object, contents)
                        end
                        local cycle, status
                        if G.profile(contents.head) then
                            cycle, status = require("OMHTT/TurretFeed").update(contents, stats, now, true)
                        else
                            cycle, status = T.cycle(contents, now, stats)
                        end
                        Audio.update(object, contents.head, cycle, status, stats, now)
                        if isServer() and (state.feedStatus ~= status or state.feedLoaded ~= cycle.loaded) then
                            cycle.status = status
                            state.feedLoaded = cycle.loaded
                            require("OMHTT/TurretItemState").publish(contents.head)
                        end
                        if state.feedStatus ~= status then
                            D.defer("turret-cycle", {id = state.id, head = contents.head:getFullType(), status = status})
                            state.feedStatus = status
                        end
                    else
                        Audio.stop(object)
                        if G.profile(contents.head) then G.cancelLoading(contents.head) end
                    end
                    require("OMHTT/TurretLure").update(object, contents, now)
                    W.publishRuntime(object, state, contents, now)
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

Budget.register("W.feedTick", W.feedTick)
Events.LoadGridsquare.Add(W.squareLoaded)
Events.OnObjectAdded.Add(W.loaded)
Events.OnObjectAboutToBeRemoved.Add(W.removed)
Events.OnDestroyIsoThumpable.Add(W.removed)
return W
