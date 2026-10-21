local H = require("OMHTT/HybridBuild")
local P = require("OMHTT/BarrierPlacement")
local oldScript, oldHandcraft, oldAction = ScriptManager, HandcraftLogic, ISHandcraftAction
local oldMenu, oldQueue, oldInfo = ISInventoryPaneContextMenu, ISTimedActionQueue, SpriteConfigManager
local oldCarried, oldPlace = P.carried, H.place
local recipes, inventory, queue = {}, {items = {}}, {}
local player = {getInventory = function() return inventory end, isDead = function() return false end,
    setHaloNote = function(self, text) self.halo = text end}
function inventory:getFirstTypeEvalArgRecurse(kind, predicate, arg)
    for i = 1, #self.items do
        local item = self.items[i]
        if item:getFullType() == kind and predicate(item, arg) then return item end
    end
end
local function item(kind)
    return {getFullType = function() return kind end, getContainer = function() return inventory end}
end
P.carried = function(value) return value.valid ~= false and {} or nil end
local selected, placed, crafted, affordable = nil, nil, 0, true
H.place = function(_, _, value) placed = value; return {item = value} end
local function recipe(name)
    return {overrideTranslationName = function() end, getName = function() return name end, getOnAddToMenu = function() return nil end,
        isCanBeDoneFromFloor = function() return true end}
end
for i = 1, #H.definitions do
    local definition = H.definitions[i]
    recipes["Base." .. definition.craft] = recipe(definition.craft)
    recipes["Base." .. definition.deploy] = recipe(definition.deploy)
end
ScriptManager = {instance = {getCraftRecipe = function(_, name) return recipes[name] end}}
HandcraftLogic = {new = function()
    return {setContainers = function() end, setRecipe = function(self, value) self.recipe = value end,
        getRecipe = function(self) return self.recipe end,
        canPerformCurrentRecipe = function() return affordable end,
        setManualSelectInputs = function(self, value) self.manual = value end,
        clearManualInputs = function() end, offerInputItem = function() end,
        getRecipeData = function() return {getAllInputItems = function() return ArrayList.new() end} end}
end}
ISInventoryPaneContextMenu = {getContainers = function() return ArrayList.new() end}
ISTimedActionQueue = {add = function(action) queue[#queue + 1] = action end}
ISHandcraftAction = {FromLogic = function(logic)
    check(logic.manual == true, "Native action receives exact manual inputs rather than the unsupported false table")
    local action = {character = player, logic = logic, isValid = function() return true end, stop = function() end}
    action.perform = function(self)
        if not affordable then return end
        crafted = crafted + 1
        self.output = item(H.definition(logic.recipe).item)
        inventory.items[#inventory.items + 1] = self.output
    end
    logic.getRecipeData = function() return {getAllCreatedItems = function()
        local list = ArrayList.new(); if action.output then list:add(action.output) end; return list
    end} end
    return action
end}
local panel = {player = player}
local definition = H.definitions[1]
local carried = item(definition.item)
inventory.items = {carried}
affordable = false
check(H.start(panel, definition) and placed == carried and #queue == 0,
    "Building prefers the exact carried defense without requiring crafting skill/materials")
inventory.items, placed = {}, nil
check(not H.start(panel, definition) and #queue == 0 and player.halo, "Missing requirements cannot produce or place a free defense")
affordable = true
check(H.start(panel, definition) and #queue == 1 and not placed, "Fallback queues the original recipe before placement")
check(not H.start(panel, definition) and #queue == 1, "Repeated Building clicks cannot queue duplicate crafts")
local action = queue[1]
action:perform(); action:perform()
check(crafted == 1 and placed == action.output and inventory.items[1] == placed,
    "Completion uses the exact real output once; placement cancellation leaves that item")
inventory.items, placed = {}, nil
H.start(panel, definition)
queue[2]:stop()
check(not panel.omhttAction and not placed and crafted == 1, "Interrupted crafting never starts placement")
H.start(panel, definition)
panel.omhttClosed = true
queue[3]:perform()
check(crafted == 2 and not placed and #inventory.items == 1, "Closing Building suppresses automatic placement but retains completed output")
inventory.items, panel.omhttClosed = {}, false
H.start(panel, definition)
affordable = false
queue[4]:perform()
check(crafted == 2 and not placed and not panel.omhttAction, "Materials disappearing before completion cannot place an uncreated output")
affordable = true
local native = recipe("VanillaChair")
local hidden = recipe("OMHTTOldPrototype")
local source = ArrayList.new(); source:add(native); source:add(hidden)
SpriteConfigManager = {GetObjectInfo = function(name)
    return {getRecipe = function() return {getCraftRecipe = function() return recipes["Base." .. name] end} end}
end}
panel.logic = {getRecipe = function() return selected end, getAllBuildableRecipes = function() return source end,
    setRecipes = function(self, list) self.list = list end, getLastSelectedRecipe = function() return native end}
panel.ReselectRecipeOrFirst = function(_, value) selected = value end
setmetatable(panel, {__index = ISBuildPanel})
panel:refreshList()
check(panel.logic.list:size() == 16 and panel.logic.list:get(0) == native,
    "Building keeps vanilla entries and exactly one route per defense, excluding old prototypes and packs")
selected = recipes["Base." .. definition.craft]
inventory.items = {carried}
panel:refreshList()
check(selected == recipes["Base." .. definition.deploy], "Inventory changes switch the same selected defense to existing-item requirements")
inventory.items = {}
recipes["Base.OMHTTCraftTurretBase"] = nil
panel:refreshList()
check(panel.logic.list:size() == 15, "Absent Turrets content is omitted without loading its placement module")
local before = #queue
panel:createBuildIsoEntity(true)
check(#queue == before, "Passive native refresh never starts crafting")
local priorMode, priorClock, fromLogic = testMode, getTimestampMs, ISHandcraftAction.FromLogic
local now, nativeCompletions = 1000, 0
local buildLogic = panel.logic
panel.logic = nil
testMode = "client"
getTimestampMs = function() return now end
ISHandcraftAction.FromLogic = function(logic)
    return {character = player, logic = logic, isValid = function() return true end,
        stop = function() end, perform = function() nativeCompletions = nativeCompletions + 1 end}
end
inventory.items, placed = {}, nil
check(H.start(panel, definition), "MP Building queues the original native craft action")
local networkCraft = queue[#queue]
networkCraft:perform(); networkCraft:perform()
check(nativeCompletions == 1 and panel.omhttPending and not placed,
    "Client completion neither crafts locally nor reads server-only created items")
check(not H.start(panel, definition), "Pending server output prevents a duplicate craft")
inventory.items = {carried}
now = now + 150
H.poll(panel)
check(not placed, "Unchanged inventory generation does not trigger another recursive search")
H.generation = H.generation + 1
now = now + 150
H.poll(panel)
check(placed == carried and not panel.omhttPending, "Replicated output unlocks exact carried-item placement")
local resolved = placed
H.poll(panel)
check(placed == resolved and nativeCompletions == 1, "Repeated panel updates cannot duplicate completion")
inventory.items, placed = {}, nil
local cancelled = 0
H.awaitInventory(panel, definition, nil, nil, function() cancelled = cancelled + 1 end)
panel.omhttClosed = true
H.poll(panel)
inventory.items = {carried}
now = now + 200
H.generation = H.generation + 1
H.poll(panel)
check(not placed and not panel.omhttPending and cancelled == 1,
    "Closing during replication cancels follow-up without consuming the received item")
panel.omhttClosed, inventory.items = false, {}
H.awaitInventory(panel, definition, nil, nil, function() cancelled = cancelled + 1 end)
now = now + 10001
H.poll(panel)
check(not placed and not panel.omhttPending and cancelled == 2,
    "Missing or ground-dropped output times out without inventing items or repeating the recipe")
local oldItem = H.item
panel.logic = buildLogic
H.item = function() return nil end
panel:refreshList()
local function countRecipe(name)
    local count = 0
    for i = 0, panel.logic.list:size() - 1 do
        if panel.logic.list:get(i):getName() == name then count = count + 1 end
    end
    return count
end
check(countRecipe("OMHTTCraftPoke") == 1 and countRecipe("OMHTTCraftPokeImprovised") == 1,
    "Building exposes both distinct mechanical crafting routes")
H.item = function(_, route)
    if route.item == "Base.OMHTTTrapPokeFloor" then return {carried = true} end
end
selected = recipes["Base.OMHTTCraftPokeImprovised"]
panel:refreshList()
check(countRecipe("OMHTTDeployPoke") == 1 and countRecipe("OMHTTCraftPokeImprovised") == 0
    and countRecipe("OMHTTCraftPoke") == 0, "Carried Poke replaces both craft rows with one deployment")
check(selected == recipes["Base.OMHTTDeployPoke"], "Improvised selection follows the shared exact-item deployment")
H.item = oldItem
testMode, getTimestampMs, ISHandcraftAction.FromLogic = priorMode, priorClock, fromLogic
P.carried, H.place = oldCarried, oldPlace
ScriptManager, HandcraftLogic, ISHandcraftAction = oldScript, oldHandcraft, oldAction
ISInventoryPaneContextMenu, ISTimedActionQueue, SpriteConfigManager = oldMenu, oldQueue, oldInfo
