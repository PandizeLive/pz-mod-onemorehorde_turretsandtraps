# P1 combat repair record

Version: `0.1.4-p1combat`. Date: 2026-09-25. Development package only; no Workshop upload. Continues P1C2-P1C4, with acceptance pending. Construction remains the developer menu; the user-requested normal crafting/building preview is a separate implementation.

Follow-up: the owner completed a player test. The [2026-09-26 review](P1_COMBAT_OWNER_REVIEW.md) records 26 shots, eight observed knockdowns, no missing texture paths and one native barrier destruction. Full checkpoint acceptance remains pending.

## Owner evidence and findings

Captured [console](../../diagnostics/captures/20260925-234452-4637/console.txt) and [OMHTT trace](../../diagnostics/captures/20260925-234452-4637/omhtt.log) preserve the reported rotation, thumping, knockdown and disappearing-turret run.

- `test-1`, `test-2`, `test-10` and `test-11` fired with negative headings. Object diagnostics show `OMHTT_Aim-1.png` / `OMHTT_Aim-3.png` and `texturePresent=false`. The installed Kahlua remainder operation retains a negative sign; using `% 16` did not normalize those angles. This is a reproduced defect, not an assumed texture streaming problem.
- Barrier health falls during thumping. Retaliation was never implemented; earlier prototype documentation explicitly limited this to aggregate HP observation. Aggregate damage does not identify individual attackers or strike cadence. The owner has been offered a temporary once-per-second exact-active-thumper alternative; it is not included without that decision.
- Earlier `knockdown=true` meant a flag was set, not an observed completed fall. The prototype used 70% chance and ten in-game minutes of target recovery protection. Either could prevent later knockdowns; the old log did not distinguish them. Do not attribute each old failure to chance alone.
- The previous potato cooldown was four in-game minutes. Owner now specifies one shot per second. This patch interprets that as real time, independent of day length / world fast-forward; it remains manual test firing.

## Changes

- Normalize headings into 0-15 without signed remainder. Sprite lookup also normalizes old inputs; server initialization repairs saved negative headings without restoring ammo or shots. Reconciliation refreshes the exact existing object's sprite.
- Store a millisecond deadline and `realtime-ms-v1` clock discriminator in the authoritative record. Migrate the old world-hour deadline once. Refill does not reset the cooldown; new deadlines survive native save-table roundtrip. Future deadlines beyond one interval after clock rollback are bounded on the next attempt. No missed shots are replayed.
- Use native `IsoZombie.knockDown(false)`, establish the front knockdown transition and request a physics reaction only when `canRagdoll()` permits it. Native animated fallback remains when physics is unavailable. Keep the provisional 70% chance; change the provisional shared target recovery guard to three real seconds. Already-down targets do not receive repeated knockdown requests.
- Log `shot-knockdown` with chance roll, failure reason, guard remaining, state and ragdoll eligibility. A bounded queue of at most 12 recent impacts samples actual state/floor/ragdoll flags around 150, 600 and 1500 ms (`shot-reaction-observed`). Sampling may occur later at low frame rates. No claim of completed animation is made from the request alone.
- Preserve the tiny splash, test rounds, SP-only combat boundary, native barrier HP and 64-slot/4-visits-per-tick limits. Direct damage calibration remains below the 3-5 reference-hit design target; this repair does not silently rebalance it.
- Record the owner's [module ideas](../MODULAR_TURRETS.md), including rapid-fire and velocity, as a separate proposal. No modules or inventory ship in this patch.

## Current installed-game evidence

Target: B42.20.4 b0bbce05d5, with loose PZ Optimizer overrides first on the classpath. Current bytecode is saved in `diagnostics/p1combat/*javap.txt`.

- `IsoZombie.knockDown(boolean)` sets knockdown/stagger, clears hit reaction, sets hit force and reports `wasHit`; vanilla `media/lua/client/DebugUIs/DebugContextMenu.lua` uses it.
- `IsoGameCharacter.canRagdoll()` checks SP/MP, the physics option, debug disable, active simulation budget, clothing and state eligibility. It returns false in MP in this installed build. This patch does not override those checks.
- `media/actiongroups/zombie/thump/to_staggerback-knockeddown-ragdoll.xml` requires knocked down, not already on the floor, no active hit reaction, FRONT/BACK attack position, and `usePhysicHitReaction`. Ordinary knockdown and physics are distinct paths.
- `ThumpState.execute` counts native animation thump events and invokes `Thump`. Its time-thumping counter can reset while flesh was recently seen. Neither aggregate barrier HP nor that counter is a reliable per-strike Lua callback.

## Verification

- [Validation log](../../diagnostics/p1combat/validation.log): 113 assertions, seven runtime Lua compilations, 56 native JSON translation loads/substitutions, native save-table roundtrips and 23 serialized packets (maximum 398 bytes).
- New regression cases fire through all 16 headings using the installed Kahlua VM, reject a shot at 999 ms despite a large world-time jump, permit a shot at 1000 ms, preserve the new deadline across serialization, repair a legacy invisible object without restoring ammunition, and exercise knockdown roll/guard/physics fallback diagnostics.
- [Dedicated restart console](../../diagnostics/p1combat/server-restart-console.log): exact version loaded; three translation categories resolved; GlobalModData saved; clean shutdown in 34.3 seconds. No player connected. The smoke-only translation probe is removed afterward and is not packaged.
- [Manifest](../../diagnostics/p1combat/manifest.json): 39 package files. [Archive](../../artifacts/OMHTT-0.1.4-p1combat.zip) and managed local installation use those exact hashes.

World, zombie and rendering calls in behavioral tests use explicit doubles. Those tests prove request logic, not native animation, corpse/loot behavior, visual timing or connected multiplayer. Player validation remains necessary.

## Owner test

1. Restart PZ, load the SP test save with Foundation Test Controls enabled, and confirm the menu shows `0.1.4-p1combat`.
2. Inspect a previously invisible turret. It should regain its white cube/arrow with the same ammo and shot count; no replacement placement is needed.
3. Fire at nearby zombies in several directions, especially southeast/southwest. The turret should remain visible after each shot; use the debug refill when empty.
4. Try firing again immediately, then after one real second. Early attempts should spend no ammo; a valid target should permit the next shot after one second. Firing is still manual.
5. With ragdolls enabled, shoot a standing thumper several times. Some rolls can fail; after a successful fall, allow it to stand and the three-second guard to expire before comparing another knockdown. The log will record the reason and actual resulting states.
6. Save/reload and inspect the same turret for matching ammo/shot count and visibility. Say testing is complete so console.txt can be reviewed. Barrier retaliation is still pending the separate choice.
