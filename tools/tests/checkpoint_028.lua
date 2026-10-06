local A = require("OMHTT/FirearmAudit")
local D = require("OMHTT/Diagnostics")
local savedManager, savedInspect, savedEmit = getScriptManager, A.inspect, D.emit
local savedSettings = SandboxVars.OMHTurretsTraps
local items, output, inspected = {}, {}, 0
for i = 1, 120 do items[i] = {isRanged = function() return false end} end
for i = 121, 123 do
    local name = "Fixture.Gun" .. i
    items[i] = {isRanged = function() return true end, getFullName = function() return name end}
end
getScriptManager = function() return {getAllItems = function() return {
    size = function() return #items end, get = function(self, index) return items[index + 1] end} end} end
A.inspect = function(name)
    inspected = inspected + 1
    if name == "Fixture.Gun122" then return {item = name, accepted = false, reason = "no-damage"} end
    return {item = name, accepted = true}
end
local rejectWrite = true
D.emit = function(event, fields)
    if rejectWrite then return false end
    output[#output + 1] = {event = event, fields = fields}
    return true
end
SandboxVars.OMHTurretsTraps = {TurretsEnabled = true, TurretDiagnosticLogging = false}
A.start(); check(not A.started, "Debug disabled does not scan or construct weapons")
SandboxVars.OMHTurretsTraps.TurretDiagnosticLogging = true
A.start(); A.tick()
check(A.pending and #output == 0 and inspected == 0, "Rate-limited audit retains pending entry")
rejectWrite = false
A.tick(); A.nextAt = 0; A.tick()
check(A.cursor == 50, "Registry scan capped at fifty scripts per tick")
for i = 1, 20 do A.nextAt = 0; A.tick() end
check(A.finished and inspected == 3 and #output == 5, "Audit logs every ranged item and final summary, including last registry item")
check(output[3].fields.reason == "no-damage", "Rejected metadata is explained without aborting remaining audit")
check(output[5].event == "firearm-audit-complete" and output[5].fields.accepted == 2
    and output[5].fields.rejected == 1, "Audit totals match accepted and rejected entries")
A.start(); A.tick()
check(#output == 5, "Startup audit runs once per session")
getScriptManager, A.inspect, D.emit = savedManager, savedInspect, savedEmit
SandboxVars.OMHTurretsTraps = savedSettings
