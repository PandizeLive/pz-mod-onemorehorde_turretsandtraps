if isClient() then return end

require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local Horde = require("OMHTT/DefenseHorde")
local Protocol = require("OMHTT/DefenseCombatProtocol")
local Damage = {}

---@param zombie IsoZombie Living victim
---@param amount number Fixed native health loss
---@param source string Device identity
---@param kind string Direct, splash or barrier
---@param operator IsoPlayer? Manual test operator
---@param weapon HandWeapon? Native kill context for manual fire
---@return number lost Actual native health removed
local function apply(zombie, amount, source, kind, operator, weapon)
    if isClient() or zombie:isDead() or amount <= 0 then return 0 end
    local allowed, core, token = Horde.beginDamage(zombie, amount, source, kind)
    if not allowed then return 0 end
    local before = zombie:getHealth()
    local remaining = before - amount
    if remaining < 0.000001 then
        remaining = 0
    end
    zombie:setHealth(remaining)
    if remaining == 0 then
        -- Manual device fire must not grant ordinary weapon-kill credit.
        zombie:Kill(nil, false)
    end
    if core then
        core.endDamage(zombie, token)
    end
    local lost = before - zombie:getHealth()
    Diagnostics.defer("damage-applied", {id = source, kind = kind, before = before,
        after = zombie:getHealth(), nativeDamage = lost, damage100 = lost * 100, dead = zombie:isDead()})
    triggerEvent("OnOMHTTDamage", zombie, lost, source, kind)
    return lost
end

---@param zombie IsoZombie Victim
---@param amount number Native damage
---@param source string Device identity
---@param kind string Effect family
---@param operator IsoPlayer? Manual operator
---@param weapon HandWeapon? Native weapon context
---@return number lost Synchronous SP-only compatibility path
function Damage.apply(zombie, amount, source, kind, operator, weapon)
    if isClient() or isServer() then return 0 end
    return apply(zombie, amount, source, kind, operator, weapon)
end

---@param zombie IsoZombie Exact victim
---@param amount number Server-calculated native health loss
---@param source string Device identity
---@param kind string Effect family
---@param callback function? Completion receives actual loss and result
---@return boolean accepted Completion may be asynchronous on MP
function Damage.request(zombie, amount, source, kind, callback)
    if isClient() or not zombie or zombie:isDead() or zombie:isInvulnerable()
        or not Protocol.number(amount, 0.000001, 1000000)
        or type(source) ~= "string" or #source == 0 or #source > 160
        or type(kind) ~= "string" or #kind == 0 or #kind > 64 then return false end
    if isServer() and zombie:getOwner() ~= nil then
        return require("OMHTT/DefenseCombatServer").request(zombie, amount, source, kind, callback)
    end
    local lost = apply(zombie, amount, source, kind, nil, nil)
    if callback then callback(lost, lost > 0 and "applied" or "rejected") end
    return lost > 0
end

return Damage
