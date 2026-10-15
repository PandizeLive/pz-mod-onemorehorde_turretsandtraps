if isServer() then return end
require("TimedActions/ISTimedActionQueue")
local T = require("OMHTT/Turret")
local G = require("OMHTT/Firearms")
local Control = require("OMHTT/TurretControlAction")
local V = {}

---@param player IsoPlayer Operator
---@param object IsoObject Device
---@param command string Supported control
---@param value number|string Requested value
---@return nil
function V.control(player, object, command, value)
    local state = T.state(object)
    if not state then return end
    ISTimedActionQueue.add(Control:new(player, object, state.id, command, value))
end

---@param contents table Inventory summary
---@return table? cycle Read-only display state
---@return string status
---@nodiscard
function V.cycle(contents)
    local head = contents.head
    if not head then return nil, "NoHead" end
    local data = head:getModData()
    local state = data.OMHTTCycle
    local loaded = state and state.loaded or 0
    if G.profile(head) then
        loaded = G.loaded(head)
    end
    return {loaded = loaded}, "Unavailable"
end

---@param object IsoObject Device
---@param contents table Inventory summary
---@param stats table Effective stats
---@return table? power Presentation only
---@nodiscard
function V.power(object, contents, stats)
    if SandboxVars.OMHTurretsTraps.PotatoRequirePower == false then return {kind = "disabled"} end
    local square = object:getSquare()
    if square:hasGridPower() and square:getRoom() then return {kind = "grid"} end
    if square:haveElectricity() then return {kind = "generator"} end
    local battery = contents.battery
    if battery and battery:getCondition() > 0 and battery:getCurrentUsesFloat() > 0
        and battery:getCurrentUsesFloat() + .0000001 >= stats.batteryPercent / 100 then return {kind = "battery"} end
    return nil
end

return V
