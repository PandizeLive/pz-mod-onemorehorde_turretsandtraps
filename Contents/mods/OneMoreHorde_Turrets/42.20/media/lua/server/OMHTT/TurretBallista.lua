if isClient() then return end
local Actors = require("OMHTT/DefenseActors")
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
    local x, y = Actors.position(target)
    local square = Actors.square(target)
    local dx, dy = x - origin:getX() - .5, y - origin:getY() - .5
    local hit = ZombRand(10000) < Heads.accuracy(stats, math.sqrt(dx * dx + dy * dy)) * 100
    hit = hit and require("OMHTT/ControlCombat").eligible(options.object, target)
    if hit then
        if instanceof(target, "IsoPlayer") then
            hit = require("OMHTT/TurretPlayerHit").hit(target, options, "Ballista")
        else
            local amount = options.damage * (options.critical and stats.critMultiplier or 1)
            amount = Conditional.damage(target, amount, Conditional.snapshot(target, stats))
            require("OMHTT/TurretHit").resolve(target, amount, record.id, "ballista", options, function()
                Proc.hit(target, true, x, y, origin:getZ(), record, player, options)
                Conditional.impact(target, square, options)
            end)
        end
        if not Volley.pierce(record, origin, target, player, options, square, x, y) then
            Volley.fragment(record, x, y, origin:getZ(), target, player, options)
        end
    else
        Volley.miss(record, origin, target, player, options)
    end
    Volley.release(options)
    return {id = record.id, shot = record.shots, x = x, y = y, z = origin:getZ(),
        fromX = origin:getX() + .5, fromY = origin:getY() + .5,
        muzzle = .4, muzzleHeight = .4, projectile = "spear", sound = "SpearCraftedHit", missed = not hit}
end

return B
