local oldSpecific, oldCell = getSpecificPlayer, getCell
local visible, floor = true, 0
function getSpecificPlayer() return {getZ = function() return floor end} end
function getCell() return {getGridSquare = function() return {isCanSee = function() return visible end} end} end
testMillis = 1000
testDraws = 0
function getTimestampMs() return testMillis end
IsoUtils = {XToIso = function() return 400 end, YToIso = function() return 300 end, XToScreen = function(x, y, z, ignored) return x end, YToScreen = function(x, y, z, ignored) return y end}
IsoCamera = {getOffX = function() return 0 end, getOffY = function() return 0 end}
UIFont = {Small = "small"}
local lastDraw
function getTextManager() return {DrawStringCentre = function(self,font,x,y,text,r,g,b,a) testDraws = testDraws + 1; lastDraw={y=y,r=r,g=g,b=b} end} end
local F = require("OMHTT/Foundation")
local impact = {id = "test-effect", shot = 1, x = 100, y = 100, z = 0}
triggerEvent("OnServerCommand", F.MODULE, "Impact", impact)
triggerEvent("OnServerCommand", F.MODULE, "Impact", impact)
triggerEvent("OnPostRender")
check(testDraws == 6, "duplicate impact renders one six-dot placeholder pop")
testMillis = 1700
testDraws = 0
triggerEvent("OnPostRender")
check(testDraws == 0, "expired effect removed")
for i = 1, 12 do
    triggerEvent("OnServerCommand", F.MODULE, "Impact", {id = "effect", shot = i, x = 100, y = 100, z = 0})
end
triggerEvent("OnPostRender")
check(testDraws == 48, "effect list capped at eight impacts")
triggerEvent("OnGameStart")
testDraws = 0
triggerEvent("OnPostRender")
check(testDraws == 0, "session reset discards effects")

local flight = {id = "flight", shot = 1, x = 100, y = 100, z = 0, fromX = 98.5, fromY = 100.5}
triggerEvent("OnServerCommand", F.MODULE, "Impact", flight)
triggerEvent("OnPostRender")
check(testDraws == 1 and lastDraw.r==0.55 and lastDraw.g==0.32 and lastDraw.b==0.13, "Shot marker uses brown")
testMillis = testMillis + 120
testDraws = 0
triggerEvent("OnPostRender")
check(testDraws == 6, "Travel marker becomes impact pop")
visible = false
testDraws = 0
triggerEvent("OnPostRender")
check(testDraws == 0, "Hidden impact does not reveal zombies")
getSpecificPlayer, getCell = oldSpecific, oldCell
