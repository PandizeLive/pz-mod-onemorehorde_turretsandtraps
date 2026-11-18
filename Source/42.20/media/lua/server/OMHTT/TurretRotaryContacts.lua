if isClient() then return end
local Actors = require("OMHTT/DefenseActors")
local F = require("OMHTT/Foundation")
local Active = require("OMHTT/ActiveTime")
local I = {tiles = {}, entries = {}}

---@param object IsoObject Removed or changed turret
---@return nil
function I.remove(object)
    local tracked = I.entries[object]
    if not tracked then return end
    for i = 1, #tracked.keys do
        local key = tracked.keys[i]
        local bucket = I.tiles[key]
        bucket.objects[object] = nil
        bucket.count = bucket.count - 1
        if bucket.count == 0 then
            I.tiles[key] = nil
        end
    end
    I.entries[object] = nil
end

---@param entry table Rotary motor owner
---@param range number Resolved head reach
---@return nil
function I.watch(entry, range)
    local object = entry.object
    local square = object:getSquare()
    local old = I.entries[object]
    if old and old.range == range and old.square == square and old.entry == entry then return end
    I.remove(object)
    local tracked = {entry = entry, square = square, range = range, keys = {}}
    I.entries[object] = tracked
    local x, y, z = square:getX() + .5, square:getY() + .5, square:getZ()
    for bx = math.floor((x - range - 2) / 8), math.floor((x + range + 2) / 8) do
        for by = math.floor((y - range - 2) / 8), math.floor((y + range + 2) / 8) do
            local key = F.key(bx, by, z)
            local bucket = I.tiles[key]
            if not bucket then
                bucket = {objects = {}, count = 0}
                I.tiles[key] = bucket
            end
            bucket.objects[object] = entry
            bucket.count = bucket.count + 1
            tracked.keys[#tracked.keys + 1] = key
        end
    end
end

---@param actor IsoGameCharacter Observed actor
---@param position table Fresh position from the shared actor index
---@param previous table? Previous same-owner position
---@param ownerReport boolean? Validated multiplayer observation
---@return nil
function I.observe(actor, position, previous, ownerReport)
    if Active.paused() or (isServer() and instanceof(actor, "IsoZombie") and actor:getOwner() and not ownerReport) then return end
    local bucket = I.tiles[F.key(math.floor(position.x / 8), math.floor(position.y / 8), position.z)]
    if not bucket then return end
    for object, entry in pairs(bucket.objects) do
        if not require("OMHTT/TurretWorld").valid(object) then
            I.remove(object)
        else
            require("OMHTT/TurretRotary").observe(entry, actor, position, previous, ownerReport)
        end
    end
end

---@return nil
function I.players()
    if Active.paused() then return end
    local players = isServer() and getOnlinePlayers()
    local count = players and players:size() or getNumActivePlayers()
    for i = 0, count - 1 do
        local player = players and players:get(i) or getSpecificPlayer(i)
        if player and not player:isDead() then
            I.observe(player, {x = player:getX(), y = player:getY(), z = math.floor(player:getZ()),
                at = GameTime.getServerTimeMills()}, nil, false)
        end
    end
end

Actors.listeners[#Actors.listeners + 1] = I.observe
Events.OnObjectAboutToBeRemoved.Add(I.remove)
Events.OnTick.Add(I.players)
return I
