local F = require("OMHTT/Foundation")
local D = require("OMHTT/Diagnostics")
local savedTurrets, savedTurretDetail = SandboxVars.OMHTurretsTraps.TurretsEnabled, SandboxVars.OMHTurretsTraps.TurretDetailedLogging
SandboxVars.OMHTurretsTraps.TurretsEnabled = true
SandboxVars.OMHTurretsTraps.TurretDetailedLogging = true
SandboxVars.OMHTurretsTraps.DetailedLogging = false
check(D.detailed("turrets") and not D.detailed("traps"), "Turret detail cannot enable trap detail")
SandboxVars.OMHTurretsTraps.TurretDetailedLogging = false
SandboxVars.OMHTurretsTraps.DetailedLogging = true
check(D.detailed("traps") and not D.detailed("turrets"), "Trap detail cannot enable turret detail")
SandboxVars.OMHTurretsTraps.TurretsEnabled = savedTurrets
SandboxVars.OMHTurretsTraps.TurretDetailedLogging = savedTurretDetail
SandboxVars.OMHTurretsTraps.DetailedLogging = false
local S = require("OMHTT/FoundationServer")
testMillis = testMillis + 2000
check(D.auditTranslations() == 0, "runtime audit resolves all probe keys through native translator")
local originalText = getText
getText = function(key, ...) return key end
check(D.auditTranslations() == 17, "missing translations detected without a screenshot")
getText = originalText
SandboxVars.OMHTurretsTraps.DiagnosticLogging = false
local oldCount = #testLogs
D.emit("disabled", {x = 1})
check(#testLogs == oldCount, "diagnostic toggle silences detailed telemetry")
SandboxVars.OMHTurretsTraps.DiagnosticLogging = true
testMillis = testMillis + 2000
oldCount = #testLogs
for i = 1, 160 do D.emit("burst", {index = i}) end
check(#testLogs - oldCount == 120, "diagnostic burst cap prevents per-frame log flood")
testMillis = testMillis + 2000
D.emit("resumed", {value = "one\ntwo=three"})
local line = testLogs[#testLogs]
check(string.find(line, "suppressed=40", 1, true) and string.find(line, "one_two_three", 1, true), "dropped log count and sanitized values retained")
local square = testSquares[F.key(100, 100, 0)]
local object = square.objects[1]
object.noTexture = true
D.object(object, "missing-texture", 0)
check(string.find(testLogs[#testLogs], "texturePresent=false", 1, true) ~= nil, "missing texture diagnosed independently of marker agreement")
object.noTexture = false
local dialogs = testDialogs
local slot = testData.tiles[F.key(100, 100, 0)]
S.onCommand(F.MODULE, "Aim", testPlayer, {x = 100, y = 100, z = 0, request = 900,
    version = F.VERSION, epoch = slot.epoch, id = slot.device.id, revision = slot.device.revision})
check(testDialogs == dialogs and testHalo == getText("UI_OMHTT_Aimed"), "routine actions do not cover world with a report")
S.onCommand(F.MODULE, "Inspect", testPlayer, {x = 120, y = 100, z = 0, request = 901, version = F.VERSION})
check(string.find(testDialog, getText("UI_OMHTT_NotCompared"), 1, true) ~= nil,
    "range rejection cannot claim local-authority agreement")
check(string.find(testDialog, "UI_OMHTT", 1, true) == nil, "native translations replace visible report keys")
testMenu.options = {}
triggerEvent("OnFillWorldObjectContextMenu", 0, testMenu, {object}, false)
local dump = testMenu.options[getText("ContextMenu_OMHTT_Dump")]
check(dump ~= nil, "bounded nearby diagnostic dump exposed")
dump.callback(dump.target)
check(string.find(testLogs[#testLogs], "event=nearby-summary", 1, true) ~= nil, "nearby dump records completion and scan cap")

D.reset()
SandboxVars.OMHTurretsTraps.DetailedLogging = true
local queuedAt = testMillis
oldCount = #testLogs
D.defer("queued-one", {value = 1})
D.defer("queued-two", {value = 2})
D.defer("queued-three", {value = 3})
check(#testLogs == oldCount, "Shot telemetry does not synchronously format or print")
testMillis = testMillis + 20
D.flush()
check(#testLogs == oldCount + 2, "Only two queued records flush per tick")
check(string.find(testLogs[#testLogs], "ms=" .. tostring(queuedAt), 1, true), "Deferred records retain original event time")
D.flush()
check(#testLogs == oldCount + 3, "Remaining diagnostic record drains on next slice")
D.reset()
oldCount = #testLogs
for i = 1, 257 do D.defer("bounded", {index = i}) end
for i = 1, 128 do testMillis = testMillis + 20; D.flush() end
check(#testLogs == oldCount + 256, "Pending diagnostic queue caps at 256 records")
check(string.find(testLogs[oldCount + 1], "suppressed=1", 1, true), "Queue overflow is counted instead of growing memory")
D.defer("discard", {})
SandboxVars.OMHTurretsTraps.DiagnosticLogging = false
D.flush()
SandboxVars.OMHTurretsTraps.DiagnosticLogging = true
oldCount = #testLogs
D.flush()
check(#testLogs == oldCount, "Disabled logging discards queued diagnostics")
D.reset()

SandboxVars.OMHTurretsTraps.DetailedLogging = false
oldCount = #testLogs
for i = 1, 500 do D.defer("combat", {totalMs = i % 3}) end
check(#testLogs == oldCount, "Normal diagnostics aggregate without per-shot output")
testMillis = testMillis + 5000
D.flush()
check(#testLogs == oldCount + 1 and string.find(testLogs[#testLogs], "combat=500", 1, true), "One summary retains event count")
D.reset()

D.reset()
oldCount = #testLogs
for i = 1, 1000 do D.measure("test-stage", i % 7) end
check(#testLogs == oldCount, "Stage profiling never prints per frame")
testMillis = testMillis + 5000
D.flush()
check(#testLogs == oldCount + 1 and string.find(testLogs[#testLogs], "test-stageCount=1000", 1, true)
    and string.find(testLogs[#testLogs], "test-stageMaxMs=6", 1, true), "Profiling retains counts and peak duration in one bounded summary")
D.reset()
