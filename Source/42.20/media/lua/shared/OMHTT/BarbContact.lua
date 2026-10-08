local C = {}

---@param x number Frame tile X
---@param y number Frame tile Y
---@param facing string Exposed face e, n, w or s
---@return number? x Backing tile X
---@return number? y Backing tile Y
---@return boolean? north Backing edge axis
---@return number? side Exposed side sign
---@nodiscard
function C.edge(x, y, facing)
    if facing == "e" then return x, y, false, 1 end
    if facing == "n" then return x, y + 1, true, -1 end
    if facing == "w" then return x + 1, y, false, -1 end
    if facing == "s" then return x, y, true, 1 end
    return nil
end

---@param edge table Backing x, y, z, north and side
---@param x number Actor X
---@param y number Actor Y
---@param z number Actor floor
---@param width number Native actor collision width
---@return boolean touching
---@nodiscard
function C.touching(edge, x, y, z, width)
    if z ~= edge.z or width <= 0 then return false end
    local along, across = y - edge.y, x - edge.x
    if edge.north then
        along, across = x - edge.x, y - edge.y
    end
    across = across * edge.side
    return along >= 0 and along <= 1 and across >= 0 and across <= width
end

---@param state table One timer per zombie across all sections
---@param now number Active milliseconds
---@param session string Active clock identity
---@param touching boolean Currently contacting a valid section
---@param interval number Positive repeat milliseconds
---@return boolean hit
function C.step(state, now, session, touching, interval)
    if interval <= 0 then return false end
    if state.session ~= session or (state.seen and now < state.seen) then
        if state.nextHit and state.seen then
            state.nextHit = now + math.max(0, math.min(interval, state.nextHit - state.seen))
        else
            state.nextHit = nil
        end
        state.session = session
    end
    state.seen = now
    if not touching or (state.nextHit and now < state.nextHit) then return false end
    state.nextHit = now + interval
    return true
end

return C
