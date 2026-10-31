if isServer() then return end
require("ISUI/ISContextMenu")
require("TimedActions/ISTimedActionQueue")
local Action = require("OMHTT/ControlAction")
local Access = require("OMHTT/ControlAccess")
local M = {}

---@param menu ISContextMenu Menu
---@param player IsoPlayer Operator
---@param object IsoObject Trap
---@return nil
function M.add(menu, player, object)
    local state = Access.state(object)
    if not state or state.kind ~= "Tether" then return end
    ---@param label string Caption
    ---@param command string Operation
    ---@param value boolean? Enabled state
    ---@return nil
    local function add(label, command, value)
        local action = Action:new(player, object, command, value)
        local option = menu:addOption(label, action, function(selected) ISTimedActionQueue.add(selected) end)
        option.notAvailable = not action:isValid()
        if command == "Repair" then
            require("OMHTT/ControlRepairTooltip").bind(option, "Tether", player)
        end
    end
    add(getText(state.enabled == false and "UI_OMHTT_TetherEnable" or "UI_OMHTT_TetherDisable"), "TetherEnabled", state.enabled == false)
    local targeting = menu:addOption(getText("UI_OMHTT_TargetingLabel"), nil, nil)
    local submenu = ISContextMenu:getNew(menu)
    menu:addSubMenu(targeting, submenu)
    require("OMHTT/ControlTargetingUI").populate(submenu, player, object)
    add(getText("UI_OMHTT_ControlRepair"), "Repair")
    add(getText("UI_OMHTT_ControlPickup"), "Pickup")
end

---@param player IsoPlayer Operator
---@param object IsoObject Trap
---@return nil
function M.open(player, object)
    local menu = ISContextMenu.get(player:getPlayerNum(), getMouseX(), getMouseY())
    M.add(menu, player, object)
    menu:setAlwaysOnTop(true)
    menu:bringToTop()
end

return M
