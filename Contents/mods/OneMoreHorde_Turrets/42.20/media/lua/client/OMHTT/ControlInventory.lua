if isServer() then return end
require("ISUI/ISInventoryPage")
require("ISUI/ISInventoryPane")
require("ISUI/ISInventoryPaneContextMenu")
local A = require("OMHTT/ControlAccess")
local Transfer = require("OMHTT/ControlTransferAction")
local Inventory = {}

---@param container ItemContainer? Native destination
---@return IsoObject? controller
local function controller(container)
    if not container or container:getType() ~= "OMHTTController" then return nil end
    local object = container:getParent()
    local state = A.state(object)
    return state and state.kind == "Controller" and object or nil
end

---@param owner ISPanel Manage or Controller window
---@param object IsoObject Controller
---@return nil
function Inventory.open(owner, object)
    if not A.near(owner.player, object) or not controller(object:getContainer()) then return end
    local panel = require("OMHTT/ControlPanel").show(owner.player, object)
    if panel then
        panel:showStockpile()
    end
end

local nativeCanPutIn = ISInventoryPane.canPutIn
---@return boolean allowed
function ISInventoryPane:canPutIn()
    local object = controller(self.inventory)
    if not object then return nativeCanPutIn(self) end
    local player = getSpecificPlayer(self.player)
    local items = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
    for i = 1, #items do
        if Transfer.canStore(player, object, items[i]) then return true end
    end
    return false
end

local nativePageCanPutIn = ISInventoryPage.canPutIn
---@return boolean allowed
function ISInventoryPage:canPutIn()
    local container = self.mouseOverButton and self.mouseOverButton.inventory
    local object = controller(container)
    if not object then return nativePageCanPutIn(self) end
    local player = getSpecificPlayer(self.player)
    local items = ISInventoryPane.getActualItems(ISMouseDrag.dragging)
    for i = 1, #items do
        if Transfer.canStore(player, object, items[i]) then return true end
    end
    return false
end

local nativeHasRoom = ISInventoryPaneContextMenu.hasRoomForAny
---@param player IsoPlayer Operator
---@param container ItemContainer Destination
---@param items InventoryItem[] Selection
---@return boolean allowed
function ISInventoryPaneContextMenu.hasRoomForAny(player, container, items)
    local object = controller(container)
    if not object then return nativeHasRoom(player, container, items) end
    for i = 1, #items do
        if Transfer.canStore(player, object, items[i]) then return true end
    end
    return false
end

local nativeDraggedUpdate = ISInventoryPaneDraggedItems.update
---@return nil
function ISInventoryPaneDraggedItems:update()
    local previousContainer, previousCount = self.mouseOverContainer, self.mouseOverItemCount
    nativeDraggedUpdate(self)
    local object = controller(self.mouseOverContainer)
    if not object or not self.items then return end
    local player = getSpecificPlayer(self.playerNum)
    local weightNow = self.mouseOverContainer:getCapacityWeight()
    local writable = A.near(player, object) and A.write(player, A.state(object))
    if previousContainer == self.mouseOverContainer and previousCount == self.mouseOverItemCount
        and self.controlItems == self.items and self.controlWeight == weightNow and self.controlWritable == writable then return end
    self.controlItems, self.controlWeight, self.controlWritable = self.items, weightNow, writable
    local remaining = 500 - weightNow
    for i = 1, #self.items do
        local item = self.items[i]
        local weight = item:getUnequippedWeight()
        local allowed = weight <= remaining and Transfer.canStore(player, object, item)
        self.itemNotOK[item] = not allowed
        if allowed then
            remaining = remaining - weight
        end
    end
end

local nativeRefresh = ISInventoryPage.refreshBackpacks
---@return nil
function ISInventoryPage:refreshBackpacks()
    nativeRefresh(self)
    for i = 1, #self.backpacks do
        local button = self.backpacks[i]
        if controller(button.inventory) then
            button.capacity = 500
        end
    end
    if controller(self.inventoryPane.inventory) then
        self.capacity = 500
    end
end

local nativeUpdate = ISInventoryPage.update
---@return nil
function ISInventoryPage:update()
    nativeUpdate(self)
    if controller(self.inventoryPane.inventory) then
        self.capacity = 500
    end
end

return Inventory
