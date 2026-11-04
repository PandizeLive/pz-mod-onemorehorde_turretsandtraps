# C361 — Scripted tether prototype

## C364 — Owner reports success; separate mod removed (2026-10-20)

Owner reports the prototype worked and requests using its mechanic in **Tether Dart Trap**. Console inspection confirms the exact debug mod loaded and 13 zombie impact events, alongside gameplay 0.2.58; connected multiplayer remains unverified. The six installed files match C362 hashes and were moved out of Zomboid/mods into local project diagnostics. **The earlier Test now/installed instructions below are historical; the debug mod is no longer installed.** Save activation settings were not edited. [Integration scope, retirement evidence and remaining decisions](checkpoints/R4C2_DART_EMITTER.md#c364--tether-dart-trap-selected-prototype-retired-2026-10-20).

## C362 — Owner-approved local installation (2026-10-20)

After asking whether the prototype was installed, the owner approved proceeding. Installed the clean, separate **OMH Tether Prototype (Debug Only)** / `OMHTT_TetherPrototype` **0.0.1** into `C:/Users/bandi/Zomboid/mods/OMHTT_TetherPrototype`. All six installed files match the native-tested C361 package and source commit `8837d50e61ac8e30e3a9b5c0ccfff0daa3ed7c1c` by SHA-256. The target did not previously exist; no existing mod or save files were replaced. The existing gameplay release remains 0.2.58. Local evidence: `diagnostics/tether-cycle/install.json`.

The prototype is installed but **not automatically enabled in any save**. Enable it for a fresh test world and run SP with `-debug`; MP use requires the same package on server/clients and admin access. The 41 native assertions remain the source validation, not rendered or connected acceptance. No new gameplay balance, recipe, knockdown or Workshop publication is implied.

### Owner test (no damage)

1. Enable **OMH Tether Prototype (Debug Only)** in a fresh test world and launch with `-debug`. Its controls appear in the world right-click menu, not Building.
2. Face a clear lane and right-click ground within four tiles, then choose **Tether Prototype: Place**. A white marker should automatically fire toward standing zombies ahead and retrieve its nail fully.
3. Choose **Link and Pulse Input** in an empty lane. It should fire once without a target. Try **Toggle Held Input**, switch it off mid-cycle, then **Unlink Inputs / Automatic**; finish-current-cycle and restored detection should work.
4. Test two zombies in line, then a wall/window and a moving zombie. Only the first collision should end outbound travel; nothing should lose health. Check cable/nail placement at different zoom levels and behind characters/walls.
5. Remove the marker or wait 60 seconds. It should disappear without lingering cable or extra shots. Report any clipping or errors; inspect console.txt after the owner reports the test.

**Test now.** This installation supersedes the earlier developer-only/no-install handoff below. Live multiplayer and rendered acceptance remain pending until tested.

Owner selected C360 **1A**, authorizing the scripted launch/retract prototype. This supersedes the native-vehicle investigation as the active approach. It does not authorize final crafting, balance, knockdown, or a gameplay release.

## Implemented scope

The separate `tools/prototypes/tether` package contains a shared cycle/geometry library, native world collision adapter, server authority and debug client presentation. It is independent of the installed gameplay packages.

- One nail progresses through outbound, retrieval, reset and ready. No second launch or queued pulse during the current cycle.
- Swept segment/circle collision chooses the nearest standing living zombie. The native square adapter stops at blocked boundaries, windows and unloaded tiles. No return damage or piercing.
- No links: forward detection starts a cycle. Linked: autonomous detection is disabled; a pulse launches without requiring a target, and a held input repeats only after completion. Releasing the input finishes the current cycle.
- The prototype records impacts without changing health. No ammunition, battery, inventory, knockdown or physical force effects.
- Client presentation draws a white technical marker/nail and a gray tether with small cosmetic sag. It interpolates between server-confirmed positions instead of predicting outbound travel beyond a collision.
- Server snapshots have a monotonic serial and authority-session identity. Clients reject malformed, duplicate, reordered and older-session snapshots. Late observers receive periodic current state rather than requiring the original launch event.
- Debug controls are restricted to SP debug mode or MP admins, with owner, distance, floor, numeric and request-rate checks on the server.
- At most eight transient emitters, each expiring after 60 seconds. Active snapshots are limited to 10 Hz, idle snapshots to 2 Hz. There are eight bounded cycle substeps per tick; dense squares fail closed and long stalls cancel without deferred hits.

Temporary fixture values are **6 tiles**, **12 tiles/second outbound**, **4 tiles/second return**, **0.4-second reset**, **0.3-tile collision radius**, and **zero damage**. These are test parameters, not selected balance.

## Verification

`tools/probe_tether_cycle.py` copies only this prototype and its tests to a separate cache and starts the installed 42.21 dedicated server locally, with no connected players. It never installs into the normal mod directory or opens the owner's save.

The native test uses actual `IsoZombie` and `IsoGridSquare` objects for the collision adapter, with synthetic square lookup and wall fixtures. It covers input/detection rules, no queued firing, complete retrieval, misses, first-hit ordering, moving targets, dead targets, unloaded paths, windows, work bounds, stall cancellation, interpolation, message order/session validation and authorization. The real Kahlua compiler also compiles the client renderer.

**Final run: 41 assertions passed in 41.4 seconds; client renderer syntax compiled; clean server shutdown.** No connected clients and no GPU/world rendering were exercised. The clean preview archive matches the six native-tested source files by SHA-256.

Evidence is in `diagnostics/tether-cycle/result.json` and `native.log`; the result records the installed JAR hash, assertions, runtime, and exact prototype file hashes. The source tests and runner are committed. Stock world-generation/map warnings are present in the isolated startup log; they are not represented as prototype failures or a clean whole-game log.

**Not verified:** rendered world layering, zoom/split-screen appearance, real mapped-wall traversal, or live connected-client synchronization. An API/native fixture test is not multiplayer or GPU acceptance.

## Developer-only visual/connected checkpoint

Prepare a fresh isolated debug/client profile using `diagnostics/tether-cycle/OMHTT_TetherPrototype.zip`, generated by the runner with the required empty native media directories; use the same prototype on a disposable local server for connected checks. Do not use the automatic runner's injected test package for player testing. The archive excludes the injected tests. The package uses normal debug right-click controls; its marker is transient, not a Building item.

1. Face a cardinal direction and place a prototype marker within four tiles. Confirm automatic detection launches toward a standing zombie and that the nail/cable return fully.
2. Use **Link and Pulse Input** with an empty lane. Confirm it fires without a target, and does not auto-fire afterward even with a zombie in the lane.
3. Toggle **Held Input** on, then off mid-cycle. Confirm repeat cycles wait for reset and release completes only the current cycle. Use **Unlink Inputs / Automatic** to restore sensing.
4. Put two zombies along the lane, then test a wall, window and a moving target. Confirm only the earliest collision ends outbound travel; inspect the impact log. Health must remain unchanged.
5. Observe at different zoom levels and behind a player/wall. Check cable visibility and layering. Repeat with a second connected observer, including joining during a cycle and packet delay.
6. Remove the marker or wait 60 seconds. Confirm no lingering cable, repeated impact or extra shot. Restart the isolated session and confirm fixtures are gone.

This is a developer checkpoint, not a request for the owner to test the current installed build. Rendered/connected acceptance remains necessary before integration. Final wall-only placement, Controller integration, crafting, health/wear, player collision policy, damage/range/timing and any knockdown are not implemented here. **Installed 0.2.58 is unchanged. Wait for a patch.**
