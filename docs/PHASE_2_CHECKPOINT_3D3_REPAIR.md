# P2C3d3 repair - 0.2.19

Approved by owner (C66). Repairs the failed inventory Install and projectile presentation; integrates owner-supplied firing/impact sounds. No Workshop upload or multiplayer enablement.

## Changes

- Inventory Install uses the carried item's actual container and validates native selected input, independent of the boolean returned by offering a duplicate item. Clears a different selected input before offering the intended packed turret. Removes premature client requires of server construction files; native construction globals are checked at click time. Rejections have a short visible message and diagnostic reason. Keeps native rotation, adjacent walking, cancellation and exact contents adoption. Building cheat remains native.
- Small / Medium / Large Expansion Kits. New drops use Base.OMHTTExpansionKitSmall, Base.OMHTTExpansionKitMedium and Base.OMHTTExpansionKitLarge. Detection and 360 use Base.OMHTTModuleDetection and Base.OMHTTModule360. Audit found no other misleading public item IDs. Old Capacity/MotionDetection/Detection360 item definitions remain supported aliases for saves; their exact condition, identity and contents are not rewritten. Old IDs may still appear on existing items or in the debug item list. Internal behavior/Sandbox keys stay stable. New loot uses only canonical IDs.
- Constructed potato turrets commit one potato and power at launch. Flight defaults to 20 tiles/second (Turrets > Projectile speed; 5-100), minimum 50ms. Damage, knockdown, splash and impact sound occur at arrival. Reload and firing cooldown still begin at launch and overlap normally. Damage and cycle tuning are unchanged.
- Arrival rechecks a living same-floor target, loaded source/target squares and unobstructed path. Up to two tiles of target movement is tolerated; larger movement or an invalid target/path becomes a harmless missed impact. It does not retarget. This is a delayed targeted hit, not physical collision simulation. Queue holds at most 128 flights; rejects before resource spending when full; checks at most 16 queued entries and resolves at most four arrivals per tick with a two-millisecond deadline between work units. In-flight shots are transient and discarded on session exit; spent ammo stays spent. Multiplayer remains gated. Legacy foundation debug devices retain their old immediate-hit diagnostic path.
- Brown projectile uses a visible UI-pass primitive with camera/zoom/split-screen projection. Impact follows the hit zombie's current position and lower height when fallen, with larger brown particles. Explicit Launch/Impact events share gameplay timing; the marker never invents its own early impact. Effects cap at 64, expire, and respect visibility/floor. Debug logs include launch, arrival, missed target, screen position and audio pitch.
- Four supplied WAVs are copied byte-for-byte from OMH/Audio/Turrets & Traps. Native sound scripts choose between two thumps and two splats; each playback varies pitch from 0.95 to 1.05. Launch plays at turret, impact at hit position. No native samples are redistributed. Reload audio is still a later selection; [audition selected files](../art/POTATO_AUDIO.html).

## Evidence

Failed 0.2.18 capture: diagnostics/captures/20260930-225142-4179. Console reports client requires of server construction Lua failed, with no Install preview log; old damage preceded the visual impact in the same frame. Duplicate native offers returning false are separately reproduced. We do not claim the log proved that was the only failed-click cause.

Current installed 42.21 source: ISBuildIsoEntity construction/cursor, BaseCraftingLogic manual selection and clearManualInputs, UI projection used by TurretRange, IsoWorld.getFreeEmitter, BaseSoundEmitter.playSound/setPitch and GameSound.getRandomClip. Native script loading verifies four audio clips and emitter methods. Kahlua checks cover early/no duplicate damage, target invalidation, queue caps, effects/sound deduplication, legacy aliases and selected input. Native write/read prove exact contents/charge/cycle restoration. Automated checks cannot establish GPU appearance or audible quality.

Automated result: 2,380 assertions; 45 Lua files; 380 native translations; 118 packaged files. Native write/read passed in 94.5/94.7 seconds. Installation evidence: RELEASE.md.

## Quick complete owner test

Use the existing save; it retains its Sandbox settings. No fresh-world grind required.

1. Restart with 0.2.19. Carry two turrets with different contents. With building cheat OFF, Install the intended one: preview rotates, cancelling costs nothing, placement walks over and consumes only that item. Open Manage and verify supplies. If blocked, report the on-screen message; logs now identify the stage.
2. Spawn new Small / Medium / Large Expansion Kits, Detection Module and 360 Module. Check their corrected item types and names. Swap kits one at a time; old saved kits should still work as Medium with unchanged contents/limits. Over-capacity removal must still refuse.
3. Set Projectile speed to 5 temporarily. Fire at zombies 4-6 tiles away. Expect a visible brown potato leaving the muzzle, then health loss, a centered brown splat and the new impact sound on arrival. One shot consumes one potato. Repeat while zoomed differently and with a knocked-down target; no distant or ground-offset splat.
4. Restore speed to 20. Fire several shots manually and automatically: two thump/splat variants with subtle pitch changes, unchanged reload/fire-rate behavior. Briefly move a target behind a wall during slow flight if convenient; no damage through the wall.
5. Pick up a loaded turret, Install it, save and reload. Ammo, components, battery charge and effective settings remain. Report Test Complete and remaining visual/audio issues.

Next planned checkpoint remains the supported-firearm mount prototype (vanilla pistol, pump shotgun, bolt-action rifle), before multiplayer certification. No firearm implementation is part of this repair.
