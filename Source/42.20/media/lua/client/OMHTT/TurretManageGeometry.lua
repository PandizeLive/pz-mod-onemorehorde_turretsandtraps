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
    if panel.geometryWidth == panel.width and panel.geometryHeight == panel.height and panel.geometryScreen == screen and panel.geometryDetails == panel.detailsOpen
        and panel.geometryLure == panel.hasLure and panel.geometryLanding == panel.hasLanding
        and panel.geometryLineHeight == panel.lineHeight and panel.geometryDetailCount == #(panel.detailLines or {}) then return false end
    panel.geometryLineHeight, panel.geometryDetailCount = panel.lineHeight, #(panel.detailLines or {})
    panel.geometryWidth, panel.geometryHeight = panel.width, panel.height
    panel.geometryScreen, panel.geometryDetails = screen, panel.detailsOpen
    panel.geometryLure, panel.geometryLanding = panel.hasLure, panel.hasLanding
    local h, width = panel.lineHeight, panel.width
    panel.body:setWidth(width - 12)
    panel.nameEntry:setWidth(width - math.max(156, getTextManager():MeasureStringX(UIFont.Small, "Weight: 9999.9 !") + 16) - 24)
    local rowWidth = panel.body.width - 12
    panel.equipmentWidth = math.floor((rowWidth - 8) * .50)
    panel.ammunitionX = panel.equipmentWidth + 12
    panel.ammunitionWidth = panel.body.width - 8 - panel.ammunitionX
    local equipment = panel.equipmentWidth - 8
    local ammoX, ammoWidth = panel.ammunitionX + 4, panel.ammunitionWidth - 8
    local compact = screen < 900
    panel.compactModuleActions = compact
    local slot = math.max(54, h * 3 + (compact and 0 or 6))
    local equipmentSlots = {panel.headSlot, panel.capacitySlot, panel.batterySlot, panel.ammoSlot, panel.voidSlot, panel.magazineSlot, panel.powerButton}
    for i = 1, #equipmentSlots do
        equipmentSlots[i]:setHeight(slot)
    end
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
        panel.sourceButton:setHeight(panel.reloadButton.height)
        panel.setAimButton:setHeight(panel.reloadButton.height)
        place(panel.sourceButton, 8, buttonY, (equipment - 6) / 2)
        place(panel.setAimButton, 8 + (equipment + 6) / 2, buttonY, (equipment - 6) / 2)
    end
    panel.equipmentBottom = buttonY + panel.reloadButton.height + 6
    panel.ammunitionBottom = panel.equipmentBottom
    panel.modulesY = panel.equipmentBottom + 10
    local columns, rows = 4, 4
    local moduleTop = panel.modulesY + panel.headerHeight + h + 8
    local details = panel.detailsOpen and math.max(h * 4 + 16, h * (#(panel.detailLines or {}) + 3) + 16) + 8 or 0
    local available = (panel.userSized and panel.height or screen - 24) - panel.body.y - moduleTop - h * 3 - 140 - details
    local minimum = h + 8
    local moduleHeight = math.max(minimum, math.min(h * 2 + 16, math.floor(available / rows) - 4))
    panel.normalModuleHeight = moduleHeight
    panel.minimumGridBottom = moduleTop + rows * (minimum + 4)
    local moduleWidth = math.min(108, math.max(moduleHeight, math.floor((rowWidth - 18) / columns)))
    for i = 1, 16 do
        local row = math.floor((i - 1) / columns)
        local column = (i - 1) % columns
        local count = columns
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
    local remaining = width - panel.priorityButton.x - 20
    panel.priorityButton:setWidth(math.floor(remaining / 2))
    place(panel.targetingButton, panel.priorityButton.x + panel.priorityButton.width + 8, panel.priorityButton.y,
        remaining - panel.priorityButton.width)
    return true
end

return G
