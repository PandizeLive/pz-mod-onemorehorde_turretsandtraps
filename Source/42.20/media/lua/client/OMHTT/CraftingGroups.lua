if isServer() then return end
require("Entity/ISUI/CraftRecipe/ISRecipeScrollingListBox")
local G = {}
local originalAdd = ISRecipeScrollingListBox.addGroup
local titles = {Normal = "IGUI_CraftingCategories_OMHNormal",
    Reinforced = "IGUI_CraftingCategories_OMHReinforced", Packed = "IGUI_CraftingCategories_OMHPacked",
    Heads = "IGUI_CraftingCategories_OMHHeads", Modules = "IGUI_CraftingCategories_OMHModules"}
local order = {"Normal", "Reinforced", "Packed", "Heads", "Modules"}
local turretGroups = {OMHTTCraftTurretHead = "Heads", OMHTTCraftTurretHeadImprovised = "Heads",
    OMHTTCraftMotionDetectionImprovised = "Modules", OMHTTCraftFiringImprovised = "Modules",
    OMHTTCraftCapacityImprovised = "Modules"}

---@param recipe CraftRecipe? Filtered recipe
---@return string? tier
local function tier(recipe)
    if not recipe then return nil end
    local name = recipe:getName()
    if string.sub(name, 1, 5) ~= "OMHTT" then return nil end
    if recipe:getCategory() == "OMHTurrets" then return turretGroups[name] end
    if recipe:getCategory() ~= "OMHTraps" then return nil end
    if string.find(name, "Pack", 1, true) or string.find(name, "Unpack", 1, true) then return "Packed" end
    if string.find(name, "Reinforce", 1, true) then return "Reinforced" end
    return "Normal"
end
local Node = {}
Node.__index = Node

---@return CraftRecipeListNodeType type
function Node:getType() return self.kind end
---@return CraftRecipe? recipe
function Node:getRecipe() return self.recipe end
---@return table? parent
function Node:getParent() return self.parent end
---@return ArrayList children
function Node:getChildren() return self.children end
---@return string title
function Node:getTitle() return getText(titles[self.id]) end
---@return Texture? icon
function Node:getIconTexture() return self.icon end
---@return table group
function Node:getGroup() return self end
---@return string identity
function Node:toString() return "OMHTT:" .. self.id end
---@return CraftRecipeListNodeExpandedState state
function Node:getExpandedState() return self.state.expanded end
---@param state CraftRecipeListNodeExpandedState Expanded state
---@return nil
function Node:setExpandedState(state) self.state.expanded = state end
---@return nil
function Node:toggleExpandedState()
    local E = CraftRecipeListNodeExpandedState
    local nextState = E.OPEN
    if self.state.expanded == E.OPEN then nextState = E.CLOSED end
    self:setExpandedState(nextState)
end

---@param widget ISRecipeScrollingListBox Native list
---@param nodes ArrayList Filtered native nodes
---@param selected CraftRecipe? Current recipe
---@param showAll boolean? Native show-all flag
---@return ArrayList nodes Original or grouped presentation
function G.nodes(widget, nodes, selected, showAll)
    local groups, result = {}, ArrayList.new()
    widget.omhttGroups = widget.omhttGroups or {}
    local types = CraftRecipeListNode.CraftRecipeListNodeType
    for i = 0, nodes:size() - 1 do
        local node = nodes:get(i)
        local recipe = node:getType() == types.RECIPE and node:getRecipe()
        local id = tier(recipe)
        if id then
            local callback = recipe:getOnAddToMenu()
            local visible = not callback or callLuaBool(callback, {player = widget.player, recipe = recipe, shouldShowAll = showAll})
            if visible then
                local group = groups[id]
                if not group then
                    local state = widget.omhttGroups[id]
                    if not state then
                        state = {expanded = CraftRecipeListNodeExpandedState.CLOSED}
                        widget.omhttGroups[id] = state
                    end
                    group = setmetatable({id = id, kind = types.GROUP, children = ArrayList.new(), rows = {}, state = state,
                        icon = node:getIconTexture()}, Node)
                    groups[id] = group
                end
                group.rows[#group.rows + 1] = setmetatable({kind = types.RECIPE, recipe = recipe, parent = group}, Node)
                if recipe == selected and group.state.selected ~= selected then
                    group:setExpandedState(CraftRecipeListNodeExpandedState.OPEN)
                end
            end
        else
            result:add(node)
        end
    end
    for i = 1, #order do
        local group = groups[order[i]]
        if group then
            result:add(group)
            for j = 1, #group.rows do group.children:add(group.rows[j]) end
            group.rows = nil
            group.state.selected = selected
        end
    end
    return result
end

---@param group table? Parent group
---@param nodes ArrayList Native filtered nodes
---@param selected CraftRecipe? Selected recipe
---@param showAll boolean? Show-all state
---@return number selectedIndex
function ISRecipeScrollingListBox:addGroup(group, nodes, selected, showAll)
    if not group then nodes = G.nodes(self, nodes, selected, showAll) end
    return originalAdd(self, group, nodes, selected, showAll)
end

return G
