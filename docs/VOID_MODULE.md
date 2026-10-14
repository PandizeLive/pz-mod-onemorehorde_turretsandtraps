# C231 Void Module and capacity revision (2026-10-14)

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
