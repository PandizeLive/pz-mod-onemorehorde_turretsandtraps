# 0.2.28: broader loot and startup weapon audit

Owner approved the discussed loot coverage and diagnostics patch, increasing the prior normalized 4.5x baseline to 5x. No combat-stat changes.

## Changes

- Base weights rise by 10/9: Firing/Detection 30; Filter/Accuracy/Rapid-Fire/Reload/Velocity/Range 5; 360/Suppression/Critical/Medium kit 2.5; Small kit 7.5; Large kit/Autoloader 1.5. Overall and component multipliers remain 1. Explicit saved multipliers remain respected.
- Add GarageMechanics (scale .3), CrateMechanics (.45), ElectronicStoreComputers (.35) and ElectronicStoreHAMRadio (.35). Garage/crate subsets match their existing tool counterparts; computers/radios contain Firing, Detection, Filter and 360. Sixteen native pools contain 121 component entries. Existing pool scales remain unchanged.
- LootLab uses the same definitions and newly extracted native routes. Added expected occupied-container count beside existing haul metrics. Existing account tuning, visibility and seed migrate without another normalization or an account reset. Older pre-normalization imports retain the established conversion.
- Debug logging triggers one startup firearm audit per SP Lua session. It scans up to fifty script records per worker visit and inspects one ranged item at a time under the shared scheduler's soft budget. Output is paced to ten lines/second at most; log-budget contention retains the pending entry. Accepted entries report full type, precision classification, mechanism/mode, range, damage, accuracy and mechanical timers. Rejected entries report why, followed by totals. Admission means adapter compatibility, not certification of every custom mod mechanic.
- The audit records its current item before inspection. An unexpected native error remains visible to the debugger; the next callback can report the interrupted item and continue. No swallowed exceptions, saved items, world objects or ammunition are created by the audit; only transient inspection items.

## Model evidence

Stock 42.21.0 extraction: 79 routing rules and 18,630 mapped candidate containers. At default model inputs (material .6, rolls/retention 1, 256 sampled worlds), expected occupied containers rise from 1,564.17 to 2,076.86 (+32.8%). Expected components rise from 2,630.03 to 3,462.40. Of successful finds, 83.95% contain one/two components and 2.79% contain five-plus. Routing, capacity and world events mean these are estimates, not exact save predictions. Already-generated containers do not refill.

## Louisville hang investigation

The owner's surviving October 4 console/debug logs contain only repeated `IsoObjectUtils.safelyRemoveTileObjectFromSquare` warnings about incomplete multi-tile objects, at frame 84752. Windows recorded AppHangB1/Application Hang, not a recorded JVM fatal crash. The WER archive contains Report.wer only, no dump or offending stack.

Current installed bytecode confirms the removal helper warns and returns -1 if all parts cannot be found; the helper itself does not retry. Existing OMHTT removal loops inspected here are bounded. The preserved evidence does not identify which caller/object caused the repeated attempts, so OMH cannot be blamed or cleared. No speculative engine-removal workaround is shipped. Original logs remain in diagnostics/v0.2.27/owner-20261004-hang. A recurrence needs the early log or a live hung-thread capture before closing the process.

## Verification

3,433 Kahlua assertions, 58 runtime/translation files and 154 package files pass. Native 42.21.0 audit inspection accepts twenty real guns and rejects two cap guns. Native write/read/restart/save checks verify all sixteen parsed loot pools/121 entries. The isolated Firearms B42 probe verifies matching audit/admission for 51 conventional guns, two cap-gun rejections and 153 conserved shots. All 72 API/page tests pass. Deployment and installation evidence is recorded in RELEASE.md.

## Quick combined test

Deferred by the owner on 2026-10-06. The steps below are historical; run the [single next-patch combined test](checkpoints/R1_PACKAGE_SPLIT.md#combined-owner-test-for-the-next-playable-build) when that build is ready. Do not repeat this as a separate round or mark it passed.

1. Restart PZ with T&T 0.2.28 and your usual gun mods. Start a disposable new world; enable Diagnostic logging, leave Detailed logging off, and keep loot multipliers at 1.
2. Let the world run for thirty seconds. Normal gameplay should remain responsive while the weapon audit completes; I will check the accepted/rejected totals in your log.
3. Check several previously unvisited garages, mechanic storage and electronics shelves. Expect more single/two-module finds with occasional jackpots; not every shelf should contain one.
4. Refresh hosted LootLab. Confirm baseline 0.2.28, retained personal settings and the Containers with modules metric. Refresh spawns should still reroll the dots.
5. Report Test Complete and any hang. Do not deliberately reproduce the Louisville hang on your main save; the cause remains unresolved.
