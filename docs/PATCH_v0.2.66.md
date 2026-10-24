# 0.2.66 - Module stacking and management corrections

Owner C444 selects C443 **1A**, completing the numerical choices for the combined C438-C443 patch.

- First-copy and additive duplicate bonuses
- Inactive module storage
- Expansion replacement and ammunition overflow
- Rarity-first module sorting
- Module icon and Details layout
- Consistent item tooltips
- Module Sandbox controls

The selected [nineteen-family tuning table](MODULE_FIRST_COPY_C443.md) now drives runtime stats and descriptions. Rapid Fire grants +40% firing speed first, +20% per additional copy; Velocity grants +30% damage first, +15% thereafter. Sixteen copies yield 4.4x firing speed or 3.55x damage. Conservation and Siphon reach 9.5 uses/refund multiplier with sixteen copies. Regulator, Impact, Splitter, Piercing and Suppression retain their reviewed behavior. This is additive contribution, not compounding. Chance totals still stop at their natural maximum; loaded-world, execution-budget and finite-volley safeguards remain.

Ordinary Rapid/Reload/Velocity/Range bonus ceilings, Fragment's damage ceiling and the old firing/reload/rack duration floors are removed. Outward acquisition yields in bounded slices and stops at an entirely unloaded boundary, so very large configured range does not require scanning an empty square of that size. The legacy synchronous fallback also has a work/time budget. No cost, rarity, loot weight, recipe or head baseline is retuned.

First Copy and Additional Copy settings appear in the existing module groups. Existing numeric option identities remain the additional-copy controls; explicitly saved values are preserved. Consequently an older save retaining its previous default values can produce different duplicate gains from a fresh world. New first-copy fields use the selected defaults. The patch does not reset Sandbox or LootLab settings.

All configured physical module slots can store items. The first capacity-enabled positions in saved exact-item priority supply effects and battery surcharge; later modules remain grey and unavailable. Broken or unsupported modules do not contribute. Rarity/category/name sorting changes presentation within active and inactive groups, independently of activation priority. Dragging one installed module onto another exchanges their priority positions. Head compatibility and unique-module restrictions still apply to incoming items. Pickup, redeployment and network snapshots retain the saved order.

Dropping a replacement kit on the occupied expansion socket projects the incoming capacity directly. Excess physical ammunition returns in batches of at most twenty rounds to the player's inventory, then to the floor when full. Native magazine/chamber and extended-feed rounds are accounted once; Conservation debt survives. The installed kit stays in place during evacuation. The final kit exchange rechecks access, exact identities and capacity, and restores both kit endpoints if delivery fails. Interruption can leave already-returned ammunition in inventory/on the floor, with the old kit still installed. Favorite items remain protected. The queue has a 1,024-batch safety bound, above normal storage, rather than an unbounded allocation on one UI event. Controller stockpiles are not dumped.

Compact module cells use separate icon/text rectangles; taller cells place labels below their icons. Details wrapping is measured at the current width/font before height allocation. Hover text explains inactive modules; the yellow feedback line identifies unsupported-head modules.

Item purpose rows consistently use readable grey `Feature:` text, including wrapped lines. Trigger Battery Consumption uses the shared colored rating with no raw hourly cost, Power Source or Additional Draw clutter. Kits show grey Controller/Turret benefits and rarity without a redundant Feature row; Traps-only kits omit turret-only benefits. Trap tips use behavior, actual loaded damage and health. Poke Floor remains **45 damage / 200 health** by default; the earlier illustrative 50 was not a balance selection.

Implementation is verified by the automated and native checks in [the test record](TEST_v0.2.66.md). Rendered UI and live combat balance still require owner acceptance. Connected-player multiplayer remains deferred. No Workshop publication, branch merge or hosted LootLab deployment.
