if isServer() then return end
require("ISUI/ISToolTipInv")
local T = require("OMHTT/Turret")
local tooltipRender = ISToolTipInv.render

---@return nil
function ISToolTipInv:render()
    local component = self.item and T.component(self.item:getFullType())
    if component then
        local old = self.item:getTooltip()
        self.item:setTooltip(nil)
        tooltipRender(self)
        if not ISContextMenu.instance or not ISContextMenu.instance.visibleCheck then
            require("OMHTT/TurretItemTooltip").footer(self, component)
        end
        self.item:setTooltip(old)
        return
    end
    if self.item and self.item:getFullType() == T.BASE then
        local old = self.item:getTooltip()
        self.item:setTooltip(getTextManager():WrapText(UIFont.Small, T.description(self.item:getInventory(), self.item:getActualWeight()), 320))
        tooltipRender(self)
        self.item:setTooltip(old)
        return
    end
    tooltipRender(self)
end

