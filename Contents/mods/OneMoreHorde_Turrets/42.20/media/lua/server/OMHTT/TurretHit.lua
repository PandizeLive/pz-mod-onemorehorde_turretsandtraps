if isClient() then return end
local Damage = require("OMHTT/Damage")
local Hit = {}

---@param zombie IsoZombie Exact victim
---@param amount number Server-calculated native damage
---@param source string Device identity
---@param kind string Projectile/effect family
---@param options table? Root shot reservation
---@param callback function? Confirmed-hit effects; receives actual loss
---@return boolean admitted
function Hit.resolve(zombie, amount, source, kind, options, callback)
    local held = options and options.pending ~= nil
    if held then options.pending = options.pending + 1 end
    return Damage.resolve(zombie, amount, source, kind, function(lost)
        if lost > 0 and callback then callback(lost) end
        if held then require("OMHTT/TurretVolley").done(options) end
    end)
end

return Hit
