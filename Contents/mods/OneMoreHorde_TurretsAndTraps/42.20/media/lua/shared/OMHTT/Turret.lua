local F = require("OMHTT/Foundation")
local D = require("OMHTT/Diagnostics")
local Cycle = require("OMHTT/TurretCycle")
OMHTT_Turret = {}
local T = OMHTT_Turret
T.BASE = "Base.OMHTTTurretBase"
T.HEAD = "Base.OMHTTPotatoHead"
T.CONTAINER = "OMHTTTurret"
T.MODULES = {Firing = true, MotionDetection = true, Filter = true, RapidFire = true, Velocity = true,
    Range = true, Capacity = true, Detection360 = true, Reload = true, Autoloader = true}

---@param key string Setting suffix
---@param fallback number Default value
---@param minimum number Lower bound
---@param maximum number Upper bound
---@return number value
---@nodiscard
function T.option(key, fallback, minimum, maximum)
    local options = SandboxVars.OMHTurretsTraps
    local value = options and options["Potato" .. key]
    if type(value) ~= "number" or value ~= value then return fallback end
    return math.max(minimum, math.min(maximum, value))
end

---@return boolean enabled
---@nodiscard
function T.enabled()
    local options = SandboxVars.OMHTurretsTraps
    return options ~= nil and options.Enabled ~= false and options.PotatoTurret ~= false
end

---@return boolean enabled Native opaque world pass, no loose head object
---@nodiscard
function T.hybrid()
    return not isClient() and not isServer() and getCore():isOption3DGroundItem()
end

---@return table config Shared cycle tuning
---@nodiscard
function T.cycleConfig()
    return {magazine = T.option("MagazineCapacity", 1, 1, 500),
        reload = T.option("ReloadTime", 1, 0, 60) * 1000,
        cooldown = T.option("Cooldown", 0.5, 0.1, 60) * 1000}
end

---@param contents table Native inventory summary
---@param now number Real-time milliseconds
---@return table? state Persisted on the exact head item
---@return string status
function T.cycle(contents, now)
    if not contents.head then return nil, "NoHead" end
    local data = contents.head:getModData()
    if not data.OMHTTCycle then data.OMHTTCycle = {schema = 1, loaded = 0, nextShot = 0} end
    local state = data.OMHTTCycle
    return state, Cycle.update(state, contents.ammo, T.cycleConfig(), now)
end

---@param item InventoryItem Candidate
---@return string? kind
---@nodiscard
function T.kind(item)
    local fullType = item:getFullType()
    if fullType == T.HEAD then return "head" end
    if fullType == "Base.Potato" then return "ammo" end
    if fullType == "Base.CarBattery1" or fullType == "Base.CarBattery2" or fullType == "Base.CarBattery3" then return "battery" end
    local module = string.match(fullType, "^Base%.OMHTTModule(.+)$")
    if module and T.MODULES[module] then return "module" end
    return nil
end

---@param container ItemContainer Storage
---@return table summary Actual inventory contents
---@nodiscard
function T.contents(container)
    local result = {ammo = 0, modules = 0, heads = 0, batteries = 0, invalid = 0, moduleNames = {}, weight = 0}
    local items = container:getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local kind = T.kind(item)
        result.weight = result.weight + item:getActualWeight()
        if kind == "ammo" then
            result.ammo = result.ammo + 1
            if not result.round then result.round = item end
        elseif kind == "head" then
            result.heads = result.heads + 1
            result.head = item
        elseif kind == "battery" then
            result.batteries = result.batteries + 1
            result.battery = item
        elseif kind == "module" then
            result.modules = result.modules + 1
            result.moduleNames[#result.moduleNames + 1] = item:getDisplayName()
        else
            result.invalid = result.invalid + 1
        end
    end
    return result
end

---@param container ItemContainer Candidate storage
---@return boolean owned
---@nodiscard
function T.isContainer(container)
    return container ~= nil and (container:getType() == T.CONTAINER
        or (container:getContainingItem() ~= nil and container:getContainingItem():getFullType() == T.BASE))
end

---@param container ItemContainer Destination
---@param item InventoryItem Candidate
---@return boolean allowed
---@nodiscard
function T.accept(container, item)
    if isClient() or isServer() or not T.enabled() then return false end
    local kind = T.kind(item)
    if not kind then return false end
    if container:contains(item) then return true end
    local contents = T.contents(container)
    if kind == "head" then return contents.heads == 0 end
    if kind == "battery" then return contents.batteries == 0 end
    if kind == "ammo" then return contents.heads == 1 and contents.ammo < T.option("AmmoCapacity", 85, 1, 500) end
    return contents.modules < T.option("ModuleCapacity", 4, 0, 20)
end

---@param container ItemContainer Source
---@param item InventoryItem Candidate removal
---@return boolean allowed
---@nodiscard
function T.canRemove(container, item)
    return not T.isContainer(container) or T.kind(item) ~= "head" or T.contents(container).ammo == 0
end

---@param container ItemContainer Owned storage
---@return nil
function T.configure(container)
    container:setType(T.CONTAINER)
    local capacity = math.ceil(9 + T.option("AmmoCapacity", 85, 1, 500) * 0.2 + T.option("ModuleCapacity", 4, 0, 20) * 0.3)
    container:setCapacity(capacity)
    if container:getContainingItem() then container:getContainingItem():setCapacity(capacity) end
    container:setAcceptItemFunction("OMHTT_Turret.accept")
    container:setExplored(true)
end

---@param source ItemContainer Source storage
---@param destination ItemContainer Destination storage
---@return nil
function T.moveContents(source, destination)
    local items = source:getItems()
    for i = items:size() - 1, 0, -1 do
        local item = items:get(i)
        source:Remove(item)
        destination:AddItem(item)
    end
end

---@param facing number Heading index
---@param hasHead boolean Head installed
---@return string sprite Persistent tile identity
---@nodiscard
function T.sprite(facing, hasHead)
    local index = 44 + math.floor(F.normalizeFacing(facing) / 4)
    if hasHead then index = 28 + F.normalizeFacing(facing) end
    return "omhtt_barrier_01_" .. index
end

---@param object IsoObject World device
---@return table? state
---@nodiscard
function T.state(object)
    if not object or not object:hasModData() then return nil end
    local state = object:getModData().OMHTTTurret
    if type(state) ~= "table" or state.schema ~= 1 then return nil end
    return state
end

---@param params table Recipe menu parameters
---@return boolean available
---@nodiscard
function OMHTT_TurretMenuAvailable(params)
    return not isClient() and not isServer() and T.enabled()
end

---@param item InventoryItem Input candidate
---@param player IsoPlayer Crafter
---@return boolean allowed
---@nodiscard
function T.recipeInput(item, player)
    return not isClient() and not isServer() and T.enabled()
end

---@param data CraftRecipeData Completed craft
---@param player IsoPlayer Crafter
---@return nil
function T.onCrafted(data, player)
    local item = data:getFirstCreatedItem()
    if not item then return end
    if item:getFullType() == T.BASE then
        T.configure(item:getInventory())
        local health = T.option("Health", 100, 1, 10000)
        item:getModData().OMHTTTurret = {schema = 1, kind = "potato", facing = 0, shots = 0, nextShot = 0,
            condition = health, maxHealth = health, revision = 1}
        if string.find(data:getRecipe():getName(), "Complete", 1, true) then
            item:getInventory():AddItem(T.HEAD)
        end
    end
    D.emit("turret-crafted", {recipe = data:getRecipe():getName(), item = item:getFullType(), itemId = item:getID()})
end

---@param container ItemContainer Contents
---@param baseWeight number Empty base weight
---@return string description Compact tooltip
---@nodiscard
function T.description(container, baseWeight)
    local contents = T.contents(container)
    local head = getText("UI_OMHTT_NoHead")
    if contents.head then head = contents.head:getDisplayName() end
    local charge = getText("UI_OMHTT_NoBattery")
    if contents.battery then charge = tostring(math.floor(contents.battery:getCurrentUsesFloat() * 100)) .. "%" end
    local modules = getText("UI_OMHTT_None")
    if #contents.moduleNames > 0 then modules = table.concat(contents.moduleNames, ", ") end
    return getText("UI_OMHTT_TurretContents", head, tostring(contents.ammo), charge, modules)
        .. "\n" .. getText("UI_OMHTT_TotalWeight", string.format("%.2f", baseWeight + contents.weight))
end

return T
