local G = require("OMHTT/CraftingGroups")
local E = CraftRecipeListNodeExpandedState
local T = CraftRecipeListNode.CraftRecipeListNodeType
local function leaf(name, callback, category)
    local recipe = {getName = function() return name end, getTranslationName = function() return name end,
        getCategory = function() return category or "OMHTraps" end,
        getOnAddToMenu = function() return callback end}
    return {getType = function() return T.RECIPE end, getRecipe = function() return recipe end,
        getIconTexture = function() return nil end}
end
local widget = setmetatable({items = {}, player = {}}, {__index = ISRecipeScrollingListBox})
function widget:addItem(name, recipe)
    local item = {text = name, item = recipe, itemindex = #self.items + 1}
    self.items[#self.items + 1] = item
    return item
end
function widget:isCraftable(recipe) return recipe.craftable == true end
function widget:doDrawNode(y, item) item.visible = true; return y + 20 end
function widget:doDrawGroup(y, item) item.visible = true; return y + 20 end
local nodes = ArrayList.new()
local base, reinforced, pack = leaf("OMHTTCraftSpikeBarrier"), leaf("OMHTTReinforceSpikeBarrier"), leaf("OMHTTPackSpikeBarriers")
local other = leaf("OtherModsTrap")
local vanilla = {getType = function() return T.GROUP end, getTitle = function() return "Open boxes" end,
    getChildren = function() local list = ArrayList.new(); list:add(other); return list end}
nodes:add(pack); nodes:add(vanilla); nodes:add(reinforced); nodes:add(base)
local selection = widget:addGroup(nil, nodes, base:getRecipe(), false)
check(selection == 4 and #widget.items == 8 and widget.items[3].groupNode, "Native list restores selection inside the Normal group")
local group = widget.items[3].groupNode
check(group.id == "Normal" and widget.items[5].groupNode.id == "Reinforced" and widget.items[7].groupNode.id == "Packed",
    "Expandable group order is Normal, Reinforced, Packed regardless of recipe order")
check(group:getChildren():get(0):getRecipe() == base:getRecipe() and widget.items[6].item == reinforced:getRecipe(),
    "Tier groups retain exact recipes without changing their categories")
check(widget.items[1].groupNode == vanilla and widget.items[2].item == other:getRecipe(), "Vanilla groups and unrelated recipes retain exact nodes")
check(group:getExpandedState() == E.OPEN, "Selected family opens automatically")
widget:toggleGroup(group)
check(group:getExpandedState() == E.CLOSED and widget:doDrawItem(0, widget.items[4], false) == 0, "Native collapse hides child rows")
widget.selected = 3
local oldJoypad = Joypad
Joypad = {AButton = 1}
widget:onJoypadDown(1, {})
check(group:getExpandedState() == E.OPEN and widget:doDrawItem(0, widget.items[4], false) == 20, "Native controller toggle reveals rows")
Joypad = oldJoypad
base:getRecipe().craftable = true
widget:toggleGroup(group)
check(group:getExpandedState() == E.CLOSED, "Mixed craftability still collapses all variants")
widget.items = {}
widget:addGroup(nil, nodes, base:getRecipe(), false)
check(widget.items[3].groupNode:getExpandedState() == E.CLOSED, "Refresh preserves deliberate collapse with unchanged selection")
local filtered = ArrayList.new(); filtered:add(pack)
widget.items = {}; widget:addGroup(nil, filtered, nil, false)
check(#widget.items == 2 and widget.items[2].item == pack:getRecipe(), "Search/favorite filtering is not expanded back to all family recipes")
local oldBool = callLuaBool
callLuaBool = function() return false end
filtered = ArrayList.new(); filtered:add(leaf("OMHTTCraftBedSpikes", "hidden"))
widget.items = {}; widget:addGroup(nil, filtered, nil, false)
check(#widget.items == 0, "Unavailable family leaves no empty header")
callLuaBool = oldBool
local build = ArrayList.new()
local turretBase = leaf("OMHTTDeployTurret", nil, "OMHTurrets")
build:add(leaf("OMHTTDeployReinforcedBedSpikes")); build:add(turretBase); build:add(leaf("OMHTTBarbs"))
widget.items = {}; widget:addGroup(nil, build, nil, false)
check(#widget.items == 5 and widget.items[1].item == turretBase:getRecipe()
    and widget.items[2].groupNode.id == "Normal" and widget.items[4].groupNode.id == "Reinforced",
    "Building keeps turret base at root and trap tiers without empty component or Packed groups")
local turrets = ArrayList.new()
local rootNames = {"OMHTTCraftTurretBase", "OMHTTCraftTurretComplete", "OMHTTCraftTurretCompleteImprovised"}
local rootNodes = {}
for i = 1, #rootNames do
    rootNodes[i] = leaf(rootNames[i], nil, "OMHTurrets"); turrets:add(rootNodes[i])
end
local head = leaf("OMHTTCraftTurretHead", nil, "OMHTurrets")
turrets:add(head); turrets:add(leaf("OMHTTCraftTurretHeadImprovised", nil, "OMHTurrets"))
local moduleNames = {"OMHTTCraftMotionDetectionImprovised", "OMHTTCraftFiringImprovised", "OMHTTCraftCapacityImprovised"}
for i = 1, #moduleNames do turrets:add(leaf(moduleNames[i], nil, "OMHTurrets")) end
local grouped = G.nodes(widget, turrets, head:getRecipe(), false)
check(grouped:size() == 5, "Turrets has three root recipes and exactly two component groups")
for i = 1, #rootNodes do check(grouped:get(i - 1) == rootNodes[i], "Complete/base turret recipes keep exact native root nodes") end
check(grouped:get(3).id == "Heads" and grouped:get(3):getChildren():size() == 2, "Both head recipes belong to Heads")
check(grouped:get(4).id == "Modules" and grouped:get(4):getChildren():size() == 3, "Modules includes the expansion kit")
widget.items = {}; selection = widget:addGroup(nil, turrets, head:getRecipe(), false)
check(selection == 5 and #widget.items == 10 and widget.items[4].groupNode:getExpandedState() == E.OPEN,
    "Native turret list selects and expands a head without adding a Normal group")
filtered = ArrayList.new(); filtered:add(head)
widget.items = {}; widget:addGroup(nil, filtered, head:getRecipe(), false)
check(#widget.items == 2 and widget.items[1].groupNode.id == "Heads", "Filtered Heads list does not recreate root recipes or empty Modules")
callLuaBool = function() return false end
filtered = ArrayList.new(); filtered:add(leaf("OMHTTCraftTurretHead", "hidden", "OMHTurrets"))
widget.items = {}; widget:addGroup(nil, filtered, nil, false)
check(#widget.items == 0, "Hidden turret component leaves no empty header")
callLuaBool = oldBool
local future = leaf("OMHTTFutureRecipe", nil, "OMHTurrets")
filtered = ArrayList.new(); filtered:add(future)
check(G.nodes(widget, filtered, nil, false):get(0) == future, "Unclassified turret recipes remain native root nodes instead of silently acquiring a tier")
local unrelated = leaf("OMHTTUnrelatedRecipe", nil, "OtherCategory")
filtered = ArrayList.new(); filtered:add(unrelated)
check(G.nodes(widget, filtered, nil, false):get(0) == unrelated, "Namespace alone cannot assign unrelated categories to trap tiers")
