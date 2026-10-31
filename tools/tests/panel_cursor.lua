local P = require("OMHTT/BarrierPlacement")
local B = require("OMHTT/BarbSections")
local C = require("OMHTT/BarbContact")
local nativeCursor = ISBuildIsoEntity
local oldInfo, oldSprite, oldLogic, oldType, oldCell = SpriteConfigManager, getSprite, BaseCraftingLogic, IsoObjectType, getCell
local oldInventory = testPlayer.getInventory
local inventory = {}
function inventory:isInCharacterInventory(player) return player == testPlayer end
function inventory:getFirstTagEvalRecurse() return {} end
function testPlayer:getInventory() return inventory end
local selectedInput, heading, consumed = {}, nil, 0
local recipe = {getName = function() return "OMHTTBarbs" end,
    getInputs = function() return {get = function() return selectedInput end} end}
local info = {getName = function() return "OMHTTBarbs" end, getRecipe = function() return {getCraftRecipe = function() return recipe end} end,
    getScript = function() return {getOnIsValid = function() return "panel-valid" end} end}
SpriteConfigManager = {GetObjectInfo = function() return info end}
local props = {has = function() return false end}
getSprite = function() return {getProperties = function() return props end, getType = function() return "marker" end} end
IsoObjectType = {wall = "wall", doorW = "doorW", doorN = "doorN"}
BaseCraftingLogic = {callLuaBool = function(_, params) return B.onIsValid(params) end}
getCell = function() local cell = oldCell(); cell.setDrag = function() end; return cell end
ISBuildIsoEntity = {new = function(_, player)
    local offered = {}
    local logic = {}
    function logic:setManualSelectInputs() end
    function logic:clearManualInputs() offered = {} end
    function logic:offerInputItem(item) offered[#offered + 1] = item end
    function logic:getRecipeData() return {getFirstManualInputFor = function() return offered[1] end} end
    function logic:performCurrentRecipe() consumed = consumed + 1; return true end
    function logic:getRecipeDataInProgress() return {luaCallOnCreate = function() end,
        getRecipe = function() return recipe end, processDestroyAndUsedItems = function() offered[1].container = nil end} end
    local face = {getWidth = function() return 1 end, getHeight = function() return 1 end,
        getzLayers = function() return 1 end, getFaceName = function() return heading end,
        getTileInfo = function() return {getSpriteName = function() return "omhtt_barrier_01_52" end} end}
    local cursor = {character = player, craftRecipe = recipe, buildPanelLogic = logic, objectInfo = info,
        previousStages = ArrayList.new(), getFace = function() return face end, getOpenFace = function() return nil end,
        haveMaterial = function() return true end, updateModData = function() end, render = function() end,
        isValid = nativeCursor.isValid, isValidPerSquare = nativeCursor.isValidPerSquare, create = nativeCursor.create}
    function cursor:setInfo(square, north, sprite)
        local original = IsoThumpable.new(getCell(), square, sprite, north)
        square:AddSpecialObject(original)
        self.placed = B.onCreate({thumpable = original, facing = heading}).object
    end
    return cursor
end}
testBuildCheat = false
local facings = {"e", "n", "w", "s"}
for i = 1, #facings do
    heading = facings[i]
    local floor = makeSquare(900 + i * 4, 900, 0)
    function floor:getCell() return getCell() end
    function floor:getProperties() return props end
    function floor:isSolid() return false end
    function floor:isSolidTrans() return false end
    local x, y, north = C.edge(floor.x, floor.y, heading)
    local backing = getCell():getGridSquare(x, y, 0) or makeSquare(x, y, 0)
    function backing:getCell() return getCell() end
    local item = {container = inventory, getFullType = function() return "Base.OMHTTTrapBarbedPanel" end,
        getCondition = function() return 100 end, getContainer = function(self) return self.container end}
    local cursor = P.place(item, testPlayer)
    local before = consumed
    cursor:create(floor.x, floor.y, 0, north, "unused")
    check(consumed == before and item.container == inventory, "Native cursor rejects missing backing before consuming panel")
    local host = IsoThumpable.new(getCell(), backing, "fixture-window", north)
    host.kind, host.health = "IsoWindow", 50
    function host:IsOpen() return false end
    backing:AddSpecialObject(host)
    check(cursor:isValid(floor), "Native per-square validation accepts backed panel in all four directions")
    cursor:create(floor.x, floor.y, 0, north, "unused")
    check(consumed == before + 1 and item.container == nil and B.record(cursor.placed), "Native cursor completes one panel attachment using selected item")
    cursor:create(floor.x, floor.y, 0, north, "unused")
    check(consumed == before + 1, "Replayed cursor cannot charge or attach twice")
end
ISBuildIsoEntity, SpriteConfigManager, getSprite, BaseCraftingLogic, IsoObjectType, getCell = nativeCursor, oldInfo, oldSprite, oldLogic, oldType, oldCell
testPlayer.getInventory = oldInventory
