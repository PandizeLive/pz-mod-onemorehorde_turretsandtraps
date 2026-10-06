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
