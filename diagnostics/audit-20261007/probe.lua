local A = require('OMHTT/TurretAutomation')
local Aim = require('OMHTT/TurretAim')
local B = require('OMHTT/TurretScheduler')
auditResults = 'Actual unchanged Lua modules; mocked world and clock. Operation counts, not frame benchmarks.\n'
local ranges = {6, 12, 20, 60}
for i = 1, #ranges do
    local radius = ranges[i]
    queries = 0
    local job = A.scan(origin, {range = radius})
    local slices = 1
    while not A.advance(job, 64, 100000) do slices = slices + 1 end
    assert(queries == (radius * 2 + 1)^2)
    auditResults = auditResults .. 'Empty scan range=' .. radius .. ' squares=' .. queries .. ' slices=' .. slices .. '\n'
end
state.aimDegrees = 90
for i = 1, 60 do Aim.request(object, target, nil) end
assert(inventories == 60)
auditResults = auditResults .. '60 repeated unaligned aim requests: inventory summaries=' .. inventories .. '\n'
state.aimDegrees = 0
Aim.entries[object] = nil
local entry = {object = object, due = 2000, target = target, fireDue = 0, key = '0:90:6:Random'}
for i = 1, 10 do assert(A.step(entry, 100000)) end
assert(rays == 20)
auditResults = auditResults .. '10 retained-target non-firing steps: clearLane calls=' .. rays .. '\n'
B.workers, B.cursor = {}, 1
local second = false
B.register('slow-native-call-double', function() clock = clock + 500 end)
B.register('next-worker', function() second = true end)
B.tick()
assert(not second and clock == 1500)
auditResults = auditResults .. '3ms scheduler cannot preempt a simulated 500ms worker; next worker deferred.\n'
