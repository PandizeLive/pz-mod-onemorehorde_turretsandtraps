if isClient() then return end
local F = require("OMHTT/Foundation")
local D = require("OMHTT/Diagnostics")
local C = {handlers = {}, tiles = {}, order = {}, sources = {}, cursor = 1, actor = 0, due = 0}
local seen = setmetatable({}, {__mode = "k"})
local channels = {"bed", "barb", "tack", "control"}

local function detach(tile)
    local index = tile.index
    if not index then return end
    local last = C.order[#C.order]
    C.order[index] = last
    C.order[#C.order] = nil
    if last ~= tile then
        last.index = index
    end
    tile.index = nil
    if C.cursor == index then
        C.actor = 0
    end
end

---@param square IsoGridSquare Newly loaded square
---@return nil
function C.loaded(square)
    if not isServer() then return end
    local tile = C.tiles[F.key(square:getX(), square:getY(), square:getZ())]
    if not tile or tile.index then return end
    tile.index = #C.order + 1
    C.order[tile.index] = tile
    C.due = 0
end

---@param owner any Exact hazard identity
---@return nil
function C.remove(owner)
    local source = C.sources[owner]
    if not source then return end
    C.sources[owner] = nil
    for i = 1, #source.keys do
        local key = source.keys[i]
        local tile = C.tiles[key]
        tile[source.kind] = tile[source.kind] - 1
        tile.count = tile.count - 1
        if tile.count == 0 then
            detach(tile)
            C.tiles[key] = nil
        end
    end
end

---@param kind string Reinitialized hazard family
---@return nil
function C.clear(kind)
    for owner, source in pairs(C.sources) do
        if source.kind == kind then
            C.remove(owner)
        end
    end
end

---@param owner any Exact hazard identity
---@param kind string Contact channel
---@param x1 number Minimum tile X
---@param y1 number Minimum tile Y
---@param x2 number Maximum tile X
---@param y2 number Maximum tile Y
---@param z number Floor
---@return nil
function C.watch(owner, kind, x1, y1, x2, y2, z)
    if not isServer() then return end
    C.remove(owner)
    local source = {kind = kind, keys = {}}
    C.sources[owner] = source
    for x = math.floor(x1), math.floor(x2) do
        for y = math.floor(y1), math.floor(y2) do
            local key = F.key(x, y, z)
            local tile = C.tiles[key]
            if not tile then
                tile = {x = x, y = y, z = z, count = 0}
                C.tiles[key] = tile
            end
            tile[kind] = (tile[kind] or 0) + 1
            tile.count = tile.count + 1
            source.keys[#source.keys + 1] = key
            local square = getCell():getGridSquare(x, y, z)
            if square then
                C.loaded(square)
            end
        end
    end
    C.due = 0
end

---@return nil
function C.tick()
    if not isServer() or #C.order == 0 or GameTime.isGamePaused() then return end
    local now = getTimestampMs()
    if now < C.due then return end
    local deadline, tiles, actors = now + 2, 0, 0
    while tiles < 64 and actors < 256 and getTimestampMs() < deadline do
        if C.cursor > #C.order then
            C.cursor, C.actor, C.due = 1, 0, now + 50
            break
        end
        local tile = C.order[C.cursor]
        local square = getCell():getGridSquare(tile.x, tile.y, tile.z)
        local moving = square and square:getMovingObjects()
        if not square then
            detach(tile)
            tiles = tiles + 1
        elseif C.actor >= moving:size() then
            C.cursor, C.actor, tiles = C.cursor + 1, 0, tiles + 1
        else
            local actor = moving:get(C.actor)
            actors = actors + 1
            if instanceof(actor, "IsoZombie") and not actor:isDead() then
                local previous = seen[actor]
                if not previous or now - previous >= 50 then
                    seen[actor] = now
                    for i = 1, #channels do
                        local kind = channels[i]
                        if (tile[kind] or 0) > 0 and C.handlers[kind] then
                            C.handlers[kind](actor)
                        end
                    end
                end
            end
            if C.order[C.cursor] == tile and C.actor < moving:size() and moving:get(C.actor) == actor then
                C.actor = C.actor + 1
            end
        end
    end
    if actors > 0 then
        D.defer("contact-scan", {actors = actors, tiles = tiles}, "traps")
    end
end

Events.OnTick.Add(C.tick)
Events.LoadGridsquare.Add(C.loaded)
Events.OnZombieCreate.Add(function(zombie) seen[zombie] = nil end)
return C
