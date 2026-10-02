# v0.2.23 — Turret controls, combat and loot

Approved 2026-10-02 with the LootLab expansion. This resumes the held gameplay draft and incorporates the owner's native critical policy. Installation evidence is in [RELEASE.md](RELEASE.md); no Workshop upload exists.

## Implemented behavior

- Manage has Fire, Power beside Battery, and Priority. The old Automatic and Unload reserve buttons are gone; ammunition moves through its slot. Power stops firing, detection, turning and feeding, cancels uncommitted shots and reload cues, and survives pickup/save/load. Already-fired potatoes still land. Old explicit Automatic Off maps to Power Off.
- Native firearm ranges are read from the actual gun: M9 15 tiles, JS-2000 12, MSR788 40 at the unmodified defaults. Initial pistol chambering no longer imposes a per-shot rack delay. Default shot intervals are 0.4 / 1.0 / 1.2 seconds respectively. Reload and manual pump/bolt cycles remain separate. M16's native range is 30, but its adapter is not enabled.
- Critical and Accuracy modules are lootable, stackable and add five percentage points per copy by default. Probability is bounded at 100%; slot capacity is the stacking limit. Native firearm critical chances and damage multipliers are retained: M9 20% / x4, JS-2000 70% / x12, MSR788 30% / x4. Shotguns roll critical once for the shot before distributing the existing damage budget. Potato baseline is 0% / x2; splash does not receive another critical roll. Manage shows effective chances. Sandbox exposes gains and critical damage tuning.
- Suppression weight drops from 0.5 to 0.25. Default remaining hearing radius is `0.4 / (1 + 0.6 * (n - 1))`: reductions of 60%, 75%, 81.8%, 85.7% and onward, never zero. Positive native hearing rounds upward to at least one tile. Known shots use the approved muffled audio; an unrecognized sound retains its original event with stack-scaled gain and a configurable 10% minimum. This does not add support for arbitrary gun mechanisms.
- Without Filter, select a random valid target and retain it until dead or invalid. Max Toughness ranks recorded initial health and retains its target; Weakest still ranks current health. Reads Horde Night's recorded baseline first, otherwise captures vanilla health at OnZombieCreate. An already-injured existing zombie with no recorded baseline cannot have its original HP reconstructed and ranks below known baselines. Searches remain sliced and valid locked targets do not trigger new crowd scans.
- All 15 components remain in ElectronicStoreMisc, CrateElectronics, MechanicShelfElectric and ArmyStorageElectronics. ElectricianTools adds Firing/Detection/Filter/360; GunStoreAccessories adds Suppression/Range/Velocity/Accuracy/Critical; ToolCabinetMechanics adds Reload/Rapid-Fire, all Expansion Kits and Autoloader. Definitions are shared by runtime and the extractor, yielding 75 pool entries in seven pools. Already-generated container loot is not retroactively replaced.

## LootLab

[Hosted tool](https://admin.onemorehorde.com/admin/LootLab/) and [canonical local tool](../art/loot-tuner/index.html) use the same 0.2.23 baseline, including component subsets in generated worlds and probability overlays. Current installed map extraction identifies 11,713 candidate containers and 45 eligible routes. Default model mean is approximately 133 countywide components; the 256-world central 90% model interval is 111–152. Capacity, stories and exploration-order differences remain explicit limitations, not hidden error bars.

Existing account tuning, old JSON and offline browser drafts migrate without a reset. Critical/Accuracy start at multiplier 1 and visible. Set to Default explicitly restores the new baseline. Shared account settings still sync PC/phone. No live preset is overwritten by deployment.

## Verification and limits

Kahlua/runtime fixtures cover ammo conservation, Power Off and cancellation, sticky target retention/invalidation, native-stat use, critical/accuracy bounds, suppression rounding, eligible loot subsets and idempotence. Native stock 42.21.0 write/read probes cover startup, saved exact items and world state, seven-pool parsing, real gun stats and ammo mechanisms. Model and API tests cover subset probabilities, seed reproducibility, account migration and concurrent/offline settings. Exact results and deployment evidence live in RELEASE.md and the website release record.

SP gameplay gate remains. The shared architecture still needs the P2C3e aggregate performance/clock and multiplayer-authority work; no blanket compatibility or frame-smoothness claim. Native critical multipliers can make shotgun damage very high in this adapter and are retained by explicit choice. Existing saves keep their Sandbox values. No recipes, art, barrier behavior or other mods were changed.

## Quick combined test

1. Restart and confirm **0.2.23**. Use the current save; saved Sandbox overrides remain. Manage should have Fire, Power and Priority, with no Automatic or Unload reserve buttons.
2. Load a potato turret, battery, Detection and Firing. Turn Power off during aiming/reloading: no new shot, sweep, reload or ammo loss. Turn it back on; it resumes.
3. Remove Filter and observe it stay on one valid zombie. Install Filter, choose Max Toughness, and wound its selected tough zombie; it should keep that target until it dies or becomes blocked/out of range.
4. Compare M9, JS-2000 and MSR788 effective range and fire rate with the same module setup. Add Critical and Accuracy copies; their displayed chances rise and stay at or below 100%. Native critical damage is intentionally retained.
5. Add one then two Suppression modules and fire. Keep an eye on head visibility, projectile alignment and stutter; reload/fire audio should still work. Logs capture the actual hearing radius and critical outcome.
6. Turn Power off, pick up/redeploy, then save/reload: Power and exact contents remain. On LootLab, confirm 0.2.23, existing rates, new components and seven pools; change one value on PC, wait for Saved across devices and reopen on phone.

**Test now** once RELEASE.md records the verified local install.
