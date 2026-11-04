if isClient() then return end
local Heads = require("OMHTT/TurretHeads")
local Sweep = {}
local EPS = 1e-10

---@param profile table Resolved two-arm sweep
---@param first number Initial motor travel, degrees
---@param last number Final motor travel within one stroke
---@param x number Initial target position relative to pivot, Y north
---@param y number Initial target Y
---@param dx number Target displacement X
---@param dy number Target displacement Y
---@param emit function Confirmed arm, pass, travel and local time fraction
local function moving(profile, first, last, x, y, dx, dy, emit)
    local angle, stroke = Heads.motion(first, profile.omni, profile.cone)
    local delta = last - first
    local theta = math.rad(angle + profile.heading)
    local omega = math.rad(delta)
    if not profile.omni and stroke % 2 == 1 then omega = -omega end
    local function side(t)
        local yaw = theta + omega * t
        return (y + dy*t)*math.cos(yaw) - (x + dx*t)*math.sin(yaw)
    end
    local function bracket(a, b)
        if b <= a then return end
        local left, right = side(a), side(b)
        if math.abs(left) <= EPS then return end
        local t = b
        if math.abs(right) > EPS then
            if (left > 0) == (right > 0) then return end
            local low, high = a, b
            for i = 1, 18 do
                local mid = (low + high) * .5
                if (side(mid) > 0) == (left > 0) then low = mid else high = mid end
            end
            t = (low + high) * .5
        end
        local yaw = theta + omega*t
        local projection = (x + dx*t)*math.cos(yaw) + (y + dy*t)*math.sin(yaw)
        local arm = projection < -EPS and 2 or 1
        local travel = first + delta*t
        local pass = profile.omni and math.floor(travel/360) or stroke
        emit(arm, pass, travel, t)
    end
    -- Split where relative bearing can reverse, and at closest approach to the pivot.
    local length2 = dx*dx + dy*dy
    local closest = -(x*dx + y*dy)/length2
    local cross = x*dy - y*dx
    local spread2 = (cross/omega - cross*cross/length2)/length2
    local cursor = 0
    local function cut(t)
        if t > cursor and t < 1 then
            bracket(cursor, t)
            cursor = t
        end
    end
    local spread = spread2 > 0 and math.sqrt(spread2) or 0
    cut(closest-spread)
    cut(closest)
    cut(closest+spread)
    bracket(cursor, 1)
end

---@param profile table Resolved motor profile
---@param before number Unwrapped starting travel
---@param after number Unwrapped ending travel
---@param x number Starting offset east
---@param y number Starting offset north
---@param dx number Displacement east
---@param dy number Displacement north
---@param emit function Receives arm, pass, travel and fraction of the interval
function Sweep.crossings(profile, before, after, x, y, dx, dy, emit)
    if after <= before then return end
    local first = before
    local stationary = dx*dx + dy*dy <= 1e-16
    local bearing = stationary and math.deg(math.atan2(y,x)) - profile.heading
    while first < after do
        local last = math.min(after, first + 45)
        if not profile.omni then
            last = math.min(last, (math.floor(first/profile.cone)+1)*profile.cone)
        end
        if stationary then
            local arm, pass, travel = Heads.crossing(bearing, first, last, profile.omni, profile.cone)
            if arm then emit(arm, pass, travel, (travel-before)/(after-before)) end
        else
            local a = (first-before)/(after-before)
            local span = (last-first)/(after-before)
            moving(profile, first, last, x+dx*a, y+dy*a, dx*span, dy*span, function(arm, pass, travel, t)
                emit(arm, pass, travel, a+span*t)
            end)
        end
        first = last
    end
end

return Sweep
