if isClient() then return end

require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local Damage = {}

---@param zombie IsoZombie Living victim
---@param amount number Fixed native health loss
---@param source string Device identity
---@param kind string Direct, splash or barrier
---@param operator IsoPlayer? Manual test operator
---@param weapon HandWeapon? Native kill context for manual fire
---@return number lost Actual native health removed
function Damage.apply(zombie, amount, source, kind, operator, weapon)
    if isClient() or isServer() or zombie:isDead() or amount <= 0 then return 0 end
    local before = zombie:getHealth()
    local remaining = before - amount
    if remaining < 0.000001 then
        remaining = 0
    end
    zombie:setHealth(remaining)
    if remaining == 0 then
        if operator then
            zombie:hitConsequences(weapon, operator, true, 0, true)
        else
            zombie:Kill(nil, false)
        end
    end
    local lost = before - zombie:getHealth()
    Diagnostics.defer("damage-applied", {id = source, kind = kind, before = before,
        after = zombie:getHealth(), nativeDamage = lost, damage100 = lost * 100, dead = zombie:isDead()})
    triggerEvent("OnOMHTTDamage", zombie, lost, source, kind)
    return lost
end

return Damage
