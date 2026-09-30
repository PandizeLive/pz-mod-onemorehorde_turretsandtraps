local R = require("OMHTT/TurretRenderer")
local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")
local hybrid, specific, oldRender, oldRefresh = T.hybrid, getSpecificPlayer, Render3DItem, W.refresh
local enabled, draws = true, {}
T.hybrid = function() return enabled end
function getSpecificPlayer(index)
    check(index == 1, "Renderer uses the event's viewport, not a guessed global")
    return {getZ = function() return 0 end, getX = function() return 610 end, getY = function() return 610 end}
end
function Render3DItem(head, square, x, y, z, yaw)
    draws[#draws + 1] = {head = head, x = x, y = y, z = z, yaw = yaw}
end
local function turret(x, yaw)
    local square = makeSquare(x, 610, 0)
    function square:isCanSee(index) return self.visible ~= false end
    local head = {setWorldScale = function(self, scale) self.scale = scale end}
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
    check(draws[i].yaw == (draws[i].head == headA and 315 or 90), "Per-instance aiming never leaks across shared models")
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
check(R.heading(first) ~= initial and first.data.OMHTTTurret.aimDegrees == 45, "Sweep moves visuals without rewriting aim or detection")
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
T.hybrid, getSpecificPlayer, Render3DItem, W.refresh = hybrid, specific, oldRender, oldRefresh
