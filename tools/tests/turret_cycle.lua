local Cycle = require("OMHTT/TurretCycle")
local config = {magazine = 1, reload = 1000, cooldown = 500}
local state = {}
check(Cycle.update(state, 85, config, 10000) == "Reloading", "Initial potato loads instead of spawning in chamber")
check(Cycle.update(state, 85, config, 10999) == "Reloading", "One-second reload cannot finish early")
check(Cycle.update(state, 85, config, 11000) == "Ready" and state.loaded == 1, "One-round magazine ready")
Cycle.consume(state, 84, config, 11000)
check(state.reloadReady == 12000 and state.nextShot == 11500, "Reload and cooldown overlap")
check(Cycle.update(state, 84, config, 11500) == "Reloading", "Cooldown completion does not skip reload")
check(Cycle.update(state, 84, config, 12000) == "Ready", "Default sustained cadence is one shot per second")
config.magazine = 3
state = {}
Cycle.update(state, 85, config, 0)
check(Cycle.update(state, 85, config, 1000) == "Ready" and state.loaded == 3, "Larger magazine loads only configured rounds")
Cycle.consume(state, 84, config, 1000)
check(Cycle.update(state, 84, config, 1499) == "Cooling", "Loaded magazine preserves independent cooldown")
check(Cycle.update(state, 84, config, 1500) == "Ready", "Larger magazine can shoot at half-second intervals")
Cycle.consume(state, 83, config, 1500)
Cycle.consume(state, 82, config, 2000)
check(state.reloadReady == 3000 and state.nextShot == 2500, "Empty larger magazine must reload")
state = nativeRoundTrip(state)
check(Cycle.update(state, 82, config, 2800) == "Reloading", "Head save preserves pending reload")
check(Cycle.update(state, 82, config, 3000) == "Ready", "Restored cycle completes normally")
check(Cycle.update(state, 1, config, 3000) == "Ready" and state.loaded == 1, "Withdrawing ammo cannot leave phantom chamber rounds")
Cycle.consume(state, 0, config, 3000)
check(Cycle.update(state, 0, config, 9000) == "Empty" and state.loaded == 0, "Time passage cannot create ammo")
check(Cycle.update(state, 2, config, 9000) == "Reloading", "Refilling empty magazine starts fresh reload")
config.reload = 0
state = {}
check(Cycle.update(state, 1, config, 0) == "Ready", "Zero reload tuning loads immediately")
Cycle.consume(state, 1, config, 0)
check(Cycle.update(state, 1, config, 499) == "Cooling", "Autoloader-compatible zero reload still respects shot cooldown")
config.reload, config.magazine = 1000, 1
state = {}
local ammo, shots = 85, 0
for now = 0, 100000, 100 do
    if Cycle.update(state, ammo, config, now) == "Ready" then
        shots, ammo = shots + 1, ammo - 1
        Cycle.consume(state, ammo, config, now)
    end
end
check(shots == 85 and ammo == 0 and state.loaded == 0, "Full reserve yields exactly 85 shots without duplicating loaded ammo")
state = {loaded = 0, pending = 1, reloadReady = 310000, nextShot = 310000}
check(Cycle.update(state, 12, config, 10000) == "Reloading" and state.reloadReady == 11000,
    "Legacy wall-clock deadline after a five-minute pause is bounded to a real reload")
check(Cycle.update(state, 12, config, 11000) == "Ready" and state.loaded == 1,
    "Repair completes without waiting through the paused minutes or creating ammo")
