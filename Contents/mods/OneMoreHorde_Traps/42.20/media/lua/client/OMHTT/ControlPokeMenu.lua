if isServer() then return end
require("ISUI/ISContextMenu")
require("TimedActions/ISTimedActionQueue")
local Action = require("OMHTT/ControlPokeAction")
local Access = require("OMHTT/ControlAccess")
local Battery = require("OMHTT/TurretBattery")
local M = {}

function M.add(menu, player, object)
    local state = Access.state(object)
    if not state or state.kind ~= "Poke" then return end
    local function add(label, operation, value, item)
        local action = Action:new(player, object, operation, value, item)
        local option = menu:addOption(label, action, function(selected) ISTimedActionQueue.add(selected) end)
        option.notAvailable = not action:isValid()
        if operation == "Repair" then
            require("OMHTT/ControlRepairTooltip").bind(option, "Poke", player)
        end
    end
    add(getText(state.enabled == false and "UI_OMHTT_PokeEnable" or "UI_OMHTT_PokeDisable"), "Power", state.enabled == false)
    local storage = object:getContainer()
    local battery = storage and storage:getItems():size() > 0 and storage:getItems():get(0)
    if battery then
        add(getText("UI_OMHTT_PokeRemoveBattery", math.floor(Battery.charge(battery) * 100)), "Battery", false, battery)
    end
    add(getText("UI_OMHTT_ControlRepair"), "Repair")
    add(getText("UI_OMHTT_ControlPickup"), "Pickup")
end

function M.open(player, object)
    local menu = ISContextMenu.get(player:getPlayerNum(), getMouseX(), getMouseY())
    M.add(menu, player, object)
    menu:setAlwaysOnTop(true)
    menu:bringToTop()
end

return M
