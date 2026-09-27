# P2C2 vault correction / 0.2.5

Approved 2026-09-27 after the failed rendered 0.2.4 test. This is an SP development candidate, not player acceptance or multiplayer certification.

## Changes

- Native `OnContextKey` supplies Interact input; automatic approach reads the player's native running/sprinting state, facing, safety checks and ignore-auto-vault flag. There are no hard-coded keyboard bindings. Both paths call the native low-fence entry, preserving its movement parameters and trip calculation. A right-click option remains an alternate route.
- Low-fence Hoppable flags remain absent: the installed `IsoMovingObject.checkHitHoppable` has a zombie route that bypasses the tall-fence guard. Do not combine Hoppable and TallHoppable flags as a supposed player-only fence. The small player input adapter retains native zombie-blocking thumpable collision, without teleporting or making the object globally passable. The rendered sprint transition still needs owner testing.
- Collision metadata now includes the native collideN/W edge. Placement draws the actual blocking line. Separate N/W ledger reservations allow perpendicular edges to share a corner tile, while parallel/opposite-facing duplicate edges remain blocked. The 1x2 part footprint, two-part identity and shared health remain. This permits a closed perimeter; it does not invisibly fill an empty gap in an existing arrangement.
- Debug > Show Collision draws nearby actual edges and spike-facing arrows. It defaults off; bounded nearby scans refresh four times per second. Existing developer textures remain placeholders, not final artwork.
- The front scratch is applied once on crossing the edge during the native animation, including a native fall that crosses it. Interrupted attempts before contact do not roll. Scratches do not force a trip. Rear crossings avoid spike scratches but retain normal native movement risks.
- Pickup/repair use a bounded, collision-checked cardinal approach from either side. Already-adjacent players do not walk into the target. A blocked route is refused; stalled movement cancels after three seconds without progress, with a 20-second total approach limit. Native movement/cancel controls still interrupt the approach. Ten-second tool-free servicing and full-condition pickup remain unchanged. Menu labels are Pick up / Repair with a short duration tooltip.
- Sandbox pages: General, Spike Barrier, Debug. Barrier damage defaults to 10 and shared HP to 100. Vault Scratch Chance is integer 0-50, default 5: zero disables spike scratches, one always scratches, N means 1 in N. Show Collision is independent of test commands. Future implemented defenses receive their own pages and useful tuning controls; no inert future options added.
- Preserved the pre-existing owner-supplied mod-list icon and its cumulative changelog note.

## Native evidence and limits

Reviewed the local pz-modding-practices, pz-lua-best-practices and pz-multiplayer-42 skills, including the vanilla-first source map. Current installed B42.20.4 classes (loose overrides before jar classes) were extracted and decompiled under `diagnostics/captures/20260927-145648-1661/native-code/`.

Relevant installed symbols: `IsoPlayer.doContext` / OnContextKey, `IsoMovingObject.checkVaultOver` / `checkHitHoppable`, `IsoGameCharacter.climbOverFence`, `ClimbOverFenceState.setParams` / `enter` / `shouldFallAfterVaultOver`, `IsoThumpable.TestCollide` / `isHoppable`, and both pathfinder SquareUpdateTask implementations. Vanilla Lua: `media/lua/shared/keyBinding.lua`, `media/lua/client/TimedActions/ISClimbOverFence.lua`, `WalkToTimedAction.lua`, `media/lua/server/BuildingObjects/ISBuildIsoEntity.lua`, and `media/lua/shared/luautils.lua`.

The installed default bindings distinguish Shift (Run), Left Alt (Sprint on Windows) and E (Interact). Native running and sprinting vaults can trip; sprinting adds a base risk and character condition/traits/fitness affect the calculation. No custom trip probability replaces vanilla. High-wall struggle/failure is a different state and is not used.

Automated evidence lives in `diagnostics/v0.2.5/`: 585 Kahlua assertions, 22 runtime modules, 103 native translation keys and 23 native packet serializations pass. Native write/read smoke processes completed in 77.0 / 75.2 seconds, including 16 objects, both pathfinder classifiers, four crossing directions and 12 run/sprint parameter cases. Kahlua tests cover input routing, corner ownership/health/removal and round-trip persistence, scratch settings/contact timing, and service routing/stalls/cancellation. Native fixtures verify edge collision, both pathfinder classifiers, public low-fence entry, run/sprint parameter preservation, and native serialization across processes. Animation variables in headless traversal fixtures are supplied by the test. These do not prove rendered client transitions, visual alignment or zombie behavior during an actual vault.

Local package installed and all 75 files verified against the manifest/archive; source is annotated `test/v0.2.5` (`90f7fe7`). [Install evidence](../diagnostics/v0.2.5/local-release.json). A restart is required; no rendered acceptance is claimed.

No installed game files, saves, keybindings, sibling mods, remote repositories or Workshop listings are changed by the package.

## Owner test

1. Restart PZ and confirm **0.2.5** in the test menu. Use a disposable SP save, normal speed, No Clip off and God Mode off. Enable Diagnostic Logging and Show Collision in the Debug Sandbox page; Build Cheat can cover ingredients.
2. Build/deploy in all four orientations. Follow the solid preview line. Join straight sections and close a rectangle by sharing perpendicular corner tiles; parallel overlap must remain rejected. Walk around the complete boundary: no gaps across the displayed lines. Existing incorrectly spaced barriers need repositioning; older full-square barriers need pickup/redeployment.
3. Use your configured Interact control (default E), then Run (Shift) and Sprint (Left Alt) into each edge from both sides. Expect the low-fence animation and native trip behavior. No right-click requirement, high-wall animation, teleport, or repeat bouncing. Try a blocked landing too.
4. Test Scratch Chance 1 from the spike side, then 0: one scratches at crossing contact, zero still permits vaulting without spike scratches. Rear crossings do not scratch. Return to default 5. Trips remain independent; a healthy character is not guaranteed to trip during a short sample.
5. Let zombies approach straight sections and corners, including during your vault. They should remain blocked and thump; front/side retaliation defaults to 10, rear to zero. Damage one barrier at a shared corner and check its neighbor keeps independent durability.
6. Repair and pick up from both sides and from a short distance. No walking into the barrier; each service takes ten seconds and cancels on movement. Block the approach and confirm refusal/cancellation. Pickup yields exactly one full-condition item and removes only its own pair. Destroy another barrier and check cleanup.
7. Save/reload the remaining joined barriers. Check collision, independent conditions and settings. Confirm General / Spike Barrier / Debug pages and the collision toggle. Exit to menu and reply **Test Complete** for log review.
