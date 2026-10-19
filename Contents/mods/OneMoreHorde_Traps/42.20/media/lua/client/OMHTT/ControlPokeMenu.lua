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
    end
    add(getText(state.enabled == false and "UI_OMHTT_PokeEnable" or "UI_OMHTT_PokeDisable"), "Power", state.enabled == false)
    local storage = object:getContainer()
    local battery = storage and storage:getItems():size() > 0 and storage:getItems():get(0)
    if battery then
        add(getText("UI_OMHTT_PokeRemoveBattery", math.floor(Battery.charge(battery) * 100)), "Battery", false, battery)
    else
        local option = menu:addOption(getText("UI_OMHTT_PokeAddBattery"))
        local sub = ISContextMenu:getNew(menu)
        menu:addSubMenu(option, sub)
        local sources = {player:getInventory()}
        local controller = Access.stockpile(player, object)
        if controller then sources[#sources + 1] = controller:getContainer() end
        local found = 0
        for index = 1, #sources do
            local items = sources[index]:getItems()
            for i = 0, items:size() - 1 do
                local item = items:get(i)
                if Battery.car(item) and found < 32 then
                    found = found + 1
                    local action = Action:new(player, object, "Battery", true, item)
                    local row = sub:addOption(item:getDisplayName() .. " (" .. math.floor(Battery.charge(item) * 100) .. "%)", action,
                        function(selected) ISTimedActionQueue.add(selected) end)
                    row.notAvailable = not action:isValid()
                end
            end
        end
        option.notAvailable = found == 0 or state.enabled ~= false or state.active
    end
    add(getText("UI_OMHTT_PokeRepair"), "Repair")
    add(getText("UI_OMHTT_ControlPickup"), "Pickup")
end

function M.open(player, object)
    local menu = ISContextMenu.get(player:getPlayerNum(), getMouseX(), getMouseY())
    M.add(menu, player, object)
    menu:setAlwaysOnTop(true)
    menu:bringToTop()
end

return M
