local R = require("OMHTT/TurretRarity")
local U = {}

---@param panel ISToolTipInv Native inventory tooltip
---@param component string Module identity
---@return nil
function U.footer(panel, component)
    local tip = panel.tooltip
    local height, spacing = panel:getHeight(), tip:getLineSpacing()
    local description, headRating
    if component then
        description = require("OMHTT/TurretDescriptions").get(component, false)
        if component == "Void" then
            description = description .. "\n" .. require("OMHTT/TurretVoid").description(panel.item)
        end
    else
        description, headRating = require("OMHTT/TurretHeadDescription").get(panel.item)
    end
    local font, originalWidth = tip:getFont(), panel:getWidth()
    local batteryPrefix = getText("UI_OMHTT_HeadBattery", "")
    local layout = panel.OMHTTFooterLayout
    if not layout or layout.description ~= description or layout.font ~= font then
        layout = {description = description, font = font, width = 0, lines = string.split(description, "\n")}
        for i = 1, #layout.lines do
            local line = layout.lines[i]
            local width = getTextManager():MeasureStringX(font, line)
            layout.width = math.max(layout.width, width + 12)
            if headRating and string.sub(line, 1, #batteryPrefix) == batteryPrefix then
                layout.batteryLine = i
                layout.batteryValue = string.sub(line, #batteryPrefix + 1)
                -- Native final-glyph bounds omit trailing-space advance in the prefix alone.
                layout.batteryOffset = width - getTextManager():MeasureStringX(font, layout.batteryValue)
            end
        end
        panel.OMHTTFooterLayout = layout
    end
    local lines = layout.lines
    local required = math.max(originalWidth, layout.width)
    panel:setWidth(required)
    panel:setX(math.max(0, math.min(panel:getX(), getCore():getScreenWidth() - required - 1)))
    tip:setX(panel:getX())
    local total = height + spacing * #lines + 8
    local top = math.max(0, math.min(panel:getY(), getCore():getScreenHeight() - total - 1))
    if top ~= panel:getY() or required ~= originalWidth then
        panel:setY(top)
        tip:setY(top)
        panel:drawRect(0, 0, panel:getWidth(), height, panel.backgroundColor.a, panel.backgroundColor.r, panel.backgroundColor.g, panel.backgroundColor.b)
        panel.item:DoTooltip(tip)
    end
    panel:setHeight(total)
    panel:drawRect(0, height, panel:getWidth(), spacing * #lines + 8, panel.backgroundColor.a, panel.backgroundColor.r, panel.backgroundColor.g, panel.backgroundColor.b)
    panel:drawRectBorder(0, 0, panel:getWidth(), total, panel.borderColor.a, panel.borderColor.r, panel.borderColor.g, panel.borderColor.b)
    local rarity = component and R.get(component)
    for i = 1, #lines do
        local colored = rarity and string.find(lines[i], getText("UI_OMHTT_ModuleRarity", ""), 1, true) ~= nil
        local y = height + 4 + (i - 1) * spacing
        if headRating and layout.batteryLine == i then
            panel:drawText(batteryPrefix, 5, y, 1, 1, 1, 1, font)
            panel:drawText(layout.batteryValue, 5 + layout.batteryOffset,
                y, headRating.r, headRating.g, headRating.b, 1, font)
        else
            panel:drawText(lines[i], 5, y,
                colored and rarity.tr or 1, colored and rarity.tg or 1, colored and rarity.tb or 1, 1, font)
        end
    end
end

return U
