# 0.2.58 — C355 approved battery balance and mechanical Poke Floor

- Battery balance
- Siphon chance
- Head consumption ratings
- Mechanical Poke Floor
- Building menu corrections

Owner approval: “Approved for patch”, 2026-10-20. Implements settled C354/C351 and C345–C346. Lever and Dart Emitter remain planned; their unresolved recipes and behavior are not invented in this patch.

## Battery balance

Direct Abundant/Common/Uncommon/Rare/Epic/Legendary/Mythic surcharges are 10/15/25/50/75/100/150 percent. Physical working modules add their surcharges once; aliases do not double-charge. Regulator remains exempt and divides battery use by `1 + 0.25 × copies`; Expansion Kits, broken modules and incompatible modules do not add power cost.

Firearm heads multiply existing battery use by 1.5; Scrapshot base cost changes from 0.002% to 0.0025% per cycle. Ballista and other heads retain their base costs. Separate Firearm Battery Multiplier and Scrapshot Battery Use Sandbox controls preserve existing custom base tuning rather than rewriting it. Firearm's new factor affects battery use only. Existing shared module-load effects on generator fuel remain unchanged in structure, so higher rarity surcharges also raise that existing fuel cost.

Siphon has one authoritative 45% roll per eligible kill for the whole stack. Success refunds 2× the shot's actual local battery debit, plus 1× per additional Siphon. Failed rolls are claimed too, preventing duplicate death callbacks from rerolling. Secondary kills still require Synergy. Controller/grid energy cannot produce a refund. Delayed rotary settlement and original battery identity/generation remain enforced.

Inventory and Manage head tooltips show Battery Consumption with green Low, amber Medium or red High values and a head-only explanation. Ratings estimate sustained base use with standard ammunition and normal reloads, excluding turret modules. Low is below 5 battery percentage points per real unpaused hour; Medium is 5 to below 15; High is 15 or above. Rotary uses its base motor-hours rate. These are comparative labels, not promised endurance. Reference save calculations remain approximately M9 98, M4 31, Ballista 23 and Scrapshot 52 real minutes with the documented 14-module loadout and no Siphon/Regulator; no timed endurance run is claimed.

## Mechanical Poke Floor and Building

Poke Floor remains contact-triggered: 50 damage, 1.5-second repeat cycle, actual scratch/fall strike, hit-cycle wear and existing repair/service. It draws no electricity, local battery or Controller fallback charge. Arm/Disarm replaces electrical wording. New battery insertion is rejected authoritatively; pre-patch batteries remain removable with exact charge/identity, and packed legacy contents remain intact. Controller assignment still provides authorized remote management, not external strikes. Traps never accept turret modules.

Both Poke recipes remove Electronics Scrap, Electric Wire, Electrical skill and Electrical XP. Standard keeps one Tire Pump, four Metal Bars, two Small Sheet Metal and eight Screws, Mechanics 1, screwdriver and wrench/pipe wrench. Improvised substitutes two Metal Pipes for the pump and requires Mechanics 2. Both retain 20 Mechanics XP, original crafting duration, weight and output.

Building now registers both crafting routes and switches them to one deployment row when a usable Poke Floor is carried. Selecting the improvised route follows the same carried-item deployment. The existing internal OMHControls category displays “OMH: Triggers”; the Poke container has a translated title.

No loot rarity/weight changes, LootLab deployment, final art, Workshop publication or merge. Rendered and connected-player acceptance and the separate five-second multiplayer placement issue remain pending. See [tests](TEST_v0.2.58.md).
