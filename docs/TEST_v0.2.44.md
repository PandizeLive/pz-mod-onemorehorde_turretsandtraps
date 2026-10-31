# 0.2.44 focused test

**Installed; owner findings received, corrective discussion active.** This is the single combined test, including held 0.2.43 checks; older rounds need not be repeated.

1. Restart and confirm **0.2.44**. Open a firearm turret with Large Expansion. Check section borders, rarity colors, right-aligned module effects, supply bars and battery hover.
2. Transfer **600 rounds** through inventory, then Manage; interrupt once. Both should batch quickly without loss or freezes. One Conservation copy should give two uses per round, including Splitter costs.
3. Select **Once Each** with several zombies: nearest first, then least turning; misses advance. Newly arriving zombies should wait until the next round.
4. Try **Tack + Martyrdom**: hits leave a slowing/damaging field for ten active seconds; kills pop with sound. Walking through tacks is safe; running risks injury. Nearby bursts cause only minor blunt injury, protected from immediate repetition.
5. Add **Synergy + Splitter + Fragment/Piercing** and run the mixed trap/turret crowd for about 30 seconds. Secondary hits should make fields/pops without endless chains or disruptive pauses; a second Synergy should be rejected.
6. Save/reload with an active Tack field and a partly used Conservation round. Field time, ammo and components should persist. Report **Test Complete** plus any issue; Codex must inspect `console.txt` before recording acceptance.

## Automated evidence

- 15,931 assertions; 111 compiled runtime/translation files; 743 native translations; 23 packet serializations. Includes 100 estimator/conservation combinations, secondary proc lineage, reservation release, terminal effects, expiry/rearm and saved active time.
- Native write/read: 141.9 / 132.4 seconds. Independent Turrets / Traps / both startup: 117.2 / 117.5 / 113.0 seconds. Module definitions, native limb damage/protection and in-process field serialization pass. Existing exact-item/defense fresh-process restore also passes.
- Native 600-round write probe: 30 groups, 17-ms preparation, 10-ms peak group. UI responsiveness still needs the client test.
- Firearms B42: 51 supported guns, 153 conserved firing transactions; handheld timing unchanged.
- Synthetic 160-burst, 486-zombie stress: 481 callbacks, final maximum 1.37 ms, total drain 364.59 ms. Earlier runs varied; this is not a gameplay frame-time ceiling.
- 202 canonical source files / 250 package files; 146 unique Sandbox options; 39 identical shared files and closed package dependencies.
- LootLab: 28 modules, 16 pools, 193 entries; 76 API/page tests; seeded model, map controls and independent-package defaults pass. Browser imports preserve prior normalized tuning and supply the three new defaults. Production bundle/access checks recorded in `diagnostics/v0.2.44/lootlab-release.json`.

No new owner test or console acceptance is claimed this turn. The C155 676-ms gap and Louisville hang remain unassigned. GPU presentation, real crowd smoothness and a live active-field restore are pending. R3C7 and broader R1C3 remain open; multiplayer remains deferred.

Tagged/source/package/installed/archive hashes and both 0.2.43 backups verify: [machine release record](../diagnostics/v0.2.44/local-release.json).

## Owner findings and console review (2026-10-12)

Owner reports battery wording/time, engagement slider and clipped status issues; overly reliable distant hits; Tack/Martyrdom errors; and requests changed effect timing, Fragment/Piercing behavior, carrying weight and rarity-linked module tooltips/power. This is not a Test Complete or acceptance of unmentioned checks.

Root OMH Capture saved `diagnostics/captures/20261012-002038-5027`. The 4,644,397-byte console starts mid-stack at frame 28400 and confirms 0.2.44 SP. It contains **1,355** identical `attempted index: fieldOrder of non-table: null` RuntimeExceptions from `TurretTackMarkers.update`, line 25, through `TurretScheduler.tick`. Maximum summarized active gap in this snapshot is 39 ms; startup and preceding performance are not present. Error spam makes this unsuitable as clean performance acceptance. No distinct Martyrdom stack appears in the captured slice; do not invent a second cause.

Client-level `require("OMHTT/TurretProc")` captures a server-owned module before its load path may exist. Current 42.21 bytecode confirms shared/client path registration and null on missing require; reproduce the ordered startup during correction. The previous test harness preloaded server modules, so its passing isolated module tests did not cover this failure path. Contact startup, markers and dependent Martyrdom behavior must be audited together. Hiding nil with an empty table is not a fix.

[Machine summary](../diagnostics/v0.2.44/owner-20261012/console-review.json) and [selected trace](../diagnostics/v0.2.44/owner-20261012/evidence.txt) retain scoped evidence. Full raw capture remains local. [C161 requested corrections and choices](checkpoints/R3_EFFECT_POLISH.md). No new source/package/install or claim that all other checks passed. No further owner test of this faulty build is requested.
