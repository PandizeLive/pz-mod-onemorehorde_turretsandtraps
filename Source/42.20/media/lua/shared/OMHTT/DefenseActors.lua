-- Native MP square membership follows prediction; combat uses real coordinates.
local A = {buckets = {}, bucketOrder = {}, nodes = {}, order = {}, cleanup = 1, cursor = 0, due = 0, generation = 1, listeners = {}}
local F = require("OMHTT/Foundation")
local WIDTH = 8

function A.square(actor)
    if not actor or not actor:getSquare() then return nil end
    if not isServer() then return actor:getSquare() end
    return getCell():getGridSquare(math.floor(actor:getX()), math.floor(actor:getY()), math.floor(actor:getZ()))
end

function A.key(x, y, z)
    return F.key(math.floor(x / WIDTH), math.floor(y / WIDTH), math.floor(z))
end

function A.remove(actor)
    local node = A.nodes[actor]
    if not node then return end
    local bucket = A.buckets[node.key]
    local last = bucket[#bucket]
    bucket[node.index] = last
    bucket[#bucket] = nil
    if last ~= node then last.index = node.index end
    if #bucket == 0 then
        local tail = A.bucketOrder[#A.bucketOrder]
        A.bucketOrder[bucket.slot] = tail
        A.bucketOrder[#A.bucketOrder] = nil
        if tail ~= bucket then tail.slot = bucket.slot end
        A.buckets[node.key] = nil
    end
    local tail = A.order[#A.order]
    A.order[node.slot] = tail
    A.order[#A.order] = nil
    if tail ~= node then tail.slot = node.slot end
    A.nodes[actor] = nil
end

function A.observe(actor, initializing)
    if isClient() then return end
    if actor:isDead() or not A.square(actor) then A.remove(actor); return end
    local x, y, z = actor:getX(), actor:getY(), math.floor(actor:getZ())
    local key = A.key(x, y, z)
    local node = A.nodes[actor]
    local previous = node and node.position
    if node and node.key ~= key then A.remove(actor); node = nil end
    if not node then
        local bucket = A.buckets[key]
        if not bucket then
            bucket = {x=math.floor(x/WIDTH), y=math.floor(y/WIDTH), z=z, slot=#A.bucketOrder+1}
            A.buckets[key], A.bucketOrder[bucket.slot] = bucket, bucket
        end
        node = {actor = actor, key = key, index = #bucket + 1, slot = #A.order + 1}
        A.order[node.slot] = node
        bucket[node.index], A.nodes[actor] = node, node
    end
    local now = getTimestampMs()
    node.generation = A.generation
    if initializing then return end
    if not previous or now ~= previous.at or x ~= previous.x or y ~= previous.y or z ~= previous.z then
        local position = {x = x, y = y, z = z, at = now}
        node.position = position
        for i = 1, #A.listeners do A.listeners[i](actor, position, previous) end
    end
end

-- One fair bounded sweep shared by all defenses, independent of their ranges.
function A.refresh()
    local now = getTimestampMs()
    if A.last and now < A.last then A.due, A.cursor = 0, 0 end
    A.last = now
    if A.refreshing or isClient() or now < A.due or GameTime.isGamePaused() then return end
    local cell = getCell()
    if not cell then return end
    local list = cell:getZombieList()
    A.refreshing = true
    local deadline, count = now + 2, 0
    while A.cursor < list:size() and count < 1024 and getTimestampMs() < deadline do
        local actor = list:get(A.cursor)
        A.cursor, count = A.cursor + 1, count + 1
        A.observe(actor)
        if A.cursor > list:size() or list:get(A.cursor - 1) ~= actor then A.cursor = A.cursor - 1 end
    end
    if A.cursor >= list:size() then
        A.cursor, A.generation, A.due = 0, A.generation + 1, now + 50
    end
    for _ = 1, math.min(256, #A.order) do
        if A.cleanup > #A.order then A.cleanup = 1 end
        local node = A.order[A.cleanup]
        if node.generation < A.generation - 1 then A.remove(node.actor)
        else A.cleanup = A.cleanup + 1 end
    end
    A.refreshing = false
end

function A.query(x, y, z, range)
    A.refresh()
    local job = {bucketIndex = 1,
        x1 = math.floor((x - range) / WIDTH), y1 = math.floor((y - range) / WIDTH),
        x2 = math.floor((x + range) / WIDTH), y2 = math.floor((y + range) / WIDTH),
        z = math.floor(z), index = 0}
    job.direct = (job.x2 - job.x1 + 1) * (job.y2 - job.y1 + 1) <= #A.bucketOrder
    job.bx, job.by = job.x1, job.y1
    return job
end

local function advanceBucket(job)
    job.index, job.last = 0, nil
    if job.direct then
        job.bx = job.bx + 1
        if job.bx > job.x2 then job.bx, job.by = job.x1, job.by + 1 end
        if job.by > job.y2 then job.players = 0 end
    else
        job.bucketIndex = job.bucketIndex + 1
    end
end

-- Each call costs one bucket or actor; callers retain their existing budgets.
function A.advance(job)
    if job.done then return nil end
    if job.players ~= nil then
        local list = isServer() and getOnlinePlayers()
        local count = list and list:size() or getNumActivePlayers()
        if job.players >= count then job.done = true; return nil end
        local actor = list and list:get(job.players) or getSpecificPlayer(job.players)
        job.players = job.players + 1
        if actor and not actor:isDead() and A.square(actor) then return actor end
        return nil
    end
    local bucket
    if job.direct then bucket = A.buckets[F.key(job.bx, job.by, job.z)]
    else bucket = A.bucketOrder[job.bucketIndex] end
    if job.bucket and job.bucket ~= bucket then job.index, job.last = 0, nil end
    job.bucket = bucket
    if not bucket then
        if job.direct then advanceBucket(job) else job.players = 0 end
        return nil
    end
    if bucket.z ~= job.z or bucket.x < job.x1 or bucket.x > job.x2 or bucket.y < job.y1 or bucket.y > job.y2 then
        advanceBucket(job)
        return nil
    end
    if job.last and job.index > 0 and (not bucket or bucket[job.index] ~= job.last) then job.index = job.index - 1 end
    job.last = nil
    if bucket and job.index < #bucket then
        job.index = job.index + 1
        job.last = bucket[job.index]
        local actor = bucket[job.index].actor
        if job.last.generation >= A.generation - 1 and not actor:isDead() and A.square(actor) then return actor end
        return nil
    end
    advanceBucket(job)
end

function A.at(square)
    if not isServer() then return square:getMovingObjects() end
    A.refresh()
    local result = {}
    local x, y, z = square:getX(), square:getY(), square:getZ()
    local bucket = A.buckets[A.key(x, y, z)]
    if bucket then
        for i = 1, #bucket do
            local actor = bucket[i].actor
            if bucket[i].generation >= A.generation - 1 and not actor:isDead() and A.square(actor) == square then result[#result + 1] = actor end
        end
    end
    -- Players use the native authoritative list; SP includes local players.
    local players = isServer() and getOnlinePlayers() or square:getMovingObjects()
    for i = 0, players:size() - 1 do
        local actor = players:get(i)
        if instanceof(actor, "IsoPlayer") and not actor:isDead() and A.square(actor) == square then result[#result + 1] = actor end
    end
    function result:size() return #self end
    function result:get(index) return self[index + 1] end
    return result
end

function A.occupants(square, job)
    if not isServer() then return A.at(square) end
    if job.occupancySquare ~= square then
        job.occupancySquare, job.occupancy = square, A.at(square)
    end
    return job.occupancy
end

Events.OnZombieCreate.Add(function(actor) A.remove(actor); A.observe(actor, true) end)
Events.OnZombieDead.Add(A.remove)
Events.OnZombieUpdate.Add(function(actor) if not isServer() then A.observe(actor) end end)
Events.OnTick.Add(A.refresh)
return A
