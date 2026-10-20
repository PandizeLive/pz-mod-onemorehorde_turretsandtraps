function testPlayer:faceThisObject() end
function testPlayer:shouldBeTurning() return false end
testInventory = {room = true, items = {}}
function testInventory:hasRoomFor() return self.room end
function testInventory:AddItem(item) self.items[#self.items + 1] = item; return item end
function testPlayer:getInventory() return testInventory end
local nextItemId=600000
function instanceItem(kind)
    nextItemId=nextItemId+1
    return {kind=kind,condition=100,id=nextItemId,data={},getID=function(self) return self.id end,getModData=function(self) return self.data end}
end
function getGameTime() return {getMinutesPerDay = function() return 60 end, getMultiplier = function() return (0.1) * 48 end, getMultiplierFromTimeDelta = function() return 48 end} end

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

Perks = {Woodwork = "Woodwork"}
ItemTag = {HAMMER = "hammer"}
function testPlayer:getPerkLevel() return self.woodwork or 0 end
