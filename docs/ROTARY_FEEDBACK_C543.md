# C543: rotary contact gaps and delayed wakeup

2026-11-01. Owner reports less frequent rotary damage and delayed wakeup after 0.2.71.7. The tested head was Rotary Blades with Enhanced Firing, Enhanced Detection and 360; Rapid Fire may also have been installed. This is failed connected acceptance, not approval for another gameplay change.

## What the capture establishes

Both client and server load 0.2.71.7. Server summaries record ten rotary attempts and ten positive damage completions, with no rotary rejection counter. Client summaries record ten owner applications, averaging 180.5 ms from the observed contact and peaking at 261 ms. Eight damage displays are counted separately. These counters do not identify all blade crossings or prove that none were missed before admission.

Turret detailed logging remains off. The server's normal active update interval averages about 100 ms; it also has a 1,253 ms maximum gap. Accepted owner reports average about 110 ms in transit. The capture does not establish the number of concurrently scheduled turrets, exact module counts, individual wake transition times, or the cause of every live miss. It therefore cannot quantify the reported worsening versus the previous session. The continuing server pause oscillation is a separate finding, not a substitute explanation for normal-speed misses.

## Reproduced underlying defect

`TurretAutomation.tick` services at most four entries per invocation under its existing shared budget. Twelve entries therefore give a turret one turn every 300 ms on a 100 ms server loop, even when every other entry costs no time. This is not a 300 ms network assumption.

`TurretRotary.contact` checks motor history from `max(observedAt - 250, previousObservation)` through the latest observation. When the turret is revisited every 300 ms, that leaves 50 ms of motor travel unchecked. The visual motor continues rotating. A standing target whose bearing repeatedly falls into that gap can receive no hits at all. Raising a timeout alone would not establish where a moving target was during the missing interval.

Detection and wake progression use the same scheduling path. `R.contact` marks a scan's target, but `entry.detectedTarget` is committed only after the scan completes; Standby sees it on a subsequent service. The one-second wake and 0.25-second alert delay start after discovery, rather than when the zombie first enters reach. Additional queue/crowd delay therefore adds to the intended wake duration.

The replay executes production `TurretAutomation.tick/step`, `TurretRotary.step/contact`, motor history/crossing geometry, shared owner positions and Standby. It uses a stationary standing zombie, two-tile range, 360, Enhanced Firing's 200 degrees/second, 100 ms owner reports delayed by 100 ms, and 30 seconds per trial. Other scheduled entries are zero-cost fixtures; damage completes immediately. This deliberately excludes network rejection, knockdown, power exhaustion and expensive competing work as explanations.

| Scheduled entries | Target angles | Angles receiving zero hits | Wake begins | Motor begins |
| --- | --- | --- | --- | --- |
| 1 | 36 | 0 | 100 ms | 1,400 ms |
| 4 | 36 | 0 | 100 ms | 1,400 ms |
| 8 | 36 | 0 | 200 ms | 1,600 ms |
| 12 | 36 | 5 | 300 ms | 1,800 ms |

The 12-entry trials apply 961 hits across 1,128 geometric crossings. Counts near the end of a trial can differ by one because the latest 100 ms observation is still in flight; that cannot explain an entire zero-hit trial. An initial focused 47-degree replay received zero damage over 32 crossings, versus 32/32 when serviced each tick. The expanded sweep tests every five degrees through the two-arm symmetric half-circle.

Repeating all 144 trials with the exact 0.2.71.6 rotary source produces identical results. This proves an existing scheduling/contact-window defect survived the patch; it does not prove that 0.2.71.7 introduced the owner's observed worsening. Reverting the last rotary change alone does not resolve this reproduced failure.

## Why previous verification missed it

C542 directly called contact with constructed motor history and checked successful, rejected and pending damage. Its scan-footprint case replaced Standby and did not exercise the real scheduling cadence. Those tests established narrow corrections but could not establish sustained contact coverage or wake response under a shared queue. Passing them, even alongside native startup checks, was insufficient evidence for this multiplayer workflow.

[Reproduction](evidence/c543-reproduction.lua) and [sanitized evidence](evidence/c543-findings.json) preserve the failure. The full harness with this optional investigation reports 44,915 assertions; the added assertions intentionally establish defects, not a fix. World, player and network objects remain test doubles; no clients connected to these replays. Two earlier fixture setup failures (an incomplete item double and loading the previous server module while in client mode) were corrected before recording the final comparison. The initial limited angle selection also failed to expose the timing gap; the expanded angle sweep prevents relying on a favorable phase.

## Recommended corrective scope

**1A recommended:** replace rotary's scan-dependent contact sampling with a bounded consumer of the existing validated owner observations, coordinated with one motor timeline. Let the first valid target observation start wakeup without waiting for an entire scan. Keep server damage, energy, module/Horde/XP authority and duplicate protection. Remove the superseded rotary scan/contact path rather than retaining a second parallel system. Preserve shared head definitions, native/unowned and single-player behavior.

Require tests through the real scheduler and contact-report path: crowd counts, target angles and movement, Enhanced/stacked Rapid Fire, cone reversals, mixed turrets/traps, delayed callbacks, lost/stale reports, ownership handoff, pause/resume, power and unload. Record actual coverage and timing, not only callback counts. A limited proof must precede another packaged correction; connected rendering still needs acceptance.

This is a recommendation, not an implemented or performance-proven replacement. Do not blindly increase budgets, replay old damage from a current position, or add another client-authoritative damage path. No gameplay/version/package/install/Workshop/live-server/sibling changes were made in this investigation. **Decision needed: approve 1A corrective scope.**
