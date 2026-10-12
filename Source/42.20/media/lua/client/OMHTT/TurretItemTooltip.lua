local R = require("OMHTT/TurretRarity")
local U = {}

---@param panel ISToolTipInv Native inventory tooltip
---@param component string Module identity
---@return nil
function U.footer(panel, component)
    local tip = panel.tooltip
    local height, spacing = panel:getHeight(), tip:getLineSpacing()
    local total = height + spacing + 8
    local top = math.max(0, math.min(panel:getY(), getCore():getScreenHeight() - total - 1))
    if top ~= panel:getY() then
        panel:setY(top)
        tip:setY(top)
        panel:drawRect(0, 0, panel:getWidth(), height, panel.backgroundColor.a, panel.backgroundColor.r, panel.backgroundColor.g, panel.backgroundColor.b)
        panel.item:DoTooltip(tip)
    end
    panel:setHeight(total)
    panel:drawRect(0, height, panel:getWidth(), spacing + 8, panel.backgroundColor.a, panel.backgroundColor.r, panel.backgroundColor.g, panel.backgroundColor.b)
    panel:drawRectBorder(0, 0, panel:getWidth(), total, panel.borderColor.a, panel.borderColor.r, panel.borderColor.g, panel.borderColor.b)
    local rarity = R.get(component)
    local label = getText("UI_OMHTT_ModuleRarity", getText("UI_OMHTT_Rarity" .. rarity.band))
    panel:drawText(label, 5, height + 4, rarity.tr, rarity.tg, rarity.tb, 1, tip:getFont())
end

return U
