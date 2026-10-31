# 0.2.70.6 - C503 multiplayer contact and presentation corrections

Owner approval: C502 **1A**, with an explicit question about Martyrdom. [Approved contract](MULTIPLAYER_FEEDBACK_C502.md#c503-approval-2026-10-28). No damage/stacking changes, new loot, sibling changes or Workshop publication.

## Contact and conditional damage

- Dedicated-server Bed, Barb/Wire, Tack and trigger contact now uses one shared watched-square driver. SP retains native zombie updates. Work resumes across ticks with ceilings of 64 tiles, 256 actors and two milliseconds between actor operations; a complete pass waits 50 milliseconds. Overlapping hazards share watched tiles and existing contact cooldowns. This is cooperative budgeting, not a guarantee that one engine call takes less than two milliseconds.
- Unloaded tiles leave the active work list and return through LoadGridsquare. Removing/reinitializing a hazard releases its watches. With no loaded watched tiles the driver makes no square queries. There is no per-trap global zombie scan or client-supplied damage amount.
- Current 42.21 NetworkZombieVariables only applies IsOnFloor to reanimated-player zombies. Owned server zombies therefore use the replicated realState names for landed/recovering/falling states. Bed landing and rotary exclusions use this shared interpretation; ordinary bumped/shove state is not guessed to be a landing. The custom trip's native transition goes to getup.
- Barrier strike reports resolve actors from the validated collider's nearby squares, retaining identity, ownership, geometry, state and repeat checks. They no longer require a zombie-update-populated ID index. Stale trap credit records cannot load absent Traps code when only Turrets is enabled.
- Deferred zombie maximum health now settles on a bounded server tick queue after spawn customization, without waiting for a turret hit. Initial Blow/Execute preserve their configured values and unknown-baseline behavior.
- Poke starts on its first eligible occupied observation and completes one overdue pending strike before retracting. Targets must still occupy the trap at the strike; no catch-up damage batch is added.
- Martyrdom already has a tick-scheduled burst path. Root and one-generation Synergy follow-up damage are regression targets; it is not converted into contact damage.

## Client presentation

- Server-confirmed actual loss supplies a nearby damage notice to the optional Pixel Strike adapter. Duplicate delivery is suppressed; each local viewport requires same floor, visible square and proximity. Captured coordinates survive lethal actor removal. Player popup preferences remain respected; no synthetic player attack is emitted.
- Automatic labels render from kind/head/number in the viewing client's language. Legacy saved automatic displayName text no longer wins over localization. Explicit custom names are retained, including strings that resemble translation keys. Portable records retain their identity.
- Turret presentation interpolates received headings over bounded sample intervals on the wall clock. Rotary travel is sent as an unwrapped scalar so full turns retain direction. Missing updates stop at the last confirmed value. Head identity changes reset the visual sample; ammunition refreshes do not. The server still owns aim, hits and timing.
- Native pack timed-action serverStart/serverStop/complete drive an observer icon. Other living players within eight tiles on the same floor receive opening state, without rewards. The client additionally checks visibility. The 24-pixel existing pack image clears on cancel/completion, leaving range or expiry. Active actions alone refresh observers; idle server work returns immediately.

## Evidence and delivery

See [verification and owner checklist](TEST_v0.2.70.6.md). Native source inspection uses the installed 42.21 jar and action-group XML; raw diagnostic material remains local. The next cumulative Workshop draft starts after the confirmed 0.2.70.5 upload documented in RELEASE.md. Previous shipped changes are not repeated in this draft.

No new world is required. The server and both clients must receive the same new Workshop build and restart before connected acceptance.
