if isServer() then return end
local A = require("OMHTT/ControlAccess")
local Battery = require("OMHTT/TurretBattery")
local D = {}

---@param object IsoObject Controller
---@param item InventoryItem Active battery
---@return string description Recent workload estimate, expressed in game hours
function D.get(object, item)
    local state = A.state(object)
    if not state then return "" end
    local charge = Battery.charge(item)
    local text = "<RGB:0.8,0.8,0.8> " .. getText("UI_OMHTT_ControllerCharge", math.floor(charge * 100))
    local rate = state.powerRate
    local fresh = state.powerSampleHours and getGameTime():getWorldAgeHours() - state.powerSampleHours < .25
    if not rate or not fresh then
        return text .. " <LINE> " .. getText("UI_OMHTT_ControllerEstimating")
    end
    if rate < .000001 then
        return text .. " <LINE> " .. getText("UI_OMHTT_ControllerStandbyEstimate")
    end
    text = text .. " <LINE> " .. getText("UI_OMHTT_ControllerActiveHours", string.format("%.1f", charge / rate))
    if state.powerReserve then
        text = text .. " <LINE> " .. getText("UI_OMHTT_ControllerReserveHours", string.format("%.1f", state.powerReserve / rate))
    end
    return text .. " <LINE> " .. getText("UI_OMHTT_ControllerRecentDraw")
end

return D
