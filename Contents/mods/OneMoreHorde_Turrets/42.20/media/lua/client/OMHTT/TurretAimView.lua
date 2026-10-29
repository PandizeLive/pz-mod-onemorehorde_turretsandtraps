local V = {}

---@param sample table Per-head presentation state
---@param target number Latest authoritative angle or unwrapped rotary travel
---@param now number Local wall clock
---@param rotary boolean Unwrapped motor travel
---@return number value Interpolated display value only
function V.sample(sample, target, now, rotary)
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
