if isClient() then return end
local Clock = require("OMHTT/TurretClock")
local Budget = require("OMHTT/TurretScheduler")
local Volley = require("OMHTT/TurretVolley")
local Proc = require("OMHTT/TurretProc")
local Damage = require("OMHTT/Damage")
local Conditional = require("OMHTT/TurretConditionalHit")
local Horde = require("OMHTT/DefenseHorde")
local Effects = require("OMHTT/DefenseEffects")
local Combat = require("OMHTT/PrototypeCombat")
local Ammo = require("OMHTT/TurretAmmo")
local O = {jobs = {}, reserved = 0, cursor = 1, serial = 0}

---@param stats table Effective shot settings
---@return number count Worst-case committed grenades
function O.capacity(stats)
    if stats.headKind ~= "Lobber" then return 0 end
    local parents = 1 + stats.splitter
    local fragments = stats.fragment > 0 and 5 * (stats.synergy and parents or 1) or 0
    return parents + fragments
end

---@param stats table Effective shot settings
---@return boolean admitted
function O.available(stats)
    return #O.jobs + O.reserved + O.capacity(stats) <= 256
end

---@param job table Plain-data grenade trajectory and effect ownership
---@return nil
function O.add(job)
    O.serial = O.serial + 1
    job.id, job.seen = tostring(O.serial), {}
    job.distance, job.index = 0, 0
    job.queuedAt = Clock.now()
    O.jobs[#O.jobs + 1] = job
    job.shared.remaining = (job.shared.remaining or 0) + 1
end

---@param record table Device identity
---@param origin IsoGridSquare Launch square
---@param target IsoZombie Fixed aim at commit
---@param player IsoPlayer? Operator
---@param options table Committed shot
---@return table facts Launch feedback
function O.launch(record, origin, target, player, options)
    if options.stats.headKind == "Scrapshot" then
        return require("OMHTT/TurretScrapshot").launch(record, origin, target, player, options)
    end
    local stats = options.stats
    local payload = Ammo.bombs[options.ammoDescriptor and options.ammoDescriptor.type]
        or Ammo.bombs["Base.OMHTTAmmoMakeshiftBomb"]
    local base = payload.damage or payload.minimum + ZombRand((payload.maximum - payload.minimum) * 100) / 100
    local damage = base / 100 * options.damage / 1.5
    if options.critical then
        damage = damage * options.critMultiplier
    end
    local x, y = origin:getX() + .5, origin:getY() + .5
    local tx, ty = options.aimX or target:getX(), options.aimY or target:getY()
    local dx, dy = tx - x, ty - y
    local distance = math.sqrt(dx * dx + dy * dy)
    local scatter = (.5 + math.min(1, math.max(0, (distance - 6) / 12))) / math.max(1, stats.accuracy / 100)
    local offset = ZombRand(62832) / 10000
    local radius = math.sqrt(ZombRand(10001) / 10000) * scatter
    local aimX, aimY = tx + math.cos(offset) * radius, ty + math.sin(offset) * radius
    dx, dy = aimX - x, aimY - y
    distance = math.min(stats.range, math.sqrt(dx * dx + dy * dy))
    local angle = math.atan2(dy, dx)
    local shared = {stats = stats, impactReady = options.impactReady, source = record.id, x = aimX, y = aimY, z = origin:getZ(), pending = 0}
    local fragments = stats.fragment > 0 and 5 or 0
    for i = 0, stats.splitter do
        local a = angle
        if i > 0 then
            a = a + math.rad(Volley.angle(stats.splitter, i, record.splitterSide or -1))
        end
        local children = (i == 0 or stats.synergy) and fragments or 0
        O.reserved = O.reserved + children
        O.add({source = record.id, shot = tostring(record.shots) .. ":" .. i, x = x, y = y, z = origin:getZ(),
            dx = math.cos(a), dy = math.sin(a), range = distance, speed = 8, fuse = 1250,
            damage = damage * (i == 0 and 1 or .5), injuryScale = i == 0 and 1 or .5, radius = payload.radius, children = children,
            sound = options.ammoDescriptor and options.ammoDescriptor.type == "Base.PipeBomb" and "PipeBombExplode"
                or (options.ammoDescriptor and options.ammoDescriptor.type == "Base.Aerosolbomb" and "AerosolBombExplode" or "FireCrackerSingleExplode"),
            gain = payload.damage and .35 or 1,
            eligible = i == 0 or stats.synergy, stats = stats, shared = shared, due = Clock.now()})
    end
    if stats.splitter % 2 == 1 then
        record.splitterSide = -(record.splitterSide or -1)
    end
    Volley.release(options)
    return {id = record.id, shot = record.shots, x = x, y = y, z = origin:getZ(),
        fromX = x, fromY = y, firearm = true, sound = "OMHTTPotatoFire", missed = true}
end

---@param shared table Firing-event owner
---@return nil
function O.impact(shared)
    if (shared.remaining or 0) > 0 or (shared.pending or 0) > 0 or not shared.impactReady then return end
    local candidate = shared.candidate
    local actor = shared.actor
    if not actor and candidate then
        local square = getCell():getGridSquare(math.floor(candidate.x), math.floor(candidate.y), candidate.z)
        local objects = square and square:getMovingObjects()
        if objects then
            for i = 0, objects:size() - 1 do
                local other = objects:get(i)
                if instanceof(other, "IsoZombie") and other:getOnlineID() == candidate.id and other:getPersistentOutfitID() == candidate.outfit then
                    actor = other
                    break
                end
            end
        end
    end
    local origin = getCell():getGridSquare(math.floor(shared.x), math.floor(shared.y), shared.z)
    if actor and origin then
        Conditional.impact(actor, origin, shared)
    end
    shared.impactReady, shared.actor = false, nil
end

---@param job table Committed grenade
---@return boolean? completed Nil waits; false consumed one bounded work step
function O.step(job)
    local now = Clock.now()
    if now < job.due then return nil end
    if not job.landed then
        local maximum = math.min(job.range, math.max(0, (now - job.due) / 1000 * job.speed))
        if job.distance >= maximum and job.distance < job.range then return nil end
        local distance = math.min(job.range, job.distance + .25)
        local previous = getCell():getGridSquare(math.floor(job.x + job.dx * job.distance), math.floor(job.y + job.dy * job.distance), job.z)
        local square = getCell():getGridSquare(math.floor(job.x + job.dx * distance), math.floor(job.y + job.dy * distance), job.z)
        local clear = previous and square and Combat.clearLane(previous, square, 2)
        if clear then
            job.distance = distance
        end
        if clear and distance < job.range then
            if not job.shown then
                job.shown = true
                Effects.emit("Launch", {id = job.source, shot = "grenade:" .. job.id, x = job.x + job.dx * job.range,
                    y = job.y + job.dy * job.range, z = job.z, fromX = job.x, fromY = job.y,
                    start = now, flight = job.range / job.speed * 1000, projectile = "grenade", silent = true})
            end
            return false
        end
        job.x, job.y = job.x + job.dx * job.distance, job.y + job.dy * job.distance
        job.landed, job.due = true, now + job.fuse
        Effects.emit("Land", {id = job.source, shot = "grenade:" .. job.id, x = job.x, y = job.y,
            z = job.z, fromX = job.x, fromY = job.y, silent = true, projectile = "grenade"})
        local bound = math.ceil(job.radius)
        job.scanX, job.scanY, job.index = -bound, -bound, 0
        return false
    end
    local origin = getCell():getGridSquare(math.floor(job.x), math.floor(job.y), job.z)
    if not origin then
        O.reserved = O.reserved - job.children
        job.children = 0
        return true
    end
    if not job.started then
        job.started = true
        Horde.sound(nil, math.floor(job.x), math.floor(job.y), job.z, 40, 40)
        Effects.emit("Impact", {id = job.source, shot = "grenade:" .. job.id, x = job.x, y = job.y, z = job.z,
            fromX = job.x, fromY = job.y, sound = job.sound or "FireCrackerSingleExplode", gain = job.gain or .15,
            silent = job.mini and job.shared.miniSoundAt ~= nil and now - job.shared.miniSoundAt < 120})
        if job.mini and (not job.shared.miniSoundAt or now - job.shared.miniSoundAt >= 120) then
            job.shared.miniSoundAt = now
        end
        for i = 1, job.children do
            local angle = math.rad((i - 1) * 72 + ZombRand(3600) / 100)
            O.reserved = O.reserved - 1
            O.add({source = job.source, shot = job.shot .. ":mini" .. i, x = job.x, y = job.y, z = job.z,
                dx = math.cos(angle), dy = math.sin(angle), range = 2, speed = 8, fuse = 500, mini = true, gain = .15, sound = "FireCrackerSingleExplode",
                damage = job.damage * job.stats.fragmentDamage, injuryScale = (job.injuryScale or 1) * job.stats.fragmentDamage, radius = 1, children = 0,
                eligible = job.stats.synergy, stats = job.stats, shared = job.shared, due = now + 250})
        end
        job.children = 0
    end
    local bound = math.ceil(job.radius)
    if job.scanY > bound then return true end
    local square = getCell():getGridSquare(math.floor(job.x) + job.scanX, math.floor(job.y) + job.scanY, job.z)
    local objects = square and square:getMovingObjects()
    if not objects or job.index >= objects:size() then
        job.index, job.scanX = 0, job.scanX + 1
        if job.scanX > bound then
            job.scanX, job.scanY = -bound, job.scanY + 1
        end
        return false
    end
    local actor = objects:get(job.index)
    if job.eligible and not Proc.available(job.stats) then return nil end
    if instanceof(actor, "IsoZombie") and not Damage.available(actor) then return nil end
    job.index = job.index + 1
    if not (instanceof(actor, "IsoZombie") or instanceof(actor, "IsoPlayer"))
        or not Proc.inside(origin, actor, job.x, job.y, job.radius) then return false end
    local saved = actor:getModData().OMHTTOrdnanceSeen
    if job.seen[actor] or (saved and saved[job.id]) then return false end
    job.seen[actor] = true
    local dx, dy = actor:getX() - job.x, actor:getY() - job.y
    local fraction = math.max(0, 1 - math.sqrt(dx * dx + dy * dy) / job.radius)
    if instanceof(actor, "IsoPlayer") then
        local scale = job.injuryScale or 1
        require("OMHTT/DefenseInjury").blast(actor, 10 * fraction * scale, .5 * fraction * scale)
    elseif Horde.allowed(actor) then
        local options = {stats = job.stats}
        if job.eligible then
            Proc.reserve(options)
        end
        local x, y = actor:getX(), actor:getY()
        local amount = job.damage * fraction
        if job.eligible then
            amount = Conditional.damage(actor, amount, Conditional.snapshot(actor, job.stats))
        end
        job.shared.pending = (job.shared.pending or 0) + 1
        Damage.resolve(actor, amount, job.source, "grenade", function(lost)
            if lost > 0 and job.eligible then
                Proc.hit(actor, true, x, y, job.z, {id = job.source, shots = job.shot}, nil, options)
                local dx, dy = actor:getX() - job.shared.x, actor:getY() - job.shared.y
                local distance = dx * dx + dy * dy
                if not actor:isDead() and not actor:isProne() and not actor:isKnockedDown()
                    and (not job.shared.distance or distance < job.shared.distance) then
                    job.shared.actor, job.shared.distance = actor, distance
                    job.shared.candidate = {id = actor:getOnlineID(), outfit = actor:getPersistentOutfitID(),
                        x = actor:getX(), y = actor:getY(), z = actor:getZ()}
                end
            end
            Proc.release(options)
            job.shared.pending = job.shared.pending - 1
            O.impact(job.shared)
        end)
    end
    if job.index > objects:size() or objects:get(job.index - 1) ~= actor then
        job.index = job.index - 1
    end
    return false
end

---@return nil
function O.tick()
    local deadline = Budget.limit(1)
    local waiting = 0
    for _ = 1, 128 do
        if #O.jobs == 0 or waiting >= #O.jobs or getTimestampMs() >= deadline then
            break
        end
        if O.cursor > #O.jobs then
            O.cursor = 1
        end
        local job = O.jobs[O.cursor]
        local completed = O.step(job)
        if completed then
            job.shared.remaining = job.shared.remaining - 1
            O.impact(job.shared)
            O.jobs[O.cursor] = O.jobs[#O.jobs]
            O.jobs[#O.jobs] = nil
            waiting = 0
        else
            O.cursor = O.cursor + 1
            if completed == nil then
                waiting = waiting + 1 else waiting = 0
            end
        end
    end
end

---@return nil
function O.save()
    local data, now = ModData.getOrCreate("OMHTTOrdnance"), Clock.now()
    data.jobs, data.serial, data.owners = {}, O.serial, {}
    local live, owners = {}, {}
    for i = 1, #O.jobs do live[O.jobs[i].id] = true end
    for i = 1, #O.jobs do
        local job, copy = O.jobs[i], {}
        for key, value in pairs(job) do
            if key ~= "seen" and key ~= "shared" then
                copy[key] = value
            end
        end
        if not owners[job.shared] then
            owners[job.shared] = #data.owners + 1
            local shared = {}
            for key, value in pairs(job.shared) do
                if key ~= "actor" then
                    shared[key] = value
                end
            end
            shared.pending = 0
            data.owners[owners[job.shared]] = shared
        end
        copy.owner = owners[job.shared]
        copy.remaining, copy.elapsed = math.max(0, job.due - now), math.max(0, now - job.due)
        for actor in pairs(job.seen) do
            local old, kept = actor:getModData().OMHTTOrdnanceSeen, {}
            if old then
                for id in pairs(old) do
                    if live[id] then
                        kept[id] = true
                    end
                end
            end
            kept[job.id] = true
            actor:getModData().OMHTTOrdnanceSeen = kept
        end
        copy.index = 0
        data.jobs[i] = copy
    end
end

---@return nil
function O.load()
    local data, now = ModData.getOrCreate("OMHTTOrdnance"), Clock.now()
    O.jobs, O.reserved, O.cursor, O.serial = {}, 0, 1, data.serial or 0
    for i = 1, #(data.jobs or {}) do
        local job = data.jobs[i]
        job.shared = data.owners[job.owner]
        job.due, job.seen = now + job.remaining - job.elapsed, {}
        O.jobs[#O.jobs + 1] = job
        O.reserved = O.reserved + job.children
    end
end

Budget.register("Ordnance.tick", O.tick)
Events.OnSave.Add(O.save)
Events.OnGameStart.Add(O.load)
Events.OnServerStarted.Add(O.load)
return O
