if isClient() or isServer() then return end
require("Entity/TimedActions/ISHandcraftAction")
require("TimedActions/ISTimedActionQueue")
local H = {}
H.definitions = {
    {item = "Base.OMHTTSpikeBarrierItem", craft = "OMHTTCraftSpikeBarrier", deploy = "OMHTTDeploySpikeBarrier"},
    {item = "Base.OMHTTReinforcedBarrierItem", craft = "OMHTTReinforceSpikeBarrier", deploy = "OMHTTDeployReinforcedBarrier"},
    {item = "Base.OMHTTBedSpikesItem", craft = "OMHTTCraftBedSpikes", deploy = "OMHTTDeployBedSpikes"},
    {item = "Base.OMHTTReinforcedBedSpikesItem", craft = "OMHTTReinforceBedSpikes", deploy = "OMHTTDeployReinforcedBedSpikes"},
    {item = "Base.OMHTTBarbedPanelItem", craft = "OMHTTCraftBarbs", deploy = "OMHTTBarbs"},
    {item = "Base.OMHTTTurretBase", craft = "OMHTTCraftTurretBase", deploy = "OMHTTDeployTurret", turret = true},
}
local byRecipe = {}
for i = 1, #H.definitions do
    local definition = H.definitions[i]
    definition.adapter = definition.turret and "OMHTT/TurretInstall" or "OMHTT/BarrierPlacement"
    byRecipe[definition.craft], byRecipe[definition.deploy] = definition, definition
end

---@param recipe CraftRecipe? Selected native recipe
---@return table? definition
function H.definition(recipe)
    return recipe and byRecipe[recipe:getName()]
end

---@param item InventoryItem Candidate
---@param context table Player and definition
---@return boolean usable
local function carried(item, context)
    if context.definition.turret then
        return require(context.definition.adapter).carried(item, context.player)
    end
    return require(context.definition.adapter).carried(item, context.player) ~= nil
end

---@param player IsoPlayer Builder
---@param definition table Build route
---@return InventoryItem? item Exact usable carried object
function H.item(player, definition)
    return player:getInventory():getFirstTypeEvalArgRecurse(definition.item, carried,
        {player = player, definition = definition})
end

---@param player IsoPlayer Builder
---@param definition table Build route
---@return CraftRecipe? recipe Enabled original crafting recipe
function H.recipe(player, definition)
    local recipe = ScriptManager.instance:getCraftRecipe("Base." .. definition.craft)
    if not recipe then return nil end
    local callback = recipe:getOnAddToMenu()
    if callback and not callLuaBool(callback, {player = player, recipe = recipe, shouldShowAll = false}) then return nil end
    return recipe
end

---@param player IsoPlayer Builder
---@param definition table Build route
---@param item InventoryItem Exact carried item
---@return ISBuildIsoEntity? cursor
function H.place(player, definition, item)
    require("BuildingObjects/ISBuildIsoEntity")
    if definition.turret then return require(definition.adapter).install(item, player) end
    return require(definition.adapter).place(item, player)
end

---@param panel ISBuildPanel Native panel
---@param definition table Build route
---@return boolean started
function H.start(panel, definition)
    local player = panel.player
    if panel.omhttAction or player:isDead() or not H.recipe(player, definition) then return false end
    local item = H.item(player, definition)
    if item then
        panel.buildEntity = H.place(player, definition, item)
        return panel.buildEntity ~= nil
    end
    local logic = HandcraftLogic.new(player, nil, nil)
    logic:setContainers(ISInventoryPaneContextMenu.getContainers(player))
    logic:setRecipe(H.recipe(player, definition))
    if panel.logic and panel.logic:getRecipe() == logic:getRecipe() and panel.logic:isManualSelectInputs() then
        logic:setManualSelectInputs(true)
        logic:clearManualInputs()
        local inputs = logic:getRecipe():getInputs()
        for i = 0, inputs:size() - 1 do
            local input = inputs:get(i)
            logic:setManualInputsFor(input, panel.logic:getManualInputsFor(input, ArrayList.new()))
        end
    end
    if not logic:canPerformCurrentRecipe() then
        player:setHaloNote(getText("UI_OMHTT_BuildRequirements"))
        return false
    end
    local inputs, resolved = ArrayList.new(), logic:getRecipeData():getAllInputItems()
    for i = 0, resolved:size() - 1 do inputs:add(resolved:get(i)) end
    logic:setManualSelectInputs(true)
    logic:clearManualInputs()
    for i = 0, inputs:size() - 1 do logic:offerInputItem(inputs:get(i)) end
    if not logic:canPerformCurrentRecipe() then return false end
    if not logic:getRecipe():isCanBeDoneFromFloor() then
        for i = 0, inputs:size() - 1 do
            ISInventoryPaneContextMenu.transferIfNeeded(player, inputs:get(i))
        end
    end
    local action = ISHandcraftAction.FromLogic(logic)
    local perform, stop, valid = action.perform, action.stop, action.isValid
    panel.omhttAction = action
    action.stopOnWalk, action.stopOnRun = true, true
    ---@param self ISHandcraftAction Craft action
    ---@return boolean valid
    action.isValid = function(self)
        return not self.character:isDead() and H.recipe(self.character, definition) ~= nil and valid(self)
    end
    ---@param self ISHandcraftAction Craft action
    ---@return nil
    action.stop = function(self)
        panel.omhttAction = nil
        stop(self)
    end
    ---@param self ISHandcraftAction Craft action
    ---@return nil
    action.perform = function(self)
        if self.omhttFinished then return end
        self.omhttFinished = true
        perform(self)
        panel.omhttAction = nil
        panel.omhttRefresh = true
        if panel.omhttClosed or self.character:isDead() or not H.recipe(self.character, definition) then return end
        local outputs = self.logic:getRecipeData():getAllCreatedItems()
        for i = 0, outputs:size() - 1 do
            local output = outputs:get(i)
            if output:getFullType() == definition.item and carried(output, {player = player, definition = definition}) then
                panel.buildEntity = H.place(player, definition, output)
                return
            end
        end
        player:setHaloNote(getText("UI_OMHTT_BuildPickUp"))
    end
    ISTimedActionQueue.add(action)
    return true
end

return H
