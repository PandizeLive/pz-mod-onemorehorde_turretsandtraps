# P2C3d1 — core turret automation and module loot (0.2.14)

## Approved behavior

C56-C58 and the owner's implementation approval cover a 90-degree placement-locked cone, core module effects, loot-only acquisition and owner-controlled Sandbox balance. The standalone 0.2.13 test is held for this combined test, not passed. This package includes its head-height/yaw correction, Magazine wording and 35-damage / overlapping 2s reload and 2s cooldown defaults. Existing saved Sandbox values remain authoritative.

The forward cone is centered on base placement (45 degrees either side by default). Head tracking and firing never rotate that anchor. Manual shots and automatic shots enforce the same geometric range/cone/loaded-floor/obstruction rules. Installing a working 360 module unlocks all angles without extending range; removing it restores the original forward cone. Redeployment sets a new placement heading and resets the visible aim to it while preserving supplies, automatic switch and priority.

| Module | Implemented effect |
| --- | --- |
| Firing | Executes the detector's FIRE request through the existing ammo/power/reload/cooldown transaction. Alone it does not acquire targets. External wiring remains P4. |
| Motion Detection | Tracks valid zombies inside effective coverage; stationary zombies qualify. Requires working head and power. Without Firing it aims but never shoots automatically. |
| Filter | Enables Closest / Furthest / Weakest / Toughest in Manage. Health priorities use current native health, with closer targets breaking ties. Without Filter, effective priority is Closest; chosen preference is retained for reinstallation. |
| 360 | Full angular coverage for manual and automatic use. Does not provide detection, firing or extra distance. |

Core effects are presence-based; extra copies provide no extra benefit. Broken modules do not activate. Range, Velocity, Rapid-Fire, Capacity, Reload and Autoloader remain debug-only storage items with inactive-effect tooltips; P2C3d2 will implement their effects. No module recipes, skill gates or XP are added.

Manage adds Automatic On/Off and a Filter-gated priority button, displays active core modules and cone width, and explicitly shows when Sandbox disables automation. Automatic defaults on when the necessary parts/power are present. Switching off stops automatic tracking/firing while allowing deliberate manual shots and servicing. Four existing slots can hold the complete core loadout. All current damage, magazine/ammo, range, power and cooldown controls govern automatic shots too.

## Scheduling and authority

Single-player only. Load/change events register exact turret objects. The scheduler services at most four entries per tick, at most 64 tile/object steps per entry, with a shared two-millisecond deadline checked between steps. Each scan covers the bounded range over multiple ticks; dense near crowds do not hide farther automatic targets. The detection interval is a minimum delay between completed scans, not a guaranteed response time under load. There is no global zombie-list sweep and no unloaded/offline simulation.

Before use, validate the square/object, current head/modules, power and policy. Pending scans restart when components or effective targeting rules change. Target range/cone/line of sight is checked again before firing; no target, no power or a running timer spends nothing. Damage uses the existing fixed-damage path; automatic kills have no invented player operator or faction XP grant. Shots never accumulate for catch-up bursts after a time jump. Native collision and save identities remain unchanged.

Manual prototype candidate acquisition retains its existing 64-moving-object budget; Filter ranks that bounded manual candidate set. Automatic scans traverse the complete bounded footprint across ticks, and revalidate the selected target at shot time. Splash remains tiny, capped, and independently obstructed; it does not inherit knockdown.

## Range display and placement

Selection shows the effective cone centered on base orientation plus a separate head-aim arrow. A 360 module changes the cone to a circle. Placement previews rotate the same geometry and resolve the selected packed base's 360 module through native CraftRecipeData manual inputs. Unselected/cheat empty-base previews use the default cone. Keep the existing General → Show turret range toggle and floor/visibility/viewport checks. No artwork was generated or redesigned.

## Sandbox and loot

| Page | Setting | Default / bounds |
| --- | --- | --- |
| Turret Automation | Enable automation | On |
| Turret Automation | Forward cone | 90 / 10–360 degrees |
| Turret Automation | Detection interval | 0.25 / 0.1–5 seconds |
| Module Loot | Overall module loot multiplier | 1 / 0–20 |
| Module Loot | Firing, Motion Detection, Filter, 360 multipliers | Each 1 / 0–20 |

Loot pools verified in installed 42.21.0: ElectronicStoreMisc, CrateElectronics, MechanicShelfElectric and ArmyStorageElectronics. Base weights per pool are 2 / 2 / 0.5 / 0.25 respectively. Effective weight is base × overall multiplier × individual multiplier. These are native distribution weights, not per-container percentages; vanilla loot settings and rolls still contribute. Core automation parts are more available than the optional modules. Zero disables new drops; owned items remain. Reload the world after changing loot settings and use containers whose loot has not generated. No refilling of searched containers or forced retroactive drops.

Current native IsoWorld triggers distribution merge before SandboxOptions.load. Therefore the mod updates only its own entries at OnLoadedTileDefinitions, after saved Sandbox values load and before map population, then reparses native item distributions once. Repeated application is idempotent; unrelated entries remain. Multiplayer loot is gated with the still-deferred turret runtime. Other gameplay tuning reads current Sandbox values without reloading resources or resetting cooldowns.

## Verification and limits

Current installed stock B42.21.0 / 4a0e9546ec, hashes in diagnostics/v0.2.14/manifest.json. Relevant evidence: IsoWorld initialization/event order, SandboxOptions.load/toLua, ItemPickerJava.Parse/container item weights, native ProceduralDistributions/SuburbsDistributions, ISBuildIsoEntity and CraftRecipeData.getFirstManualInputFor, ISButton.setTitle, and existing model projection APIs. Native head import and eight-direction projection checks remain passing.

1,935 Kahlua assertions pass; 40 runtime files compile, 280 native translation keys load, 23 packet serialization checks pass and 106 package files are manifested. New regressions cover cone edge/side/rear, independent aim, all priorities, wall obstruction, an 80-zombie near crowd, bounded scan/deadline, actual autonomous ammo/damage, module removal/broken condition, global/individual switches, cancellation, time jumps, registry retirement, Manage controls, native-input placement preview and idempotent/zero/scaled loot entries.

Native write/read probes passed in 53.4 / 51.9 seconds. Fresh-process restoration verifies automatic switch, priority and baseFacing in both world and packed objects, along with prior identity/charge/condition/cooldown fields. Actual native item conditions activate/deactivate modules. Native loot parsing retains four modules in all four pools; the exact native packed input resolves before consumption. Native collision/sight/recipes remain valid. These headless checks do not establish rendered alignment, mouse interaction or full gameplay/performance acceptance. P2C3e still owns multiplayer/performance certification.

Logs include automatic state transitions, selected target/priority/cone/base-facing, no-target scan summaries, exact ammo/power expenditure, manual rejection geometry and effective per-pool loot weights. No per-frame diagnostic spam. The isolated native logs retain unrelated vanilla map warnings; no blanket error-free claim.

## Complete combined owner test

Use single-player with a potato turret, charged car battery, potatoes and all four core modules; native debug item spawning is fine for the functional test. Existing saves should explicitly select damage 35, ammo 85, magazine 1, reload/cooldown 2s, cone 90 and detection interval 0.25s. Enable automation and Show turret range. For loot testing, raise multipliers if desired, then reload before visiting an ungenerated electronics/mechanic container.

1. Restart and confirm **0.2.14**. Check Turret Automation / Module Loot Sandbox pages. Rotate a placement preview, then select the built base: expect a forward cone, a grounded head and Magazine wording in Manage.
2. Install Motion Detection only, with ammo/head/power. Zombies in front should be tracked without automatic shots; zombies behind should be ignored. Add Firing and step away: expect automatic shots using real potatoes/power, no faster than the configured timers, and matching head aim.
3. Add Filter and switch all four priorities against suitable visible targets. Add 360: expect circular coverage and rear targets becoming eligible. Remove 360: coverage returns to the original placement direction even if the head had turned.
4. Turn Automatic off: shots stop; deliberate manual Fire remains available. Turn it back on, then remove Firing or Detection: automatic fire stops. Place a wall between turret and zombie: no shooting through it.
5. Pick up/redeploy facing another direction, then save/reload. Expect retained contents/charge, automatic switch and priority; the cone follows the new placement. Zoom around the selected turret and check held head-height/yaw fixes.
6. Visit fresh relevant loot containers after reloading with your chosen loot multipliers; core modules can appear, while future stat modules should not. Finish with **Test complete**, capture console via OMH.cmd → 6, and report screenshots of any alignment/UI faults. Individual containers are random, so absence from one is not proof of failure.
