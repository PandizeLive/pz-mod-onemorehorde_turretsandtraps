local Active = require("OMHTT/ActiveTime")
local C = {time = getTimestampMs(), clock = Active.new(true)}

---@return number now Simulation milliseconds
---@nodiscard
function C.now()
    return C.time
end

---@return nil
function C.tick()
    C.time = C.time + Active.step(C.clock)
end

Events.OnTick.Add(C.tick)
return C
