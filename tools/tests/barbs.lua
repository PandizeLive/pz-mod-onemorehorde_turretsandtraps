local C = require("OMHTT/BarbContact")
local S = require("OMHTT/BarbSupport")
local timer = {}
check(C.step(timer, 0, "first", true, 2000), "First actual contact hits immediately")
for now = 0, 1900, 100 do
    check(not C.step(timer, now, "first", true, 2000), "Repeated or overlapping contact cannot multiply hits")
end
check(not C.step(timer, 1999, "first", true, 2000), "Interval boundary remains exclusive until due")
check(C.step(timer, 2000, "first", true, 2000), "Continuous contact repeats after two seconds")
check(not C.step(timer, 2500, "first", false, 2000), "Exit stops damage")
check(not C.step(timer, 3000, "first", true, 2000), "Rapid reentry preserves shared timer")
check(not C.step(timer, 4000, "first", false, 2000), "An expired timer does not damage an absent zombie")
check(C.step(timer, 4000, "first", true, 2000), "Contact after expiry qualifies once")
check(C.step(timer, 100000, "first", true, 2000), "A long gap permits only one observed-contact hit")
check(not C.step(timer, 100000, "first", true, 2000), "No backlog burst after a long gap")
check(not C.step(timer, 0, "reload", true, 2000), "Reload rebases remaining interval")
check(not C.step(timer, 1999, "reload", true, 2000), "Reload cannot evade cooldown")
check(C.step(timer, 2000, "reload", true, 2000), "Reloaded timer eventually resumes")
check(not C.step(timer, 0, "reload", true, 2000), "Clock rollback preserves bounded remainder")
check(not C.step({}, 0, "off", true, 0), "Invalid interval cannot create per-update damage")
local facings = {"e", "n", "w", "s"}
for i = 1, #facings do
    local x, y, north, side = C.edge(10, 20, facings[i])
    local edge = {x = x, y = y, z = 0, north = north, side = side}
    local ax, ay = x + side * .15, y + .5
    if north then ax, ay = x + .5, y + side * .15 end
    check(C.touching(edge, ax, ay, 0, .3), "Each exposed orientation has contact")
    check(C.touching(edge, ax, ay, 0, .3), "Stationary contact is valid")
    check(not C.touching(edge, ax, ay, 1, .3), "Other floors cannot contact")
    if north then ay = y - side * .15 else ax = x - side * .15 end
    check(not C.touching(edge, ax, ay, 0, .3), "Protected face is excluded")
    if north then ay = y + side * .31 else ax = x + side * .31 end
    check(not C.touching(edge, ax, ay, 0, .3), "Nearby outside collision width does not contact")
    if north then ax, ay = x + 1.01, y else ax, ay = x, y + 1.01 end
    check(not C.touching(edge, ax, ay, 0, .3), "Contact cannot extend beyond the one-tile span")
end
check(C.edge(0, 0, "invalid") == nil, "Unknown orientations are rejected")
local own = {shared = false, health = 50}
check(not S.wear(own, 0) and own.health == 50, "No durability loss without applied damage")
for i = 1, 49 do check(not S.wear(own, .1), "Separate barbs survive their first 49 activations") end
check(own.health == 1 and S.repair(own) and own.health == 50, "Repair restores separate durability")
check(not S.repair(own), "Full-condition repair is a no-op")
for i = 1, 49 do S.wear(own, .1) end
check(S.wear(own, .1) and own.health == 0, "The fiftieth activation breaks separate barbs")
check(not S.repair(own), "Broken and retired barbs cannot be revived through stale repair")
local shared = {shared = true}
check(not S.wear(shared, .1) and shared.health == nil, "Shared supports gain no separate health or activation wear")
check(not S.repair(shared), "Barb repair cannot heal a shared support")
testResults[#testResults + 1] = "Barb contact/timer/durability: passed"
