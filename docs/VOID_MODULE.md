# C231 Void Module and capacity revision (2026-10-14)

## C233 Ammo balance, attenuated stats and separated decisions (2026-10-14)

Owner suggests comparable limits such as40 spears/40 grenades/250 rounds, explicitly asking damage balance including AoE rather than approving equal counts. Rejects the ambiguous Shell label for the turret projectile; use **Improvised Grenade** as player-facing name, leaving shotgun shells clearly distinct. Existing recipe and150/radius4 behavior stay selected; this is naming, not a handheld grenade capability. Existing internal identifiers need not change solely for the label.

Owner selects C2322B with a correction: donor ammo statistics should contribute an attenuated bonus/multiplier, not be added in full to head damage; this framework will also support future alternate firearm ammunition. C2323A (whole potatoes/SweetPotato/registered equivalents including rotten/cooked states, no cans/jars/seeds/prepared dishes) is approved. Relevant per-ammo quality/condition cannot be erased by Void conversion if needed for selected stat behavior. Replace the proposed flat full-type-only count map with counts grouped by full type and relevant validated quality/stat state; do not keep whole live inventory-item objects in metadata or silently discard all condition. Aggregated display can still show totals by type. More distinct state groups increase storage work; process/copy them through bounded operations and cache displayed totals.

Vegetable launcher annotation is a request to explore an idea, not approve implementation. Record a future produce-ammo extension to Potato Launcher as the preferred first exploration; a separate head should need a distinct role. Keep this patch's approved whole-potato boundary. No new final art or recipes are authorized by the joke.

Owner then corrects decision presentation: separate each topic, give brief thoughts, show options, blank line before the next topic. This supersedes C232's combined-table preference and is persisted in AGENTS.md. Current response should address the vegetable annotation with its required inline directive.

### Decision1 proposals: capacity targets

- **1A recommended:** Standard firearm base allowance250 rounds, spear-family hard ceiling40, Improvised Grenade20, Aerosol Bomb6, Pipe Bomb4. Existing potato and scrap limits unchanged. Standard firearm expansion ammo bonuses remain applicable; special-ammo hard ceilings do not grow with kits, whose module-slot benefit remains. Void bypasses reserve limits, not magazine/reload behavior. These are starting balance targets, not guaranteed equal damage or physically guaranteed storage.
- **1B:** Same, but Improvised Grenade40, Aerosol12, Pipe8. More generous explosive endurance and substantially greater crowd-damage potential.

Mixed Lobber ammo should share its capacity budget: sum(count for payload / its pure-payload allowance) <=1, including ready rounds. This is a proposal within either option, replacing the earlier independent-per-payload allowance proposal; e.g.10 Improvised Grenades plus2 Pipe Bombs fills1A. Cannot fill every payload to its standalone maximum at once. Spear variants likewise share one family limit. Native weight checks still apply;250 heavy/modded rounds are a count target, not immunity from weight. Existing excess contents are never deleted. Magazines and native firearm loaded rounds are not silently truncated. No blanket75% reduction is selected.

Arithmetic evidence:40*240=9600 potential spear damage before hit chance, overkill and module effects. Hypothetical grenade sum-of-falloff weights3 means each150 grenade applies450 aggregate damage:20*450=9000,40*450=18000. This is an illustrative crowd assumption, not measured typical target density. Native Aerosol center damage350-<700/radius6 and Pipe450-<900/radius7 imply much more area potential. Linear falloff over a uniformly populated circular area has average factor1/3 and area proportional to radius squared; obstruction, density, timing, misses and overkill break simple equalities.250 bullets at illustrative40 damage is10000; actual guns have different damage and cadence, so no universal equivalence claim. Conservation/Splitter/Fragment/critical/proc builds further vary damage per stored round. Keep fixed published family values instead of dynamically recapping inventory on module changes.

### Decision2 proposals: ammo stat contribution

Compare compatible donor ammo's base damage stat to the designated ordinary ammo reference for that head/family, before modules and criticals. Let r=donorDamage/referenceDamage.

- **2A recommended:** Head damage multiplier=1+0.25*(r-1). A spear with twice the reference damage adds25%:240 becomes300. A half-strength spear gives0.875x:240 becomes210.
- **2B:** Use0.50 instead: double-strength spear yields360 head damage; half-strength yields180.

One proposed shared framework for current spear handling and later alternate firearm ammo. Do not pretend existing bullet items all expose comparable weapon damage; future firearm ammo needs its own registered relative modifier/reference, not the mounted gun's damage counted twice. Baseline ratio uses average native min/max damage where available; condition is retained separately and is not automatically a second damage multiplier. Require finite nonnegative values and a positive reference; unsupported stats remain unavailable until a compatibility adapter supplies meaning. The percentage compresses ordinary differences but is not an upper bound against absurd mod stats; outlier policy/condition wear behavior still requires validation if found. No new uncapped 1:1 addition, stealth clamp or global firearm damage rewrite authorized.

This is planning only, based on714170c with origin fetched. Existing C229-C232 unrelated choices remain approved. Native feasibility, exact damage weighting selection and this capacity proposal are not yet implemented. Mirror under C108/C119; no source/version/install/test changes.

## C232 Selective capacity, broad ammo families and compact decisions (2026-10-14)

Owner replaces the blanket75% proposal with **selective maxima for stronger/slower ammunition** (1C). Accepts rotten and other potato variants, requests automatic support for modded spears, selects **3A with Void beside Ammo**, **4A safe portable removal**, and **5A Mythic/defaultweight1**. Void still uses magazines. All previously approved module-owned/non-withdrawable storage rules remain. Exact ammo caps, treatment of donor condition/metadata and the scope of prepared potato foods are not automatically settled by the family-compatibility request.

Presentation instruction is persisted in AGENTS.md C232: compact numbered decision tables, recommendation and one short material concern; detailed rationale in documents. Do not repeat settled choices as questions.

### Confirmed native evidence

- Installed42.21 `XpSystem/XpUpdate.lua` calls `weapon:getScriptItem():containsWeaponCategory(WeaponCategory.SPEAR)`. Native `generated/items/weapon.txt` includes many `base:spear` weapons (crafted/fire-hardened/crude/long and attached-tool variants). Correctly categorized mod HandWeapons can follow the same classifier. Cache classification by full type after scripts load; provide explicit allow/deny compatibility overrides for miscategorized items. Do not match English names, blindly accept any identifier containing Spear, or rescan all item scripts each tick.
- Current source hardcodes `Base.SpearCrafted` and `Base.Potato` in `Turret.kind`, acceptance and reserve counting, and head ammo metadata. Broadening only the UI would leave firing/transfers broken; route acceptance, physical reserve counting, firing, tooltip, Void conversion and saves through the same ammo-family classifier.
- `Base.Potato` uses `FoodType=Vegetables` and `Tags=base:isseed`, neither uniquely identifies potatoes. Native food scripts also contain SweetPotato, jars/cans/opened variants and PotatoPancakes; name matching would incorrectly include seeds and recipes. Use explicit native whole-potato types plus a mod compatibility registry/custom opt-in tag. Native rotten/cooked states belong to the same Food item and need no separate ID. Owner explicitly overrides the C231 rotten-food rejection for potato ammo.
- No spear matches were found in the locally installed FirearmsVanilla42.16 media/scripts search; many visible spear variants are already native. This does not rule out other versions/add-ons or establish the currently enabled mod roster. Promise category-based interoperability, not universal support for incorrectly tagged mods.

### Remaining compact options (proposals, not approved)

| Topic | A (recommended) | B | Material concern |
| --- | --- | --- | --- |
|1 Physical special-ammo caps |Spears40, Improvised Shells12, Aerosol Bombs6, Pipe Bombs6; other existing limits unchanged |Spears20, Shells6, Aerosol3, Pipe3; others unchanged |These hard ceilings include ready ammunition; expansion kits cannot raise them. Native weight may still bind; Void is exempt, but magazine sizes remain finite. |
|2 Projectile/ammo statistics |Accepted variants use the mounted head's existing damage; Void stores standardized full-type counts and discards condition/freshness |Preserve donor condition and scale damage from individual spear stats |B adds balance and serialization work; one ammo family's modded melee damage must not accidentally become a Ballista damage exploit. |
|3 Potato-family boundary |Whole Potato/SweetPotato and registered equivalents, including rotten/cooked/burnt states; no cans, jars, seeds or prepared dishes |Also support opened canned/jarred potatoes |B needs an explicit ammunition yield and container-return rule; never silently destroy containers or convert arbitrary dishes. |

For1, the spear cap is shared by all accepted spear variants; changing full type must not multiply storage. Limits apply to each listed explosive family, shared across equivalent registered variants; mixed Lobber reserves may hold each distinct approved payload up to its limit, still subject to real weight. Existing types are not blanket nerfed. Expansion kits still supply module slots and their existing ammo benefit for uncapped ordinary families. Values are proposed test baselines, not measured balance. Native loaded firearm magazines are not truncated by a new generic cap. On existing over-cap contents, block further additions without deleting ammunition. With1B, the Lobber's base3-magazine still fits3 native bombs; any larger magazine module is bounded by actual family ammo availability as in the current cycle.

For2A, conversion preserves full-type identity/count for display and compatibility, not item-instance details; standardized charges cannot be physically withdrawn. Rotten potato acceptance does not imply all rotten food is ammunition. Existing favorited-item protections and unsupported explosive variant guards remain. Intact spear requirement remains the proposed baseline; if broken spear use is desired, select it explicitly rather than silently treating broken tools as usable. Category inclusion is an engineering method; no new mod dependency required.

UI: distinct Void target adjacent to Ammo, explicit Store in Void, no install-time or normal Ammo-transfer auto-conversion. Show compatible current ammo in Ammo/selected-head context; Void tooltip lists all stored types. Manual operation, safe removal and Mythic acquisition are selected, not open. Same bounded transfer path, cached revision-based display and normal reload/magazine behavior remain engineering obligations.

Based on ecff49d; fetched origin. No gameplay/source/version/install/test-acceptance changes. These selections and remaining options supersede conflicting C231 proposal text below; preserve history rather than claiming the75% nerf was approved.

Owner selects C2301A (five mini grenades) and2B (Tire Pump standard recipes for both heads, with same-output improvised alternatives). They would prefer a more distinctive donor component but accept the pump; do not reopen those recipes without new evidence. The module/recipe choices are approved design, not implemented.

Owner replaces the proposed fixed40-spear/deferred-storage decision with3C: reduce all ammo capacities by roughly75%, introduce **Void Module**, consume physical ammo into effectively unlimited weightless storage for turret use, associate storage with the exact module, show currently compatible ammo in the turret Ammo section and all contained ammo in its tooltip. Module portability and non-withdrawable ammo are explicit direction. Reduction scope/exact values and detailed lifecycle remain open. Prior40-spear choice is the baseline for comparison, not permission to silently choose40 or10 after this revision.

## Evidence and feasibility

Current `TurretStats.resolve` calculates physical total-ammo limits separately from magazines, adding kit bonuses100/200/400/650. `Turret.configure` and native transfer room checks apply weight separately. Void counts would bypass physical ammo weight without altering native item weights/capacity or restoring the abandoned packed-turret compression feature. The module itself retains its normal inventory weight.

Current custom-head cycle `TurretCycle.update` limits loaded counts by actual ammunition and persists cycle state on the exact head. `TurretConservation.consume` persists fractional consumption debt. Native firearm ammo, physical reserves, and the new virtual counts must share deliberate source accounting, not simply add an unlimited capacity number. Existing `getModData` persistence on heads/items suggests a module-owned, versioned type/count map; native save/reload/transfer proof for this new payload is still required. This is a feasibility direction, not a runtime verification claim.

Store one count per registered supported ammo full type, not one dummy item per round. Full types separate modded ammunition; do not classify by localized display name. Counts are finite and nonnegative; effectively unlimited means no gameplay count cap, not infinite free ammunition or unbounded numerical precision. Guard numerical overflow. Zero entries can be removed; unavailable mod types must remain recoverable data, not erased or substituted. No new all-world/per-tick scan: update on committed conversion, reload/consumption, service and item changes; cache UI by revision. Use the existing bounded transfer budget so600-round conversion does not freeze the game.

## Choices to present now (proposals)

### 1. Physical capacity reduction

- **1A recommended:** Reduce expansion ammo bonuses75%, rounded up: Makeshift25, Small50, Medium100, Large163. Keep base ammo limits (including40 spears) and magazine sizes. Void already has a major storage/portability advantage without weakening starter turrets further. Expansion module-slot bonuses stay unchanged. Physical weight checks still apply, so the reduced bonuses cannot guarantee heavy-ammo capacity.
- **1B:** Reduce both base total-ammo limits and expansion ammo bonuses75%; leave magazines and expansion module slots unchanged. A100 baseline becomes25, spear40 becomes10. This makes Void more necessary and is a larger balance change. Native gun magazines larger than the reduced total cannot be silently truncated or have ammo deleted; any selection of1B needs the capacity model to treat the total limit as at least the current magazine capacity or explicitly split reserve and ready limits. Present this edge case before implementation rather than inventing a hidden exception. Existing saves/configuration must not be silently rewritten or excess physical ammo deleted.

### 2. Conversion contents

- **2A recommended:** Conversion creates standardized turret ammo charges by full type. All supported ammo families may coexist, including those incompatible with the mounted head. Physical condition, freshness, names and other per-item metadata are discarded explicitly; virtual potatoes do not rot and virtual spears retain no individual condition. Only valid usable inputs are accepted; reject rotten food, broken weapons, favorited items and unsafe payload variants. Only ammo types with a verified turret adapter are supported; arbitrary unrelated items are not ammunition. Plain loose native/compatible mod ammunition first; boxes and loaded magazines are not silently destroyed/unpacked. Existing ammo registration governs compatibility, not the mounted head alone.
- **2B:** Preserve item condition/freshness/custom metadata inside virtual storage. More serialization and identity work; reduces the count-map performance/simplicity advantage. Exact behavior of aging and per-item status must then be specified before implementation.

In either case converted ammunition is permanently non-withdrawable as physical items, as requested. It is not recreated by firearm unloading, removal, crafting, module swapping or any ordinary inventory action. This means no loaded virtual native gun/magazine may escape into player inventory with ordinary recoverable rounds. Existing physically loaded rounds remain actual items/counts, separate from virtual credit.

### 3. Conversion interaction

- **3A recommended:** An explicit **Store in Void** action/drop target. Installing a module does not consume existing ammo. Normal Ammo transfers remain physical unless the player explicitly selects conversion. Clearly label irreversible conversion, without repetitive per-round confirmations. Both Manage and direct inventory actions use the same bounded transaction path.
- **3B:** Incoming supported loose ammo dragged into the Ammo area while Void is installed automatically converts. Clearly change the area label to **Void Ammo**. Existing contents are still never auto-consumed merely by installation. Easier flow, greater accidental-conversion risk.

Conversion should work while turret power is OFF and have no extra battery charge: installed module's ordinary rarity surcharge already applies during firing. A storage operation should not require burning turret battery. Recommend physical ready/reserve ammunition first, then compatible Void ammo during normal reload; do not bypass reload, magazine size, Lobber priority/fallback or Conservation/Splitter rules. Native loaded physical rounds remain preferred until spent. A virtual reload binds its source module and ammo type for consistent consumption; do not silently mix ammo identities.

### 4. Module removal

- **4A recommended:** Safe service removal pauses new firing, cancels/reconciles virtual loading, and leaves all unspent virtual ammo on the exact removable module. Module-owned counts include reserved/ready virtual rounds so they cannot be double-credited on removal. Already committed shots stay spent. Conservation debt travels with the module by ammo type; service/swap must not reset it or grant a free Impact first-shot event. Physical ammo remains with the turret/head. Reinstall resumes through normal reload.
- **4B:** Block removal until its currently loaded virtual rounds are spent. Simpler service flow, but awkward with Conservation, no nearby targets or a changed head.

Recommend one Void Module installed per turret, no stacking, weight0.2 even when full. Multiple modules may be carried separately with independent stores; never merge their stores automatically. Pickup preserves the exact module. If the turret breaks, preserve the recoverable module through the established contents-recovery path; if the module item itself is destroyed/deleted its stored charges are lost, with no global backup that can duplicate them. Changing heads only changes which stored type is usable; it cannot discard other stored ammo.

### 5. Acquisition and power

- **5A recommended:** Loot-only Mythic at default weight1, included in LootLab/Module Packs/normal module pools. Standard rarity-linked power surcharge, currently+1.0 to module load at Mythic; not an extra2x multiplier per module or a separate continuous drain. Inventory weight0.2. Custom loaded rarity anchors remain authoritative.
- **5B:** Loot-only Legendary at default weight3; corresponding default surcharge+0.8. Easier access to the same storage capability.

Infinite virtual reserve means expansion ammo bonuses do not further increase Void storage, but expansion module slots remain useful. Void does not increase the ready magazine; Magazine/Reload/Autoloader still work normally. Empty modules still occupy a slot and follow normal active-module power rules; no hidden exemption.

## Display contract

Ammo section shows physical usable ammo and compatible Void ammo distinctly, with current selected payload for multi-ammo Lobber. Never sum bullets, spears and bombs as interchangeable shots. Tooltip lists every stored full type via localized display names and counts, plus the permanent-conversion notice. Incompatible stored types stay in the tooltip when heads change. Preserve magazine bar; Void reserve has no meaningful fill fraction, so use count/Unlimited wording rather than a fake full/empty bar. No overflowing tooltip: scroll/inspect list for many modded types. Detailed list builds on revision/hover, not every tick.

## Verification before implementation handoff

Native item save/load and exact-module transfer, identical-looking independent modules, pickup/reinstall, physical/virtual mixed sources, module/head removal mid-reload, Conservation fractional debt, expansion removal, native gun/magazine unload, invalid/duplicate conversion requests, partial bulk conversion/interruption, unavailable item definitions and destruction cleanup require focused proof. Inventory removal and count credit must form one authoritative validated operation; do not credit on a client/UI preview or imply disk-crash atomicity from a single Lua call. Do not duplicate virtual charges in separate world/global/head backups. Existing supported-mode guards remain; this does not authorize a new multiplayer milestone.

Only documentation changed. All earlier unrelated C229 selections remain settled; no gameplay version/install/test-acceptance changes. Based on7ffbdff; fetched origin. Mirror to the existing development PR under C108/C119. Owner is choosing a materially broader storage feature; native feasibility and exact balance still need selection/proof before shipping.
