# 0.2.63.2 verification

Owner approved C400 fixes and will test personally when able. Owner testing remains deferred. No stress preset was added. Restart before loading the new build when available.

- Controller loading and assigned devices
- Connections resizing, renaming and groups
- Triggers during busy combat

## Automated evidence

Full validation passed **27,152 assertions**, compiling 316 runtime/translation files. The C400 audit fixture is now a normal C401 regression stage (`tools/tests/performance_c400.lua`), retaining the original audit counts in the historical C400 document/commit.

- Across 100 simulated budget-exhausting updates, dirty and routine work each dispatch 50 times; previously routine work dispatched zero times. FIFO ordering and queue draining pass.
- With 256 cached devices, both early and late assigned out-of-range devices appear. Indexed removal is checked.
- At width 300 with repeated 48-character names, initial text measurements are 108 for 64 entries and 300 for 256 entries (previously 2,880/11,520). Unchanged refreshes measure zero text and retain the existing layout.
- Resize, rename, connection change and explicit group/collapse refresh invalidate layout. Replacing a replicated state table updates the row without rebuilding unchanged structure.
- Previous C399 discovery fairness, expansion lookup/invalidation and 320-device round-robin checks remain passing.
- Dependency/manifest checks pass: 378 source files, 525 package files, 137 identical shared files and both independent entries.

A final Kahlua removal check also caught aliased table writes retaining the last cache slot; separate writes and permanent last/final-slot regressions correct this. One intermediate label-cache fixture failed because labels generated within the current rebuild were not reused until the next rebuild. The cache was corrected and full validation rerun. Failed attempts are not counted as passes. Final native write passed in 64.8s and fresh-process read in 63.8s. Standalone Traps and Turrets startup passed in 56.3s and 54.1s; combined-package startup passed in 50.6s. These are the corrected final-source runs; earlier pre-correction runs are not the release evidence.

No FPS improvement, rendered fix or connected-player acceptance is inferred from these tests. All native probes use isolated caches and zero connected clients; player saves are not modified.
