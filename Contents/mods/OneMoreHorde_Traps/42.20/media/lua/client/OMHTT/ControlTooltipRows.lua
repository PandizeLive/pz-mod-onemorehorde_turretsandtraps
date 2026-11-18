if isServer() then return end
local R = {}
local grey = {r = .8, g = .8, b = .8}
local white = {r = 1, g = 1, b = 1}

---@param panel ISToolTipInv Native tooltip
---@param description string Semantic rows separated by newlines
---@param battery table? Consumption rating
---@param rarity table? Rarity color
---@return nil
function R.footer(panel, description, battery, rarity)
    local tip, measure = panel.tooltip, getTextManager()
    local font, spacing = tip:getFont(), tip:getLineSpacing()
    local batteryPrefix = getText("UI_OMHTT_HeadBattery", "")
    local featurePrefix = getText("UI_OMHTT_ModuleFeature", "")
    local rarityPrefix = getText("UI_OMHTT_ModuleRarity", "")
    local cached = panel.OMHTTRows
    if not cached or cached.description ~= description or cached.font ~= font or cached.spacing ~= spacing then
        cached = {description = description, font = font, spacing = spacing, lines = {}, width = 0}
        local rows = string.split(description, "\n")
        for i = 1, #rows do
            local text = rows[i]
            local kind = "normal"
            if string.sub(text, 1, #featurePrefix) == featurePrefix
                then
                kind = "feature"
            end
            if string.sub(text, 1, #rarityPrefix) == rarityPrefix then kind = "rarity" end
            if string.sub(text, 1, #batteryPrefix) == batteryPrefix then kind = "battery" end
            local lines = string.split(measure:WrapText(font, text, 350), "\n")
            for j = 1, #lines do
                local line = {text = lines[j], kind = kind}
                if kind == "battery" and j == 1 and string.sub(line.text, 1, #batteryPrefix) == batteryPrefix then
                    line.value = string.sub(line.text, #batteryPrefix + 1)
                    line.offset = measure:MeasureStringX(font, line.text) - measure:MeasureStringX(font, line.value)
                end
                cached.lines[#cached.lines + 1] = line
                cached.width = math.max(cached.width, measure:MeasureStringX(font, line.text) + 12)
            end
        end
        panel.OMHTTRows = cached
    end
    local height = panel:getHeight()
    local width = math.max(panel:getWidth(), cached.width)
    local total = height + #cached.lines * spacing + 8
    panel:setWidth(width)
    panel:setX(math.max(0, math.min(panel:getX(), getCore():getScreenWidth() - width - 1)))
    panel:setY(math.max(0, math.min(panel:getY(), getCore():getScreenHeight() - total - 1)))
    tip:setX(panel:getX()); tip:setY(panel:getY())
    panel:drawRect(0, 0, width, height, panel.backgroundColor.a, panel.backgroundColor.r, panel.backgroundColor.g, panel.backgroundColor.b)
    local original = panel.item:getTooltip()
    panel.item:setTooltip(nil)
    panel.item:DoTooltip(tip)
    panel.item:setTooltip(original)
    panel:setHeight(total)
    panel:drawRect(0, height, width, total - height, panel.backgroundColor.a, panel.backgroundColor.r, panel.backgroundColor.g, panel.backgroundColor.b)
    panel:drawRectBorder(0, 0, width, total, panel.borderColor.a, panel.borderColor.r, panel.borderColor.g, panel.borderColor.b)
    for i = 1, #cached.lines do
        local row = cached.lines[i]
        local color = row.kind == "feature" and white or grey
        if row.kind == "rarity" and rarity then color = {r = rarity.tr, g = rarity.tg, b = rarity.tb} end
        local y = height + 4 + (i - 1) * spacing
        if row.kind == "battery" and battery then
            if row.value then
                panel:drawText(batteryPrefix, 5, y, grey.r, grey.g, grey.b, 1, font)
                panel:drawText(row.value, 5 + row.offset, y, battery.r, battery.g, battery.b, 1, font)
            else
                panel:drawText(row.text, 5, y, battery.r, battery.g, battery.b, 1, font)
            end
        else
            panel:drawText(row.text, 5, y, color.r, color.g, color.b, 1, font)
        end
    end
end

return R
