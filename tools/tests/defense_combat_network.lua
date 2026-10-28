local S = require("OMHTT/DefenseCombatServer")
local C = require("OMHTT/DefenseCombatClient")
local P = require("OMHTT/DefenseCombatProtocol")
local oldMode, oldCore, oldServer, oldClient, oldPlayer = testMode, OneMoreHordeDefenseIntegration, sendServerCommand, sendClientCommand, getSpecificPlayer
local serverPackets, clientPackets, completions = {}, {}, {}
local player = {getOnlineID = function() return 12 end, isDead = function() return false end}
local stranger = {getOnlineID = function() return 13 end, isDead = function() return false end}
local activePlayer = player
OneMoreHordeDefenseIntegration = nil
getSpecificPlayer = function(index) return index == 0 and activePlayer or nil end
sendServerCommand = function(recipient, module, command, message)
    check((recipient == player or recipient == stranger) and module == P.MODULE, "Combat addresses a selected native owner only")
    serverPackets[#serverPackets + 1] = {command, nativeRoundTrip(message)}
end
sendClientCommand = function(sender, module, command, message)
    check(sender == activePlayer and module == P.MODULE, "Receipt uses the authenticated local owner")
    clientPackets[#clientPackets + 1] = {command, nativeRoundTrip(message)}
end
local nextId = 3000
check(math.floor(P.EPSILON * 1000) >= 1, "Lethal reservation survives native thousandth-health quantization")
local function actor(id)
    local z = {id = id, health = 1, data = {}, owner = player}
    function z:getOnlineID() return self.id end
    function z:getPersistentOutfitID() return self.id * 10 end
    function z:getOwnerPlayer() return self.owner end
    function z:getOwner() return self.connection or (self.owner and player) end
    function z:getHealth() return self.health end
    function z:setHealth(value) self.health = value end
    function z:getNetworkCharacterAI() error("NetworkZombieAI is not exposed to Lua") end
    function z:isDead() return self.health <= 0 end
    function z:isRemoteZombie() return self.remote == true end
    function z:isInvulnerable() return self.invulnerable == true end
    function z:getModData() return self.data end
    function z:getX() return 100 end
    function z:getY() return 100 end
    function z:getZ() return 0 end
    function z:Kill(attacker) check(attacker == nil, "Device death never fabricates player credit"); self.health = 0; self.killed = true end
    return z
end
local function pair()
    nextId = nextId + 1
    local server, client = actor(nextId), actor(nextId)
    testMode = "client"; C.created(client)
    testMode = "server"; S.created(server)
    return server, client
end
local function done(lost, reason) completions[#completions + 1] = {lost, reason} end
local function clientReceive()
    local packet = table.remove(serverPackets, 1)
    check(packet ~= nil, "Expected server command")
    testMode = "client"; C.command(P.MODULE, packet[1], packet[2]); testMode = "server"
    return packet
end
local function serverReceive(sender)
    local packet = table.remove(clientPackets, 1)
    check(packet ~= nil, "Expected owner acknowledgement")
    S.command(P.MODULE, packet[1], sender or player, packet[2])
    return packet
end
local server, client = pair()
check(S.request(server, .3, "turret-1", "firearm", done), "Server accepts owner-aware damage")
check(not S.request(server, .3, "turret-1", "firearm", done), "One pending hit per native victim bounds contention")
clientReceive()
check(client.health == 1 and server.health == 1, "Prepare does not damage either replica")
local ready = serverReceive(stranger)
check(#serverPackets == 0, "Another player's Ready cannot authorize a commit")
S.command(P.MODULE, ready[1], player, ready[2])
client.health = .8 -- Ordinary local player damage occurs between preparation and commit.
local commit = clientReceive()
check(math.abs(client.health - .5) < .000001, "Relative damage preserves an intervening ordinary player hit")
testMode = "client"; C.command(P.MODULE, commit[1], commit[2]); testMode = "server"
check(math.abs(client.health - .5) < .000001, "Repeated commit cannot apply the same damage twice")
serverReceive(); serverReceive()
check(math.abs(server.health - .5) < .000001 and #completions == 1 and math.abs(completions[1][1] - .3) < .000001,
    "Server commits one bounded receipt and one completion callback")
S.command(P.MODULE, ready[1], player, ready[2])
check(#serverPackets == 0, "Late Ready cannot recreate a finished hit")

server, client = pair()
local beforeCompletions = #completions
S.request(server, .3, "bed-1", "bed-spikes", done)
clientReceive(); serverReceive()
client.remote = true
clientReceive(); serverReceive()
check(client.health == 1 and server.health == 1 and #completions == beforeCompletions + 1,
    "A replica that lost native control refuses the damage command")

server, client = pair()
S.request(server, .3, "wire-1", "barbs", done)
clientReceive(); serverReceive(); clientReceive()
server.owner = stranger
serverReceive()
check(server.health == 1 and #serverPackets == 1, "Applied receipt survives handoff and prepares the new owner")
local replacementOwner = actor(client.id)
replacementOwner.health = .6
activePlayer = stranger
testMode = "client"; C.created(replacementOwner); testMode = "server"
clientReceive(); serverReceive(stranger)
local reconciliation = clientReceive()
check(replacementOwner.health == .6, "Handoff does not subtract damage twice or heal lower new-owner health")
serverReceive(stranger)
check(server.health == .6 and completions[#completions][2] == "applied", "Handoff settles the original hit once")
testMode = "client"; C.command(P.MODULE, reconciliation[1], reconciliation[2]); testMode = "server"
serverReceive(stranger)
check(server.health == .6, "Repeated handoff reconciliation is idempotent")
activePlayer = player

serverPackets, clientPackets = {}, {}
server, client = pair()
S.request(server, .3, "wire-1", "barbs", done)
clientReceive(); serverReceive()
local heldCommit = table.remove(serverPackets, 1)
server.owner, client.remote = stranger, true
for i = 1, 10 do S.tick() end
clientReceive(); serverReceive()
testMode = "client"; C.command(P.MODULE, heldCommit[1], heldCommit[2]); testMode = "server"
check(client.health == 1, "Unapplied status revokes a delayed commit after handoff")
clientPackets = {}
activePlayer = stranger
replacementOwner = actor(client.id)
testMode = "client"; C.created(replacementOwner); testMode = "server"
clientReceive(); serverReceive(stranger); clientReceive(); serverReceive(stranger)
check(math.abs(replacementOwner.health - .7) < .00001 and math.abs(server.health - .7) < .00001,
    "A revoked old-owner hit is applied once by the new owner")
activePlayer = player

server, client = pair()
local finisher = false
OneMoreHordeDefenseIntegration = {API_VERSION = 1, authorize = function() return true end,
    beginDamage = function(_, source, kind, lethal) finisher = lethal; return true, lethal and {} or nil end,
    endDamage = function(z, token)
        if token then check(z.killed and finisher, "Horde finisher context spans the actual server death") end
    end}
S.request(server, 2, "turret-1", "firearm", done)
clientReceive(); serverReceive(); clientReceive()
check(not client:isDead() and client.health == P.EPSILON and not finisher, "Owner reserves lethal damage; server still owns terminal attribution")
serverReceive()
check(server.killed and finisher and completions[#completions][1] == 1, "Server commits exactly the reported native health loss before death")
OneMoreHordeDefenseIntegration = nil

server, client = pair()
S.request(server, .3, "turret-1", "firearm", done)
clientReceive()
server.owner = nil
serverReceive()
check(client.health == 1 and completions[#completions][2] == "owner-unavailable", "Disconnect before commit does not hurt the zombie")
check(not S.request(server, 0/0, "turret-1", "firearm", done), "NaN damage cannot enter the queue")

server, client = pair()
check(not S.request(server, .3, {}, "firearm", done), "Invalid provenance cannot enter the queue")
server.invulnerable = true
check(not S.request(server, .3, "turret-1", "firearm", done), "Invulnerable native targets are rejected before sending")
server.invulnerable = false
S.request(server, .3, "turret-1", "firearm", done)
clientReceive()
server.connection = {} -- Same player identity, different native connection.
serverReceive()
check(server.health == 1 and client.health == 1 and #serverPackets == 1,
    "Changed native connection requires a fresh preparation")
S.created(server)
serverPackets, clientPackets = {}, {}
local tinyAfter, tinyLost, tinyLethal = P.result(.0012, .0005)
check(tinyAfter == P.EPSILON and not tinyLethal and math.abs(tinyLost - .0002) < .000001,
    "Nonlethal sub-thousandth result stays alive on the native health wire")

server, client = pair()
S.request(server, .3, "turret-1", "firearm", done)
local originalPrepare = clientReceive()
serverReceive()
local delayedCommit = table.remove(serverPackets, 1)
local replacement = actor(client.id) -- The native object/online ID/outfit combination is reused.
testMode = "client"
C.created(replacement)
C.command(P.MODULE, originalPrepare[1], originalPrepare[2])
C.command(P.MODULE, delayedCommit[1], delayedCommit[2])
check(replacement.health == 1, "Old prepare+commit cannot damage a recycled identity with a new client receipt")
testMode = "server"
S.created(server)
clientPackets = {}

serverPackets, clientPackets = {}, {}
local held = {}
-- Receipts outlive native actor unload/recycling; only the original token can settle them.
server, client = pair()
S.request(server, .3, "turret-archive", "firearm", done)
clientReceive(); serverReceive(); clientReceive()
clientPackets = {}
testMode = "client"; C.created(actor(client.id)); testMode = "server"
server.owner = stranger
S.tick()
clientReceive(); serverReceive()
activePlayer = stranger
clientReceive(); serverReceive(stranger); clientReceive(); serverReceive(stranger)
check(math.abs(server.health - .7) < .000001 and completions[#completions][2] == "applied",
    "Unloaded old-owner actor retains its receipt and handoff settles without another damage subtraction")
activePlayer = player

local runOwner, runEvent = {}, {}
local marks = 0
OneMoreHordeDefenseIntegration = {API_VERSION = 1,
    authorize = function() return true, runOwner, runEvent end,
    beginDamage = function(_, _, _, lethal) check(not lethal, "Pre-dispatch assistance is never a fabricated finisher"); marks = marks + 1; return true end,
    endDamage = function() end}
server, client = pair()
S.request(server, .3, "turret-run", "firearm", done)
clientReceive()
runEvent = {}
serverReceive()
check(#serverPackets == 0 and client.health == 1 and marks == 0,
    "A new receiving Horde event cancels the old event's pending hit before dispatch")
server, client = pair()
S.request(server, .3, "turret-run", "firearm", done)
clientReceive(); serverReceive()
check(marks == 1 and client.health == 1, "Run assistance is marked before the owner can apply damage")
S.created(server)
serverPackets, clientPackets = {}, {}
OneMoreHordeDefenseIntegration = nil

local damage = require("OMHTT/Damage")
server, client = pair()
local confirmed = 0
local function count(lost) confirmed = confirmed + lost end
check(damage.resolve(server, .2, "first", "firearm", count)
    and damage.resolve(server, .3, "second", "splitter", count), "Concurrent device hits are admitted into a bounded victim queue")
check(#serverPackets == 1, "Only one relative health operation is in flight per victim")
clientReceive(); serverReceive(); clientReceive(); serverReceive()
check(math.abs(confirmed - .2) < .000001 and #serverPackets == 0, "Completion does not recursively burst the queued hit")
damage.tick()
clientReceive(); serverReceive(); clientReceive(); serverReceive()
check(math.abs(confirmed - .5) < .000001 and math.abs(client.health - .5) < .000001,
    "Serialized hits preserve both damage amounts without overwriting one another")

server, client = pair()
local hit = require("OMHTT/TurretHit")
local volley = require("OMHTT/TurretVolley")
local owner = {pending = 1, rayBudget = 0, procJobs = 0, procFields = 0}
local callbacks = 0
hit.resolve(server, .2, "retained", "fragment", owner, function() callbacks = callbacks + 1 end)
volley.done(owner)
check(owner.pending == 1 and callbacks == 0, "Pending owner acknowledgement retains the root effect reservation")
clientReceive(); serverReceive(); clientReceive(); serverReceive()
check(owner.pending == 0 and callbacks == 1, "Confirmed effect runs once before releasing the final reservation")

serverPackets, clientPackets = {}, {}
for i = 1, P.MAX_PENDING do
    held[i] = pair()
    check(S.request(held[i], .1, "wire-1", "barbs", done), "Bounded queue accepts available capacity")
end
local extra = pair()
check(not S.request(extra, .1, "wire-1", "barbs", done), "Queue limit rejects excess work without sending a packet")
local oldMillis = testMillis
testMillis = testMillis + P.TIMEOUT + 1
for i = 1, 9 do S.tick() end
check(S.request(extra, .1, "wire-1", "barbs", done), "Bounded timeout sweep recovers all pending capacity")
S.created(extra)
testMillis = oldMillis
testMode, OneMoreHordeDefenseIntegration, sendServerCommand, sendClientCommand, getSpecificPlayer = oldMode, oldCore, oldServer, oldClient, oldPlayer
