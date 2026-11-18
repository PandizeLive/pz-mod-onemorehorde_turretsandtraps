# C545 Rotary Blades connected retest

On November 2 the owner reported inconsistent Rotary Blades damage on their multiplayer server and requested investigation. The local client console, remote running server console and remote package identify 0.2.71.8. The publisher also confirms the unlisted upload of item 3828638252 from test/v0.2.71.8 at source 9e2d636. The client recorded 40 damage, two tiles of reach, zero critical chance and eight installed modules in the inspected turret. The module identities for this particular session were not logged.

## Connected evidence

The owner could not tell whether a standing zombie stayed still through several blade passes during the live test. The server counted 36 rotary contacts admitted to damage and 36 positive completions. The client counted 36 owner applications and 36 damage displays. Time from the supplied observation endpoint to owner application averaged 110.2 ms and peaked at 187 ms. The timestamp describes the end of a movement sample, so it cannot measure visible blade impact precisely. These are aggregate counts for the capture. Turret detailed logging was off. A contact that never made it to damage has no per-victim trace. Across all defenses the server accepted 17,770 observations, rejected 955 for position and 15 for age. Those rejections cannot be assigned specifically to the blades.

## Reproductions on the released code

The [optional Kahlua probe](evidence/c545-rotary-replay.lua) runs through the validated report handler, indexed rotary listener, actual line check, motor and hit admission. The world, actors, report delivery, clock and damage sink are controlled. [Measurements](evidence/c545-rotary.json).

1. **Walking across the sweep.** On open ground a blade travels from 0 to 20 degrees in 100 ms. A standing target 0.45 tiles from the center walks from +3 to -9 degrees. Its path crosses the arm, yet the turret submits zero hits. The target travels under one tenth of a tile. The reverse failure also occurs for a path from -9 to +11 degrees that stays behind the arm throughout. Across 262 short paths, an independent check of the target's side of the turning arm at 0.1 ms intervals counted 126 crossings. The released code missed 21 and admitted 25 extra. These cases are deliberately selected geometry, not a server miss-rate estimate. Both endpoint positions and motor travel were verified in the fixture. Rotary.contact uses the midpoint bearing within each slice, treating a moving zombie as stationary during that slice.
2. **Standing still between motor updates.** A stationary target, 100 ms ticks and reports, 65 ms transit and 1,000 degrees of motor travel produced six expected contacts. Delivering every report 15 ms after a tick counted all six. Delivering every report 85 ms after a tick counted zero. In the second trace each observation describes a moment 20 ms beyond the newest motor sample. Rotary.contact stores the new frame before finding that travelAt cannot yet resolve it. When the motor catches up the discarded interval is never tested. The capture cannot establish whether the real packet phases followed this synthetic schedule.
3. **Falling and getting up.** The validated owner report carries down/prone, but rotary reads the server's separately replicated zombie stance for the observation. A standing report paired with a down server state missed the control strike. A down report paired with a standing server state admitted it. Stance agreement is necessary at both ends of a swept contact. The capture has no paired stance trace for any specific miss.

The earlier C544 check looked at many angles with evenly timed snapshots. Its moving examples crossed the range boundary along a fixed bearing and its stance fixture changed both copies together. Those tests could pass while these failures remained. This diagnostic's assertions describe the released failures and are separate from a future patch's acceptance tests. To rerun after compiling the release harness, pass the repository root and docs/evidence/c545-rotary-replay.lua as the two arguments to KahluaCheck. Use the 0.2.71.8 source and test harness for this historical replay.

## Proposed correction

**1A, recommended.** Replace rotary's sampled-bearing test with a crossing test using target motion and blade motion over the same time interval. Use the existing server motor history. Retain the unprocessed portion of a validated observation until motor history covers it, then consume it once, with bounded expiry and cleanup on identity change, disappearance or pause. Use the validated stance at observation time for owned zombies, and native stance for native observations. Reset continuity on falling, rising or ownership change. Keep one damage transaction per real arm pass, preserve target policy and range, and use the existing diagnostics to count deferred or discarded intervals during the connected check.

A patch should pass the stationary phase pair, sideways misses and false hits, stance disagreement, both rotation directions and arms, cone reversals, packet loss and stacked speeds. Compare the geometry with an independent reference and check the actual health transaction separately. A connected retest still determines what the player sees.

**1B.** Capture one isolated run with Turret Detailed Logging before changing gameplay. Existing traces identify admitted hits and motor snapshots but cannot identify every skipped interval. This can narrow live attribution while leaving both reproduced contact failures in the current build.

## Simpler implementation to try first (November 2)

The owner asked whether the repair overcomplicates rotary combat. Keep the physical pass rule and server damage transaction. Each motor advance can consume nearby targets' validated movement and stance over the time the motor covers. An early observation stays available for the next advance. Try the target's change of side relative to the turning arm as the crossing test. Split at reversals and distinct arm passes and consume each crossing once.

An independent endpoint side-change calculation matched all 262 short straight paths against the 0.1 ms reference. Testing only the latest target position against the swept sector missed 22 crossings and added 22. These cases cover one short forward sweep. Before packaging, check both stationary packet timings, pivot crossings, grazing contacts, reversals, stacked speeds, posture changes and actual health deductions. A periodic area attack could hit while both arms face elsewhere. This proposed simplification of 1A awaits the owner's choice.

## Hitbox clarification (November 2)

The owner proposed disabling contact while stopped and rearming a blade after a rotation. In option 1A each moving arm has a logical hitbox. The server checks the area it swept between motor samples against nearby standing targets. Each arm remembers which zombie it struck on that pass so it can still hit the rest of a crowd. Full rotation gives the same arm another pass; with limited travel the return stroke can hit again. A stopped arm deals no new contact damage. A global reset per hit or a mandatory full turn would change crowd or cone behavior.

On the installed 42.21 build, LuaManager.GlobalObject.Render3DItem calls WorldItemModelDrawer.renderMain. The two rendered arms use this client item-draw path. It supplies no server blade-overlap event. A logical swept hitbox can reuse the nearby actor index and server damage path. Verify crowded update cost and real health changes before packaging. This clarification is a proposal, pending approval.

## Skipped updates and client authority

For 1A, compare the full supported interval of motor travel and validated target movement, even if intermediate evaluations were skipped. Handle each distinct arm pass within that interval once. If movement or posture history has a gap large enough to make the crossing unknowable, resume from a fresh observation. Stationary endpoints alone cannot prove a zombie stayed still in between. Verify short gaps, expiry, duplicated reports and ownership handoffs against health changes. Live data loss precludes guaranteeing every visible crossing.

The client simulating a zombie already reports its position and stance and applies server-requested damage. That client could also present a predicted impact or report a candidate contact if connected tests establish a need. Its view of the motor can lag. Giving it final say would also let a modified client claim or suppress hits, affecting kills, XP and Horde rules. Keep final contact acceptance with the server for the proposed repair. Client contact hints are a separate fallback, pending a measured need.

## November 2 decision

The owner selected 1A after confirming shared coverage for the Bat, Blades and custom two-arm rotary heads. The implementation and test results are in [0.2.71.9](TEST_v0.2.71.9.md).
