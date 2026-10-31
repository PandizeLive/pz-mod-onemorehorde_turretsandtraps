local E = require("OMHTT/TurretProc")
local V = require("OMHTT/TurretVolley")
local S = require("OMHTT/TurretStats")
local Clock = require("OMHTT/TurretClock")
local oldClock, oldData, oldEvent, oldNoise, oldRoll = Clock.now, ModData, triggerEvent, addSound, testRoll
local now, data, sounds, noise = 1000, {}, {}, 0
Clock.now = function() return now end
ModData = {getOrCreate = function(key) if not data[key] then data[key] = {} end; return data[key] end}
triggerEvent = function(event, module, command, facts)
    if command == "Click" then sounds[#sounds + 1] = {name = facts.sound, time = now} end
end
addSound = function() noise = noise + 1 end
testRoll = 0
E.load(); V.reset()
for x = 2200, 2220 do for y = 2200, 2210 do makeSquare(x, y, 0) end end
local origin = testSquares["2205:2205:0"]
local victim = makeZombie(testSquares["2207:2205:0"], 10)
local bystander = makeZombie(testSquares["2208:2205:0"], 10)
local stats = S.resolve({active = {Tack = 1, Martyrdom = 1, Fragment = 1}})
local options = {stats = stats, damage = .5}
V.reserve(options)
victim.health = 0
E.hit(victim, true, victim:getX(), victim:getY(), 0, {id = "delay", shots = 1}, nil, options)
V.cancel(options)
local field = E.fieldOrder[1]
check(field.starts == 1500 and field.expires == 11500 and not E.contact(bystander), "Tack lifetime starts after its half-second landing delay")
now = 1499; E.tick()
check(#sounds == 0 and noise == 0 and bystander.health == 10, "No early sound or damage")
now = 1500; E.tick()
check(sounds[1].name == "MetalworkingPunchDrop" and E.contact(bystander), "Tack lands at the captured location after 500 ms")
now = 1550; E.tick()
check(sounds[2].name == "AttackStomp" and noise == 0, "Martyrdom sound precedes the pop by 200 ms")
E.save(); data = nativeRoundTrip(data)
now = 100000; E.load()
check(E.jobs[1].due - now == 200 and E.fields[field.id].expires - now == 9950, "Pending burst and field preserve remaining active time across offline save")
E.tick(); check(noise == 0, "Reload does not prematurely pop")
now = now + 200
for i = 1, 100 do E.tick() end
check(noise == 1 and bystander.health < 10 and #sounds == 2, "Restored burst pops once without replaying its sound")
data = {}; E.load(); V.reset()
stats = S.resolve({active = {Fragment = 1}})
stats.range = 6
options = {stats = stats, damage = .5}
V.reserve(options)
victim.health = 10
V.miss({id = "miss", shots = 2}, origin, victim, nil, options)
V.release(options)
now = now + 300
for i = 1, 100 do V.tick() end
check(#V.queue == 5 and victim.health == 10, "Miss reaches full range without turning the scan into a damage ray")
check(math.abs(V.queue[1].x - 2211.5) < .001, "Miss fragments at terminal range")
local due = V.queue[1].group.due
check(due == nil, "Fragments launch immediately at terminal stop")
E.save(); V.save(); data = nativeRoundTrip(data)
now = now + 500000; E.load(); V.load()
check(#V.queue == 5 and V.queue[1].group.due == now, "All in-flight fragment rays survive native table serialization")
local before = #sounds
V.tick(); check(#sounds == before, "Reloaded in-flight fragments do not replay their launch sound")
now = now + 250
for i = 1, 200 do V.tick() end
check(#V.queue == 0 and V.reserved == 0 and E.reservedJobs == 0 and E.reservedFields == 0,
    "Restored lineage releases every admission credit")
check(#sounds == before and sounds[#sounds].name == "OMHTTPotatoFire", "Non-firearm fragments inherit the originating head cue exactly once")
local rarity = require("OMHTT/TurretRarity")
rarity.refresh({})
for name in pairs(require("OMHTT/LootDefinitions").WEIGHTS) do
    local description = require("OMHTT/TurretDescriptions").get(name, false)
    if string.sub(name, 1, 8) == "Capacity" then
        check(string.find(description, "Controller:") and string.find(description, "Turret:") and not string.find(description, "Feature:"), "Kits have device-specific benefits: " .. name)
    else
        check(string.find(description, "Feature:") and string.find(description, "Stackable:")
            and string.find(description, "Battery Drain:") and string.find(description, "Rarity:"), "Every loot module has four fields: " .. name)
    end
    check(not string.find(description, "Tooltip_OMHTT"), "Every module feature translation resolves")
end
data = {}; E.load(); V.reset()
Clock.now, ModData, triggerEvent, addSound, testRoll = oldClock, oldData, oldEvent, oldNoise, oldRoll
