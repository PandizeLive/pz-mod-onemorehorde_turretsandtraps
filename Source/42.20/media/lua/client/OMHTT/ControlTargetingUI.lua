if isServer() then return end
require("ISUI/ISContextMenu")
local Access = require("OMHTT/ControlAccess")
local Policy = require("OMHTT/ControlTargeting")
local U = {}

---@param state table? Public device snapshot
---@return string caption
function U.caption(state)
    local mode = state and state.targeting or "Inherit"
    if state and state.kind == "Controller" and not state.targeting then
        mode = "Zombies"
    end
    return getText("UI_OMHTT_Targeting", getText("UI_OMHTT_Target" .. mode))
end

---@param menu ISContextMenu Native menu
---@param player IsoPlayer Operator
---@param object IsoObject Defense
---@return nil
function U.populate(menu, player, object)
    local state = Access.state(object)
    if not state or not Policy.supported(state.kind) then return end
    local modes = {"Zombies", "OtherFactions"}
    if state.kind ~= "Controller" then
        modes[#modes + 1] = "Inherit"
    end
    for i = 1, #modes do
        local mode = modes[i]
        local option = menu:addOption(getText("UI_OMHTT_Target" .. mode), object, function(target, value)
            require("OMHTT/ControlClient").command(player, target, "Targeting", value)
        end, mode)
        option.notAvailable = not Access.authorized(player, object) or not Access.write(player, state)
    end
end

---@param player IsoPlayer Operator
---@param object IsoObject Selected device
---@return nil
function U.open(player, object)
    local menu = ISContextMenu.get(player:getPlayerNum(), getMouseX(), getMouseY())
    U.populate(menu, player, object)
    menu:setAlwaysOnTop(true)
    menu:bringToTop()
end

---@param button ISButton Menu control
---@param player IsoPlayer Operator
---@param object IsoObject? Selection
---@return nil
function U.refresh(button, player, object)
    local state = object and Access.state(object)
    local supported = state and Policy.supported(state.kind)
    button:setVisible(supported == true)
    button:setEnable(supported and Access.authorized(player, object) and Access.write(player, state) or false)
    button:setTitle(U.caption(state))
    local effective = state and state.targetingEffective or "Zombies"
    if state and not isClient() then
        local records = require("OMHTT/ControlWorld").records().records
        effective = Policy.resolve(state, state.controller and records[state.controller])
    end
    button.tooltip = getText("UI_OMHTT_TargetingHelp", getText("UI_OMHTT_Target" .. effective))
end

return U
