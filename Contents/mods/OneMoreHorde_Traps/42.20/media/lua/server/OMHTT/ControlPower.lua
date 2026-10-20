if isClient() then return end
local Battery = require("OMHTT/TurretBattery")
local Access = require("OMHTT/ControlAccess")
local P = {dirty = setmetatable({}, {__mode = "k"})}

function P.battery(object, cost)
    local W = require("OMHTT/ControlWorld")
    local state, storage = W.state(object), object:getContainer()
    if not state or not storage then return nil end
    local battery = W.batteries[object]
    if not battery and state.batteryId then battery = storage:getItemWithID(state.batteryId) end
    local function usable(item)
        return item and Battery.car(item) and item:getContainer() == storage and item:getCondition() > 0
            and Battery.charge(item) > 0 and Battery.charge(item) + 0.0000000001 >= cost
    end
    if not usable(battery) then
        battery = nil
        local items = storage:getItems()
        local index = W.batteryScan[object] or 0
        for i = 1, math.min(64, items:size()) do
            if index >= items:size() then index = 0 end
            local candidate = items:get(index)
            index = index + 1
            if usable(candidate) then battery = candidate; break end
        end
        W.batteryScan[object] = index
    end
    W.batteries[object], state.batteryId = battery, battery and battery:getID() or nil
    return battery
end

function P.fallback(object, cost)
    local W = require("OMHTT/ControlWorld")
    local state = W.state(object)
    local controller = state and state.controller and W.objects[state.controller]
    local host = controller and W.state(controller)
    if not host or host.kind ~= "Controller" or not host.placed or controller:getHealth() <= 0
        or not Access.range(controller, object) or getCell():getGridSquare(host.x, host.y, host.z) ~= controller:getSquare() then return nil end
    local battery = P.battery(controller, cost)
    if battery then return {kind = "controller", battery = battery, controller = controller, cost = cost} end
end

function P.spend(source)
    local item = source.battery
    if not item or item:getCondition() <= 0 or Battery.charge(item) + 0.0000000001 < source.cost then return nil end
    if source.controller and item:getContainer() ~= source.controller:getContainer() then return nil end
    local spent = Battery.spend(item, source.cost)
    if isServer() then P.dirty[item] = true end
    return spent
end

function P.flush()
    if not isServer() then return end
    local now = getTimestampMs()
    if now < (P.due or 0) then return end
    P.due = now + 250
    local count = 0
    for item in pairs(P.dirty) do
        P.dirty[item] = nil
        if item:getContainer() then
            sendItemStats(item)
            require("OMHTT/TurretItemState").publish(item)
        end
        count = count + 1
        if count >= 64 then break end
    end
end

function P.idle(object, elapsed)
    local square = object:getSquare()
    if square:haveElectricity() or (square:hasGridPower() and square:getRoom()) then return true end
    local W = require("OMHTT/ControlWorld")
    local state = W.state(object)
    local remaining = math.max(0, elapsed / 48) + (state.powerDebt or 0)
    for i = 1, 64 do
        local battery = P.battery(object, 0)
        if not battery then
            state.powerDebt = nil
            return false
        end
        if remaining <= 0 then state.powerDebt = nil; return true end
        local cost = math.min(remaining, Battery.charge(battery))
        if not P.spend({battery = battery, controller = object, cost = cost}) then return false end
        remaining = math.max(0, remaining - cost)
    end
    state.powerDebt = remaining
    return remaining == 0 and P.battery(object, 0) ~= nil
end

return P
