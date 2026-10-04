local B = {workers = {}, cursor = 1, deadline = nil}

---@param name string Worker identity
---@param callback function Bounded worker
---@return nil
function B.register(name, callback)
    for i = 1, #B.workers do
        if B.workers[i].name == name then B.workers[i].run = callback; return end
    end
    B.workers[#B.workers + 1] = {name = name, run = callback}
end

---@param duration number Local budget milliseconds
---@return number deadline Wall clock deadline
---@nodiscard
function B.limit(duration)
    return math.min(getTimestampMs() + duration, B.deadline or math.huge)
end

---@return nil
function B.tick()
    if isClient() or isServer() or GameTime.isGamePaused() then return end
    B.deadline = getTimestampMs() + 3
    for i = 1, #B.workers do
        if getTimestampMs() >= B.deadline then break end
        if B.cursor > #B.workers then B.cursor = 1 end
        local worker = B.workers[B.cursor]
        B.cursor = B.cursor + 1
        worker.run()
    end
    B.deadline = nil
end

Events.OnTick.Add(B.tick)
return B
