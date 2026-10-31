local T = require("OMHTT/ControlTargeting")
local W = require("OMHTT/ControlWorld")
local A = require("OMHTT/ControlAccess")
local Action = require("OMHTT/ControlAction")
local saved = {mode = testMode, faction = Faction, state = W.state, records = W.records,
    objects = W.objects, publish = W.publish, authorized = A.authorized, write = A.write}
local host = {kind = "Controller", id = "target-host", owner = "owner", placed = true, links = {}}
local turret = {kind = "Turret", id = "target-turret", owner = "owner", placed = true, links = {}, controller = host.id}
check(T.resolve(turret, host) == "Zombies", "Legacy targeting defaults to zombies")
host.targeting = "OtherFactions"
check(T.resolve(turret, host) == "OtherFactions", "Unconfigured assigned defense inherits Controller")
turret.targeting = "Zombies"
check(T.resolve(turret, host) == "Zombies", "Explicit Zombies override is not inheritance")
host.targeting = "Zombies"
turret.targeting = "OtherFactions"
check(T.resolve(turret, host) == "OtherFactions", "Controller default changes preserve explicit overrides")
turret.targeting = nil
host.targeting = "OtherFactions"
host.placed = false
check(T.resolve(turret, host) == "Zombies", "Retired Controller cannot supply inherited policy")
host.placed = true
turret.controller = nil
check(T.resolve(turret, host) == "Zombies", "Unassigned defense uses Zombies default")
turret.controller = "different-host"
check(T.resolve(turret, host) == "Zombies", "Unrelated Controller cannot supply policy")
turret.controller = host.id
turret.targeting = "Invalid"
check(T.resolve(turret, host) == "OtherFactions", "Invalid stored mode cannot create a third mode")
turret.targeting = nil
for _, kind in pairs({"Plate", "Poke", "Button", "Lever", "Laser"}) do
    check(not T.valid({kind = kind}, "OtherFactions"), "Passive devices and triggers reject targeting: " .. kind)
end
check(T.valid(host, "Zombies") and T.valid(host, "OtherFactions"), "Controller accepts selected defaults")
check(not T.valid(host, "Inherit"), "Controller has no parent to inherit")
check(T.valid(turret, "Inherit") and T.valid({kind = "Tether"}, "Inherit"), "Recognizing defenses can clear overrides")
check(not T.valid(turret, {}) and not T.valid(turret, "Everyone") and not T.valid(nil, "Zombies"), "Malformed commands rejected")
local factions = {owner = {}, enemy = {}}
factions.ally = factions.owner
Faction = {getPlayerFaction = function(username) return factions[username] end}
local function player(name)
    return {getUsername = function() return name end}
end
check(not T.outsider(turret, player("owner")), "Owner never deliberately acquired")
check(not T.outsider(turret, player("ally")), "Owner current faction excluded")
check(T.outsider(turret, player("enemy")), "Another faction is an outsider")
check(T.outsider(turret, player("neutral")), "Factionless player is an outsider")
turret.access, turret.faction = "Public", "old-sharing-faction"
check(not T.outsider(turret, player("ally")), "Management access does not define combat alliance")
factions.owner = nil
check(T.outsider(turret, player("neutral")), "Factionless owners do not share a universal neutral faction")
check(T.outsider(turret, player("ally")), "Owner leaving faction takes effect without rebuilding defense")
check(not T.outsider(turret, player("owner")), "Factionless owner remains excluded")
check(not T.outsider({}, player("enemy")), "Missing owner fails closed")
testMode = "server"
local objects, records, states, published = {}, {[host.id] = host, [turret.id] = turret}, {}, {}
local function object(state)
    local data = {}
    local result = {getHealth = function() return 100 end, getModData = function() return data end,
        transmitModData = function() end}
    states[result], objects[state.id] = state, result
    return result
end
local controller, defense = object(host), object(turret)
W.state = function(o) return states[o] end
W.records = function() return {records = records} end
W.objects = objects
A.authorized = function() return true end
A.write = function() return true end
local function action(o, value)
    return setmetatable({character = player("owner"), object = o, id = states[o].id,
        command = "Targeting", value = value, elapsed = 0, seconds = 0}, {__index = Action})
end
local inherited = W.copy(turret)
check(inherited.targeting == nil and inherited.controller == host.id, "Private recovery copy retains inheritance")
turret.targeting = "Zombies"
check(W.copy(turret).targeting == "Zombies", "Private recovery copy retains explicit mode")
W.publish(defense)
check(defense:getModData().OMHTTControl.targetingEffective == "Zombies", "Public snapshot reports effective override")
W.publish = function(o) published[o] = (published[o] or 0) + 1 end
local change = action(controller, "OtherFactions")
check(change:isValid() and change:complete(), "Authorized Controller targeting command completes")
check(turret.targeting == "Zombies" and published[defense] == 1, "Default update publishes but never overwrites override")
check(not change:complete(), "Replay cannot apply a targeting command twice")
check(action(defense, "Inherit"):complete() and turret.targeting == nil, "Override removal preserves true inheritance")
check(T.resolve(turret, host) == "OtherFactions", "Cleared override uses current default")
local stale = action(defense, "Zombies")
stale.id = "replaced-id"
check(not stale:isValid(), "Replaced device identity rejects stale targeting edit")
A.write = function() return false end
check(not action(defense, "Zombies"):complete(), "No write permission cannot change targeting")
A.write = function() return true end
A.authorized = function() return false end
check(not action(defense, "Zombies"):complete(), "Invalid remote session cannot change targeting")
A.authorized = function() return true end
testMode = "client"
check(not action(defense, "Zombies"):complete(), "Client cannot mutate authoritative targeting")
testMode, Faction = saved.mode, saved.faction
W.state, W.records, W.objects, W.publish = saved.state, saved.records, saved.objects, saved.publish
A.authorized, A.write = saved.authorized, saved.write
