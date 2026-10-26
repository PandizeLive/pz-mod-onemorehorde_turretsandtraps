if isClient() then return end
local A = require("OMHTT/ControlAccess")
local Q = {jobs = {}, first = 1, last = 0, pending = setmetatable({}, {__mode = "k"})}

---@param object IsoObject Newly placed device or Controller
---@param player IsoPlayer Placer
---@return nil
function Q.add(object, player)
    local state = A.state(object)
    if not state or not player or state.owner ~= player:getUsername() or Q.pending[object]
        or (state.kind ~= "Controller" and state.controller) then return end
    Q.last = Q.last + 1
    local job = {object = object, player = player, id = state.id, owner = state.owner,
        sweep = state.kind == "Controller", index = 1, rejected = {}}
    Q.jobs[Q.last], Q.pending[object] = job, true
end

---@param job table Placement job
---@param world table Authoritative ControlWorld
---@return boolean complete
local function step(job, world)
    local state = A.state(job.object)
    if not state or state.id ~= job.id or state.owner ~= job.owner or not state.placed
        or job.object:getObjectIndex() < 0 or job.object:getHealth() <= 0
        or job.player:isDead() or job.player:getUsername() ~= job.owner then return true end
    if job.sweep then
        local id = world.order[job.index]
        if not id then return true end
        job.index = job.index + 1
        local object = world.objects[id]
        local candidate = A.state(object)
        if candidate and candidate.kind ~= "Controller" and not candidate.controller
            and candidate.owner == job.owner and A.range(job.object, object) then
            Q.add(object, job.player)
        end
        return false
    end
    if state.controller then return true end
    local index = job.controllerIndex or 1
    local id = world.order[index]
    job.controllerIndex = index + 1
    if id then
        local controller = world.objects[id]
        local host = A.state(controller)
        if host and host.kind == "Controller" and host.placed and controller:getObjectIndex() >= 0
            and host.owner == job.owner
            and not job.rejected[id] and controller:getHealth() > 0 and A.range(controller, job.object) then
            local distance = (host.x - state.x) ^ 2 + (host.y - state.y) ^ 2
            if not job.best or distance < job.distance or (distance == job.distance and id < job.bestId) then
                job.best, job.bestId, job.distance = controller, id, distance
            end
        end
        return false
    end
    if not job.best then return true end
    if world.assign(job.best, job.object, job.player, true) then return true end
    -- A nearer full Controller must not prevent the next eligible one being used.
    job.rejected[job.bestId] = true
    job.best, job.bestId, job.distance, job.controllerIndex = nil, nil, nil, nil
    return false
end

---@return nil
function Q.tick()
    if GameTime.isGamePaused() or Q.first > Q.last then return end
    local world = require("OMHTT/ControlWorld")
    local deadline = getTimestampMs() + 1
    for _ = 1, 32 do
        local job = Q.jobs[Q.first]
        if not job then break end
        if step(job, world) then
            Q.pending[job.object], Q.jobs[Q.first] = nil, nil
            Q.first = Q.first + 1
        end
        if getTimestampMs() >= deadline then break end
    end
    if Q.first > Q.last then
        Q.jobs, Q.first, Q.last = {}, 1, 0
    end
end

---@return nil
function Q.reset()
    Q.jobs, Q.first, Q.last = {}, 1, 0
    Q.pending = setmetatable({}, {__mode = "k"})
end

Events.OnTick.Add(Q.tick)
Events.OnGameStart.Add(Q.reset)
return Q
