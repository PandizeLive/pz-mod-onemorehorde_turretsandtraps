# C527 - Rotary stop burst and delayed hits

Owner reports delayed rotary damage and violent spinning after the motor finishes. Decoded the83-frame GIF (5.19seconds) and inspected timestamped samples, captured current local console and read-only SFTP server console/version. Both client and server load0.2.71. This is a failed rotary acceptance result, not evidence that the previous automated checks established smooth multiplayer.

## Confirmed defects

1. `TurretRenderer.animate` switches from `TurretAimView.motor` to the old `sample` path once the last `aimAt` is over1000ms old. `TurretWorld.publishRuntime` correctly stops sending unchanged stationary travel. The two interpolation paths retain separate state. A prior idle sample can therefore replay old unwrapped rotation after the motor has stopped. The actual renderer replay produces18 degrees per10ms at1020ms after the stop, with a180degrees/second motor: ten times its intended speed. C526 tested the motor helper but omitted this renderer/fallback handoff. Replace the competing rotary paths with one continuous display state that holds a stopped/stale motor; do not add idle network traffic to hide the defect.
2. `TurretRotary.contact` obtains fresh square membership from `DefenseActors.square`, then computes distance/bearing and hit positions with native `getX/getY`. `TurretModules.inside` also uses those native coordinates. A controlled production contact replay confirms rejection while an accepted, current owner report places the zombie inside the sweep; the same crossing only registers after native coordinates catch up. Use one validated position/time basis for rotary detection and crossing, with stale-report, ownership, reach and duplicate checks. This proves a delay/miss mechanism, not the exact delay of an individual hit in the GIF.
3. Server console contains45 `missing argument #1 to 'lower'` exceptions from `TurretConditionalHit.impact`, called by `TurretRotary` after an applied hit. It lowercases a nil native animation-state name. Health is applied before this callback; the exception interrupts reaction processing and prevents the following `Proc.release` call. Replace this animation-name dependency with the existing authoritative stance/native reaction checks, and verify shared callers and cleanup. Do not mask the callback with protected calls.

The server log shows approximately100ms update cadence. This and transport remain part of the timing budget, but neither explains away the reproducible replay burst or callback exception. Current logs cannot measure the complete rendered rotary sweep-to-hit delay per victim; add bounded sweep/contact/application correlation while repairing the path.

## Proof and limits

`tools/tests/rotary_feedback_c527.lua` runs the actual renderer and rotary contact functions with controlled world/network adapters. Full harness plus this optional diagnostic passes41,772 assertions. This successful run reproduces faulty behavior; it is not a corrected build. Initial diagnostic attempts corrected PowerShell JVM argument quoting, a too-high burst assertion threshold, and the test actor's native coordinates/authoritative turret registration; the final test requires both rejection and successful control hit.

Captured logs, frames and replay output remain in ignored `diagnostics/c527`; [sanitized evidence](evidence/c527-findings.json). No production Lua, version, package, install, Workshop content or live-server settings changed.

## Recommended correction

**1A - Complete rotary correction:** one render timeline through start/run/stop/idle/restart and packet gaps; validated-position crossing; repair the shared impact callback; bounded sweep-to-visible-hit diagnostics. Reproduce these defects first, then require the corrected checks to pass, including the actual renderer beyond the one-second idle boundary, missing animation state and asynchronous callback cleanup. Verify both rotary heads, cone/360 modes, prone exclusion, mixed modules and shared impact callers. Preserve server damage/death/XP/Horde authority.

**1B - Stop animation only:** leave hit geometry and callback defects unresolved. Not recommended.

High reasoning is appropriate for the correction; Fast is recommended if the full native verification exceeds25minutes. **Decision needed: corrective patch scope.** Prior GitHub automatic approval-review block remains; no bypass attempted.

## C528 approval and follow-through

Owner selected1A. The full correction is implemented in0.2.71.1; see [C528](ROTARY_REPAIR_C528.md). The original C527 reproduction remains a diagnostic of the old failure, not a passing correction test.
