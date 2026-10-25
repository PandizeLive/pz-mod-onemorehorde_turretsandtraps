if isClient() then return end

local Footprint = require("OMHTT/BarrierFootprint")
local Foundation = require("OMHTT/Foundation")
local Damage = require("OMHTT/Damage")
local Horde = require("OMHTT/DefenseHorde")
local Diagnostics = require("OMHTT/Diagnostics")
local ActorState = require("OMHTT/DefenseActorState")
local Barrier = {TYPE = "OMHTTBarrierClaw", TOKEN = "OMHTTBarrierStrike"}
local generation = 0
local indexed = setmetatable({}, {__mode = "v"})
local receipts = setmetatable({}, {__mode = "k"})

---@param module string Namespace
---@param command string Observed native strike
---@param player IsoPlayer Authenticated sender
---@param message table Native identity and collider reference
---@return nil
function Barrier.command(module, command, player, message)
    if not isServer() or module ~= "OMHTT_BarrierContact" or command ~= "Strike" or type(message) ~= "table" then return end
    local P = require("OMHTT/DefenseCombatProtocol")
    if not P.identity(message.id) or not P.identity(message.outfit) or type(message.barrier) ~= "string"
        or #message.barrier > 160 or not P.number(message.x, 0, 1000000) or not P.number(message.y, 0, 1000000)
        or not P.number(message.z, -32, 32) or not P.number(message.index, 0, 10000)
        or message.index % 1 ~= 0 or message.x % 1 ~= 0 or message.y % 1 ~= 0 or message.z % 1 ~= 0
        or (message.token ~= "left" and message.token ~= "right") then return end
    local zombie = indexed[message.id]
    if not zombie or zombie:getOnlineID() ~= message.id or zombie:isDead() or zombie:getPersistentOutfitID() ~= message.outfit
        or not zombie:getOwner() or not zombie:getOwner():havePlayer(player)
        or not Horde.allowed(zombie) or not Foundation.barrierEnabled() then return end
    if not string.find(string.lower(zombie:getRealState()), "thump", 1, true) then return end
    local square = getCell():getGridSquare(message.x, message.y, message.z)
    local objects = square and square:getObjects()
    if not objects or message.index >= objects:size() or zombie:getZ() ~= message.z then return end
    local target = objects:get(message.index)
    local record = Footprint.exact(target)
    if not record or record.id ~= message.barrier or target:getHealth() <= 0 then return end
    local dx, dy = zombie:getX() - message.x - .5, zombie:getY() - message.y - .5
    if dx * dx + dy * dy > 4 or Barrier.face(record, zombie:getX(), zombie:getY(), target:getModData().OMHTTEdge) == "rear" then return end
    local now, receipt = getTimestampMs(), receipts[zombie]
    if receipt and receipt.owner == player and receipt.id == record.id
        and (receipt.token == message.token or now - receipt.at < 200) then return end
    receipts[zombie] = {owner = player, id = record.id, token = message.token, at = now}
    Damage.resolve(zombie, Foundation.barrierDamage(record) / 100, record.id, "barrier")
end

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
    local data = ActorState.peek(zombie)
    if not data then return end
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
    if isClient() then return end
    if isServer() then
        local id = zombie:getOnlineID()
        if id ~= -1 then indexed[id] = zombie end
        if zombie:getOwner() then return end
    end
    local data = ActorState.peek(zombie)
    local target = zombie:getThumpTarget()
    if zombie:isDead() or not target or zombie:getCurrentStateName() ~= "ThumpState"
        or not Foundation.barrierEnabled() or not Horde.allowed(zombie) then
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
        data = ActorState.get(zombie)
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
            animation = Barrier.TYPE, damage100 = Foundation.barrierDamage(record)}, nil, nil, "traps")
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
                elapsedMs = now - state.lastStrikeAt, barrierHP = target:getHealth(), strikes = state.strikes}, nil, nil, "traps")
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
            token = token, x = zombie:getX(), y = zombie:getY(), barrierHP = target:getHealth()}, nil, nil, "traps")
        return
    end
    local lost = 0
    Damage.resolve(zombie, Foundation.barrierDamage(record) / 100, record.id, "barrier", function(amount) lost = amount end)
    Diagnostics.emit("barrier-strike", {id = record.id, token = token, strikes = state.strikes,
        face = face, facing = record.facing, width = record.width,
        x = zombie:getX(), y = zombie:getY(), nativeDamage = lost, damage100 = lost * 100,
        barrierHP = target:getHealth(), elapsedMs = elapsed, dead = zombie:isDead()}, nil, nil, "traps")
    if zombie:isDead() then
        Barrier.release(zombie)
    end
end

Events.OnGameStart.Add(Barrier.reset)
Events.OnServerStarted.Add(Barrier.reset)
Events.OnClientCommand.Add(Barrier.command)
Events.OnZombieUpdate.Add(Barrier.update)
Events.OnZombieDead.Add(Barrier.release)
Events.OnZombieCreate.Add(function(zombie)
    receipts[zombie] = nil
    Barrier.release(zombie)
    Barrier.update(zombie)
end)

return Barrier
