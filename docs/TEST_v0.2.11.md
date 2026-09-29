# Owner test — 0.2.11 failed

2026-09-29: the owner reports a floating turret base and Manage throwing an error. Capture: diagnostics/captures/20260929-164940-1100, containing console, OMHTT trace, error context and installed identity. The log confirms 0.2.11 on 42.21.0 / 4a0e9546ec.

The deployed device is an empty base (head=false, items=0), so its floating appearance is not evidence to change the recorded head mount settings. Sprite omhtt_barrier_01_46 has native render offsets 64/192. The base image projects ground center at 64/208 instead of tile center 64/224, producing a 16-pixel vertical mismatch.

Manage logs require("OMHTT/TurretWorld") failed at client-file load. Later isValid at TurretManage.lua:79 throws attempted index: near of non-table: null; the native action queue then clears the broken action. Server-ready occurs after client loading. The file captured the early nil return in a local variable. The previous test harness loaded the server first, masking the error; its passing assertion count did not establish client usability.

0.2.11.1 moves world-module lookup into interaction callbacks and loads the client panel before its server dependency in the regression harness. The new guard fails against the old source and passes against the repair. It also corrects the base-only texture projection, preserving sprite IDs, collision, contents and head calibration. No successful gameplay/render acceptance is inferred from this failed test.
