if isServer() then return end
require("ISUI/ISToolTipInv")
local native=ISToolTipInv.render
function ISToolTipInv:render()
    local description, battery, rarity = require("OMHTT/ControlItemDescription").get(self.item)
    local original = self.item and self.item:getTooltip()
    if description then self.item:setTooltip(nil) end
    native(self)
    if description then self.item:setTooltip(original) end
    if not description or (ISContextMenu.instance and ISContextMenu.instance.visibleCheck) then return end
    require("OMHTT/ControlTooltipRows").footer(self, description, battery, rarity)
end
