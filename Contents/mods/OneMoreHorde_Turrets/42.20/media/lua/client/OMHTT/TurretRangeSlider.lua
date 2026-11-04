if isServer() then return end
require("RadioCom/ISUIRadio/ISSliderPanel")
local Slider = ISSliderPanel:derive("OMHTTManageRangeSlider")

---@param value number Proposed range
---@param silent boolean? Server-state refresh rather than user input
---@return nil
function Slider:setCurrentValue(value, silent)
    if self.target and self.target.readOnly and not silent then return end
    ISSliderPanel.setCurrentValue(self, value, silent)
end

---@param x number Mouse X
---@param y number Mouse Y
---@return nil
function Slider:onMouseDown(x, y)
    if self.target and self.target.readOnly then return end
    ISSliderPanel.onMouseDown(self, x, y)
end

---@return nil
function Slider:render()
    ISSliderPanel.render(self)
    if self.target and self.target.readOnly then
        self:drawRect(0, 0, self.width, self.height, .55, .08, .08, .08)
    end
end

return Slider
