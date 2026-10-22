local indicatorSetting = SandboxVars.OMHTurretsTraps.TurretStateIndicator
SandboxVars.OMHTurretsTraps.TurretStateIndicator = false
local R = require("OMHTT/TurretRenderer")
local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")
local hybrid, specific, oldRender, oldRefresh = T.hybrid, getSpecificPlayer, Render3DItem, W.refresh
local enabled, draws = true, {}
local oldDebug = getDebugOptions
local atlas = {value = true, default = true}
function atlas:getValueAsString() return tostring(self.value) end
function atlas:getDefaultValue() return self.default end
function atlas:setValue(v) self.value = v end
function atlas:setDefaultToCurrentValue() self.default = self.value end
function getDebugOptions() return {getOptionByName = function(_, name)
    check(name == "WorldItemAtlas.Enable", "Native atlas option selected")
    return atlas
end} end
T.hybrid = function() return enabled end
function getSpecificPlayer(index)
    check(index == 1, "Renderer uses the event's viewport, not a guessed global")
    return {getZ = function() return 0 end, getX = function() return 610 end, getY = function() return 610 end}
end
function Render3DItem(head, square, x, y, z, yaw)
    if yaw == -1 then check(not atlas.value and not atlas.default, "Mounted gun bypasses atlas in debug and non-debug") end
    draws[#draws + 1] = {head = head, x = x, y = y, z = z, yaw = yaw, rx = head.rx, ry = head.ry, rz = head.rz}
end
local function turret(x, yaw)
    local square = makeSquare(x, 610, 0)
    function square:isCanSee(index) return self.visible ~= false end
    local head = {getFullType = function() return T.HEAD end, setWorldScale = function(self, scale) self.scale = scale end}
    head.rx, head.ry, head.rz = 0, 0, 0
    function head:getWorldXRotation() return self.rx end
    function head:getWorldYRotation() return self.ry end
    function head:getWorldZRotation() return self.rz end
    function head:setWorldXRotation(v) self.rx = v end
    function head:setWorldYRotation(v) self.ry = v end
    function head:setWorldZRotation(v) self.rz = v end
    local object = {data = {OMHTTTurret = {schema = 1, facing = 0, aimDegrees = yaw}}, square = square, index = 0}
    function object:hasModData() return true end
    function object:getModData() return self.data end
    function object:getSquare() return self.square end
    function object:getObjectIndex() return self.index end
    function object:getContainer() return {getItems = function() return {size = function() return 0 end} end} end
    R.changed(object, head)
    return object, head
end
local first, headA = turret(610, 45)
local second, headB = turret(611, 270)
R.render(1)
check(#draws == 2 and headA.scale == 0.512 and headB.scale == 0.512, "Actual installed heads use recorded calibration")
for i = 1, #draws do
    check(math.abs(draws[i].z - (0.4 - 16 / 192)) < 0.000001 and draws[i].y == 610.5, "Head draws at base center and height lowered with base")
    check(draws[i].rz == (draws[i].head == headA and 315 or 90), "Per-instance aiming never leaks across shared models")
end
local A = require("OMHTT/TurretAutomation")
local savedSpeed = SandboxVars.OMHTurretsTraps.IdleSweepSpeed
SandboxVars.OMHTurretsTraps.IdleSweepSpeed = 30
A.entries[first] = {status = "no-target"}
R.animate(testMillis)
local initial = R.heading(first)
for i = 1, 100 do
    testMillis = testMillis + 100
    R.animate(testMillis)
    local offset = ((R.heading(first) + 180) % 360) - 180
    check(math.abs(offset) <= 45.00001, "Idle sweep stays inside locked cone")
end
check(R.heading(first) ~= initial and first.data.OMHTTTurret.facing == 0, "Sweep updates physical head angle without moving detection cone")
A.entries[first].status = "inactive"
local stopped = R.heading(first)
testMillis = testMillis + 100
R.animate(testMillis)
check(R.heading(first) == stopped, "Inactive detector freezes head")
A.entries[first].status, A.entries[first].target = "tracking-only", {}
first.data.OMHTTTurret.aimDegrees = 20
R.animate(testMillis)
check(R.heading(first) == 20, "Target tracking overrides idle sweep")
A.entries[first] = nil
SandboxVars.OMHTurretsTraps.IdleSweepSpeed = savedSpeed
R.changed(first, nil)
draws = {}
R.render(1)
check(#draws == 1 and draws[1].head == headB, "Removing head removes only its model")
second.square.visible = false
draws = {}
R.render(1)
check(#draws == 0, "Hidden square does not reveal turret head")
enabled = false
second.index = -1
testMillis = testMillis + 1100
W.refresh = function() end
R.tick()
check(R.entries[second] == nil, "Removed turrets retire while 3D rendering is disabled")
R.entries[first] = nil
enabled = true
local gunObject, gun = turret(610, 45)
function gun:getFullType() return "Base.Pistol" end
gun.rx, gun.ry, gun.rz = 13, 27, 39
function gun:getWorldXRotation() return self.rx end
function gun:getWorldYRotation() return self.ry end
function gun:getWorldZRotation() return self.rz end
function gun:setWorldXRotation(value) self.rx = value end
function gun:setWorldYRotation(value) self.ry = value end
function gun:setWorldZRotation(value) self.rz = value end
local oldInstance = instanceItem
instanceItem = function(fullType)
    check(fullType == "Base.OMHTTTurretGunSupportVisual", "Only a technical support is created for gun rendering")
    return {support = true}
end
R.changed(gunObject, gun)
draws = {}
R.render(1)
check(#draws == 2 and draws[1].head.support and draws[2].head == gun, "One support and actual gun render without a ground item")

check(draws[2].yaw == -1 and math.abs(draws[2].rx + 90) < .0001 and math.abs((draws[2].ry + 360) % 360 - 315) < .000001 and math.abs(draws[2].rz) < .0001, "Native item XYZ pose " .. tostring(draws[2].yaw) .. "/" .. tostring(draws[2].rx) .. "/" .. tostring(draws[2].ry) .. "/" .. tostring(draws[2].rz))
check(gun.rx == 13 and gun.ry == 27 and gun.rz == 39, "Rendering restores original gun pose")
check(math.abs(draws[2].z - draws[1].z - .1) < .000001, "Gun is seated above the support")
check(atlas.value and atlas.default, "Ground item atlas settings restored after mounted draw")
atlas.value, atlas.default = false, true
R.render(1)
check(not atlas.value and atlas.default, "Stored non-default atlas preference survives draw")
local Draw = require("OMHTT/ControlModelDraw")
local restore = Draw.buffer
restore.atlas, restore.enabled, restore.default = atlas, false, true
restore.item, restore.x, restore.y, restore.z = gun, 13, 27, 39
Draw.pending = restore
atlas.value, atlas.default = false, false
gun.rx, gun.ry, gun.rz = -90, 315, 0
R.restoreDraw()
check(not atlas.value and atlas.default and gun.rx == 13 and gun.ry == 27 and gun.rz == 39,
    "Interrupted draw state can be recovered before the next render/tick")
R.entries[gunObject] = nil
Draw.atlas = nil
getDebugOptions = oldDebug
instanceItem = oldInstance
T.hybrid, getSpecificPlayer, Render3DItem, W.refresh = hybrid, specific, oldRender, oldRefresh

SandboxVars.OMHTurretsTraps.TurretStateIndicator = indicatorSetting
