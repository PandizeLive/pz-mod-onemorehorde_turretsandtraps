local T = require("OMHTT/Turret")
local V = require("OMHTT/TurretVolley")
local O = require("OMHTT/TurretOrdnance")
local B = require("OMHTT/TurretForward")
local Clock = require("OMHTT/TurretClock")
local oldMode, oldClock, oldSettings = testMode, Clock.now, SandboxVars.OMHTurretsTraps
testMode, SandboxVars.OMHTurretsTraps = "sp", {}
local now = 10000
Clock.now = function() return now end
local square = makeSquare(2600, 2600, 0)
local object = {getSquare = function() return square end}
for _, kind in pairs({"Potato", "Ballista", "Scrapshot", "Lobber"}) do
    local head = {getFullType = function() return "Base.OMHTTTurret" .. kind end}
    local stats = T.cycleConfig({head = head, active = {}, powerLoad = 0})
    if kind == "Scrapshot" then check(stats.damage == 320, "Scrapshot uses eight forty-damage pellets") end
    local record = {id = "forward-test", kind = "potato", shots = 0, ammo = 5, facing = 0, landingRange = 9}
    local options = {forward = true, managed = true, stats = stats, range = stats.range, weapon = head,
        interval = stats.cooldown, damage = stats.damage / 100, critChance = 0, critMultiplier = 2,
        projectileSpeed = 20, ammoCost = 1, commit = function() return true end}
    local count = #V.queue
    local result, facts = B.fire(record, object, nil, options)
    check(result == "Fired" and record.ammo == 4 and record.shots == 1,
        "Targetless " .. kind .. " commits exactly one normal firing cycle")
    if kind == "Lobber" then
        check(math.abs(options.aimX - 2609.5) < .0001 and options.aimY == 2600.5,
            "Lobber fixed-facing endpoint uses its separate nine-tile landing setting")
        check(#O.jobs > 0 and O.jobs[#O.jobs].range <= stats.range, "Blind Lobber retains bounded grenade travel")
        O.jobs, O.reserved = {}, 0
    else
        check(#V.queue > count and math.abs(V.queue[count + 1].dy) < .001 or kind == "Scrapshot",
            "Blind primary direction does not acquire an off-axis target")
    end
    if kind == "Potato" or kind == "Ballista" then
        check(facts.shot == V.queue[count + 1].shot, "Projectile launch and impact share one presentation identity")
    end
    V.done(options)
    now = now + 100000
    local visits = 0
    while #V.queue > 0 and visits < 1000 do
        local ray = table.remove(V.queue, 1)
        ray.distance = ray.range
        V.finish(ray)
        visits = visits + 1
    end
    check(#V.queue == 0 and V.reserved == 0, "Empty-lane shot releases every ray reservation")
end
local head = {getFullType = function() return T.HEAD end}
local stats = T.cycleConfig({head = head, active = {}, powerLoad = 0})
local record = {id = "forward-reject", kind = "potato", shots = 0, ammo = 3, facing = 4}
local options = {forward = true, managed = true, stats = stats, range = stats.range, commit = function() return false end}
check(B.fire(record, object, nil, options) == "Unavailable" and record.ammo == 3 and record.shots == 0 and V.reserved == 0,
    "Rejected resource transaction creates no shot or reservation leak")
local Access = require("OMHTT/TurretAccess")
local Action = require("OMHTT/TurretControlAction")
local oldNear, oldContents = Access.near, T.contents
Access.near = function() return true end
local selected = "Lobber"
T.contents = function() return {head = {getFullType = function() return "Base.OMHTTTurret" .. selected end}, active = {}, powerLoad = 0} end
local control = setmetatable({id = "landing-test", object = {getContainer = function() return {} end}, command = "LandingRange"}, {__index = Action})
for _, value in pairs({6, 9, 18}) do
    control.value = value
    check(control:isValid(), "Server accepts an in-range integral landing distance")
end
for _, value in pairs({-1, 5, 19, 9.5, "9", 0 / 0, math.huge}) do
    control.value = value
    check(not control:isValid(), "Server rejects malformed or out-of-range landing distance")
end
selected, control.value = "Ballista", 9
check(not control:isValid(), "Landing control cannot mutate a different head")
Access.near, T.contents = oldNear, oldContents
Clock.now, testMode, SandboxVars.OMHTurretsTraps = oldClock, oldMode, oldSettings
