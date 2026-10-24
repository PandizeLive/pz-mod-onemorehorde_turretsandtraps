if isServer() then return end
local Theme = {
    accent = {r = .70, g = .70, b = .70, a = 1},
    surface = {r = .16, g = .16, b = .16, a = 1},
    hover = {r = .24, g = .24, b = .24, a = 1},
    on = {r = .08, g = .42, b = .16, a = .95},
    off = {r = .48, g = .08, b = .08, a = .95},
    onHover = {r = .12, g = .58, b = .22, a = 1},
    offHover = {r = .65, g = .12, b = .12, a = 1},
}

---@param panel ISPanel Scrollable section
---@return nil
function Theme.scrollbar(panel)
    local bar = panel.vscroll
    if not bar then return end
    bar:setAnchorRight(false)
    bar:setAnchorBottom(false)
    bar:setX(panel.width - 17)
    bar:setY(0)
    bar:setWidth(17)
    bar:setHeight(panel.height)
    bar.doSetStencil = false
end

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
    require("OMHTT/ControlWindowChrome").arrange(panel)
    Theme.gradient = panel.titlebarbkg
    panel:drawTextureScaled(panel.titlebarbkg, 2, 1, panel.width - 4, panel.titleHeight - 2, 1, 1, 1, 1)
    panel:drawRect(1, panel.titleHeight - 1, panel.width - 2, 1, 1, .35, .35, .35)
    local footer = panel.footerHeight
    panel:drawRect(1, panel.height - footer, panel.width - 2, footer - 1, .95, .08, .08, .08)
    panel:drawRect(1, panel.height - footer, panel.width - 2, 1, 1, .3, .3, .3)
    local left = panel.closeButton.x + panel.closeButton.width + 6
    panel:setStencilRect(left, 1, panel.width - left - 8, panel.titleHeight - 2)
    local brand = getText("UI_OMHTT_Brand")
    panel:drawText(brand, left, 1, .85, .25, .25, 1, UIFont.Small)
    local x = left + getTextManager():MeasureStringX(UIFont.Small, brand)
    panel:drawText(" - " .. getText(key), x, 1, 1, 1, 1, 1, UIFont.Small)
    panel:clearStencilRect()
end

---@param panel ISPanel Drawing owner
---@param x number Left
---@param y number Top
---@param width number Width
---@param height number Height
---@return nil
function Theme.header(panel, x, y, width, height)
    if width <= 0 or height <= 0 then return end
    panel:drawRect(x, y, width, height, 1, .19, .20, .18)
    if Theme.gradient then
        panel:drawTextureScaled(Theme.gradient, x, y, width, height, .45, 1, 1, 1)
    end
    panel:drawRect(x, y, width, 1, .55, .43, .45, .40)
    panel:drawRect(x, y + height - 1, width, 1, 1, .28, .30, .25)
end

---@param panel ISPanel Drawing owner
---@param x number Left
---@param y number Top
---@param width number Width
---@param height number Height
---@param remaining number Remaining resource fraction
---@return nil
function Theme.meter(panel, x, y, width, height, remaining)
    if width <= 0 or height <= 0 then return end
    local fraction = 0
    if type(remaining) == "number" and remaining == remaining then
        fraction = math.max(0, math.min(1, remaining))
    end
    panel:drawRect(x, y, width, height, 1, .14, .16, .12)
    local fill = width * fraction
    if fill <= 0 then return end
    local red, green, blue = .46, .59, .35
    if fraction <= .1 then
        red, green, blue = .74, .29, .22
    elseif fraction <= .25 then
        red, green, blue = .76, .55, .27
    end
    panel:drawRect(x, y, fill, height, 1, red, green, blue)
    if Theme.gradient then
        panel:drawTextureScaled(Theme.gradient, x, y, fill, height, .22, 1, 1, 1)
    end
    panel:drawRect(x, y, fill, math.min(1, height), .3, 1, 1, 1)
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
    panel:drawRect(x, y, width, height, .88, .055, .055, .055)
    panel:drawRectBorder(x, y, width, height, .65, .30, .30, .30)
    Theme.header(panel, x, y, width, header)
    panel:drawText(title, x + 8, y + 4, .95, .95, .95, 1, UIFont.Small)
end

return Theme
