if isClient() then return end
local F = require("OMHTT/Foundation")
local D = require("OMHTT/Diagnostics")
local C = {handlers = {}, tiles = {}, sources = {}, count = 0}
local channels = {"bed", "barb", "tack", "control", "poke"}

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
            C.tiles[key] = nil
            C.count = C.count - 1
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
                C.count = C.count + 1
            end
            tile[kind] = (tile[kind] or 0) + 1
            tile.count = tile.count + 1
            source.keys[#source.keys + 1] = key
        end
    end
end

local Actors = require("OMHTT/DefenseActors")

function C.contact(actor, position, crossed, ownerReport)
    if not isServer() or not require("OMHTT/DefenseCombatProtocol").living(actor) then return end
    local tile = C.tiles[F.key(math.floor(position.x), math.floor(position.y), position.z)]
    if not tile then return end
    for i = 1, #channels do
        local kind = channels[i]
        if (ownerReport or not actor:getOwner() or kind == "control") and (not crossed or kind == "poke" or kind == "barb" or kind == "tack")
            and (tile[kind] or 0) > 0 and C.handlers[kind] then C.handlers[kind](actor, position) end
    end
    D.count("contact-observed", 1, "traps")
end

-- Interpolate only short, recent, unobstructed native movement. Never replay a
-- teleport, a floor change, an old packet gap or a landing at an invented tile.
function C.observe(actor, position, previous, ownerReport)
    if C.count == 0 then return end
    C.contact(actor, position, false, ownerReport)
    if not previous or previous.z ~= position.z or position.at - previous.at > 250 then return end
    local dx, dy = position.x - previous.x, position.y - previous.y
    local distance = math.sqrt(dx * dx + dy * dy)
    if distance <= .2 or distance > 2 then return end
    local steps, seen, crossing = math.ceil(distance / .2), {}, {}
    seen[F.key(math.floor(position.x), math.floor(position.y), position.z)] = true
    for i = 0, steps - 1 do
        local sample = {x=previous.x + dx*i/steps, y=previous.y + dy*i/steps, z=position.z, at=position.at}
        local key = F.key(math.floor(sample.x), math.floor(sample.y), sample.z)
        if not seen[key] then
            seen[key] = true
            if C.tiles[key] then crossing[#crossing + 1] = sample end
        end
    end
    if #crossing == 0 then return end
    local from = getCell():getGridSquare(math.floor(previous.x), math.floor(previous.y), previous.z)
    local to = getCell():getGridSquare(math.floor(position.x), math.floor(position.y), position.z)
    if not require("OMHTT/DefenseLine").clear(from, to, 3) then
        D.count("contact-crossing-blocked", 1, "traps")
        return
    end
    for i = 1, #crossing do C.contact(actor, crossing[i], true, ownerReport) end
end

Actors.listeners[#Actors.listeners + 1] = C.observe
return C
