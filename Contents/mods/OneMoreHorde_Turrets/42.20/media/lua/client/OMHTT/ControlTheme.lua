if isServer() then return end
local Theme = {
    accent = {r = 231 / 255, g = 160 / 255, b = 90 / 255, a = 1},
    surface = {r = 48 / 255, g = 37 / 255, b = 27 / 255, a = 1},
    hover = {r = .30, g = .21, b = .13, a = 1},
    on = {r = .08, g = .42, b = .16, a = .95},
    off = {r = .48, g = .08, b = .08, a = .95},
    onHover = {r = .12, g = .58, b = .22, a = 1},
    offHover = {r = .65, g = .12, b = .12, a = 1},
}

---@param button ISButton Control
---@return nil
function Theme.button(button)
    button.backgroundColor = {r = Theme.surface.r, g = Theme.surface.g, b = Theme.surface.b, a = 1}
    button.backgroundColorEnabled = {r = Theme.surface.r, g = Theme.surface.g, b = Theme.surface.b, a = 1}
    button.backgroundColorMouseOver = Theme.hover
end

---@param button ISButton Power control
---@param powered boolean Current switch state
---@param enabled boolean Operator can change state
---@return nil
function Theme.power(button, powered, enabled)
    local color = powered and Theme.on or Theme.off
    button.backgroundColor = button.backgroundColor or {}
    button.backgroundColorEnabled = button.backgroundColorEnabled or {}
    local background, cached = button.backgroundColor, button.backgroundColorEnabled
    background.r, background.g, background.b, background.a = color.r, color.g, color.b, color.a
    cached.r, cached.g, cached.b, cached.a = color.r, color.g, color.b, color.a
    button.backgroundColorMouseOver = powered and Theme.onHover or Theme.offHover
    button:setEnable(enabled)
    background.r, background.g, background.b, background.a = color.r, color.g, color.b, color.a
end

---@param panel ISPanel Window
---@param key string Localized title suffix
---@return nil
function Theme.title(panel, key)
    panel:drawRect(1, 1, panel.width - 2, panel.titleHeight - 2, 1, .19, .145, .105)
    panel:setStencilRect(12, 4, panel.width - 60, panel.titleHeight - 4)
    local brand = getText("UI_OMHTT_Brand")
    panel:drawText(brand, 12, 8, .85, .25, .25, 1, UIFont.Medium)
    local x = 12 + getTextManager():MeasureStringX(UIFont.Medium, brand)
    panel:drawText(" - " .. getText(key), x, 8, 1, 1, 1, 1, UIFont.Medium)
    panel:clearStencilRect()
end

---@param panel ISPanel Section owner
---@param x number Left
---@param y number Top
---@param width number Width
---@param height number Height
---@param header number Title-strip height
---@param title string Caption
---@return nil
function Theme.section(panel, x, y, width, height, header, title)
    panel:drawRect(x, y, width, height, .98, .055, .05, .045)
    panel:drawRectBorder(x, y, width, height, .65, .30, .25, .20)
    panel:drawRect(x, y, width, header, 1, Theme.surface.r, Theme.surface.g, Theme.surface.b)
    panel:drawRect(x, y, 2, header, 1, Theme.accent.r, Theme.accent.g, Theme.accent.b)
    panel:drawText(title, x + 8, y + 4, .95, .90, .85, 1, UIFont.Small)
end

return Theme
