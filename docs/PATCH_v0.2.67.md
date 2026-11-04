# 0.2.67 - Ammo capacity and management polish

C450 records the owner's final "Approved" after C449 1A. Implements the C445 corrections, C447 Native slim choice for Controller/Manage, and C449 six-hour ammunition table.

- Shared ammunition multipliers
- Controller and Device Settings panes
- Controller assignment cleanup
- Matching expansion sockets
- Controller battery endurance
- Equipment transfer sounds
- Consistent item tooltip colors
- Mechanical Poke Floor inventory item
- Blocky development head models

Fresh worlds use 400 firearm rounds, 80 shells, 75 potatoes, 30 Ballista spears, 90 Scrapshot materials and 35 Lobber bombs. Makeshift/Small/Medium/Large multiply these bases by 2.5/5/7.5/10, flooring the final count. Small still grants eight total module slots. Tooltips report total slots and the effective multiplier. Large Enhanced M4's 4,000 rounds calculate to approximately 6h07m at the reviewed 90-minute day including reloads, before extra modules or other operating constraints. This is ammunition endurance, not a guarantee that its battery/condition will last as long. [Full head/tier comparisons](AMMO_SIX_HOURS_C448.md).

Existing numeric Sandbox storage values retain their old units and family allowance table. The six retired options remain readable with -1 as the fresh-world sentinel and are hidden from the custom settings display. **Use New Ammo Rules in Existing Worlds** explicitly opts an older world into the new base/multiplier controls without overwriting its saved legacy numbers. Existing real ammunition is never truncated by loading this patch. Head-family bases and expansion multipliers appear in their existing Turrets/Modules groups; no new side category or loot tuning.

Controller and Manage use the selected shaded section headers and slim resource gradients. Controller's Device Settings and Controller Settings have equal widths, aligned to the map edges, independently scrolling below it. Controller controls stay accessible while another device is selected. Narrow Access/Unassign buttons stack; long target summaries use their tooltip and a short button title. Expansion sockets share the Expansion Kit title, Drop Here hint and effective-rarity kit silhouette, preserving Stored Batteries and the established Online/range area.

Authoritative assignment reconciliation removes loaded devices confirmed outside the current host radius, including their group entry and remote session. It runs within the existing bounded device tick and on registration. Temporary unloading does not prove an invalid assignment. Authorized Unassign can remove that exact host's stale assignment even when outside range or without power. Ownership and direct trigger connections are preserved.

Controller battery hover estimates current-battery and total stored-battery endurance from recent actual Controller spending, including idle and fallback supply. It uses game hours, explicitly labels estimates, and initially says Calculating. Reserve inspection handles at most 32 inventory entries per one-second sample; no full-stockpile scan per frame. Broken batteries are excluded. Controller idle endurance gains a Sandbox control with the unchanged 48-hour default. An estimate is not a promised runtime under a changing load.

Successful module, head, battery and expansion transactions play the native local UI activation cue. Multiplayer authority sends a fixed confirmation to the operator; cancelled/rejected transfers and each individual overflow round stay silent. Purpose/Feature rows are white and statistical rows readable grey, including wrapping; rarity, rating and availability colors remain. Spike Barrier says its rear is vulnerable without adding retaliation there.

Newly crafted/recovered Poke Floors use a plain item with no portable capacity. The old item ID stays a container so native deserialization cannot discard old contents. Both IDs use the same deployment route and public name. Placement retains condition; recovery returns actual legacy contents to inventory or the ground, bounded to 64 items per attempt with failed deliveries retained. Old packed items can still show their old native capacity until deployed/recovered. No new loot entry, duplicate craft row or recipe cost change.

Six distinct blocky artist-kit meshes are integrated for Ballista, Scrapshot, Lobber, Arc, Rotary Bat and Rotary Blades. Existing firearm models, Potato model and owner module artwork remain. Neutral module development markers stay alternatives in the [artist handoff](../art/artist-handoff/C445/README.md); they do not replace supplied artwork. Native mesh import is verified separately from in-game visual acceptance.

[Verification and short checklist](TEST_v0.2.67.md). No Workshop upload, hosted LootLab deployment, sibling-project change or branch merge.
