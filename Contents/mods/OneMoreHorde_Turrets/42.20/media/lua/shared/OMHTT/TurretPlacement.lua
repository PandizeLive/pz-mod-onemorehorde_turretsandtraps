local T = require("OMHTT/Turret")
OMHTT_TurretPlacement = {}
local P = OMHTT_TurretPlacement

---@param params table Native construction validation
---@return boolean valid
---@nodiscard
function P.valid(params)
    return T.enabled() and params ~= nil and require("OMHTT/ControlDefinitions").controller(params)
end

---@param params table Native server-completed construction
---@return table? result Native transmission instruction
function P.create(params)
    if isClient() then return nil end
    return require("OMHTT/TurretWorld").onCreate(params)
end

return P
