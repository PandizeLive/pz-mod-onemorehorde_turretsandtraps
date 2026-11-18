testTackRequire = require
testTackStart = #Events.OnGameStart.handlers
function require(name)
    if name == "OMHTT/TurretProc" or name == "OMHTT/Damage" then
        error("Client initialization required unavailable server file: " .. name)
    end
    local module = testTackRequire(name)
    check(module ~= nil, "Client startup dependency exists: " .. name)
    return module
end
