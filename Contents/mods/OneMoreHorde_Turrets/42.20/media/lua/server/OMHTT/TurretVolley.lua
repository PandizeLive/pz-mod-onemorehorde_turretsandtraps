if isClient() then return end
local Horde = require("OMHTT/DefenseHorde")
local Budget = require("OMHTT/TurretScheduler")
local Damage = require("OMHTT/Damage")
local F = require("OMHTT/Foundation")
local Clock = require("OMHTT/TurretClock")
local V = {queue = {}, reserved = 0, serial = 0, cursor = 1}
local Proc = require("OMHTT/TurretProc")
local Conditional = require("OMHTT/TurretConditionalHit")

---@param stats table Shot stats
---@return number rays Worst-case lineage capacity
function V.capacity(stats)
    local children = (stats.splitter or 0) + (stats.piercing or 0)
    return (stats.splitter or 0) + ((stats.fragment or 0) > 0 and 5 or 0)
        + (((stats.piercing or 0) > 0 or (stats.fragment or 0) > 0) and 1 or 0)
        + (stats.synergy and (stats.fragment or 0) > 0 and children * 5 or 0)
end

---@param options table Root shot owner
---@return nil
function V.done(options)
    if not options.pending then return end
    options.pending = options.pending - 1
    if options.pending == 0 then
        V.reserved = V.reserved - options.rayBudget
        options.rayBudget = 0
        Proc.release(options)
    end
end

---@param stats table Effective modules
---@return boolean available Bounded committed effect capacity
---@nodiscard
function V.available(stats)
    return #V.queue + V.reserved + V.capacity(stats) <= 256 and Proc.available(stats)
end

---@param options table Committed primary shot
---@return nil
function V.reserve(options)
    if not options.stats then return true end
    if not V.available(options.stats) then return false end
    options.primaryDone = nil
    options.rayBudget = V.capacity(options.stats)
    options.pending = options.managed and 2 or 1
    options.fragmentReserved = options.stats.fragment > 0 and 5 or nil
    options.pierceReserved = options.stats.piercing > 0 and 1 or nil
    V.reserved = V.reserved + options.rayBudget
    Proc.reserve(options)
    return true
end

---@param options table Primary owner after impact or cancellation
---@return nil
function V.release(options)
    if options.primaryDone then return end
    options.primaryDone = true
    options.fragmentReserved, options.pierceReserved = nil, nil
    V.done(options)
end

---@param options table Admission whose resource commit failed
---@return nil
function V.cancel(options)
    if not options.pending then return end
    options.pending = 1
    V.done(options)
end

---@param count number Installed Splitters
---@param index number Child index
---@param oddSide number Alternating sign
---@return number degrees Aim-relative direction
---@nodiscard
function V.angle(count, index, oddSide)
    local pair = math.ceil(index / 2)
    local step = math.min(15, 90 / math.ceil(count / 2))
    local side = index % 2 == 1 and -1 or 1
    if count % 2 == 1 and index == count then side = oddSide end
    return side * pair * step
end

---@param record table Firing device
---@param x number Origin X
---@param y number Origin Y
---@param z number Floor
---@param angle number Radians in world coordinates
---@param range number Ray length
---@param damage number Resolved damage
---@param group table Shared burst ownership
---@param index number Child identity
---@return nil
function V.ray(record, x, y, z, angle, range, damage, group, index)
    local owner = group.options
    if not group.persistId then
        V.serial = V.serial + 1
        group.persistId = tostring(V.serial)
    end
    if owner and owner.pending then
        if owner.rayBudget <= 0 then error("Ray admission exhausted") end
        owner.rayBudget, V.reserved = owner.rayBudget - 1, V.reserved - 1
        owner.pending = owner.pending + 1
    end
    V.queue[#V.queue + 1] = {x = x, y = y, z = z, dx = math.cos(angle), dy = math.sin(angle),
        range = range, distance = 0, damage = damage, group = group, id = record.id,
        shot = tostring(record.shots) .. ":" .. group.kind .. ":" .. index, objectIndex = 0}
end

---@param record table Persisted device controls
---@param origin IsoGridSquare Muzzle tile
---@param target IsoZombie Primary aim
---@param player IsoPlayer? Operator
---@param options table Committed shot snapshot
---@return nil
function V.split(record, origin, target, player, options, impact)
    local stats = options.stats
    if stats.splitter == 0 then V.done(options); return end
    local x, y = origin:getX() + .5, origin:getY() + .5
    local angle = math.atan2(target:getY() - y, target:getX() - x)
    local side = record.splitterSide or -1
    if stats.splitter % 2 == 1 then record.splitterSide = -side end
    local group = {options = options, kind = "splitter", player = player, weapon = options.effectWeapon, stats = stats, hits = {}, remaining = stats.splitter, rays = {}}
    if impact and impact.firearm then
        local dx, dy = impact.x - x, impact.y - y
        local distance = math.sqrt(dx * dx + dy * dy)
        local forward = math.min(impact.muzzle or require("OMHTT/Turret").HEAD_VISUAL.muzzle * require("OMHTT/Turret").HEAD_VISUAL.scale * 1.5, distance / 2)
        group.fromX, group.fromY = x, y
        if distance > 0 then group.fromX, group.fromY = x + dx / distance * forward, y + dy / distance * forward end
        group.height = impact.muzzleHeight
        group.rays[1] = {id = record.id, shot = tostring(record.shots) .. ":primary", x = impact.x, y = impact.y, z = impact.z,
            fromX = group.fromX, fromY = group.fromY, muzzleHeight = group.height, firearm = true, missed = impact.missed}
        impact.deferVisual = true
    end
    local damage = options.damage * (options.critical and options.critMultiplier or 1) * stats.splitterDamage
    for i = 1, stats.splitter do
        V.ray(record, x, y, origin:getZ(), angle + math.rad(V.angle(stats.splitter, i, side)), stats.range, damage, group, i)
    end
    V.done(options)
end

---@param record table Shot identity
---@param x number Impact X captured before damage
---@param y number Impact Y captured before damage
---@param z number Impact floor
---@param target IsoZombie Origin victim, including a killed victim
---@param player IsoPlayer? Operator
---@param options table Primary snapshot
---@return nil
function V.fragment(record, x, y, z, target, player, options)
    if not options.fragmentReserved then return end
    options.fragmentReserved = nil
    local stats = options.stats
    local owner = options.root or options
    local group = {options = owner, kind = "fragment", player = player, weapon = options.effectWeapon, stats = stats, hits = {}, remaining = 5, rays = {}, height = .30}
    if target then group.hits[target] = true end
    group.due = Clock.now() + 250
    local rotation = ZombRand(36000) / 100
    local damage = options.damage * (options.critical and options.critMultiplier or 1) * stats.fragmentDamage
    for i = 1, 5 do
        local angle = math.rad(rotation + (i - 1) * 72 + ZombRand(4201) / 100 - 21)
        V.ray(record, x, y, z, angle, stats.fragmentRange, damage, group, i)
    end
end

---@param record table Committed primary identity
---@param origin IsoGridSquare Muzzle square
---@param target IsoZombie First primary hit
---@param player IsoPlayer? Operator
---@param options table Committed shot snapshot
---@param square IsoGridSquare Victim square captured before damage
---@param hitX number Victim X captured before damage
---@param hitY number Victim Y captured before damage
---@return nil
function V.pierce(record, origin, target, player, options, square, hitX, hitY)
    if not options.pierceReserved then return end
    options.pierceReserved = nil
    local stats = options.stats
    local x, y = origin:getX() + .5, origin:getY() + .5
    local dx, dy = hitX - x, hitY - y
    local distance = math.sqrt(dx * dx + dy * dy)
    if distance <= 0 or distance >= stats.range then return end
    local group = {options = options, kind = "piercing", player = player, weapon = options.weapon, stats = stats,
        hits = {[target] = true}, left = stats.piercing, fromX = hitX, fromY = hitY}
    local damage = options.damage * (options.critical and options.critMultiplier or 1) * stats.pierceRetention
    V.ray(record, x, y, origin:getZ(), math.atan2(dy, dx), stats.range, damage, group, 1)
    local ray = V.queue[#V.queue]
    ray.distance, ray.minimum, ray.square, ray.scanning = distance, distance, square, true
    return true
end

---@param ray table Committed ray
---@return nil
function V.finish(ray)
    local victim, group = ray.best, ray.group
    local hit = false
    if victim and not victim:isDead() and Horde.allowed(victim) and victim:getSquare() == ray.square
        and getCell():getGridSquare(ray.square:getX(), ray.square:getY(), ray.z) == ray.square
        and math.abs((victim:getX() - ray.x) * ray.dy - (victim:getY() - ray.y) * ray.dx) <= math.max(.2, victim:getWidth())
        and (victim:getX() - ray.x) * ray.dx + (victim:getY() - ray.y) * ray.dy >= 0
        and (victim:getX() - ray.x) * ray.dx + (victim:getY() - ray.y) * ray.dy <= ray.range
        and (group.kind == "splitter" or not V.seen(group, victim)) then
        local chance = 100
        if group.stats.headKind == "Ballista" then
            chance = require("OMHTT/TurretHeads").accuracy(group.stats, ray.bestDistance)
        elseif group.stats.firearm then
            chance = require("OMHTT/FirearmAccuracy").chance(group.weapon, group.stats, ray.bestDistance, victim:isProne())
        end
        if ZombRand(10000) < chance * 100 then
            if group.kind ~= "splitter" then group.hits[victim] = true end
            local owner = group.options
            local x, y, square = victim:getX(), victim:getY(), victim:getSquare()
            local amount = ray.damage
            if group.stats.synergy then amount = Conditional.damage(victim, amount, Conditional.snapshot(victim, group.stats)) end
            hit = require("OMHTT/TurretHit").resolve(victim, amount, ray.id, group.kind, owner, function()
                if group.stats.synergy and owner then
                    local record = {id = ray.id, shots = ray.shot}
                    Proc.hit(victim, true, x, y, ray.z, record, group.player, owner)
                    Conditional.impact(victim, square, owner)
                end
            end)
        end
    end
    local distance = ray.bestDistance or math.min(ray.distance, ray.range)
    local facts = {id = ray.id, shot = ray.shot,
        x = ray.x + ray.dx * distance, y = ray.y + ray.dy * distance, z = ray.z,
        fromX = group.fromX or ray.x, fromY = group.fromY or ray.y, muzzleHeight = group.height, firearm = true, missed = not hit, silent = true}
    if group.remaining then
        group.rays[#group.rays + 1] = facts
        group.remaining = group.remaining - 1
        if group.remaining == 0 then require("OMHTT/DefenseEffects").emit("Volley", {rays = group.rays}) end
    else
        require("OMHTT/DefenseEffects").emit("Ray", facts)
    end
    if group.kind == "piercing" and victim then
        group.hits[victim] = true
        if hit then
            group.left = group.left - 1
        end
        if group.left > 0 and ray.distance < ray.range and ray.square then
            if hit then ray.damage = ray.damage * group.stats.pierceRetention end
            group.fromX, group.fromY = facts.x, facts.y
            ray.minimum = math.max(ray.minimum, distance)
            ray.best, ray.bestDistance, ray.scanning, ray.objectIndex = nil, nil, true, 0
            return true
        end
    end
    if group.options and group.stats.fragment > 0 and group.kind ~= "fragment"
        and (group.kind == "piercing" or group.kind == "terminal" or group.stats.synergy) then
        V.fragment({id = ray.id, shots = ray.shot}, facts.x, facts.y, ray.z, victim, group.player,
            {root = group.options, stats = group.stats, effectWeapon = group.weapon,
                damage = ray.damage, critical = false, fragmentReserved = 5})
    end
    if group.options then V.done(group.options) end
    return false
end

---@param ray table Incremental ray state
---@return boolean done Ray reached a victim, obstruction or range limit
function V.step(ray)
    if ray.scanning then
        local objects = ray.square:getMovingObjects()
        if ray.objectIndex < objects:size() then
            local candidate = objects:get(ray.objectIndex)
            ray.objectIndex = ray.objectIndex + 1
            if ray.group.kind ~= "terminal" and instanceof(candidate, "IsoZombie") and not candidate:isDead() and candidate:getSquare() == ray.square
                and (ray.group.kind == "splitter" or not V.seen(ray.group, candidate)) then
                local x, y = candidate:getX() - ray.x, candidate:getY() - ray.y
                local along = x * ray.dx + y * ray.dy
                local across = math.abs(x * ray.dy - y * ray.dx)
                if along >= (ray.minimum or 0) and along <= ray.range and across <= math.max(.2, candidate:getWidth())
                    and (not ray.bestDistance or along < ray.bestDistance) then
                    ray.best, ray.bestDistance = candidate, along
                end
            end
            return false
        end
        ray.scanning = false
        if ray.best then return true end
    end
    if ray.distance >= ray.range then return true end
    ray.distance = math.min(ray.range, ray.distance + .25)
    local square = getCell():getGridSquare(math.floor(ray.x + ray.dx * ray.distance), math.floor(ray.y + ray.dy * ray.distance), ray.z)
    if not square then return true end
    if square ~= ray.square then
        local previous = ray.square or getCell():getGridSquare(math.floor(ray.x), math.floor(ray.y), ray.z)
        if not previous or not require("OMHTT/PrototypeCombat").clearLane(previous, square, 2) then
            ray.distance = math.max(0, ray.distance - .25)
            return true
        end
        ray.square, ray.objectIndex, ray.scanning = square, 0, true
    end
    return false
end

---@return nil
function V.tick()
    local deadline, now = Budget.limit(1), Clock.now()
    local waiting = 0
    for _ = 1, 128 do
        if #V.queue == 0 or waiting >= #V.queue or getTimestampMs() >= deadline then break end
        if V.cursor > #V.queue then V.cursor = 1 end
        local ray = V.queue[V.cursor]
        local group = ray.group
        if group.due and now < group.due then
            waiting, V.cursor = waiting + 1, V.cursor + 1
        else
            waiting = 0
            if group.kind == "fragment" and not group.sounded then
                group.sounded = true
                Proc.sound("OMHTTSuppressedM9Shoot", ray)
            end
            local origin = getCell():getGridSquare(math.floor(ray.x), math.floor(ray.y), ray.z)
            local complete = false
            if not origin or V.step(ray) then
                if not origin then ray.best, ray.bestDistance, ray.distance = nil, nil, 0 end
                complete = not V.finish(ray)
            end
            if complete then
                V.queue[V.cursor] = V.queue[#V.queue]
                V.queue[#V.queue] = nil
            else
                V.cursor = V.cursor + 1
            end
        end
    end
end

---@param group table Persistent lineage
---@param actor IsoZombie Candidate
---@return boolean seen
function V.seen(group, actor)
    if group.hits[actor] then return true end
    local saved = actor:getModData().OMHTTSavedRayHits
    if saved and saved[group.persistId] then
        group.hits[actor] = true
        return true
    end
    return false
end

---@param record table Shot identity
---@param origin IsoGridSquare Muzzle
---@param target IsoZombie Aim point
---@param player IsoPlayer? Operator
---@param options table Admitted shot
---@param targetX number? Original projectile aim X
---@param targetY number? Original projectile aim Y
---@return nil
function V.miss(record, origin, target, player, options, targetX, targetY)
    if not options.fragmentReserved then return end
    options.fragmentReserved = nil
    local x, y = origin:getX() + .5, origin:getY() + .5
    local group = {options = options, kind = "terminal", player = player, weapon = options.weapon, stats = options.stats, hits = {}}
    V.ray(record, x, y, origin:getZ(), math.atan2((targetY or target:getY()) - y, (targetX or target:getX()) - x), options.stats.range,
        options.damage * (options.critical and options.critMultiplier or 1), group, 1)
end

---@return nil
function V.save()
    local data, now = ModData.getOrCreate("OMHTTVolley"), Clock.now()
    data.serial, data.rays, data.groups, data.owners = V.serial, {}, {}, {}
    local groups, owners, live = {}, {}, {}
    for i = 1, #V.queue do live[V.queue[i].group.persistId] = true end
    for i = 1, #V.queue do
        local ray, saved = V.queue[i], {}
        local group, owner = ray.group, ray.group.options
        for key, value in pairs(ray) do
            if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then saved[key] = value end
        end
        saved.scanning, saved.objectIndex, saved.bestDistance = ray.square ~= nil, 0, nil
        if ray.square then saved.squareX, saved.squareY = ray.square:getX(), ray.square:getY() end
        if not owners[owner] then
            owners[owner] = #data.owners + 1
            data.owners[owners[owner]] = {stats = owner.stats, rayBudget = owner.rayBudget, procJobs = owner.procJobs,
                procFields = owner.procFields, impactReady = owner.impactReady}
        end
        if not groups[group] then
            groups[group] = #data.groups + 1
            local copy = {stats = group.stats, owner = owners[owner], rays = group.rays, delay = math.max(0, (group.due or now) - now)}
            for key, value in pairs(group) do
                if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then copy[key] = value end
            end
            for actor in pairs(group.hits) do
                local marks, kept = actor:getModData().OMHTTSavedRayHits, {}
                if marks then for id in pairs(marks) do if live[id] then kept[id] = true end end end
                kept[group.persistId] = true
                actor:getModData().OMHTTSavedRayHits = kept
            end
            data.groups[groups[group]] = copy
        end
        saved.group = groups[group]
        data.rays[i] = saved
    end
end

---@return nil
function V.load()
    V.reset()
    local data, now = ModData.getOrCreate("OMHTTVolley"), Clock.now()
    V.serial = data.serial or 0
    local owners, groups = {}, {}
    for i = 1, #(data.owners or {}) do
        local owner = data.owners[i]
        owner.pending, owner.primaryDone = 0, true
        owners[i] = owner
        V.reserved = V.reserved + owner.rayBudget
        Proc.reservedJobs = Proc.reservedJobs + owner.procJobs
        Proc.reservedFields = Proc.reservedFields + owner.procFields
    end
    for i = 1, #(data.groups or {}) do
        local group = data.groups[i]
        group.options, group.hits, group.due = owners[group.owner], {}, now + group.delay
        groups[i] = group
    end
    for i = 1, #(data.rays or {}) do
        local ray = data.rays[i]
        ray.group = groups[ray.group]
        if ray.squareX then ray.square = getCell():getGridSquare(ray.squareX, ray.squareY, ray.z) end
        if not ray.square then ray.scanning = false end
        ray.group.options.pending = ray.group.options.pending + 1
        V.queue[#V.queue + 1] = ray
    end
end

---@return nil
function V.reset()
    V.queue, V.reserved, V.cursor = {}, 0, 1
end

Budget.register("TurretVolley.tick", V.tick)
Events.OnGameStart.Add(V.load)
Events.OnServerStarted.Add(V.load)
Events.OnSave.Add(V.save)
return V
