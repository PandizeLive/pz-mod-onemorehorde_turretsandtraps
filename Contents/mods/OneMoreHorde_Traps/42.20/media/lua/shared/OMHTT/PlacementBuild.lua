local B = {}

---@param cursor ISBuildIsoEntity Validated portable entity cursor
---@param item InventoryItem Exact owned defense
---@param companion InventoryItem? Second independent Bed tile
---@param x number Validated tile X
---@param y number Validated tile Y
---@param z number Validated floor
---@return nil
function B.create(cursor, item, companion, x, y, z)
    -- Moving an existing defense is not crafting a free replacement. Vanilla create
    -- skips consumption in Build Cheat and passes the preview recipe data to OnCreate.
    -- Give native setInfo the exact portable inputs for its restoration callbacks.
    -- Keep native health, SpriteConfig, special-object insertion and transmission.
    local inputs = ArrayList.new()
    inputs:add(item)
    if companion then inputs:add(companion) end
    local receipt = {getAllConsumedItems = function() return inputs end}
    local logic = cursor.buildPanelLogic
    cursor.buildPanelLogic = {
        getRecipeData = function() return receipt end,
        getAllConsumedItems = function() return inputs end,
    }
    local face = cursor:getFace()
    for layer = 0, face:getzLayers() - 1 do
        for dx = 0, face:getWidth() - 1 do
            for dy = 0, face:getHeight() - 1 do
                local tile = face:getTileInfo(dx, dy, layer)
                if tile and tile:getSpriteName() then
                    local square = getCell():getGridSquare(x + dx, y + dy, z + layer)
                    cursor:setInfo(square, cursor.north, tile:getSpriteName(), false)
                end
            end
        end
    end
    cursor.buildPanelLogic = logic
    for i = 0, inputs:size() - 1 do
        local source = inputs:get(i)
        local container = source:getContainer()
        if container and container:contains(source) then
            cursor.character:removeFromHands(source)
            container:Remove(source)
            if isServer() then sendRemoveItemFromContainer(container, source) end
        end
    end
end

return B
