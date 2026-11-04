if isServer() then return end
local Line = require("OMHTT/DefenseLine")
local F = require("OMHTT/Foundation")
local V = {fields = {}, fieldOrder = {}, fieldCount = 0, buckets = {}}
local Clock = require("OMHTT/TurretClock")
local watched = setmetatable({}, {__mode = "k"})
local nextPrune, cursor = 0, 1

---@param field table Server-owned field view
---@param add boolean Index or remove
---@return nil
function V.index(field, add)
    for x = math.floor((field.x - field.radius - 2) / 8), math.floor((field.x + field.radius + 2) / 8) do
        for y = math.floor((field.y - field.radius - 2) / 8), math.floor((field.y + field.radius + 2) / 8) do
            local key = F.key(x, y, field.z)
            local bucket = V.buckets[key]
            if add then
                if not bucket then bucket = {}; V.buckets[key] = bucket end
                bucket[field.id] = field
            elseif bucket then
                bucket[field.id] = nil
                local empty = true
                for _ in pairs(bucket) do empty = false; break end
                if empty then V.buckets[key] = nil end
            end
        end
    end
end

---@param id string Field identity
---@return nil
function V.remove(id)
    local old = V.fields[id]
    if not old then return end
    V.index(old, false)
    V.fields[id] = nil
    for i = 1, #V.fieldOrder do
        if V.fieldOrder[i] == old then
            table.remove(V.fieldOrder, i)
            break
        end
    end
    V.fieldCount = V.fieldCount - 1
end

---@param module string Network namespace
---@param command string Upsert/remove
---@param fields table Server snapshots with relative durations
---@return nil
function V.receive(module, command, fields)
    if not isClient() or module ~= "OMHTT_TackView" or type(fields) ~= "table" then return end
    if command == "Remove" then V.remove(fields.id); return end
    if command ~= "Fields" then return end
    local now = require("OMHTT/TurretClock").now()
    for i = 1, math.min(32, #fields) do
        local field = fields[i]
        V.remove(field.id)
        if V.fieldCount < 512 and field.remaining > 0 then
            field.starts, field.expires = now + field.startsIn, now + field.remaining
            V.fields[field.id] = field
            V.fieldOrder[#V.fieldOrder + 1] = field
            V.fieldCount = V.fieldCount + 1
            V.index(field, true)
        end
    end
end

---@param actor IsoGameCharacter Local contact candidate
---@return table? field Active contact, using the same wall checks as server combat
function V.contact(actor)
    local square = actor:getSquare()
    if not square or actor:isDead() then return nil end
    local bucket = V.buckets[F.key(math.floor(actor:getX() / 8), math.floor(actor:getY() / 8), square:getZ())]
    if not bucket then return nil end
    local now = require("OMHTT/TurretClock").now()
    for _, field in pairs(bucket) do
        local dx, dy = actor:getX() - field.x, actor:getY() - field.y
        if now >= field.starts and now < field.expires and dx * dx + dy * dy <= field.radius * field.radius then
            local origin = getCell():getGridSquare(math.floor(field.x), math.floor(field.y), field.z)
            if Line.clear(origin, square, field.radius + 2) then return field end
        end
    end
end

---@return nil
function V.start()
    if not isClient() then return end
    local player = getSpecificPlayer(0)
    if player then
        V.update(player)
    end
end

---@param player IsoPlayer Local player entering another area
---@return nil
function V.update(player)
    if not isClient() or not player:isLocalPlayer() then return end
    local wall = getTimestampMs()
    local old = watched[player]
    local x, y = math.floor(player:getX() / 40), math.floor(player:getY() / 40)
    if not old or (wall >= old.due and (old.x ~= x or old.y ~= y)) then
        watched[player] = {x = x, y = y, due = wall + 5000}
        sendClientCommand(player, "OMHTT_TackView", "Request", {})
    end
    local now = Clock.now()
    if now < nextPrune then return end
    nextPrune = now + 250
    for _ = 1, math.min(32, #V.fieldOrder) do
        if cursor > #V.fieldOrder then cursor = 1 end
        local field = V.fieldOrder[cursor]
        if not field then break end
        if now >= field.expires then
            V.remove(field.id)
        else
            cursor = cursor + 1
        end
    end
end

Events.OnServerCommand.Add(V.receive)
Events.OnGameStart.Add(V.start)
Events.OnPlayerUpdate.Add(V.update)
return V
