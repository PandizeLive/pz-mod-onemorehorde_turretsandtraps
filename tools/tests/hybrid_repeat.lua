local H = require("OMHTT/HybridBuild")
local saved = {getCell = getCell, cursor = ISBuildIsoEntity, building = ISBuildingObject,
    handcraft = HandcraftLogic, info = SpriteConfigManager, menu = ISInventoryPaneContextMenu,
    item = H.item, place = H.place, recipe = H.recipe, start = H.start}
local drag, queued, nextItem, callback, cancellation = nil, nil, nil, nil, nil
local crafts, affordable, reads = 0, true, 0
local square = {}
getCell = function() return {getDrag = function() return drag end, setDrag = function(_, value) drag = value end,
    getGridSquare = function() return square end} end
local player = {isDead = function() return false end, getPlayerNum = function() return 0 end,
    getCurrentSquare = function(self) return self.square end}
local panel, definition = {player = player}, H.definitions[1]
local function cursor(item)
    return {nSprite = 1, item = item, objectInfo = {getScript = function() return {getTimedActionOnIsValid = function() return "native-check" end} end},
        onActionComplete = function() end, onTimedActionStart = function() end,
        getSprite = function(self) self.directionResolved = true end,
        isValid = function(self, target) return target ~= nil and not self.blockBuild end}
end
H.recipe = function() return {} end
H.item = function() reads = reads + 1; return nextItem end
H.place = function(_, _, item) drag = cursor(item); return drag end
ISBuildingObject = {tryBuild = function(self)
    queued = {perform = function() nextItem = nil; self:onActionComplete() end}
    self:onTimedActionStart(queued)
    return queued
end}
ISBuildIsoEntity = {new = function(_, _, _, facing)
    local value = cursor(); value.nSprite = facing; return value
end}
ISInventoryPaneContextMenu = {getContainers = function() return ArrayList.new() end}
SpriteConfigManager = {GetObjectInfo = function() return {} end}
HandcraftLogic = {new = function() return {setContainers = function() end, setRecipe = function() end,
    canPerformCurrentRecipe = function() return affordable end} end}
H.start = function(_, _, ready, stopped)
    crafts = crafts + 1; callback, cancellation = ready, stopped; return true
end
local first, second = {}, {}
local original = H.bind(panel, definition, H.place(player, definition, first), 4)
check(not original.dragNilAfterPlace and original.nSprite == 4, "Building keeps a cursor and its rotation")
original:tryBuild(1, 2, 0)
local firstAction = queued
original:tryBuild(1, 2, 0)
check(queued == firstAction and original.blockBuild and panel.omhttPlacement == queued and queued.onIsValid == "native-check", "Pending placement blocks duplicate clicks and keeps native validation")
check(not saved.start(panel, definition), "Building button cannot reuse the item reserved by a pending placement")
queued.perform = (function(perform)
    return function(self) nextItem = second; perform(self) end
end)(queued.perform)
-- Supply the next carried item after native consumption, as the inventory adapter would.
local oldItem = H.item
H.item = function() return second end
firstAction:perform()
check(drag ~= original and drag.item == second and drag.nSprite == 4 and crafts == 0, "Completion rebinds the next exact carried item without crafting")
local after = drag
firstAction:perform()
check(drag == after, "Repeated completion cannot open another placement session")
H.item, nextItem = oldItem, nil
after:tryBuild(2, 2, 0); queued:perform()
local preview = drag
check(preview ~= after and not preview.item and crafts == 0 and preview.nSprite == 4,
    "Exhausted inventory leaves a rotated preview without automatically crafting stock")
local beforeReads = reads
for i = 1, 20 do check(preview:haveMaterial(square), "Available recipe permits the next preview") end
check(reads == beforeReads + 1, "Unchanged previews do not rescan inventory every frame")
player.square = {}
preview:haveMaterial(square)
check(reads == beforeReads + 2, "Changing player square refreshes nearby recipe materials")
preview:tryBuild(3, 2, 0); preview:tryBuild(3, 2, 0)
check(crafts == 1 and preview.blockBuild, "Next world click queues one original recipe")
cancellation()
check(not preview.blockBuild, "Interrupted craft releases the preview")
preview:tryBuild(3, 2, 0)
callback(second)
check(drag.item == second and drag.nSprite == 4 and drag.blockBuild and drag.directionResolved, "Real crafted output resolves native heading before placement at the chosen tile")
local pending = queued
drag = nil
pending:perform()
check(drag == nil, "Right-click cancellation prevents completion from reopening the cursor")
H.repeatPlacement(panel, definition, 2)
preview = drag
preview:tryBuild(4, 2, 0)
drag = nil
callback(first)
check(drag == nil, "Cancelling during crafting keeps the output without automatic placement")
H.repeatPlacement(panel, definition, 2)
preview = drag
panel.omhttClosed = true
preview:tryBuild(4, 2, 0)
check(not H.active(panel, preview), "Closed Building cannot continue the placement session")
getCell, ISBuildIsoEntity, ISBuildingObject = saved.getCell, saved.cursor, saved.building
HandcraftLogic, SpriteConfigManager, ISInventoryPaneContextMenu = saved.handcraft, saved.info, saved.menu
H.item, H.place, H.recipe, H.start = saved.item, saved.place, saved.recipe, saved.start
