if isServer() then return end
local G = {}
local T = require("OMHTT/Turret")

---@param control ISUIElement Child
---@param x number Left
---@param y number Top
---@param width number Width
---@return nil
local function place(control, x, y, width)
    control:setX(x)
    control:setY(y)
    control:setWidth(width)
end

---@param panel ISPanel Manage window
---@return boolean changed
function G.apply(panel)
    local screen = getPlayerScreenHeight(panel.player:getPlayerNum())
    if panel.geometryWidth == panel.width and panel.geometryHeight == panel.height and panel.geometryScreen == screen then return false end
    panel.geometryWidth, panel.geometryHeight = panel.width, panel.height
    panel.geometryScreen = screen
    local h, width = panel.lineHeight, panel.width
    panel.body:setWidth(width - 12)
    panel.nameEntry:setWidth(width - math.max(156, getTextManager():MeasureStringX(UIFont.Small, "Weight: 9999.9 !") + 16) - 24)
    if panel.closeButton then
        panel.closeButton:setX(width - 34)
    end
    local rowWidth = panel.body.width - 12
    panel.equipmentWidth = math.floor((rowWidth - 8) * .40)
    panel.ammunitionX = panel.equipmentWidth + 12
    panel.ammunitionWidth = panel.body.width - 8 - panel.ammunitionX
    local equipment = panel.equipmentWidth - 8
    local ammoX, ammoWidth = panel.ammunitionX + 4, panel.ammunitionWidth - 8
    local slot = math.max(54, h * 3 + 6)
    local top, second = 4 + panel.headerHeight + 6, 4 + panel.headerHeight + slot + 14
    local head = math.floor((equipment - 6) * .60)
    place(panel.headSlot, 8, top, head)
    place(panel.capacitySlot, 14 + head, top, equipment - head - 6)
    place(panel.batterySlot, 8, second, equipment - 60)
    place(panel.powerButton, 8 + equipment - 54, second, 54)
    place(panel.ammoSlot, ammoX, top, (ammoWidth - 8) / 2)
    place(panel.voidSlot, ammoX + (ammoWidth + 8) / 2, top, (ammoWidth - 8) / 2)
    place(panel.magazineSlot, ammoX, second, ammoWidth)
    local buttonY = second + slot + 6
    place(panel.loadOrderButton, ammoX + ammoWidth - panel.loadOrderButton.width, buttonY, panel.loadOrderButton.width)
    place(panel.reloadButton, panel.loadOrderButton.x - panel.reloadButton.width - 6, buttonY, panel.reloadButton.width)
    if panel.sourceButton then
        place(panel.sourceButton, 8, buttonY, (equipment - 6) / 2)
        place(panel.setAimButton, 8 + (equipment + 6) / 2, buttonY, (equipment - 6) / 2)
    end
    panel.equipmentBottom = buttonY + panel.reloadButton.height + 6
    panel.ammunitionBottom = panel.equipmentBottom
    panel.modulesY = panel.equipmentBottom + 10
    local columns, rows = 8, 3
    local moduleWidth = (rowWidth - 50) / columns
    local moduleTop = panel.modulesY + panel.headerHeight + 6
    local available = (panel.userSized and panel.height or screen - 24) - panel.body.y - moduleTop - h * 3 - 140
    local moduleHeight = math.max(h + 8, math.min(h * 2 + 16, math.floor(available / rows) - 4))
    if panel.detailsOpen and panel.normalModuleHeight then
        moduleHeight = panel.normalModuleHeight
    else
        panel.normalModuleHeight = moduleHeight
    end
    panel.minimumGridBottom = moduleTop + rows * (h + 12)
    for i = 1, 16 do
        local row = i <= 4 and 0 or 1 + math.floor((i - 5) / columns)
        local column = i <= 4 and i - 1 or (i - 5) % columns
        local count = row == 1 and 8 or 4
        local inset = (rowWidth - (count * moduleWidth + (count - 1) * 6)) / 2
        place(panel.moduleSlots[i], 4 + inset + column * (moduleWidth + 6), moduleTop + row * (moduleHeight + 4), moduleWidth)
        panel.moduleSlots[i]:setHeight(moduleHeight)
    end
    panel.moduleGridBottom = moduleTop + rows * (moduleHeight + 4)
    panel.detailsButton:setX(panel.body.width - panel.detailsButton.width - 8)
    place(panel.equipmentHelp, 4, 4, panel.equipmentWidth)
    place(panel.ammunitionHelp, panel.ammunitionX, 4, panel.ammunitionWidth)
    place(panel.modulesHelp, 4, panel.modulesY, rowWidth)
    local sliderX = math.min(width - 320, 28 + getTextManager():MeasureStringX(UIFont.Small, getText("UI_OMHTT_EngagementRange", getText("UI_OMHTT_RangeMax"))))
    place(panel.rangeSlider, sliderX, panel.rangeSlider.y, width - sliderX - 24)
    place(panel.landingSlider, sliderX, panel.landingSlider.y, width - sliderX - 24)
    place(panel.lureSlider, sliderX, panel.lureSlider.y, width - sliderX - 168)
    panel.lurePlay:setX(width - 156)
    panel.lureLoop:setX(width - 86)
    panel.priorityButton:setWidth(width - panel.priorityButton.x - 12)
    return true
end

return G
