local H = require("OMHTT/DefenseHorde")
local Damage = require("OMHTT/Damage")
local Combat = require("OMHTT/PrototypeCombat")
local Volley = require("OMHTT/TurretVolley")
local oldMode, oldCore = testMode, OneMoreHordeDefenseIntegration
testMode = "sp"
OneMoreHordeDefenseIntegration = nil
local origin = makeSquare(700, 700, 0)
local zombie = makeZombie(makeSquare(701, 700, 0), 2)
function zombie:getInventory() return nil end
check(H.allowed(zombie), "Standalone ambient target allowed")
zombie.data.OMHEventId = "receiving-run"
check(not H.allowed(zombie), "Tagged Horde target needs a recognized consent API")
check(Damage.apply(zombie, 1, "turret-a", "potato") == 0 and zombie.health == 2, "Denied victim loses no health")
local permissions, beginCalls, endings = false, 0, 0
local identity = {}
OneMoreHordeDefenseIntegration = {
    API_VERSION = 1,
    authorize = function(candidate) return candidate == zombie and permissions end,
    beginDamage = function(candidate, source, kind, lethal)
        beginCalls = beginCalls + 1
        check(candidate == zombie and source == "turret-a", "Damage carries exact victim and device identity")
        return permissions, identity
    end,
    endDamage = function(candidate, token)
        check(candidate == zombie and token == identity, "Finisher scope closes on the exact token")
        endings = endings + 1
    end,
}
check(Damage.apply(zombie, 1, "turret-a", "potato") == 0, "Receiving run can refuse foreign assistance")
permissions = true
check(Damage.apply(zombie, .5, "turret-a", "potato") == .5 and endings == 1, "Consented damage invokes authoritative context once")
check(beginCalls == 2, "One damage operation performs one core admission")
permissions = false
local rayBudget, procJobs = Volley.reserved, require("OMHTT/TurretProc").reservedJobs
local options = {pending = 1, rayBudget = 1, procJobs = 0, procFields = 0}
Volley.reserved = Volley.reserved + 1
local result = Combat.hit({id = "turret-a", shots = 1}, origin, zombie, nil, options)
check(result.missed and zombie.health == 1.5, "Revoked consent cancels a delayed impact")
check(options.pending == 0 and Volley.reserved == rayBudget
    and require("OMHTT/TurretProc").reservedJobs == procJobs, "Cancelled impact releases reserved effect capacity")
local found = Combat.candidates(origin, 3)
check(#found == 0, "Unconsenting Horde is excluded before ammunition commitment")
permissions = true
options = {pending = 1, rayBudget = 1, damage = .1, critical = false, critChance = 0,
    knockdown = 0, splash = 0, radius = 0, range = 3}
Volley.reserved = Volley.reserved + 1
Combat.hit({id = "turret-a", shots = 2}, origin, zombie, nil, options)
check(options.pending == 0 and Volley.reserved == rayBudget, "Successful potato impact also releases its primary reservation")
local nativeKill = zombie.Kill
function zombie:Kill(killer, gory)
    check(killer == nil and not gory, "Manual turret operator is not fabricated as a weapon killer")
    nativeKill(self, killer, gory)
end
check(Damage.apply(zombie, 2, "turret-a", "potato", testPlayer) > 0 and zombie:isDead(), "Lethal device application keeps native death callback")
testMode = "client"
check(not H.allowed(zombie) and not H.beginDamage(zombie, 1, "turret-a", "potato"), "Client cannot authorize effects")
testMode, OneMoreHordeDefenseIntegration = oldMode, oldCore

local oldSound, sounds = addSound, 0
addSound = function() sounds = sounds + 1 end
testMode, OneMoreHordeDefenseIntegration = "server", {API_VERSION = 1, worldSoundAllowed = function() return false end}
check(not H.sound(nil, 1, 2, 0, 20, 20) and sounds == 0, "Unassisted active run prevents automated world attraction")
OneMoreHordeDefenseIntegration.worldSoundAllowed = function() return true end
check(H.sound(nil, 1, 2, 0, 20, 20) and sounds == 1, "Consented native world attraction is emitted once")
OneMoreHordeDefenseIntegration = {API_VERSION = 1}
check(not H.sound(nil, 1, 2, 0, 20, 20), "Older core without attraction admission fails closed")
addSound, testMode, OneMoreHordeDefenseIntegration = oldSound, oldMode, oldCore
