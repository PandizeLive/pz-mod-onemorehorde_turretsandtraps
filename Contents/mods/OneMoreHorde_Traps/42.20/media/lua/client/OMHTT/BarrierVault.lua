if isServer() then return end
require("TimedActions/ISClimbOverFence")
local F = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local Vault = {}
local active = {}
local sequence = 0
local lastInputReport = {}

---@param player IsoPlayer Acting player
---@param object IsoThumpable Selected part
---@param id string Expected identity
---@return table? plan Validated crossing
---@return string? reason Rejection translation key
function Vault.plan(player, object, id)
    if isServer() or not F.barrierEnabled() or player:isDead() then return nil, "UI_OMHTT_Unavailable" end
    local Footprint = require(isClient() and "OMHTT/BarrierView" or "OMHTT/BarrierFootprint")
    local record = Footprint.exact(object)
    if not record or record.id ~= id or not Footprint.parts(record) then return nil, "UI_OMHTT_Unavailable" end
    if record.collisionModel ~= "edge-v1" and record.collisionModel ~= "outline-v1" then return nil, "ContextMenu_OMHTT_VaultRedeploy" end
    if active[player] or player:getCurrentState() == ClimbOverFenceState.instance() then return nil, "ContextMenu_OMHTT_VaultBusy" end
    local from = player:getCurrentSquare()
    if not from or from:getZ() ~= record.z then return nil, "ContextMenu_OMHTT_VaultApproach" end
    local parts = Footprint.colliders(record)
    if object:getModData().OMHTTEdge then
        parts = {object}
    end
    for i = 1, #parts do
        local part = parts[i]
        local north = part:getNorth()
        local square = part:getSquare()
        local x, y = square:getX(), square:getY()
        local negativeX, negativeY = x - 1, y
        if north then
            negativeX, negativeY = x, y - 1
        end
        local positive = from:getX() == x and from:getY() == y
        local negative = from:getX() == negativeX and from:getY() == negativeY
        if positive or negative then
            if part:getNorth() ~= north or part:isBlockAllTheSquare() or part:isCanPassThrough() or part:isHoppable() then
                return nil, "UI_OMHTT_Unavailable"
            end
            local toX, toY, direction = x, y, IsoDirections.E
            if north then
                direction = IsoDirections.S
            end
            if positive then
                toX, toY, direction = negativeX, negativeY, IsoDirections.W
                if north then
                    direction = IsoDirections.N
                end
            end
            local landing = getCell():getGridSquare(toX, toY, record.z)
            if not landing or not landing:getFloor() or not landing:isFree(false)
                or landing:HasStairs() or landing:HasStairsBelow() or landing:getMovingObjects():size() > 0
                or landing:has(IsoFlagType.water) or landing:getVehicleContainer() then
                return nil, "ContextMenu_OMHTT_VaultLanding"
            end
            local objects = landing:getObjects()
            for j = 0, objects:size() - 1 do
                local other = objects:get(j)
                if instanceof(other, "IsoThumpable") and other:isBlockAllTheSquare() then
                    return nil, "ContextMenu_OMHTT_VaultLanding"
                end
            end
            if not from:isPlayerAbleToHopWallTo(direction, landing)
                or not IsoWindow.canClimbThroughHelper(player, from, landing, north) then
                return nil, "ContextMenu_OMHTT_VaultLanding"
            end
            local side = "rear"
            local edge = part:getModData().OMHTTEdge
            if edge and edge.role == "cap" then
                side = "side"
            elseif positive == (record.facing == 0 or record.facing == 12) then
                side = "front"
            end
            return {object = part, id = id, side = side, direction = direction,
                fromX = from:getX(), fromY = from:getY(), toX = toX, toY = toY, z = record.z}
        end
    end
    return nil, "ContextMenu_OMHTT_VaultApproach"
end

---@param player IsoPlayer Acting player
---@param plan table Crossing state
---@param result string Terminal result
---@return nil
local function finish(player, plan, result)
    active[player] = nil
    Diagnostics.emit("barrier-vault-result", {crossing = plan.sequence, id = plan.id, side = plan.side,
        result = result, roll = plan.roll, injured = plan.injured, contact = plan.contact, godMode = player:isGodMod(),
        x = player:getX(), y = player:getY(), z = player:getZ(), outcome = plan.outcome,
        state = tostring(player:getCurrentState()), fromX = plan.fromX, fromY = plan.fromY, toX = plan.toX, toY = plan.toY,
        animationStarted = plan.animationStarted == true, entered = plan.entered == true,
        elapsedMs = getTimestampMs() - plan.startedAt}, nil, nil, "traps")
end

---@param player IsoPlayer Local player update
---@return nil
function Vault.update(player)
    if isClient() and not player:isLocalPlayer() then return end
    local plan = active[player]
    if not plan then
        Vault.autoVault(player)
        return
    end
    local Footprint = require(isClient() and "OMHTT/BarrierView" or "OMHTT/BarrierFootprint")
    local record = Footprint.exact(plan.object)
    if player:isDead() or not record or record.id ~= plan.id or not Footprint.parts(record)
        or not F.barrierEnabled() then
        finish(player, plan, "cancelled")
        return
    end
    local state = player:getCurrentState()
    local climbing = state == ClimbOverFenceState.instance()
    if climbing then
        if not plan.entered then
            plan.entered = true
            Diagnostics.emit("barrier-vault-enter", {crossing = plan.sequence, id = plan.id, side = plan.side}, nil, nil, "traps")
        end
        if player:getVariableBoolean("ClimbFenceStarted") or player:getVariableBoolean("VaultOverRun")
            or player:getVariableBoolean("VaultOverSprint") then
            plan.animationStarted = true
        end
        plan.outcome = player:getVariableString("ClimbFenceOutcome")
        local crossedPlane = math.floor(player:getX()) == plan.toX and math.floor(player:getY()) == plan.toY
        if plan.animationStarted and crossedPlane and not plan.contact
            and (plan.outcome == "success" or plan.outcome == "fall") then
            Vault.contact(player, plan)
        end
    elseif plan.entered then
        local landed = math.floor(player:getX()) == plan.toX and math.floor(player:getY()) == plan.toY
            and math.floor(player:getZ()) == plan.z
        if plan.contact and math.floor(player:getZ()) == plan.z then
            local dx, dy = plan.toX - plan.fromX, plan.toY - plan.fromY
            local progress = (player:getX() - plan.fromX - 0.5) * dx + (player:getY() - plan.fromY - 0.5) * dy
            landed = progress >= 0.5
        end
        local recovered = state == IdleState.instance() or state == PlayerMovementState.instance()
        if landed and recovered and plan.animationStarted and plan.outcome == "success" then
            if not plan.contact then
                Vault.contact(player, plan)
            end
            finish(player, plan, "crossed")
        else
            finish(player, plan, "interrupted")
        end
        return
    end
    local elapsed = getTimestampMs() - plan.startedAt
    if elapsed < 0 or elapsed > 15000 or (not plan.entered and elapsed > 1500) then
        finish(player, plan, "native-entry-timeout")
    end
end

OMHTTBarrierVaultAction = ISClimbOverFence:derive("OMHTTBarrierVaultAction")

---@return boolean valid
function OMHTTBarrierVaultAction:isValid()
    return Vault.plan(self.character, self.item, self.omhttId) ~= nil
end

---@return nil
function OMHTTBarrierVaultAction:perform()
    local plan, reason = Vault.plan(self.character, self.item, self.omhttId)
    if plan and plan.fromX == self.omhttFromX and plan.fromY == self.omhttFromY then
        Vault.begin(self.character, plan, "menu")
        self.direction = plan.direction
        ISClimbOverFence.perform(self)
    else
        Diagnostics.emit("barrier-vault-refused", {id = self.omhttId, reason = reason or "approach-changed"}, nil, nil, "traps")
        ISBaseTimedAction.perform(self)
    end
end

---@param character IsoPlayer Acting player
---@param object IsoThumpable Selected part
---@param plan table Validated crossing
---@return OMHTTBarrierVaultAction action
function OMHTTBarrierVaultAction:new(character, object, plan)
    local action = ISClimbOverFence.new(self, character, object, plan.direction)
    action.isTallHoppable = false
    action.omhttId, action.omhttFromX, action.omhttFromY = plan.id, plan.fromX, plan.fromY
    return action
end

---@param object IsoThumpable Selected part
---@param player IsoPlayer Acting player
---@param id string Expected identity
---@return nil
function Vault.queue(object, player, id)
    local plan, reason = Vault.plan(player, object, id)
    if not plan then
        Diagnostics.emit("barrier-vault-refused", {id = id, reason = reason}, nil, nil, "traps")
        return
    end
    ISTimedActionQueue.add(OMHTTBarrierVaultAction:new(player, plan.object, plan))
end

---@param player IsoPlayer Crossing player
---@param plan table Validated crossing
---@param source string Input route
---@return nil
function Vault.begin(player, plan, source)
    sequence = sequence + 1
    plan.sequence, plan.startedAt = sequence, getTimestampMs()
    plan.roll, plan.injured, plan.contact = -1, false, false
    active[player] = plan
    Diagnostics.emit("barrier-vault-start", {crossing = sequence, id = plan.id, side = plan.side,
        fromX = plan.fromX, fromY = plan.fromY, toX = plan.toX, toY = plan.toY, z = plan.z,
        input = source, running = player:isRunning(), sprinting = player:isSprinting()}, nil, nil, "traps")
end

---@param player IsoPlayer Crossing player
---@param plan table Active crossing
---@return nil
function Vault.contact(player, plan)
    plan.contact = true
    local denominator = F.barrierScratchChance()
    if plan.side == "front" and denominator > 0 then
        plan.roll = ZombRand(denominator)
        if plan.roll == 0 and not player:isGodMod() then
            require("OMHTT/DefenseInjury").contact(player, plan.id, "scratch")
            plan.injured = true
        end
    end
    Diagnostics.emit("barrier-vault-contact", {crossing = plan.sequence, id = plan.id, side = plan.side,
        denominator = denominator, roll = plan.roll, injured = plan.injured, outcome = plan.outcome}, nil, nil, "traps")
end

---@param player IsoPlayer Local player
---@param direction IsoDirections Cardinal crossing direction
---@return table? plan Exact barrier crossing
---@return table? refusal Nearby barrier rejection
---@nodiscard
function Vault.forDirection(player, direction)
    local from = player:getCurrentSquare()
    if not from then return nil end
    local x, y = from:getX(), from:getY()
    if direction == IsoDirections.S then
        y = y + 1
    end
    if direction == IsoDirections.E then
        x = x + 1
    end
    local square = getCell():getGridSquare(x, y, from:getZ())
    if not square then return nil end
    local Footprint = require(isClient() and "OMHTT/BarrierView" or "OMHTT/BarrierFootprint")
    local objects = square:getSpecialObjects()
    local refusal = nil
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        local record = Footprint.exact(object)
        if record and not object:isCanPassThrough() then
            local plan, reason = Vault.plan(player, object, record.id)
            if plan and plan.direction == direction then return plan end
            if not plan then
                refusal = {id = record.id, direction = direction, reason = reason}
            end
        end
    end
    return nil, refusal
end

---@param player IsoPlayer Local player
---@param plan table Nearby barrier crossing
---@param reason string Input gate
---@param distance number Distance to collision plane
---@param reach number Native collision feeler distance
---@return nil
local function reportInput(player, plan, reason, distance, reach)
    local now = getTimestampMs()
    local previous = lastInputReport[player]
    local key = plan.id .. ":" .. tostring(plan.direction) .. ":" .. reason
    if previous and now - previous.ms >= 0 and now - previous.ms < 1500 then return end
    lastInputReport[player] = {key = key, ms = now}
    Diagnostics.emit("barrier-vault-input", {id = plan.id, reason = reason, direction = tostring(plan.direction),
        state = tostring(player:getCurrentState()), x = player:getX(), y = player:getY(),
        distance = distance, reach = reach, running = player:isRunning(), sprinting = player:isSprinting()}, nil, nil, "traps")
end

---@param player IsoPlayer Local player
---@param automatic boolean Running approach rather than Interact
---@param heldMs number Native context hold duration
---@return nil
function Vault.tryInput(player, automatic, heldMs)
    if active[player] or not F.barrierEnabled() or player:isDead() or player:getVehicle()
        or player:isIgnoreAutoVault() or player:isGrappling() then return end
    local state = player:getCurrentState()
    if automatic and (not (player:isPlayerMoving() or player:pressedMovement(false))
        or not (player:isRunning() or player:isSprinting())) then return end
    local facing = player:getDir()
    local directions = {IsoDirections.N, IsoDirections.E, IsoDirections.S, IsoDirections.W}
    local facingGroups = {
        {IsoDirections.N, IsoDirections.NE, IsoDirections.NW},
        {IsoDirections.E, IsoDirections.NE, IsoDirections.SE},
        {IsoDirections.S, IsoDirections.SE, IsoDirections.SW},
        {IsoDirections.W, IsoDirections.NW, IsoDirections.SW},
    }
    for i = 1, #directions do
        local group = facingGroups[i]
        if facing == group[1] or facing == group[2] or facing == group[3] then
            local plan, refusal = Vault.forDirection(player, directions[i])
            if refusal then
                reportInput(player, refusal, refusal.reason, -1, player:getFeelersize())
            end
            if plan then
                local safe = player:isSafeToClimbOver(plan.direction)
                local near = true
                local distance, reach = 0, player:getFeelersize() + 0.02
                if automatic then
                    local north = i == 1 or i == 3
                    local position, edge = player:getX(), plan.object:getSquare():getX()
                    if north then
                        position, edge = player:getY(), plan.object:getSquare():getY()
                    end
                    distance = math.abs(position - edge)
                    near = distance <= reach
                end
                local ready = state == IdleState.instance() or state == PlayerMovementState.instance()
                if near and ready and (safe or (not automatic and heldMs >= 500)) then
                    Vault.begin(player, plan, automatic and "native-movement" or "native-context")
                    player:climbOverFence(plan.direction)
                    return
                elseif near then
                    reportInput(player, plan, ready and "unsafe-landing" or "native-state", distance, reach)
                end
            end
        end
    end
end

---@param player IsoPlayer Local player
---@return nil
function Vault.autoVault(player)
    Vault.tryInput(player, true, 0)
end

---@param player IsoPlayer Native context event player
---@param heldMs number Native Interact hold duration
---@return nil
function Vault.onContext(player, heldMs)
    Vault.tryInput(player, false, heldMs)
end

Events.OnContextKey.Add(Vault.onContext)
Events.OnPlayerUpdate.Add(Vault.update)
return Vault
