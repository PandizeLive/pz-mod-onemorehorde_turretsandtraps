local C = {}

---@param value any Candidate
---@return boolean finite
function C.finite(value)
    return type(value) == "number" and value == value and math.abs(value) < 10000000
end

---@param x number Origin
---@param y number Origin
---@param z number Floor
---@param dx number Unit direction
---@param dy number Unit direction
---@return table state
function C.new(x, y, z, dx, dy)
    return {x = x, y = y, z = z, dx = dx, dy = dy, distance = 0, phase = "idle",
        sequence = 0, revision = 0, range = 6, speed = 12, returnSpeed = 4,
        resetTime = .4, resetLeft = 0, links = 0, held = false, debt = 0}
end

---@param state table Cycle
---@param detected boolean Detected forward target
---@param pulse boolean Fresh input
---@return boolean started
function C.start(state, detected, pulse)
    if state.phase ~= "idle" then return false end
    if state.links > 0 then
        if not pulse and not state.held then return false end
    elseif not detected then
        return false
    end
    state.sequence = state.sequence + 1
    state.revision = state.revision + 1
    state.phase, state.distance, state.debt = "out", 0, 0
    return true
end

---@param state table Cycle
---@return nil
function C.cancel(state)
    state.phase, state.distance, state.debt, state.resetLeft = "idle", 0, 0, 0
    state.revision = state.revision + 1
end

---@param state table Cycle
---@param elapsed number Simulation seconds
---@param cast function Swept first-hit query returning fraction, victim, reason
---@param hit function Authoritative impact callback
---@return nil
function C.step(state, elapsed, cast, hit)
    if not C.finite(elapsed) or elapsed < 0 or elapsed > 2 then
        C.cancel(state)
        return
    end
    if state.phase == "idle" then return end
    state.debt = state.debt + elapsed
    if state.debt > 2 then
        C.cancel(state)
        return
    end
    for i = 1, 8 do
        if state.debt <= .000001 or state.phase == "idle" then break end
        local dt = math.min(.05, state.debt)
        state.debt = state.debt - dt
        if state.phase == "out" then
            local destination = math.min(state.range, state.distance + state.speed * dt)
            local fraction, victim, reason = cast(state, state.distance, destination)
            if fraction then
                state.distance = state.distance + (destination - state.distance) * fraction
                state.phase = "back"
                state.revision = state.revision + 1
                hit(state, victim, reason)
            else
                state.distance = destination
                if destination >= state.range then
                    state.phase = "back"
                    state.revision = state.revision + 1
                end
            end
        elseif state.phase == "back" then
            state.distance = math.max(0, state.distance - state.returnSpeed * dt)
            if state.distance == 0 then
                state.phase, state.resetLeft = "reset", state.resetTime
                state.revision = state.revision + 1
            end
        elseif state.phase == "reset" then
            state.resetLeft = math.max(0, state.resetLeft - dt)
            if state.resetLeft <= .000001 then
                C.cancel(state)
            end
        end
    end
end

---@param ax number Segment start
---@param ay number Segment start
---@param bx number Segment end
---@param by number Segment end
---@param x number Circle center
---@param y number Circle center
---@param radius number Collision radius
---@return number? fraction First intersection
function C.intersection(ax, ay, bx, by, x, y, radius)
    local vx, vy, ox, oy = bx - ax, by - ay, ax - x, ay - y
    local a = vx * vx + vy * vy
    local c = ox * ox + oy * oy - radius * radius
    if c <= 0 then return 0 end
    if a <= .00000001 then return nil end
    local b = 2 * (ox * vx + oy * vy)
    local discriminant = b * b - 4 * a * c
    if discriminant < 0 then return nil end
    local fraction = (-b - math.sqrt(discriminant)) / (2 * a)
    if fraction >= 0 and fraction <= 1 then return fraction end
    return nil
end

---@param state table Cycle
---@param id number Device identity
---@param serial number Monotonic message counter
---@param session string? Authority lifetime
---@return table payload Primitive values only
function C.snapshot(state, id, serial, session)
    return {id = id, serial = serial, session = session or "1", sequence = state.sequence, phase = state.phase,
        x = state.x, y = state.y, z = state.z, dx = state.dx, dy = state.dy,
        distance = state.distance, range = state.range, speed = state.speed,
        returnSpeed = state.returnSpeed}
end

---@param previous table? Previous accepted message
---@param message any New server message
---@return boolean accepted
function C.accept(previous, message)
    if type(message) ~= "table" then return false end
    if type(message.session) ~= "string" or #message.session > 16
        or not string.match(message.session, "^%d+$") then return false end
    local fields = {"id", "serial", "sequence", "x", "y", "z", "dx", "dy", "distance", "range", "speed", "returnSpeed"}
    for i = 1, #fields do
        if not C.finite(message[fields[i]]) then return false end
    end
    if message.id < 1 or message.id > 8 or message.id ~= math.floor(message.id)
        or message.serial < 1 or message.serial ~= math.floor(message.serial)
        or message.sequence < 0 or message.sequence ~= math.floor(message.sequence)
        or message.range <= 0 or message.range > 6 or message.distance < 0 or message.distance > message.range
        or message.speed <= 0 or message.speed > 12 or message.returnSpeed <= 0 or message.returnSpeed > 4
        or math.abs(message.dx * message.dx + message.dy * message.dy - 1) > .001 then return false end
    if message.phase ~= "out" and message.phase ~= "back" and message.phase ~= "reset" and message.phase ~= "idle" then return false end
    if previous and message.session ~= previous.session then
        return tonumber(message.session) > tonumber(previous.session)
    end
    return not previous or message.serial > previous.serial
end

---@param message table Accepted server state
---@param elapsed number Seconds since receipt
---@param previousDistance number? Last displayed confirmed distance
---@return number x
---@return number y
function C.position(message, elapsed, previousDistance)
    local distance = message.distance
    if previousDistance then
        local fraction = math.max(0, math.min(1, elapsed / .1))
        distance = previousDistance + (distance - previousDistance) * fraction
    end
    return message.x + message.dx * distance, message.y + message.dy * distance
end

return C
