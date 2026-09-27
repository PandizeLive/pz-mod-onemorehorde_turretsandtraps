ISBaseTimedAction = {}
function ISBaseTimedAction:derive() return setmetatable({}, {__index = self}) end
function ISBaseTimedAction:new(character)
    self.__index = self
    return setmetatable({character = character, stopOnWalk = true, stopOnRun = true, stopOnAim = true}, self)
end
function ISBaseTimedAction:perform() end
function ISBaseTimedAction:stop() end
function ISBaseTimedAction:setActionAnim() end
function ISBaseTimedAction:setAnimVariable() end
function ISBaseTimedAction:setOverrideHandModels() end
function ISBaseTimedAction:setJobDelta(value) self.delta = value end
function ISBaseTimedAction:forceComplete() self.forced = true end
function testPlayer:faceThisObject() end
function testPlayer:shouldBeTurning() return false end
testInventory = {room = true, items = {}}
function testInventory:hasRoomFor() return self.room end
function testInventory:AddItem(item) self.items[#self.items + 1] = item; return item end
function testPlayer:getInventory() return testInventory end
function instanceItem(kind) return {kind = kind, condition = 100} end
function getGameTime() return {getRealworldSecondsSinceLastUpdate = function() return 0.1 end} end
