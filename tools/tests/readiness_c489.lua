-- C489 defect reproductions converted to C490 delivery regressions.
local S = require("OMHTT/TurretTackServer")
local V = require("OMHTT/TurretTackView")
local E = require("OMHTT/TurretProc")
local Clock = require("OMHTT/TurretClock")
local saved = {mode = testMode, wall = getTimestampMs, clock = Clock.now, specific = getSpecificPlayer,
    online = getOnlinePlayers, server = sendServerCommand, client = sendClientCommand, order = E.fieldOrder,
    fields = V.fields, viewOrder = V.fieldOrder, count = V.fieldCount, buckets = V.buckets}
local wall, simulation, requests, broadcasts, enumerations = 8000000, 8000000, 0, 0, 0
local packets, players = {}, {}

---@param x number Position
---@return table player Network actor double
local function actor(x)
    return {x = x, dead = false, isDead = function(self) return self.dead end,
        isLocalPlayer = function() return true end, getX = function(self) return self.x end,
        getY = function() return 0 end}
end
local player, second, far = actor(0), actor(200), actor(2000)
players = {player, second, far}
getTimestampMs = function() return wall end
Clock.now = function() return simulation end
getSpecificPlayer = function(index) if index == 0 then return player end end
getOnlinePlayers = function()
    enumerations = enumerations + 1
    return {size = function() return #players end, get = function(_, i) return players[i + 1] end}
end
V.fields, V.fieldOrder, V.fieldCount, V.buckets = {}, {}, 0, {}
local field = {id = "c490-existing", x = 200, y = 0, z = 0, radius = 2,
    source = "c490-turret", starts = simulation + 2000, expires = simulation + 300000}
E.fieldOrder = {field}
sendServerCommand = function(recipient, module, command, payload)
    if type(recipient) == "string" then
        broadcasts = broadcasts + 1
        return
    end
    packets[#packets + 1] = {player = recipient, command = command, data = nativeRoundTrip(payload)}
    if recipient == player or recipient == second then
        local mode = testMode
        testMode = "client"
        V.receive(module, command, nativeRoundTrip(payload))
        testMode = mode
    end
end
sendClientCommand = function(sender, module, command, payload)
    requests = requests + 1
    local mode = testMode
    testMode = "server"
    S.command(module, command, sender, nativeRoundTrip(payload))
    testMode = mode
end
---@return nil
local function pump()
    local mode = testMode
    testMode = "server"
    S.pump()
    testMode = mode
end

testMode = "client"
V.start()
V.update(player)
pump()
check(requests == 1 and #packets == 0, "C490 startup and first update coalesce")
player.x, wall, simulation = 200, wall + 1000, simulation + 6000
V.update(player)
check(requests == 1, "C490 fast-forward cannot accelerate the network request clock")
wall = wall + 4000
V.update(player)
pump()
check(requests == 2 and V.fields[field.id] ~= nil, "C490 stationary arrival receives existing field after real cooldown")
check(V.fields[field.id].expires == field.expires, "C490 field expiry remains simulation time")
local before = requests
for i = 1, 100 do V.update(player) end
check(requests == before, "C490 stationary view has no snapshot polling")

-- Transport delay can still place a later request inside the server cooldown.
testMode = "server"
wall = wall + 1000
for i = 1, 100 do S.command("OMHTT_TackView", "Request", player) end
local count = #packets
pump()
check(#packets == count, "C490 repeated early requests wait instead of bypassing throttle")
player.x, field.x, wall = 400, 400, wall + 4000
pump()
check(#packets == count + 1 and packets[#packets].data[1].x == 400,
    "C490 deferred coalesced snapshot uses latest position without client retry")
pump()
local idle = enumerations
for i = 1, 100 do pump() end
check(enumerations == idle, "C490 idle pump performs no player enumeration")

second.x = 400
S.publish(field)
check(#packets == count + 3 and V.fieldCount == 1, "C490 nearby split-screen deliveries do not duplicate fields")
player.x, second.x = 2000, 2000
S.publish(field, true)
check(#packets == count + 5 and V.fieldCount == 0, "C490 removal reaches previous observers after they leave")
S.publish(field, true)
check(#packets == count + 5, "C490 removal tracking retires without replay")

second.x = 400
testMode = "client"
V.update(second)
pump()
check(V.fields[field.id] ~= nil and packets[#packets].player == second, "C490 second local player receives late-arrival snapshot")
simulation = field.expires + 1
V.update(second)
check(V.fieldCount == 0, "C490 accelerated simulation expires fields independently of network time")

testMode = "server"
local gone, dead = actor(400), actor(400)
players[#players + 1], players[#players + 2] = gone, dead
S.command("OMHTT_TackView", "Request", gone)
S.command("OMHTT_TackView", "Request", dead)
players = {player, second, far, dead}
dead.dead = true
count = #packets
pump()
pump()
check(#packets == count, "C490 disconnect and death retire queued requests")

local fresh = actor(400)
players = {fresh}
E.fieldOrder = {}
for i = 1, 512 do
    E.fieldOrder[i] = {id = "c490-limit-" .. i, x = 400, y = 0, z = 0, radius = 2,
        source = "c490-turret", starts = simulation + 500, expires = simulation + 300000}
end
S.command("OMHTT_TackView", "Request", fresh)
count = #packets
pump()
check(#packets == count + 16, "C490 maximum snapshot remains sixteen bounded packets")
for i = count + 1, #packets do
    check(#packets[i].data == 32 and packets[i].data[1].startsIn == 500, "C490 native snapshot preserves batch and deployment bounds")
end

players = {fresh}
for i = 2, 32 do players[i] = actor(2000 + i) end
count = #packets
for i = 1, 512 do
    S.publish(E.fieldOrder[i])
    S.publish(E.fieldOrder[i], true)
end
check(#packets == count + 1024 and broadcasts == 0, "C490 512 field lifecycles deliver 1024 targeted packets, zero global broadcasts")
for i = count + 1, #packets do
    check(packets[i].player == fresh, "C490 distant unrelated recipients receive no Tack traffic")
end

local a, b = actor(400), actor(400)
players = {a, b}
S.command("OMHTT_TackView", "Request", a)
S.command("OMHTT_TackView", "Request", b)
count = #packets
pump()
check(#packets == count + 16, "C490 one snapshot maximum per server tick")
pump()
check(#packets == count + 32, "C490 next requester progresses on following tick")
pump()

testMode, getTimestampMs, Clock.now, getSpecificPlayer = saved.mode, saved.wall, saved.clock, saved.specific
getOnlinePlayers = saved.online
sendServerCommand, sendClientCommand, E.fieldOrder = saved.server, saved.client, saved.order
V.fields, V.fieldOrder, V.fieldCount, V.buckets = saved.fields, saved.viewOrder, saved.count, saved.buckets
testPackAudit = "C490 Tack: real-time requests; deferred/coalesced latest-area delivery; nearby updates; remembered removals; split-screen/expiry/disconnect/bounds pass."
