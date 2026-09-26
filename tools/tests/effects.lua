testMillis = 1000
testDraws = 0
function getTimestampMs() return testMillis end
IsoUtils = {XToScreen = function(x, y, z, ignored) return x end, YToScreen = function(x, y, z, ignored) return y end}
IsoCamera = {getOffX = function() return 0 end, getOffY = function() return 0 end}
UIFont = {Small = "small"}
function getTextManager() return {DrawStringCentre = function() testDraws = testDraws + 1 end} end
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
