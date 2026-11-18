if isServer() then return end
local B = require("OMHTT/BedSpikes")
local F = require("OMHTT/Foundation")
local Barbs = require("OMHTT/BarbSections")
local P = require("OMHTT/ContactPlayer")
P.trapsRegistered = true
P.barbs = Barbs
if isClient() then
    ---@param object IsoObject Newly streamed object awaiting its mod data
    ---@return boolean ready Passive trap view is now indexed
    require("OMHTT/ControlDiscovery").providers.traps = function(object)
        if not object:hasModData() or not object:getSquare() then return false end
        local data = object:getModData()
        if data.OMHTTBed then
            B.loaded(object:getSquare())
            return B.record(object) ~= nil
        elseif data.OMHTTBarbFrame then
            Barbs.loaded(object:getSquare())
            return Barbs.record(object) ~= nil
        end
        return false
    end
    require("OMHTT/DefenseContactClient").checks.traps=function(zombie)
        local key=F.key(math.floor(zombie:getX()),math.floor(zombie:getY()),math.floor(zombie:getZ()))
        return B.nearby[key]~=nil or Barbs.nearby[key]~=nil
    end
end
require("OMHTT/DefenseMotion").checks.traps = function(zombie, source)
    local barb = Barbs.contact(zombie)
    if barb and (source == nil or barb.id == source) then
        return Barbs.option("MovementDivisor", 2, 1, 10)
    end
    return nil
end

---@param player IsoPlayer Updated player
---@return nil
function B.player(player)
    if isClient() and not player:isLocalPlayer() then return end
    local square = player:getSquare()
    local id = B.enabled() and square and B.tiles[F.key(square:getX(), square:getY(), square:getZ())] or nil
    local barb = Barbs.contact(player)
    local divisor = Barbs.option("MovementDivisor", 2, 1, 10)
    if not barb and P.tackContact then barb, divisor = P.tackContact(player), 2 end
    local poke
    if square then
        local objects = square:getSpecialObjects()
        for i = 0, objects:size() - 1 do
            local state = require("OMHTT/ControlAccess").state(objects:get(i))
            if state and state.kind == "Poke" then poke = state.id; break end
        end
    end
    P.update(player, id, barb, divisor,
        B.option("SprintTripChance", 20, 0, 100), B.option("ScratchChance", 20, 0, 100), poke)
end

Events.OnPlayerUpdate.Add(B.player)
