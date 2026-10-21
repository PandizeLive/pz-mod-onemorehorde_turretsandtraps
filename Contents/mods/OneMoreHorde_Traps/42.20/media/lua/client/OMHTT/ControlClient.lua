if isServer() then return end
require("TimedActions/ISTimedActionQueue")
require("TimedActions/ISBaseTimedAction")
require("TimedActions/ISInventoryTransferAction")
local A = require("OMHTT/ControlAccess")
local Action = require("OMHTT/ControlAction")
local Transfer = require("OMHTT/ControlTransferAction")
Transfer.setOnComplete = ISInventoryTransferAction.setOnComplete
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
    return require("OMHTT/ControlRemote").request(player, controller, target)
end

---@param object IsoObject Device
---@param automatic boolean? Ignore a custom name
---@return string name
function U.name(object, automatic)
    local state = A.state(object)
    if not state then return "" end
    if not automatic and state.displayName then return state.displayName end
    if state.kind ~= "Controller" and not automatic and state.name and state.name ~= "" then return state.name end
    if state.kind == "Turret" then
        local head = state.headType
        local name = head and head ~= "Base" and getItemNameFromFullType(head) or getText("UI_OMHTT_TurretBase")
        return name .. (state.number and " #" .. state.number or "")
    end
    return getText("UI_OMHTT_Control" .. state.kind) .. (state.number and " #" .. state.number or "")
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
    local entity = kind == "Plate" and "OMHTTDeployInsetPlate" or "OMHTTDeploy" .. kind
    if kind == "Button" then
        entity = "OMHTTDeploySwitchButton"
    end
    local info = SpriteConfigManager.GetObjectInfo(entity)
    if not info then return nil end
    local containers = ArrayList.new()
    containers:add(item:getContainer())
    local cursor = ISBuildIsoEntity:new(player, info, 1, containers)
    cursor.omhttInputs = {item}
    cursor.buildPanelLogic:setManualSelectInputs(true)
    cursor.buildPanelLogic:clearManualInputs()
    cursor.buildPanelLogic:offerInputItem(item)
    require("OMHTT/PlacementTiming").apply(cursor, require("OMHTT/ControlRepair").profiles[kind].pickup)
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
                    if state.kind == "Controller" then
                        context:addOption(getText("UI_OMHTT_ControlManage"), object, function(device)
                            if luautils.walkAdjObject(player, device, false) then
                                ISTimedActionQueue.add(Open:new(player, device))
                            end
                        end)
                    end
                    if state.kind == "Button" then
                        context:addOption(getText("UI_OMHTT_ControlPress"), object, function(device)
                            if luautils.walkAdjObject(player, device, false) then
                                U.command(player, device, "Pulse")
                            end
                        end)
                    end
                    if state.kind == "Tether" then
                        require("OMHTT/ControlTetherMenu").add(context, player, object)
                    end
                    if state.kind == "Poke" then
                        require("OMHTT/ControlPokeMenu").add(context, player, object)
                    end
                    if state.kind ~= "Turret" and state.kind ~= "Poke" and state.kind ~= "Tether" and A.write(player, state) then
                        context:addOption(getText("UI_OMHTT_ControlPickup"), object, function(device)
                            if luautils.walkAdjObject(player, device, false) then
                                U.command(player, device, "Pickup")
                            end
                        end)
                        if object:getHealth() < 100 then
                            local repair = context:addOption(getText("UI_OMHTT_ControlRepair"), object, function(device)
                                if luautils.walkAdjObject(player, device, false) then
                                    U.command(player, device, "Repair")
                                end
                            end)
                            repair.notAvailable = not require("OMHTT/ControlRepair").ready(player, state.kind)
                            require("OMHTT/ControlRepairTooltip").bind(repair, state.kind, player)
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
    local pokeIn = destination and destination:getType() == "OMHTTPoke"
    local pokeStorage = pokeIn and destination or source
    if pokeStorage and pokeStorage:getType() == "OMHTTPoke" then
        local actionType = require("OMHTT/ControlPokeAction")
        actionType.setOnComplete = ISInventoryTransferAction.setOnComplete
        local host, bag
        if not pokeIn and destination ~= player:getInventory() then
            if destination and destination:getType() == "OMHTTController" then
                host = destination:getParent()
            else
                bag = destination and destination:getContainingItem()
                if not bag then return nativeTransfer(self, player, item, source, destination, time) end
            end
        end
        local action = actionType:new(player, pokeStorage:getParent(), "Battery", pokeIn == true, item, nil, host, bag)
        action.srcContainer, action.destContainer = source, destination
        return action
    end
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
                local actionType = require("OMHTT/TurretTransferAction")
                actionType.setOnComplete = ISInventoryTransferAction.setOnComplete
                local action = actionType:new(player, turret, item, not incoming, record.id, nil, nil, incoming, object)
                action.srcContainer, action.destContainer = source, destination
                return action
            end
        end
        local bag
        if not incoming and destination ~= player:getInventory() then
            bag = destination and destination:getContainingItem() or false
        end
        return Transfer:new(player, object, item, incoming == true, state.id, bag)
    end
    return nativeTransfer(self, player, item, source, destination, time)
end

---@param object IsoObject Replicated or loaded sensor
---@return nil
function U.passive(object)
    if not isClient() or not instanceof(object, "IsoThumpable") then return end
    local state = A.state(object)
    if state then
        C.passive(object, state.kind)
    end
end

---@param square IsoGridSquare Loaded square
---@return nil
function U.loaded(square)
    if not isClient() then return end
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        U.passive(objects:get(i))
    end
end

if isClient() then
    Events.LoadGridsquare.Add(U.loaded)
    Events.OnObjectAdded.Add(U.passive)
end
Events.OnFillInventoryObjectContextMenu.Add(U.inventory)
---@param object IsoObject Native world pick
---@return nil
function U.clicked(object)
    local state = A.state(object)
    if not state or state.kind ~= "Button" then return end
    local player = getSpecificPlayer(0)
    if not player or player:isDead() or getCell():getDrag(0) then return end
    if luautils.walkAdjObject(player, object, false) then
        U.command(player, object, "Pulse")
    end
end
Events.OnObjectLeftMouseButtonDown.Add(U.clicked)
Events.OnFillWorldObjectContextMenu.Add(U.world)
return U

