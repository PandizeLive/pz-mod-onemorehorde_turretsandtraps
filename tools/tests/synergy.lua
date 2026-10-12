local V = require("OMHTT/TurretVolley")
local E = require("OMHTT/TurretProc")
local S = require("OMHTT/TurretStats")
local R = require("OMHTT/TurretRarity")
local Once = require("OMHTT/TurretOnceEach")
local Estimate = require("OMHTT/TurretBatteryEstimate")
local Clock = require("OMHTT/TurretClock")
local savedClock, savedSettings, savedRoll = Clock.now, SandboxVars.OMHTurretsTraps, testRoll
local now = 5000
Clock.now = function() return now end
SandboxVars.OMHTurretsTraps, testRoll = {}, 0
local oldModData = ModData
local savedData = {}
ModData = {getOrCreate = function() return savedData end}
E.load(); V.reset()
local origin
for x = 1990, 2015 do for y = 1990, 2015 do makeSquare(x, y, 0) end end
origin = testSquares["2000:2000:0"]
local a = makeZombie(testSquares["2001:2000:0"], 10)
local b = makeZombie(testSquares["2005:2000:0"], 10)
function b:getWidth() return .3 end
local c = makeZombie(testSquares["2001:1999:0"], 10)
local profile = {heading = 0, cone = 360, range = 10}
local round = {members = {b,c,a}, used = {}}
local complete, selected = Once.select(round, origin, profile, 150, math.huge)
check(complete and selected == a, "Once each starts with the nearest, independent of current heading")
round.used[a], round.started = true, true
complete, selected = Once.select(round, origin, profile, 0, math.huge)
check(complete and selected == b, "Once each then chooses the smallest turn, even for a farther target")
round.used[b] = true
c.health = 0
complete, selected = Once.select(round, origin, profile, 0, math.huge)
check(complete and not selected, "Dead cohort members are skipped; later arrivals are absent")

R.refresh({})
check(R.get("Firing").b == 1 and R.get("Synergy").b == 130/255, "Seven-stop scale includes both blue and purple extremes")
R.refresh({LootRateSynergy = 0, LootRateTack = 0})
check(R.get("Synergy").weight == 0 and R.get("Martyrdom").b == 130/255, "Disabled weights are excluded from extrema")
R.refresh({ModuleLootRate = 0})
check(R.get("Firing").weight == 0, "Global loot off uses disabled neutral colors")
R.refresh({})

local one = S.resolve({active = {Conservation = 1}})
for _, capacity in pairs({1, 7, 14, 30, 60}) do
    for _, divisor in pairs({1, 2, 3, 9, 17}) do
        for _, cost in pairs({1, 2, 5, 12}) do
            local loaded, debt, shots = capacity, .25, 0
            while loaded > 0 do
                local total = debt + math.min(loaded, cost) / divisor
                local spent = math.floor(total + .0000001)
                loaded, debt, shots = loaded - spent, math.max(0, total - spent), shots + 1
            end
            check(Estimate.magazineUses(capacity, cost, divisor, .25) == shots, "Fast estimate matches exact partial-load Conservation/Splitter accounting")
        end
    end
end
one.cooldown, one.reload = 100, 1000
check(Estimate.duration(one, nil, 21) == 11000, "One-round Conservation reloads every two shots and overlaps cooldown")
one.autoloader, one.reload = true, 0
check(Estimate.duration(one, nil, 21) == 2000, "Autoloader removes reload contribution without changing consumption")
local stats = S.resolve({active = {Synergy = 1, Tack = 1, Martyrdom = 1, Fragment = 1, Splitter = 4, Piercing = 4, Firing = 1, MotionDetection = 1, Filter = 1, Detection360 = 1}})
stats.piercing = 4
check(stats.tack == 1 and stats.martyrdom == 1.5 and E.hits(stats) == 62, "Sixteen-slot stress configuration reserves all possible passive hits")
local shot = {stats = stats, damage = .1, managed = true}
check(V.reserve(shot), "Mixed Synergy shot admitted")
local record = {id = "proc-test", shots = 1}
E.hit(a, true, a:getX(), a:getY(), 0, record, nil, shot)
E.hit(a, true, a:getX(), a:getY(), 0, record, nil, shot)
check(E.fieldCount == 1 and E.contact(a), "Repeated hits across the lifetime create one stationary field")
local fieldId = a.data.OMHTTTackField
V.cancel(shot)
check(E.reservedFields == 0 and E.reservedJobs == 0 and V.reserved == 0, "Unused worst-case capacity is released")
now = now + 5000
E.save(); savedData = nativeRoundTrip(savedData)
now = now + 500000
E.load()
check(E.contact(a) and E.fields[fieldId].expires - now == 5000, "Save/load retains remaining active lifetime, excluding offline time")
now = now + 5001
check(not E.contact(a), "Expired field is harmless even before maintenance removes it")
E.tick()
check(E.fieldCount == 0, "Expired fields and spatial buckets are reclaimed")
shot = {stats = stats, damage = .1, managed = true}; V.reserve(shot)
E.hit(a, true, a:getX(), a:getY(), 0, record, nil, shot)
check(E.fieldCount == 1 and a.data.OMHTTTackField ~= fieldId, "Next eligible hit after expiry rearms the same zombie")
V.cancel(shot)

local oldEmitter = a.getEmitter
a.getEmitter = function() return {playSound = function() end} end
shot = {stats = stats, damage = .1, managed = true}; V.reserve(shot)
a.health = 0
E.hit(a, true, a:getX(), a:getY(), 0, record, nil, shot)
V.cancel(shot)
local near = makeZombie(testSquares["2002:2000:0"], .1)
local fieldsBefore = E.fieldCount
for _ = 1, 200 do if #E.jobs > 0 then E.tick() end end
check(near:isDead() and #E.jobs == 0 and E.fieldCount == fieldsBefore, "Martyrdom terminal kill creates no recursive burst or Tack field")
a.getEmitter = oldEmitter

E.load(); V.reset()
local admissions = {}
while V.available(stats) do
    local options = {stats = stats, damage = .1, managed = true}
    check(V.reserve(options), "Every admitted shot reserves successfully")
    admissions[#admissions + 1] = options
end
check(#admissions > 0 and #admissions < 10, "Dense Synergy capacity back-pressures firing with bounded reservations")
for i = 1, #admissions do V.cancel(admissions[i]) end
check(V.reserved == 0 and E.reservedFields == 0 and E.reservedJobs == 0 and V.available(stats), "Cancelled shots restore admission exactly")

local savedWall = getTimestampMs
for _, linked in pairs({false, true}) do
    E.jobs, E.fields, E.fieldOrder, E.buckets, E.fieldCount = {}, {}, {}, {}, 0
    E.reservedFields, E.reservedJobs = 0, 0
    V.reset()
    local linkedStats = S.resolve({active = {Splitter = 1, Fragment = 1, Tack = 1, InitialBlow = 1}})
    linkedStats.synergy = linked
    local owner = {stats = linkedStats, damage = 1, managed = false}
    check(V.reserve(owner), "Secondary interaction fixture admitted")
    b.health, b.data.OMHTTTackField, b.data.OMHTTInitialHealth = 10, nil, 10
    local group = {kind = "splitter", options = owner, stats = linkedStats, hits = {}, remaining = 1, rays = {}}
    V.ray(record, 2000.5, 2000.5, 0, 0, 10, .1, group, 1)
    local ray = V.queue[1]
    ray.best, ray.square, ray.bestDistance = b, b.square, 5
    V.finish(ray)
    table.remove(V.queue, 1)
    check(E.fieldCount == (linked and 1 or 0), "Only linked secondary hits can drop Tack")
    check(#V.queue == (linked and 5 or 0), "Linked Splitter produces one Fragment generation")
    check(math.abs(b.health - (linked and 9.875 or 9.9)) < .0001, "Synergy retains Initial Blow health eligibility")
    V.release(owner)
    for _ = 1, 1000 do if #V.queue > 0 then V.tick() end end
    check(#V.queue == 0 and V.reserved == 0 and E.reservedFields == 0, "Lineage drains and returns all unused reservation credits")
end
E.jobs, E.fields, E.fieldOrder, E.buckets, E.fieldCount = {}, {}, {}, {}, 0
getTimestampMs = realMillis
local callbacks, maximum, start = 0, 0, realMillis()
for x = 2000, 2008 do for y = 2000, 2008 do
    for _ = 1, 6 do makeZombie(testSquares[x .. ":" .. y .. ":0"], 100) end
end end
for turret = 1, 4 do
    for i = 1, 40 do
        E.jobs[#E.jobs + 1] = {x = 2004.5, y = 2004.5, z = 0, radius = 2, damage = 20,
            source = "stress" .. turret, seen = {}, queuedAt = now, dx = -2, dy = -2, index = 0}
    end
end
while #E.jobs > 0 and callbacks < 100000 do
    local before = realMillis()
    E.tick()
    maximum = math.max(maximum, realMillis() - before)
    callbacks = callbacks + 1
end
check(#E.jobs == 0, "Four-turret dense terminal AoE queue drains without recursive additions")
testProcStress = "bursts=160 zombies=486 callbacks=" .. callbacks .. " maxCallbackMs=" .. maximum .. " drainMs=" .. (realMillis() - start)
getTimestampMs = savedWall
E.jobs, E.fields, E.fieldOrder, E.buckets, E.fieldCount = {}, {}, {}, {}, 0
E.reservedFields, E.reservedJobs = 0, 0
V.reset()
Clock.now, SandboxVars.OMHTurretsTraps, testRoll, ModData = savedClock, savedSettings, savedRoll, oldModData
