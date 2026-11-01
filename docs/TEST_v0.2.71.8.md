# 0.2.71.8 verification

Owner approved C5431A. [Implementation and proof limits](ROTARY_REPAIR_C544.md).

**50,554 assertions passed.** All 144 angle/scheduler cases match observed blade crossings; additional stacked-speed, cone, delayed-receipt, movement, pause and lifecycle cases pass. Exact released rotary/scheduler code fails the corrective replay. Native 42.21 write/read and Traps-only, Turrets-only and combined starts pass.465 source and641 package files validate. [Evidence](evidence/c544-verification.json).

Zero connected clients; rendered multiplayer acceptance remains pending. The server-report replay uses world/network adapters and a delayed damage sink. The full head/module matrix separately tests the real damage transaction. Native ownership probes use real engine userdata. These do not establish connected smoothness.

Installation/staging pending. **Wait for delivery.**

## Owner checklist

After uploading 0.2.71.8, restart server and clients. Keep the current world.

- Rotary Blades wakeup and damage
- Stacked Rapid Fire with360
- Rotary cone reversals
- Moving targets and mixed traps
- Stop, power-off and pause/resume

General zombie sliding during multiplayer pause remains separate from this repair.
