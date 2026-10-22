local A = require("OMHTT/TurretArc")
local V = require("OMHTT/TurretVolley")
local S = require("OMHTT/TurretStats")
local H = require("OMHTT/TurretHeads")
local Clock = require("OMHTT/TurretClock")
local Damage = require("OMHTT/Damage")
local Effects = require("OMHTT/DefenseEffects")
local Combat = require("OMHTT/ControlCombat")
local Line = require("OMHTT/DefenseLine")
local Conditional = require("OMHTT/TurretConditionalHit")
local Proc = require("OMHTT/TurretProc")
local Siphon = require("OMHTT/TurretSiphon")
local Horde = require("OMHTT/DefenseHorde")
local old = {mode = testMode, settings = SandboxVars.OMHTurretsTraps, instance = instanceof, cell = getCell,
    clock = Clock.now, damage = Damage.resolve, effects = Effects.emit, eligible = Combat.eligible,
    line = Line.clear, snapshot = Conditional.snapshot, conditional = Conditional.damage, impact = Conditional.impact,
    proc = Proc.hit, siphon = Siphon.hit, fragment = V.fragment, sound = Horde.sound}
testMode, SandboxVars.OMHTurretsTraps = "sp", {}
local itemData = {}
local head = {getFullType = function() return "Base.OMHTTTurretArc" end,
    getCondition = function() return 100 end, getModData = function() return itemData end}
local stats = S.resolve({head = head, active = {}, powerLoad = 0})
check(stats.ammoFree and stats.damage == 20 and stats.cooldown == 1000 and stats.arcTargets == 6 and stats.arcJump == 4, "Arc approved base contract")
check(math.abs(stats.batteryPercent - .02) < .000001, "Arc pays .02 percent per main discharge")
local rating, drain = require("OMHTT/TurretHeadDescription").rating(head)
check(math.abs(drain - 72) < .000001 and rating == require("OMHTT/ControlConsumption").band(72), "Arc rating includes cadence: Extreme")
for _, name in pairs({"Magazine", "Reload", "Autoloader", "Conservation", "Void", "Accuracy"}) do
    check(not H.supports(head, name), "Arc excludes meaningless module " .. name)
end
for _, name in pairs({"Fragment", "Velocity", "Splitter", "Piercing", "Impact", "Synergy", "Siphon"}) do
    check(H.supports(head, name), "Arc supports selected module " .. name)
end
local Feed = require("OMHTT/TurretFeed")
local cycle, status = Feed.update({head = head}, stats, 1000, true)
local paid, rounds = Feed.consume({head = head}, stats, cycle, 1000)
check(status == "Ready" and paid and rounds == 0, "Arc fires with no physical ammunition")
cycle, status = Feed.update({head = head}, stats, 1999, true)
check(status == "Cooling" and not Feed.consume({head = head}, stats, cycle, 1999), "Arc cannot evade paid cooldown")
cycle, status = Feed.update({head = head}, stats, 2000, true)
check(status == "Ready" and not cycle.reloadReady, "Arc returns ready without reload")
local now, actors, hits, cues, procs, fragments = 0, {}, {}, {}, 0, 0
local square = {getX = function() return 0 end, getY = function() return 0 end, getZ = function() return 0 end}
local object = {getSquare = function() return square end, getObjectIndex = function() return 0 end}
function square:getMovingObjects() return {size = function() return #actors end, get = function(_, n) return actors[n + 1] end} end
getCell = function() return {getGridSquare = function(_, x, y) if x == 0 and y == 0 then return square end return {getMovingObjects = function() return {size = function() return 0 end} end} end} end
instanceof = function(value, kind) return value and value.kind == kind end
Clock.now = function() return now end
Combat.eligible = function(_, actor) return not actor.protected end
Line.clear = function() return true end
Conditional.snapshot = function() return {} end
Conditional.damage = function(_, damage) return damage end
Conditional.impact = function() end
Proc.hit = function() procs = procs + 1 end
Siphon.hit = function() end
Horde.sound = function() end
V.fragment = function(_, _, _, _, actor) fragments = fragments + 1; check(actor ~= nil, "Arc fragment excludes exact burst origin") end
Effects.emit = function(command, facts) cues[#cues + 1] = {command = command, facts = facts} end
Damage.resolve = function(actor, damage, _, _, callback)
    actor.health = actor.health - damage
    hits[#hits + 1] = {actor = actor, damage = damage, time = now}
    callback(damage)
    return true
end
local serial = 0
local function start(count, modules)
    serial = serial + 1
    now, actors, hits, cues, procs, fragments = 0, {}, {}, {}, 0, 0
    A.jobs, A.cursor = {}, 1
    for i = 1, count do
        local actor = {kind = "IsoZombie", x = .5 + i * .2, health = 10, data = {}}
        function actor:getX() return self.x end
        function actor:getY() return .5 end
        function actor:getZ() return 0 end
        function actor:getSquare() return square end
        function actor:isDead() return self.health <= 0 end
        function actor:getModData() return self.data end
        actors[i] = actor
    end
    local resolved = S.resolve({head = head, active = modules or {}, powerLoad = 0})
    local options = {stats = resolved, object = object, weapon = head, damage = .2, range = 12,
        critMultiplier = 2, managed = true, source = "arc-test"}
    check(V.reserve(options), "Arc reserves bounded effects before firing")
    A.launch({id = "arc-test", shots = serial}, square, actors[1], nil, options)
    V.done(options)
    return options
end
local function step()
    now = now + 10
    local job = A.jobs[1]
    if job and A.step(job, now, getTimestampMs() + 1000) then
        table.remove(A.jobs, 1)
        V.release(job.options)
    end
end
local function finish()
    for _ = 1, 1000 do if #A.jobs == 0 then break end; step() end
    check(#A.jobs == 0, "Arc finite lifecycle completes")
    local seen = {}
    for i = 1, #hits do
        check(not seen[hits[i].actor], "One direct hit per actor across all chains")
        seen[hits[i].actor] = true
    end
end
local crowded = S.resolve({head = head, active = {Splitter = 16, Piercing = 16, Fragment = 1, Synergy = 1, Tack = 1, Martyrdom = 1}, powerLoad = 0})
check(V.available(crowded), "Large approved Arc lineage is admitted per contact instead of permanently rejected")
local options = start(20)
finish()
check(#hits == 6 and #cues == 6 and procs == 1 and options.pending == 0, "Base arc hits six and releases reservation")
for i = 1, #hits do check(hits[i].damage == .2, "Native chain retains 20 damage") end
options = start(20, {Piercing = 2})
finish()
check(#hits == 8 and math.abs(hits[7].damage - .14) < .000001 and math.abs(hits[8].damage - .098) < .000001, "Piercing adds diminishing jumps after six")
options = start(30, {Splitter = 1, Piercing = 2, Fragment = 1})
finish()
check(#hits == 14 and fragments == 1 and procs == 1, "Unlinked Synergy: main eight, Splitter six, initial-only procs")
check(hits[9].time - hits[8].time >= 100 and math.abs(hits[9].damage - .1) < .000001, "Branch waits for main and receives reduced damage")
options = start(30, {Splitter = 1, Piercing = 2, Fragment = 1, Synergy = 1})
finish()
check(#hits == 16 and fragments == 16 and procs == 16, "Synergy enables branch Piercing and each eligible on-hit effect")
options = start(20)
actors[2].protected = true
finish()
check(#hits == 6 and hits[2].actor == actors[3], "Nearest eligible candidate excludes protected actor")
options = start(20)
step()
local job = A.jobs[1]
A.search(job, job.x, job.y, 4)
check(not A.scan(job, getTimestampMs() - 1) and job.search.tile == 0, "Expired shared budget does no scanning")
V.save()
local data = ModData.getOrCreate("OMHTTVolley")
check(#data.arcs == 1 and #data.owners == 1 and data.arcs[1].owner == 1, "Arc saves continuation under shared reservation owner")
local owners = data.owners
owners[1].pending, owners[1].primaryDone, owners[1].object = 0, true, object
A.load(data.arcs, owners, now)
finish()
check(#hits == 6, "Save/reload continues without repeating marked initial victim")
testMode, SandboxVars.OMHTurretsTraps = old.mode, old.settings
instanceof, getCell, Clock.now = old.instance, old.cell, old.clock
Damage.resolve, Effects.emit, Combat.eligible, Line.clear = old.damage, old.effects, old.eligible, old.line
Conditional.snapshot, Conditional.damage, Conditional.impact = old.snapshot, old.conditional, old.impact
Proc.hit, Siphon.hit, V.fragment, Horde.sound = old.proc, old.siphon, old.fragment, old.sound
print("[OMHTT-C421] arc contract, nearest search, finite branches, synergy, persistence, cooldown and reservations checked")

local View = require("OMHTT/TurretArcView")
local savedClock, savedAccept = Clock.now, Effects.accept
local time = 1000
Clock.now = function() return time end
Effects.accept = function() return true end
View.bursts, View.cursor = {}, 1
local module = require("OMHTT/Foundation").MODULE
View.receive(module, "Arc", {fromX = 0, fromY = 0, x = 4, y = 0, z = 0})
local burst = View.bursts[1]
check(burst and #burst.segments > 3 and #burst.segments <= 32, "Electrical world effect has bounded jagged segments")
local crooked = false
for i = 1, #burst.segments do
    local segment = burst.segments[i]
    if math.abs(segment.y) > .01 then crooked = true end
    check(segment.scale > 0 and segment.scale < 1, "Electrical segments are finite world geometry")
end
check(crooked and burst.untilTime == 1160, "Electricity is jagged and expires in 160 active milliseconds")
View.receive(module, "Arc", {fromX = 0, fromY = 0, x = 10000, y = 0, z = 0})
check(View.cursor == 2, "Malformed oversized beam is rejected")
for i = 1, 100 do View.receive(module, "Arc", {fromX = 0, fromY = 0, x = 4, y = 0, z = 0}) end
local count = 0
for _ in pairs(View.bursts) do count = count + 1 end
check(count == 64, "Electrical presentation ring stays bounded under burst load")
Clock.now, Effects.accept = savedClock, savedAccept
View.bursts, View.cursor = {}, 1
