if isServer() then return end
require("ISUI/ISWorldObjectContextMenu")
local R = require("OMHTT/ControlRepair")
local U = {}

---@param kind string Repair profile
---@param player IsoPlayer Operator
---@param toolsReady boolean? Whether required retained tools are available
---@return string description Native rich text
function U.description(kind, player, toolsReady)
    local profile = R.profiles[kind]
    local lines = {}
    if profile.material then
        local color = #R.materials(player, kind) > 0 and " <RGB:0.3,0.9,0.3> " or " <RGB:1,0.3,0.3> "
        lines[#lines + 1] = color .. getText("UI_OMHTT_RepairMaterialRequired", getItemNameFromFullType(profile.material), 1)
    end
    local ready = toolsReady ~= false and R.tools(player, kind)
    local color = ready and " <RGB:0.3,0.9,0.3> " or " <RGB:1,0.3,0.3> "
    lines[#lines + 1] = color .. getText("UI_OMHTT_RepairToolRequired", getText(profile.tools))
    lines[#lines + 1] = " <RGB:1,1,1> " .. getText("UI_OMHTT_RepairTime", profile.seconds)
    return table.concat(lines, " <LINE> ")
end

---@param option table Native context option
---@param kind string Repair profile
---@param player IsoPlayer Operator
---@param toolsReady boolean? Whether required retained tools are available
---@return nil
function U.bind(option, kind, player, toolsReady)
    option.toolTip = ISWorldObjectContextMenu.addToolTip()
    option.toolTip.description = U.description(kind, player, toolsReady)
end

return U
