# Module pack and owner loot weights

**Current: C177 is implemented in 0.2.47; see the final contract below. Earlier sections preserve decision history.**

2026-10-12. Owner requests recording a new card-pack-like item for the next combined game patch, alongside adaptive battery hours/minutes, and says one more support requirement is coming. Concept and use of the supplied weights are confirmed; implementation is held for the remaining pack rules. C174 now identifies the additional support topic as a separate proposed Viewpoint compatibility workstream. No source/package/default/settings or hosted account changes in this planning turn. Inspected 5300ae965abd18774e0d017e9d69a29f0606020d; origin fetched without incoming changes.

## Confirmed direction

- New openable item rewards modules using the module weight catalog.
- Optional CS2-style rolling reveal, enabled by default.
- Reveal cards follow Manage styling: module icon, name/text, rarity-colored text and dim colored background. Reuse existing assets/style; no new final artwork is authorized.
- Apply the owner-provided effective module weights below in the planned update; use the same catalog for pack selection and existing module weighting rather than inventing a separate rarity table.
- Combine with the battery duration display correction: appropriate in-game minutes/hours without a power-balance change.
- C174 identifies the additional support topic as Project Viewpoint, recommended as a separate optional compatibility prototype; no implementation approval yet. Remaining pack rules still require discussion. C171's tooltip-formatting error and repeated capacity warnings remain open and must not disappear from the corrective queue.

## Recommended implementation contract, not yet settled

Treat the roll as presentation of one committed reward outcome, not repeated live RNG. Disabling/skipping/closing the animation must not improve odds or lose/duplicate the reward; persist any state necessary to safely finish across save/reload. Allocate/update the reel only while it is visible, with bounded visible cards and cached icon/text/colors. No world-wide tick loop for unopened packs. Native inventory transaction and UI feasibility must be verified before shipping.

For a single reward draw, use normalized relative weights, weight / sum(enabled eligible weights). Existing container loot uses independent per-item chances, so the pack cannot literally reuse its container-roll algorithm. Reward count, acquisition/drop rate/recipe, whether packs supplement or replace loose-module drops, physical weight, final name, opening time and animation controls/duration remain to settle. All 29 exported entries include expansion kits; Makeshift modules are not in the supplied loot catalog, so their inclusion is not implicitly approved. Recommend the exported catalog as the initial eligibility set.

Rarity labels/colors and per-module battery surcharges are already linked to loaded loot weights; adopting these weights can change those bands without changing the base battery drain. Preserve that existing rule unless the owner revises it. The global loot factor below is separate world tuning and cancels out of a normalized pack draw; do not multiply pack weights by Material loot, rolls or retention.

## Validated owner export

Source: uploaded omh-loot-scenario.json, baseline T&T 0.2.46, 29 known modules. SHA-256: fbe83b0062914bf2bef17292a5ab34f841c07dc9ae3b3c406db33509f0c10927. The export still stores multipliers internally; effective weights below are baseline weight times multiplier, not the raw items values. Original JSON is retained below for provenance.

When incorporating these as new baseline/default weights, apply them once. Rebase old saved multipliers by oldWeight/newWeight as needed to retain their effective choices; do not multiply the new base by the same imported factor a second time. Validate catalog, Sandbox export and saved/account scenario migration together. Existing generated loot must not be rerolled. Global=1.011111111111111; Material=0.6; rolls=1; retention=1. Capture these separately; this turn does not authorize overwriting existing game saves or account settings.

| Module | Catalog ID | Effective loot weight | Exported multiplier |
| --- | --- | ---: | ---: |
| Firing | Firing | 15 | 0.5 |
| Detection | MotionDetection | 15 | 0.5 |
| Filter | Filter | 10 | 2 |
| 360 | Detection360 | 8 | 3.2 |
| Suppression | Suppression | 4 | 1.6 |
| Rapid-Fire | RapidFire | 6 | 1.2 |
| Reload | Reload | 6 | 1.2 |
| Velocity | Velocity | 5 | 1 |
| Range | Range | 7 | 1.4 |
| Small Expansion Kit | CapacitySmall | 7.5 | 1 |
| Medium Expansion Kit | Capacity | 2.5 | 1 |
| Large Expansion Kit | CapacityLarge | 1.5 | 1 |
| Autoloader | Autoloader | 1.5 | 1 |
| Critical | Critical | 4 | 1.6 |
| Accuracy | Accuracy | 7 | 1.4 |
| Magazine | Magazine | 6 | 1.2 |
| Splitter | Splitter | 3 | 1.2 |
| Fragment | Fragment | 3 | 1.2 |
| Enhanced Firing | FiringEnhanced | 1.5 | 1 |
| Enhanced Detection | MotionDetectionEnhanced | 1.5 | 1 |
| Piercing | Piercing | 4 | 1.6 |
| Initial Blow | InitialBlow | 4 | 1.6 |
| Execute | Execute | 2.5 | 1 |
| Impact | Impact | 3 | 1.2 |
| Conservation | Conservation | 2 | 0.8 |
| Synergy | Synergy | 1 | 1 |
| Martyrdom | Martyrdom | 2 | 1.3333333333333333 |
| Tack | Tack | 2 | 1.3333333333333333 |
| Regulator | Regulator | 6 | 1.0909090909090908 |

### Original scenario

```json
{
  "version": 1,
  "baseline": "T&T 0.2.46",
  "seed": 2841424833,
  "global": 1.011111111111111,
  "material": 0.6,
  "rolls": 1,
  "retention": 1,
  "selected": "all",
  "overlay": "spawns",
  "visible": {
    "Firing": true,
    "MotionDetection": true,
    "Filter": true,
    "Detection360": true,
    "Suppression": true,
    "RapidFire": true,
    "Reload": true,
    "Velocity": true,
    "Range": true,
    "CapacitySmall": true,
    "Capacity": true,
    "CapacityLarge": true,
    "Autoloader": true,
    "Critical": true,
    "Accuracy": true,
    "Magazine": true,
    "Splitter": true,
    "Fragment": true,
    "FiringEnhanced": true,
    "MotionDetectionEnhanced": true,
    "Piercing": true,
    "InitialBlow": true,
    "Execute": true,
    "Impact": true,
    "Conservation": true,
    "Synergy": true,
    "Martyrdom": true,
    "Tack": true,
    "Regulator": true
  },
  "items": {
    "Firing": 0.5,
    "MotionDetection": 0.5,
    "Filter": 2,
    "Detection360": 3.2,
    "Suppression": 1.6,
    "RapidFire": 1.2,
    "Reload": 1.2,
    "Velocity": 1,
    "Range": 1.4,
    "CapacitySmall": 1,
    "Capacity": 1,
    "CapacityLarge": 1,
    "Autoloader": 1,
    "Critical": 1.6,
    "Accuracy": 1.4,
    "Magazine": 1.2,
    "Splitter": 1.2,
    "Fragment": 1.2,
    "FiringEnhanced": 1,
    "MotionDetectionEnhanced": 1,
    "Piercing": 1.6,
    "InitialBlow": 1.6,
    "Execute": 1,
    "Impact": 1.2,
    "Conservation": 0.8,
    "Synergy": 1,
    "Martyrdom": 1.3333333333333333,
    "Tack": 1.3333333333333333,
    "Regulator": 1.0909090909090908
  }
}
```

Historical C173 gate superseded: Viewpoint was identified in C174; see the latest C176 selections below.


## C175 approval and remaining choices

2026-10-12. Owner: "Understood, approved for the hour patch and module pack", followed by "Also the new weights" and permission to present questions/options first. This approves the feature scope and supplied weight adoption, not an unspecified loot-economy design. Viewpoint stays separate. No game code/package/settings change in this discussion. Base inspected: 2722432792b6cf264205eade531fe9e3d5c027ad; origin fetched, no incoming dev commits.

Choices presented (not selected):

- 1A recommended: one reward per pack. 1B: three independent rewards, duplicates possible. One is easier to balance and keeps opening brief.
- 2A recommended: packs are rare additional finds alongside loose modules, relative weight 1.0 in existing module-eligible pools. This increases total loot; weight is not a percentage. 2B: replace loose-module loot with packs, tuned for comparable overall module frequency; this changes location-specific reward mixes and needs LootLab validation. Do not silently remove loose modules or add pack loot before this choice.
- 3A recommended: all 29 entries from the export, including expansion kits. 3B: the 26 modules only; expansion kits stay as loose loot. Makeshift craftable modules remain outside the supplied catalog.

Proposed routine defaults: Module Pack name, 0.2 item weight, loot-only/no new crafting recipe, two-second opening action and four-second optional default-on reveal with Skip. Reward committed once before the visual reveal; skip/close must not reroll or duplicate it. Existing Manage icons/rarity text and dim backgrounds, bounded visible cards, UI work only while open. Defaults remain proposals until owner response; native transaction/persistence behavior needs proof.

All 29 new effective weights apply to the module catalog and selected pack eligibility, with existing tuning preservation and no double application as described above. Battery formatting changes units at 60 in-game minutes and leaves drain/reload-inclusive estimation arithmetic unchanged. C171 tooltip/capacity findings remain explicitly queued, not claimed fixed. Medium effort suits the display correction; recommend Fast for the full pack implementation if estimated over 25 minutes.


## C176 selected pack rules and zombie-body loot

2026-10-12. Owner selects 1B, 2A and 3A, adding: "We'll also have them appear on zombie bodies more often." Three independent weighted rewards per pack, duplicates allowed; packs supplement loose modules at relative weight 1.0 in existing module-eligible container pools; all 29 exported entries eligible, including expansion kits. Keep the C175 routine defaults unless subsequently revised; no need to ask the same questions again. Interpret the zombie-body request as packs, not a global increase to unrelated corpse loot or individual modules.

Current ModuleLoot.lua only injects procedural container pools; it has no module/pack zombie-body route. Installed vanilla Distributions.lua has outfit-specific tables that replace inventorymale/inventoryfemale, so adding to only the generic table would miss many zombies. A complete corpse route and once-only reward accounting require native verification during implementation. Container weight 1.0 is not a 1% corpse drop rate; do not equate those values.

Only new material choice: independent pack chance per eligible zombie body, including turret kills. Recommend 1% (1B); offer 0.5% (1A) and 2% (1C). For 1,000 eligible bodies these yield expected 5/10/20 packs and 15/30/60 rewards respectively, before any failed item placement; actual samples vary. These are design probabilities, not measured native loot rates. Proposed separate Sandbox percentage, zero disables, at most one pack per body; ordinary loot unchanged. No rate selected yet. This is the final known balance gate; do not request another generic patch approval after selection. Implementation must verify corpse inventory insertion timing and prevent repeat rolls on reload/event duplication without per-tick corpse scanning.

Base inspected 1f143eb59e66da70cf0ed3c9b12650c6f4797fe4; origin fetched, no incoming dev commits. No source/package/install/version or test-result changes. C171 corrective issues and C170 cancellation remain unchanged; Viewpoint remains separate. C108/C119 mirror applies.

## C177 15 percent body rate and implementation

2026-10-12. Owner overrides the proposed 1% with: "should be way more common, like 15%". The C175/C176 approvals remain in force; no further generic approval gate. This section supersedes all historical unresolved pack choices above.

Implemented in 0.2.47: Module Pack (Base.OMHTTModulePack), weight .2, loot-only, two-second interruptible opening, three independent weighted rewards with duplicates. All 29 catalog entries, including expansion kits, are eligible; Makeshift crafted variants are excluded. Container weight 1.0 supplements existing loose modules in the same sixteen eligible pools. New Sandbox corpse chance defaults to 15%, range 0-100, zero disables. At most one pack per newly killed body, including turret kills; ordinary corpse loot is unchanged. Expected 150 packs / 450 rewards per 1,000 deaths at default, with natural sampling variation. This is intentionally generous, not a rare corpse reward.

Installed 42.21 native IsoZombie.onKilled calls DoZombieInventory before OnZombieDead. The event adds to that inventory and records a once-only marker; no corpse scans or per-tick loot work. Disabled Turrets/feature/global module loot and multiplayer gates remain closed. The selected outcomes are stored on the exact pack before granting; all three real items are inserted before consuming it. Failed grants keep the pack and its draw; repeated completion is blocked. Reward grant precedes the optional default-on four-second reveal, so Skip/Close cannot reroll or lose rewards. Reveal reuses Manage icons/rarity colors and draws bounded visible cards only while its panel is open.

The supplied 29 effective weights become defaults by changing the existing per-item default multipliers, preserving the old raw weight scale and saved custom values. Global default remains 1; the export's saved global 1.0110954207 is not made a universal baseline. Pack odds use the current per-item effective weights. Zero-weight entries are excluded. Rarity colors/names and additive power surcharges therefore follow the new loaded weights (for example, default Regulator becomes Uncommon at weight 6). Existing worlds/accounts keep their explicit tuning; use new/reset defaults or import the export to adopt these values there. No save/account database is rewritten.

Battery duration uses minutes below 60 and hours from 60, with one decimal; cost, reload-aware duration calculation and .00045 base setting are unchanged. The separate C171 tooltip fix draws the four translated module lines directly instead of sending percentage text back through the native translation-key parser. Capacity warning cleanup remains open; Viewpoint remains separate and packed-turret reduction stays abandoned.

LootLab baseline 0.2.47 is deployed from a verified isolated snapshot; live bundle and Access/public route checks pass. Map/statistics explicitly remain loose-module estimates and exclude packs. Native, Kahlua, browser and deployment evidence are recorded in [the version test](../TEST_v0.2.47.md); rendered gameplay is pending. Development mirror required under C108/C119; no Workshop upload.


## C180 - Approved audit correction

Owner approves solving the C178/C179 issues. 0.2.47.1 implements the corrections without changing the acquisition/reward contract. Empty eligibility is refreshed with loaded loot settings (`ModuleLoot.apply`) and checked without scanning module weights on each death; opening refreshes the reusable weighted pool if loaded values change. Existing packs remain available after weights are restored. Reveal metadata is prepared per opening from native script items, preserving current translated names and rarity colors; only drawing occurs per frame. Large fonts/short viewports scroll the complete reward rows while controls remain fixed. [Patch](../PATCH_v0.2.47.1.md) and [combined test](../TEST_v0.2.47.1.md) supersede the earlier pending-correction status.
