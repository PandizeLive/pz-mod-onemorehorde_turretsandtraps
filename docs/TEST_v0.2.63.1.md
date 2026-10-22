# 0.2.63.1 verification

Owner cannot test currently. Keep both this checklist and the preceding 0.2.63 visual checklist deferred, not passed. When available, restart to load the new version.

- Controller entry loading
- Expansion replacement and capacity
- Pickup, redeploy and reload

## Automated evidence

Full Kahlua validation passed **27,129 assertions** (316 runtime/translation files compiled). The focused C399 fixture covers 256 delayed candidates, 12,800 allowance queries, queue lifecycle, late inventory and 320 mixed device dispatches. See [audit](AUDIT_C399.md) for measured counts and boundaries. Native write passed in 75.2s and fresh-process read in 63.1s on installed game 42.21. Exact Controller kit install/removal, 10/50 range, 100/500 allowance and heavy exact-item recovery passed. Standalone Traps and Turrets startup passed in 69.0s and 60.5s; combined-package startup passed in 54.5s. Package dependency/manifest checks passed: 378 source files and 525 packaged files.

No game FPS, rendered behavior or connected-player acceptance is inferred from test doubles or zero-client native probes. No player saves or enabled-mod selections are changed.
