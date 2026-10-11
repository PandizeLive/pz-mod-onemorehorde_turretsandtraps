if isClient() or isServer() then return end
local F = require("OMHTT/Foundation")
local Beds = require("OMHTT/BedSpikes")
local Barbs = require("OMHTT/BarbSections")
local P = {}
local definitions = {
    ["Base.OMHTTTrapSpikeBarrier"] = {"OMHTTDeploySpikeBarrier", F.barrierEnabled},
    ["Base.OMHTTTrapSpikeBarrierReinforced"] = {"OMHTTDeployReinforcedBarrier", F.barrierEnabled},
    ["Base.OMHTTTrapBedSpikes"] = {"OMHTTDeployBedSpikes", Beds.enabled, false, true},
    ["Base.OMHTTTrapBedSpikesReinforced"] = {"OMHTTDeployReinforcedBedSpikes", Beds.enabled, false, true},
    ["Base.OMHTTTrapConcertinaWire"] = {"OMHTTDeployConcertinaWire", Barbs.wireEnabled},
    ["Base.OMHTTTrapBarbedPanel"] = {"OMHTTBarbs", function() return Barbs.enabled() end, true},
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

---@param item InventoryItem Carried trap
---@param player IsoPlayer Builder
---@return string route Native entity ID
---@return InventoryItem? companion Second independent tile
function P.route(item, player)
    local definition = P.carried(item, player)
    local companion = nil
    if definition[4] then
        local candidates = player:getInventory():getAllTypeRecurse(item:getFullType())
        for i = 0, candidates:size() - 1 do
            local other = candidates:get(i)
            if other ~= item and P.carried(other, player) then companion = other; break end
        end
    end
    local route = definition[1]
    if definition[4] and not companion then route = route .. "Single" end
    return route, companion
end

---@param item InventoryItem Selected item
---@param player IsoPlayer Builder
---@return ISBuildIsoEntity? cursor
function P.place(item, player)
    local definition = P.carried(item, player)
    if not definition or player:isDead() then return nil end
    require("BuildingObjects/ISBuildIsoEntity")
    local route, companion = P.route(item, player)
    local info = SpriteConfigManager.GetObjectInfo(route)
    if not info then return nil end
    local containers = ArrayList.new()
    containers:add(item:getContainer())
    if item:getContainer() ~= player:getInventory() then containers:add(player:getInventory()) end
    if companion and companion:getContainer() ~= item:getContainer() and companion:getContainer() ~= player:getInventory() then
        containers:add(companion:getContainer())
    end
    local cursor = ISBuildIsoEntity:new(player, info, 1, containers)
    require("OMHTT/PlacementTiming").apply(cursor)
    local logic = cursor.buildPanelLogic
    logic:setManualSelectInputs(true)
    logic:clearManualInputs()
    logic:offerInputItem(item)
    if companion then logic:offerInputItem(companion) end
    if definition[3] and not player:isBuildCheat() then
        local inventory = player:getInventory()
        local hammer = inventory:getFirstTagEvalRecurse(ItemTag.HAMMER, usable)
        local pliers = inventory:getFirstTagEvalRecurse(ItemTag.PLIERS, usable)
        if not hammer or not pliers then
            player:setHaloNote(getText("UI_OMHTT_BarbTools"))
            return nil
        end
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
        if not P.carried(item, player) or companion and not P.carried(companion, player) then return false end
        if definition[3] and not require("OMHTT/BarbService").tools(player) then return false end
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
