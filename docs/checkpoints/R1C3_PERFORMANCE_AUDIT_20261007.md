# Performance audit while the 0.2.30 owner test is held

**Current disposition, 2026-10-10:** this is historical 0.2.30 audit evidence, with C121/C122 findings below. [0.2.34](../PATCH_v0.2.34.md) implemented aim inventory caching and removal of duplicate same-step retained-target LOS checks. Installed [0.2.38.1](../PATCH_v0.2.38.1.md) preserves native pitch variation while avoiding the noisy emitter setter, skips irrelevant Concertina lookups and adds aggregate trap/reload timings. Other proposals below require their own scope/evidence. R1C3 stays open; only the [four-step performance comparison](../TEST_v0.2.38.1.md) is requested. No automated result proves the client pauses fixed.

2026-10-07. Base: `dev` / `5fc64467873ea81404927882cdeb5b07d2e1c50a`, fetched and equal to origin/dev. C97 approves investigation and barbed-section design, not a new gameplay patch. Source/Contents remain the installed 0.2.30 implementation.

## Conclusion

There is useful optimization work left. Repeated inventory summaries and line-of-sight checks are confirmed; rendering and barrier topology have scaling gaps. None is established as the cause of the reported 300-700 ms pauses. Prior captures put 313-778 ms outliers inside the audio helper, while preparation/combat were mostly 0-2 ms. The new audio-stage measurements still need an owner gameplay capture. The focused 0.2.30 test is held, not waived or passed.

## Checks run this session

Ran the unchanged TurretScheduler, TurretAutomation and TurretAim Lua files in the installed game's Kahlua runtime, with deliberately mocked world/clock/dependencies. The probe counts operations; it does not measure client frames, native ray cost, allocations in bytes, FMOD, GPU time or gameplay smoothness. Reproduction files: `diagnostics/audit-20261007/AuditProbe.java`, `bootstrap.lua`, `probe.lua` and `results.txt`.

| Probe | Result |
| --- | --- |
| Empty square scan, range 6 | 169 square lookups, 3 slices of at most 64 work units |
| Empty square scan, range 12 | 625 lookups, 10 slices |
| Empty square scan, range 20 | 1,681 lookups, 27 slices |
| Empty square scan, range 60 | 14,641 lookups, 229 slices |
| 60 repeated unaligned requests for the same target | 60 calls to the full inventory-summary function |
| 10 retained-target steps without firing | 20 line-of-sight checks |
| Simulated 500 ms operation inside the 3 ms scheduler | Operation finishes; next worker deferred. Budget is cooperative, not preemptive. |

Slice counts are not frame counts. Empty-world scans are a controlled upper-area example; targets add moving-object work and priority-dependent rays. These results prove the call pattern, not the real cost of each call.

## Findings and proposed patch order

1. **Reuse inventory work during aiming.** `TurretAim.lua:30` calls `T.contents` on each unaligned request; its tick also rebuilds contents at 100 ms validation intervals. `Turret.lua:113` walks all items and rounds, creates summary tables and obtains translated module names/weights. `TurretWorld.lua:117` already has a 200 ms snapshot shared by automation/feed, but aim bypasses it. Recommend sharing the snapshot for advisory checks and retaining fresh resource validation at shot/transfer commit. Cache invalidation must cover same-count replacement, head/module condition, tuning changes and pickup/reload; do not introduce stale ammo or power transactions to save scans.
2. **Remove same-step duplicate rays.** `TurretAutomation.lua:86` checks a retained target's lane and checks it again before requesting aim; firing validates again at commit. Reuse only the successful result inside that same step. Keep fresh checks on later ticks and actual shots, so moving targets and new obstructions remain correct. Do not replace targeting priorities or reduce acquisition cadence as an undocumented optimization.
3. **Measure work outside combat scheduling.** `TurretRenderer.lua:64/104/146` visits tracked entries for animation each tick, drawing each viewport and periodic cleanup. Distance/visibility filter drawing after iteration; there is no shared combat deadline here. Preserve visible frame animation; first add gated timings/counts, then consider nearby indexing and staggered stale-entry cleanup if measured. `PrototypeEffects.lua:41` already caps its visual list at 64; it is not an unbounded projectile list.
4. **Keep long-range acquisition responsive.** `TurretAutomation.lua:37` bounds scans to 64 work units per visit, with at most four entries per worker call; the scheduler rotates workers under a shared 3 ms deadline. This avoids a single full-area Lua scan, but high range increases search latency substantially. Start with inventory/ray cleanup. A shared spatial candidate index is a larger change requiring movement, stationary-zombie, floor, unload and fairness proofs; it is not the first patch.
5. **Address barrier topology separately.** `BarrierOutline.lua:76` rebuilds all persistent barrier outlines when dirty. `BarrierGeometry.outline` compares each record's ends against every record and allocates shapes repeatedly: quadratic topology work on a change, not every ordinary combat tick. Prefer an edge/endpoint index preserving joins and exposed caps. This is relevant to large mixed defenses and destruction, but not evidence against the audio finding. Do not reuse this global rebuild design for new barbs.
6. **Continue audio diagnosis without speculative sound changes.** `PrototypeEffects.lua:15` now records emitter/play/pitch/volume stages only with turret diagnostics enabled. A Lua deadline cannot interrupt a blocking native audio operation. Do not claim a lower budget, speculative preloading, dropped sounds or reduced pitch variation solves it. The earlier isolated muted-audio probe did not reproduce the client stalls.

Existing safeguards remain useful: shared round-robin combat budget; feeder cap of four; aim cap of eight; flight cap of sixteen per worker visit; detailed-only reaction observation; coalesced refresh queue; indexed Bed Spikes proximity and at most four deferred companion removals per tick. No evidence justifies rewriting these wholesale. A damaging bed fall currently resolves its two world parts twice; this is a small local cleanup candidate, lower priority than aim and rays.

## Verification required for an implementation slice

For cache/ray cleanup, compare operation counts before/after and preserve targeting, aiming speed, moving obstruction rejection, same-count inventory replacement, condition/module changes, exact ammo/power use, pickup/redeploy and saved state. Run existing affected Kahlua checks. Use the already-held owner workload to assess frame smoothness when the owner returns; do not require another full split regression. Renderer and topology changes should be separate slices with their own evidence. This audit does not enable MP or certify frame times.

## C121/C122 audio and contact follow-up (2026-10-10)

The 0.2.38 owner capture records active-update gaps up to 1,077 ms and 674 ms in the sound pitch setter. The current installed 42.21 setter bytecode logs and assigns pitch broadly across the emitter; the log explains a concrete avoidable path, not proof of every stall's cause. C122 approves optimization with pitch preserved. 0.2.38.1 uses the native script pitch field and randomized clip selection across the same 101 values, preserving owned samples/weighting and native event audio. Nine nearby Concertina tiles now require only the occupied tile's world lookup; live object/backing validation remains. Trap and reload aggregate timings expose remaining costs. Native queued audio and Lua checks pass; see [current test/verification](../TEST_v0.2.38.1.md). R1C3 stays open until comparable owner gameplay evidence establishes improvement.

## C123 owner comparison (2026-10-10)

The owner reports lag apparently gone on 0.2.38.1. The [captured comparison](../TEST_v0.2.38.1.md#owner-result-and-console-comparison-2026-10-10) shows audio max 3 ms versus 674 ms and trap callbacks max 2 ms. Update-gap maximum drops from 1,077 to 368 ms, but remaining outliers and fewer shots prevent claiming all stalls eliminated. The focused perceived-lag result is positive; no repeat checklist is requested. Keep residual-gap, larger-load and authority questions open without treating them as approval for new changes.
