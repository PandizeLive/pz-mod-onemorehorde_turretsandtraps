local P = require("OMHTT/DefenseCombatProtocol")
local H = require("OMHTT/DefenseHorde")
local M = {checks = {}}
local indexed = setmetatable({}, {__mode = "v"})
local contacts = setmetatable({}, {__mode = "k"})
local serial = 0

---@param zombie IsoZombie Locally simulated actor
---@param kind string Validated reaction
---@param x number Origin/direction X
---@param y number Origin/direction Y
---@param distance number? Bounded tether displacement
---@return nil
local function apply(zombie, kind, x, y, distance)
    if not P.living(zombie) then return end
    if kind == "pull" then
        require("OMHTT/DefenseDisplacement").start(zombie, x, y, distance or 0)
    elseif kind == "visualPull" then
        require("OMHTT/DefenseDisplacement").present(zombie, x, y)
    elseif kind == "trip" then
        if zombie:isOnFloor() or zombie:isKnockedDown() or zombie:getBumpType() ~= "" then return end
        zombie:setVariable("BumpAnimFinished", false)
        zombie:setVariable("SprinterTripped", false)
        zombie:setVariable("OMHTTBedLanded", false)
        zombie:setBumpType("OMHTTBedTrip")
    elseif kind == "knock" then
        if zombie:isOnFloor() or zombie:isKnockedDown() then return end
        zombie:knockDown(false)
        if x ~= 0 or y ~= 0 then
            zombie:setPlayerAttackPosition("FRONT")
            zombie:setUsePhysicHitReaction(false)
            local dx, dy = zombie:getX() - x, zombie:getY() - y
            local length = math.sqrt(dx * dx + dy * dy)
            if length > 0 then zombie:setHitDir(Vector2.new(dx / length, dy / length)) end
            zombie:setHitForce(.35)
        end
    elseif kind == "stagger" then
        if zombie:isProne() or zombie:isKnockedDown() or zombie:isStaggerBack() then return end
        local dx, dy = zombie:getX() - x, zombie:getY() - y
        local length = math.sqrt(dx * dx + dy * dy)
        if length > 0 then zombie:setHitDir(Vector2.new(dx / length, dy / length)) end
        zombie:setHitForce(.1)
        zombie:setStaggerBack(true)
    end
end

---@param zombie IsoZombie Exact server victim
---@param kind string trip, knock, stagger or slow
---@param source string Server defense identity
---@param x number? Origin X or slowdown divisor
---@param y number? Origin Y
---@param distance number? Bounded tether displacement
---@return boolean accepted
function M.request(zombie, kind, source, x, y, distance)
    if isClient() or not zombie or zombie:isDead() or not H.allowed(zombie) then return false end
    if kind ~= "trip" and kind ~= "knock" and kind ~= "stagger" and kind ~= "slow"
        and kind ~= "pull" then return false end
    if kind == "pull" and not P.number(distance, 0, 2) then return false end
    local lease = H.capture(zombie)
    if not H.mark(zombie, lease, source, kind) then return false end
    local player = isServer() and zombie:getOwnerPlayer()
    if player and zombie:getOwner() then
        if zombie:getOnlineID() == -1 then return false end
        -- Contact slowdown is applied by the owner on the exact local frame,
        -- under the short approach consent lease. Do not send delayed impulses.
        if kind == "slow" then return true end
        serial = serial + 1
        sendServerCommand(player, "OMHTT_MotionV1", kind, {id = zombie:getOnlineID(),
            outfit = require("OMHTT/DefenseCombatProtocol").outfit(zombie:getPersistentOutfitID()), serial = serial, source = source, x = x or 0, y = y or 0, distance = distance})
        if kind == "trip" or (kind == "pull" and distance > 0) then
            require("OMHTT/DefenseEffects").send("OMHTT_MotionV1", kind == "trip" and "visualTrip" or "visualPull", {
                id = zombie:getOnlineID(), outfit = require("OMHTT/DefenseCombatProtocol").outfit(zombie:getPersistentOutfitID()), serial = serial,
                x = x or 0, y = y or 0, fromX = zombie:getX(), fromY = zombie:getY()})
        end
    elseif kind == "slow" then
        require("OMHTT/BarbMovement").apply(zombie, x)
    else
        apply(zombie, kind, x or 0, y or 0, distance)
    end
    return true
end

---@param module string Server namespace
---@param command string Reaction
---@param message table Server facts
---@return nil
function M.command(module, command, message)
    if not isClient() or module ~= "OMHTT_MotionV1" or type(message) ~= "table"
        or not P.identity(message.id) or not P.identity(message.outfit)
        or not P.number(message.serial, 1, 1000000000000)
        or not P.number(message.x, -1000000, 1000000) or not P.number(message.y, -1000000, 1000000) then return end
    if command == "pull" and not P.number(message.distance, 0, 2) then return end
    local zombie = indexed[message.id]
    if not P.living(zombie) or zombie:getOnlineID() ~= message.id
        or require("OMHTT/DefenseCombatProtocol").outfit(zombie:getPersistentOutfitID()) ~= message.outfit then return end
    if command == "visualTrip" or command == "visualPull" then
        if not zombie:isRemoteZombie() then return end
    elseif zombie:isRemoteZombie() then
        return
    end
    local contact = contacts[zombie]
    if contact and message.serial <= contact.serial then return end
    contact = contact or {}
    contact.serial = message.serial
    contacts[zombie] = contact
    if command == "visualTrip" then
        apply(zombie, "trip", 0, 0)
    else
        apply(zombie, command, message.x, message.y, message.distance)
    end
end

---@param zombie IsoZombie Updated native actor
---@return nil
function M.update(zombie)
    if not isClient() or not P.living(zombie) then return end
    local id = zombie:getOnlineID()
    if id ~= -1 then indexed[id] = zombie end
    if not require("OMHTT/DefenseContactClient").permitted(zombie) then return end
    local divisor = 1
    for _, check in pairs(M.checks) do
        local value = check(zombie)
        if type(value) == "number" then divisor = math.max(divisor, value) end
    end
    if divisor > 1 then require("OMHTT/BarbMovement").apply(zombie, divisor) end
end

---@param zombie IsoZombie Recycled actor
---@return nil
function M.created(zombie)
    contacts[zombie] = nil
    M.update(zombie)
end

Events.OnZombieUpdate.Add(M.update)
Events.OnZombieCreate.Add(M.created)
Events.OnServerCommand.Add(M.command)
return M
