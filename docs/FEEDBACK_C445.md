# C445 - 0.2.66 feedback, artist handoff and next corrective scope

**C446 follow-up:** [Twelve-hour goal, saved-time verification and UI previews](AMMO_UI_C446.md) supersede the capacity recommendation and refine the visual options below. These C445 numerical bases remain unselected historical candidates. Requested corrective scope and artist handoff remain.

Date: 2026-10-24. Inspected `codex/performance-barbed-audit` at `5db1edf8f96770c3921cdfb8943317ea0523ddc7`, fetched origin and checked the sole open development PR (#1); origin/dev has no new unincorporated work. Owner supplied three screenshots and requests audit, corrections, an ammo-capacity review, native UI comparison, and artist assets. This is discussion of the next gameplay patch, not approval of newly proposed ammo balance. The explicitly requested standalone asset handoff is created in this turn. Installed Source/Contents and 0.2.66 remain unchanged.

## Owner corrections retained

- Spike Barrier description: rear is **vulnerable**, meaning it lacks retaliation. Do not accidentally add rear contact damage or alter collision.
- Feature text becomes white; statistical labels and their descriptions/values become readable grey, including wrapped lines. Keep rarity and consumption-rating value colors, plus availability/status colors. Expansion kits retain their Controller/Turret rows without a Feature heading.
- Small kit must show **8 total module slots**, not +6, with Controller **+20 Tiles / +200 Storage Weight**. "10x" was explicitly a placeholder, not an approved universal multiplier.
- Controller and Device Settings stay visible together below the map, equal widths and aligned to the map's outside edges. Remove the top Controller Settings navigation button. At reduced widths stack Access/Unassign buttons within their half instead of shrinking their labels. Use measured font-based minimum widths and independent vertical scroll areas.
- Align matching slots across both menus: "Expansion Kit", "Drop Here", the kit's real silhouette, same icon sizes/borders/hover/disabled behavior. Keep meaningful distinctions such as Stored Batteries.
- Add Controller battery endurance information; account for fallback usage and stored batteries rather than presenting idle endurance as guaranteed firing time.
- Authorize a structured artist package, distinct development module markers and very blocky custom head models. This expands temporary mechanical-placeholder scope only; it does not replace the owner's final-art policy or request native texture-pack switching.

## Findings and proposed corrections

### Assignment outside Controller range

Confirmed defect, not a guessed screenshot interpretation:

- `ControlWorld.register` retains a controller when its record exists, is placed, on the same Z and below the membership limit. It does not check XY distance after redeployment.
- `ControlAction:isValid` applies `ControlAccess.range` to Assign with either boolean value.
- `ControlWorld.assign` independently rejects out-of-range devices before considering removal. Thus the UI cannot fix the stranded assignment by sending Unassign.
- `ControlPanel` deliberately displays assigned entries outside the discovery radius; `ControlAccess.remoteAllowed` and `ControlPower.fallback` already reject their remote management/power. The visible entry therefore does not prove remote power is working outside range.

Proposed correction: validate geometry on placement/redeployment, Controller movement and effective-radius changes, with bounded reconciliation for loaded devices. Clear the Controller assignment, old group membership and remote service session when authoritative coordinates prove it outside range. Preserve device owner, name, items, condition and independently valid direct trigger links. Do not interpret temporary unloading, missing client snapshots or power loss as proof of distance. When unloaded data cannot establish the current radius, defer reconciliation until known rather than deleting claims speculatively. Allow an authorized nearby Controller operator to remove its exact stale assignment even outside range; keep owner/admin and exact-ID checks. Handle unloaded records without granting remote inventory access. Do not change the existing direct-trigger semantics or make unlinking silently force a new shot.

### Menu audio

`ISButton` already plays native `UIActivateButton`. OMHTT graph/group/map selections call that UI cue. Pack-opening has its own sounds. `TurretSlot`, `ControlExpansionSlot`, `ControlBatterySlot`, `TurretTransferAction`, `TurretModuleSwap` and `TurretExpansionAction` have no equivalent confirmed module/equipment transfer cue. A slot is an ISPanel, so it does not inherit button activation audio.

Use a quiet native local UI cue for successful install/remove/reorder/swap operations, including Head/Battery/Expansion and both menus. Play once per user operation after exact-item success/replication, not once per returned round or on every hover. Failed/rejected/cancelled actions keep their error text without a success cue. Preserve ordinary native inventory and button sounds; do not add double clicks, zombie hearing events or server-side UI audio. Integration can reuse the bounded replicated completion callback pattern in `ControlTransferCallbacks`; swaps need equivalent success evidence rather than merely entering `perform`.

### Poke Floor capacity

`OMHTT_PokeFloor.txt` still declares `ItemType = base:container`, `Capacity = 15`, `WeightReduction = 0`. Its native capacity text is real container metadata, inherited from the earlier battery design. `ControlPokeAction` rejects new battery installation but keeps old batteries removable; deploy/pickup still transfer the container's contents.

Recommend removing the obsolete portable storage model, not claiming that pressure operation uses capacity. Update deployment/pickup/repair together because current code requires a container. Preserve/recover any real old contents to inventory/floor safely before replacement, and retain condition/exact-item authority. Merely deleting the Capacity line leaves a container and is not a complete fix. Check heavy-item carrying with a normal portable item. No added power, disarm function or trap module slot.

### Tooltips and silhouettes

`ControlTooltipRows.footer` and rich descriptions currently color feature rows grey, with correctly carried wrapped-row semantics. Invert normal/feature styling centrally, and update custom slot/detail tooltips consistently; do not blanket-recolor the game's own native item fields or other mods. Preserve semantic rating/rarity colors. `ControlItemDescription` and `TurretDescriptions` currently show added slots and vague ammo text; both must call the same total-slot/capacity description.

`ControlExpansionSlot` draws a plus sign and literal Expansion Kit title. `TurretSlot` displays Drop Here with its representative kit; `SlotHint.set` reads the script's original texture, which remains a cube/dev icon. `ControlExpansionArt.apply` only replaces an instantiated item's current texture. The hint therefore misses the supplied category/rarity art. Share a cached texture resolver between actual icons and hints, including rarity changes, without creating inventory items each frame. Unify visual components while keeping Turrets and Traps independently loadable.

### Controller endurance

`ControlBatterySlot.update` constructs a plain `ISToolTipInv`; it has no Controller estimate. `ControlPower.idle` currently charges `elapsedGameHours / 48`, so one full battery powers the Controller alone for **48 in-game hours**, before trigger draw and turret/trap fallback. Grid/generator supply can avoid idle battery spending; fallback attack charges have their own path, so grid must not imply every connected defense draws zero battery.

Recommend a compact tooltip: active charge, estimated duration **at recent draw**, and total reserve duration using usable stored charge. Show "Calculating" until a positive valid observation interval exists; distinguish idle-only upper estimate and grid standby instead of inventing infinity. Include all battery spend paths in a bounded ledger; no whole-stockpile scan per hover/frame, no sampling raw real-time while game time is accelerated. Preserve exact charge ledger and existing 64-item scan budget. Expose Controller idle endurance as a useful Sandbox setting with default48, rather than leave the divisor hidden. Estimates remain workload-dependent, not a promise.

## Ammo-capacity conclusion revisited

The settled C280-C283 conclusion was **fixed counts by ammo family**, informed by roughly eight game hours of ordinary firing at a 90-minute day (30 real minutes). Exact day-length/RPM-dependent capacity was rejected. Different reload/cadence/ammo effects justified different quantities. Physical ammunition retains full weight; native two-hand heavy pickup and validated mod-specific over-capacity transfers were implemented separately. Void remains optional and distinct. These conclusions remain recorded in `checkpoints/R4C1_CONNECTED_CONTROLS.md`, C280-C283.

Current defaults, verified in `TurretAmmoCapacity.rows`:

| Ammo family | No kit | Makeshift | Small | Medium | Large | Small/base |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Potato |100|250|500|750|1000|5x|
| Ballista spears |40|100|175|250|350|4.375x|
| Lobber bombs |20|75|150|250|350|7.5x|
| Scrapshot |20|200|400|650|900|20x|
| Firearm rounds |250|1000|2500|3750|5000|10x|
| Shotgun shells |250|400|600|800|1000|2.4x|

Small has eight total module slots (two base plus six); Controller Small adds20 tiles/200 weight. Arc and rotary heads use no ammunition, so no ammo multiplier should imply a benefit there. Magazine capacity is a separate module/head property.

The implementation is `base + floor((familyTierTotal - familyDefaultBase) * legacyBonusScale)`. Legacy expansion bonus controls scale those differences relative to100/200/400/650. It is not currently a plain multiplier, and changing a head's base setting does not proportionally scale expansion storage.

**Feasibility:** a universal multiplier is straightforward at the count resolver; current storage does not require this uneven table. Preserve the same authoritative transfer checks, real mass, feed/chamber accounting, Void rules and C444 overflow behavior. It is a balance/settings migration, not an engine impossibility. Cannot preserve both all current base counts and all current Large counts with one multiplier because their existing ratios differ (4x-45x).

**1A - Recommended if adopting uniform multipliers:** Makeshift **2.5x**, Small **5x**, Medium **7.5x**, Large **10x**, applied to the configured ammo-family base; floor fractional rounds. Preserve current Large totals by changing family bases to the table below. This keeps the previous high-tier endurance goal and simplifies every expansion tooltip/Sandbox control, while intentionally redistributing early reserves. The ammo must still be acquired and carried; this grants storage, not free ammunition or DPS.

| Ammo family | Current base | Proposed base | Proposed Makeshift | Small | Medium | Large |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Potato |100|100|250|500|750|1000|
| Ballista |40|35|87|175|262|350|
| Lobber |20|35|87|175|262|350|
| Scrapshot |20|90|225|450|675|900|
| Firearm rounds |250|500|1250|2500|3750|5000|
| Shotgun shells |250|100|250|500|750|1000|

Tradeoff: starter firearm storage doubles, Scrapshot rises4.5x and Lobber1.75x; starter shotgun storage falls60%, Ballista12.5%. This needs explicit owner selection and eventual play testing. It is not presented as already balanced or approved. Small tooltip would become `Controller: +20 Tiles / +200 Storage Weight` and `Turret: 8 Module Slots / 5x Ammo Capacity` at defaults.

**1B - Preserve current balance:** keep the family table and improve wording to exact totals for the mounted head. Standalone kit information must identify that ammo gain depends on head; do not print a false universal number. Retains all current reserve balance but less compact general information.

**1C - Uniform multipliers, retain current bases:** same2.5/5/7.5/10 schedule, no changes to no-kit counts. Large becomes1000/400/200/200/2500/2500 in the table's family order. Simple but substantial late-tier reductions for Scrapshot/Lobber/firearms and a shotgun increase; least recommended for the previously chosen endurance goal.

For either multiplier migration, preserve explicitly saved per-family and legacy expansion tuning. Record a versioned settings migration/legacy mode rather than reset Sandbox values, reinterpret a custom number silently or touch LootLab rarity/weights. Fresh defaults and migrated saves must show their actual effective rules. Do not add unrelated loot/progression changes.

## Native radio / Vehicle Mechanics UI review

Checked installed B42.21 Lua under `media/lua/client/RadioCom` and `Vehicles/ISUI/ISVehicleMechanics.lua`, not only the screenshot:

- `RWMElement:createChildren/prerender/new`: font-sized framed headers, native `media/ui/XpSystemUI/tab_unselected.png`, compact vertical sections, joypad focus. Reuse native header texture/spacing through one OMHTT theme helper; no need to copy native files into the artist archive.
- `RWMPower:createChildren`: `ISLedLight`, `ISItemDropBox`, `ISBatteryStatusDisplay` compose one compact power row. A lamp plus text suits online/asleep/disabled feedback; text must remain so color alone is not required.
- `ISItemDropBox:render/onMouseMove`: representative item silhouette, occupied icon and valid/invalid hover states. Match these behaviors across battery/kit/head slots. Reuse visual logic, not the radio's item mutation callbacks; ours need authoritative exact-item operations and package independence.
- Vehicle Mechanics: font-sized grouped lists, aligned labels, colored condition values, native scrolling and detail-on-selection. Apply alignment/condition cues to our device rows. A full car-like exploded diagram is unnecessary for Controller connections and would demand additional hit regions/art for no clear benefit.

**2A - Recommended native polish:** retain the current map/connection workflows, apply the native framed header, slot, indicator, scrolling and aligned-row conventions; deliver the requested two equal Settings panes. Keep text contrast, keyboard/joypad focus and unclipped button labels in view. No return of pin/lock controls.

**2B - Restrict this patch to consistency fixes:** two Settings panes, correct slots/hints/sounds/tooltips/range cleanup, retain the current header/battery-bar styling. Smaller visual scope; native-style refresh remains deferred.

## Artist deliverable and checks

Created `art/artist-handoff/C445/` with current project assets from Source once, unpacked atlas PNGs and exact sprite/offset mapping, existing editable Potato/base scene,32 unique module markers plus four kit markers, six new24-48-triangle box heads in OBJ/native `.x`, previews and an artist guide. Existing Potato and firearm support are reused; actual vanilla/modded weapon models are not copied or replaced. Shared byte-identical source/export files have one canonical asset entry. Source images supplied for categories/rarities remain intact. No native switching system or runtime asset duplication is added.

Checks: every source/export hash, PNG decode, native-pack page extent, unique module item ID, finite mesh values, valid triangle indexes, independent OBJ/native vertex/face agreement; both contact sheets visually inspected. No game-native import or rendered placement claim for the staged new heads. Texture/depth/rotary scale/pitch and fallback integration remain patch verification. See the handoff README for axes, pivots, module rarity mapping, artwork provenance and deliverable instructions.

Owner log captured through the standard Capture action: `diagnostics/captures/20261024-125714-6543`, console SHA256 `A5E9450A15D985AA4D08FC2257BC74404A0A6ABA864082876454951ECB6B3EE8`. It identifies0.2.66/SP. No OMHTT exception stack is found; base-game font and unrelated Firearms translation warnings exist. This does not invalidate visible owner-reported failures. No new gameplay acceptance, performance stress result or connected multiplayer pass is claimed.

**Decision needed:** ammo policy1A/1B/1C and native UI scope2A/2B. Asset creation is complete; gameplay patch integration awaits those scope decisions. No repeated approval request for the clearly requested text/slot/range fixes.


## C447 selection update (2026-10-24)

C446 2A Native slim is selected for Controller and Turret Manage; shared headers/meters are implemented in Source. [Exact scope and remaining work](AMMO_UI_C446.md#c447---556-supply-and-selected-native-slim-style-2026-10-24). Separate C445 functional/layout/asset corrections remain pending. Ammo ceilings, base values and universal multipliers remain unselected; Horde Night and Trait Shop styling is explicitly deferred.
