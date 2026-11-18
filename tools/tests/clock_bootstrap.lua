testActiveClockNow = require("OMHTT/TurretClock").now
require("OMHTT/TurretClock").now = function() return testMillis end

require("OMHTT/ControlClock").now=function() return getTimestampMs() end
