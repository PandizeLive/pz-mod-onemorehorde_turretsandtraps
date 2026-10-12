require("PZAPI/ModOptions")
local O = {}

---@return nil
function O.register()
    local options = PZAPI.ModOptions:getOptions("OneMoreHorde_TurretsAndTraps")
    if not options then
        options = PZAPI.ModOptions:create("OneMoreHorde_TurretsAndTraps", "OMH: Turrets")
        options:addTickBox("ShowNoiseRadius", getText("UI_OMHTT_ShowNoiseRadius"), true, getText("UI_OMHTT_NoiseRadiusTooltip"))
    end
    if not options:getOption("PackAnimation") then
        options:addTickBox("PackAnimation", getText("UI_OMHTT_PackAnimation"), true, getText("UI_OMHTT_PackAnimationTooltip"))
    end
    O.options = options
end

---@return boolean visible
---@nodiscard
function O.noiseVisible()
    if not O.options then O.register() end
    return O.options:getOption("ShowNoiseRadius"):getValue()
end

O.register()

---@return boolean enabled
---@nodiscard
function O.packAnimation()
    if not O.options then O.register() end
    return O.options:getOption("PackAnimation"):getValue()
end

return O
