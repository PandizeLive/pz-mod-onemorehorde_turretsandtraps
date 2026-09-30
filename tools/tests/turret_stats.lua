local S = require("OMHTT/TurretStats")
local C = require("OMHTT/TurretCycle")
local settings = SandboxVars.OMHTurretsTraps
local base = S.resolve()
check(base.damage == 35 and base.range == 6 and base.ammo == 100 and base.modules == 4, "No modules preserve saved base balance")
local active = {Reload = 2, RapidFire = 2, Velocity = 2, Range = 2, Capacity = 1}
local stats = S.resolve({active = active})
check(math.abs(stats.cooldown - 2000 / 1.5) < 0.001 and math.abs(stats.reload - 2000 / 1.5) < 0.001,
    "Reload and Rapid-Fire independently stack speed without subtractive negative timers")
check(stats.damage == 49 and stats.knockdown == 80 and stats.range == 10 and stats.modules == 8 and stats.ammo == 200,
    "Damage, knockdown, range and storage bonuses combine")
active.Autoloader = 1
stats = S.resolve({active = active})
check(stats.reload == 0 and stats.cooldown > 0 and stats.magazine == 1, "Autoloader bypasses reload only")
active = {Reload = 40, RapidFire = 40, Velocity = 40, Range = 40, Capacity = 40}
stats = S.resolve({active = active})
check(stats.damage == 70 and stats.knockdown == 90 and stats.range == 16 and stats.modules == 8 and stats.ammo == 200,
    "Stack caps apply and legacy duplicate Capacity never compounds")
check(math.abs(stats.cooldown - 2000 / 3) < 0.001 and math.abs(stats.reload - 2000 / 3) < 0.001, "Speed bonuses stop at configured cap")
local original = settings.PotatoKnockdownChance
settings.PotatoKnockdownChance = 100
check(S.resolve({active = active}).knockdown == 100, "Module cap cannot nerf higher base knockdown")
settings.PotatoKnockdownChance = original
settings.RangeBonus, settings.RangeBonusCap = 200, 1000
check(S.resolve({active = active}).range == 30, "Maximum range bounds scan work")
settings.RangeBonus, settings.RangeBonusCap = nil, nil
settings.RapidFireBonus, settings.ReloadBonus = 0, 0
check(S.resolve({active = active}).cooldown == base.cooldown and S.resolve({active = active}).reload == base.reload,
    "Zero Sandbox gains disable speed bonuses")
settings.RapidFireBonus, settings.ReloadBonus = nil, nil
local state = {}
C.update(state, 100, base, 0)
C.update(state, 100, S.resolve({active = {Reload = 4}}), 1000)
check(state.reloadReady == 1500, "Changing reload speed preserves completed fraction")
C.update(state, 100, base, 1000)
check(state.reloadReady == 2000, "Removing and reinserting reload cannot erase remaining work")
C.update(state, 100, base, 2000)
C.consume(state, 99, base, 2000)
C.update(state, 99, S.resolve({active = {RapidFire = 4, Autoloader = 1}}), 3000)
check(state.nextShot == 3500 and state.loaded == 1, "Rapid-Fire retimes remaining cooldown while Autoloader completes reload")
C.update(state, 99, base, 3000)
check(state.nextShot == 4000, "Removing Rapid-Fire restores remaining cooldown fraction")
state = nativeRoundTrip(state)
check(C.update(state, 99, base, 3999) == "Cooling", "Serialized modified timer cannot fire early")
check(C.update(state, 99, base, 4000) == "Ready", "Serialized modified timer completes on time")
local fast = S.resolve({active = {RapidFire = 40, Reload = 40, Autoloader = 1}})
state = {}
local ammo, shots = 100, 0
for now = 0, 100000, 100 do
    if C.update(state, ammo, fast, now) == "Ready" then
        shots, ammo = shots + 1, ammo - 1
        C.consume(state, ammo, fast, now)
    end
end
check(shots == 100 and ammo == 0 and state.loaded == 0, "Fastest modules conserve exactly one real potato per shot")

settings.PotatoCooldown, settings.PotatoReloadTime = 0.1, 0.1
local short = S.resolve({active = {RapidFire = 10, Reload = 10}})
check(short.cooldown == 100 and short.reload == 100, "Module time floors never slow an already faster base")
settings.PotatoCooldown, settings.PotatoReloadTime = nil, nil
