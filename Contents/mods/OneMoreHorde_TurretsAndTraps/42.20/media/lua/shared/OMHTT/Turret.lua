local F = require("OMHTT/Foundation")
local D = require("OMHTT/Diagnostics")
local Cycle = require("OMHTT/TurretCycle")
local Stats = require("OMHTT/TurretStats")
OMHTT_Turret = {}
local T = OMHTT_Turret
T.BASE = "Base.OMHTTTurretBase"
T.HEAD = "Base.OMHTTPotatoHead"
T.HEAD_VISUAL = {height = 0.4 - 16 / 192, scale = 0.512, muzzle = 0.55}
T.CONTAINER = "OMHTTTurret"
T.MODULES = {Firing = true, MotionDetection = true, Filter = true, RapidFire = true, Velocity = true,
    Range = true, Capacity = true, CapacitySmall = true, CapacityLarge = true, Detection360 = true, Reload = true, Autoloader = true}
T.TYPES = {}
T.COMPONENTS = {}
local itemTypes = {CapacitySmall = "OMHTTExpansionKitSmall", Capacity = "OMHTTExpansionKitMedium",
    CapacityLarge = "OMHTTExpansionKitLarge", MotionDetection = "OMHTTModuleDetection", Detection360 = "OMHTTModule360"}
for name in pairs(T.MODULES) do
    local fullType = "Base." .. (itemTypes[name] or "OMHTTModule" .. name)
    T.TYPES[name], T.COMPONENTS[fullType] = fullType, name
end

---@param fullType string Locale-independent item type
---@return string? component Stable behavior key
---@nodiscard
function T.component(fullType)
    return T.COMPONENTS[fullType]
end

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

---@param contents table? Native inventory summary
---@return table config Effective cycle and stat tuning
---@nodiscard
function T.cycleConfig(contents)
    return Stats.resolve(contents)
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
    return state, Cycle.update(state, contents.ammo, T.cycleConfig(contents), now)
end

---@param item InventoryItem Candidate
---@return string? kind
---@nodiscard
function T.kind(item)
    local fullType = item:getFullType()
    if fullType == T.HEAD then return "head" end
    if fullType == "Base.Potato" then return "ammo" end
    if fullType == "Base.CarBattery1" or fullType == "Base.CarBattery2" or fullType == "Base.CarBattery3" then return "battery" end
    local module = T.component(fullType)
    if module == "Capacity" or module == "CapacitySmall" or module == "CapacityLarge" then return "capacity" end
    if module and T.MODULES[module] then return "module" end
    return nil
end

---@param container ItemContainer Storage
---@return table summary Actual inventory contents
---@nodiscard
function T.contents(container)
    local result = {ammo = 0, modules = 0, capacities = 0, heads = 0, batteries = 0, invalid = 0, moduleNames = {}, active = {}, weight = 0}
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
        elseif kind == "module" or kind == "capacity" then
            if kind == "capacity" then
                result.capacities = result.capacities + 1
            else
                result.modules = result.modules + 1
            end
            result.moduleNames[#result.moduleNames + 1] = item:getDisplayName()
            if item:getCondition() > 0 then
                local name = T.component(item:getFullType())
                result.active[name] = (result.active[name] or 0) + 1
            end
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
    if kind == "capacity" then return contents.capacities == 0 end
    local stats = Stats.resolve(contents)
    if kind == "ammo" then return contents.heads == 1 and contents.ammo < stats.ammo end
    return contents.modules < stats.modules
end

---@param container ItemContainer Source
---@param item InventoryItem Candidate removal
---@return boolean allowed
---@nodiscard
function T.canRemove(container, item)
    if not T.isContainer(container) then return true end
    local contents = T.contents(container)
    if T.kind(item) == "head" then return contents.ammo == 0 end
    if T.kind(item) == "capacity" and item:getCondition() > 0 then
        contents.active.Capacity, contents.active.CapacitySmall, contents.active.CapacityLarge = nil, nil, nil
        if contents.capacities > 1 then
            local items = container:getItems()
            for i = 0, items:size() - 1 do
                local other = items:get(i)
                if other ~= item and T.kind(other) == "capacity" and other:getCondition() > 0 then
                    local name = T.component(other:getFullType())
                    contents.active[name] = 1
                end
            end
        end
        local stats = Stats.resolve(contents)
        return contents.ammo <= stats.ammo and contents.modules <= stats.modules
    end
    return true
end

---@param container ItemContainer Owned storage
---@return nil
function T.configure(container)
    container:setType(T.CONTAINER)
    local stats = Stats.resolve({active = {Capacity = 1, CapacitySmall = 1, CapacityLarge = 1}})
    local capacity = math.ceil(10 + stats.ammo * 0.2 + (stats.modules + 1) * 0.3)
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
    if contents.battery then charge = getText("UI_OMHTT_ChargePercent", tostring(math.floor(contents.battery:getCurrentUsesFloat() * 100))) end
    local modules = getText("UI_OMHTT_None")
    if #contents.moduleNames > 0 then modules = table.concat(contents.moduleNames, ", ") end
    return getText("UI_OMHTT_TurretContents", head, tostring(contents.ammo), charge, modules)
        .. "\n" .. getText("UI_OMHTT_TotalWeight", string.format("%.2f", baseWeight + contents.weight))
end

return T
