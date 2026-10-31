if isClient() then return end
local Battery = require("OMHTT/TurretBattery")
local E = {entries = setmetatable({}, {__mode = "k"})}

---@param object IsoObject Controller
---@return table entry Bounded, unsaved observation state
function E.entry(object)
    local entry = E.entries[object]
    if not entry then
        entry = {hours = getGameTime():getWorldAgeHours(), spent = 0, index = 0, charge = 0, fresh = true}
        E.entries[object] = entry
    end
    return entry
end

---@param object IsoObject Controller
---@param amount number Actual battery charge spent
---@return nil
function E.spend(object, amount)
    local entry = E.entry(object)
    entry.spent = entry.spent + math.max(0, amount)
end

---@param object IsoObject Controller
---@param state table Authoritative device state
---@return boolean changed Public estimate was sampled
function E.sample(object, state)
    local entry, now = E.entry(object), getTimestampMs()
    local oldRate, oldReserve = state.powerRate, state.powerReserve
    if entry.fresh then
        state.powerRate, state.powerSampleHours, entry.fresh = nil, nil, nil
    end
    if now < (entry.due or 0) then return false end
    entry.due = now + 1000
    local items = object:getContainer():getItems()
    local size = items:size()
    if entry.size ~= size then
        entry.size, entry.index, entry.charge = size, 0, 0
    end
    local stop = math.min(size, entry.index + 32)
    for i = entry.index, stop - 1 do
        local item = items:get(i)
        if Battery.car(item) and item:getCondition() > 0 then
            entry.charge = entry.charge + Battery.charge(item)
        end
    end
    entry.index = stop
    if stop >= size then
        state.powerReserve = math.floor(entry.charge * 1000) / 1000
        entry.index, entry.charge = 0, 0
    end
    local hours = getGameTime():getWorldAgeHours()
    local elapsed = hours - entry.hours
    if elapsed < 0 or elapsed > 1 then
        entry.hours, entry.spent, state.powerRate = hours, 0, nil
    elseif elapsed >= 1 / 60 then
        local rate = entry.spent / elapsed
        rate = state.powerRate and state.powerRate * .5 + rate * .5 or rate
        state.powerRate = math.floor(rate * 1000000 + .5) / 1000000
        state.powerSampleHours = hours
        entry.hours, entry.spent = hours, 0
    end
    local changed = oldRate ~= state.powerRate or oldReserve ~= state.powerReserve
        or not entry.publishedHours or hours - entry.publishedHours >= .1
    if changed then
        entry.publishedHours = hours
    end
    return changed
end

return E
