local A = require("OMHTT/BarrierApproach")
local P = require("OMHTT/BarrierFootprint")
local F = require("OMHTT/Foundation")
local object = testSquares[F.key(702, 700, 0)].objects[1]
local record = P.exact(object)
testPlayer.x, testPlayer.y, testPlayer.state = 705.5, 700.5, "idle"
BehaviorResult = {Failed = "failed", Succeeded = "succeeded", Working = "working"}
local path = {result = BehaviorResult.Working}
function path:cancel() self.cancelled = true end
function path:pathToLocation(x, y, z) self.x, self.y, self.z = x, y, z end
function path:update() return self.result end
function testPlayer:getPathFindBehavior2() return path end
function testPlayer:setPath2(value) self.path = value end
function testPlayer:pressedMovement() return self.pressed == true end
function testPlayer:pressedCancelAction() return false end
function getGameSpeed() return 1 end
local queued = nil
ISTimedActionQueue.add = function(action) queued = action end
local function actionFor(route)
    local action = OMHTTBarrierApproachAction:new(testPlayer, object, record.id, "Repair", route)
    action.action = {
        setPathfinding = function() end,
        setAllowedWhileDraggingCorpses = function() end,
        forceStop = function() action.stopped = true end,
        forceComplete = function() action.completed = true end,
    }
    return action
end
local route = A.route(testPlayer, record)
check(route and #route == 3, "service uses short cardinal approach")
local action = actionFor(route)
action:start()
for i = 1, #route do
    testPlayer.x, testPlayer.y = route[i].x + 0.5, route[i].y + 0.5
    path.result = BehaviorResult.Succeeded
    action:update()
    check(not action.stopped, "valid waypoint does not stop the approach")
end
check(action.completed and not queued, "service begins only after reaching a valid side")
action:perform()
check(queued and queued.operation == "Repair" and queued.id == record.id, "arrival queues exact ten-second service")
testPlayer.x, testPlayer.y = 705.5, 700.5
local stalled = actionFor(A.route(testPlayer, record))
stalled:start()
path.result = BehaviorResult.Working
testMillis = testMillis + 3100
stalled:update()
check(stalled.stopped and stalled.failure == "blocked-or-stalled", "stationary walking times out")
local cancelled = actionFor(A.route(testPlayer, record))
cancelled:start()
testPlayer.pressed = true
cancelled:update()
check(cancelled.stopped and not cancelled.completed, "manual movement cancels approach without a service award")
testPlayer.pressed = false

-- Native same-square collision can be true while walking toward the tile center.
testPlayer.x, testPlayer.y = 705.5, 700.5
local arrivalRoute = A.route(testPlayer, record)
local arrival = actionFor(arrivalRoute)
arrival:start()
local waypoint = arrivalRoute[1]
local originalCollision = waypoint.testCollideAdjacent
function waypoint:testCollideAdjacent(player, dx, dy, dz)
    if dx == 0 and dy == 0 then return true end
    return originalCollision(self, player, dx, dy, dz)
end
testPlayer.x, testPlayer.y = waypoint.x + 0.99, waypoint.y + 0.5
path.result = BehaviorResult.Working
arrival:update()
check(not arrival.stopped and not arrival.completed, "entering waypoint tile must not test collision against itself or finish early")
path.result = BehaviorResult.Succeeded
arrival:update()
check(not arrival.stopped and arrival.step == 2, "native path success advances waypoint after tile entry")
waypoint.testCollideAdjacent = originalCollision
