if isServer() then return end
require("TimedActions/ISTimedActionQueue")
local T = require("OMHTT/Turret")
local G = require("OMHTT/Firearms")
local Control = require("OMHTT/TurretControlAction")
local V = {}

---@param module string Namespace
---@param command string Result notification
---@param message table Server operation result
---@return nil
function V.receive(module, command, message)
    if not isClient() or module ~= "OMHTT_TurretControl" or command ~= "Result" or type(message) ~= "table"
        or type(message.id) ~= "string" or type(message.status) ~= "string" then return end
    V.result = {id = message.id, status = message.status, at = getTimestampMs()}
end

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
    if T.cycleConfig(contents).rotary then return {loaded = 0}, "Ready" end
    local data = head:getModData()
    local virtual = data.OMHTTCycle and data.OMHTTCycle.virtual
    local state = G.profile(head) and not virtual and data.OMHTTGunCycle or data.OMHTTCycle
    local loaded = state and state.loaded or 0
    if G.profile(head) and not virtual then
        loaded = G.loaded(head)
    end
    return {loaded = loaded, virtual = virtual, payload = state and state.payload}, state and state.status or "Unavailable"
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
    if battery and battery:getCondition() > 0 and require("OMHTT/TurretBattery").charge(battery) > 0
        and require("OMHTT/TurretBattery").charge(battery) + .0000001 >= stats.batteryPercent / 100 then return {kind = "battery"} end
    return nil
end

Events.OnServerCommand.Add(V.receive)
return V
