if isClient() or isServer() then return end
local F = require("OMHTT/Foundation")
local Beds = require("OMHTT/BedSpikes")
local Barbs = require("OMHTT/BarbSections")
local P = {}
local definitions = {
    ["Base.OMHTTSpikeBarrierItem"] = {"OMHTTDeploySpikeBarrier", F.barrierEnabled},
    ["Base.OMHTTReinforcedBarrierItem"] = {"OMHTTDeployReinforcedBarrier", F.barrierEnabled},
    ["Base.OMHTTBedSpikesItem"] = {"OMHTTDeployBedSpikes", Beds.enabled},
    ["Base.OMHTTReinforcedBedSpikesItem"] = {"OMHTTDeployReinforcedBedSpikes", Beds.enabled},
    ["Base.OMHTTBarbedPanelItem"] = {"OMHTTBarbs", Barbs.enabled, true},
}

---@param item InventoryItem Selected item
---@param player IsoPlayer Builder
---@return table? definition
---@nodiscard
function P.carried(item, player)
    if not item or not item:getContainer() or not item:getContainer():isInCharacterInventory(player) then return nil end
    local definition = definitions[item:getFullType()]
    if definition and definition[2]() and item:getCondition() > 0 then return definition end
    return nil
end

---@param item InventoryItem Tool
---@return boolean usable
---@nodiscard
local function usable(item)
    return item:getCondition() > 0
end

---@param item InventoryItem Selected item
---@param player IsoPlayer Builder
---@return ISBuildIsoEntity? cursor
function P.place(item, player)
    local definition = P.carried(item, player)
    if not definition or player:isDead() then return nil end
    require("BuildingObjects/ISBuildIsoEntity")
    local info = SpriteConfigManager.GetObjectInfo(definition[1])
    if not info then return nil end
    local containers = ArrayList.new()
    containers:add(item:getContainer())
    if item:getContainer() ~= player:getInventory() then containers:add(player:getInventory()) end
    local cursor = ISBuildIsoEntity:new(player, info, 1, containers)
    local logic = cursor.buildPanelLogic
    logic:setManualSelectInputs(true)
    logic:clearManualInputs()
    logic:offerInputItem(item)
    if definition[3] then
        local inventory = player:getInventory()
        local hammer = inventory:getFirstTagEvalRecurse(ItemTag.HAMMER, usable)
        local pliers = inventory:getFirstTagEvalRecurse(ItemTag.PLIERS, usable)
        if not hammer or not pliers then return nil end
        logic:offerInputItem(hammer)
        logic:offerInputItem(pliers)
    end
    local input = info:getRecipe():getCraftRecipe():getInputs():get(0)
    if logic:getRecipeData():getFirstManualInputFor(input) ~= item then return nil end
    local valid = cursor.isValid
    ---@param self ISBuildIsoEntity Cursor
    ---@param square IsoGridSquare Destination
    ---@param north boolean Facing
    ---@return boolean valid
    cursor.isValid = function(self, square, north)
        if not P.carried(item, player) then return false end
        return valid(self, square, north)
    end
    if definition[3] then
        local render = cursor.render
        ---@param self ISBuildIsoEntity Cursor
        ---@param x number Tile X
        ---@param y number Tile Y
        ---@param z number Floor
        ---@param square IsoGridSquare Preview square
        ---@return nil
        cursor.render = function(self, x, y, z, square)
            render(self, x, y, z, square)
            local face = self:getFace()
            if not face then return end
            local bx, by, north, side = require("OMHTT/BarbContact").edge(x, y, face:getFaceName())
            if not bx then return end
            local dx, dy = side * .35, 0
            if north then
                bx, dx, dy = bx + .5, 0, side * .35
            else
                by = by + .5
            end
            renderIsoLine(bx, by, z, bx + dx, by + dy, z, 3, 1, 1, 1, 1)
            renderIsoLine(bx + dx, by + dy, z, bx + dx * .6 - dy * .3, by + dy * .6 + dx * .3, z, 3, 1, 1, 1, 1)
            renderIsoLine(bx + dx, by + dy, z, bx + dx * .6 + dy * .3, by + dy * .6 - dx * .3, z, 3, 1, 1, 1, 1)
        end
    end
    cursor.dragNilAfterPlace = true
    getCell():setDrag(cursor, player:getPlayerNum())
    return cursor
end

---@param index number Player number
---@param context ISContextMenu Inventory menu
---@param selection table Selected items or stacks
---@return nil
function P.menu(index, context, selection)
    local player = getSpecificPlayer(index)
    if not player or player:isDead() then return end
    for i = 1, #selection do
        local item = selection[i]
        if type(item) == "table" and item.items then item = item.items[1] end
        local definition = P.carried(item, player)
        if definition then
            local key = definition[3] and "UI_OMHTT_AttachTrap" or "UI_OMHTT_PlaceTrap"
            local option = context:addOption(getText(key), item, P.place, player)
            if definition[3] then
                option.notAvailable = not require("OMHTT/BarbService").tools(player)
            end
            return
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(P.menu)
return P
