ISBuildingObject = {derive = function(self, name) return {} end}
function getWorld() return {getCell = function() return getCell() end, getFreeEmitter = function() return {playSound = function() return 1 end, setPitch = function() end} end} end
function showDebugInfoInChat(text) end
function testPlayer:isBuildCheat() return testBuildCheat == true end
function testPlayer:getPlayerCraftHistory()
    return {addCraftHistoryCraftedEvent = function() end}
end
