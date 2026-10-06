local F = require("OMHTT/Foundation")
local T = require("OMHTT/Turret")
local D = require("OMHTT/Diagnostics")
local saved = SandboxVars.OMHTurretsTraps
SandboxVars.OMHTurretsTraps = {Enabled = false, SpikeBarrier = true, TurretsEnabled = true,
    DiagnosticLogging = true, TurretDiagnosticLogging = false}
check(T.enabled() and not F.barrierEnabled(), "Trap master cannot disable independent turret operation")
check(not D.enabled("turrets"), "Turret audit respects its own diagnostic setting")
SandboxVars.OMHTurretsTraps.Enabled = true
SandboxVars.OMHTurretsTraps.TurretsEnabled = false
check(F.barrierEnabled() and not T.enabled(), "Turret master cannot disable independent traps")
check(D.enabled("traps") and not D.enabled("turrets"), "Trap diagnostics cannot start turret audit")
SandboxVars.OMHTurretsTraps = {TurretsEnabled = true, TurretDiagnosticLogging = true}
check(T.enabled() and D.enabled("turrets"), "Turret-only settings need no trap defaults")
check(not D.enabled("traps"), "Absent trap entry has no active diagnostic toggle")
SandboxVars.OMHTurretsTraps = saved
