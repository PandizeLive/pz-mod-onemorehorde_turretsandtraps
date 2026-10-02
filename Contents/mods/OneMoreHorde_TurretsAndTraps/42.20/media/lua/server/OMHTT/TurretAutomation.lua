if isClient() or isServer() then return end
local T = require("OMHTT/Turret")
local M = require("OMHTT/TurretModules")
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
    entry.job, entry.due, entry.status, entry.target = nil, 0, nil, nil
end

---@param origin IsoGridSquare Turret square
---@param profile table Target rules
---@return table job
---@nodiscard
function A.scan(origin, profile)
    local radius = math.ceil(profile.range)
    return {origin = origin, profile = profile, radius = radius, x = -radius, y = -radius,
        index = 0, bestDistance = 0, visited = 0}
end

---@param job table Incremental scan
---@param budget number Maximum work units
---@param deadline number Wall-clock ceiling
---@return boolean complete
function A.advance(job, budget, deadline)
    local Combat = require("OMHTT/PrototypeCombat")
    for step = 1, budget do
        if getTimestampMs() >= deadline then return false end
        if job.y > job.radius then return true end
        local square = getCell():getGridSquare(job.origin:getX() + job.x, job.origin:getY() + job.y, job.origin:getZ())
        local objects = square and square:getMovingObjects()
        if objects and job.index < objects:size() then
            local zombie = objects:get(job.index)
            job.index = job.index + 1
            job.visited = job.visited + 1
            if instanceof(zombie, "IsoZombie") then
                local inside, distance = M.inside(job.origin, zombie, job.profile)
                local select = inside and (job.profile.priority == "Random"
                    or M.better(zombie, distance, job.best, job.bestDistance, job.profile.priority))
                if select and Combat.clearLane(job.origin, zombie:getSquare(), job.profile.range) then
                    if job.profile.priority == "Random" then
                        job.eligible = (job.eligible or 0) + 1
                        select = ZombRand(job.eligible) == 0
                    end
                    if select then job.best, job.bestDistance = zombie, distance end
                end
            end
        else
            job.index = 0
            job.x = job.x + 1
            if job.x > job.radius then
                job.x = -job.radius
                job.y = job.y + 1
            end
        end
    end
    return job.y > job.radius
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
    local now = getTimestampMs()
    if now < entry.due then return true end
    local aim = require("OMHTT/TurretAim").entries[object]
    if require("OMHTT/TurretSearch").pending[object] or (aim and aim.player) then return true end
    local interval = M.option("DetectionInterval", 0.25, 0.1, 5) * 1000
    local contents = T.contents(object:getContainer())
    if not W.valid(object) or not M.detects(state, contents) or not W.power(object, contents) then
        entry.job, entry.due = nil, now + interval
        entry.target = nil
        A.status(entry, "inactive")
        return true
    end
    local profile = M.profile(state, contents)
    local key = profile.heading .. ":" .. profile.cone .. ":" .. profile.range .. ":" .. profile.priority
    if entry.key ~= key then entry.job, entry.target = nil, nil end
    entry.key = key
    local Combat = require("OMHTT/PrototypeCombat")
    local target = entry.target
    local sticky = profile.priority == "Random" or profile.priority == "Toughest"
    local retained = sticky and target and M.inside(square, target, profile)
        and Combat.clearLane(square, target:getSquare(), profile.range)
    local job = {visited = 0}
    if not retained then
        if not entry.job then entry.job = A.scan(square, profile) end
        if not A.advance(entry.job, 64, deadline) then return true end
        job, target = entry.job, entry.job.best
    end
    entry.job, entry.due = nil, now + interval
    if not target or not M.inside(square, target, profile)
        or not Combat.clearLane(square, target:getSquare(), profile.range) then
        entry.target = nil
        if entry.status ~= "no-target" then
            D.defer("turret-auto-search", {id = state.id, visits = job.visited, range = profile.range,
                cone = profile.cone, baseFacing = state.baseFacing, selected = false})
        end
        A.status(entry, "no-target")
        return true
    end
    local aligned = require("OMHTT/TurretAim").request(object, target, nil)
    if entry.target ~= target then
        entry.target = target
        D.defer("turret-auto-target", {id = state.id, x = target:getX(), y = target:getY(), visits = job.visited,
            priority = profile.priority, cone = profile.cone, baseFacing = state.baseFacing, aim = state.aimDegrees})
    end
    if not aligned then
        A.status(entry, "Aiming")
    elseif contents.active.Firing then
        A.status(entry, W.fire(nil, object, target))
    else
        A.status(entry, "tracking-only")
    end
    return true
end

---@return nil
function A.tick()
    local deadline = getTimestampMs() + 2
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
            A.entries[entry.object] = nil
            table.remove(A.order, A.cursor)
        end
    end
end

Events.OnOMHTTTurretChanged.Add(A.changed)
Events.OnTick.Add(A.tick)
return A
