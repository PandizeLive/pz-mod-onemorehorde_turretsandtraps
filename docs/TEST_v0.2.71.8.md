# 0.2.71.8 verification

Owner approved C5431A. [Implementation and proof limits](ROTARY_REPAIR_C544.md).

**50,554 assertions passed.** All 144 angle/scheduler cases match observed blade crossings; additional stacked-speed, cone, delayed-receipt, movement, pause and lifecycle cases pass. Exact released rotary/scheduler code fails the corrective replay. Native 42.21 write/read and Traps-only, Turrets-only and combined starts pass.465 source and641 package files validate. [Evidence](evidence/c544-verification.json).

Zero connected clients; rendered multiplayer acceptance remains pending. The server-report replay uses world/network adapters and a delayed damage sink. The full head/module matrix separately tests the real damage transaction. Native ownership probes use real engine userdata. These do not establish connected smoothness.

Installed and staged from immutable `test/v0.2.71.8` / `9e2d636`. All 465 source and 641 tag/package/install/archive/stage files and prior backups verify; page metadata/preview preserved. [Delivery](evidence/c544-delivery.json). No Workshop upload, live-server or sibling changes. **Test now after uploading 0.2.71.8 and restarting server and clients. No new world required.** GitHub mirror verified at `dc352861` through draft PR1, including immutable `test/v0.2.71.8`, under standing owner authorization.

## Owner checklist

After uploading 0.2.71.8, restart server and clients. Keep the current world.

- Rotary Blades wakeup and damage
- Stacked Rapid Fire with360
- Rotary cone reversals
- Moving targets and mixed traps
- Stop, power-off and pause/resume

General zombie sliding during multiplayer pause remains separate from this repair.

## November 2 connected retest

**C545 / Rotary Blades failed connected acceptance on 0.2.71.8 (2026-11-02).** All 36 admitted rotary hits applied. The released code misses sideways crossings and can discard a stationary target's entire pass when observations arrive ahead of motor history. A separate replay confirms disagreement between reported and native stance. Turret detailed logging was off, so individual live misses cannot be attributed. [Connected findings and corrective choices](ROTARY_RETEST_C545.md). Recommend **1A** to correct the shared contact calculation and cover both packet phases. **Decision needed.** The owner could not tell whether a standing zombie stayed still through several blade passes during the live test. The unlisted 0.2.71.8 upload is confirmed in the publisher receipt.
