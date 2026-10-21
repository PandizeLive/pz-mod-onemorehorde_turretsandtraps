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
    local materials = getText("UI_OMHTT_RepairNone")
    if profile.material then
        materials = getText("UI_OMHTT_RepairMaterial", getItemNameFromFullType(profile.material), #R.materials(player, kind))
    end
    local tools = getText(profile.tools)
    if toolsReady == false or not R.tools(player, kind) then
        tools = tools .. " - " .. getText("UI_OMHTT_RepairToolsMissing")
    end
    local lines = {
        getText("UI_OMHTT_RepairMaterials", materials),
        getText("UI_OMHTT_RepairTools", tools),
        getText("UI_OMHTT_RepairSkills"),
        getText("UI_OMHTT_RepairTime", profile.seconds),
        getText(kind == "Turret" and "UI_OMHTT_RepairBaseResult" or "UI_OMHTT_RepairResult"),
    }
    if kind == "Poke" then
        lines[#lines + 1] = getText("UI_OMHTT_RepairPokeAccess")
    end
    if profile.material then
        lines[#lines + 1] = getText("UI_OMHTT_RepairMaterialSource")
    end
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
