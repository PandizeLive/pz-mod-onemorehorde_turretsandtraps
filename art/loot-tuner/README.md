# Knox Country Loot Lab

Open `index.html` directly in a desktop browser. Keep `data.js`, `model.js`, `app.js`, `style.css` and `provenance.json` alongside it. No server, account or internet connection is required.

This is a personal, offline balancing tool for **new-world estimates**. It does not change the game, install a gameplay patch, or predict a save's exact future drops.

## Use

1. Choose a component, or All components.
2. Change the T&T global multiplier and individual component multipliers. Material loot defaults to Apocalypse's 0.60; use your intended world settings.
3. Click **Refresh spawns** for a new seed. Generated spawns shows one sample world, with a distinct color for each component. Switch to Container chances to inspect possible containers.
4. Toggle individual components, or Show all / Hide all. Visibility never rerolls loot or changes rates. Select a town, zoom and hover dots for coordinates, floor, chances and generated quantities.
5. Compare countywide and nearest-town estimates. Save/load scenario JSON to compare settings; export the Sandbox excerpt when satisfied. Apply settings yourself only after reviewing the excerpt.

The baseline is **T&T 0.2.23** and **Project Zomboid 42.21.0**, including Critical/Accuracy and the reduced Suppression loot weight. The owner approved this gameplay patch and site update together. Gameplay installation is tracked separately in `docs/RELEASE.md`.

## What the numbers mean

The map contains 11,713 eligible **container-sprite candidates**, extracted from native lot headers/packs, with 45 eligible procedural routing rules. Real map geometry and town labels come from the installed map. All floors are included; a dot is a possible container, not a promised module.

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

Pinch to zoom, drag with one finger, or use the 44px on-map zoom controls. Tap a nearby marker when zoomed in for container details. The Tune loot / Back to map links avoid scrolling through the report on a phone. Legend checkboxes, dots, names and rate fields use fixed columns. A separate colored marker moves on a fixed logarithmic 0–1,000+ expected-items scale; it includes the final scenario multipliers and retention. It reflects estimated abundance, not random sample luck.

`tools/loot_site/test_map_controls.cjs` checks the actual gesture controller for pinch anchoring, pinch-to-pan continuity, cancellation, taps and limits. Physical iOS/Android interaction remains a user acceptance check.

## Saved settings

The hosted admin LootLab autosaves rates, seed, component visibility, estimate selection and overlay to the signed-in admin account. PC and phone must use the same login. Set to Default restores the T&T 0.2.23 scenario baseline (including Material 0.60, rolls 1 and retention 100%) and saves that reset. Map pan/zoom and town jumps are navigation, not saved tuning settings.

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
