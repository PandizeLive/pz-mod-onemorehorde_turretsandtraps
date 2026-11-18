local R = require("OMHTT/TurretRarity")
local U = {}

---@param panel ISToolTipInv Native inventory tooltip
---@param component string Module identity
---@return nil
function U.footer(panel, component)
    local tip = panel.tooltip
    local height, spacing = panel:getHeight(), tip:getLineSpacing()
    local description, headRating
    if component and string.sub(component, 1, 6) == "Manual" then
        description = getText("UI_OMHTT_ModuleRarity", getText("UI_OMHTT_Rarity" .. R.get(component).band))
    elseif component then
        description = require("OMHTT/TurretDescriptions").get(component, false)
        if component == "Void" then
            description = description .. "\n" .. require("OMHTT/TurretVoid").description(panel.item)
        end
    else
        description, headRating = require("OMHTT/TurretHeadDescription").get(panel.item)
    end
    require("OMHTT/ControlTooltipRows").footer(panel, description, headRating, component and R.get(component))
end

return U
