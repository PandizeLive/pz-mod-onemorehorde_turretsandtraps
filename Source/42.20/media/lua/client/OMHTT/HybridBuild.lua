if isServer() then return end
require("Entity/TimedActions/ISHandcraftAction")
require("TimedActions/ISTimedActionQueue")
local H = {}
H.generation = 0
H.definitions = {
    {item = "Base.OMHTTTrapSpikeBarrier", craft = "OMHTTCraftSpikeBarrier", deploy = "OMHTTDeploySpikeBarrier"},
    {item = "Base.OMHTTTrapSpikeBarrierReinforced", craft = "OMHTTReinforceSpikeBarrier", deploy = "OMHTTDeployReinforcedBarrier"},
    {item = "Base.OMHTTTrapBedSpikes", craft = "OMHTTCraftBedSpikes", deploy = "OMHTTDeployBedSpikes"},
    {item = "Base.OMHTTTrapBedSpikesReinforced", craft = "OMHTTReinforceBedSpikes", deploy = "OMHTTDeployReinforcedBedSpikes"},
    {item = "Base.OMHTTTrapConcertinaWire", craft = "OMHTTCraftConcertinaWire", deploy = "OMHTTDeployConcertinaWire"},
    {item = "Base.OMHTTTrapBarbedPanel", craft = "OMHTTCraftBarbs", deploy = "OMHTTBarbs"},
    {item = "Base.OMHTTTurretBase", craft = "OMHTTCraftTurretBase", deploy = "OMHTTDeployTurret", turret = true},
    {item = "Base.OMHTTTrapController", craft = "OMHTTCraftController", deploy = "OMHTTDeployController", control = true},
    {item = "Base.OMHTTTrapPressurePlate", craft = "OMHTTCraftPlate", deploy = "OMHTTDeployInsetPlate", control = true},
    {item = "Base.OMHTTTrapButton", craft = "OMHTTCraftButton", deploy = "OMHTTDeployButton", control = true},
}
local byRecipe = {}
for i = 1, #H.definitions do
    local definition = H.definitions[i]
    definition.adapter = definition.control and "OMHTT/ControlClient" or (definition.turret and "OMHTT/TurretInstall" or "OMHTT/BarrierPlacement")
    byRecipe[definition.craft], byRecipe[definition.deploy] = definition, definition
    if string.find(definition.deploy, "BedSpikes", 1, true) then byRecipe[definition.deploy .. "Single"] = definition end
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
    if context.definition.turret or context.definition.control then
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
---@param definition table Route
---@param item InventoryItem Carried item
---@return SpriteConfigManager.ObjectInfo? info Exact deployment quantity
function H.info(player, definition, item)
    local route = definition.deploy
    if string.find(route, "BedSpikes", 1, true) then route = require(definition.adapter).route(item, player) end
    return SpriteConfigManager.GetObjectInfo(route)
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
---@param cursor ISBuildIsoEntity Session cursor
---@return boolean active
function H.active(panel, cursor)
    return not panel.omhttClosed and not panel.player:isDead()
        and getCell():getDrag(panel.player:getPlayerNum()) == cursor
end

---@param panel ISBuildPanel Native panel
---@return nil
function H.poll(panel)
    local pending = panel.omhttPending
    if not pending then return end
    if panel.omhttClosed or panel.player:isDead() or pending.cursor and not H.active(panel, pending.cursor) then
        panel.omhttPending = nil
        if pending.cancelled then pending.cancelled() end
        return
    end
    local now = getTimestampMs()
    if now < pending.nextCheck then return end
    pending.nextCheck = now + 100
    if not H.recipe(panel.player, pending.definition) then
        panel.omhttPending = nil
        if pending.cancelled then pending.cancelled() end
        return
    end
    if pending.generation == H.generation and now < pending.deadline then return end
    pending.generation = H.generation
    if pending.cursor then
        local inputs = pending.cursor.omhttInputs or {}
        for i = 1, #inputs do
            local item = inputs[i]
            local container = item:getContainer()
            if container and container:contains(item) and now < pending.deadline then return end
        end
        panel.omhttPending = nil
        H.repeatPlacement(panel, pending.definition, pending.cursor.nSprite)
        return
    end
    local item = H.item(panel.player, pending.definition)
    if item then
        panel.omhttPending = nil
        if pending.ready then
            pending.ready(item)
        else
            H.bind(panel, pending.definition, H.place(panel.player, pending.definition, item))
        end
    elseif now >= pending.deadline then
        panel.omhttPending = nil
        panel.player:setHaloNote(getText("UI_OMHTT_BuildPickUp"))
        if pending.cancelled then pending.cancelled() end
    end
end

---@param panel ISBuildPanel Native panel
---@param definition table Build route
---@param cursor ISBuildIsoEntity? Completed placement awaiting consumption replication
---@param ready function? Crafted item callback
---@param cancelled function? Abandoned follow-up callback
---@return nil
function H.awaitInventory(panel, definition, cursor, ready, cancelled)
    local now = getTimestampMs()
    panel.omhttPending = {definition = definition, cursor = cursor, ready = ready, cancelled = cancelled,
        deadline = now + 10000, nextCheck = now}
    H.poll(panel)
end

---@param panel ISBuildPanel Native panel
---@param definition table Build route
---@param cursor ISBuildIsoEntity Exact-item cursor
---@param facing number? Previous orientation
---@return ISBuildIsoEntity? cursor
function H.bind(panel, definition, cursor, facing)
    if not cursor then return nil end
    if facing then cursor.nSprite = facing end
    cursor.dragNilAfterPlace, cursor.blockAfterPlace = false, true
    local complete, start = cursor.onActionComplete, cursor.onTimedActionStart
    ---@param self ISBuildIsoEntity Original cursor
    ---@return nil
    cursor.onActionComplete = function(self)
        complete(self)
        self.blockBuild = false
        panel.omhttPlacement = nil
    end
    ---@param self ISBuildIsoEntity Copied cursor
    ---@param action ISBuildAction Native action
    ---@return nil
    cursor.onTimedActionStart = function(self, action)
        start(self, action)
        local perform = action.perform
        ---@param timed ISBuildAction Completed action
        ---@return nil
        action.perform = function(timed)
            if timed.omhttRepeated then return end
            timed.omhttRepeated = true
            perform(timed)
            panel.omhttPlacement = nil
            if H.active(panel, cursor) then
                if isClient() then
                    H.awaitInventory(panel, definition, cursor)
                else
                    H.repeatPlacement(panel, definition, cursor.nSprite)
                end
            end
        end
    end
    ---@param self ISBuildIsoEntity Original cursor
    ---@param x number Tile X
    ---@param y number Tile Y
    ---@param z number Floor
    ---@return nil
    cursor.tryBuild = function(self, x, y, z)
        if self.blockBuild or panel.omhttPending or not H.active(panel, self) then return end
        local action = ISBuildingObject.tryBuild(self, x, y, z)
        if action then
            action.onIsValid = self.objectInfo:getScript():getTimedActionOnIsValid()
            self.blockBuild = true
            panel.omhttPlacement = action
        end
    end
    panel.buildEntity = cursor
    return cursor
end

---@param panel ISBuildPanel Native panel
---@param definition table Build route
---@param facing number Last orientation
---@return nil
function H.repeatPlacement(panel, definition, facing)
    if panel.omhttClosed or panel.player:isDead() or not H.recipe(panel.player, definition) then return end
    local item = H.item(panel.player, definition)
    if item then
        H.bind(panel, definition, H.place(panel.player, definition, item), facing)
        return
    end
    local containers = ISInventoryPaneContextMenu.getContainers(panel.player)
    local logic = HandcraftLogic.new(panel.player, nil, nil)
    logic:setContainers(containers)
    logic:setRecipe(H.recipe(panel.player, definition))
    local info = SpriteConfigManager.GetObjectInfo(definition.deploy)
    if not info then return end
    local preview = ISBuildIsoEntity:new(panel.player, info, facing, containers)
    preview.dragNilAfterPlace = false
    ---@param self ISBuildIsoEntity Planning cursor
    ---@param square IsoGridSquare Destination
    ---@return boolean available
    preview.haveMaterial = function(self, square)
        local position = panel.player:getCurrentSquare()
        if self.omhttGeneration ~= H.generation or self.omhttPosition ~= position then
            self.omhttGeneration = H.generation
            self.omhttPosition = position
            logic:setContainers(ISInventoryPaneContextMenu.getContainers(panel.player))
            self.omhttAvailable = H.item(panel.player, definition) ~= nil or logic:canPerformCurrentRecipe()
        end
        return H.active(panel, self) and H.recipe(panel.player, definition) ~= nil
            and self.omhttAvailable
    end
    ---@param self ISBuildIsoEntity Planning cursor
    ---@param x number Tile X
    ---@param y number Tile Y
    ---@param z number Floor
    ---@return nil
    preview.tryBuild = function(self, x, y, z)
        if self.blockBuild or not H.active(panel, self) then return end
        local square = getCell():getGridSquare(x, y, z)
        if not self:isValid(square) then return end
        self.blockBuild = true
        local orientation = self.nSprite
        local started = H.start(panel, definition, function(output)
            self.blockBuild = false
            if not H.active(panel, self) then return end
            local cursor = H.bind(panel, definition, H.place(panel.player, definition, output), orientation)
            if cursor then
                cursor:getSprite()
                if cursor:isValid(square) then cursor:tryBuild(x, y, z) end
            end
        end, function() self.blockBuild = false end)
        if not started then self.blockBuild = false end
    end
    panel.buildEntity = preview
    getCell():setDrag(preview, panel.player:getPlayerNum())
end

---@param panel ISBuildPanel Native panel
---@param definition table Build route
---@param ready function? Exact crafted/carried item callback
---@param cancelled function? Interrupted crafting callback
---@return boolean started
function H.start(panel, definition, ready, cancelled)
    local player = panel.player
    if panel.omhttAction or panel.omhttPlacement or panel.omhttPending or player:isDead() or not H.recipe(player, definition) then return false end
    local item = H.item(player, definition)
    if item then
        if ready then ready(item); return true end
        panel.buildEntity = H.bind(panel, definition, H.place(player, definition, item))
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
        if cancelled then cancelled() end
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
        if isClient() then
            -- Native complete() crafts on the server; client RecipeData has no created items.
            H.awaitInventory(panel, definition, nil, ready, cancelled)
            return
        end
        local outputs = self.logic:getRecipeData():getAllCreatedItems()
        for i = 0, outputs:size() - 1 do
            local output = outputs:get(i)
            if output:getFullType() == definition.item and carried(output, {player = player, definition = definition}) then
                if ready then ready(output) else H.bind(panel, definition, H.place(player, definition, output)) end
                return
            end
        end
        player:setHaloNote(getText("UI_OMHTT_BuildPickUp"))
        if cancelled then cancelled() end
    end
    ISTimedActionQueue.add(action)
    return true
end

return H

