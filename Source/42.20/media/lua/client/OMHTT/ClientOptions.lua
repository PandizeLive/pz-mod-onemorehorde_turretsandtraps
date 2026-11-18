local O = require("OMHTT/ControlOptions")
local C = {}

---@return boolean visible
---@nodiscard
function C.noiseVisible()
    return O.get("ShowNoiseRadius")
end

---@return boolean enabled
---@nodiscard
function C.packAnimation()
    return O.get("PackAnimation")
end

return C
