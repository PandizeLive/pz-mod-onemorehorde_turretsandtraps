local O = require("OMHTT/TurretRange")
local R = require("OMHTT/TurretRenderer")
local T = require("OMHTT/Turret")
local oldUI, oldCore, oldUtils, oldCamera = ISUIElement, getCore, IsoUtils, IsoCamera
local oldPlayer, oldLeft, oldTop = getSpecificPlayer, getPlayerScreenLeft, getPlayerScreenTop
local oldWidth, oldHeight = getPlayerScreenWidth, getPlayerScreenHeight
local strokes, stencil, legend = {}, nil, nil
local projections = 0
ISUIElement = {new = function()
    return {instantiate = function() end, drawLine2 = function(self, x, y, tx, ty)
        strokes[#strokes + 1] = {x, y, tx, ty}
    end, setStencilRect = function(self, x, y, w, h) stencil = {x, y, w, h} end,
    clearStencilRect = function() end, drawText = function(_, text) legend = text end}
end}
function getPlayerScreenLeft() return 100 end
function getPlayerScreenTop() return 50 end
function getPlayerScreenWidth() return 640 end
function getPlayerScreenHeight() return 480 end
IsoUtils = {XToScreen = function(x, y) return (x - y) * 64 end,
    YToScreen = function(x, y, z) return (x + y) * 32 - z * 192 end}
IsoCamera = {getOffX = function() return -700 end, getOffY = function() return 1000 end}
local square = makeSquare(20, 30, 2)
function square:isCanSee() return self.visible ~= false end
local object = {data = {OMHTTTurret = {schema = 1, id = "range-test", aimDegrees = 90}}, index = 0}
function object:hasModData() return true end
function object:getModData() return self.data end
function object:getSquare() return square end
function object:getObjectIndex() return self.index end
local player = {z = 2}
function player:isDead() return false end
function player:getX() return 20.5 end
function player:getY() return 30.5 end
function player:getZ() return self.z end
function getSpecificPlayer() return player end
R.entries[object] = {head = {}, hasDetector = true, automatic = {range = 6}, profile = {heading = 0, cone = 90, omni = false, range = 6, stats = {firearm = false, hearingMultiplier = 1}}}
O.selected = {}
O.clicked(object)
check(O.selected[0].click == object, "Native left mouse pick selects exact turret")
check(Events.OnPreUIDraw.handlers[1] == O.render, "Range draws before UI controls")
local lines = O.lines(20.5, 30.5, 6, 90, 360)
check(#lines == 67, "Manual coverage is full circle with aim arrow")
check(math.abs(lines[65][3] - 20.5) < 0.00001 and lines[65][4] == 24.5, "Aim uses combat heading convention")
for i = 1, 64 do
    local dx, dy = lines[i][3] - 20.5, lines[i][4] - 30.5
    check(math.abs(dx * dx + dy * dy - 36) < 0.00001, "Range arc respects actual radius")
end
SandboxVars.OMHTurretsTraps.ShowTurretRange = true
for _, zoom in pairs({0.5, 1, 2}) do
    function getCore()
        return {getZoom = function() projections = projections + 1; return zoom end, getScreenWidth = function() return 1280 end,
            getScreenHeight = function() return 720 end}
    end
    strokes = {}
    O.render()
    check(#strokes == 133, "Selected turret renders locked cone plus independent aim")
    check(stencil[1] == 100 and stencil[2] == 50 and stencil[3] == 640 and stencil[4] == 480, "Range clips to its player viewport")
    check(math.abs(strokes[67][1] - (60 / zoom + 100)) < 0.00001
        and math.abs(strokes[67][2] - (248 / zoom + 50)) < 0.00001, "Origin projects floor, camera, zoom and viewport once")
end
local entry = R.entries[object]
local before = entry.overlays.coverage.lines
projections = 0
local row = before[1]
for i = 1, 500 do object.data.OMHTTTurret.aimDegrees = i; O.render() end
check(projections == 500, "Camera/zoom projection is sampled once per viewport render instead of per endpoint")
check(entry.overlays.coverage.lines == before and before[1] == row, "Repeated range rendering reuses arc and segment tables while aim changes")
entry.automatic.range = 4.5
strokes = {}; O.render()
check(entry.overlays.coverage.range == 4.5 and entry.overlays.manual.range == 6 and #strokes == 199,
    "Improvised detection draws reduced automatic coverage and separate full manual reach")
check(legend == getText("UI_OMHTT_RangeLegend", "4.5", "6.0"), "Distinct ranges have an explicit color legend")
entry.hasDetector = false
strokes = {}; O.render()
check(entry.overlays.coverage.range == 6 and #strokes == 133
    and legend == getText("UI_OMHTT_RangeManualLegend", "6.0"), "No detector shows manual reach without promising automatic targeting")
entry.hasDetector = true; entry.automatic.range = 6
O.render()
check(legend == getText("UI_OMHTT_RangeSharedLegend", "6.0"), "Equal ranges share one correctly labeled boundary")
strokes = {}; square.visible = false; O.render()
check(#strokes == 0, "Unseen turret does not reveal range")
square.visible = true; player.z = 1; O.render()
check(#strokes == 0, "Other floors do not reveal range")
player.z = 2; SandboxVars.OMHTurretsTraps.ShowTurretRange = false; O.render()
check(#strokes == 0, "Sandbox toggle disables range")
O.focus(0,"facing",object,true)
O.preview[0]={object=object,heading=123.25}
strokes={};O.render()
check(#strokes>0 and entry.overlays.coverage.heading==123.25
    and legend==getText("UI_OMHTT_SetFacingHint"),"Explicit direction picker previews FoV even when passive overlays are disabled")
check(entry.profile.heading~=123.25,"Cursor preview does not mutate normal targeting profile")
O.preview[0]=nil
O.focus(0,"facing",object,false)
strokes={};O.render()
check(#strokes==0,"Cancel restores passive overlay preference")
SandboxVars.OMHTurretsTraps.ShowTurretRange = true
R.entries[object].head = nil; O.render()
check(#strokes == 0, "Empty base has no weapon range")
O.focus(0, "manage", object, true); O.focus(0, "manage", object, false)
check(O.selected[0].manage == nil and O.selected[0].click == object, "Closing Manage clears only its selection")
object.index = -1; O.render()
check(O.selected[0] == nil, "Removed turret retires selection")
object.data.OMHTTTurret = nil; O.focus(0, "hover", object, true)
check(O.selected[0].hover == nil, "Stale hover cannot raise a missing-state error")
R.entries[object] = nil; O.selected = {}
ISUIElement, getCore, IsoUtils, IsoCamera = oldUI, oldCore, oldUtils, oldCamera
getSpecificPlayer, getPlayerScreenLeft, getPlayerScreenTop = oldPlayer, oldLeft, oldTop
getPlayerScreenWidth, getPlayerScreenHeight = oldWidth, oldHeight
