if isServer() then return end
require("Entity/ISUI/CraftRecipe/ISRecipeScrollingListBox")
local G = {}
local originalAdd = ISRecipeScrollingListBox.addGroup
local families = {
    OMHTTCraftSpikeBarrier = "SpikeBarrier", OMHTTReinforceSpikeBarrier = "SpikeBarrier",
    OMHTTPackSpikeBarriers = "SpikeBarrier", OMHTTUnpackSpikeBarriers = "SpikeBarrier",
    OMHTTPackReinforcedBarriers = "SpikeBarrier", OMHTTUnpackReinforcedBarriers = "SpikeBarrier",
    OMHTTCraftBedSpikes = "BedSpikes", OMHTTReinforceBedSpikes = "BedSpikes",
    OMHTTCraftTurretComplete = "PotatoTurret", OMHTTCraftTurretCompleteImprovised = "PotatoTurret",
    OMHTTCraftTurretHead = "PotatoHead", OMHTTCraftTurretHeadImprovised = "PotatoHead",
}
local titles = {SpikeBarrier = "UI_OMHTT_SpikeBarrier", BedSpikes = "UI_OMHTT_BedSpikes",
    PotatoTurret = "UI_OMHTT_CraftGroupPotatoTurret", PotatoHead = "UI_OMHTT_CraftGroupPotatoHead"}
local order = {OMHTTCraftSpikeBarrier = 1, OMHTTReinforceSpikeBarrier = 2,
    OMHTTPackSpikeBarriers = 3, OMHTTUnpackSpikeBarriers = 4,
    OMHTTPackReinforcedBarriers = 5, OMHTTUnpackReinforcedBarriers = 6,
    OMHTTCraftBedSpikes = 1, OMHTTReinforceBedSpikes = 2,
    OMHTTCraftTurretComplete = 1, OMHTTCraftTurretCompleteImprovised = 2,
    OMHTTCraftTurretHead = 1, OMHTTCraftTurretHeadImprovised = 2}
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

---@param a table First recipe node
---@param b table Second recipe node
---@return boolean before
---@nodiscard
local function compareRecipes(a, b)
    return order[a.recipe:getName()] < order[b.recipe:getName()]
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
        local id = recipe and families[recipe:getName()]
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
                    result:add(group)
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
    for _, group in pairs(groups) do
        table.sort(group.rows, compareRecipes)
        for i = 1, #group.rows do group.children:add(group.rows[i]) end
        group.rows = nil
        group.state.selected = selected
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
