# 0.2.32 — focused owner test

Restart the game, use a fresh single-player debug world with both entries enabled, and keep God Mode off for the injury check. This replaces the remaining 0.2.31 checklist.

1. **Version and menus:** confirm **0.2.32** in the developer menu. Bed Spikes/Barbed Panel settings belong under **Traps**; default zombie bed trips and potato knockdown both read **40%**. Crafting lists the defenses; Building has no OMH choices.
2. **Craft and place:** craft a Bed Spikes and Barbed Panel (crafting cheat is fine). Inventory shows **Place Trap** / **Attach Trap**. Rotate the panel through four directions, attach it to a fence, and place the bed immediately behind it. Both should fit; one bed texture repeats and the panel has two visual states. Its Repair/Remove menu must open without errors. Turret components use **Install Trap**.
3. **Player crossing:** walk through safely with bush-like movement, then cross with noclip: no forced brush animation or injury. Turn noclip off, temporarily set **Player sprint trip chance** to **100**, and sprint onto a bed: a fall should cause a laceration once. Restore **20** afterward.
4. **Zombie recovery:** temporarily set bed trip chance to **100** and lead a few zombies across. They should fall, take one hit/six durability wear per landing, get back up and move again; no immediate repeat trip during the five-second recovery protection. Restore **40**, save/reload, and confirm both defenses remain. Report **pass/fail by step**, plus any pause or stuck actor; stop there for log review.

## Owner findings — 2026-10-07

Acceptance is incomplete. Owner reports inconsistent Pack/Bundle/Five recipe names, excessive flat crafting rows, zombie/player trips reading as knockback, failed Barbed Panel placement, missing brush animation while running, turret placement not using Install Trap, and questions about carried weights. Keep simplified Building as a deferred option; current crafting direction remains active.

Local console snapshot: `diagnostics/v0.2.32/owner-report-20261007/console.txt` (untracked). Version 0.2.32 SP is established. Frame 23900 logs `ISBuildIsoEntity -> square invalid - fail`; the generic message does not identify the defense or failing predicate. Later build successes cannot be assigned to a particular item either. Do not claim a panel root cause from this log alone.

Verified code/current installed 42.21 evidence:

- Recipes.json still mixes Pack Five Spike Barriers, Unpack Five Spike Barriers and Bundle Reinforced Spike Barriers. Select Pack/Unpack consistently, with no quantity in names. Current portable item names already use Pack. Basic Spike Barrier crafting/packing/unpacking are different actions; grouping should preserve each operation.
- Current native ISRecipeScrollingListBox supports group rows and open/partial/closed states. Current JAR javap proves CraftRecipeGroup only registers OPEN_BOX. Custom family groups are not available merely by adding a recipeGroup string. Prototype a small UI adapter using existing presentation; verify mouse/controller, search/filter/favorites and other-mod behavior before claiming support. No vanilla Open Box repurposing.
- Native player/run/inTrees.xml uses Bob_RunTrees, distinct from movement/inTrees.xml's Bob_WalkTrees. Our custom OMHTTBedBrush only exists in movement. Player fall sets BumpFallType=pushedFront and BumpDone=false, selecting the backward stumble; native player/bumped/bumpFall.xml uses Bob_RunStumble with BumpDone=true and front-fall/end events. Zombie code explicitly calls knockDown(false), so the owner's knockdown description is consistent. Restore a genuine forward trip with complete recovery; do not revert to the incomplete old animation-only request.
- Panel completion revalidates both carried item and native placement conditions. The exact failed predicate remains unresolved. Independently, Service.tools accepts BuildCheat but BarrierPlacement.place still returns nil without hammer/pliers; align cheat handling and report concrete rejection reasons. A native cursor-through-completion fixture is needed, not only onCreate recipe fixtures.
- TurretInstall.menu still uses Place Trap; Install Trap was applied to component management. Owner now requests the turret placement action use Install Trap too.
- Current weights: panel 4, basic bed 4, reinforced bed 5. These are recipe item weights, not evidence of a runtime multiplication bug. Recommend panel 2 and retain bulky 1x2 beds at 4/5; owner choice pending.

No new gameplay patch or acceptance pass is claimed by this investigation. Grouping/weight choices were presented to the owner. The next repair should include forward trips with recovery, walk/run foliage states, complete panel placement and consistent actions; do not repeat the old full regression checklist.
