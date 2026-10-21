local D = require("OMHTT/ControlDefinitions")
local M = require("OMHTT/TetherMount")
local T = {}
D.passiveKinds.Tether = true
D.types.Tether = "Base.OMHTTTrapTetherDart"
require("OMHTT/PlacementRules").routes.OMHTTDeployTether = {D.types.Tether, 2}

---@param params table Native placement
---@return boolean valid
function T.valid(params)
    local square = params.square
    if not square or SandboxVars.OMHTurretsTraps.Enabled == false then return false end
    local mount = M.resolve(square:getX(), square:getY(), square:getZ(), params.facing)
    if not mount then return false end
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local state = require("OMHTT/ControlAccess").state(objects:get(i))
        if state and state.kind == "Tether" and state.facing == params.facing then return false end
    end
    return true
end

---@param params table Native construction commit
---@return table? transmission
function T.created(params)
    if isClient() then return nil end
    local W = require("OMHTT/ControlWorld")
    local result = W.create(params)
    local state = W.state(params.thumpable)
    if state then
        state.facing = params.facing
        params.thumpable:setIsThumpable(false)
        W.publish(params.thumpable)
    end
    return result
end

OMHTT_Tether = T
return T
