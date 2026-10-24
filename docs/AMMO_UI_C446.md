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
