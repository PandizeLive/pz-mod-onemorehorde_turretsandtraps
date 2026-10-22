# C400 - Follow-up performance audit

Requested 2026-10-22: another performance audit and advice on useful stress-test support. Baseline: installed/tagged 0.2.63.1, source `49b769e8d6c7cf731719d55e37a8caa251e63e51`, documentation HEAD `ee5c2401fe77b5141d91df0d8b5605a3940bfbfe`. Fetched origin/dev; no incoming dev commits beyond this branch. Gameplay, packages and installed files are unchanged.

## Findings

### High priority: routine scheduler starvation under continuous dirty work

`ControlWorld.tick` processes the dirty receiver list before routine round-robin work, sharing a two-millisecond deadline. There is no reserved routine turn. The fixture injects one newly dirty receiver per update and advances the test clock two milliseconds during its processing. After 100 updates, dirty dispatches are 100 and routine dispatches are zero. This proves a conditional scheduling flaw; it does **not** prove a real receiver takes two milliseconds, or that ordinary gameplay presently creates this backlog. Plates, sensors and Controller refreshes can be delayed when this condition occurs. Dirty work is also LIFO, so older dirty entries may be postponed by recurring new entries.

Recommendation: fair FIFO dirty work plus guaranteed alternation/progress for routine work within the shared budget. Bound dispatch counts as well as elapsed time; don't increase the budget to mask starvation. Verify urgent OFF transitions and action completion remain correct. An individual non-preemptible operation can still exceed the soft deadline.

### High priority: assigned cached devices can remain absent

`ControlPanel.scan` seeds from the first 64 entries in `Discovery.objects` on every scan. Its spatial scan cannot rediscover assigned devices outside the current radius. With 256 known devices, two assigned out-of-range devices were selected from early/late cache positions. After two full scans, the early device was visible and the late device was absent. The resulting menu depends on hash iteration order.

Recommendation: a resumable cache traversal or maintained assignment index, with bounded work and correct removal/unload handling. Prefer the smallest solution that preserves selection, pending feedback and out-of-range visibility. Avoid an unbounded scan in the opening frame.

### Medium priority: repeated Connections layout/text work

`ControlGraph.refreshForPanel` reconstructs all rows/markers/edges every 500ms. `fit` repeatedly removes one character and measures the resulting text. Offscreen rows are processed too. At modeled graph width 300 and allowed 48-character names, the real refresh function made **2,880 text measurements for 64 rows** and **11,520 for 256 rows** per refresh. Text measurement itself, group layout and stats were test doubles; these are operation counts, not milliseconds. At unchanged content the work still repeats twice a second.

Recommendation: cache fitted labels by text/font/width; separate structural rebuilds from live status refreshes. Invalidate on names, connections, groups, discovered devices and size changes. Consider visible-row rendering separately; don't skip needed data updates just because a row is offscreen.

## Reproducibility and limits

`tools/tests/performance_c400.lua` is an optional **audit reproduction**, not a passing regression contract for the desired behavior. It deliberately asserts that the current defects reproduce; replace those expectations when fixing them. Run it as the optional argument to the existing KahluaCheck harness after its normal stages. Local output: `diagnostics/c400-audit.log`.

Final run: **27,037 assertions** including five C400 assertions; 316 runtime/translation files compile. This differs from the 27,129 release run because the optional module-pack audit was replaced by C400, not because release assertions were removed. One graph-fixture attempt failed on its string-generation helper; the fixture now uses a literal valid-length name and the complete run passes. No production fix, new native startup test, FPS measurement or owner acceptance is claimed. Existing C399 release proof remains unchanged.

## Proposed stress-test support

Recommend a temporary debug-only preset and aggregate timing report **inside this mod**, not a separate mod. This support is proposed, not yet implemented or approved as a patch. Use a disposable world; do not populate the owner's real save. Avoid per-frame log spam. Bound spawned objects and clean up only the preset's tracked objects.

Measure frame-time percentiles/worst spikes, scheduler queue depth and oldest-item age, scan completion time, menu refresh time, and object/target counts. Keep client frame timing distinct from server work. Averages alone hide hitches. Record package version, Sandbox settings, enabled mods and hardware alongside the result.

Start with 8 defenses/50 zombies, then 16/100 and 32/200. Increase only while responsive; these are proposed test loads, not supported limits. Use additional Controllers when exceeding their configured assignment limits. Compare the same scene with Controller closed/open, then large and narrow windows. Include mixed heads/traps, simultaneous trigger activity, long names/groups and heavy stockpiles. Compare idle against active combat. Only after a mod-only baseline should Horde Night and the usual mod list be added. Connected multiplayer remains a later separate acceptance test.

Owner checklist when available (each item under ten words):

- Controller closed versus open
- Gradually larger defense and zombie groups
- Trigger spam, narrow menus, heavy stockpiles

A copied test save, console.txt and a short frame-time capture would help reproduce real-world hitches. No files or live test are required now; owner testing remains deferred. Recommend fixing the confirmed scheduling/cache flaws and adding counters before asking the owner to stress this build.

## Proposed next patch

**1A (recommended):** fix the three findings and add bounded debug stress presets/timing summaries, then run the staged owner test when available.

**1B:** fix the three findings first; keep stress setup manual.

No balance change or broader content work is proposed. **Decision needed: next patch scope.**
