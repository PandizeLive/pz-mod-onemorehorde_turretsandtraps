# P1 shove, damage and retaliation patch

Date: 2026-09-26. Version: `0.1.5-p1retaliation`. Owner explicitly approved this patch after the [completed 0.1.4 review](P1_COMBAT_OWNER_REVIEW.md). This is an SP combat prototype; connected multiplayer combat remains disabled. No Workshop release or final-art work occurred.

## Implemented behavior

Potato direct damage is now a fixed **0.50 native HP**, equivalent to **50 actual damage at a x100 display scale**. Current Normal-toughness zombies initialize at 1.8-2.1 HP, giving 4-5 direct hits; Tough zombies at 3.5-3.8 HP take 7-8. Random toughness naturally varies. No target-relative percentage damage is used. The old dummy hammer's melee reduction no longer lowers nonfatal damage. Tiny splash remains 0.001 HP, limited to three secondary victims, without secondary knockdown.

Successful knockdown rolls request native animated stumble-and-fall with FRONT reaction, a hit direction away from the turret, force 0.35 and physics-hit reaction disabled for this hit. The global ragdoll option is untouched. The provisional 70% chance and three-real-second shared target guard remain; base shot interval stays one real second. Delayed samples now include X/Y displacement so actual backward movement can be measured. Animation feel, collision and displacement still need player evidence.

Barrier retaliation uses an additional `OMHTTBarrierClaw` animation node that references the existing vanilla `Zombie_DoorClaw` animation. It does not replace a vanilla XML file or introduce artwork. Only a zombie currently in native ThumpState, targeting an exact live registered OMHTT barrier on the same floor and within two tiles, receives the custom ThumpType. The previous type is restored on interruption/target change/death. Other objects retain their normal behavior.

The node carries the vanilla claw's two `ThumpFrame` moments (0.23 and 0.73 of the animation) and matching native SetVariable markers, alternating left/right. A newly observed marker removes **0.20 native HP**, or **20 actual damage at x100**, from that attacker only. Repeated polls, time passage and aggregate barrier HP changes cause no damage. This keeps native barrier wear and destruction rather than forcing one barrier HP loss per thump. Native damage/death handling is SP-only; barrier kills use the environmental kill path without inventing a nearby player's ownership or reward.

Optional Pixel Strike Indicator presentation uses its installed `spawn` function with actual HP loss multiplied by its configured scale. It respects damage/ordinary-hit options, omits tiny splash spam, does not change third-party files/settings and does not synthesize a broad `OnWeaponHitCharacter` event. Missing indicator code does not affect combat. At scale 100, full direct hits display 50 and full barrier hits 20; a finishing blow can display less because actual remaining health is lower. Health-bar percentages are separate units. The adapter currently uses the first local viewport; split-screen is unproven.

## Exact limits of the strike prototype

The engine's `ThumpAnimations` and live animation-track classes are not exposed to ordinary Lua in this installation. Earlier HP/counter polling could not identify each strike. The new route exposes the animation's strike moments through native SetVariable events and reads them on OnZombieUpdate; it is not a once-per-second contact timer.

This is **not yet certified as a lossless per-native-strike hook**. Multiple animation markers crossed between two Lua updates can collapse into the last token, especially with fast-forward/frame skips. Blending and state transitions still require in-game comparison with native wear. A marker observed after its barrier is destroyed/removed or the target changes is deliberately discarded, including a possible final breaking strike, to prevent damage from a removed defense. There is no catch-up burst. These are acceptance limits; do not hide them or mark P1C2 complete before the player trace validates normal-speed behavior and the remaining cases are resolved.

Diagnostics: `barrier-attacker-attached`, `barrier-strike`, `damage-applied`, `damage-presentation`, and `shot-reaction-observed`. If an attached attacker produces no new marker for five real seconds, `barrier-marker-wait` records the condition; repeated warnings are limited to once per five seconds per attacker. No world scan was added: the native OnZombieUpdate event visits its current zombie, and exact-target lookup scans only that barrier's square.

## Evidence and verification

- Installed game: B42.20.4 b0bbce05d5, with PZ Optimizer overrides first on the classpath.
- Current `LuaManager.Exposer` bytecode is retained in [LuaExposer.javap.txt](../../diagnostics/p1retaliation/LuaExposer.javap.txt). Public native knockdown/Kill signatures and Normal-toughness constants are present in the earlier same-build bytecode evidence under `diagnostics/p1combat`.
- The actual native `AnimNode.Parse` accepts the XML, resolves the SetVariable event bindings and verifies two marker times equal the native strike times. This checks parsing/configuration, not live scheduling.
- [Validation log](../../diagnostics/p1retaliation/validation.log): 135 assertions, ten Lua modules compiled, 56 translations loaded/formatted by native Translator, native save-table roundtrips and 23 packets serialized (maximum 403 bytes).
- Behavioral checks include one attacker versus bystanders, repeated polls, independent attackers, wrong target, interruption, new session, removal, MP guards, fixed damage across three starting health values, death once, floating-point finishing damage and optional indicator settings/absence. World/zombie/UI behavior uses explicit doubles; it does not prove native animation or corpse/loot outcomes.
- The native parser fixture can print a file-GUID-table warning because the standalone harness does not initialize the full game filesystem. The animation object/bindings are asserted directly. Do not treat that fixture warning as a live OMHTT exception.
- [Isolated server console](../../diagnostics/p1retaliation/server-restart-console.log): exact version initialized; native translations resolved; GlobalModData saved; clean shutdown in 47.6 seconds. No player connected. Later changes only add marker-wait diagnostics and explicit empty native event parameters; final Kahlua/native-parser validation covers them.
- [Manifest](../../diagnostics/p1retaliation/manifest.json) records 43 package files. [Archive](../../artifacts/OMHTT-0.1.5-p1retaliation.zip) and managed local install are hash-verified. No uploader/publication was added.

## Owner test

1. Restart PZ and load an SP test save with Foundation Test Controls enabled; confirm `0.1.5-p1retaliation`. Use normal game speed for this first strike-marker test.
2. With Pixel Indicator enabled and damage scale 100, place a barrier and let one standing zombie thump it. Expect 20-damage popups at claw strikes; its health should fall while the barrier also takes native wear.
3. Add a second thumper and a nearby nonattacking zombie. Both attackers should take their own damage; the bystander should remain unharmed. Interrupt one attacker and check that retaliation stops for it.
4. Fire a potato at a standing zombie with ragdolls enabled. Expect 50 actual damage on a full hit and, on successful knockdown rolls, a short animated stumble-and-fall. Allow recovery before repeating; the turret should remain visible.
5. Continue until a zombie dies, checking the corpse/loot, then save/reload and inspect the defenses' ammo/condition. Normal-toughness zombies should take 4-5 potato hits; Random toughness can take fewer or more.
6. Tell me testing is complete. I will compare strike markers, damage, movement, death and reload records in console.txt; missing marker activity should produce its own diagnostic automatically.

## Completed owner test

The owner completed this build and reported it working well on 2026-09-26. See [the captured review and follow-up](../PHASE_1_CHECKPOINT_2.md) for exact damage, death, animation and marker-gap evidence. The follow-up adds directional damage and a 1x2 barrier footprint; earlier acceptance limits remain explicitly tracked.
