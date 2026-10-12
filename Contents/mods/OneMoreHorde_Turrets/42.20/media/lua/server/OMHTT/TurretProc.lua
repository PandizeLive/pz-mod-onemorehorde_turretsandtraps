if isClient() or isServer() then return end
local Clock = require("OMHTT/TurretClock")
local Budget = require("OMHTT/TurretScheduler")
local Damage = require("OMHTT/Damage")
local F = require("OMHTT/Foundation")
local E = {jobs = {}, fields = {}, fieldOrder = {}, fieldCursor = 1, buckets = {}, reservedJobs = 0, reservedFields = 0, fieldCount = 0,
    serial = 0, injuryAt = {}, maxMs = 0, maxAge = 0, audioAt = 0}

---@param stats table Effective modules
---@return number hits Maximum eligible projectile victims
function E.hits(stats)
    local children = stats.synergy and ((stats.splitter or 0) + (stats.piercing or 0)) or 0
    return 9 + children + (stats.synergy and (stats.fragment or 0) > 0 and 5 * (1 + children) or 0)
end

---@param stats table Snapshot
---@return boolean available Worst-case admission, before resource commit
function E.available(stats)
    local count = E.hits(stats)
    return ((stats.martyrdom or 0) == 0 or #E.jobs + E.reservedJobs + count <= 512)
        and ((stats.tack or 0) == 0 or E.fieldCount + E.reservedFields + count <= 512)
end

---@param options table Shot owner
---@return nil
function E.reserve(options)
    local stats = options.stats
    local count = E.hits(stats)
    options.procJobs = (stats.martyrdom or 0) > 0 and count or 0
    options.procFields = (stats.tack or 0) > 0 and count or 0
    E.reservedJobs = E.reservedJobs + options.procJobs
    E.reservedFields = E.reservedFields + options.procFields
end

---@param options table Completed shot owner
---@return nil
function E.release(options)
    E.reservedJobs = E.reservedJobs - (options.procJobs or 0)
    E.reservedFields = E.reservedFields - (options.procFields or 0)
    options.procJobs, options.procFields = 0, 0
end

---@param field table Field position and radius
---@param add boolean Insert or erase
---@return nil
function E.index(field, add)
    for x = math.floor((field.x - field.radius) / 8), math.floor((field.x + field.radius) / 8) do
        for y = math.floor((field.y - field.radius) / 8), math.floor((field.y + field.radius) / 8) do
            local key = F.key(x, y, field.z)
            local bucket = E.buckets[key]
            if add then
                if not bucket then bucket = {}; E.buckets[key] = bucket end
                bucket[field.id] = field
            elseif bucket then
                bucket[field.id] = nil
                local empty = true
                for _ in pairs(bucket) do empty = false; break end
                if empty then E.buckets[key] = nil end
            end
        end
    end
end

---@param origin IsoGridSquare Effect origin
---@param actor IsoGameCharacter Candidate
---@param x number Center X
---@param y number Center Y
---@param radius number Tiles
---@return boolean eligible Same floor, circle and clear line
function E.inside(origin, actor, x, y, radius)
    local square = actor:getSquare()
    if not origin or not square or actor:isDead() or square:getZ() ~= origin:getZ() then return false end
    local dx, dy = actor:getX() - x, actor:getY() - y
    return dx * dx + dy * dy <= radius * radius
        and require("OMHTT/PrototypeCombat").clearLane(origin, square, radius + 2)
end

---@param actor IsoGameCharacter Updated actor
---@return table? field First valid local contact; overlaps cannot stack
function E.contact(actor)
    if E.fieldCount == 0 then return nil end
    local square = actor:getSquare()
    if not square then return nil end
    local bucket = E.buckets[F.key(math.floor(actor:getX() / 8), math.floor(actor:getY() / 8), square:getZ())]
    if not bucket then return nil end
    local now = Clock.now()
    for _, field in pairs(bucket) do
        local dx, dy = actor:getX() - field.x, actor:getY() - field.y
        if now < field.expires and dx * dx + dy * dy <= field.radius * field.radius then
            local origin = getCell():getGridSquare(math.floor(field.x), math.floor(field.y), field.z)
            if E.inside(origin, actor, field.x, field.y, field.radius) then return field end
        end
    end
    return nil
end

---@param zombie IsoZombie Damaged victim (position captured before death)
---@param alive boolean Alive before damage
---@param x number Pre-hit position
---@param y number Pre-hit position
---@param z number Floor
---@param record table Source ID and shot
---@param player IsoPlayer? Actual operator
---@param options table Root admitted shot
---@return nil
function E.hit(zombie, alive, x, y, z, record, player, options)
    if not alive or not options.procJobs then return end
    local stats, now = options.stats, Clock.now()
    if stats.tack > 0 then
        local data = zombie:getModData()
        local previous = E.fields[data.OMHTTTackField]
        if not previous or now >= previous.expires then
            if options.procFields <= 0 then error("Tack admission exhausted") end
            options.procFields, E.reservedFields = options.procFields - 1, E.reservedFields - 1
            E.serial = E.serial + 1
            local field = {id = tostring(E.serial), x = x, y = y, z = z, radius = stats.tack,
                damage = stats.tackDamage, expires = now + stats.tackLifetime, source = record.id}
            E.fields[field.id], data.OMHTTTackField = field, field.id
            E.fieldOrder[#E.fieldOrder + 1] = field
            E.fieldCount = E.fieldCount + 1
            E.index(field, true)
        end
    end
    if stats.martyrdom > 0 and zombie:isDead() then
        if options.procJobs <= 0 then error("Martyrdom admission exhausted") end
        options.procJobs, E.reservedJobs = options.procJobs - 1, E.reservedJobs - 1
        E.serial = E.serial + 1
        E.jobs[#E.jobs + 1] = {id = tostring(E.serial), x = x, y = y, z = z, radius = stats.martyrdom, damage = stats.martyrdomDamage,
            source = record.id, player = player, weapon = options.effectWeapon, seen = {}, queuedAt = now,
            dx = -math.ceil(stats.martyrdom), dy = -math.ceil(stats.martyrdom), index = 0}
        addSound(zombie, math.floor(x), math.floor(y), z, 20, 20)
        if now >= E.audioAt then
            triggerEvent("OnServerCommand", F.MODULE, "Impact", {id = record.id, shot = "martyrdom:" .. E.serial,
                x = x, y = y, z = z, fromX = x, fromY = y})
            E.audioAt = now + 100
        end
    end
end

---@param player IsoPlayer Nearby player
---@return nil
function E.injure(player)
    if player:isDead() or player:isGodMod() or player:isNoClip() or player:isGhostMode() then return end
    local index, now = player:getPlayerNum(), Clock.now()
    if E.injuryAt[index] and now < E.injuryAt[index] then return end
    E.injuryAt[index] = now + 1000
    local limbs = {BodyPartType.ForeArm_L, BodyPartType.ForeArm_R, BodyPartType.LowerLeg_L, BodyPartType.LowerLeg_R}
    local part = player:getBodyDamage():getBodyPart(limbs[ZombRand(4) + 1])
    part:AddDamage(2)
    part:setAdditionalPain(math.min(100, part:getAdditionalPain() + 5))
end

---@param job table Incremental terminal burst
---@return boolean complete
function E.step(job)
    local radius = math.ceil(job.radius)
    if job.dy > radius then return true end
    local origin = getCell():getGridSquare(math.floor(job.x), math.floor(job.y), job.z)
    if not origin then return true end
    local square = getCell():getGridSquare(math.floor(job.x) + job.dx, math.floor(job.y) + job.dy, job.z)
    local moving = square and square:getMovingObjects()
    if moving and job.index < moving:size() then
        local actor = moving:get(job.index)
        job.index = job.index + 1
        if (instanceof(actor, "IsoZombie") or instanceof(actor, "IsoPlayer")) and not job.seen[actor]
            and (not job.id or actor:getModData().OMHTTBurstSeen ~= job.id)
            and E.inside(origin, actor, job.x, job.y, job.radius) then
            job.seen[actor] = true
            actor:getModData().OMHTTBurstSeen = job.id
            if instanceof(actor, "IsoPlayer") then
                E.injure(actor)
            else
                Damage.apply(actor, job.damage / 100, job.source, "martyrdom", job.player, job.weapon)
            end
        end
        if job.index > moving:size() or moving:get(job.index - 1) ~= actor then job.index = job.index - 1 end
    else
        job.index, job.dx = 0, job.dx + 1
        if job.dx > radius then job.dx, job.dy = -radius, job.dy + 1 end
    end
    return false
end

---@return nil
function E.tick()
    local start, now, deadline = getTimestampMs(), Clock.now(), Budget.limit(1)
    for _ = 1, 8 do
        if #E.fieldOrder == 0 or getTimestampMs() >= deadline then break end
        if E.fieldCursor > #E.fieldOrder then E.fieldCursor = 1 end
        local field = E.fieldOrder[E.fieldCursor]
        if now >= field.expires then
            E.index(field, false)
            E.fields[field.id], E.fieldCount = nil, E.fieldCount - 1
            E.fieldOrder[E.fieldCursor] = E.fieldOrder[#E.fieldOrder]
            E.fieldOrder[#E.fieldOrder] = nil
        else
            E.fieldCursor = E.fieldCursor + 1
        end
    end
    local consumed = 0
    for _ = 1, 64 do
        if consumed >= #E.jobs or getTimestampMs() >= deadline then break end
        local job = E.jobs[consumed + 1]
        E.maxAge = math.max(E.maxAge, now - job.queuedAt)
        if E.step(job) then consumed = consumed + 1 end
    end
    if consumed > 0 then
        local count = #E.jobs
        for i = 1, count - consumed do E.jobs[i] = E.jobs[i + consumed] end
        for i = count - consumed + 1, count do E.jobs[i] = nil end
    end
    E.maxMs = math.max(E.maxMs, getTimestampMs() - start)
end

---@return nil
function E.save()
    local data, now = ModData.getOrCreate("OMHTTTack"), Clock.now()
    data.serial, data.fields = E.serial, {}
    for _, field in pairs(E.fields) do
        if field.expires > now then
            data.fields[#data.fields + 1] = {id = field.id, x = field.x, y = field.y, z = field.z,
                radius = field.radius, damage = field.damage, remaining = field.expires - now, source = field.source}
        end
    end
    data.jobs = {}
    for i = 1, #E.jobs do
        local job = E.jobs[i]
        data.jobs[i] = {id = job.id, x = job.x, y = job.y, z = job.z, radius = job.radius,
            damage = job.damage, source = job.source}
    end
    data.injury = {}
    for index, expires in pairs(E.injuryAt) do
        if expires > now then data.injury[index] = expires - now end
    end
end

---@return nil
function E.load()
    E.jobs, E.fields, E.buckets, E.injuryAt, E.fieldOrder, E.fieldCursor = {}, {}, {}, {}, {}, 1
    E.reservedJobs, E.reservedFields, E.fieldCount = 0, 0, 0
    local data, now = ModData.getOrCreate("OMHTTTack"), Clock.now()
    E.serial = data.serial or 0
    for index, remaining in pairs(data.injury or {}) do E.injuryAt[index] = now + math.min(1000, remaining) end
    for i = 1, #(data.fields or {}) do
        local field = data.fields[i]
        field.expires = now + field.remaining
        E.fields[field.id], E.fieldCount = field, E.fieldCount + 1
        E.fieldOrder[#E.fieldOrder + 1] = field
        E.index(field, true)
    end
    for i = 1, #(data.jobs or {}) do
        local job = data.jobs[i]
        job.dx, job.dy, job.index, job.seen, job.queuedAt = -math.ceil(job.radius), -math.ceil(job.radius), 0, {}, now
        E.jobs[#E.jobs + 1] = job
    end
end

Budget.register("TurretProc.tick", E.tick)
Events.OnSave.Add(E.save)
Events.OnGameStart.Add(E.load)
return E
