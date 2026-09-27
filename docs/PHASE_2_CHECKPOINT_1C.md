# P2C1c plus SP servicing and menu repair: 0.2.2

Owner approval on 2026-09-27 combines five-item bundles, pickup and free repair with the requested Crafting-category/description correction. High reasoning was recommended; expanded scope estimated 35-50 minutes with Fast recommended. [Previous owner evidence](TEST_v0.2.1.md).

## Behavior

- Crafting exposes Turrets & Traps in addition to Carpentry, without duplicate recipe definitions or changing native category metadata. Search, normal category navigation, inventory refresh and workbench queries retain their native scope.
- Craft, build and deploy show the owner's purpose description and readable statistics: damage 20 per thump at the front/sides, maximum durability 100, size 1x2. Only OMHTT selected-recipe headers receive responsive wrapping; native requirements remain in the normal input/skill widgets.
- Right-click either placed half for Spike Barrier: shared current condition, Pick up, and Repair. The display is a read of existing condition, not a new health system. Repair is unavailable at 100/100.
- Pickup and free repair each use ten active real seconds and native movement/aim interruption. The progress calculation uses the installed GameTime real-seconds API, independent of fast-forward; large per-frame deltas are bounded. Paused/non-updating time does not accumulate. Completion revalidates the live pair, identity, distance, feature switches and inventory capacity.
- Pickup removes both halves once and returns exactly one full-condition portable barrier. Repair restores both halves to 100 without materials. This intentionally supersedes condition-preserving basic-barrier recovery; moving a barrier can restore it for the same time cost. No XP. Full-inventory pickup preserves the barrier and reports why it failed.
- Pack five pristine barriers into one Spike Barrier Pack; unpack to five. Weight is `5 x 6 x 0.33 = 9.9`, with the approved 67% reduction and still-provisional individual weight 6. No additional material/tool/skill or XP requirement. Native Making action/time 100 is initial pack/unpack timing. Damaged loose items remain ineligible; pickup supplies full-condition ones.
- All new servicing remains SP-only, matching construction. Future turret resources, reinforced tier retention, MP authority and access rules are not replaced by the basic-barrier full-recovery decision.

## Vaulting and artwork limits

The owner requests player vaulting, a 20% front-side scratch chance and a safe rear. This supersedes the earlier design ban, but **0.2.2 still blocks vaulting**. Current barriers use `IsoThumpable.blockAllTheSquare`; native `ClimbOverFenceState.setParams` targets an adjacent square/edge, while `IsoGameCharacter.climbOverFence` checks the landing through `IsoWindow.canClimbThroughHelper`. Simply setting hoppable changes zombie routing and does not prove traversal across the full occupied tile. The installed ClimbOverFenceState API was checked with javap; historical source was used to map the movement/collision path. A deliberate native collision/animation prototype is next, with blocked landing, interruption, front/rear roll deduplication and zombie routing tests. No fake teleport, Java injection, scratch roll without a completed crossing, or unverified movement behavior is shipped.

Condition stages in final sprites are a useful future glance cue; the owner is sourcing artwork without AI. Current developer arrows/cubes are unchanged. The world menu supplies exact condition now.

## Verification

- 299 Kahlua assertions, 18 runtime modules, 79 native translation keys, 23 packet serializations. Tests run installed menu/category/layout methods with UI/logic/font doubles: mod/native navigation, search, refresh, workbench isolation, narrow/wide wrapping, complete statistics and no vanilla-description mutation.
- Service tests cover current condition, either-half menus, ten-second gate, movement flags/cancel, free repair, full-inventory refusal, pair retirement, wrong identity/distance/MP rejection and duplicate completion.
- Native game smoke performs real five-to-one and one-to-five CraftRecipeData transactions, rejects four-item packing, verifies 9.9 weight and zero XP/skill requirements. Existing recipes/150 material mixes, portable transactions and native sprite/object serialization remain checked. The write/read processes passed in 38.0/36.6 seconds, restoring the same 16 native object streams with 37 condition and valid identities. Logs live under `diagnostics/v0.2.2/`.
- Headless probes cannot certify rendered UI, walking to a clicked barrier, visible progress/cancel behavior or player vaulting. The following owner test is still required; this is not full Phase 1 or MP acceptance.

## Owner test

1. Restart PZ into **0.2.2** on the disposable SP save. Enable Diagnostic Logging and Foundation Test Controls; leave Building/Crafting Cheat off. Have Carpentry 1, a sharp knife/cleaver and four wood/four binding units for one normal craft; gather five loose barriers for the bundle check below.
2. In Crafting, check Carpentry and Turrets & Traps, search for Spike Barrier and craft one. Select craft/build/deploy entries and resize the window: purpose text and all three statistics should stay readable. Native categories must remain usable.
3. At a built barrier, use **OMH Foundation Test â†’ Set test condition to 37** on its tile. Right-click either half â†’ Spike Barrier: both should show **Condition: 37/100**.
4. Start Repair and walk away before completion: condition must remain 37. Retry without moving: after ten seconds both halves should show 100/100, with no materials consumed or XP.
5. Set condition to 37 again. Start pickup, cancel by walking, then retry to completion. Both world halves should disappear together and exactly one full-condition barrier should enter inventory. Allow at least 6 free inventory capacity.
6. Deploy the recovered item: one 1x2 barrier at 100 condition, no additional materials or XP. The old location should be usable again.
7. With five loose barriers, pack them through Crafting. Expect one **Spike Barrier Pack**, weight 9.9. Unpack it: exactly five barriers return, no packing/unpacking XP.
8. Save and reload; check the remaining placed barrier and inventory counts. Say **Test Complete** and report visible issues. I will inspect version, category/wrapping, service cancellation/completion, bundle transactions and restoration diagnostics. Vaulting remains pending and is not part of this test.

## Release

Use OMH.cmd, annotated `test/v0.2.2`, a verified archive and a full managed 0.2.1 backup. No remote push or Workshop upload. Removing 0.2.2 also removes its pack item definition; retain a pre-update disposable save when testing rollback. [Current release evidence](RELEASE.md).
