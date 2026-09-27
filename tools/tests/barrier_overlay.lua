local F = require("OMHTT/Foundation")
local oldCore, oldUtils, oldCamera = getCore, IsoUtils, IsoCamera
local oldPlayers, oldPlayer = getNumActivePlayers, getSpecificPlayer
local oldLeft, oldTop = getPlayerScreenLeft, getPlayerScreenTop
local strokes = {}
ISUIElement = {new = function()
    return {instantiate = function() end, drawLine2 = function(self, x, y, tx, ty)
        strokes[#strokes + 1] = {x, y, tx, ty}
    end}
end}
testMode, testSquares = "sp", {}
testPlayer.x, testPlayer.y, testPlayer.z = 20.5, 30.5, 2
local square = makeSquare(20, 30, 2)
local object = IsoThumpable.new(getCell(), square, "omhtt_barrier_01_2", true)
object:getModData().OMHTT = {kind = "barrier", facing = 4}
square:AddSpecialObject(object)
function getNumActivePlayers() return 1 end
function getSpecificPlayer() return testPlayer end
function getPlayerScreenLeft() return 100 end
function getPlayerScreenTop() return 50 end
IsoUtils = {XToScreen = function(x, y) return (x - y) * 64 end,
    YToScreen = function(x, y, z) return (x + y) * 32 - z * 192 end}
IsoCamera = {getOffX = function() return -700 end, getOffY = function() return 1000 end}
local O = require("OMHTT/BarrierCollisionOverlay")
local ui = Events.OnPostUIDraw.handlers
check(ui[#ui] == O.render, "screen-space overlay uses UI phase")
for i = 1, #Events.OnPostRender.handlers do
    check(Events.OnPostRender.handlers[i] ~= O.render, "screen-space overlay never uses world projection")
end
SandboxVars.OMHTurretsTraps.ShowCollision = true
for _, zoom in pairs({0.5, 1, 2}) do
    function getCore()
        return {getZoom = function() return zoom end, getScreenWidth = function() return 1280 end,
            getScreenHeight = function() return 720 end}
    end
    testMillis = testMillis + 300
    strokes = {}
    O.update()
    O.render()
    check(#strokes == 8, "one native edge and direction arrow rendered")
    check(strokes[1][1] == 60 / zoom + 100 and strokes[1][2] == 216 / zoom + 50,
        "overlay projects floor, zoom and viewport origin exactly once")
    check(strokes[1][3] == 124 / zoom + 100 and strokes[1][4] == 248 / zoom + 50,
        "overlay endpoint matches native north edge")
end
SandboxVars.OMHTurretsTraps.ShowCollision = false
strokes = {}
O.update()
O.render()
check(#strokes == 0, "disabled collision overlay has no residual lines")
getCore, IsoUtils, IsoCamera = oldCore, oldUtils, oldCamera
getNumActivePlayers, getSpecificPlayer = oldPlayers, oldPlayer
getPlayerScreenLeft, getPlayerScreenTop = oldLeft, oldTop
