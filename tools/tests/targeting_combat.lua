local C = require("OMHTT/ControlCombat")
local W = require("OMHTT/ControlWorld")
local H = require("OMHTT/TurretPlayerHit")
local I = require("OMHTT/DefenseInjury")
local old = {mode = testMode, instance = instanceof, faction = Faction, options = getServerOptions,
    zone = NonPvpZone, owner = getPlayerFromUsername, state = W.state, records = W.records,
    clock = getTimestampMs, random = ZombRand, parts = BodyPartType, injury = I.turret,
    settings = SandboxVars.OMHTurretsTraps, cell = getCell}
local now, shots, rolls = 100000, {}, 0
local oldOnline = getOnlinePlayers
getTimestampMs = function() return now end
ZombRand = function(n)
    if n == 10000 then rolls = rolls + 1 end
    return 0
end
BodyPartType = {ForeArm_L = 2, ForeArm_R = 3, UpperLeg_L = 11, UpperLeg_R = 12,
    ToIndex = function(x) return x end, FromIndex = function(x) return x end}
instanceof = function(o, kind) return o and o.class == kind end
local factions = {owner = "base", ally = "base", enemy = "outsiders"}
Faction = {getPlayerFaction = function(name) return factions[name] end}
local settings = {PVP = true, SafetySystem = true}
getServerOptions = function() return {getBoolean = function(_, key) return settings[key] end} end
local zoneX
NonPvpZone = {getNonPvpZone = function(x) return zoneX == x and {} or nil end}
local function actor(name, x)
    local a = {name = name, x = x or 10, safety = false, class = "IsoPlayer", armor = 0}
    function a:getUsername() return self.name end
    function a:getPlayerNum() return 0 end
    function a:getOnlineID() return 15 end
    function a:getX() return self.x end
    function a:getY() return 0 end
    function a:getZ() return 0 end
    function a:getHealth() return 1 end
    function a:getSafety() return {isEnabled = function() return self.safety end} end
    function a:isDead() return self.dead == true end
    function a:isGodMod() return self.god == true end
    function a:isNoClip() return self.noclip == true end
    function a:isGhostMode() return self.ghost == true end
    function a:getBodyPartClothingDefense() return self.armor end
    return a
end
local owner, enemy, ally = actor("owner", 0), actor("enemy"), actor("ally")
getPlayerFromUsername = function(name) return name == "owner" and owner or nil end
local host = {kind = "Controller", id = "host", placed = true, targeting = "OtherFactions"}
local state = {kind = "Turret", id = "defense", controller = host.id, owner = "owner", x = 0, y = 0, z = 0}
local object = {getSquare = function() return owner end}
W.state = function() return state end
W.records = function() return {records = {[host.id] = host}} end
testMode = "server"
check(C.eligible(object, enemy), "Inherited Other Factions acquires outsider through actual private-record shape")
check(not C.eligible(object, owner) and not C.eligible(object, ally), "Owner/faction exclusion is acquisition-only")
check(C.protected(C.source(object), ally), "Physical allied collateral still follows server protection, not blanket faction immunity")
state.access = "Public"
check(not C.eligible(object, ally), "Public management access never changes combat alliance")
factions.enemy = "base"
check(not C.eligible(object, enemy), "Changing faction while acquired revokes target immediately")
factions.enemy = nil
check(C.eligible(object, enemy), "Factionless outsider included")
state.targeting = "Zombies"
check(not C.eligible(object, enemy), "Explicit local override beats Controller")
state.targeting = nil
host.placed = false
check(not C.eligible(object, enemy), "Packed Controller cannot enable player acquisition")
host.placed = true
settings.PVP = false
check(not C.eligible(object, enemy) and not C.protected(C.source(object), enemy), "PvP-off blocks acquisition and physical turret injury")
settings.PVP = true
owner.safety, enemy.safety = true, true
check(not C.eligible(object, enemy), "Both safety-enabled players protected")
owner.safety = false
check(C.eligible(object, enemy), "One participant disabling safety follows native PvP rule")
getPlayerFromUsername = function() return nil end
check(not C.eligible(object, enemy), "Offline owner treated conservatively as safety-enabled")
enemy.safety = false
check(C.eligible(object, enemy), "Offline owner can defend against safety-disabled outsider")
zoneX = 10
check(not C.eligible(object, enemy), "Target non-PvP zone checked")
zoneX = 0
check(not C.eligible(object, enemy), "Defense non-PvP zone checked")
zoneX = nil
for _, flag in pairs({"dead", "god", "noclip", "ghost"}) do
    enemy[flag] = true
    check(not C.eligible(object, enemy), "Protected actor excluded: " .. flag)
    enemy[flag] = false
end
-- The actual incremental acquisition loop must discover players, not only zombies.
local Auto = require("OMHTT/TurretAutomation")
local Combat = require("OMHTT/PrototypeCombat")
local oldLane = Combat.clearLane
Combat.clearLane = function() return true end
local square = {getX = function() return 10 end, getY = function() return 0 end, getZ = function() return 0 end}
function square:getMovingObjects() return {size = function() return 2 end, get = function(_, i) return i == 0 and ally or enemy end} end
function enemy:getSquare() return square end
function ally:getSquare() return square end
getOnlinePlayers = function() return {size=function() return 2 end,get=function(_,i) return i == 0 and ally or enemy end} end
local empty = {getMovingObjects = function() return {size = function() return 0 end} end}
getCell = function() return {getZombieList=function() return {size=function() return 0 end} end, getGridSquare = function(_, x, y)
    if x == 10 and y == 0 then return square end
    return x >= 0 and x < 10 and y == 0 and empty or nil
end} end
local profile = {object = object, range = 12, heading = 0, cone = 90, priority = "Closest"}
local job = Auto.scan(owner, profile)
local slices = 0
while not Auto.advance(job, 64, now + 1) do
    slices = slices + 1
    check(slices < 50, "Player acquisition stays bounded")
end
check(job.best == enemy and slices <= 1, "Candidate acquisition promptly selects outsider and skips faction mate")
state.targeting = "Zombies"
job = Auto.scan(owner, profile)
while not Auto.advance(job, 64, now + 1) do end
check(job.best == nil, "Changing policy removes players from the actual scan")
state.targeting = nil
getCell, Combat.clearLane = old.cell, oldLane
getOnlinePlayers = oldOnline
testMode = "client"
check(not C.eligible(object, enemy), "Client cannot run authoritative acquisition")
testMode = "server"
SandboxVars.OMHTurretsTraps = {FriendlyPlayerDamageMultiplier = 1, HostilePlayerDamageMultiplier = 1, FriendlyPlayerWoundMultiplier = 1, HostilePlayerWoundMultiplier = 1}
I.turret = function(player, part, amount, wound)
    shots[#shots + 1] = {player = player, part = part, amount = amount, wound = wound}
end
local function root()
    return {playerSource = C.source(object), stats = {execute = 1, critMultiplier = 100, damage = 100000}}
end
for _, row in pairs({{"Potato", 2, "none"}, {"Firearm", 4, "scratch"}, {"Shotgun", 8, "scratch"},
    {"Ballista", 10, "scratch"}, {"Scrapshot", 8, "scratch"}, {"RotaryBat", 2, "none"},
    {"RotaryBlades", 4, "cut"}, {"Lobber", 10, "scratch"}}) do
    now = now + 3000
    check(H.hit(enemy, root(), row[1]), "Admits selected head " .. row[1])
    local hit = shots[#shots]
    check(hit.amount == row[2] and hit.wound == row[3], "Fixed 1C profile ignores zombie crit/Execute: " .. row[1])
    check(hit.part == 2, "Limb-only selection")
end
now = now + 3000
local volley, start, before = root(), #shots, rolls
for i = 1, 20 do H.hit(enemy, volley, "Scrapshot", 1 / 8) end
local total = 0
for i = start + 1, #shots do total = total + shots[i].amount end
check(total == 8 and #shots == start + 8 and rolls == before + 1, "Pellets and Splitter share one eight-damage volley and one wound roll")
local persisted = nativeRoundTrip(volley)
check(not H.hit(enemy, persisted, "Scrapshot", 1 / 8), "Native persisted budget cannot repeat injury after restart")
now = now + 3000
local original = root()
original.playerEvent = "persisted-shot-test"
H.hit(enemy, original, "Shotgun", .25)
local copyA, copyB = nativeRoundTrip(original), nativeRoundTrip(original)
H.hit(enemy, copyA, "Shotgun", .5)
H.hit(enemy, copyB, "Shotgun", .5)
check(shots[#shots].amount == 2 and not H.hit(enemy, original, "Shotgun"),
    "Separately serialized projectile/proc owners rejoin the same remaining injury budget")
now = now + 3000
local shell = root()
H.hit(enemy, shell, "Shotgun", .25)
H.hit(enemy, shell, "Shotgun", .25)
check(shots[#shots].amount == 2, "Shotgun damage proportional to landed pellets")
before = #shots
H.hit(enemy, {root = shell}, "Shotgun", 1)
check(#shots == before + 1 and shots[#shots].amount == 4, "Child shot consumes only remaining shell budget")
check(not H.hit(enemy, shell, "Burst"), "Martyrdom cannot bypass exhausted shot cap")
now = now + 3000
before = rolls
H.hit(enemy, root(), "Potato")
H.hit(enemy, root(), "Firearm")
H.hit(enemy, root(), "Ballista")
check(rolls == before + 1 and shots[#shots].amount == 10 and shots[#shots].wound == "none",
    "Zero-chance hit leaves wound opportunity; other turret damage stacks while wound rolls throttle")
now = now + 3000
enemy.armor = 100
before = rolls
local armored = root()
H.hit(enemy, armored, "Shotgun", .5)
check(rolls == before, "Armor-blocked hit consumes no wound opportunity")
enemy.armor = 50
H.hit(enemy, armored, "Shotgun", .5)
check(shots[#shots].amount == 2 and rolls == before + 1, "Later unblocked pellet can roll once and armor reduces damage")
enemy.armor = 100
now = now + 3000
H.hit(enemy, root(), "RotaryBat")
enemy.armor = 0
check(not H.hit(enemy, root(), "RotaryBlades"), "Armor-blocked rotary contact still respects shared recovery")
now = now + 3000
H.hit(enemy, root(), "Lobber", .25)
check(shots[#shots].amount == 2.5, "Explosion preserves radial falloff")
SandboxVars.OMHTurretsTraps = {TurretPlayerDamageMultiplier = 2, TurretPlayerWoundMultiplier = 0, HostilePlayerDamageMultiplier = 1}
now = now + 3000
H.hit(enemy, root(), "Ballista")
check(shots[#shots].amount == 20 and shots[#shots].wound == "none", "Independent Sandbox damage/wound tuning")
SandboxVars.OMHTurretsTraps = {FriendlyPlayerDamageMultiplier = 1, HostilePlayerDamageMultiplier = 1, FriendlyPlayerWoundMultiplier = 1, HostilePlayerWoundMultiplier = 1}
settings.PVP = false
before = #shots
check(not H.hit(enemy, root(), "Ballista") and #shots == before, "Impact rechecks server rules after launch")
testMode = "sp"
check(H.hit(enemy, root(), "Ballista") and shots[#shots].amount == 10, "SP collateral uses same selected injury profile")
testMode = "client"
before = #shots
check(not H.hit(enemy, root(), "Ballista") and #shots == before, "Client cannot originate turret injuries")
-- C393 relationship multipliers: separate defaults and independent zero overrides.
testMode = "server"
settings.PVP = true
SandboxVars.OMHTurretsTraps = {}
now = now + 3000
check(H.hit(enemy, root(), "Firearm") and shots[#shots].amount == 16, "Hostile default multiplies existing damage by four")
now = now + 3000
check(H.hit(ally, root(), "Firearm") and shots[#shots].amount == 8, "Friendly default doubles damage")
SandboxVars.OMHTurretsTraps = {FriendlyPlayerDamageMultiplier = 0}
now = now + 3000
check(H.hit(enemy, root(), "Firearm") and shots[#shots].amount == 16, "Missing hostile setting never inherits friendly zero")
SandboxVars.OMHTurretsTraps = {HostilePlayerWoundMultiplier = 0}
now = now + 3000
check(H.hit(enemy, root(), "Firearm") and shots[#shots].wound == "none", "Hostile wounds can independently be disabled")
-- Strict server-to-owner injury envelope: limb-only, bounded, once per event.
I.turret = old.injury
local oldSpecific = getSpecificPlayer
local amount, woundsReceived = 0, 0
local victim = actor("network-victim")
function victim:getBodyDamage()
    return {getBodyPart = function()
        return {AddDamage = function(_, n) amount = amount + n end,
            setScratched = function() woundsReceived = woundsReceived + 1 end,
            setCut = function() woundsReceived = woundsReceived + 1 end}
    end}
end
getSpecificPlayer = function(index) return index == 3 and victim or nil end
testMode = "client"
local message = {id = 15, serial = 9000000, part = 2, amount = 4, wound = "scratch"}
I.receive("OMHTT_InjuryV1", "turret", message)
I.receive("OMHTT_InjuryV1", "turret", message)
check(amount == 4 and woundsReceived == 1, "Owner receives authoritative limb injury exactly once")
message.serial, message.part = 9000001, 0
I.receive("OMHTT_InjuryV1", "turret", message)
check(amount == 4, "Head/non-limb messages rejected")
message.part, message.amount = 2, 501
I.receive("OMHTT_InjuryV1", "turret", message)
check(amount == 4, "Over-limit network injury rejected")
message.amount, message.id = 4, 16
I.receive("OMHTT_InjuryV1", "turret", message)
check(amount == 4, "Other player's injury cannot apply locally")
getSpecificPlayer = oldSpecific
testMode, instanceof, Faction = old.mode, old.instance, old.faction
getServerOptions, NonPvpZone, getPlayerFromUsername = old.options, old.zone, old.owner
W.state, W.records = old.state, old.records
getTimestampMs, ZombRand, BodyPartType, I.turret = old.clock, old.random, old.parts, old.injury
SandboxVars.OMHTurretsTraps, getCell = old.settings, old.cell
