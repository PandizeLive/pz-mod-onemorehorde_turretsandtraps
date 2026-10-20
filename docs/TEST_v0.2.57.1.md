# Test 0.2.57.1

## Automated evidence

- Installed-game Kahlua/API/content validation passes **25,857 assertions** (308 source files, 402 packaged files and 343 local UI translation keys). It covers compact 4/4/4/4 geometry, equal action-button sizes, removed window controls, linked power authorization and five-second pickup/placement at normal and accelerated SP speeds.
- Native dedicated fixtures pass 2,000 fractional Controller battery debits, verify LightSwitch registration, and accept twelve player-built wall orientations across three wall tiers while preserving host health and rejecting the wrong edge.
- Native write/fresh-process read checks exercise exact items, power, accepted turn/reload/shot cycles and persistence. These use zero connected clients and are not multiplayer acceptance.
- Separate Traps-only, Turrets-only and combined startup checks pass (67.9 / 65.0 / 65.5 seconds). Evidence is under diagnostics/v0.2.57.1.
- Geometry traces were rendered and inspected for both management windows. These are test drawing traces, not screenshots of the game renderer or proof of native inventory clipping/audio playback.

## Focused owner test

1. Restart and confirm **0.2.57.1**. Resize both windows and inspect title/footer, corner grip, equal Remove To/Set Aim buttons, compact centered module rows and Connections headings/groups. No lock/pin/collapse buttons should remain.
2. Leave a charged Controller running and exercise assigned-device fallback. It should not alternate Online/Offline. A released linked trigger should keep its turret off without a brief manual startup; press the button/plate and confirm the turn/reload/shot completes, then power releases.
3. Press a button and listen for the light-switch cue. Inspect the Poke Floor's white outlined marker and raised/lowered state.
4. Place barbed panels on player-built walls of each tier/orientation. Verify the host is retained and the panel can be serviced normally.
5. Time pickup and portable placement at normal SP speed (five seconds), then fast-forward. Repair remains ten seconds. Test interruption and exact-item recovery. Multiplayer native placement retains its skill-dependent duration; exact five seconds remains unresolved.

Fresh test worlds remain the supported policy. Owner-rendered and connected-player testing are pending, not passed. The earlier 0.2.57 snapshot remains available for rollback.

## Action audit

Turret, barrier, bed, barbed-panel removal, Controller/trigger and Poke Floor service all use the same game-speed-aware SP elapsed-time rule: five seconds to pick up/remove, ten for repair/reinforcement. MP custom service uses fifty native duration units per second. Inventory transfers, magazine operations, pack opening and instantaneous commands retain their native timed-action progression and distinct intended durations; they do not use the former unscaled real-time accumulator. Portable SP deployment uses the shared PlacementTiming hook across BarrierPlacement, ControlClient and TurretInstall. Native MP placement remains the documented exception.

Verification caught an obsolete placement test that reused an already-wrapped action, and a package preflight correctly rejected the transient source/package mismatch while the final Controller timer was being rebuilt. Those were corrected before final release verification.

## Installation and rollback

Installed 2026-10-19 from immutable `test/v0.2.57.1` / `69fa39088f589a140bcd81a286b73a99afa20daa`. All 308 source and 402 tagged/package/installed/archive files match; both 0.2.57 package backups verify. [Release record](../diagnostics/v0.2.57.1/local-release.json), [native write excerpts](../diagnostics/v0.2.57.1/corrections-write.log), [native read excerpts](../diagnostics/v0.2.57.1/corrections-read.log), [validator](../diagnostics/v0.2.57.1/validation.log). Full native logs remain local. No Workshop upload or merge.
