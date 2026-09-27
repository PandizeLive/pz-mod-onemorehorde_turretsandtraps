testOriginalRequire = require
function require(name)
    if name == "OMHTT/BarrierService" or name == "OMHTT/BarrierFootprint" then
        error("server module required before it is registered: " .. name)
    end
    return testOriginalRequire(name)
end
