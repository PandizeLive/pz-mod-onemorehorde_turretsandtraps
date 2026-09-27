if isClient() or isServer() then return end
require("TimedActions/ISClimbOverFence")
local F = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local Vault = {}
local active = {}
local sequence = 0

---@param player IsoPlayer Acting player
---@param object IsoThumpable Selected part
---@param id string Expected identity
---@return table? plan Validated crossing
---@return string? reason Rejection translation key
function Vault.plan(player, object, id)
    if isClient() or isServer() or not F.barrierEnabled() or player:isDead() then return nil, "UI_OMHTT_Unavailable" end
    local Footprint = require("OMHTT/BarrierFootprint")
    local record = Footprint.exact(object)
    if not record or record.id ~= id or not Footprint.parts(record) then return nil, "UI_OMHTT_Unavailable" end
    if record.collisionModel ~= "edge-v1" then return nil, "ContextMenu_OMHTT_VaultRedeploy" end
    if active[player] or player:getCurrentState() == ClimbOverFenceState.instance() then return nil, "ContextMenu_OMHTT_VaultBusy" end
    local from = player:getCurrentSquare()
    if not from or from:getZ() ~= record.z then return nil, "ContextMenu_OMHTT_VaultApproach" end
    local parts = Footprint.parts(record)
    local north = record.facing == 4 or record.facing == 12
    for i = 1, #parts do
        local part = parts[i]
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
            if positive == (record.facing == 0 or record.facing == 12) then
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
    local roll, injured, leg = -1, false, "none"
    if result == "crossed" and plan.side == "front" then
        roll = ZombRand(5)
        if roll == 0 and not player:isGodMod() then
            local bodyPart = BodyPartType.LowerLeg_L
            leg = "left"
            if ZombRand(2) == 1 then
                bodyPart, leg = BodyPartType.LowerLeg_R, "right"
            end
            player:getBodyDamage():getBodyPart(bodyPart):setScratched(true, true)
            injured = true
        end
    end
    Diagnostics.emit("barrier-vault-result", {crossing = plan.sequence, id = plan.id, side = plan.side,
        result = result, roll = roll, injured = injured, leg = leg, godMode = player:isGodMod(),
        x = player:getX(), y = player:getY(), z = player:getZ(), outcome = plan.outcome,
        elapsedMs = getTimestampMs() - plan.startedAt})
end

---@param player IsoPlayer Local player update
---@return nil
function Vault.update(player)
    local plan = active[player]
    if not plan then return end
    local Footprint = require("OMHTT/BarrierFootprint")
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
            Diagnostics.emit("barrier-vault-enter", {crossing = plan.sequence, id = plan.id, side = plan.side})
        end
        if player:getVariableBoolean("ClimbFenceStarted") then
            plan.animationStarted = true
        end
        plan.outcome = player:getVariableString("ClimbFenceOutcome")
    elseif plan.entered then
        local landed = math.floor(player:getX()) == plan.toX and math.floor(player:getY()) == plan.toY
            and math.floor(player:getZ()) == plan.z
        local recovered = state == IdleState.instance() or state == PlayerMovementState.instance()
        if landed and recovered and plan.animationStarted and plan.outcome == "success" then
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
        sequence = sequence + 1
        plan.sequence, plan.startedAt = sequence, getTimestampMs()
        active[self.character] = plan
        self.direction = plan.direction
        Diagnostics.emit("barrier-vault-start", {crossing = sequence, id = plan.id, side = plan.side,
            fromX = plan.fromX, fromY = plan.fromY, toX = plan.toX, toY = plan.toY, z = plan.z})
        ISClimbOverFence.perform(self)
    else
        Diagnostics.emit("barrier-vault-refused", {id = self.omhttId, reason = reason or "approach-changed"})
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
        Diagnostics.emit("barrier-vault-refused", {id = id, reason = reason})
        return
    end
    ISTimedActionQueue.add(OMHTTBarrierVaultAction:new(player, plan.object, plan))
end

Events.OnPlayerUpdate.Add(Vault.update)
return Vault
