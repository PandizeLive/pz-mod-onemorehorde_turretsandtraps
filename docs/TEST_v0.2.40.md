# 0.2.40 test and verification

Status: source implemented and automated/native write-read passed; all three package-isolation checks passed; tagged installation follows. Owner acceptance is pending. One combined checklist replaces the held 0.2.39 Concertina test; the accepted 0.2.38.1 lag checklist stays closed.

## Short owner test

Use a fresh SP test world with both 0.2.40 entries. Debug-spawn the three loot-only modules and a Large Expansion Kit if needed; use a battery to see power cost.

1. Place Concertina in two orientations. Confirm each is one 1x2 trap; damage either end, then repair/pick up from the other. Both halves share condition and leave together.
2. Mount a potato head, then add one and two Magazine Modules: capacity should be 2 and 3. Add a Splitter and fire at a small spread of zombies: keep the central shot plus a side shot. Two ready potatoes cost two; one ready potato still fires the full volley.
3. Add Fragment. A primary hit should create one five-ray burst; a missed primary should not. Nearby victims can be hit, but victims behind a solid wall should remain protected. Watch for obvious stalls during this same brief check.
4. Mount a loaded pistol with two Magazine Modules. Reload, fire, remove a Magazine Module, eject the native magazine and recover the gun. Total remaining bullets across turret, gun/magazine, inventory and floor must equal the starting total minus fired rounds; the recovered gun/magazine retain normal capacity.
5. Reinstall the expanded loaded gun, quit/reload, and confirm modules, ready ammo, reserve and battery are retained. Report any UI, ray-direction or sound problem; say "test complete" so console.txt and exact installed versions can be captured.

## Automated evidence

- 5,018 Kahlua assertions; 96 runtime/translation files compile; 608 native translation keys; 23 packet serializations. World/player/network/UI objects in logic tests are doubles; this is not rendered acceptance.
- Formula examples at bases 1/7/14/30/60; native/chamber versus physical feed conservation; surplus return and repeated service protection; zero/partial/full volley consumption; native whole-shot critical budget; lethal-hit and eight-pellet single-burst integration.
- Splitter counts through 40 preserve primary/180-degree fan and saved odd-side alternation. Fragment fixed-five separation, damage cap, distinct victims, wall/range/unloaded-path checks and direct-only damage pass. Queue admission caps total committed/reserved rays at 256; dense-object work yields within 128 steps per callback. Headless bounds are not an in-game lag benchmark.
- Native 42.21 write/read pass in 81.1/80.8 seconds. All 20 admitted firearms preserve native capacity, total ammo, physical feed weight, three-round Splitter consumption and removal; fresh-process binary restore preserves the extension alongside exact gun identity/attachments/native magazine/chamber. Module scripts and 138 loot entries across sixteen native pools load correctly.
- Integrated queue saturation and insufficient multiplied battery power reject firing before resource use; four offensive copies charge exactly twice the base battery cost.
- Static split-package checks: 190 source files, 230 package files (105 Traps / 125 Turrets), 122 unique Sandbox options and 31 identical shared helpers.
- Known stock asset/world-generation diagnostics remain. The first native write attempt reached persistence successfully but failed an obsolete 121-entry loot-count assertion; updated to 138 after verifying the additional pool entries, then reran successfully. First new logic run also exposed literal percent translation formatting, corrected to native-safe percent wording before completion. Test expectations were corrected for floating-point tolerance and the existing nil return of Cycle.consume; final checks pass.

## Limits

SP combat only; no owner/GPU/audio or maximum-load endurance acceptance claimed. Queued child effects and in-flight potatoes are runtime-only, discarded on reload without replay/refund. Real ammo and module state persist. Hosted LootLab still advertises its 0.2.28 baseline and does not yet contain the three new module entries. No new crafting or Workshop upload.

## Installation and GitHub

Native Traps-only/Turrets-only/both startup passed in 90.5/91.5/90.2 seconds. Pending immutable test/v0.2.40 tag, root OMH.cmd Install, hash verification and C108/C119 development mirror. Evidence below will be updated before handoff.
