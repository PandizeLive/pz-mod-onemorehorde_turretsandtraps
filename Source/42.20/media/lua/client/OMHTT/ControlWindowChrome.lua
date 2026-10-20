if isServer() then return end
local C = {}

---@param panel ISPanel Managed window
---@return nil
function C.arrange(panel)
    if not panel.closeButton then return end
    local size = panel.titleHeight - 2
    panel.closeButton:setX(1)
    panel.closeButton:setY((panel.titleHeight - size) / 2)
    panel.closeButton:setWidth(size)
    panel.closeButton:setHeight(size)
    if panel.resizeGrip then
        panel.resizeGrip:setX(panel.width - panel.resizeGrip.width)
        panel.resizeGrip:setY(panel.height - panel.resizeGrip.height)
    end
end

---@param panel ISPanel Managed window
---@return nil
function C.update(panel)
    C.arrange(panel)
end

---@param panel ISPanel Managed window
---@return nil
function C.install(panel)
    panel.titlebarbkg = getTexture("media/ui/Panel_TitleBar.png")
    panel.backgroundColor = {r = 0, g = 0, b = 0, a = .9}
    panel.borderColor = {r = .4, g = .4, b = .4, a = 1}
    panel.closeButton:setTitle("")
    panel.closeButton:setImage(getTexture("media/ui/inventoryPanes/Button_Close.png"))
    panel.closeButton.tooltip = getText("UI_OMHTT_CloseHelp")
    panel.closeButton.borderColor = {r = 0, g = 0, b = 0, a = 0}
    panel.closeButton.backgroundColor = {r = 0, g = 0, b = 0, a = 0}
    panel.closeButton.backgroundColorMouseOver = {r = .4, g = .4, b = .4, a = .4}
    C.arrange(panel)
end

return C
