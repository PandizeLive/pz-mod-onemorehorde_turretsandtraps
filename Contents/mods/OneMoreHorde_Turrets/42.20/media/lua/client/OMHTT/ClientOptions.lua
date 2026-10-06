require("PZAPI/ModOptions")
local O = {}

---@return nil
function O.register()
    local options = PZAPI.ModOptions:getOptions("OneMoreHorde_TurretsAndTraps")
    if not options then
        options = PZAPI.ModOptions:create("OneMoreHorde_TurretsAndTraps", "OMH: Turrets")
        options:addTickBox("ShowNoiseRadius", getText("UI_OMHTT_ShowNoiseRadius"), true, getText("UI_OMHTT_NoiseRadiusTooltip"))
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
return O
