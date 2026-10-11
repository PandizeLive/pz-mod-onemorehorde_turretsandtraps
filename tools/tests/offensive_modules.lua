local V = require("OMHTT/TurretVolley")
local Stats = require("OMHTT/TurretStats")
local Cycle = require("OMHTT/TurretCycle")
local savedSettings, savedRoll = SandboxVars.OMHTurretsTraps, testRoll
SandboxVars.OMHTurretsTraps = {}
testRoll = 0
for _, base in pairs({1, 7, 14, 30, 60}) do
    SandboxVars.OMHTurretsTraps.PotatoMagazineCapacity = base
    for count = 0, 10 do
        local stats = Stats.resolve({active = {Magazine = count}})
        check(stats.magazine == math.ceil(base + count * math.max(1, base * .35)), "Linear magazine growth rounds only the final capacity")
    end
end
SandboxVars.OMHTurretsTraps.PotatoMagazineCapacity = nil
for count = 1, 40 do
    local stats = Stats.resolve({active = {Fragment = count, Splitter = 2}})
    check(math.abs(stats.fragmentDamage - math.min(.4, (.2 + (count - 1) * .05))) < .000001 and stats.fragmentRange == 4,
        "Fragment damage caps while range stays independent")
    check(stats.effectPower == 1.5 + count * .25, "Power stays additive, including copies above damage cap")
    for i = 1, count do
        check(math.abs(V.angle(count, i, -1)) <= 90 and V.angle(count, i, -1) ~= 0, "High-stack fan stays within 180 degrees and preserves primary")
    end
end
local origin = makeSquare(1200, 1200, 0)
for x = 1195, 1210 do for y = 1195, 1210 do makeSquare(x, y, 0) end end
origin = testSquares["1200:1200:0"]
local victim = makeZombie(testSquares["1202:1200:0"], 5)
function victim:getWidth() return .3 end
local stats = Stats.resolve({active = {Splitter = 3, Fragment = 5}})
local record = {id = "modules", shots = 1}
local options = {stats = stats, damage = 1, critical = true, critMultiplier = 2}
V.reset(); V.reserve(options)
check(V.reserved == 5, "Delayed primary reserves one burst of queue capacity")
V.fragment(record, victim:getX(), victim:getY(), 0, victim, nil, options)
V.fragment(record, victim:getX(), victim:getY(), 0, victim, nil, options)
check(#V.queue == 5 and V.reserved == 0, "Primary callbacks cannot produce a second fragment burst")
for i = 1, 5 do
    local ray = V.queue[i]
    check(ray.damage == .8 and ray.range == 4 and ray.group.hits[victim], "Fragments inherit full critical budget and exclude primary victim")
    for j = i + 1, 5 do
        local other = V.queue[j]
        local dot = math.max(-1, math.min(1, ray.dx * other.dx + ray.dy * other.dy))
        check(math.deg(math.acos(dot)) >= 29.999, "All five radial directions have at least 30 degrees separation")
    end
end
V.reset(); V.split(record, origin, victim, nil, options)
check(#V.queue == 3 and V.queue[1].damage == 1 and record.splitterSide == 1, "Splitter adds one half-damage child per copy with shared critical")
local firstOdd = V.queue[3].dy
V.reset(); V.split(record, origin, victim, nil, options)
check(V.queue[3].dy == -firstOdd and record.splitterSide == -1, "Odd outer side alternates each volley")
check(nativeRoundTrip(record).splitterSide == -1, "Odd-side state survives native mod-data serialization")
local function drain()
    for i = 1, 1000 do if #V.queue == 0 then return end; V.tick() end
    error("Bounded queue did not drain")
end
local group = {kind = "fragment", stats = {firearm = false}, hits = {}}
V.reset()
V.ray(record, 1200.5, 1200.5, 0, 0, 4, .2, group, 1)
V.ray(record, 1200.5, 1200.5, 0, 0, 4, .2, group, 2)
drain()
check(math.abs(victim.health - 4.8) < .0001 and not victim.knocked and #V.queue == 0,
    "Burst damages each secondary victim once without knockdown or recursion")
local blocked = testSquares["1201:1200:0"]
blocked.blocked = true
V.ray(record, 1200.5, 1200.5, 0, 0, 4, .2, {kind = "splitter", stats = {firearm = false}, hits = {}}, 1)
drain()
check(math.abs(victim.health - 4.8) < .0001, "Native edge obstruction blocks child damage")
blocked.blocked = false
V.ray(record, 1200.5, 1200.5, 0, 0, 1, .2, {kind = "splitter", stats = {firearm = false}, hits = {}}, 1)
drain()
check(math.abs(victim.health - 4.8) < .0001, "Children respect their own range")
V.ray(record, 1200.5, 1200.5, 0, 0, 4, .2, {kind = "splitter", stats = {firearm = false}, hits = {}}, 1)
testSquares["1201:1200:0"] = nil
drain()
check(math.abs(victim.health - 4.8) < .0001, "Unloaded route retires child without remote damage")
testSquares["1201:1200:0"] = blocked
V.reset()
for i = 1, 251 do V.queue[i] = {} end
check(not V.available(stats) and V.available({splitter = 0, fragment = 0}), "Full queue refuses effect volleys before resource commit, leaving ordinary fire available")
V.reset(); V.reserve(options); V.release(options); V.release(options)
check(V.reserved == 0 and #V.queue == 0, "Miss releases its reservation exactly once without a burst")
for i = 1, 300 do origin.moving[i] = {kind = "IsoPlayer"} end
V.ray(record, 1200.5, 1200.5, 0, 0, 4, .2, group, 1)
V.tick()
check(#V.queue == 1 and V.queue[1].objectIndex <= 127, "Dense moving-object lists yield after the 128-step callback bound")
V.reset(); origin.moving = {}
for ready = 1, 3 do
    local state = {loaded = ready, nextShot = 0}
    Cycle.consume(state, 20 - ready, {splitter = 5, magazine = 6, cooldown = 100, reload = 100}, 1000)
    check(state.loaded == 0, "Potato partial volley consumes only the ready load")
end
SandboxVars.OMHTurretsTraps, testRoll = savedSettings, savedRoll

