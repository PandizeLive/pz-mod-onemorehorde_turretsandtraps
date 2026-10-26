local Clock = require("OMHTT/ControlClock")
local Movement = require("OMHTT/BarbMovement")
local D = {}
local active = setmetatable({}, {__mode = "k"})

---@param zombie IsoZombie Locally simulated target
---@param pulling boolean Move toward rather than away from the muzzle
---@param x number Muzzle X
---@param y number Muzzle Y
---@param distance number Maximum displacement in tiles
---@return nil
function D.start(zombie, pulling, x, y, distance)
    if distance <= 0 or zombie:isDead() or Movement.traversing(zombie) then return end
    local dx, dy = zombie:getX() - x, zombie:getY() - y
    local length = math.sqrt(dx * dx + dy * dy)
    if length <= .01 then return end
    if pulling then
        distance = math.min(distance, math.max(0, length - .35))
        dx, dy = -dx, -dy
    end
    if distance <= 0 then return end
    local now = Clock.now()
    local duration = pulling and 500 or 250
    active[zombie] = {dx = dx / length, dy = dy / length, remaining = distance,
        speed = distance / duration, last = now, expires = now + duration, z = math.floor(zombie:getZ())}
end

---@param zombie IsoZombie Native update before collision resolution
---@return nil
function D.update(zombie)
    local motion = active[zombie]
    if not motion then return end
    local now, square = Clock.now(), zombie:getSquare()
    if zombie:isDead() or not square or math.floor(zombie:getZ()) ~= motion.z or Movement.traversing(zombie)
        or (isClient() and zombie:isRemoteZombie()) or (isServer() and zombie:getOwner() ~= nil)
        or now > motion.expires or now < motion.last then
        active[zombie] = nil
        return
    end
    local elapsed = now - motion.last
    motion.last = now
    if elapsed <= 0 then return end
    -- Consume elapsed force without a teleport or a backlog after fast-forward.
    local amount = math.min(.075, motion.remaining, elapsed * motion.speed)
    local x, y = zombie:getX(), zombie:getY()
    local nx, ny = x + motion.dx * amount, y + motion.dy * amount
    local destination = getCell():getGridSquare(math.floor(nx), math.floor(ny), motion.z)
    if not destination or destination:isSolid() or destination:isSolidTrans()
        or (destination ~= square and square:isBlockedTo(destination)) then
        active[zombie] = nil
        return
    end
    -- Feed pending movement into native collision handling; never set world position.
    zombie:setNextX(nx)
    zombie:setNextY(ny)
    motion.remaining = motion.remaining - amount
    if motion.remaining <= .000001 then
        active[zombie] = nil
    end
end

---@param zombie IsoZombie Recycled actor
---@return nil
function D.clear(zombie)
    active[zombie] = nil
end

Events.OnZombieUpdate.Add(D.update)
Events.OnZombieCreate.Add(D.clear)
return D
