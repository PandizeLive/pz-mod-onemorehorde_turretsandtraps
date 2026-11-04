local T = require("OMHTT/Turret")
local strokes = {}
local oldRender = renderIsoLine
function renderIsoLine(x, y, z, tx, ty, tz) strokes[#strokes + 1] = {x, y, z, tx, ty, tz} end
local handlers = Events.OnGameStart.handlers
handlers[#handlers]()
local selected = nil
local input = {}
local data = {getRecipe = function() return {getInputs = function() return {size = function() return 1 end, get = function() return input end} end} end,
    getFirstManualInputFor = function(_, value) check(value == input, "Preview reads exact recipe input"); return selected end}
local cursor = {objectInfo = {getName = function() return "OMHTTDeployTurret" end},
    buildPanelLogic = {getRecipeData = function() return data end}, face = "e"}
function cursor:getFace() return {getFaceName = function() return self.face end} end
ISBuildIsoEntity.render(cursor, 20, 30, 2, nil)
check(testPreviewNative and #strokes == 69, "Placement keeps native preview and adds default cone")
check(strokes[67][1] == 20.5 and strokes[67][2] == 30.5 and strokes[67][4] == 26.5, "East placement arrow matches base direction")
for i = 1, #strokes do check(strokes[i][3] == 2 and strokes[i][6] == 2, "Preview stays on selected floor") end
cursor.face = "n"; strokes = {}
ISBuildIsoEntity.render(cursor, 20, 30, 2, nil)
check(strokes[67][4] == 20.5 and strokes[67][5] == 24.5, "Rotating placement rotates cone before building")
local omni = {getID = function() return 111 end, getFullType = function() return "Base.OMHTTModule360" end, getActualWeight = function() return 0.3 end,
    getDisplayName = function() return "360" end, getCondition = function() return 10 end}
selected = {getFullType = function() return T.BASE end, getInventory = function() return {getContainingItem = function() return nil end, getParent = function() return nil end, getItems = function()
    return {size = function() return 1 end, get = function() return omni end} end} end}
strokes = {}; ISBuildIsoEntity.render(cursor, 20, 30, 2, nil)
check(#strokes == 67, "Packed 360 module expands placement preview to circle")
ISBuildIsoEntity, renderIsoLine = testOldBuildEntity, oldRender
