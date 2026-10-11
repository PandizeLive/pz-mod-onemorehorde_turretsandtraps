# 0.2.38 focused test

Status: automated/native verification and tagged installation passed. Owner reports general function working provisionally on 2026-10-10; lag reproduced. See the findings below. Individual unmentioned checklist items are not automatically passed. This replaces the prior active checklist and carries its unaccepted collapse/audio/continuous-placement checks into one run. Older results remain historical.

## Owner test (fresh world, single player)

1. Restart the game, create a fresh world, enable the entries you use and confirm **0.2.38** in the loaded marker. Check Crafting/Building: root Turret Base, Heads/Modules, Makeshift names, no complete Potato Turret crafts; inspect Traps/Modules Sandbox headings.
2. Craft Bed Spikes: receive **two** items. Place the pair, then reinforce/repair/pick up one tile; the other must remain unchanged. Place that one recovered tile alone. Building should keep its placement preview between placements.
3. Craft/place **Concertina Wire** with pliers, one Barbed Wire and two Wire uses. Check five-second place/pickup and ten-second free repair. Wire is freestanding; panels still need backing.
4. Lead zombies across wire and a panel edge: half-speed only during contact, normal movement after exit, timed damage without stronger overlap slowing. Check independent wear/repair, door-following and window-frame barbs; save/reload once.
5. With god/noclip **off**, walk safely, then run/sprint through a short adjoining hazard line. Watch brush-through, entry scratches/trips and a cut only on a new landing. Injuries are chance-based. Noclip should bypass; god mode should prevent injury/trips.
6. Let zombies fall on Bed Spikes: collapse/recover, hear the impact, and confirm only the hit tile wears/breaks. Briefly repeat your loaded-turret crowd test; report visible pauses and finish with **Test complete** so console.txt can be captured/reviewed.

Do not repeat unrelated old tests. Native probes do not establish rendered collapse, audio balance or elimination of 300-700ms pauses. Report what you observed; unmentioned checks are not automatically formal passes.

## Automated evidence

All final native write/read and isolated-package runs pass. 3,946 Kahlua assertions; 94 compiled runtime/translation files; 574 native translation keys; 23 packet serializations. Native write/read pass in 95.7/90.6 seconds. Traps-only/Turrets-only/both startup pass in 81.3/83.3/88.3 seconds. The manifest covers 188 source and 228 package files; 111 Sandbox options and 31 identical shared helpers pass independent checks. Native tests cover 32 independent bed objects across pair/single/tier/facing routes, eight panel/support pairs and one worn coil. Current native logs include stock asset/world-generation diagnostics; no mod probe failure remains in passing runs. Unit coverage includes continuous movement during cooldown, changed input speed, non-stacking overlaps, exit/disable/removal, player entry/landing/god/noclip rules, independent tile wear/retirement, pickup conservation, exact pair/single placement inputs and Sandbox ordering. Native probes cover registered recipes/retained tools, independent item/world state and texture registry aliases.

During development, native checks caught duplicate sprite registrations and an incorrect native recipe-time conversion; both were corrected before installation. The extended atlas verifier also needed new wire/single-tile mappings. No failed attempt is an acceptance result.

## Owner findings and console review (2026-10-10)

Owner: "Looks like it's functioning, but there was some lag when using Spike Beds, Concertina, and a Turret." General function is a provisional owner report, not item-by-item acceptance. Performance fails this run. No new full regression is requested.

Root Capture saved `20261010-220500-0006`; [reviewed machine-readable evidence](../diagnostics/v0.2.38/owner-test-20261010.json) records the console hash and line references. Both 0.2.38 entries loaded on game 42.21. The gameplay interval is lines 3439-3824, before return-to-menu warnings. A restored turret appears at startup, so the fresh-world prerequisite is not established. Raw console remains local.

- 81 summary windows record active-update gaps up to **1,077 ms**, with **858/633/362 ms** additional window maxima. These are elapsed update gaps, not a CPU profile or a count of every hitch.
- `PrototypeEffects.sound` measures up to **674 ms inside the setPitch interval**; further windows show 342, 235 and 196 ms. The 343-ms firing path includes 343 ms of effects work, with 342 ms in pitch. This makes runtime pitch adjustment a concrete investigation target, but does not assign every gap or prove an FMOD root cause.
- Measured head animation/render, range and effect-render maxima are **2/2/3/3 ms**. This does not clear unmeasured engine rendering, trap processing, GC or other mods. `TurretReloadAudio.play` also uses setPitch but lacks stage timing.
- Summaries total **19 bed trips, 20 bed falls and 58 launched shots**. Falls can originate outside the bed trip roll. Counts prove execution, not visible recovery or exact damage correctness.
- During gameplay there are five native `CellLoader` missing `vegetation_groundcover_01_*` tile errors. No Lua exception/stack trace appears in this interval. After returning to the menu, Firearms translation formatting warnings recur; neither issue is attributed to this mod or claimed to explain the hitches.

Proposed next patch, awaiting owner approval: remove per-play runtime pitch randomization from turret effect/reload audio while retaining existing clips, clip selection, volumes and zombie-hearing rules; add gated aggregate timings for reload and Bed Spikes/barb processing. The audible tradeoff is less pitch variation, not silent or removed sounds. Compare a brief repeat of the same mixed workload after that patch. Keep R1C3 open; do not promise all lag is fixed.
