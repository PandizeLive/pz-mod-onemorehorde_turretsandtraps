local R = require("OMHTT/TurretRarity")
local U = {}

---@param panel ISToolTipInv Native inventory tooltip
---@param component string Module identity
---@return nil
function U.footer(panel, component)
    local tip = panel.tooltip
    local height, spacing = panel:getHeight(), tip:getLineSpacing()
    local description = require("OMHTT/TurretDescriptions").get(component, false)
    local font, width = tip:getFont(), panel:getWidth() - 10
    local layout = panel.OMHTTFooterLayout
    if not layout or layout.description ~= description or layout.font ~= font or layout.width ~= width then
        layout = {description = description, font = font, width = width,
            lines = string.split(getTextManager():WrapText(font, description, width), "\n")}
        panel.OMHTTFooterLayout = layout
    end
    local lines = layout.lines
    local total = height + spacing * #lines + 8
    local top = math.max(0, math.min(panel:getY(), getCore():getScreenHeight() - total - 1))
    if top ~= panel:getY() then
        panel:setY(top)
        tip:setY(top)
        panel:drawRect(0, 0, panel:getWidth(), height, panel.backgroundColor.a, panel.backgroundColor.r, panel.backgroundColor.g, panel.backgroundColor.b)
        panel.item:DoTooltip(tip)
    end
    panel:setHeight(total)
    panel:drawRect(0, height, panel:getWidth(), spacing * #lines + 8, panel.backgroundColor.a, panel.backgroundColor.r, panel.backgroundColor.g, panel.backgroundColor.b)
    panel:drawRectBorder(0, 0, panel:getWidth(), total, panel.borderColor.a, panel.borderColor.r, panel.borderColor.g, panel.borderColor.b)
    local rarity = R.get(component)
    for i = 1, #lines do
        local colored = i == #lines
        panel:drawText(lines[i], 5, height + 4 + (i - 1) * spacing,
            colored and rarity.tr or 1, colored and rarity.tg or 1, colored and rarity.tb or 1, 1, tip:getFont())
    end
end

return U
