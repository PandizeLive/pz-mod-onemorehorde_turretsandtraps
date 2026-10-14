# C229 Consolidated pre-patch choices (2026-10-14)

**C234 / shared explosive capacity and Makeshift Bomb confirmed (2026-10-14).** Owner rejects per-explosive-type quotas, chooses Makeshift Bomb naming and approves25%of relative donor-stat difference. [Settled rules and final capacity choice](VOID_MODULE.md#c234-shared-explosive-capacity-and-makeshift-bomb-2026-10-14). One shared bomb count replaces subtype limits/weighted mixing;40 versus20 total bombs remains proposed. No gameplay/install/test-status change.

**C233 / damage-aware ammo limits and attenuated stats (2026-10-14).** Owner asks capacity balance including AoE, replaces Shell wording with grenade, selects retained donor ammo stats with reduced contribution for future alternate-ammo support, and approves whole-potato scope. [Capacity/scaling proposals and native evidence](VOID_MODULE.md#c233-ammo-balance-attenuated-stats-and-separated-decisions-2026-10-14). Vegetable/produce launcher remains an exploration idea. Separate decision blocks with thoughts/options now supersede combined tables in AGENTS.md. Exact capacity and scaling values remain proposals; no gameplay/install/test-status change.

**C232 / selective ammo limits and Void controls selected (2026-10-14).** Owner replaces blanket75% cuts with selective ammo maxima, allows rotten/variant potatoes and requests modded-spear support; selects manual Void beside Ammo, safe module removal and Mythic rarity. Magazines remain. [Native classification evidence and compact remaining choices](VOID_MODULE.md#c232-selective-capacity-broad-ammo-families-and-compact-decisions-2026-10-14). Exact caps, donor-stat normalization and prepared-potato scope remain proposals. Compact decision-table preference added to AGENTS.md. No gameplay/install/test-status change.

**C231 / mini grenades and recipes selected; Void storage proposed (2026-10-14).** Owner selects C2301A and2B, replacing storage option3 with a roughly75% ammo-capacity reduction and portable Void Module holding permanently converted weightless ammo by type. [Approved direction, tradeoffs and remaining choices](VOID_MODULE.md). Reduction scope, normalization, conversion interaction, removal and rarity remain proposals. Preserve five-mini behavior, pump/improvised same-output recipes and earlier unrelated approvals. No gameplay/install/test-status change.

## C230 Owner selections and revised recipe/Fragment proposals (2026-10-14)

This section supersedes the proposal-only status below for selected groups. Owner chooses C229 **1A, 2A with mini-grenade Fragment, 3B, 4A, 5A, 6A, 7B, 9A with two Scrap Metal, 10A, 11A, 12A with a40-spear limit**. Group8 is expressly returned for native-component/improvised recipe proposals. No gameplay implementation or test acceptance follows from this documentation update.

- Mixed reserves with homogeneous loaded magazines, per-payload Conservation, existing fallback and ammo exceptions selected.
- Lobber's compatible-module option selected, but its Fragment burst becomes mini grenades. Exact count/damage/radius/fuse/propagation below remain proposals, not silently inferred approval. This change applies to Lobber Fragment, not a global replacement of firearm/Scrapshot/Potato Fragment.
- Scrapshot Splitter adds one60-damage side projectile per module, not another eight-fragment fan. Other selected module rules retained.
- Potato attenuated splash overlap, reload2/6/4/3seconds, C2296A power, Uncommon-default Lure weight14, moderate injuries and scattered Lobber aiming selected.
- Shell recipe now consumes **two Scrap Metal**, not six, with the other9A values unchanged. Owner's rationale: cover both pipe ends; record as game-recipe flavor, not real fabrication guidance.
- Ballista gets a40-spear count limit. Interpret40 as total stored ammunition, including ready spears, consistent with current overall ammo-limit accounting; magazine remains5 and its separate modules still work within total storage. Owner asks whether expansion can increase it and suggests investigating a bypass if weight-bound. Fixed40 with no spear-count expansion this patch is a recommendation pending the storage clarification below; do not silently claim a scalable expansion policy was approved. Future ammo-type-specific expansion is requested for consideration.

### Native/source evidence and storage answer

Inspected installed42.21 `media/scripts/generated/items/normal.txt (TirePump)`, `weapon.txt (Shotgun, DoubleBarrelShotgun, SpearCrafted)` and current native `zombie.inventory.ItemContainer` bytecode. Tire Pump is a native item weighing2; Crafted Spear weighs2. Native shotguns are genuine available item definitions, not invented gun-receiver parts (`Base.Receiver` is electronics and must not be described as a firearm receiver).

`TurretStats.resolve` adds expansion ammo bonuses100/200/400/650 to a count limit. `Turret.configure` already sizes placed storage using the maximum configured kit stats and clamps it to100 weight, regardless of which kit is installed. `TurretTransfers.rejection` also checks native `hasRoomFor`. Therefore kits do not currently expand the weight capacity; heavier ammo can hit weight before count.40 spears alone weigh80; head/battery/modules add more. With a base40 plus current bonuses the advertised limits would be140/240/440/690, which this storage cannot realize. Do not advertise those spear counts.

Native `ItemContainer.setCapacity(int)` warns above100 on ordinary world containers but then assigns the requested capacity; it is not an immutable Java100 clamp. Our clamp respects that warned threshold. Calling an over-limit setter is therefore technically possible but not verified as a safe supported solution. Carried `InventoryContainer` additionally has its own50-minus-item-weight rule (earlier confirmed maximum44 for the six-weight base). Do not conflate the carried44-weight warning with44 spears. Pickup also requires actual contents weight to fit the player's inventory.

Recommendation: fixed40 total spears for this patch, truthful weight-space display, expansion kits still improve module slots but no unreachable spear promise. Future investigation should compare a dedicated spear rack using real bounded containers with an over-limit placed-container prototype; verify transfer, save/reload, kit removal and pickup before selecting. Do not modify native spear weights, bypass checks silently, fake a vehicle container or revive packed-weight reduction. Feasibility exploration is not implementation approval for a virtual-ammo subsystem. Even40 is a count ceiling, not a guarantee with arbitrary heavier contents.

### New option1: mini-grenade Fragment (proposals)

- **1A recommended:** Five mini grenades, emitted0.25seconds after the parent explosion; short0.25second outward flight up to2tiles, each with a0.5second fuse after landing and1-tile blast radius. Each deals the existing Fragment percentage of that parent's center damage: default20%, +5percentage points per extra Fragment up to the existing40% cap. Thus a150-damage Shell gives five30-damage mini blasts with one Fragment. Preserve linear falloff, walls/same-floor/actor-only behavior; mini grenades do not inherit full native bomb damage/radius. Count and radius do not stack. No extra ammunition charge or new power surcharge beyond selected module power; reserve work before firing.
- **1B:** Eight mini grenades with the same combined center-damage budget as1A, so each gets5/8 of1A's damage. Same timing/radius/travel. More visual activity and collision/explosion processing, no extra aggregate damage budget.

Both: side-parent grenades create minis only with Synergy. Mini damage may trigger Tack/Martyrdom under the selected Synergy rules, but never another Fragment or Splitter generation; resulting proc effects remain terminal under existing protections. Player damage/scratch chance scales by the same mini damage fraction relative to the parent, not a full10-damage/50%-scratch roll for every mini. Duplicate player collision processing stays blocked; distinct mini explosions may overlap. These are bounded-work design targets, not proven performance. Mini landing/detonation lifecycle must be validated, including parent expiry and unload cleanup.

### New option2: native-component recipes (proposals)

Recommend alternative recipes producing the **same head item and statistics**, following the existing Potato head pattern. Improvised means no special donor item, higher skill/time and some extra common scrap, not a new inferior head/inventory variant. Both routes include the integrated mount. In-game quantities only.

| Input or requirement | Lobber standard | Lobber improvised | Scrapshot standard | Scrapshot improvised |
| --- | --- | --- | --- | --- |
| Special component |1 Tire Pump |None |1 native shotgun |None |
| Metal Pipes |2 |2 |1 |2 |
| Small Metal Sheets |2 |2 |1 |1 |
| Scrap Metal |2 |4 |2 |4 |
| Electronics Scrap |4 |4 |2 |2 |
| Electric Wire |2 |2 |1 |1 |
| Screws |12 |12 |8 |8 |
| Mechanics/Electrical |3/2 |4/2 |2/1 |4/1 |
| Mechanics/Electrical XP |30/10 |30/10 |20/5 |20/5 |
| Recipe time |864 |1080 |576 |720 |

- **2A recommended:** Table above. Lobber uses a Tire Pump as the thematic pneumatic component; Scrapshot salvages a shotgun assembly. Accept native Shotgun/DoubleBarrelShotgun and their sawn-off variants, nonbroken, unloaded/chamber-empty and attachments removed. Reject unsafe inputs rather than deleting their ammunition/attachments. Native gun ballistics/ammo type are not inherited by the finished head.
- **2B:** Same except Scrapshot's special component is a Tire Pump instead of a shotgun. Easier shared sourcing; loses the distinct shotgun donor identity. Same improvised recipes and stats.

All routes retain screwdriver, wrench/pipe wrench, pliers and metal saw. Yield1; Lobber weight8, Scrapshot6; no recipe book; base-only maintenance. Time values are script recipe units; improvised is25%longer than its standard route. Costs/tools/skills/XP/time all need owner selection. Existing Potato recipes are comparison evidence and are not being changed. Recipes named Improvised follow existing scheme; do not duplicate the output inventory items. Actual native transaction validation remains an implementation gate.

### New option3: immediate spear expansion policy

- **3A recommended:** Fixed40 total spears now, kits still grant module slots; evaluate native-safe ammo racks/type-specific expansion in a later checkpoint.
- **3B:** Treat40 as the unexpanded base and prototype scalable storage before completing the Ballista part of this patch. Exact kit spear bonuses need a later choice after feasibility; do not reuse +100/+200/+400/+650 automatically. Other approved patch work can proceed independently.

Only these three revised decisions remain open from this turn. All other C229 selections above stay settled. Checked2a1b7cf, fetched origin with no newer planning changes; documentation mirrored through the existing development PR, without gameplay/source/version/install/test changes.

## Historical C229 proposal slate

Proposals only at C229; the C230 selections above now take precedence. Owner asks for all remaining choices and recommendations before patching. Based on active development 15e8b63 and C225-C228; all A options below are recommended. No gameplay, version, installation or test-acceptance change. This document completes the decision agenda rather than reopening approved head statistics, magazine capacities, Lobber Conservation/Splitter, rotary Tack/Martyrdom, Potato Piercing or pack controls/audio.

## 1. Lobber mixed ammunition

- **1A:** Mixed reserve, one payload type per loaded magazine and firing event. Side grenades use the primary's type. Existing priority, fallback OFF, return-to-preferred at normal reload and explicit safe unload/reload remain. If only one preferred round is available, load one; do not fill the remaining slots with another type. Existing insufficient-ammo/full-shot and last-round exceptions remain. Conservation accounting is isolated per payload type so switching cannot convert leftover Shell credit into Pipe Bomb credit.
- **1B:** Mixed ready magazine; consume actual rounds in queue order and launch each round's own payload, with separately tracked Conservation credit. More variety, less predictable Splitter salvos and more complicated UI/persistence. Never consume Shells to produce Pipe Bombs.

## 2. Lobber effects

- **2A:** Support ordinary control/stat/feed modules, Conservation and Splitter; exclude Piercing because a grenade detonates rather than penetrating. Velocity changes damage, not fuse. Range extends targeting, not blast radius. Accuracy reduces landing scatter. Critical/Initial Blow/Execute apply to each blast victim; snapshot eligibility before that victim's damage. Main blast victims can trigger Tack/Martyrdom. Fragment produces one endpoint burst per primary grenade; side grenades gain those secondary effects only with Synergy. Impact's first-post-reload entitlement applies to one closest eligible surviving victim per firing event, not every blast victim. Effects do not recursively reproduce themselves. Suppression affects launcher noise, not the explosion. No change to standalone bomb behavior.
- **2B:** Same normal stats/feed and approved Conservation/Splitter, but exclude Fragment, Tack, Martyrdom, Synergy and Impact on Lobber. Less explosive-effect workload and a simpler role; fewer module combinations.

Both preserve current module stacking values. Firing/Enhanced Firing and Rapid-Fire use shared custom-head cadence semantics; no new hidden rate multiplier. Detection/Enhanced Detection, Filter, 360, Magazine, Reload, Autoloader, Regulator and expansion capacity remain meaningful. No newly supported module may charge power while having no effect.

## 3. Scrapshot effects

- **3A:** Splitter adds full eight-fragment side fans, each at 50% primary damage (60 total before modifiers). Piercing works along each fragment's path with existing continuation loss. Enable Magazine/Reload/Autoloader/Impact now that a magazine is approved. Primary fragments can proc effects; secondary fans/penetrated contacts require Synergy for secondary procs. Tack/Martyrdom/Impact eligibility is deduplicated per victim/firing event, with Impact limited to one eligible victim; Fragment occurs once at the main fan endpoint, and once per side fan only with Synergy. Critical/Initial Blow use one pre-damage snapshot per victim per firing event across its fragments; Execute checks resulting health. Do not multiply proc attempts by eight just because eight fragments hit one body.
- **3B:** Same rules, but each Splitter adds one side projectile carrying 60 damage instead of eight smaller fragments. Same side damage budget, lower projectile workload, less shotgun-like appearance.

No projectile cap silently truncates an accepted firing event. Reserve sufficient bounded work before consuming resources; defer a shot under overload. Neither option permits Fragment/Martyrdom/Tack recursive chains. Retain standard meaningful control/stat/power modules; Accuracy affects aim error, not the approved 90-degree fan width. Base Critical and knockdown are zero; modules can supply them. Geometry determines pellet contacts rather than an additional per-pellet accuracy rejection.

## 4. Potato piercing splash

- **4A:** Each directly pierced zombie produces splash scaled by that contact's remaining damage (existing 70% retention per penetration). Distinct impacts can splash the same nearby zombie. Existing knockdown chance occurs at every direct contact only; splash cannot penetrate, cause its own splash or knock down.
- **4B:** Same attenuation/direct-contact behavior, but each nearby zombie can take splash only once per potato. Reduces crowded-group damage; changes the proposed per-impact overlap behavior.

Existing secondary proc/Synergy rules remain; this does not enable new Potato splash proc propagation.

## 5. Reload durations

| Head | 5A recommended | 5B slower reloads |
| --- | ---: | ---: |
| Potato | 2 seconds | 3 seconds |
| Ballista | 6 seconds | 8 seconds |
| Lobber | 4 seconds | 6 seconds |
| Scrapshot | 3 seconds | 5 seconds |

Reload and shot cooldown overlap, matching the current cycle. Reload modules shorten reload only; Autoloader removes reload delay, not shot cooldown. Safe ammo switching performs one ordinary reload after the exact old ready items have a valid destination; no extra five-second timer and no free Impact rearm from swapping a nonempty magazine. Preserve unchanged firearm timings and ammo-free rotaries. Magazine capacities remain Potato3/Ballista5/Lobber3/Scrapshot10.

## 6. New power baselines

| Action | 6A recommended base charge | Actions per full battery before modifiers |
| --- | ---: | ---: |
| Lobber Shell | 0.02% | 5,000 |
| Lobber Aerosol | 0.03% | approximately 3,333 |
| Lobber Pipe Bomb | 0.04% | 2,500 |
| Scrapshot primary fan | 0.002% | 50,000 |
| Lure pulse at 20 tiles | 0.02% | 5,000 |

- **6A:** Values above; a Splitter side grenade/fan adds 50% of its corresponding primary energy cost. Conservation reduces ammunition use, not emitted-projectile energy. Existing rarity/module load and Regulator apply. Head costs are normalized to their listed base damage/range; future damage/range configuration uses the shared scaling without applying the baseline twice. Lure scales with radius squared, relative to20 tiles; no weapon damage factor.
- **6B:** Double these new costs. Stronger resource pressure, especially with explosive Splitter builds.

Retain existing Potato/Ballista/rotary baselines; Ballista's approved range increase naturally raises its existing range factor. These are proposed tuning values, not measured battery life. Do not promise six in-game hours for every configuration. Recompute estimates from actual modules, cadence, reloads and world day length. No idle drain is introduced.

## 7. Lure acquisition and defaults

- **7A:** Loot-only, weight10 (Rare at current default tier anchors), inventory weight0.2, non-stacking, usable with every head. Include normal module loot pools, Module Packs and LootLab. Default range10 tiles, repeat OFF; retain approved5-20 limits/five-second repeat. Save range; stop repeat on pickup/power-off and require manual restart. Keep repeat on an ordinary save/reload while still installed/powered, with no offline/catch-up pulses. Audible gain tracks range; Suppression does not change this explicit lure setting.
- **7B:** Same behavior, loot weight14 (Uncommon at current defaults), easier to acquire.

Actual rarity follows loaded tier anchors; do not overwrite custom player/account tiers or change the15% zombie Module Pack drop chance. Owned Horde Night clip is bundled as a separate positional Turrets sound, without a sibling dependency.

## 8. Head recipes and maintenance

All quantities are Project Zomboid inventory units, not real-world fabrication instructions. Both yield one head with integrated mount, no recipe book, and follow existing base-only wear/repair.

| | Lobber | Scrapshot |
| --- | --- | --- |
| Materials | 2 Metal Pipes, 2 Small Metal Sheets, 4 Scrap Metal, 4 Electronics Scrap, 2 Electric Wire, 12 Screws | 1 Metal Pipe, 1 Small Metal Sheet, 4 Scrap Metal, 2 Electronics Scrap, 1 Electric Wire, 8 Screws |
| Retained tools | Screwdriver, wrench/pipe wrench, pliers, metal saw | Same |
| Skills | Mechanics4, Electrical2 | Mechanics3, Electrical1 |
| XP | Mechanics30, Electrical10 | Mechanics20, Electrical5 |
| Duration | Same recipe time as Ballista (864) | Same recipe time as Rotary Bat (576) |
| Item weight | 8 | 6 |

- **8A:** Recipes above.
- **8B:** Same except double the Scrap Metal and Electronics Scrap for each head. More costly initial construction; no increase to power/damage or skill gates.

Native recipe timing units are deliberately compared to existing recipes, not claimed as real seconds. Existing install/pickup/repair times remain. Final art remains owner-sourced; technical placeholders are not final designs.

## 9. Improvised Shell recipe

- **9A:** One output, weight1: 1 Metal Pipe, 6 Scrap Metal, 1 Electronics Scrap, 8 native Gunpowder uses and 2 Duct Tape uses. Retained metal saw, pliers and screwdriver; Mechanics2/Electrical1; XP5/2. Native recipe time100, matching the ordinary Pipe Bomb craft's configured time. No recipe book. Turret-only, as already approved.
- **9B:** Same except12 Gunpowder uses and8 Scrap Metal. More expensive ammunition sink.

Uses are drainable game charges, not whole jars/rolls. Validate native consumption and displayed costs before installation. These ingredients are gameplay balancing proposals only.

## 10. Player collateral

- **10A:** Moderate custom injuries: an explosive blast applies up to10 body-part damage at center, linearly falling to zero, plus up to50% scratch chance with the same falloff; Scrapshot applies2 body-part damage per connecting pellet, capped at10 per firing event, and one25% scratch roll if any connect. Arms/legs only, no automatic fracture, deep wound, infection or burn. Module critical/Execute/proc effects never target players. Same attack cannot damage a player repeatedly through duplicate collision processing. Distinct explosions still hurt separately. No player auto-targeting.
- **10B:** More dangerous: double those body-part damage values and use lacerations instead of scratches. Existing rotary player injuries unchanged in either option.

These are separate player injury rules, not applying zombie-scale150-900 numbers to players, and not a claim of native explosive fidelity. Native handheld bombs remain unchanged. Respect existing invulnerability and supported-mode checks.

## 11. Aim and travel

- **11A:** Lobber lands within0.5 tile of aim point at minimum range, growing to1.5 tiles at maximum; Accuracy reduces scatter using the shared accuracy bonus relative to its baseline. Grenades travel8 tiles/sec to a fixed launch-time aim point, with a visual arc and collision checks. No homing, no unproven over-wall clearance. Scrapshot retains the approved90-degree fan, with correct geometry and no extra random per-pellet failure. Ballista retains its approved75/60/45% distance curve rescaled to24 tiles and24tiles/sec travel; arc is visual unless actual clearance is proven.
- **11B:** Same, but Lobber lands exactly at the launch-time aim point; Accuracy is unsupported on Lobber and shown as such. Moving targets can still escape during travel/fuse.

Obstruction must stop travel; no teleporting damage through walls. Use existing suitable native firing/impact cues and current suppressed Fragment cue; exact sound IDs are an implementation evidence task, not a new owner audition gate. Show matching range/landing feedback. If safe arc/projectile lifecycle cannot be verified, report the limitation before changing approved travel behavior.

## 12. Ballista storage constraint

- **12A:** Preserve exact physical ammo and existing container weight capacity. Make Manage distinguish magazine, reserve count ceiling and actual remaining weight space, with a clear full-by-weight message. A loaded build may still hold only about44 spears; this fixes misleading capacity presentation, not storage volume. Do not revive packed-weight compression.
- **12B:** Require genuinely larger spear storage before shipping this feature. Investigate native-safe dedicated ammo storage first; a separate exact-item storage system may be necessary and is not yet proven. Keep the rest of the patch independently implementable. No silent item-weight changes, virtual ledger or unsupported capacity override.

## Implementation gates, not further owner choices

Current installed build remains0.2.49 with partial owner findings. Native trajectory/collision, player injuries, exact-item mixed-ammo save/pickup/transfer, engine sound behavior and workload budgeting require local proof. Maintain server-authoritative supported behavior, standalone package combinations, no protected Lua calls and no catch-up bursts. Admit bounded work before spending resources, preserving accepted module semantics and timers. Recipe transactions need native verification. No new owner test is requested during discussion.

Once selected, these choices provide a complete design baseline for C228. New evidence that makes an approved behavior infeasible still requires candid discussion; it is not permission to substitute a different mechanic. No new final art, broader multiplayer milestone, recursive proc chains, packed compression, Workshop upload or PR merge is included.
