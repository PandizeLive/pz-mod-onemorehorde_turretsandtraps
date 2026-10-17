if isServer() then return end
require("TimedActions/ISTimedActionQueue")
require("TimedActions/ISBaseTimedAction")
require("TimedActions/ISInventoryTransferAction")
local A = require("OMHTT/ControlAccess")
local Action = require("OMHTT/ControlAction")
local Transfer = require("OMHTT/ControlTransferAction")
local C = require("OMHTT/ControlDefinitions")
local U = {}
require("OMHTT/ControlInventory")
local Open = ISBaseTimedAction:derive("OMHTTOpenControls")

---@return boolean valid
function Open:isValid()
    return A.near(self.character, self.object)
end

---@return nil
function Open:perform()
    if self:isValid() then
        require("OMHTT/ControlPanel").open(self.character, self.object)
    end
    ISBaseTimedAction.perform(self)
end

---@param character IsoPlayer Operator
---@param object IsoObject Device
---@return table action
function Open:new(character, object)
    local action = ISBaseTimedAction.new(self, character)
    action.object, action.maxTime = object, 1
    return action
end

---@param player IsoPlayer Operator
---@param object IsoObject Device
---@param command string Operation
---@param value any Value
---@param target IsoObject? Other endpoint
---@return nil
function U.command(player, object, command, value, target)
    ISTimedActionQueue.add(Action:new(player, object, command, value, target))
end

---@param player IsoPlayer Operator
---@param controller IsoObject Live controller
---@param target IsoObject Assigned device
---@return boolean opened
function U.remote(player, controller, target)
    local state, host = A.state(target), A.state(controller)
    if not host or not state or not host.powered or state.controller ~= host.id or not A.near(player, controller) then return false end
    A.session(player, controller, target)
    U.command(player, controller, "Remote", nil, target)
    return true
end

---@param object IsoObject Device
---@return string name
function U.name(object)
    local state = A.state(object)
    if not state then return "" end
    if state.name and state.name ~= "" then return state.name end
    if state.kind == "Turret" then
        local head = require("OMHTT/Turret").contents(object:getContainer()).head
        local name = head and head:getDisplayName() or getText("UI_OMHTT_TurretBase")
        return name .. (state.number and " " .. state.number or "")
    end
    return getText("UI_OMHTT_Control" .. state.kind)
end

---@param item InventoryItem Device
---@param player IsoPlayer Builder
---@return boolean carried
function U.carried(item, player)
    if not item or not item:getContainer() or not item:getContainer():isInCharacterInventory(player) then return false end
    for _, fullType in pairs(C.types) do
        if item:getFullType() == fullType then return true end
    end
    return false
end

---@param item InventoryItem Exact device
---@param player IsoPlayer Builder
---@return ISBuildIsoEntity? cursor
function U.place(item, player)
    if not U.carried(item, player) then return nil end
    require("BuildingObjects/ISBuildIsoEntity")
    local kind
    for key, fullType in pairs(C.types) do
        if item:getFullType() == fullType then
            kind = key
        end
    end
    local info = SpriteConfigManager.GetObjectInfo("OMHTTDeploy" .. kind)
    if not info then return nil end
    local containers = ArrayList.new()
    containers:add(item:getContainer())
    local cursor = ISBuildIsoEntity:new(player, info, 1, containers)
    cursor.omhttInputs = {item}
    cursor.buildPanelLogic:setManualSelectInputs(true)
    cursor.buildPanelLogic:clearManualInputs()
    cursor.buildPanelLogic:offerInputItem(item)
    require("OMHTT/PlacementTiming").apply(cursor)
    cursor.dragNilAfterPlace = true
    getCell():setDrag(cursor, player:getPlayerNum())
    return cursor
end

---@param index number Local player index
---@param context ISContextMenu Menu
---@param selection table Inventory selections
---@return nil
function U.inventory(index, context, selection)
    local player = getSpecificPlayer(index)
    for i = 1, #selection do
        local item = selection[i]
        if type(item) == "table" and item.items then
            item = item.items[1]
        end
        if U.carried(item, player) then
            context:addOption(getText("UI_OMHTT_ControlPlace"), item, U.place, player)
            return
        end
    end
end

---@param index number Local player
---@param context ISContextMenu Menu
---@param objects table World selection
---@param test boolean Probe
---@return nil
function U.world(index, context, objects, test)
    if test then return end
    local player, seen = getSpecificPlayer(index), {}
    for i = 1, #objects do
        local square = objects[i]:getSquare()
        local list = square and square:getObjects()
        if list then
            for j = 0, list:size() - 1 do
                local object = list:get(j)
                local state = A.state(object)
                if state and not seen[object] then
                    seen[object] = true
                    context:addOption(getText("UI_OMHTT_ControlManage"), object, function(device)
                        if luautils.walkAdjObject(player, device, false) then
                            ISTimedActionQueue.add(Open:new(player, device))
                        end
                    end)
                    if state.kind == "Button" then
                        context:addOption(getText("UI_OMHTT_ControlPress"), object, function(device)
                            if luautils.walkAdjObject(player, device, false) then
                                U.command(player, device, "Pulse")
                            end
                        end)
                    end
                    if state.kind ~= "Turret" and A.write(player, state) then
                        context:addOption(getText("UI_OMHTT_ControlPickup"), object, function(device)
                            if luautils.walkAdjObject(player, device, false) then
                                U.command(player, device, "Pickup")
                            end
                        end)
                        if object:getHealth() < 100 then
                            context:addOption(getText("UI_OMHTT_ControlRepair"), object, function(device)
                                if luautils.walkAdjObject(player, device, false) then
                                    U.command(player, device, "Repair")
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end

local nativeTransfer = ISInventoryTransferAction.new
---@param player IsoPlayer Operator
---@param item InventoryItem Exact item
---@param source ItemContainer Origin
---@param destination ItemContainer Destination
---@param time number? Duration
---@return table action
function ISInventoryTransferAction:new(player, item, source, destination, time)
    local incoming = destination and destination:getType() == "OMHTTController"
    local storage = incoming and destination or source
    local object = storage and storage:getParent()
    local state = A.state(object)
    if state and state.kind == "Controller" then
        local turretStorage = incoming and source or destination
        if turretStorage and turretStorage:getType() == "OMHTTTurret" then
            local turret = turretStorage:getParent()
            local T = require("OMHTT/Turret")
            local record = T.state(turret)
            if record then
                return require("OMHTT/TurretTransferAction"):new(player, turret, item, not incoming, record.id, nil, nil, incoming)
            end
        end
        return Transfer:new(player, object, item, incoming == true, state.id)
    end
    return nativeTransfer(self, player, item, source, destination, time)
end

Events.OnFillInventoryObjectContextMenu.Add(U.inventory)
Events.OnFillWorldObjectContextMenu.Add(U.world)
return U

