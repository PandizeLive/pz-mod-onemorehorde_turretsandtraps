if isClient() then return end
local T = require("OMHTT/Turret")
local Battery = require("OMHTT/TurretBattery")
local ItemState = require("OMHTT/TurretItemState")
local ActorState = require("OMHTT/DefenseActorState")
local S = {}
local motors = setmetatable({}, {__mode = "k"})

---@param object IsoObject Paid device
---@param power table Exact committed power source
---@param stats table Paid module snapshot
---@param spent number Actual battery debit
---@return table? energy Persistable source and cost
function S.capture(object, power, stats, spent)
    if power.kind ~= "battery" or (stats.siphon or 0) <= 0 then return nil end
    local control = require("OMHTT/ControlWorld").state(object)
    if not control then return nil end
    local battery = ItemState.get(power.battery, "battery", {debt = 0})
    return {source = control.id, turret = T.state(object).id, battery = power.battery:getID(),
        generation = battery.generation or 0, cost = spent, multiplier = stats.siphon,
        synergy = stats.synergy == true, closed = true, kills = 0, settled = 0}
end

---@param energy table? Paid energy record
---@return nil
function S.settle(energy)
    if not energy or not energy.closed or energy.kills <= energy.settled then return end
    local count = energy.kills - energy.settled
    energy.settled = energy.kills
    local W = require("OMHTT/ControlWorld")
    local object = W.objects[energy.source]
    if not object or object:getObjectIndex() < 0 or object:getHealth() <= 0 then return end
    local state = T.state(object)
    if not state or state.id ~= energy.turret then return end
    local battery = object:getContainer():getItemById(energy.battery)
    if not battery or T.kind(battery) ~= "battery" then return end
    local saved = ItemState.get(battery, "battery", {debt = 0})
    if (saved.generation or 0) ~= energy.generation then return end
    Battery.restore(battery, energy.cost * energy.multiplier * count)
end

---@param zombie IsoZombie Confirmed killed victim
---@param energy table? Paid root
---@param secondary boolean Module-created damage
---@return nil
function S.hit(zombie, energy, secondary)
    if not energy or not zombie:isDead() or (secondary and not energy.synergy) then return end
    local guard = ActorState.get(zombie)
    if guard.OMHTTSiphonClaimed then return end
    guard.OMHTTSiphonClaimed = true
    -- Claim failures too: duplicate death callbacks must never reroll a missed proc.
    if ZombRand(100) >= 45 then return end
    energy.kills = energy.kills + 1
    S.settle(energy)
end

---@param energy table? Interrupted or completed pass
---@return nil
function S.close(energy)
    if not energy then return end
    energy.closed = true
    S.settle(energy)
end

---@param entry table Rotary scheduler entry
---@return nil
function S.stop(entry)
    local windows = motors[entry]
    if not windows then return end
    for _, energy in pairs(windows) do
        S.close(energy)
    end
    motors[entry] = nil
end

---@param entry table Rotary scheduler entry
---@param power table Paid source
---@param stats table Active modules
---@param spent number Exact charge fraction
---@param before number Previous angular travel
---@param after number Paid angular travel
---@param omni boolean Full rotation
---@return table? windows At most two observed pass records
function S.motor(entry, power, stats, spent, before, after, omni, cone)
    if after <= before or power.kind ~= "battery" or (stats.siphon or 0) <= 0 then
        S.stop(entry)
        return nil
    end
    local span = omni and 360 or (cone or 90)
    local first, last = math.floor(before / span), math.floor(after / span)
    local windows = motors[entry]
    if not windows then
        windows = {}
        motors[entry] = windows
    end
    local current = windows[first]
    local saved = ItemState.get(power.battery, "battery", {debt = 0})
    if current and (current.battery ~= power.battery:getID() or current.generation ~= (saved.generation or 0)
        or current.multiplier ~= stats.siphon or current.synergy ~= stats.synergy or current.closed) then
        S.stop(entry)
        windows = {}
        motors[entry] = windows
    end
    local retained = {}
    for pass = math.max(first, last - 1), last do
        local energy = windows[pass] or S.capture(entry.object, power, stats, 0)
        if energy then
            energy.closed = false
            local travel = math.max(0, math.min(after, (pass + 1) * span) - math.max(before, pass * span))
            energy.cost = energy.cost + spent * travel / (after - before)
            retained[pass] = energy
            if pass < last then
                S.close(energy)
            end
        end
    end
    for pass, energy in pairs(windows) do
        if not retained[pass] then
            if pass == first then
                energy.cost = energy.cost + spent * ((first + 1) * span - before) / (after - before)
            end
            S.close(energy)
        end
    end
    motors[entry] = retained
    return retained
end

---@return nil
function S.save()
    for entry in pairs(motors) do
        S.stop(entry)
    end
end

Events.OnSave.Add(S.save)
return S
