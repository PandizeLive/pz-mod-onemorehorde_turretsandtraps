local Clock = require("OMHTT/ControlClock")
local Movement = require("OMHTT/BarbMovement")
local D = {}
local active = setmetatable({}, {__mode = "k"})
local names = {"OMHTTPullForward", "OMHTTPullRight", "OMHTTPullBack", "OMHTTPullLeft"}

---@param zombie IsoZombie Target
---@return boolean owned Tether reaction
local function reacting(zombie)
    local name = zombie:getBumpType()
    for i = 1, #names do
        if name == names[i] then return true end
    end
    return false
end

---@param zombie IsoZombie Target
---@return nil
function D.clear(zombie)
    local motion = active[zombie]
    if motion then zombie:setDeferredMovementEnabled(motion.deferred) end
    active[zombie] = nil
    if reacting(zombie) then
        zombie:setVariable("BumpAnimFinished", true)
        zombie:setBumpType("")
    end
end

---@param zombie IsoZombie Target
---@param motion table Active pull
---@param now number Simulation time
---@return nil
local function finish(zombie, motion, now)
    zombie:setVariable("BumpAnimFinished", true)
    zombie:setBumpType("")
    motion.finishing = now + 150
end

---@param zombie IsoZombie Target
---@param x number Muzzle X
---@param y number Muzzle Y
---@return number? heading Aligned facing in radians
function D.present(zombie, x, y)
    if zombie:isDead() or zombie:isProne() or Movement.traversing(zombie) or zombie:isStaggerBack()
        or (zombie:getBumpType() ~= "" and not reacting(zombie)) then return end
    local dx, dy = x - zombie:getX(), y - zombie:getY()
    if dx * dx + dy * dy <= .0001 then return end
    local heading = zombie:getDirectionAngleRadians()
    local angle = math.atan2(dy, dx)
    local relative = math.atan2(math.sin(angle - heading), math.cos(angle - heading))
    local quarter = math.floor(relative / (math.pi / 2) + .5)
    local target = angle - quarter * math.pi / 2
    zombie:setVariable("BumpAnimFinished", false)
    zombie:setBumpType(names[(quarter + 4) % 4 + 1])
    if isClient() and zombie:isRemoteZombie() then
        local old = active[zombie]
        local deferred = zombie:isDeferredMovementEnabled()
        if old then deferred = old.deferred end
        active[zombie] = {visualOnly = true, deferred = deferred, expires = Clock.now() + 500}
        zombie:setDeferredMovementEnabled(false)
    end
    return target
end

---@param zombie IsoZombie Locally simulated target
---@param x number Muzzle X
---@param y number Muzzle Y
---@param distance number Maximum displacement in tiles
---@return boolean? started
function D.start(zombie, x, y, distance)
    if distance <= 0 or (isClient() and zombie:isRemoteZombie())
        or (isServer() and zombie:getOwner() ~= nil) then return end
    local dx, dy = x - zombie:getX(), y - zombie:getY()
    local length = math.sqrt(dx * dx + dy * dy)
    distance = math.min(distance, math.max(0, length - .35))
    if distance <= 0 then return end
    local heading = D.present(zombie, x, y)
    if not heading and (not zombie:isCrawling() or Movement.traversing(zombie) or zombie:isDead()) then return end
    local now = Clock.now()
    local old = active[zombie]
    local deferred = zombie:isDeferredMovementEnabled()
    if old then deferred = old.deferred end
    active[zombie] = {dx = dx / length, dy = dy / length, remaining = distance, heading = heading,
        speed = distance / 500, last = now, expires = now + 500, z = math.floor(zombie:getZ()), deferred = deferred}
    -- Native 42.21 ignores the AnimNode movement flag; use the exposed actor gate.
    zombie:setDeferredMovementEnabled(false)
    return true
end

---@param zombie IsoZombie Native update before collision resolution
---@return nil
function D.update(zombie)
    local motion = active[zombie]
    if not motion then return end
    local now, square = Clock.now(), zombie:getSquare()
    if motion.finishing then
        if now >= motion.finishing or zombie:isDead() or Movement.traversing(zombie)
            or (not motion.visualOnly and ((isClient() and zombie:isRemoteZombie())
                or (isServer() and zombie:getOwner() ~= nil)))
            or (zombie:getBumpType() ~= "" and not reacting(zombie)) then D.clear(zombie) end
        return
    end
    if motion.visualOnly then
        if not zombie:isRemoteZombie() or zombie:isDead() or Movement.traversing(zombie) then D.clear(zombie)
        elseif now >= motion.expires then finish(zombie, motion, now) end
        return
    end
    if zombie:isDead() or not square or math.floor(zombie:getZ()) ~= motion.z or Movement.traversing(zombie)
        or (motion.heading and (not reacting(zombie) or zombie:isProne())) or zombie:isStaggerBack()
        or (isClient() and zombie:isRemoteZombie()) or (isServer() and zombie:getOwner() ~= nil)
        or now < motion.last then
        D.clear(zombie)
        return
    end
    if now > motion.expires then finish(zombie, motion, now); return end
    local elapsed = now - motion.last
    motion.last = now
    if elapsed <= 0 then return end
    local amount = math.min(.075, motion.remaining, elapsed * motion.speed)
    local x, y = zombie:getX(), zombie:getY()
    local nx, ny = x + motion.dx * amount, y + motion.dy * amount
    local destination = getCell():getGridSquare(math.floor(nx), math.floor(ny), motion.z)
    if not destination or destination:isSolid() or destination:isSolidTrans()
        or (destination ~= square and square:isBlockedTo(destination)) then
        D.clear(zombie)
        return
    end
    if motion.heading then
        local facing = zombie:getDirectionAngleRadians()
        local angle = math.atan2(math.sin(motion.heading - facing), math.cos(motion.heading - facing))
        local turn = math.min(elapsed, 50) * math.pi / 1000
        angle = facing + math.max(-turn, math.min(turn, angle))
        zombie:setTargetAndCurrentDirection(math.cos(angle), math.sin(angle))
    end
    zombie:setNextX(nx)
    zombie:setNextY(ny)
    motion.remaining = motion.remaining - amount
    if motion.remaining <= .000001 then finish(zombie, motion, now) end
end

Events.OnZombieUpdate.Add(D.update)
Events.OnZombieCreate.Add(D.clear)
return D
