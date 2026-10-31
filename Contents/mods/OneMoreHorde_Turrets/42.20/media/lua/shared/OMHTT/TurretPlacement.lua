local T = require("OMHTT/Turret")
OMHTT_TurretPlacement = {}
local P = OMHTT_TurretPlacement

---@param params table Native construction validation
---@return boolean valid
---@nodiscard
function P.valid(params)
    local square = params and params.square
    if require("OMHTT/ControlPokeFootprint").reserved(square) then return false end
    if not T.enabled() or not square or not square:TreatAsSolidFloor()
        or square:isSolid() or square:isSolidTrans() then return false end
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        if T.state(object) then return false end
        if object:hasModData() then
            local data = object:getModData()
            if data.OMHTT or data.OMHTTEdge then return false end
        end
    end
    return true
end

---@param params table Native server-completed construction
---@return table? result Native transmission instruction
function P.create(params)
    if isClient() then return nil end
    return require("OMHTT/TurretWorld").onCreate(params)
end

return P
