local State = require("OMHTT/TurretItemState")
local B = {}

---@param battery DrainableComboItem Battery retaining its native whole-use charge
---@return number charge Charge including its persisted fractional remainder
function B.charge(battery)
    local state = State.get(battery, "battery")
    return math.max(0, math.min(1, battery:getCurrentUsesFloat() - (state and state.debt or 0)))
end

---@param battery DrainableComboItem Exact carried/installed battery
---@param cost number Charge fraction consumed by this action
---@return number spent Exact cost, independent of native whole-use rounding
function B.spend(battery, cost)
    if isClient() or cost <= 0 then return 0 end
    local before = B.charge(battery)
    local desired = math.max(0, before - cost)
    battery:setCurrentUsesFloat(desired)
    local state = State.get(battery, "battery", {debt = 0})
    state.debt = battery:getCurrentUsesFloat() - desired
    if isServer() then
        local data = battery:getModData()
        if type(data.OMHTTBatteryDrain) ~= "table" then data.OMHTTBatteryDrain = {} end
        data.OMHTTBatteryDrain.debt = state.debt
    end
    return before - desired
end

---@param battery DrainableComboItem Original installed battery
---@param amount number Earned charge fraction
---@return number restored
function B.restore(battery, amount)
    if isClient() or amount <= 0 then return 0 end
    local before = B.charge(battery)
    local desired = math.min(1, before + amount)
    battery:setCurrentUsesFloat(desired)
    local state = State.get(battery, "battery", {debt = 0})
    state.debt = battery:getCurrentUsesFloat() - desired
    if isServer() then
        local data = battery:getModData()
        if type(data.OMHTTBatteryDrain) ~= "table" then
            data.OMHTTBatteryDrain = {}
        end
        data.OMHTTBatteryDrain.debt = state.debt
    end
    return desired - before
end

---@param battery InventoryItem Removed item
---@return nil
function B.detach(battery)
    if isClient() then return end
    local state = State.get(battery, "battery", {debt = 0})
    state.generation = (state.generation or 0) + 1
end

return B
