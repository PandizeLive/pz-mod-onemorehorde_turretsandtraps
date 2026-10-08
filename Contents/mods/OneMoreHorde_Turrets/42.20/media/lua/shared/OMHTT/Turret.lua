local F = require("OMHTT/Foundation")
F.turretsAvailable = true
local D = require("OMHTT/Diagnostics")
local Cycle = require("OMHTT/TurretCycle")
local Stats = require("OMHTT/TurretStats")
local G = require("OMHTT/Firearms")
OMHTT_Turret = {}
local T = OMHTT_Turret
T.BASE = "Base.OMHTTTurretBase"
T.HEAD = "Base.OMHTTPotatoHead"
T.HEAD_VISUAL = {height = 0.4 - 16 / 192, scale = 0.512, muzzle = 0.55}
T.CONTAINER = "OMHTTTurret"
T.MODULES = {FiringImprovised = true, MotionDetectionImprovised = true, CapacityImprovised = true, Firing = true, MotionDetection = true, Filter = true, RapidFire = true, Velocity = true,
    Range = true, Critical = true, Accuracy = true, Suppression = true, Capacity = true, CapacitySmall = true, CapacityLarge = true, Detection360 = true, Reload = true, Autoloader = true}
T.SINGLE = {Firing = true, MotionDetection = true, Filter = true, Detection360 = true, Autoloader = true}
T.TYPES = {}
T.COMPONENTS = {}
local roles = {FiringImprovised = "Firing", MotionDetectionImprovised = "MotionDetection"}
local itemTypes = {CapacityImprovised = "OMHTTExpansionKitImprovised", MotionDetectionImprovised = "OMHTTModuleDetectionImprovised", CapacitySmall = "OMHTTExpansionKitSmall", Capacity = "OMHTTExpansionKitMedium",
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

---@param fullType string Exact item type
---@return string? role Shared exclusivity key
---@nodiscard
function T.role(fullType)
    local component = T.component(fullType)
    return roles[component] or component
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
    return options ~= nil and options.TurretsEnabled ~= false
end

---@param state table? Persisted controls
---@return boolean enabled
function T.isOn(state)
    if not state then return false end
    if state.powered ~= nil then return state.powered end
    return state.automatic ~= false
end

---@return boolean enabled Native opaque world pass, no loose head object
---@nodiscard
function T.hybrid()
    return not isClient() and not isServer() and getCore():isOption3DGroundItem()
end

---@param head InventoryItem? Installed head
---@return number degreesPerSecond
---@nodiscard
function T.turnSpeed(head)
    if G.profile(head) then return Stats.option("FirearmTurnSpeed", 90, 1, 360) end
    return T.option("TurnSpeed", 90, 1, 360)
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
    if G.profile(contents.head) then return G.update(contents, T.cycleConfig(contents), now, false) end
    if SandboxVars.OMHTurretsTraps.PotatoTurret == false then return nil, "Disabled" end
    local data = contents.head:getModData()
    if not data.OMHTTCycle then data.OMHTTCycle = {schema = 1, loaded = 0, nextShot = 0} end
    local state = data.OMHTTCycle
    if data.OMHTTPowerOff then return state, "Off" end
    return state, Cycle.update(state, contents.ammo, T.cycleConfig(contents), now)
end

---@param item InventoryItem Candidate
---@return string? kind
---@nodiscard
function T.kind(item)
    local fullType = item:getFullType()
    if fullType == T.HEAD or G.profile(item) then return "head" end
    if fullType == "Base.Potato" or G.AMMO[fullType] then return "ammo" end
    if fullType == "Base.CarBattery1" or fullType == "Base.CarBattery2" or fullType == "Base.CarBattery3" then return "battery" end
    local module = T.component(fullType)
    if module == "CapacityImprovised" or module == "Capacity" or module == "CapacitySmall" or module == "CapacityLarge" then return "capacity" end
    if module and T.MODULES[module] then return "module" end
    return nil
end

---@param container ItemContainer Storage
---@return table summary Actual inventory contents
---@nodiscard
function T.contents(container)
    local result = {reserve = 0, reserveAll = 0, rounds = {}, ammo = 0, modules = 0, capacities = 0, heads = 0, batteries = 0, invalid = 0, moduleNames = {}, active = {}, moduleCounts = {}, weight = 0}
    local items = container:getItems()
    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local kind = T.kind(item)
        result.weight = result.weight + item:getActualWeight()
        if kind == "ammo" then
            result.rounds[#result.rounds + 1] = item
            result.reserveAll = result.reserveAll + 1
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
            local component = T.role(item:getFullType())
            result.moduleCounts[component] = (result.moduleCounts[component] or 0) + 1
            result.moduleNames[#result.moduleNames + 1] = item:getDisplayName()
            if item:getCondition() > 0 then
                local name = T.component(item:getFullType())
                result.active[name] = (result.active[name] or 0) + 1
                if roles[name] then
                    result.active[roles[name]] = (result.active[roles[name]] or 0) + 1
                end
            end
        else
            result.invalid = result.invalid + 1
        end
    end
    local ammoType = "Base.Potato"
    if G.profile(result.head) then ammoType = G.ammoType(result.head) end
    for i = 1, #result.rounds do
        local round = result.rounds[i]
        if round:getFullType() == ammoType then
            result.reserve = result.reserve + 1
            if not result.round then result.round = round end
        else
            result.invalid = result.invalid + 1
        end
    end
    result.ammo = result.reserve
    if G.profile(result.head) then result.ammo = result.ammo + G.loaded(result.head) end
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
    if kind == "head" then
        if contents.heads > 0 then return false end
        if G.profile(item) then
            contents.head = item
            return contents.reserveAll + G.loaded(item) <= Stats.resolve(contents).ammo
        end
        return contents.reserveAll <= Stats.resolve(contents).ammo
    end
    if kind == "battery" then return contents.batteries == 0 end
    if kind == "capacity" then return contents.capacities == 0 end
    local stats = Stats.resolve(contents)
    if kind == "ammo" then
        local ammoType = "Base.Potato"
        if G.profile(contents.head) then ammoType = G.ammoType(contents.head) end
        return contents.heads == 1 and item:getFullType() == ammoType and contents.reserveAll + (G.profile(contents.head) and G.loaded(contents.head) or 0) < stats.ammo
    end
    local component = T.role(item:getFullType())
    if T.SINGLE[component] and contents.moduleCounts[component] then return false end
    return contents.modules < stats.modules
end

---@param container ItemContainer Source
---@param item InventoryItem Candidate removal
---@return boolean allowed
---@nodiscard
function T.canRemove(container, item)
    if not T.isContainer(container) then return true end
    local contents = T.contents(container)
    if T.kind(item) == "head" then return not G.servicing[item] end
    if T.kind(item) == "capacity" and item:getCondition() > 0 then
        contents.active.CapacityImprovised = nil
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
        return contents.reserveAll + (G.profile(contents.head) and G.loaded(contents.head) or 0) <= stats.ammo and contents.modules <= stats.modules
    end
    return true
end

---@param container ItemContainer Owned storage
---@return nil
function T.configure(container)
    container:setType(T.CONTAINER)
    local stats = Stats.resolve({active = {CapacityImprovised = 1, Capacity = 1, CapacitySmall = 1, CapacityLarge = 1}})
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
    return "omhtt_turret_01_" .. (index - 28)
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
