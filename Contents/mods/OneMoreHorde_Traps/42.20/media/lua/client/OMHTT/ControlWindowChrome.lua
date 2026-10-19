if isServer() then return end
require("ISUI/ISButton")
local C = {}

---@param panel ISPanel Managed window
---@return nil
function C.arrange(panel)
    if not panel.lockButton then return end
    if panel.chromeWidth == panel.width and panel.chromeTitleHeight == panel.titleHeight then return end
    panel.chromeWidth, panel.chromeTitleHeight = panel.width, panel.titleHeight
    local size = panel.titleHeight - 8
    panel.closeButton:setX(4)
    panel.closeButton:setY(4)
    panel.closeButton:setWidth(size)
    panel.closeButton:setHeight(size)
    panel.pinButton:setX(panel.width - size - 4)
    panel.lockButton:setX(panel.width - size * 2 - 8)
end

---@param panel ISPanel Managed window
---@return nil
function C.update(panel)
    if not panel.lockButton then return end
    C.arrange(panel)
    local inside = (panel:isMouseOver() and (not panel.chromeCollapsed or panel:getMouseY() < panel.titleHeight)) or panel.moving or panel.resizeGrip.resizing
    if panel.pinned or inside then
        panel.collapseAt = nil
        if panel.chromeCollapsed then
            panel.chromeCollapsed = false
            panel:clearMaxDrawHeight()
        end
    elseif not panel.chromeCollapsed then
        panel.collapseAt = panel.collapseAt or getTimestampMs() + 700
        if getTimestampMs() >= panel.collapseAt then
            panel.chromeCollapsed = true
            panel:setMaxDrawHeight(panel.titleHeight)
        end
    end
end

---@param panel ISPanel Managed window
---@return nil
function C.install(panel)
    panel.backgroundColor = {r = 0, g = 0, b = 0, a = .8}
    panel.borderColor = {r = .4, g = .4, b = .4, a = 1}
    panel.titleTexture = getTexture("media/ui/Panel_TitleBar.png")
    panel.pinned, panel.keepOpen = true, false
    local size = panel.titleHeight - 8
    local lock = ISButton:new(0, 4, size, size, "", panel, function(owner)
        owner.keepOpen = not owner.keepOpen
        owner.lockButton:setImage(getTexture(owner.keepOpen and "media/ui/inventoryPanes/Button_Lock.png" or "media/ui/inventoryPanes/Button_LockOpen.png"))
    end)
    local pin = ISButton:new(0, 4, size, size, "", panel, function(owner)
        owner.pinned = not owner.pinned
        owner.pinButton:setImage(getTexture(owner.pinned and "media/ui/inventoryPanes/Button_Collapse.png" or "media/ui/inventoryPanes/Button_Pin.png"))
        C.update(owner)
    end)
    lock:initialise()
    pin:initialise()
    panel.lockButton, panel.pinButton = lock, pin
    panel:addChild(lock)
    panel:addChild(pin)
    lock:setImage(getTexture("media/ui/inventoryPanes/Button_LockOpen.png"))
    pin:setImage(getTexture("media/ui/inventoryPanes/Button_Collapse.png"))
    panel.closeButton:setTitle("")
    panel.closeButton:setImage(getTexture("media/ui/inventoryPanes/Button_Close.png"))
    lock.tooltip = getText("UI_OMHTT_KeepOpenHelp")
    pin.tooltip = getText("UI_OMHTT_PinHelp")
    panel.closeButton.tooltip = getText("UI_OMHTT_CloseHelp")
    local buttons = {lock, pin, panel.closeButton}
    for i = 1, #buttons do
        local button = buttons[i]
        button.borderColor = {r = 0, g = 0, b = 0, a = 0}
        button.backgroundColor = {r = 0, g = 0, b = 0, a = 0}
        button.backgroundColorMouseOver = {r = .4, g = .4, b = .4, a = .4}
    end
    C.arrange(panel)
end

return C
