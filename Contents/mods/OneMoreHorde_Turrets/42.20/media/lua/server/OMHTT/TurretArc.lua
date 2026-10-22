if isClient() then return end
local Clock = require("OMHTT/TurretClock")
local Budget = require("OMHTT/TurretScheduler")
local Volley = require("OMHTT/TurretVolley")
local Conditional = require("OMHTT/TurretConditionalHit")
local Proc = require("OMHTT/TurretProc")
local Effects = require("OMHTT/DefenseEffects")
local A = {jobs = {}, cursor = 1}

---@return boolean admitted
function A.available()
    return #A.jobs < 32
end

---@param job table Paid pulse
---@param x number Search origin X
---@param y number Search origin Y
---@param radius number Circular reach
---@param forward boolean? Restrict initial untargeted shot to aim line
function A.search(job, x, y, radius, forward)
    job.search = {x = x, y = y, radius = radius, left = math.floor(x - radius), top = math.floor(y - radius),
        width = math.floor(x + radius) - math.floor(x - radius) + 1,
        height = math.floor(y + radius) - math.floor(y - radius) + 1, tile = 0, index = 0, forward = forward}
end

---@param job table Paid pulse
---@param actor IsoGameCharacter Candidate
---@param search table Spatial query
---@return boolean available
function A.eligible(job, actor, search)
    if not (instanceof(actor, "IsoZombie") or instanceof(actor, "IsoPlayer")) then return false end
    local marks = actor:getModData().OMHTTSavedArcHits
    if job.seen[actor] or (marks and marks[job.key]) or actor:isDead() or not actor:getSquare() then return false end
    if math.floor(actor:getZ()) ~= job.z then return false end
    if not require("OMHTT/ControlCombat").eligible(job.options.object, actor) then return false end
    local dx, dy = actor:getX() - search.x, actor:getY() - search.y
    if dx * dx + dy * dy > search.radius * search.radius then return false end
    if search.forward and (dx * job.dx + dy * job.dy < 0 or math.abs(dx * job.dy - dy * job.dx) > .35) then return false end
    local origin = getCell():getGridSquare(math.floor(search.x), math.floor(search.y), job.z)
    return origin ~= nil and require("OMHTT/DefenseLine").clear(origin, actor:getSquare(), search.radius + 2)
end

---@param job table Pulse with incremental nearest search
---@param deadline number Shared wall-clock deadline
---@return boolean complete
function A.scan(job, deadline)
    local scan, cell = job.search, getCell()
    for _ = 1, 64 do
        if getTimestampMs() >= deadline then return false end
        if scan.tile >= scan.width * scan.height then return true end
        local x = scan.left + scan.tile % scan.width
        local y = scan.top + math.floor(scan.tile / scan.width)
        local square = cell:getGridSquare(x, y, job.z)
        local objects = square and square:getMovingObjects()
        if objects and scan.index < objects:size() then
            local actor = objects:get(scan.index)
            scan.index = scan.index + 1
            if A.eligible(job, actor, scan) then
                local distance = (actor:getX() - scan.x) ^ 2 + (actor:getY() - scan.y) ^ 2
                if not scan.best or distance < scan.distance then
                    scan.best, scan.distance = actor, distance
                end
            end
        else
            scan.tile, scan.index = scan.tile + 1, 0
        end
    end
    return false
end

---@param job table Paid pulse
---@param actor IsoGameCharacter Selected victim
function A.hit(job, actor)
    local options, stats = job.options, job.options.stats
    local search = job.search or {x = job.x, y = job.y, radius = stats.range}
    if not A.eligible(job, actor, search) then
        job.target, job.search = nil, nil
        A.search(job, search.x, search.y, search.radius, search.forward)
        return
    end
    if instanceof(actor, "IsoZombie") and not require("OMHTT/Damage").available(actor) then
        job.target = actor
        return
    end
    if not Volley.available(stats) then
        job.target = actor
        return
    end
    local contact = {}
    for key, value in pairs(options) do contact[key] = value end
    contact.managed, contact.forward = false, false
    if not Volley.reserve(contact) then return end
    options = contact
    job.seen[actor] = true
    local x, y = actor:getX(), actor:getY()
    local origin = getCell():getGridSquare(math.floor(search.x), math.floor(search.y), job.z)
    job.hits = job.hits + 1
    local damage = job.damage
    if job.hits > stats.arcTargets then
        damage = damage * stats.pierceRetention
        job.damage = damage
    end
    local fragmentDamage = damage
    local primary = job.branch == 0
    local proc = stats.synergy or (primary and job.hits == 1)
    if primary or stats.synergy then damage = Conditional.damage(actor, damage, Conditional.snapshot(actor, stats)) end
    Effects.emit("Arc", {fromX = search.x, fromY = search.y, x = x, y = y, z = job.z, id = job.id, shot = job.shot})
    job.x, job.y, job.search, job.target = x, y, nil, nil
    job.anchors[#job.anchors + 1] = {x = x, y = y}
    job.waiting = true
    local finished = false
    local function complete(lost)
        if finished then return end
        finished = true
        if lost > 0 then
            Effects.emit("ArcHit", {x = x, y = y, z = job.z, gain = stats.hearingMultiplier})
            if not instanceof(actor, "IsoPlayer") then
                require("OMHTT/TurretSiphon").hit(actor, options.siphon, not primary)
            end
            if proc and not instanceof(actor, "IsoPlayer") then
                Proc.hit(actor, true, x, y, job.z, {id = job.id, shots = job.shot}, job.player, options)
                local impact = {impactReady = options.impactReady, stats = stats, source = job.id}
                Conditional.impact(actor, origin, impact)
            end
            if stats.fragment > 0 and proc then
                Volley.fragment({id = job.id, shots = job.shot}, x, y, job.z, actor, job.player,
                    {root = options, stats = stats, effectWeapon = options.effectWeapon, damage = fragmentDamage, critical = false, fragmentReserved = 5})
            end
        end
        Volley.release(options)
        job.waiting = false
    end
    if instanceof(actor, "IsoPlayer") then
        complete(require("OMHTT/TurretPlayerHit").hit(actor, options, "Arc", damage / math.max(.000001, options.damage)) and 1 or 0)
    else
        local accepted = require("OMHTT/Damage").resolve(actor, damage, job.id, "arc", complete)
        if not accepted then complete(0) end
    end
end

---@param record table Turret state
---@param origin IsoGridSquare Muzzle square
---@param target IsoGameCharacter? Initial target
---@param player IsoPlayer? Operator
---@param options table Reserved and paid shot
function A.launch(record, origin, target, player, options)
    local damage = options.damage * (options.critical and options.critMultiplier or 1)
    local x, y = origin:getX() + .5, origin:getY() + .5
    local angle = -math.rad(record.aimDegrees or 0)
    local job = {key = tostring(record.id) .. ":" .. tostring(record.shots), id = record.id, shot = record.shots, options = options, player = player, target = target,
        x = x, y = y, z = origin:getZ(), dx = math.cos(angle), dy = math.sin(angle),
        seen = {}, anchors = {{x = x, y = y}}, anchor = 1, branch = 0, hits = 0,
        damage = damage, baseDamage = damage, due = Clock.now(), started = Clock.now()}
    if target then
        job.dx, job.dy = target:getX() - x, target:getY() - y
        local length = math.sqrt(job.dx * job.dx + job.dy * job.dy)
        if length > 0 then job.dx, job.dy = job.dx / length, job.dy / length end
    else
        A.search(job, x, y, options.range, true)
    end
    local radius = require("OMHTT/TurretStats").hearingRadius(options.weapon, options.stats)
    require("OMHTT/DefenseHorde").sound(options.object, x, y, job.z, radius, 10)
    Effects.emit("ArcShot", {x = x, y = y, z = job.z, gain = options.stats.hearingMultiplier})
    A.jobs[#A.jobs + 1] = job
    return nil
end

---@param job table Pulse
---@param now number Active milliseconds
---@param deadline number Work deadline
---@return boolean finished
function A.step(job, now, deadline)
    if job.waiting or now < job.due then return false end
    local object, stats = job.options.object, job.options.stats
    if not object and job.objectX then
        local square = getCell():getGridSquare(job.objectX, job.objectY, job.z)
        if not square then return false end
        local objects = square:getObjects()
        for i = 0, objects:size() - 1 do
            local candidate = objects:get(i)
            local state = require("OMHTT/Turret").state(candidate)
            if state and state.id == job.id then object = candidate; break end
        end
        job.options.object = object
    end
    if not object or object:getObjectIndex() < 0 or not object:getSquare() then return true end
    if not job.search and job.hits == 0 and not job.target then A.search(job, job.x, job.y, stats.range, true) end
    if job.target then A.hit(job, job.target); return false end
    if job.search then
        if not A.scan(job, deadline) then return false end
        local candidate = job.search.best
        if candidate and A.eligible(job, candidate, job.search) then
            if job.branchSearch then
                job.branchSearch = nil
                job.branch, job.hits = job.branch + 1, 0
                job.damage = job.baseDamage * stats.splitterDamage
            end
            A.hit(job, candidate)
            return false
        end
        if job.hits == 0 and job.branch == 0 then
            Effects.emit("Arc", {fromX = job.x, fromY = job.y, x = job.x + job.dx * stats.range, y = job.y + job.dy * stats.range, z = job.z})
            return true
        end
        job.search = nil
        if job.branchSearch then job.anchor = job.anchor + 1 else job.exhausted = true end
    end
    local limit = stats.arcTargets + ((job.branch == 0 or stats.synergy) and stats.piercing or 0)
    if not job.exhausted and not job.branchSearch and job.hits < limit then
        A.search(job, job.x, job.y, stats.arcJump)
        return false
    end
    if job.branch >= stats.splitter then return true end
    if not job.branchSearch then
        job.branchSearch, job.exhausted, job.anchor = true, nil, 1
        job.due = now + 100
    end
    local anchor = job.anchors[job.anchor]
    if not anchor then return true end
    A.search(job, anchor.x, anchor.y, job.anchor == 1 and stats.range or stats.arcJump)
    return false
end

---@return nil
function A.tick()
    local now, deadline = Clock.now(), Budget.limit(1)
    for _ = 1, math.min(16, #A.jobs) do
        if #A.jobs == 0 or getTimestampMs() >= deadline then return end
        if A.cursor > #A.jobs then A.cursor = 1 end
        local job = A.jobs[A.cursor]
        if A.step(job, now, deadline) then
            table.remove(A.jobs, A.cursor)
            Volley.release(job.options)
        else
            A.cursor = A.cursor + 1
        end
    end
end

---@param ownerIndex function Shared volley owner serialization
---@return table jobs Persistable continuation
function A.save(ownerIndex)
    local result, live = {}, {}
    for i = 1, #A.jobs do live[A.jobs[i].key] = true end
    for i = 1, #A.jobs do
        local job, saved = A.jobs[i], {}
        for key, value in pairs(job) do
            if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then saved[key] = value end
        end
        local square = job.options.object and job.options.object:getSquare()
        saved.objectX, saved.objectY = square and square:getX() or job.objectX, square and square:getY() or job.objectY
        saved.delay, saved.waiting = math.max(0, job.due - Clock.now()), nil
        saved.owner, saved.anchors = ownerIndex(job.options), job.anchors
        if job.search then
            saved.search = {x = job.search.x, y = job.search.y, radius = job.search.radius, forward = job.search.forward}
        end
        for actor in pairs(job.seen) do
            local old, kept = actor:getModData().OMHTTSavedArcHits, {}
            if old then for key in pairs(old) do if live[key] then kept[key] = true end end end
            kept[job.key] = true
            actor:getModData().OMHTTSavedArcHits = kept
        end
        result[i] = saved
    end
    return result
end

---@param saved table? Saved jobs
---@param owners table Restored shared owners
---@param now number Active clock
function A.load(saved, owners, now)
    A.jobs, A.cursor = {}, 1
    for i = 1, #(saved or {}) do
        local job = saved[i]
        job.options, job.seen, job.due = owners[job.owner], {}, now + job.delay
        job.options.pending = job.options.pending + 1
        job.options.primaryDone = nil
        if job.search then A.search(job, job.search.x, job.search.y, job.search.radius, job.search.forward) end
        A.jobs[i] = job
    end
end

Budget.register("TurretArc.tick", A.tick)
return A
