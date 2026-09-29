# 0.2.13 — turret aiming, range and balance

The lowered base left the head too high, and positive combat heading rotated the native model the wrong way. Lower the head by the same 16 screen pixels and negate heading for native model yaw. Selection now shows actual manual range and an aim arrow; General can disable it.

Manage uses Magazine. Default damage becomes 35, with overlapping two-second reload and cooldown; magazine 1 and total ammo 85 remain. Existing saved Sandbox values are preserved. Current manual targeting remains 360 degrees; a forward restriction and module effects remain separate decisions/checkpoints.

[Evidence and complete five-step test](PHASE_2_CHECKPOINT_3_AIM_RANGE.md). Native projection checks cover eight headings and vertical offset. Rendered acceptance remains pending; no Workshop upload or remote push.
