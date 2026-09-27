# P2C2-vault: player crossing and directional injury

Status: next checkpoint authorized 2026-09-27; feasibility probe implemented. Gameplay changes and a new install are pending the collision-shape decision below. The owner requested testing this checkpoint together with the untested 0.2.3 repair. That supersedes the previous sequencing recommendation to accept 0.2.3 first, without marking it accepted.

## Decision presented to the owner

Recommend **fence-style edge collision**, keeping the two-tile construction footprint and one shared durability pool. Each part blocks one aligned tile edge; players can stand on the usable ground behind that edge. A complete barrier still spans two tiles, but no longer excludes players from both entire tile interiors. Zombies must still thump it. No new art is required, although current cube/arrow markers are not a final edge-shaped model.

Alternative: retain full-square collision and defer vaulting. A normal fence hop lands in the immediately adjacent tile; with a full-square barrier that tile is still occupied. The native fence obstacle outcome uses a failure animation, not a general traversal across the whole furniture tile. No teleport, globally passable interval, or silent zombie hopping is proposed.

This choice is pending; no timeout implies consent. Current installed 0.2.3 still uses full-square collision and has no vault action or injury roll.

## Native feasibility evidence

`tools/NativeVaultProbe.java` runs inside the existing isolated native server test, using installed B42.20.4 classes. Invoke through the stable smoke helper with `OMHTT_VAULT_PROBE=1`; evidence goes to `diagnostics/vault-prototype/`, preserving tagged version test logs.

- Constructs actual IsoThumpable edge objects and actual IsoPlayer/IsoGridSquare instances.
- Both directions across north and west edges block native TestCollide and TestPathfindCollide, with isHoppable false.
- Native ClimbOverFenceState.setParams/execute cross the expected edge in E/W/S/N using the engine's own slide movement. Fixture animation variables are supplied explicitly; this is not rendered animation proof or the public climb-entry/landing gate.
- The state's collision exception remains inside the crossing rectangle and floor. No runtime collider flags are temporarily opened.
- Native source mapping: installed ISClimbOverFence.perform calls IsoGameCharacter.climbOverFence; installed state bytecode confirms parameter setup and movement. Historical 42.20.2 source was used only for discovery. Native player entry also uses IsoWindow.canClimbThroughHelper and isPlayerAbleToHopWallTo; these must remain enforced and need runtime acceptance.

The first probe run failed because its reflective grid-square constructor used IsoChunk instead of the installed SliceY signature. The corrected probe passes. No gameplay package files or installed save were changed by these probes. They use isolated test-cache fixtures, with no player connected.

## Implementation after the collision decision

1. Keep ordinary walking/zombie collision closed. New native construction must initialize correct north/west edge orientation for every visual heading. South-facing native build cursors currently pass `north=false`; explicitly handle that rather than assuming sprite heading is collision orientation.
2. Choose a safe existing-barrier migration. Prefer keeping old full-square barriers unchanged until pickup/redeployment into the new model; pickup's full repair is already intentional. Persist the collision model per barrier and explain the one-time redeploy requirement. Do not rebuild live objects in a removal callback or reset their identity/damage implicitly.
3. Offer an explicit player vault through native climb initiation. Validate same level, correct front/rear approach, clear loaded landing, current object identity, and no conflicting action. First scope is front/rear crossing; do not silently assign safe side-entry behavior.
4. Roll once after a verified crossing: front `ZombRand(5) == 0`, rear no injury roll. A failed/cancelled crossing must not apply damage or replay a completed roll. Use a native environmental scratch (no zombie-infection roll); body part/clothing behavior must be documented and verified. Keep random outcomes observable with bounded crossing ID, side, position, result and injury diagnostics.
5. Reject interruption/death/removal/reload edge cases safely without moving the player with Lua coordinate setters. Native actor-scoped collision exceptions must not enable passage for zombies or other players. Keep MP closed until dedicated-server acceptance.
6. Reconcile retaliation's front/rear plane with edge geometry; the current classifier assumes a half-tile-deep solid rectangle. Preserve the approved front/side hazard and safe rear. Preserve paired health, servicing, destruction and bundle behavior from 0.2.3.

## Combined owner test for the future candidate

Do not run this as a claim that a new candidate is installed; supply its exact version when implementation is ready.

1. Restart into that candidate on a disposable SP save with diagnostics on and developer controls available. Check Damage 10 / HP 100, menus and wrapped descriptions. Have a barrier item, free inventory capacity and five loose barriers for packing.
2. Set a barrier to 37 HP; cancel Repair by walking, then finish it: ten seconds to full HP. Cancel/finish Pickup: exactly one item and both halves removed. Redeploy at full HP; pack/unpack must remain five-for-five without XP.
3. Build new barriers in all four headings. Walking across their blocking line must fail. Use the native vault action from the rear: cross to the clear landing without a scratch or movement lock.
4. Cross from the spike-facing front repeatedly: one logged 20% roll per completed crossing, never guaranteed on the fifth attempt. Interrupted/blocked attempts must not roll or teleport. Keep the sample on the disposable character.
5. Block a landing and try again: refusal. Let zombies attack during another player vault: they must continue thumping, with 10 damage at front/side and none from the rear. Destroy a barrier without errors or leftover collision.
6. Save/reload and check collision, orientation, shared HP and item counts. Separately check custom 5 damage / 200 HP and repair-to-maximum behavior. Say Test Complete for console review; broader MP acceptance remains separate.
