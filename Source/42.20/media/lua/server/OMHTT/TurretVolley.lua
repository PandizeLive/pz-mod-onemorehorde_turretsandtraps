if isClient() or isServer() then return end
local Budget = require("OMHTT/TurretScheduler")
local Damage = require("OMHTT/Damage")
local F = require("OMHTT/Foundation")
local V = {queue = {}, reserved = 0}

---@param stats table Effective modules
---@return boolean available Bounded committed effect capacity
---@nodiscard
function V.available(stats)
    local count = stats.splitter + (stats.fragment > 0 and 5 or 0) + ((stats.piercing or 0) > 0 and 1 or 0)
    return count == 0 or #V.queue + V.reserved + count <= 256
end

---@param options table Committed primary shot
---@return nil
function V.reserve(options)
    if options.stats and (options.stats.piercing or 0) > 0 then
        options.pierceReserved = 1
        V.reserved = V.reserved + 1
    end
    if options.stats and options.stats.fragment > 0 then
        options.fragmentReserved = 5
        V.reserved = V.reserved + 5
    end
end

---@param options table Finished primary shot
---@return nil
function V.release(options)
    if options.pierceReserved then
        V.reserved = math.max(0, V.reserved - options.pierceReserved)
        options.pierceReserved = nil
    end
    if options.fragmentReserved then
        V.reserved = math.max(0, V.reserved - options.fragmentReserved)
        options.fragmentReserved = nil
    end
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
    if stats.splitter == 0 then return end
    local x, y = origin:getX() + .5, origin:getY() + .5
    local angle = math.atan2(target:getY() - y, target:getX() - x)
    local side = record.splitterSide or -1
    if stats.splitter % 2 == 1 then record.splitterSide = -side end
    local group = {kind = "splitter", player = player, weapon = options.effectWeapon, stats = stats, hits = {}, remaining = stats.splitter, rays = {}}
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
    V.reserved = math.max(0, V.reserved - options.fragmentReserved)
    options.fragmentReserved = nil
    local stats = options.stats
    local group = {kind = "fragment", player = player, weapon = options.effectWeapon, stats = stats, hits = {[target] = true}, remaining = 5, rays = {}, height = .30}
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
    V.reserved = math.max(0, V.reserved - options.pierceReserved)
    options.pierceReserved = nil
    local stats = options.stats
    local x, y = origin:getX() + .5, origin:getY() + .5
    local dx, dy = hitX - x, hitY - y
    local distance = math.sqrt(dx * dx + dy * dy)
    if distance <= 0 or distance >= stats.range then return end
    local group = {kind = "piercing", player = player, weapon = options.weapon, stats = stats,
        hits = {[target] = true}, left = stats.piercing, fromX = hitX, fromY = hitY}
    local damage = options.damage * (options.critical and options.critMultiplier or 1) * stats.pierceRetention
    V.ray(record, x, y, origin:getZ(), math.atan2(dy, dx), stats.range, damage, group, 1)
    local ray = V.queue[#V.queue]
    ray.distance, ray.minimum, ray.square, ray.scanning = distance, distance, square, true
end

---@param ray table Committed ray
---@return nil
function V.finish(ray)
    local victim, group = ray.best, ray.group
    local hit = false
    if victim and not victim:isDead() and victim:getSquare() == ray.square
        and getCell():getGridSquare(ray.square:getX(), ray.square:getY(), ray.z) == ray.square
        and math.abs((victim:getX() - ray.x) * ray.dy - (victim:getY() - ray.y) * ray.dx) <= math.max(.2, victim:getWidth())
        and (victim:getX() - ray.x) * ray.dx + (victim:getY() - ray.y) * ray.dy >= 0
        and (victim:getX() - ray.x) * ray.dx + (victim:getY() - ray.y) * ray.dy <= ray.range
        and (group.kind == "splitter" or not group.hits[victim]) then
        local chance = 100
        if group.stats.firearm then
            chance = require("OMHTT/FirearmAccuracy").chance(group.weapon, group.stats, ray.bestDistance, victim:isProne())
        end
        if ZombRand(10000) < chance * 100 then
            if group.kind ~= "splitter" then group.hits[victim] = true end
            hit = Damage.apply(victim, ray.damage, ray.id, group.kind, group.player, group.weapon) > 0
        end
    end
    local distance = ray.bestDistance or math.min(ray.distance, ray.range)
    local facts = {id = ray.id, shot = ray.shot,
        x = ray.x + ray.dx * distance, y = ray.y + ray.dy * distance, z = ray.z,
        fromX = group.fromX or ray.x, fromY = group.fromY or ray.y, muzzleHeight = group.height, firearm = true, missed = not hit, silent = true}
    if group.remaining then
        group.rays[#group.rays + 1] = facts
        group.remaining = group.remaining - 1
        if group.remaining == 0 then triggerEvent("OnServerCommand", F.MODULE, "Volley", {rays = group.rays}) end
    else
        triggerEvent("OnServerCommand", F.MODULE, "Ray", facts)
    end
    if group.kind == "piercing" and victim then
        group.hits[victim] = true
        if hit then
            group.left = group.left - 1
            ray.damage = ray.damage * group.stats.pierceRetention
        end
        if group.left > 0 and ray.distance < ray.range and ray.square then
            group.fromX, group.fromY = facts.x, facts.y
            ray.minimum = math.max(ray.minimum, distance)
            ray.best, ray.bestDistance, ray.scanning, ray.objectIndex = nil, nil, true, 0
            return true
        end
    end
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
            if instanceof(candidate, "IsoZombie") and not candidate:isDead() and candidate:getSquare() == ray.square
                and (ray.group.kind == "splitter" or not ray.group.hits[candidate]) then
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
    local deadline = Budget.limit(1)
    local consumed = 0
    for _ = 1, 128 do
        if consumed >= #V.queue or getTimestampMs() >= deadline then break end
        local ray = V.queue[consumed + 1]
        local origin = getCell():getGridSquare(math.floor(ray.x), math.floor(ray.y), ray.z)
        if not origin or V.step(ray) then
            if not origin then ray.best, ray.bestDistance, ray.distance = nil, nil, 0 end
            if not V.finish(ray) then consumed = consumed + 1 end
        end
    end
    if consumed > 0 then
        local count = #V.queue
        for i = 1, count - consumed do V.queue[i] = V.queue[i + consumed] end
        for i = count - consumed + 1, count do V.queue[i] = nil end
    end
end

---@return nil
function V.reset()
    V.queue, V.reserved = {}, 0
end

Budget.register("TurretVolley.tick", V.tick)
Events.OnGameStart.Add(V.reset)
return V
