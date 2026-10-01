# 0.2.19.1 - hidden compatibility items and barrel-origin projectile

Owner reports that 0.2.19 otherwise worked well, but the item-spawn list exposed both legacy and canonical component definitions. That was a presentation defect in the compatibility implementation. The projectile also visibly started at the head center.

The owner subsequently reports a stutter every time the turret shoots; the same patch includes targeted firing overhead reduction and stage timings.

## Changes and evidence

Five old definitions (ModuleCapacitySmall/Capacity/CapacityLarge/MotionDetection/Detection360) now use native Hidden=true. The actual installed ISItemsListViewer.initList predicate excludes hidden scripts. They remain registered and usable for old saves; current kit/Detection/360 types alone appear in the spawn list and normal loot. No inventory conversion, item deletion, obsolete flag or menu override.

Projectile presentation begins at the barrel tip: placeholder local +X 0.55 multiplied by item scale 0.512 and the engine's non-vehicle scale 1.5 gives a 0.4224-tile forward offset. Native current Core.DoPushIsoStuff bytecode confirms the scale; the exported model and original MuzzleMarker confirm its local position. Render scale and muzzle metadata now live together. Direction follows the committed shot vector, including diagonals and 360 coverage. Near targets clamp the offset to half their distance, and zero-length vectors stay finite. Impact deadline, damage, reload and cooldown are unchanged. No new balance option is needed for an asset alignment value.

Firing overhead: the 0.2.19 capture measures 179 shots with a median 4ms / maximum 7ms inside the previous firing instrumentation, excluding preparation and the rest of the game frame. That is evidence of synchronous overhead, not proof of the full stutter cause. Hybrid firing now reads its inventory once, skips rebuilding unchanged turret configuration and avoids resetting detection after each shot. The sprite fallback still refreshes after a successful shot, and real component/setting changes still refresh normally. Ammo, power, aim and collision validation remain authoritative at launch.

High-frequency shot telemetry now queues up to 256 scalar records and formats/prints at most two per tick, with a one-millisecond deadline checked between entries. Original event timestamps are retained; output sequence/frame can differ from event order, and suppressed counts expose overflow. The duplicate unguarded potato-shot print is removed. Diagnostic toggle/reset clears pending output. New prepare/combat/refresh/effects, direct-hit/reaction/splash, audio and initial-render timings separate work for the next capture. No claim of a measured FPS improvement is made before owner testing.

Regression checks cover bounded diagnostic draining, no synchronous log output, queue limits and a single inventory scan/no refresh on a hybrid shot. They also cover eight headings, nearby/zero-distance targets, unchanged launch facts and flight deadline. Native checks use the game's item-list visibility predicate and require exactly twelve visible components, five hidden aliases and no duplicate behavior entries; aliases must still instantiate and retain their native save behavior. Existing hidden Capacity is included in loaded-turret persistence fixtures. Full native write/read evidence and installation status are in RELEASE.md. This cannot prove final on-screen alignment at every camera zoom.

The 0.2.19 test capture is diagnostics/captures/20260930-235954-5110. It records successful Install preview and delayed impacts. Owner's positive test report is retained; the duplicate/muzzle corrections and reported firing stutter need player checking.

## Focused owner test

1. Restart with 0.2.19.1 and reopen the item-spawn list. Search OMHTT: each Expansion Kit tier, Detection Module and 360 Module appears once, using the current item type.
2. Open an existing turret containing an old kit/module. It still works and keeps its contents; do not replace it just to change its old internal ID.
3. Fire a few shots facing two different directions, with Projectile speed 5 if helpful. The brown potato starts at the barrel end and the existing impact/sound timing remains synchronized. Restore speed 20 if changed.
4. Let it fire about ten shots with Manage closed, then a few with Manage open. Check whether each-shot stutter remains; leave diagnostic logging on so stage timings are captured.
5. Save/reload once with an old component installed. Confirm it remains usable, then report Test Complete and whether any stutter happens at launch or impact.

Supported-firearm mount remains the next planned feature checkpoint; this patch resolves the reported usability issues and removes confirmed firing overhead.
