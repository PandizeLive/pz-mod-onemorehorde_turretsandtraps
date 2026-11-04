require = testTackRequire
check(#Events.OnGameStart.handlers == testTackStart + 2, "Both Tack clients defer server binding until game start")
for i = testTackStart + 1, #Events.OnGameStart.handlers do Events.OnGameStart.handlers[i]() end
check(require("OMHTT/ContactPlayer").tackContact == require("OMHTT/TurretProc").contact,
    "Tack player contact binds the real initialized server module")
local oldPlayer = getSpecificPlayer
getSpecificPlayer = function() return nil end
local workers = require("OMHTT/TurretScheduler").workers
local ran = false
for i = 1, #workers do
    if workers[i].name == "TurretTackMarkers.update" then workers[i].run(); ran = true end
end
check(ran, "Real Tack marker callback runs after ordered startup without nil fieldOrder")
getSpecificPlayer = oldPlayer
