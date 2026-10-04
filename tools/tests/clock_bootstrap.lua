testActiveClockNow = require("OMHTT/TurretClock").now
require("OMHTT/TurretClock").now = function() return testMillis end
