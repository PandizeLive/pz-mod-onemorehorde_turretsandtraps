local Geometry = require("OMHTT/WindowGeometry")
local panel = testControlPanelBase:new(20,30,1000,650)
panel.player = {getPlayerNum=function() return 0 end}
Geometry.install(panel, "NativePersistenceFixture", 900, 500, function() end)
Geometry.resize(panel, 994, 640)
Geometry.close(panel)
check(string.find(testLayoutText, "OMHTT_NativePersistenceFixture_0", 1, true)
    and string.find(testLayoutText, "width=994", 1, true), "Installed native layout writer persists menu dimensions")
check(ISLayoutManager.windows[panel.geometryKey].target.object == nil
    and ISLayoutManager.windows[panel.geometryKey].target.player == nil,
    "Closed native layout registration retains only geometry")
ISLayoutManager.layouts = nil
ISLayoutManager.ReadIni()
local restored = ISLayoutManager.layouts[1].windows[1]
check(tonumber(restored.width) == 994 and tonumber(restored.height) == 640 and restored.visible == nil,
    "Installed native layout reader restores size without stale visibility or device state")
getCore,getFileReader,getFileWriter,ISLayoutManager,luautils.stringStarts = testLayoutSaved.core,testLayoutSaved.reader,testLayoutSaved.writer,testLayoutSaved.manager,testLayoutSaved.starts

ISPanel = testLayoutSaved.panel
