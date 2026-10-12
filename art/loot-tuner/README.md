# Knox Country Loot Lab

Component controls edit direct loot weights (zero disables). Global/material/roll controls remain separate. Existing saved scenarios, cloud values and Sandbox exports retain their multiplier schema; the UI converts weight to/from the baseline internally, without rescaling saved tuning. Display formatting does not rewrite stored values. Limits match the game's per-item 0–20 multiplier, expressed as 0–20 times each component's baseline weight.

Open `index.html` directly in a desktop browser. Keep `data.js`, `model.js`, `app.js`, `style.css` and `provenance.json` alongside it. No server, account or internet connection is required.

This is a personal, offline balancing tool for **new-world estimates**. It does not change the game, install a gameplay patch, or predict a save's exact future drops.

## Use

1. Choose a component, or All components.
2. Change the T&T global multiplier and individual component loot weights. Material loot defaults to Apocalypse's 0.60; use your intended world settings.
3. Click **Refresh spawns** for a new seed. Generated spawns shows one sample world, with a distinct color for each component. Switch to Container chances to inspect possible containers.
4. Toggle individual components, or Show all / Hide all. Visibility never rerolls loot or changes rates. Select a town, zoom and hover dots for coordinates, floor, chances and generated quantities.
5. Compare countywide and nearest-town estimates. Save/load scenario JSON to compare settings; export the Sandbox excerpt when satisfied. Apply settings yourself only after reviewing the excerpt.

The baseline is **T&T 0.2.47** and **Project Zomboid 42.21.0**, including Critical/Accuracy and the reduced Suppression loot weight. The owner approved this gameplay patch and site update together. Gameplay installation is tracked separately in `docs/RELEASE.md`.

## What the numbers mean

The map contains 18,514 eligible **container-sprite candidates**, extracted from native lot headers/packs, with 75 eligible procedural routing rules. Real map geometry and town labels come from the installed map. All floors are included; a dot is a possible container, not a promised module.

The generated overlay first selects one pool per candidate using shared room quotas, then samples each component in that pool with an independent, stable per-container seed. The same seed/settings reproduce the same result; changing one component does not reroll others. Co-located components have small screen-space offsets for readability, without changing their world coordinates. Scenario JSON also retains visibility and overlay choice.

The model runs 256 reproducible room-routing scenarios, randomizing candidate order and respecting matching forced tiles, eligible room quotas and competing pools. It applies the current native integer loot roll threshold, Material loot multiplier and minimum-one roll count. Items have separate roll chances: loot weights are not percentages of a normalized bag of prizes.

Expected counts are averaged over routing scenarios. The 90% range is the central interval of modelled item draws. It is **not** a confidence interval for extraction accuracy or for all possible game behaviour. Regional groups use distance to the nearest native town label, not official boundaries.

At 100% retention, estimates assume every successful roll fits and survives. The retention slider applies independent losses as a sensitivity analysis. It is not calibrated against the game and is not exported as a Sandbox setting.

### Known exclusions and uncertainty

- Container capacity: the native picker can abort a pool early when a successful item cannot fit. Module entries are appended after vanilla entries, so capacity can materially reduce the results.
- Room stories, container replacement, nested inventories, vehicles, corpses, respawn, mod maps and other mods are not simulated.
- Room quotas consumed by non-candidate containers are not simulated. Native iteration order and player exploration order can differ from the random candidate order here. Native weighted selection's integer/hash iteration details are approximated by continuous weighted selection.
- Multi-sprite candidates require runtime confirmation. The extraction is not a census of generated world ItemContainers.
- New-world time multiplier is fixed at one, and ZombiePopLootEffect at zero. Other values are outside this model. Full-county totals assume eventual generation of all candidate containers, not immediate availability at spawn.
- Installed module loot is single-player; this is not a multiplayer forecast.

Use relative comparisons to narrow release settings, then calibrate against fresh in-game containers. No exact spawn-location claim is made.

## Rebuild and verification

Tools are in `../../tools/loot_site/`:

- `prepare.py`: parse current native map headers and prepare an isolated stock export probe.
- `export.lua` / `export_native.py`: export current native loot routes and sprite properties using an isolated stock server cache; no live save or installed mod changes.
- `build_data.py`: match eligible physical sprites in native lotpacks, read native map geometry, and read canonical packaged T&T weights and pool subsets.
- `test_model.cjs`: verify integer probability thresholds, disabled entries, quota selection, seeded sampling, aggregate consistency, import validation and numerical monotonicity. Run using Node.
- `verify_site.py`: check local HTML dependencies, control IDs, provenance hashes and record static checks.

Extracted source metadata is in `provenance.json`. Detailed extraction and test reports are in `../../diagnostics/loot-site/`. This data snapshot contains extracted game map information. The owner authorized deployment behind the OMH admin login.

No browser-rendering acceptance is claimed by the automated checks. The model and local links are checked independently; the user opens the local HTML for visual review.

## Mobile controls and rarity

Pinch to zoom, drag with one finger, or use the 44px on-map zoom controls. Tap a nearby marker when zoomed in for container details. The Tune loot / Back to map links avoid scrolling through the report on a phone. Legend checkboxes, dots, names and weight fields use fixed columns. A separate colored marker moves on a fixed logarithmic 0–1,000+ expected-items scale; it includes the final scenario multipliers and retention. It reflects estimated abundance, not random sample luck.

`tools/loot_site/test_map_controls.cjs` checks the actual gesture controller for pinch anchoring, pinch-to-pan continuity, cancellation, taps and limits. Physical iOS/Android interaction remains a user acceptance check.

## Saved settings

The hosted admin LootLab autosaves rates, seed, component visibility, estimate selection and overlay to the signed-in admin account. PC and phone must use the same login. Set to Default restores the T&T 0.2.47 scenario baseline (including Material 0.60, rolls 1 and retention 100%) and saves that reset. Map pan/zoom and town jumps are navigation, not saved tuning settings.

The account endpoint uses the existing admin host/Access/allowlist gate and a separate D1 table. Writes use revision checks; clients merge only locally changed fields after a conflict. Explicit reset/import replace the whole scenario. Saves debounce for 450 ms and refresh when the page regains focus or every 15 seconds while visible. A browser-local pending draft survives connection failures and reloads; the status distinguishes unsynced changes from successful saves. A failed initial read never uploads defaults. Local file copies use browser storage only.

Implementation: `settings-sync.js` owns synchronization; `app.js` connects the controls. Server validation and SQLite-backed request/controller tests live in the website project's `cloudflare-api/src/loot-lab-settings.ts` and `tests/loot-lab-settings.test.ts`. Baseline/schema changes must be coordinated with that validator.

## Component routing in 0.2.23

- ElectronicStoreMisc, CrateElectronics, MechanicShelfElectric and ArmyStorageElectronics: all 15 components.
- ElectricianTools: Firing, Detection, Filter and 360.
- GunStoreAccessories: Suppression, Range, Velocity, Accuracy and Critical.
- ToolCabinetMechanics: Reload, Rapid-Fire, all three Expansion Kits and Autoloader.

The native pools have their own roll counts and room quotas. Both generated spawns and expected probabilities enforce these component subsets. Old 0.2.22 account settings, JSON exports and unsynced browser drafts retain their tuning; the two new components default to multiplier 1 and visible. Set to Default explicitly resets the whole scenario.

## Save feedback correction, 2026-10-02

The sticky status bar distinguishes the hosted account-sync page from a browser-only local copy and links local users to the hosted page. Component rates and seeds register valid input while typing; incomplete numbers remain uncommitted and background refresh does not overwrite a focused number field. Model recalculation is briefly debounced after recording the edit. Page close still requests a keepalive flush, with browser drafts as recovery if a save cannot finish. Sync now retries pending edits or fetches the latest account state. Download scenario exports JSON; it is separate from automatic account saving.

## Approved defaults — 0.2.24

The owner approved account scenario revision 84 on 2026-10-02. Overall T&T loot is 6; Firing, Detection, Small/Large Expansion Kits and Autoloader are 3; all other component multipliers are 2. Global and component values multiply. Material 0.60, rolls 1 and retention 1 remain estimate inputs; the mod does not override vanilla Material loot or roll counts. Scenario seed/visibility are not gameplay settings. Existing account tuning and saved game Sandbox values are preserved. New-world Sandbox defaults, missing-value runtime fallbacks and LootLab Set to Default agree.

## 0.2.25: ordinary finds and jackpots

Twelve native pools now use explicit per-pool scales. Ordinary electronics shelves use 0.35; electronics crates and military electronics retain 1. GarageTools 0.3, CrateTools 0.45, ToolStoreTools/ToolStoreMisc/MechanicShelfTools 0.4 broaden themed finds. ElectricianTools uses 0.5, existing gun accessories/mechanic cabinets use 1. Global 6 and approved per-component defaults are unchanged. No container cap or second loot injection pass is used.

Generated circles become larger for containers containing five or more total components. Probability-circle size uses the unconditional chance of five or more components, including the chance of selecting a different loot pool. Tooltip and summary counts include hidden components. At distant zoom levels, circles aggregate nearby containers; zoom in to inspect individual candidates.

Haul probabilities use an exact convolution of independent per-item rolls with a 5+ tail, mixed over room/pool routing samples. The default model has about 77% one/two-item successful finds and 5.5% jackpots; total abundance increases with broader eligibility. These are model estimates before correlated capacity/story losses.

## 0.2.28: normalized tuning

Base weights now include approved global 4.5 and the prior component factors; all controls default to 1. Pool scales remain unchanged. New Sandbox export keys are ModuleLootRate and LootRate<Component>, preventing old saved multipliers from applying twice. Existing game loot controls start at the normalized baseline; generated loot is untouched. Old website scenarios/drafts convert their factors to retain effective weights. The owner scenario receives the requested 4.5-equivalent reset using a conditional revision update. Default estimates: 2,630 items, 83.17% one/two-item finds and 2.61% five-plus jackpots.

## 0.2.41 catalog refresh

Magazine, Splitter, Fragment, Enhanced Firing and Enhanced Detection now use the current game pools and weights. Both Enhanced modules match Large Expansion rarity and eligible pools. Existing account/scenario rates, seed and visibility are preserved; newly added modules start at multiplier 1. No global loot multiplier increase. The simulation still excludes physical container-capacity rejection.


## 0.2.42 catalog refresh

Piercing, Initial Blow, Execute and Impact are loot-only modules with the same 2.5 weight and eligible pools as Splitter/Fragment. The catalog contains 24 lootable modules and 170 entries across 16 pools. Existing per-item weights and global loot multipliers are unchanged; adding four independent candidates raises total expected component finds in those pools. Saved 0.2.41 scenarios keep existing rates and give new fields multiplier 1/visible.

## 0.2.43 catalog refresh

Conservation uses offensive-module weight 2.5, adding five entries to the same eligible pools (25 modules, 175 entries). Other weights and global controls are unchanged. Saved 0.2.42 tuning is retained; Conservation starts at multiplier 1 and visible.

Module colors are keyed by ID, with a deterministic fallback for future entries. Shapes indicate Control, Ballistics, Ammo/reload, Hit effects or Expansion in both legend and map; marker size retains existing haul/count semantics. Show all / Hide all stays beneath the sync banner while scrolling. These are display controls, not loot-rate changes.

## Scrolling layout

On desktop/tablet widths above 700px, the map and its controls stay below the sync banner while the component list scrolls. All summary metrics, town/pool tables and methodology are below the complete tuning area; Statistics jumps there directly. On phones the map stays in normal page flow above tuning so it does not cover the controls; statistics remain last. Sticky positioning uses CSS, with banner-height updates only on resize, not scroll-time model work.

## 0.2.47 defaults and packs

New defaults match the owner export, while the underlying multiplier scale and saved values are preserved. Module Packs supplement loose loot (container weight 1.0; independent 15% body chance) and contain three draws from all 29 entries. Current map/haul metrics model loose modules only, not pack drops or their contents. The corpse percentage is a separate game Sandbox setting, not Material loot or container weight.
