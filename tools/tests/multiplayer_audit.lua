local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")
local Combat = require("OMHTT/PrototypeCombat")
local Pack = require("OMHTT/TurretModulePack")
local Bed = require("OMHTT/BedSpikes")
local Barb = require("OMHTT/BarbSections")
local oldMode = testMode
local oldSettings = SandboxVars.OMHTurretsTraps
SandboxVars.OMHTurretsTraps = {Enabled=true, TurretsEnabled=true, BedSpikes=true, BarbSections=true, BarbWire=true}
for _, mode in pairs({"client", "server"}) do
    testMode = mode
    check(not T.accept(nil, nil), "MP rejects turret inventory before touching native input: " .. mode)
    check(not T.hybrid() and T.recipeInput(nil, nil) and OMHTT_TurretMenuAvailable({}), "Turret crafting is available; hybrid rendering remains gated: " .. mode)
    check(not W.valid(nil), "Missing production turret is rejected: " .. mode)
    check(Combat.fire({kind="potato",ammo=4,shots=0}, nil, nil) == "MPCombatDeferred", "MP combat is explicitly deferred: " .. mode)
    check(Pack.open(nil, nil) == nil, "Pack opening rejects missing authoritative player/item: " .. mode)
    check(Bed.enabled(), "Bed Spikes lifecycle is enabled in MP: " .. mode)
    check(not Barb.enabled("panel") and Barb.enabled("wire"), "Concertina lifecycle enabled; panel authority remains gated: " .. mode)
end
testMode, SandboxVars.OMHTurretsTraps = oldMode, oldSettings
testMultiplayerAudit = "clientAndServerGuards=pass gameplayCompatibility=blocked liveDedicated=not-run liveListen=not-run"
