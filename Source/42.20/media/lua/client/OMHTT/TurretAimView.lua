local V = {}

---@param travel number Confirmed unwrapped motor travel
---@param age number Milliseconds since synchronized snapshot
---@param speed number Authoritative degrees per second
---@param moving boolean Motor state
---@param stopAt number? Confirmed end of current stroke
---@return number value Bounded presentation only; never used for hit tests
function V.rotary(travel, age, speed, moving, stopAt)
    local value = travel
    if moving then
        value = value + speed * math.max(0,math.min(250,age))/1000
        if stopAt then
            value = math.min(value,stopAt)
        end
    end
    return value
end

---@param sample table Reused per-head state
---@param current number Current displayed angle
---@param target number Current position of the server-selected target
---@param now number Local presentation milliseconds
---@param speed number Authoritative degrees per second
---@return number heading Bounded visual turn only
function V.follow(sample, current, target, now, speed)
    local elapsed = sample.followAt and math.max(0, math.min(100, now - sample.followAt)) / 1000 or 0
    sample.followAt = now
    local delta = (target - current + 540) % 360 - 180
    sample.value = (current + math.max(-speed * elapsed, math.min(speed * elapsed, delta)) + 360) % 360
    sample.target, sample.from, sample.at, sample.duration = sample.value, sample.value, now, 100
    return sample.value
end

---@param sample table Per-head presentation state
---@param target number Latest authoritative angle or unwrapped rotary travel
---@param now number Local wall clock
---@param rotary boolean Unwrapped motor travel
---@return number value Interpolated display value only
function V.sample(sample, target, now, rotary)
    sample.followAt = nil
    if sample.target == nil or now < sample.at or (rotary and target < sample.target) then
        sample.target, sample.from, sample.value, sample.at, sample.duration = target, target, target, now, 250
    end
    local fraction = math.min(1, math.max(0, now - sample.at) / sample.duration)
    local difference = sample.target - sample.from
    if not rotary then
        difference = (difference + 540) % 360 - 180
    end
    sample.value = sample.from + difference * fraction
    if target ~= sample.target then
        local interval = now - sample.at
        sample.from, sample.target, sample.at = sample.value, target, now
        sample.duration = math.max(100, math.min(400, interval))
    end
    return rotary and sample.value or sample.value % 360
end

return V
