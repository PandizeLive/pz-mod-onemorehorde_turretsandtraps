local Budget = require("OMHTT/TurretScheduler")
local Clock = require("OMHTT/TurretClock")
if isClient() then return end
local T = require("OMHTT/Turret")
local M = require("OMHTT/TurretModules")
local CombatPolicy = require("OMHTT/ControlCombat")
local D = require("OMHTT/Diagnostics")
local F = require("OMHTT/Foundation")
local A = {entries = {}, order = {}, cursor = 1}

---@param object IsoObject Turret
---@param head InventoryItem? Installed head
---@return nil
function A.changed(object, head)
    local entry = A.entries[object]
    if not entry then
        entry = {object = object, due = 0}
        A.entries[object] = entry
        A.order[#A.order + 1] = entry
    end
    require("OMHTT/TurretSiphon").stop(entry)
    local definition = require("OMHTT/TurretHeads").get(head)
    entry.rotaryKind = definition and definition.rotary == true
    local state = T.state(object)
    if state then
        state.rotaryManual, state.rotaryMoving = nil, false
    end
    entry.rotaryHead, entry.rotaryJob, entry.stopAt = nil, nil, nil
    entry.job, entry.due, entry.status, entry.target, entry.fireDue = nil, 0, nil, nil, 0
end

---@param origin IsoGridSquare Turret square
---@param profile table Target rules
---@return table job
---@nodiscard
function A.scan(origin, profile)
    return {origin = origin, profile = profile, radius = 0, limit = math.ceil(profile.range), x = 0, y = 0,
        index = 0, bestDistance = 0, visited = 0, members = {}, seen = {}}
end

-- Visit concentric boundaries, yielding per square/object. A completely unloaded
-- boundary cannot be crossed by any valid loaded line of sight.
local function advanceSquare(job)
    job.index = 0
    local r = job.radius
    if job.x == r and job.y == r then
        if not job.ringLoaded or r >= job.limit then job.done = true; return end
        job.radius, job.x, job.y, job.ringLoaded = r + 1, -r - 1, -r - 1, false
    elseif math.abs(job.y) == r then
        job.x = job.x + 1
        if job.x > r then job.x, job.y = -r, job.y + 1 end
    elseif job.x == -r then
        job.x = r
    else
        job.x, job.y = -r, job.y + 1
    end
end

---@param job table Incremental scan
---@param budget number Maximum work units
---@param deadline number Wall-clock ceiling
---@return boolean complete
function A.advance(job, budget, deadline)
    local Combat = require("OMHTT/PrototypeCombat")
    for step = 1, budget do
        if getTimestampMs() >= deadline then return false end
        if job.done then return true end
        local square = getCell():getGridSquare(job.origin:getX() + job.x, job.origin:getY() + job.y, job.origin:getZ())
        if square then job.ringLoaded = true end
        local objects = square and square:getMovingObjects()
        if objects and job.index < objects:size() then
            local zombie = objects:get(job.index)
            job.index = job.index + 1
            job.visited = job.visited + 1
            if CombatPolicy.eligible(job.profile.object, zombie) then
                local inside, distance = M.inside(job.origin, zombie, job.profile)
                local select = inside and (job.profile.priority == "OnceEach" or job.profile.priority == "Random"
                    or M.better(zombie, distance, job.best, job.bestDistance, job.profile.priority))
                if select and Combat.clearLane(job.origin, zombie:getSquare(), job.profile.range) then
                    if job.profile.priority == "OnceEach" and not job.seen[zombie] then
                        job.members[#job.members + 1], job.seen[zombie] = zombie, true
                    end
                    if job.profile.priority == "Random" then
                        job.eligible = (job.eligible or 0) + 1
                        select = ZombRand(job.eligible) == 0
                    end
                    if select then job.best, job.bestDistance = zombie, distance end
                end
            end
        else
            advanceSquare(job)
        end
    end
    return job.done == true
end

---@param entry table Scheduled turret
---@param status string Outcome
---@return nil
function A.status(entry, status)
    if entry.status == status then return end
    entry.status = status
    local state = T.state(entry.object)
    if not state then return end
    D.defer("turret-auto-state", {id = state.id, status = status})
end

---@param entry table Scheduled turret
---@param deadline number Tick wall-clock ceiling
---@return boolean retained
function A.step(entry, deadline)
    local W = require("OMHTT/TurretWorld")
    local object = entry.object
    local square, state = object:getSquare(), T.state(object)
    if not square or not state or object:getObjectIndex() < 0
        or getCell():getGridSquare(square:getX(), square:getY(), square:getZ()) ~= square then return false end
    local now = Clock.now()
    local contents = W.contents(object)
    local standby = require("OMHTT/TurretStandby")
    local waking = standby.entries[object]
    if state.standby == "waking" and waking and not standby.valid(object, waking.target, contents) then
        standby.step(object, contents, nil)
        entry.target, entry.job = nil, nil
        A.status(entry, "no-target")
        return true
    end
    if state.facingPending then return true end
    if entry.rotaryKind then
        return require("OMHTT/TurretRotary").step(entry, deadline)
    end
    if now < entry.due and (not entry.target or now < (entry.fireDue or 0)) then return true end
    local aim = require("OMHTT/TurretAim").entries[object]
    if require("OMHTT/TurretSearch").pending[object] or (aim and aim.player) then return true end
    local stats = T.cycleConfig(contents)
    local interval = M.option("DetectionInterval", 0.25, 0.1, 5) * 1000
    if contents.active.MotionDetectionEnhanced then interval = math.min(interval, M.option("EnhancedDetectionInterval", 0.1, 0.05, 5) * 1000) end
    if not W.valid(object) or not M.detects(state, contents) or not W.power(object, contents, stats) then
        entry.job, entry.due = nil, now + interval
        entry.target = nil
        standby.step(object, contents, nil)
        A.status(entry, "inactive")
        return true
    end
    local profile = M.profile(state, contents, true, stats)
    profile.object = object
    local key = profile.heading .. ":" .. profile.cone .. ":" .. profile.range .. ":" .. profile.priority
    if entry.key ~= key then entry.job, entry.target, entry.round = nil, nil, nil end
    entry.key = key
    local Combat = require("OMHTT/PrototypeCombat")
    local target = entry.target
    local sticky = profile.priority == "Random" or profile.priority == "Toughest"
    local retained = target and CombatPolicy.eligible(object, target) and M.inside(square, target, profile)
        and Combat.clearLane(square, target:getSquare(), profile.range)
    local job = {visited = 0}
    if profile.priority == "OnceEach" then
        if not retained then
            if not entry.round then
                if not entry.job then entry.job = A.scan(square, profile) end
                if not A.advance(entry.job, 64, deadline) then return true end
                entry.round = {members = entry.job.members, used = {}}
                entry.job = nil
            end
            local complete, selected = require("OMHTT/TurretOnceEach").select(entry.round, square, profile, state.aimDegrees or profile.heading, deadline)
            if not complete then return true end
            target, retained = selected, false
            if not target then
                entry.round, entry.target, entry.due = nil, nil, now + interval
                standby.step(object, contents, nil)
                A.status(entry, "no-target")
                return true
            end
        end
    elseif not retained or entry.job or (not sticky and now >= entry.due) then
        if not entry.job then entry.job = A.scan(square, profile) end
        local fireReady = retained and contents.active.Firing and now >= (entry.fireDue or 0)
        if not fireReady and A.advance(entry.job, 64, deadline) then
            job = entry.job
            if job.best then target, retained = job.best, false end
            entry.job, entry.due = nil, now + interval
        elseif not retained then
            entry.target = nil
            return true
        end
    elseif now >= entry.due then
        entry.due = now + interval
    end
    if not target or not CombatPolicy.eligible(object, target) or (not retained and (not M.inside(square, target, profile)
        or not Combat.clearLane(square, target:getSquare(), profile.range))) then
        entry.target = nil
        if entry.status ~= "no-target" then
            D.defer("turret-auto-search", {id = state.id, visits = job.visited, range = profile.range,
                cone = profile.cone, baseFacing = state.baseFacing, selected = false})
        end
        standby.step(object, contents, nil)
        A.status(entry, "no-target")
        return true
    end
    local previousTarget = entry.target
    entry.target = target
    if not standby.step(object, contents, target, false, true) then
        A.status(entry, "Waking")
        return true
    end
    local aligned = require("OMHTT/TurretAim").request(object, target, nil)
    if previousTarget ~= target then
        entry.target = target
        D.defer("turret-auto-target", {id = state.id, x = target:getX(), y = target:getY(), visits = job.visited,
            priority = profile.priority, cone = profile.cone, baseFacing = state.baseFacing, aim = state.aimDegrees})
    end
    if not aligned then
        A.status(entry, "Aiming")
    elseif contents.active.Firing and now >= (entry.fireDue or 0) then
        local result = W.fire(nil, object, target)
        entry.fireDue = now + 50
        if result == "Fired" or result == "Misfire" then entry.fireDue = now + T.cycleConfig(contents).cooldown end
        if result == "Fired" and profile.priority == "OnceEach" and entry.round then
            entry.round.used[target], entry.round.started = true, true
            entry.target, entry.due = nil, now
        end
        A.status(entry, result)
    elseif not contents.active.Firing then
        A.status(entry, "tracking-only")
    end
    return true
end

---@return nil
function A.tick()
    local deadline = Budget.limit(2)
    local count = math.min(4, #A.order)
    for i = 1, count do
        if getTimestampMs() >= deadline or #A.order == 0 then return end
        if A.cursor > #A.order then
            A.cursor = 1
        end
        local entry = A.order[A.cursor]
        if A.step(entry, deadline) then
            A.cursor = A.cursor + 1
        else
            require("OMHTT/TurretSiphon").stop(entry)
            A.entries[entry.object] = nil
            table.remove(A.order, A.cursor)
        end
    end
end

Events.OnOMHTTTurretChanged.Add(A.changed)
Budget.register("A.tick", A.tick)
return A
