function testPlayer:faceThisObject() end
function testPlayer:shouldBeTurning() return false end
testInventory = {room = true, items = {}}
function testInventory:hasRoomFor() return self.room end
function testInventory:AddItem(item) self.items[#self.items + 1] = item; return item end
function testInventory:getItems() return {size = function() return #self.items end, get = function(_, i) return self.items[i + 1] end} end
function testInventory:Remove(item) for i = #self.items, 1, -1 do if self.items[i] == item then table.remove(self.items, i) end end end
function testInventory:getFirstTagEvalRecurse(tag, predicate)
    local tool = self.tool
    if tool and tool.tag == tag and predicate(tool) then return tool end
end
function testPlayer:removeFromHands() end
function sendRemoveItemFromContainer() end
function testPlayer:getInventory() return testInventory end
local nextItemId=600000
function instanceItem(kind)
    nextItemId=nextItemId+1
    return {kind=kind,condition=100,id=nextItemId,data={},getID=function(self) return self.id end,getModData=function(self) return self.data end,
        getFullType=function(self) return self.kind end, isFavorite=function() return false end,
        getCondition=function(self) return self.condition end, getConditionMax=function() return 100 end,
        setCondition=function(self,value) self.condition=value end}
end
function getGameTime() return {getMinutesPerDay = function() return 60 end, getWorldAgeHours = function() return testTime end, getMultiplier = function() return (0.1) * 48 end, getMultiplierFromTimeDelta = function() return 48 end} end

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
ItemTag = {HAMMER = "hammer", PLIERS = "pliers", WRENCH = "wrench", SCREWDRIVER = "screwdriver"}
function testPlayer:getPerkLevel() return self.woodwork or 0 end

-- Supply the real policy's material/tool to isolated service fixtures.
function testRepairSupply(player, kind)
    local profile = require("OMHTT/ControlRepair").profiles[kind]
    local inventory = player:getInventory()
    if not inventory.getItems then inventory.getItems = testInventory.getItems end
    if not inventory.Remove then inventory.Remove = function(self, item)
        for i = #self.items, 1, -1 do if self.items[i] == item then table.remove(self.items, i) end end
    end end
    local items = inventory:getItems()
    for i = 0, items:size() - 1 do
        local entry = items:get(i)
        if not entry.isFavorite then entry.isFavorite = function() return false end end
        if not entry.getFullType then entry.getFullType = function(self) return self.kind end end
    end
    local oldTool = inventory.getFirstTagEvalRecurse
    inventory.getFirstTagEvalRecurse = function(self, tag, predicate)
        if tag == ItemTag[profile.tag] then
            local tool = {getCondition = function() return 10 end}
            if predicate(tool) then return tool end
        end
        if oldTool then return oldTool(self, tag, predicate) end
    end
    if not player.removeFromHands then player.removeFromHands = function() end end
    if profile.material then
        local material = {getFullType = function() return profile.material end, isFavorite = function() return false end,
            getContainer = function() return inventory end, getCondition = function() return 100 end}
        inventory:AddItem(material)
    end
end
