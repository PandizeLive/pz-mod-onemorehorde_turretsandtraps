local S = require("OMHTT/TurretTackServer")
local V = require("OMHTT/TurretTackView")
local E = require("OMHTT/TurretProc")
local Clock = require("OMHTT/TurretClock")
local saved = {mode = testMode, wall = getTimestampMs, clock = Clock.now, specific = getSpecificPlayer,
    server = sendServerCommand, client = sendClientCommand, order = E.fieldOrder,
    fields = V.fields, viewOrder = V.fieldOrder, count = V.fieldCount, buckets = V.buckets}
local wall, simulation, requests, responses, broadcasts = 8000000, 8000000, 0, 0, 0
local player = {x = 0}

---@return boolean dead
function player:isDead() return false end
---@return boolean localPlayer
function player:isLocalPlayer() return true end
---@return number x
function player:getX() return self.x end
---@return number y
function player:getY() return 0 end

getTimestampMs = function() return wall end
Clock.now = function() return simulation end
getSpecificPlayer = function(index) if index == 0 then return player end end
V.fields, V.fieldOrder, V.fieldCount, V.buckets = {}, {}, 0, {}
local field = {id = "c489-existing-field", x = 200, y = 0, z = 0, radius = 2,
    source = "c489-turret", starts = simulation, expires = simulation + 300000}
E.fieldOrder = {field}
sendServerCommand = function(recipient, module, command, payload)
    if type(recipient) == "string" then
        broadcasts = broadcasts + 1
        return
    end
    check(recipient == player, "C489 snapshot responds to authenticated requester")
    responses = responses + 1
    local mode = testMode
    testMode = "client"
    V.receive(module, command, nativeRoundTrip(payload))
    testMode = mode
end
sendClientCommand = function(sender, module, command, payload)
    requests = requests + 1
    local mode = testMode
    testMode = "server"
    S.command(module, command, sender, nativeRoundTrip(payload))
    testMode = mode
end

testMode = "client"
V.update(player)
check(requests == 1 and responses == 0, "C489 initial area has no nearby saved Tack field")
player.x, wall, simulation = 200, wall + 1000, simulation + 6000
V.update(player)
check(requests == 2 and responses == 0, "C489 reproduces accelerated area request rejected by wall-clock throttle")
wall, simulation = wall + 10000, simulation + 10000
for i = 1, 20 do V.update(player) end
check(requests == 2 and V.fields[field.id] == nil,
    "C489 defect reproduced: stationary client never retries the suppressed area snapshot")
testMode = "server"
S.command("OMHTT_TackView", "Request", player)
check(responses == 1 and V.fields[field.id] ~= nil,
    "C489 missing field is available once the same snapshot request is actually retried")
for i = 1, 512 do
    field.id = "c489-field-" .. tostring(i)
    S.publish(field)
    S.publish(field, true)
end
check(broadcasts == 1024, "C489 reproduces 512 field creations and removals using global broadcasts")

testMode, getTimestampMs, Clock.now, getSpecificPlayer = saved.mode, saved.wall, saved.clock, saved.specific
sendServerCommand, sendClientCommand, E.fieldOrder = saved.server, saved.client, saved.order
V.fields, V.fieldOrder, V.fieldCount, V.buckets = saved.fields, saved.viewOrder, saved.count, saved.buckets
testPackAudit = "C489 confirmed: Tack clock mismatch loses area snapshot; 1024 global broadcasts for 512 field lifecycles. Production unchanged."
