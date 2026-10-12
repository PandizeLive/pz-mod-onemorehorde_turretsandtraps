# C161 - 0.2.44 owner findings and next corrective/content plan

## C162 - selected rules and expanded Martyrdom audition (2026-10-12)

Owner proposes 1C: begin at 1.0x and add .1x-2.0x per module; selects 2A, 3B and 5B; rejects the first Martyrdom sounds as too extreme and requests more choices. No gameplay implementation this discussion.

- Power direction: additive `1 + sum(module surcharge)`, with each working copy adding .1-2.0 by rarity. This is mathematically the same overall curve as C161 1B, expressed more clearly. Replace the old 5-percent module-count factor, not an additional multiplier on top of it; retain the separate weapon factor. Examples: one cheapest 1.1x, one highest-cost 3x, sixteen cheapest 2.6x, sixteen highest-cost 33x. Direct multiplication of module costs is rejected. The upper end remains a substantial battery-life penalty, not equivalent to the previous gentle surcharge. Tooltips should show `Battery Drain: +0.1x` through `+2.0x` to communicate addition. Suggested seven-band increments are +.1, +.2, +.4, +.7, +1, +1.5, +2; interior values are a recommendation, not an owner-selected table.
- **2A selected:** one aim roll per shotgun shot; retain 60% ordinary / 80% precision maximum-range defaults for now.
- **3B selected:** Fragment at terminal projectile stop: impact after remaining penetration is exhausted, solid obstruction or range end on a miss, followed by the requested .25-second delay. Preserve one finite source lineage and full-range limit; Fragment never recursively generates Fragment.
- **5B selected:** native MetalworkingPunchDrop for delayed Tack landing. Do not reopen the sound choice.
- **4 remains open:** replace rejected 4A-4C in the picker with 4D BareHandsHit (recommended audition), 4E PlungerHit, 4F CorkPopWine, 4G AttackStomp, 4H ZombieRipClothing. These are registered installed-game events and each passed non-silent stopped native capture. BulletHitBody and CorkPopChampagne did not finish the isolated default-parameter capture and were excluded, not silently shipped with truncated previews. Existing suppressed M9 reference is retained; Tack selection is fixed in the picker. [Updated local sound picker](../../art/EFFECT_AUDIO.html).

Only the sound selection and any objection to the recommended interior rarity increments remain for discussion. Installed 0.2.44 is unchanged and still has the C161 initialization failure. R3C7/R1C3 acceptance stays open; no more play is requested before the corrective patch. Earlier choices below are historical; this section supersedes their unresolved state.


2026-10-12. Owner requests the changes below after testing 0.2.44. This records requested direction and the remaining material choices; no gameplay patch is installed by this discussion. Active branch inspected: `codex/performance-barbed-audit`, `f4bac32fc9c524c3a694a55c9f8829014f6c6b26`; origin fetched, only the existing development draft PR is open.

## Confirmed findings

- Captured `console.txt` identifies 0.2.44 SP and contains 1,355 identical `fieldOrder of non-table: null` exceptions in `TurretTackMarkers.update`, line 25. The snapshot starts mid-stack at frame 28400, so it cannot establish the initial failure time. Maximum summarized active-update gap in this slice is 39 ms; error spam and missing effects prevent a clean performance acceptance. Prior 676-ms findings are neither reproduced nor cleared by this slice.
- Client Tack files require server-only `TurretProc` at file load. Installed 42.21 `LuaManager.LoadDirBase()` loads shared/client paths, and `GlobalObject.require` searches only registered paths, returning null when missing. This strongly supports a load-order defect; preserve the inference distinction until ordered SP/client startup reproduces it. Defer registration/module acquisition until all required SP modules are initialized, rather than hiding nil with empty defaults. Audit both Tack contact and markers, Martyrdom, save restore and the test harness's preloaded server map. Earlier headless/isolated probes missed this startup boundary.
- Shotgun Piercing is explicitly gated off by `getProjectileCount() <= 1` in `TurretStats.resolve`. This is a deliberate old restriction to remove under the owner's new direction, not an absent native capability. The current adapter is an SP approximation, not native player shooting.
- `FirearmCombat.hit` rolls accuracy per pellet. With nine pellets and 60% per-pellet chance, chance of at least one hit is about 99.97% (against a sufficiently surviving target), despite lower damage on partial hits. The displayed 77% is base stat accuracy, not necessarily the actual distance-adjusted probability. Current maximum-range defaults are 60% ordinary / 80% precision, before Accuracy copies.
- Engagement slider starts at half the window width with fixed height/negative vertical offset; the row has insufficient association/padding. Long applicability text shares the status line and is clipped.
- Current power is `weaponFactor * (1 + .05 * workingModuleCount)` with all module weights 1. Sixteen copies give 1.8x before weapon damage/range. Expansion utility is not an extra ordinary-module surcharge.

## Requested changes

- Short battery tooltip: `0.27% / shot`, estimated shots left, and approximate in-game duration. Remove continuous-target/unlimited-ammo prose and the words "including reloads"; retain reloads in calculation. Convert using the world's native day length, cache on relevant state/hover, and label in-game time clearly. Rounding stays display-only.
- Martyrdom: wait .75 active seconds after eligible death, then burst/audio/20-radius AI noise together. Keep existing terminal damage, radius stacking and minor player-injury rule.
- Tack: wait .5 active seconds after eligible impact, then play landing audio and start the ten-active-second field. Retain same-zombie rearm after field expiry and no refresh/stacked contact. Capture impact position, not a later moving-target position.
- Fragment: remove hit requirement; .25 active-second delay at projectile endpoint, existing suppressed pistol sound (audition uses the shipped layered M9). Preserve five fragments, current damage stacking, finite Synergy lineage and precommit reservations. Endpoint choice below remains material.
- Piercing: all supported guns, including shotguns. Recommend one penetration chain per original shot (not per pellet), retaining the existing victim/damage constraints; native shotgun pellets remain the current adapter approximation. Potato head is not a gun and is not newly included by this instruction.
- Packed turret: 67% reduction to carried contents, empty base unchanged, using native container weight reduction where behavior supports it. Verify actual inventory encumbrance, pickup room checks, displayed weight, save/reload and restoration of full item weight after unloading. This interpretation follows "with contents"; do not silently reduce loose base or deployed storage limits.
- Rewrite all module item/hover descriptions as Feature / Stackable / Battery Drain / Rarity. Keep one short readable feature line; omit recovery/internal processing/cap boilerplate. Use the same loaded rarity/color resolver for Manage and tooltips. Proposed seven labels: Abundant, Common, Uncommon, Scarce, Rare, Very Rare, Ultra Rare. Horde Night's frequency labels are contextual, not an existing seven-tier module rarity API; this stays standalone.
- Preserve inset panels (reaffirmed through the layout picker); measure label width and pad one shared engagement row. Wrap distinct status/applicability warnings on a separate line. Removing shotgun restriction must not merely hide the warning.

## Choices to discuss

**1 - rarity power scope**

- **1A recommended:** rarity 1.1-3.0x weights the existing 5% module surcharge. Sixteen equally common/rare modules produce 1.88x / 3.4x total module factor. Tooltip must distinguish this per-module drain weight from total turret consumption; retain actual total cost in battery hover.
- **1B:** literal whole-base additive cost: `1 + sum(rarityMultiplier - 1)`. Sixteen common/rare modules produce 2.6x / 33x. One 3x module produces 3x total, two produce 5x, not 9x. Never multiply every copy's factor together (3^16 exceeds 43 million).
- Both follow loaded rarity and cache the result on configuration changes. Changing relative loot weights will therefore change power balance. Crafted/disabled entries require a stable fallback (recommend cheapest for crafted; canonical positive-weight rarity when loot is disabled), not zero drain or division by zero. Existing custom Sandbox values need explicit preservation/migration during implementation.

**2 - accuracy**

- **2A recommended:** one distance-based aiming roll per shotgun shot, preserving current 60%/80% far-end defaults initially; pellet distribution follows a successful aim roll. This fixes misleading almost-guaranteed hits without simultaneously rebasing every weapon.
- **2B:** same shot-level roll, plus reduce ordinary/precision maximum-range defaults to 40%/60%. Accuracy modules remain useful. Saved Sandbox values must not silently retain misleading labels or reset unrelated tuning.

**3 - Fragment endpoint**

- **3A (matches owner's wording):** full unobstructed projectile range, stopped by solid geometry; passing a zombie does not move the burst back to that victim. This also fires on misses, but close targets can be far from the burst. Piercing spends the same original range budget.
- **3B recommended for close-range Synergy:** burst at the projectile's terminal stop (first hit without remaining penetration, solid obstruction, otherwise range end). Misses still fragment, and successful hits place fragments near enemies. This differs from "always at full range" and requires the owner's selection.

**4/5 - sounds**

[Local sound picker](../../art/EFFECT_AUDIO.html): 4A BloodSplatter (recommended), 4B AerosolBombExplode, 4C PipeBombExplode; 5A BoxOfShellsPlaceAll (recommended), 5B MetalworkingPunchDrop, 5C DropSoilFromGravelBag. Current installed native events rendered through the existing FMOD audition helper; no gameplay sound chosen merely by creating the page. Existing suppressed M9 reference is included. Preview clipping prevention is not final in-game gain or AI hearing radius.

## Implementation/verification gate

Use a single ordered SP client-start test as well as native API probes. Verify both independent package modes, delayed jobs across save/reload/pause, cancelled shots/reservations and bounded worst-case shotgun/Synergy/Fragment work. Delays begin once at the specified source event; no duplicate activation or backlog burst. UI should be checked at the owner's font size, including translated text widths. Keep R3C7 and R1C3 acceptance open; no additional owner play on the broken build is requested. After these choices, recommend High reasoning for implementation; use Fast if the expected run exceeds 25 minutes.
