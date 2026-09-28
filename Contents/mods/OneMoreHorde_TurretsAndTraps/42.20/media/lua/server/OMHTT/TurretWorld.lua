if isClient() then return end
local T = require("OMHTT/Turret")
local F = require("OMHTT/Foundation")
local D = require("OMHTT/Diagnostics")
OMHTT_TurretWorld = {}
local W = OMHTT_TurretWorld
local facings = {e = 0, n = 4, w = 8, s = 12}
local generators = {}

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
    return dx * dx + dy * dy <= 4 and require("OMHTT/PrototypeCombat").clearLane(origin, square, 2)
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
    local state = T.state(object)
    if not state or not object:getContainer() then return end
    local contents = T.contents(object:getContainer())
    local sprite = T.sprite(state.facing, contents.head ~= nil)
    if object:getSpriteName() ~= sprite then
        object:setSprite(sprite)
        object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_OBJECT_MODIFY)
    end
    local config = object:getSpriteConfig()
    if not config or not config:isValid() or config:getTileInfo():getSpriteName() ~= sprite then
        local entity = "OMHTTDeployTurret"
        if contents.head then entity = "OMHTTPotatoVisual" .. math.floor(F.normalizeFacing(state.facing) / 4) end
        local info = SpriteConfigManager.GetObjectInfo(entity)
        if not info then error("[OMHTT] Missing turret visual entity " .. entity) end
        if config then GameEntityFactory.RemoveComponentType(object, ComponentType.SpriteConfig) end
        GameEntityFactory.AddComponent(object, ComponentType.SpriteConfig:CreateComponentFromScript(info:getScript()))
        if not object:getSpriteConfig():isValid() then error("[OMHTT] Invalid turret sprite " .. sprite) end
    end
    state.condition = object:getHealth()
end

---@param params table Native construction callback
---@return nil
function W.onCreate(params)
    if isClient() or isServer() then return end
    local object, player, data = params.thumpable, params.character, params.craftRecipeData
    if T.state(object) then return end
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
    source:getModData().OMHTTDeployed = true
    object:setName(getText("UI_OMHTT_TurretBase"))
    object:setMaxHealth(state.maxHealth)
    object:setHealth(state.condition)
    object:setBlockAllTheSquare(false)
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
---@param object IsoThumpable Device
---@param id string Expected identity
---@return boolean applied
function W.pickup(player, object, id)
    if not W.near(player, object) or T.state(object).id ~= id then return false end
    local item = instanceItem(T.BASE)
    local state = T.state(object)
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
    generators[object] = nil
    if not T.state(object) or not object:getContainer() then return end
    local square = object:getSquare()
    if not square then return end
    local items = object:getContainer():getItems()
    for i = items:size() - 1, 0, -1 do
        local item = items:get(i)
        object:getContainer():Remove(item)
        square:AddWorldInventoryItem(item, 0.5, 0.5, 0)
    end
    D.emit("turret-destroyed", {id = T.state(object).id, contentsDropped = true})
    object:getModData().OMHTTTurret = nil
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
---@return string result
function W.fire(player, object)
    if not W.near(player, object) then return "Unavailable" end
    local contents = T.contents(object:getContainer())
    if contents.heads ~= 1 or contents.head:getCondition() <= 0 then return "NoHead" end
    if contents.ammo == 0 then return "Empty" end
    local power = W.power(object, contents)
    if not power then return "NoPower" end
    local state = T.state(object)
    state.ammo = contents.ammo
    local options = {range = T.option("Range", 6, 1, 20), interval = T.option("Cooldown", 1, 0.1, 60) * 1000,
        damage = T.option("Damage", 50, 0, 1000) / 100, knockdown = T.option("KnockdownChance", 70, 0, 100),
        splash = T.option("SplashDamage", 0.1, 0, 100) / 100, radius = T.option("SplashRadius", 1.1, 0, 3), managed = true}
    ---@return boolean committed
    function options.commit()
        if not W.near(player, object) or not object:getContainer():contains(contents.round) then return false end
        if power.kind == "battery" then
            power.battery:setCurrentUsesFloat(math.max(0, power.battery:getCurrentUsesFloat() - power.cost))
        elseif power.kind == "generator" then
            power.generator:setFuel(math.max(0, power.generator:getFuel() - power.cost))
        end
        object:getContainer():Remove(contents.round)
        D.emit("turret-resource-spent", {id = state.id, ammoItem = contents.round:getID(), power = power.kind, cost = power.cost})
        return true
    end
    local Combat = require("OMHTT/PrototypeCombat")
    local result, impact = Combat.fire(state, object, player, options)
    W.refresh(object)
    if impact then triggerEvent("OnServerCommand", F.MODULE, "Impact", impact) end
    D.emit("turret-fire-result", {id = state.id, result = result, ammo = T.contents(object:getContainer()).ammo, power = power.kind})
    return result
end

Events.LoadGridsquare.Add(W.squareLoaded)
Events.OnObjectAdded.Add(W.loaded)
Events.OnObjectAboutToBeRemoved.Add(W.removed)
return W
