if isServer() then return end

require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")

---@param zombie IsoZombie Damaged local victim
---@param lost number Actual health loss
---@param source string Device identity
---@param kind string Damage category
---@return nil
local function showDamage(zombie, lost, source, kind)
    if isClient() or lost <= 0 or kind == "splash" then return end
    local indicator = PixelStrikeIndicator
    if type(indicator) ~= "table" or type(indicator.spawn) ~= "function"
        or type(indicator.Config) ~= "table" then return end
    local config = indicator.Config
    if config.showDamageDealt ~= true or config.showOrdinaryHits ~= true
        or type(config.scale) ~= "number" or config.scale <= 0 then return end
    local player = getSpecificPlayer(0)
    if not player or not zombie:getSquare() or player:getZ() ~= zombie:getSquare():getZ() then return end
    indicator.spawn(zombie, lost * config.scale, "hit", 0)
    Diagnostics.defer("damage-presentation", {id = source, kind = kind, integration = "PixelStrikeIndicator",
        actualDamage = lost, scale = config.scale, displayValue = lost * config.scale})
end

Events.OnOMHTTDamage.Add(showDamage)

---@param module string Namespace
---@param command string Presentation event
---@param facts table Server-confirmed loss and captured position
---@return nil
local function receive(module, command, facts)
    if not isClient() or module ~= "OMHTT_DamageView" or command ~= "Hit" or type(facts) ~= "table" then return end
    local protocol = require("OMHTT/DefenseCombatProtocol")
    if not protocol.number(facts.x, -1000000, 1000000) or not protocol.number(facts.y, -1000000, 1000000)
        or not protocol.number(facts.z, -32, 32) or not protocol.number(facts.lost, .000001, 1000000)
        or not protocol.number(facts.packet, 1, 1000000000000) then return end
    if not require("OMHTT/DefenseEffects").accept(facts) then return end
    local indicator = PixelStrikeIndicator
    if type(indicator) ~= "table" or type(indicator.spawnAt) ~= "function" or type(indicator.Config) ~= "table" then return end
    local config = indicator.Config
    if config.showDamageDealt ~= true or config.showOrdinaryHits ~= true
        or type(config.scale) ~= "number" or config.scale <= 0 then return end
    local square = getCell():getGridSquare(math.floor(facts.x), math.floor(facts.y), math.floor(facts.z))
    if not square then return end
    for i = 0, getNumActivePlayers() - 1 do
        local player = getSpecificPlayer(i)
        if player and math.floor(player:getZ()) == math.floor(facts.z) and square:isCanSee(i)
            and (player:getX() - facts.x) ^ 2 + (player:getY() - facts.y) ^ 2 <= 10000 then
            -- Coordinates survive the native lethal-hit corpse/removal packet order.
            indicator.spawnAt(facts.x, facts.y, facts.z, facts.lost * config.scale, "hit", i)
        end
    end
end

Events.OnServerCommand.Add(receive)
