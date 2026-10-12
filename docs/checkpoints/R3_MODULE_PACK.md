# C173 - Module pack and owner loot weights

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

**Decision needed:** the owner has another support requirement to add; continue discussion before patching.


## C175 approval and remaining choices

2026-10-12. Owner: "Understood, approved for the hour patch and module pack", followed by "Also the new weights" and permission to present questions/options first. This approves the feature scope and supplied weight adoption, not an unspecified loot-economy design. Viewpoint stays separate. No game code/package/settings change in this discussion. Base inspected: 2722432792b6cf264205eade531fe9e3d5c027ad; origin fetched, no incoming dev commits.

Choices presented (not selected):

- 1A recommended: one reward per pack. 1B: three independent rewards, duplicates possible. One is easier to balance and keeps opening brief.
- 2A recommended: packs are rare additional finds alongside loose modules, relative weight 1.0 in existing module-eligible pools. This increases total loot; weight is not a percentage. 2B: replace loose-module loot with packs, tuned for comparable overall module frequency; this changes location-specific reward mixes and needs LootLab validation. Do not silently remove loose modules or add pack loot before this choice.
- 3A recommended: all 29 entries from the export, including expansion kits. 3B: the 26 modules only; expansion kits stay as loose loot. Makeshift craftable modules remain outside the supplied catalog.

Proposed routine defaults: Module Pack name, 0.2 item weight, loot-only/no new crafting recipe, two-second opening action and four-second optional default-on reveal with Skip. Reward committed once before the visual reveal; skip/close must not reroll or duplicate it. Existing Manage icons/rarity text and dim backgrounds, bounded visible cards, UI work only while open. Defaults remain proposals until owner response; native transaction/persistence behavior needs proof.

All 29 new effective weights apply to the module catalog and selected pack eligibility, with existing tuning preservation and no double application as described above. Battery formatting changes units at 60 in-game minutes and leaves drain/reload-inclusive estimation arithmetic unchanged. C171 tooltip/capacity findings remain explicitly queued, not claimed fixed. Medium effort suits the display correction; recommend Fast for the full pack implementation if estimated over 25 minutes.
