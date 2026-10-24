if isClient() then return end
local L = {}

---@param player IsoPlayer Authorized operator
---@param object IsoObject Legacy Poke Floor
---@return boolean empty All real legacy contents were recovered
function L.recover(player, object)
    local storage, inventory = object:getContainer(), player:getInventory()
    if not storage then return true end
    for i = 1, 64 do
        if storage:getItems():isEmpty() then return true end
        local item = storage:getItems():get(0)
        storage:Remove(item)
        local carried = inventory:isItemAllowed(item) and inventory:hasRoomFor(player, item)
        local delivered
        if carried then
            delivered = inventory:AddItem(item) == item
        else
            delivered = object:getSquare():AddWorldInventoryItem(item, .5, .5, 0) ~= nil
        end
        if not delivered then
            storage:AddItem(item)
            return false
        end
        if isServer() then
            sendRemoveItemFromContainer(storage, item)
            if carried then
                sendAddItemToContainer(inventory, item)
            end
        end
    end
    return storage:getItems():isEmpty()
end

return L
