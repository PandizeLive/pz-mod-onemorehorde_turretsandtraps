# 0.2.46 - Battery endurance and Regulator

C168 approves the C167 selections. [Contract](checkpoints/R3_POWER_PACKING_OPTIONS.md) | [Focused test](TEST_v0.2.46.md).

- Battery endurance rebalance
- Regulator Module
- Lighter modules
- New rarity names
- Inventory rarity tooltip correction
- Regulator LootLab integration

Base battery consumption is .00045 percent per firing action. Seven additive per-copy surcharges are .1/.15/.25/.4/.6/.8/1.0; the separate weapon factor and no-idle-draw behavior remain. Generator fuel shares these revised module factors but retains its own base setting. Saved custom settings are not globally overwritten. On the reference weapon at four shots/second and a 90-real-minute day, sixteen maximum-cost copies imply about 6.3 in-game hours before reload pauses; this is not a universal minimum for all guns/day lengths.

Regulator is loot-only, stackable, defaults to Rare (weight 5.5), uses utility/electronics/mechanical pools, and weighs .2. Battery consumption divides by `1 + .25 * working copies`; one/two/four copies extend life 25/50/100 percent. No own power surcharge; generator use is unaffected. Broken copies occupy slots without a benefit. Installed Modules shows the current drain reduction; standard four-field hover descriptions remain. Its exception adds no tick loop.

All module items, including expansion and Makeshift variants, now have .2 script weight instead of .3. Base/head/trap weights are unchanged. Names follow Abundant/Common/Uncommon/Rare/Epic/Legendary/Mythic with existing colors. Rarity surcharge text preserves .15 and .25 accurately rather than rounding them to tenths.

The inventory tooltip retains native item details and draws a separately bounded colored rarity footer using exposed methods. It no longer subtracts inaccessible Java padding fields. Headless checks reproduce the missing-field boundary and bottom-screen geometry; final rendered game acceptance remains pending.

LootLab is deployed at 0.2.46 with 29 modules/208 entries, a utility-square Regulator marker, and migration preserving previous account/browser tuning. The new entry defaults to visible/rate 1. No database writes or unrelated Worker source changes.

## Unfinished approved packing

Automatic sealed pickup/normal summary/placement unpack with 67% contents reduction remains approved but **not implemented**. The native byte-buffer route is not safely restorable through ordinary Lua; current generic loaders still require buffer access/version handling. No supported lossless alternative was established. Shipping a Java dependency or rebuilding arbitrary modded items from selected properties would change the accepted constraints. Existing real-item pickup/placement retains its previous weight. Do not present module weight reduction as completion of packing.

SP only; no Workshop publication. Cumulative unpublished notes are preserved.
