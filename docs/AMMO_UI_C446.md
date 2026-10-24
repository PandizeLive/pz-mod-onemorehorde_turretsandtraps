# C446 - Twelve-hour ammo endurance and Controller meter choices

Date: 2026-10-24. Owner asks for firearms at 5,000 rounds, other ammunition runtimes, a twelve-in-game-hour continuous-firing target, and descriptive gradient UI mockups. This sets the endurance direction and authorizes standalone comparisons; it does not select a numerical capacity policy or authorize installing a UI variant. Installed 0.2.66 remains unchanged. C445 corrective scope and artist assets remain pending.

## Verified time baseline and calculation

The save referenced by the current console has `DayLength=4` in `map_sand.bin`. The installed game's `SandboxOptions.getDayLengthMinutes()` bytecode maps 4 to **90 minutes**. Therefore twelve game hours equals **45 minutes at normal speed**. Fast-forward advances the simulation and these firing/reloading clocks together. A 120-minute day would make the same ammunition last 75% as many game hours.

Ran current `TurretStats.resolve` and `TurretBatteryEstimate.duration` in the installed Kahlua VM with weapon inputs read from installed vanilla scripts and Firearms B42's 42.16 scripts. Native-script inputs and explicitly modeled gun methods are not a live weapon/endurance test. Twenty weapon/head samples across four builds produced 80 rows; independent arithmetic checked duration and both sides of the twelve-hour threshold. Includes normal magazine reload and rack delays, full first magazine, sustained target availability; excludes aiming changes, initial wake, jams, breaks and supply interruptions. A partial final magazine can shorten the final reload slightly; practical capacities below are rounded upward. These are ammo endurance estimates, not a promise of uninterrupted combat or battery life.

Saved firing/reload/cycle settings match the default timing baseline (0.75/1/1 for firearms, Enhanced 4/3). The save preserves Rapid Fire extra-copy 25%, versus current fresh-world 20%; the saved first-copy value is 40%. Baseline/Enhanced-only numbers do not depend on that difference. Calculation-only speed-stack examples retain the owner's saved values.

Full comparison: [all twenty samples](../art/ui-mockups/C446/ammo-table.md). Sanitized, relevant numerical inputs and result rows are retained beside it. Raw saves and console logs are not included in the handoff.

| Weapon/head | Current Large stock | Estimated game-time runtime | Minimum stock for 12 h, normal firing | Minimum stock for 12 h, Enhanced Firing |
| --- | ---: | ---: | ---: | ---: |
| M4 (Firearms B42) / native M16 |5,000|9 h 32 m|6,290|7,832|
| M9 (Firearms B42) |5,000|20 h 11 m|2,972|3,721|
| Native M9 |5,000|17 h 25 m|3,447|4,266|
| Native M14 |5,000|23 h 31 m|2,552|3,261|
| Native bolt-action .308 rifle |5,000|48 h 39 m|1,235|1,510|
| Native pump shotgun |1,000|9 h 08 m|1,313|1,542|
| Native double-barrel shotgun |1,000|14 h 03 m|855|901|
| Potato / Sweet Potato |1,000|8 h 53 m|1,351|1,351|
| Ballista / accepted spear types |350|9 h 18 m|451|564|
| Scrapshot / all accepted scraps |900|8 h 23 m|1,287|1,638|
| Lobber / Makeshift, Aerosol, Pipe Bomb |350|8 h 32 m|492|656|

Five thousand shells would last about 45 h 45 m in the native pump shotgun, or 46 h 09 m in the installed Firearms override; current Large shell storage is only 1,000. Ammo payload type changes damage/power but not these custom-head firing intervals. Arc and both rotary heads have no ammunition; their operation is constrained by battery, condition and target availability instead. The reusable Tether Dart also has no consumable ammo reserve.

## Endurance boundary to select

Interpret twelve hours as the **full Large Expansion** stock target, following the owner's reference to its existing 5,000 rounds. Smaller kits remain progression steps. Do not silently grant every starter turret twelve hours or create adaptive capacity. C280's fixed capacities and rejection of automatic day-length/RPM-dependent inventory remain in force unless explicitly replaced.

**1A recommended:** size fixed Large reserves for Enhanced Firing without Rapid Fire, Autoloader, Magazine, Splitter or Conservation. Suggested rounded totals: **8,000 ordinary firearm rounds / 1,600 shotgun shells / 1,500 potatoes / 600 spears / 1,800 scrap / 700 bombs**. Slower guns exceed twelve hours; that is acceptable head diversity. It also gives the plain baseline some margin. Enhanced currently does not speed Potato through the existing Stats path; do not silently treat this audit as authority to change that behavior.

**1B:** size for ordinary Firing only: **6,500 rounds / 1,400 shells / 1,500 potatoes / 500 spears / 1,300 scrap / 500 bombs**. Enhanced and other speed upgrades reduce endurance below twelve hours.

Fixed stock cannot guarantee twelve hours for all uncapped speed/loadout/Sandbox combinations. In the owner's saved settings, an M4 with Enhanced plus four Rapid modules needs about 12,961 rounds for twelve hours;5,000 lasts 4 h 37 m. Conservation extends endurance, while Splitter can spend additional ammunition. Do not resize inventories whenever modules change or erase these operating-cost tradeoffs to force exactly twelve hours.

The proposed universal kit multipliers remain feasible but need final base values after selecting the target: with 2.5/5/7.5/10 x, option 1A would mean bases **800/160/150/60/180/70** in the family order above. This would substantially increase some starter reserves and exceed the current 500 firearm base-setting limit. That implication must be settled before implementation; numerical ceilings and physical weight handling must be reviewed together. Alternatively keep existing starter reserves and family totals. Neither the previous C445 base table nor these new base values is selected yet.

## Three requested UI mockups

[Editable comparison](../art/ui-mockups/C446/controller-meters.html), plus rendered images:

- **2A / Native slim (recommended):** [image](../art/ui-mockups/C446/controller-native-slim.png). Thin continuous gradient bars below their labels; restrained native-style beveled section headers, simple aligned labels/values and side-by-side service buttons where they fit. Smallest increase in visual noise and height.
- **2B / Radio segments:** [image](../art/ui-mockups/C446/controller-radio-segments.png). Ten lit segments for battery, ammo, health and free capacity, with exact numbers above. More pronounced radio-style centered header strips and a full-width action stack. Closest to the radio reference, but taller and visually busier.
- **2C / Readable gauges:** [image](../art/ui-mockups/C446/controller-readable-gauges.png). Wider 24 px continuous bars with label/value inside; flatter headers with a restrained left accent. Easier to spot remaining resources, but gives meters more prominence than the native slim design.

Common layout: battery and Expansion Kit split their equipment allocation evenly; Online/range stays in its right status area. Device Settings and Controller Settings occupy equal halves below the map, aligned to its outer edges. No top Controller Settings button. Compact connection entries, shared section treatment, full readable controls, wrapping/stacking at constrained widths. Map/artwork and resource values are illustrative; this is not an installed game screenshot. Opaque mockup surfaces stand in for the live game's dark backdrop; final integration can retain existing readability-safe transparency.

Meter meaning is consistent: filled area means **remaining** battery, ammunition, health or free capacity. Storage shows both 165/400 used and 235/400 free, so a shrinking bar means less available room. Preserve counts/percentages and textual states for color-independent readability. Use a subtle shaded fill, amber at low remaining resources and red near depletion; no pulsing/glowing decoration. Reuse a cached native-style gradient and existing state values; no new scan per frame or generated per-item textures are necessary.

Standalone checks: all three variants rendered and visually inspected;12 variant/width checks at 1080/736/390/320 found no horizontal overflow or control clipping; local Access/Unassign interactions and script-error checks passed. These establish mockup behavior only, not native PZ layout acceptance. Owner choice and game implementation remain outstanding.

**Decision needed:** endurance baseline 1A/1B and UI 2A/2B/2C. Twelve-hour goal is recorded; no gameplay balance or visual variant has been installed.


## C447 - 5.56 supply and selected Native slim style (2026-10-24)

Owner asks whether finding 8,000 5.56 rounds is realistic and selects **2A**, explicitly applying the visuals to Controller and Turret Manage. Horde Night and Trait Shop are deferred. This authorizes the selected UI source work; it does not select C446's numerical ammo option, alter loot, or approve the entire pending corrective build for installation.

### Supply evidence

Current installed vanilla `media/scripts/generated/recipes/recipes_ammunition.txt` (`OpenBoxOfBullets20`) unpacks one `Base.556Box` into **20 rounds**. `recipes_packing.txt` (`OpenCarton12`) unpacks one `Base.556Carton` into **12 boxes**, or **240 rounds**. Thus 8,000 rounds is **400 boxes**, or 33 1/3 cartons; **34 full cartons contain 8,160 rounds**. These are current B42 quantities, not assumptions based on another game version.

Current `media/lua/server/Items/ProceduralDistributions.lua` includes 5.56 boxes and cartons in `ArmyStorageAmmunition` and `GunStoreAmmunition`, alongside competing calibers. Those entries use weighted rolls: their weights are neither guaranteed counts nor literal percentage chances. Firearms B42 adds other ammunition to these pools; it does not establish a guaranteed 8,000-round supply. No store-count or acquisition-day promise is justified without sampling actual map containers, rarity settings and prior looting.

The current save has `AmmoLootNew=0.6` and `HoursForLootRespawn=0`. Respawn is off, so previously cleared ammunition stores do not routinely replenish. Loose native 5.56 weighs .035 per round (280 encumbrance for 8,000); the installed Firearms B42 42.16 override in `scripts/Items/Firearms_Items_Ammo.txt` sets .02 (160 encumbrance). These are loose-item carrying weights, not packed-carton weights or a change to turret virtual reserve handling. Only these relevant settings and source conclusions are recorded; raw saves are not included.

**Assessment:** feasible as a late-game stockpile after targeted looting, but not a reliable ordinary fill or sustainable daily single-turret budget. Capacity and affordability are separate: allowing 8,000 reserves room for a siege without making its ammunition cheap. Retain 8,000 only as a proposed ceiling, not an assumption about what players routinely own. The twelve-hour target still needs a baseline choice; making smaller practical stocks last twelve hours would require explicitly reviewing ammo efficiency/cadence and module tradeoffs. No such rebalance, loot increase or new numeric stock target is selected here. The C446 1A/1B capacity proposals remain unselected.

### Selected visual implementation

Source now shares one Native slim header/meter implementation between Controller and Turret Manage. Existing native window-header texture is reused for restrained shading; no new artwork, texture generation, scan or per-item cache is introduced. Header highlight/separator lines retain native panel structure. Continuous meters represent remaining battery, ammo, condition or free storage; green above 25%, amber at or below 25%, red at or below 10%. Existing text/tooltip values remain available, and Controller storage explicitly labels its free weight. The stockpile list reserves ten extra pixels for the new meter.

Affected clients: `ControlTheme`, `TurretSlot`, `ControlBatterySlot`, `ControlGraph`, `ControlStockpilePane`, plus one EN translation. Both management menus use the shared helpers; group strips use the same header treatment. This is the selected visual treatment only. C445's separate settings-pane layout, assignment cleanup, transfer audio, slot hints/endurance, tooltip and asset-integration corrections remain pending, not silently marked complete by this styling selection.

Verification: installed Kahlua compiles 329 runtime/translation files; current suite plus the focused meter bounds/threshold/zero-width probe passes **27,607 assertions**. The meter uses at most four draw operations, clamps fractions and emits no fill for empty/invalid resources. Translation JSON parses; changed source introduces no prohibited protected calls; diff whitespace checks pass. Local evidence: `.local/c447-style.log` and `.local/c447-style.lua`. UI/world/network objects in this suite are test doubles; no live performance, native gradient rendering or connected-client acceptance is claimed.

Source changes are staged for the next patch. `Contents`, installed **0.2.66**, immutable test tag and saved balance remain unchanged. The cumulative Workshop draft retains its existing heading/notes and gains one net visual-change bullet; no publication occurred. Standing C108/C119 commit/mirror applies. **Wait for a patch** for visuals; ammo balance discussion remains open.


## C448 - Six-hour target supersedes twelve hours (2026-10-24)

The owner now targets six hours of constant M4 firing and requests every kit/head comparison. [Current proposed multipliers, bases and full runtime tables](AMMO_SIX_HOURS_C448.md) supersede the unselected twelve-hour numerical candidates. C447 Native slim selection and staged implementation remain unchanged. Numerical approval remains pending; no gameplay or installed change.


## C449 approval update (2026-10-24)

Owner selects C4481A. [The six-hour table is now approved](AMMO_SIX_HOURS_C448.md#c449---1a-selected-2026-10-24), superseding the unselected twelve-hour numerical candidates. Native slim remains selected for both management menus; Horde Night/Trait Shop styling stays deferred. No Source/Contents or installed change is claimed by this approval record.
