function testPlayer:faceThisObject() end
function testPlayer:shouldBeTurning() return false end
testInventory = {room = true, items = {}}
function testInventory:hasRoomFor() return self.room end
function testInventory:AddItem(item) self.items[#self.items + 1] = item; return item end
function testPlayer:getInventory() return testInventory end
function instanceItem(kind) return {kind = kind, condition = 100} end
function getGameTime() return {getRealworldSecondsSinceLastUpdate = function() return 0.1 end} end

function testPlayer:setIsFarming() end
ISTimedActionQueue = {getTimedActionQueue = function() return {resetQueue = function() end} end}
function testServiceAction(player, object, id, operation)
    local action = OMHTTBarrierServiceAction:new(player, object, id, operation)
    action.action = {
        setActionAnim = function() end, setAnimVariable = function() end,
        setOverrideHandModelsObject = function() end,
        setJobDelta = function(self, value) action.delta = value end,
        forceComplete = function() action.forced = true end,
    }
    return action
end

ISWorldObjectContextMenu = {addToolTip = function() return {} end}
