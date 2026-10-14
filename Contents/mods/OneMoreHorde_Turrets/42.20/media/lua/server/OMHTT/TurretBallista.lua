if isClient() or isServer() then return end
local Heads = require("OMHTT/TurretHeads")
local Damage = require("OMHTT/Damage")
local Conditional = require("OMHTT/TurretConditionalHit")
local Volley = require("OMHTT/TurretVolley")
local Proc = require("OMHTT/TurretProc")
local Horde = require("OMHTT/DefenseHorde")
local B = {}
local weapon

---@param record table Turret state
---@param origin IsoGridSquare Muzzle square
---@param target IsoZombie Eligible target
---@param player IsoPlayer? Operator
---@param options table Committed shot
---@return table facts Presentation facts
function B.hit(record, origin, target, player, options)
    if not weapon then
        weapon = instanceItem("Base.SpearCrafted")
    end
    options.effectWeapon = weapon
    local stats = options.stats
    local x, y, square = target:getX(), target:getY(), target:getSquare()
    local dx, dy = x - origin:getX() - .5, y - origin:getY() - .5
    local hit = ZombRand(10000) < Heads.accuracy(stats, math.sqrt(dx * dx + dy * dy)) * 100
    hit = hit and Horde.allowed(target)
    if hit then
        local amount = options.damage * (options.critical and stats.critMultiplier or 1)
        amount = Conditional.damage(target, amount, Conditional.snapshot(target, stats))
        Damage.apply(target, amount, record.id, "ballista", player, weapon)
        Proc.hit(target, true, x, y, origin:getZ(), record, player, options)
        Conditional.impact(target, square, options)
        if not Volley.pierce(record, origin, target, player, options, square, x, y) then
            Volley.fragment(record, x, y, origin:getZ(), target, player, options)
        end
    else
        Volley.miss(record, origin, target, player, options)
    end
    Volley.release(options)
    return {id = record.id, shot = record.shots, x = x, y = y, z = origin:getZ(),
        fromX = origin:getX() + .5, fromY = origin:getY() + .5, sound = "SpearCraftedSwing",
        muzzle = .4, muzzleHeight = .4, firearm = true, missed = not hit}
end

return B
