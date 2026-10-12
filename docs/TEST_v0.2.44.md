# 0.2.44 focused test

**Owner test pending.** This is the single combined test, including held 0.2.43 checks; older rounds need not be repeated.

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
