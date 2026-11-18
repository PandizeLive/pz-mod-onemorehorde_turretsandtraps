local Probe = {}

---@param attacker IsoPlayer Native synthetic attacker
---@param square IsoGridSquare Isolated native square
---@return table fixture Native victim and production credit record
function Probe.create(attacker, square)
    local victim = IsoPlayer.new(getCell())
    victim:setCurrent(square)
    victim:setX(72.6)
    victim:setY(72.2)
    victim:setHealth(1)
    victim:getBodyDamage():RestoreToFullHealth()
    local Pools = require("OMHTS_DefenseRewards")
    local Credit = require("OMHTS_DefenseCredit")
    local store = {accounts = {}}
    assert(Pools.initialize(store))
    local bindings = {
        [attacker] = {lifeId = 1, record = {life = {id = 1, status = "alive"}}},
        [victim] = {lifeId = 2, record = {life = {id = 2, status = "alive"}}},
    }
    Credit.initialize({store = store, bindings = bindings, key = function(player)
        if player == attacker then return "attacker" end
        return "victim"
    end})
    return {victim = victim, store = store}
end

return Probe
