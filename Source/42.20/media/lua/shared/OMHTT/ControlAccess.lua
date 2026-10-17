local A = {}
A.remote = setmetatable({}, {__mode = "k"})

---@param object IsoObject Device
---@return table? state
function A.state(object)
    if not object then return nil end
    if not isClient() then return require("OMHTT/ControlWorld").state(object) end
    if not object:hasModData() then return nil end
    local state = object:getModData().OMHTTControl
    return type(state) == "table" and state or nil
end

---@param player IsoPlayer Operator
---@param object IsoObject Device
---@return boolean nearby
---@nodiscard
function A.near(player, object)
    if not player or player:isDead() or not object or object:getObjectIndex() < 0 then return false end
    local origin, square = player:getSquare(), object:getSquare()
    if not origin or not square or origin:getZ() ~= square:getZ() then return false end
    local dx, dy = player:getX() - square:getX() - .5, player:getY() - square:getY() - .5
    return math.abs(origin:getX() - square:getX()) <= 1 and math.abs(origin:getY() - square:getY()) <= 1
        and math.abs(dx) <= 1.6 and math.abs(dy) <= 1.6 and (origin == square or origin:canReachTo(square))
end

---@param first IsoObject Device
---@param second IsoObject Device
---@return boolean within
---@nodiscard
function A.range(first, second)
    if not first or not second or first:getObjectIndex() < 0 or second:getObjectIndex() < 0 then return false end
    local a, b = first:getSquare(), second:getSquare()
    if not a or not b or a:getZ() ~= b:getZ() then return false end
    return (a:getX() - b:getX()) ^ 2 + (a:getY() - b:getY()) ^ 2 <= 400
end

---@param player IsoPlayer Operator
---@param state table? Device ownership
---@param policy boolean? Changing access policy
---@return boolean allowed
---@nodiscard
function A.write(player, state, policy)
    if not player or player:isDead() then return false end
    if not state then return true end
    local name = player:getUsername()
    if name == state.owner or player:getAccessLevel() == "Admin" or player:getAccessLevel() == "admin" then return true end
    if policy then return false end
    if state.access == "Public" then return true end
    if state.access ~= "Faction" or not state.faction then return false end
    local faction = Faction.getPlayerFaction(player)
    if not faction or faction:getName() ~= state.faction then return false end
    return faction:getOwner() == state.owner or faction:getPlayers():contains(state.owner)
end

---@param player IsoPlayer Operator
---@param object IsoObject Assigned target
---@param read boolean? Read-only request
---@return boolean reachable
function A.remoteAllowed(player, object, read)
    if not player or player:isDead() or not object or object:getObjectIndex() < 0 then return false end
    local state = A.state(object)
    if not read and not A.write(player, state) then return false end
    local sessions = A.remote[player]
    local session = sessions and sessions[object]
    if not session or session.target ~= object or getTimestampMs() > session.untilTime then return false end
    local controller = session.controller
    local host = A.state(controller)
    if not host or not state or state.controller ~= host.id or host.kind ~= "Controller"
        or controller:getHealth() <= 0 or not A.near(player, controller) or not A.range(controller, object) then return false end
    if not read and not A.write(player, host) then return false end
    return host.powered == true
end

---@param player IsoPlayer Operator
---@param object IsoObject Device
---@param read boolean? Read-only request
---@return boolean reachable
function A.authorized(player, object, read)
    if not player or player:isDead() or not object or object:getObjectIndex() < 0 then return false end
    if not read and not A.write(player, A.state(object)) then return false end
    return A.near(player, object) or A.remoteAllowed(player, object, read)
end

---@param player IsoPlayer Operator
---@param object IsoObject Turret
---@return IsoObject? controller Authorized remote stockpile
function A.stockpile(player, object)
    local sessions = A.remote[player]
    local session = sessions and sessions[object]
    if session and session.target == object and A.remoteAllowed(player, object) then
        return session.controller
    end
end

---@param player IsoPlayer Operator
---@param controller IsoObject Authorized controller
---@param target IsoObject Assigned endpoint
---@return nil
function A.session(player, controller, target)
    local sessions = A.remote[player]
    if not sessions then
        sessions = setmetatable({}, {__mode = "k"})
        A.remote[player] = sessions
    end
    local now = getTimestampMs()
    for object, session in pairs(sessions) do
        if session.untilTime < now then
            sessions[object] = nil
        end
    end
    sessions[target] = {controller = controller, target = target, untilTime = now + 15000}
end

return A

