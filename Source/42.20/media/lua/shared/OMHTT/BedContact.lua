local C = {}

---@param state table Per-zombie contact history
---@param frame table Current position, floor and movement snapshot
---@return boolean hit Newly landed fall on spikes
---@return boolean roll New upright movement opportunity
function C.step(state, frame)
    local hit, roll = false, false
    if state.initialized ~= true then
        state.initialized = true
        state.fallen = frame.prone or frame.down
    elseif frame.prone and not state.fallen then
        state.fallen = true
        hit = frame.bed ~= nil and not frame.crawler
    end
    if state.fallen and not frame.prone and not frame.down then
        state.fallen = false
        state.protectedUntil = frame.now + frame.recovery
    end
    if not frame.prone and not frame.down and not frame.crawler and frame.moving and frame.bed
        and frame.now >= (state.protectedUntil or 0) and frame.now >= (state.requestedUntil or 0)
        and frame.tile ~= state.rollTile then
        local moved = state.rollX == nil or (frame.x - state.rollX) ^ 2 + (frame.y - state.rollY) ^ 2 >= 0.25
        if moved then
            state.rollTile, state.rollX, state.rollY = frame.tile, frame.x, frame.y
            roll = true
        end
    end
    if not frame.bed then
        state.rollTile = nil
    end
    return hit, roll
end

return C
