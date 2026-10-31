# C529 - Remaining Splitter, stabilizer and rotary findings

Owner reports errors, Splitter delay with more than one or two modules, walls built over Poke stabilizers and rotary damage desynchronization. Request is **confirm findings and compare**, not approval to change gameplay. Latest local console and read-only SFTP server capture both load0.2.71.1. [Sanitized evidence](evidence/c529-findings.json). Credentials remain outside the repository; raw logs remain ignored.

## Comparison with C527 / 0.2.71

| Area | Prior evidence | Current evidence |
| --- | --- | --- |
| Shared Impact error |45 server exceptions from lowercasing a nil animation name |Zero matching exceptions or server Lua RuntimeExceptions in this capture |
| Other mod Lua errors |No captured client RuntimeException |Two ControlAccess.state / ControlTriggerView.render exceptions during IngameState.exit |
| Rotary display/application |Old capture lacked the new rotary timing counters |37 owner applications:5763ms total,155.8ms average,215ms maximum from sampled position;31 display samples:156.2ms average,215ms maximum |
| Rotary position/sweep timing |Geometry used native coordinates despite newer owner position |Report age at evaluated hit reaches201ms; sweep-job age reaches about100ms. Accepted reports and sweep travel still need one contact-time basis |
| Stabilizer exclusion |OMH placement reservation tests passed |Reservation applies only to participating OMH placement paths; ordinary vanilla construction has no integration |

Different capture durations and combat loads mean raw event totals are not improvement percentages. The37 owner applications and31 visible popup samples do not prove six missing hits: popup eligibility/suppression differs. Global damage queue maximum304ms includes all damage families and must not be presented as rotary-only. No repeated end-spin report was supplied this turn; previous production regression remains fixed, while live overall rotary acceptance remains failed.

## Splitter mechanism reproduced

`TurretVolley.tick` shares128 incremental operations per scheduler visit and up to1ms wall time. Each child ray advances in0.25-tile steps and scans each entered tile. Firearm `V.split` defers the primary visual into a group, and `V.finish` emits the combined Volley only after every child finishes. Increasing children therefore delays the entire displayed firearm volley. Occupants, other volleys and the global3ms scheduler can add work. This is an algorithmic wait, independent of internet transport.

The optional `tools/tests/feedback_c529.lua` invokes production ray creation/tick/finish over empty loaded tiles,100ms visits and an unlimited wall-clock deadline to isolate the128-operation ceiling:

| Splitter children |10-tile firearm last visual |30-tile firearm last visual |
| --- | --- | --- |
|1 |0ms |0ms |
|2 |0ms |100ms |
|4 |100ms |300ms |
|8 |200ms |700ms |
|16 |500ms |1500ms |

Physical Potato children launch immediately and finish at their expected500ms/1500ms flight in these same empty-path cases, independent of count1-16. This test does not establish that all heads share the observed delay, and does not model dense occupants, actual network transit, other workers or damaged-victim serialization. The user's head/loadout is requested before attributing their exact event. Full harness plus this investigation passes43,717 assertions; this successful run reproduces a defect, not a repaired candidate. The different optional audit explains the count difference from C528's43,794.

## Stabilizer boundary

`ControlPokeFootprint.reserved` finds a center's versioned five-tile reservation. Callers are OMH Barrier/Bed/Turret/Control/Tether placement; `PlacementTiming.preview` only decorates the OMH Poke cursor. The bars are client-rendered hardware and create no native object on the arm tile. Installed42.21 `ISWoodenWall.isValid` checks wall collisions, objects, materials and floor support, not this reservation. `ISBuildIsoEntity.isValidPerSquare` calls recipe-specific validation; vanilla recipes have no OMH callback. Thus a free-looking arm tile is not blocked for ordinary building. Reverse-order placement was missed by the original tests.

The repair should participate in native construction validation on both preview and authoritative completion, including edge placement and multi-tile objects. Preserve walking over low bars. Avoid post-build deletion, collision walls or per-frame scans. Verify ordinary wall first, then relevant native build paths, both placement orders and pickup releasing the reservation.

## Remaining rotary timing and client error

The new coordinates remove the old native-position wait, and the nil-name error is absent. However `TurretRotary.contact` compares `job.before/after` travel with the latest accepted owner position, which can describe a different instant. Client `TurretAimView.motor` displays predicted current travel while damage still requires observation, server evaluation and owner application. The captured155.8ms average/215ms maximum supports a visible timing gap; it is not a complete measurement from first rendered blade contact. Aggregate logs cannot reconstruct individual blade angle, actor position and applied hit at one timestamp. Raising expiry or global work limits would hide neither mismatch safely.

The two client exceptions route through `ControlAccess.state` line40 while `IngameState.exit` is rendering. Its `not isClient()` branch attempts to use server ControlWorld after the multiplayer session is shutting down. This is a renderer/session-lifecycle cleanup problem, not evidence the former combat callback still throws. Repair view lifetime and explicit world/session ownership; do not add a protected-call blanket around rendering.

## Recommended next scope

**1A - Combined underlying correction (recommended):** remove the full-volley display wait and replace range-increment scanning with bounded traversal that scales with crossed tiles/occupants; cover the reported head once confirmed, firearm and physical children, stacks1/2/4/8/16, and busy mixed combat. Integrate stabilizer reservations with native build preview/completion. Align rotary sweep evidence and presentation around a defined timestamp, prove moving crossings and both clients, and cleanly retire client views at disconnect. Keep server damage/death/Horde/XP authority. Do not claim live timing fixed from helper tests alone.

**1B - Construction and disconnect error only:** leave Splitter and rotary acceptance open. Lower scope, but does not meet the requested fluent combat goal.

High reasoning is appropriate for1A; use Fast if full implementation/native verification exceeds25minutes. No production/package/install changes this turn. **Decision needed.** Prior automatic approval-review block on GitHub mirroring remains; no alternate push attempted.
