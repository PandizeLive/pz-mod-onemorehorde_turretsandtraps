if isServer() then return end
require("RadioCom/ISUIRadio/ISSliderPanel")
require("ISUI/ISButton")
local T = require("OMHTT/Turret")
local U = require("OMHTT/TurretUtilities")
local E = {}

---@param panel ISPanel Manage window
---@param x number Slider origin
---@return nil
function E.create(panel, x)
    local Slider = require("OMHTT/TurretRangeSlider")
    panel.lureSlider = Slider:new(x, 0, panel.width - x - 168, panel.lineHeight + 2, panel, function(self, value)
        self.pendingLure = math.floor(value)
    end)
    panel.lureSlider:initialise()
    panel.lureSlider:setValues(5, 20, 1, 5, true)
    panel:addChild(panel.lureSlider)
    panel.landingSlider = Slider:new(x, 0, panel.width - x - 24, panel.lineHeight + 2, panel, function(self, value)
        self.pendingLanding = math.floor(value)
    end)
    panel.landingSlider:initialise()
    panel:addChild(panel.landingSlider)
    panel.lurePlay = ISButton:new(panel.width - 156, 0, 64, 24, getText("UI_OMHTT_Play"), panel, function(self)
        U.control(self, "LurePulse", true)
    end)
    panel.lureLoop = ISButton:new(panel.width - 86, 0, 74, 24, "", panel, function(self)
        U.control(self, "LureRepeat", not T.state(self.object).lureRepeat)
    end)
    local buttons = {panel.lurePlay, panel.lureLoop}
    for i = 1, #buttons do
        buttons[i]:initialise()
        panel:addChild(buttons[i])
    end
end

---@param panel ISPanel Manage window
---@param contents table Current equipment
---@param stats table Effective head tuning
---@return nil
function E.refresh(panel, contents, stats)
    local state = T.state(panel.object)
    panel.hasLure, panel.hasLanding = contents.active.Lure ~= nil, stats.headKind == "Lobber"
    panel.lureSlider:setVisible(panel.hasLure)
    panel.lurePlay:setVisible(panel.hasLure)
    panel.lureLoop:setVisible(panel.hasLure)
    local writable = require("OMHTT/TurretAccess").near(panel.player, panel.object, panel.deviceId)
    panel.lurePlay:setEnable(writable and panel.hasLure)
    panel.lureLoop:setEnable(writable and panel.hasLure)
    if panel.hasLure then
        panel.lureLoop:setTitle(getText(state.lureRepeat and "UI_OMHTT_LoopOn" or "UI_OMHTT_LoopOff"))
        if not panel.lureSlider.dragInside then
            if panel.pendingLure then
                U.control(panel, "LureRange", panel.pendingLure)
                panel.pendingLure = nil
            end
            panel.lureSlider:setCurrentValue(state.lureRange or 10, true)
        end
    end
    panel.landingSlider:setVisible(panel.hasLanding)
    if panel.hasLanding then
        if panel.landingMaximum ~= stats.range then
            panel.landingMaximum = stats.range
            panel.landingSlider:setValues(math.ceil(stats.minimumRange), math.floor(stats.range), 1, 5, true)
        end
        if not panel.landingSlider.dragInside then
            if panel.pendingLanding then
                U.control(panel, "LandingRange", panel.pendingLanding)
                panel.pendingLanding = nil
            end
            panel.landingSlider:setCurrentValue(math.max(stats.minimumRange, math.min(stats.range, state.landingRange or stats.range)), true)
        end
    end
    require("OMHTT/TurretManageLayout").refresh(panel)
end

---@param panel ISPanel Manage window
---@return nil
function E.draw(panel)
    local state = T.state(panel.object)
    if panel.hasLure then
        panel:drawText(getText("UI_OMHTT_LureRange", state.lureRange or 10), 12, panel.lureY + 4, 1, 1, 1, 1, UIFont.Small)
    end
    if panel.hasLanding then
        panel:drawText(getText("UI_OMHTT_LandingRange", math.min(panel.stats.range, state.landingRange or panel.stats.range)),
            12, panel.landingY + 4, 1, 1, 1, 1, UIFont.Small)
    end
end

return E
