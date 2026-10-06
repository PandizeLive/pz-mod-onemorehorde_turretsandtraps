if isClient() or isServer() then return end
require("TimedActions/WalkToTimedAction")
require("OMHTT/BarrierServiceAction")
local Approach = require("OMHTT/BarrierApproach")
local Diagnostics = require("OMHTT/Diagnostics")
OMHTTBarrierApproachAction = ISWalkToTimedAction:derive("OMHTTBarrierApproachAction")

---@return nil
function OMHTTBarrierApproachAction:start()
    self.startedAt, self.progressAt = getTimestampMs(), getTimestampMs()
    self.lastX, self.lastY = self.character:getX(), self.character:getY()
    Diagnostics.emit("barrier-approach-start", {id = self.id, x = self.lastX, y = self.lastY, steps = #self.route})
    ISWalkToTimedAction.start(self)
end

---@return nil
function OMHTTBarrierApproachAction:update()
    if self.character:pressedMovement(false) or self.character:pressedCancelAction() then
        self:forceStop()
        return
    end
    local now = getTimestampMs()
    local Footprint = require("OMHTT/BarrierFootprint")
    local record = Footprint.exact(self.object)
    local from = self.character:getCurrentSquare()
    if not from then
        self.failure = "unloaded-position"
        self:forceStop()
        return
    end
    local dx, dy = self.location:getX() - from:getX(), self.location:getY() - from:getY()
    if not record or record.id ~= self.id or now - self.startedAt > 20000 or now - self.progressAt > 3000
        or math.abs(dx) + math.abs(dy) > 1
        or ((dx ~= 0 or dy ~= 0) and from:testCollideAdjacent(self.character, dx, dy, 0)) then
        self.failure = "blocked-or-stalled"
        self:forceStop()
        return
    end
    local movedX, movedY = self.character:getX() - self.lastX, self.character:getY() - self.lastY
    if movedX * movedX + movedY * movedY >= 0.01 then
        self.lastX, self.lastY, self.progressAt = self.character:getX(), self.character:getY(), now
    end
    self.result = self.character:getPathFindBehavior2():update()
    if self.result == BehaviorResult.Failed then
        self.failure = "path-failed"
        self:forceStop()
    elseif self.result == BehaviorResult.Succeeded then
        Diagnostics.emit("barrier-approach-step", {id = self.id, step = self.step,
            x = self.character:getX(), y = self.character:getY()})
        if Approach.ready(self.character, record) then
            self:forceComplete()
        else
            self.step = self.step + 1
            if not self.route[self.step] then
                self.failure = "destination-changed"
                self:forceStop()
                return
            end
            self.location = self.route[self.step]
            self.progressAt = now
            self.character:getPathFindBehavior2():pathToLocation(self.location:getX(), self.location:getY(), self.location:getZ())
        end
    end
end

---@return nil
function OMHTTBarrierApproachAction:perform()
    local Footprint = require("OMHTT/BarrierFootprint")
    local record = Footprint.exact(self.object)
    ISWalkToTimedAction.perform(self)
    if record and Approach.ready(self.character, record) then
        ISTimedActionQueue.add(OMHTTBarrierServiceAction:new(self.character, self.object, self.id, self.operation))
    end
end

---@return nil
function OMHTTBarrierApproachAction:stop()
    Diagnostics.emit("barrier-approach-stop", {id = self.id, reason = self.failure or "cancelled",
        x = self.character:getX(), y = self.character:getY(), step = self.step,
        targetX = self.location:getX(), targetY = self.location:getY(),
        elapsed = self.startedAt and getTimestampMs() - self.startedAt or 0,
        stalled = self.progressAt and getTimestampMs() - self.progressAt or 0})
    if self.failure then
        self.character:setHaloNote(getText("UI_OMHTT_ServiceBlocked"), 255, 170, 80, 180)
    end
    ISWalkToTimedAction.stop(self)
end

---@param character IsoPlayer Acting player
---@param object IsoThumpable Selected part
---@param id string Exact barrier identity
---@param operation string Pickup or Repair
---@param route table Collision-checked cardinal waypoints
---@return OMHTTBarrierApproachAction action
function OMHTTBarrierApproachAction:new(character, object, id, operation, route)
    local action = ISWalkToTimedAction.new(self, character, route[1])
    action.object, action.id, action.operation, action.route, action.step = object, id, operation, route, 1
    return action
end

return OMHTTBarrierApproachAction
