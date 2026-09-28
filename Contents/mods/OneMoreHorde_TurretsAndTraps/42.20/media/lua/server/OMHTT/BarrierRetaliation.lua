if isClient() then return end

local Footprint = require("OMHTT/BarrierFootprint")
local Foundation = require("OMHTT/Foundation")
local Damage = require("OMHTT/Damage")
local Diagnostics = require("OMHTT/Diagnostics")
local Barrier = {TYPE = "OMHTTBarrierClaw", TOKEN = "OMHTTBarrierStrike"}
local generation = 0

---@param record table Authoritative barrier geometry
---@param x number Attacker world X
---@param y number Attacker world Y
---@param edge table? Exact outline segment
---@return string face Front, side or rear
---@nodiscard
function Barrier.face(record, x, y, edge)
    if edge then
        local outward = (x - (edge.x + edge.tx) / 2) * edge.nx + (y - (edge.y + edge.ty) / 2) * edge.ny
        if outward < 0 then return "rear" end
        if edge.role == "cap" then return "side" end
        return "front"
    end
    local nx, ny = Foundation.barrierDirection(record.facing)
    local width = 1
    if record.width == 2 then
        width = 2
    end
    local dx = x - record.x - 0.5 + ny * (width - 1) * 0.5
    local dy = y - record.y - 0.5 - nx * (width - 1) * 0.5
    local depth = 0.5
    if record.collisionModel == "edge-v1" then
        dx = dx + math.abs(nx) * 0.5
        dy = dy + math.abs(ny) * 0.5
        depth = 0
    elseif record.collisionModel == "outline-v1" then
        dx, dy = dx - nx * 0.5, dy - ny * 0.5
        depth = 0
    end
    local forward = dx * nx + dy * ny
    local lateral = -dx * ny + dy * nx
    local sideDistance = math.abs(lateral) - width * 0.5
    if forward < 0 and -forward - depth >= sideDistance then return "rear" end
    if forward - depth >= sideDistance then return "front" end
    return "side"
end

---@param zombie IsoZombie Previously tracked attacker
---@return nil
function Barrier.release(zombie)
    if not zombie:hasModData() then return end
    local data = zombie:getModData()
    local state = data.OMHTTBarrierStrike
    if not state then return end
    if zombie:getVariableString("ThumpType") == Barrier.TYPE then
        zombie:setVariable("ThumpType", state.previousType)
    end
    zombie:clearVariable(Barrier.TOKEN)
    data.OMHTTBarrierStrike = nil
end

---@return nil
function Barrier.reset()
    generation = getTimestampMs()
end

---@param zombie IsoZombie Engine-updated zombie
---@return nil
function Barrier.update(zombie)
    if isClient() or isServer() then return end
    local data = nil
    if zombie:hasModData() then
        data = zombie:getModData()
    end
    local target = zombie:getThumpTarget()
    if zombie:isDead() or not target or zombie:getCurrentStateName() ~= "ThumpState"
        or not Foundation.barrierEnabled() then
        if data and data.OMHTTBarrierStrike then
            Barrier.release(zombie)
        end
        return
    end
    local record = Footprint.exact(target)
    local square = zombie:getSquare()
    if not record or not square or square:getZ() ~= target:getSquare():getZ()
        or (record.placementSource ~= "construction" and SandboxVars.OMHTurretsTraps.FoundationTestControls ~= true) then
        if data and data.OMHTTBarrierStrike then
            Barrier.release(zombie)
        end
        return
    end
    local dx = zombie:getX() - target:getSquare():getX() - 0.5
    local dy = zombie:getY() - target:getSquare():getY() - 0.5
    if dx * dx + dy * dy > 4 then
        Barrier.release(zombie)
        return
    end
    if not data then
        data = zombie:getModData()
    end
    local state = data.OMHTTBarrierStrike
    if not state or state.id ~= record.id or state.generation ~= generation then
        Barrier.release(zombie)
        local previousType = zombie:getVariableString("ThumpType")
        if not previousType or previousType == Barrier.TYPE then
            previousType = "DoorClaw"
        end
        state = {id = record.id, generation = generation, previousType = previousType, token = "", strikes = 0,
            lastStrikeAt = getTimestampMs(), nextWarning = getTimestampMs() + 5000}
        data.OMHTTBarrierStrike = state
        zombie:clearVariable(Barrier.TOKEN)
        zombie:setVariable("ThumpType", Barrier.TYPE)
        Diagnostics.emit("barrier-attacker-attached", {id = record.id, x = zombie:getX(), y = zombie:getY(),
            animation = Barrier.TYPE, damage100 = Foundation.barrierDamage(record)})
        return
    end
    if zombie:getVariableString("ThumpType") ~= Barrier.TYPE then
        Barrier.release(zombie)
        return
    end
    local token = zombie:getVariableString(Barrier.TOKEN)
    local now = getTimestampMs()
    if (token ~= "left" and token ~= "right") or token == state.token then
        if now >= state.nextWarning then
            Diagnostics.emit("barrier-marker-wait", {id = record.id, token = tostring(token),
                elapsedMs = now - state.lastStrikeAt, barrierHP = target:getHealth(), strikes = state.strikes})
            state.nextWarning = now + 5000
        end
        return
    end
    local elapsed = now - state.lastStrikeAt
    state.lastStrikeAt = now
    state.nextWarning = now + 5000
    state.token = token
    state.strikes = state.strikes + 1
    local face = Barrier.face(record, zombie:getX(), zombie:getY(), target:getModData().OMHTTEdge)
    if face == "rear" then
        Diagnostics.emit("barrier-strike-blocked", {id = record.id, face = face, facing = record.facing,
            token = token, x = zombie:getX(), y = zombie:getY(), barrierHP = target:getHealth()})
        return
    end
    local lost = Damage.apply(zombie, Foundation.barrierDamage(record) / 100, record.id, "barrier", nil, nil)
    Diagnostics.emit("barrier-strike", {id = record.id, token = token, strikes = state.strikes,
        face = face, facing = record.facing, width = record.width,
        x = zombie:getX(), y = zombie:getY(), nativeDamage = lost, damage100 = lost * 100,
        barrierHP = target:getHealth(), elapsedMs = elapsed, dead = zombie:isDead()})
    if zombie:isDead() then
        Barrier.release(zombie)
    end
end

Events.OnGameStart.Add(Barrier.reset)
Events.OnZombieUpdate.Add(Barrier.update)
Events.OnZombieDead.Add(Barrier.release)

return Barrier
