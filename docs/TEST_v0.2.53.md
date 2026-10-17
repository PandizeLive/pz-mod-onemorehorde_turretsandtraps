# 0.2.53 verification and short owner test

Installed from immutable `test/v0.2.53` / `cff0fe9e591db5a2589d784f0fc9410be05dac80`. All 278 source and 348 packaged/installed/archive files match; both 0.2.52 backups verify. [Install evidence](../diagnostics/v0.2.53/local-release.json).

## Automated verification

Full validator: **20,807 assertions**, 196 Lua/runtime/translation compilations, 278 source files and 348 packaged files (130 Traps, 218 Turrets), 277 literal translation keys. Controls coverage includes private/public/faction rules, current faction membership, endpoint/range checks, assignment/reassignment and packed quotas, multiple remote sessions, expiry/outage/unassignment, pulse replay, held/release/recovery/unloaded behavior, private identity recovery, clearing broken input links without automatic firing, bounded discovery and menu rectangle checks. Existing ammo, combat, Horde consent, Void and exact-item transfer regressions remain in the full suite.

Stock 42.21 native probes verify three craft transactions and retained tools, production creation callbacks, private ownership despite forged public hints, 48-hour fractional backup and immediate saved-battery recovery behind stockpile items, scoped remote access, 500-weight rejection, both-handed heavy controller pickup/redeployment and 30 family/tier capacities. Fresh-process persistence covers 167 controller items over 100 weight and 5,000 real firearm rounds (5,002 total items). Native package startup checks cover Traps-only, Turrets-only and both, with shared controls registered once. Logs/results are in diagnostics/v0.2.53; release verification records the final outcome separately from owner acceptance.

These are automated Lua test-double and zero-client native checks. They do not certify rendered menus, real player/zombie pressure-plate crossings, audible balance or connected dedicated/listen multiplayer. Native map/property warnings also occur in the isolated environment; mod callback checks are separate. Old 0.2.52 turrets need pickup/redeployment for control ownership; use a fresh world when practical.

## Test now — five checks

1. Restart and confirm **0.2.53**. Place a controller, pressure plate, wall button and turret. Give the controller a small battery; open Controls and assign the three devices.
2. Link the plate to a loaded Firing turret. Step on/off: it powers/fires, then stops aiming/firing. Try a button press, then add Detection and repeat with zombies.
3. From the controller, open full turret Manage. Rename it; move a head/module/ammo from both your inventory and the controller stockpile, then remove something back to each destination. Check Load Order/Reload and menu fit.
4. Try a Large Expansion load beyond the old weight cap (5,000 rounds, 350 spears/bombs or 900 scrap). Pick up/redeploy the loaded turret and controller: both hands when needed, exact contents/full weight retained.
5. Save/reload. Confirm names, access, assignments, links and stock remain; released plates must not replay firing. Remove controller power: remote changes stop, direct plate links still work.

After the test, capture console.txt and review the exact loaded version/errors. Connected multiplayer later adds two-player ownership/faction/public changes, competing transfers, disconnect/reconnect and synchronized plate/fire effects. Do not repeat unrelated passed tests.
