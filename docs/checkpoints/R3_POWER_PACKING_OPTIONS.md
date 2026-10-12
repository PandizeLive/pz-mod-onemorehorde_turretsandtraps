# C166 - Pickup weight, power endurance and rarity discussion

2026-10-12. Discussion only, not patch approval. Inspected `codex/performance-barbed-audit` at `40881f4259a529b38597fa41692bc9d92342f9c4`; origin fetched with no incoming changes. Owner reports battery drain effects work but a full late-game turret shows about 1.5 in-game minutes. Requests safe packing alternatives, at least six in-game hours, an efficiency module and more enjoyable rarity names. Prior inset-panel selection remains unchanged.

## Verified findings

- Installed 0.2.45 console reports 4.079648422352103 percent per shot, 212.5 damage, 30 range, 250-ms cooldown, 2700-ms reload and 16 modules. Latest save `Sandbox/2026-10-11_13-56-01/map_sand.bin` stores Battery use 0.1, ModulePowerBonus 5, generator fuel 0.001 and DayLength 4. No save was edited. Native installed 42.21 `SandboxOptions.getDayLengthMinutes()` maps 4 to 90 real minutes, not the historical two-hour assumption.
- Shipped base Battery use is 0.005 percent per firing action; no idle draw. Saved 0.1 is twenty times higher. Current formula: base * max(1, sqrt(base weapon damage / 80 * clamped base range / 15)) * (1 + sum(module rarity surcharges) * ModulePowerBonus / 5). Splitter/Fragment do not separately charge power. Rarity surcharges are .1/.2/.4/.7/1/1.5/2; +2 is per module, not a total cap. Sixteen maximum surcharges yield 33x. Display rounding does not affect consumption.
- Weapon factor in this sample is 2.3048861143 and inferred module factor 17.7. At saved settings a full battery affords 24 shots, or 1.53 in-game minutes at four shots/sec without reloads. Default base gives 490 shots / 32.6 minutes before reload time. This agrees with the reported short estimate; a six-hour target requires a balance change even after correcting saved settings.
- Console also confirms repeated `__sub not defined for operands` in `TurretMenu.lua:24`, the new rarity-color inventory tooltip overlay. It reads native tooltip padding fields directly; ordinary Lua field exposure must be corrected/proven. This is a failed client check, not cleared by the owner's positive battery report. Track in TEST_v0.2.45.md; do not claim all acceptance passed.

## 1 - Safe pickup weight choices

Existing exact-item container pickup preserves item state. Ordinary container contents count at full unequipped weight; the tested opaque snapshot buffer cannot be restored through ordinary Lua. This proves that route failed, not that every possible native route is impossible.

- **1A recommended for simplicity:** native equipped carrying case/turret. Apply contents reduction while equipped in a supported hand/back slot; real contained items remain intact. Ordinary inventory would remain full weight, and native equipped base-weight behavior must be disclosed/verified. This changes the original ordinary-inventory requirement and is not approved by discussion.
- **1B:** reduce only the portable turret base's own weight; keep contents full weight. Simple and safe for arbitrary modded guns, but saves little in an ammo-heavy loadout and does not meet the approved contents reduction.
- **1C:** retain exact auto-packed behavior as a separate feasibility task. Prove an accessible native lossless serialization/restore API or discuss a maintained Java bridge dependency before implementation. Do not promise feasibility or add that dependency implicitly. Required evidence: full gun/attachments/chamber/magazine/condition/mod-data/battery/nested-item roundtrip, save/restart, cancelled pickup/placement, failures without item loss or duplication, and no repeated inventory scan. No handwritten partial reconstruction, hidden world vault or global weight mutation.

## 2 - Battery balance choices

All estimates below use this sample's weapon, 90-real-minute day, four shots/sec, full battery, and omit reload pauses for a conservative continuous-fire comparison. Idle costs zero. Reloads/target gaps extend endurance. Changes are proposals and would require updating the selected world's saved setting, not just new-world defaults.

| Choice | Proposed base percent/shot | Per-copy rarity surcharges | Sample endurance | Same weapon with sixteen highest surcharges |
| --- | --- | --- | --- | --- |
| 2A | .0004 | Keep .1 through 2 | 6.81 in-game hours | 3.65 hours |
| 2B recommended | .0015 | .01/.02/.04/.07/.1/.15/.2 | 12.03 hours | 7.65 hours |
| 2C | Calibrated base plus a six-hour minimum-endurance limit | Retain relative costs below the limit | At least six hours | At least six hours |

2A is the smallest change but leaves a steep rare-module penalty. 2B keeps rarity meaningful with a much gentler slope and room for the new efficiency module; these numbers are starting reference tuning, not a guarantee for every weapon, cadence or day length. 2C requires a cached per-shot ceiling derived from day length and fastest configured cadence; extreme builds then stop paying extra power at the limit, weakening power balance. Prefer 2B unless a universal six-hour floor is explicitly required. Generator fuel currently shares module/weapon factors; recommend applying gentler surcharge tiers consistently but tuning battery base separately and not silently changing saved generator fuel.

## 3 - Efficiency module choices

Requested concept, exact balance/acquisition unapproved. Suggested name: **Power Efficiency Module**, keeping it distinct from Conservation's ammo effect; alternatives Power Saver or Regulator. Recommend loot-only Rare, stackable for A/B, no own power surcharge as an explicit exception so it cannot consume its own benefit. Resolve rarity via the chosen naming table and update LootLab on implementation.

- **3A recommended:** final battery consumption divided by `1 + .5 * copies`. One/two/four copies give 33.3/50/66.7 percent less drain and 1.5/2/3x life versus the same other installed modules. Never reaches free firing; uses valuable slots. Replacing an existing module also removes that module's surcharge, so actual loadout improvement can be larger.
- **3B:** divide by `1 + .25 * copies`; one/two/four copies give 20/33.3/50 percent less drain and 1.25/1.5/2x life. Milder slot tradeoff.
- **3C:** one non-stackable module halves battery drain. Simplest fixed benefit, less build flexibility.

Recommend battery-only initially, not generator efficiency without an explicit scope choice. Cache on equipment/settings changes, no extra tick loop. The module extends an already usable baseline; it must not be required to repair basic endurance.

## 4 - Seven-tier rarity naming choices

Keep current seven colors/order; names indicate relative loot rarity, not a new randomized quality/stat system. Relative loot edits still change bands and linked power; avoid implying otherwise.

- **4A recommended:** Abundant / Common / Uncommon / Rare / Epic / Legendary / Mythic.
- **4B industrial:** Abundant / Common / Uncommon / Rare / Superior / Masterwork / Legendary.
- **4C scavenger:** Abundant / Common / Scarce / Rare / Exotic / Legendary / Relic.

Decision needed on 1/2/3/4. No gameplay version bump, save edits, package changes or installation in this discussion. The tooltip error is recorded for the next corrective patch. Recommend High for the eventual combined implementation and Fast if the packing investigation expands beyond 25 minutes.

## C167 - Selected directions and revised power evaluation (2026-10-12)

Owner selects 1C, 3B with Regulator name, 4A and module item weight .2; proposes revising 2B to base .0008% and per-copy additions .1-1.0, asking "how's that?" This supersedes the open choices above for 1/3/4; power remains a discussion proposal. Inspected ef89fe9 and fetched origin before recording.

- **Packing:** retain auto-pack on Pick Up, normal summary, automatic unpack through existing placement, 67% contents reduction and unchanged empty-base weight. Prove safe native roundtrip first; no implicit Java dependency approval or equipped-only substitution.
- **Item weight:** all current OMHTTModule items are .3, including Makeshift/expansion variants. Change them to .2 in the next patch, including the new Regulator. This is physical item weight, not loot selection weight. Sixteen ordinary modules become 3.2 instead of 4.8 total; expansion also saves .1 separately. No base/head/trap weight change.
- **Regulator:** selected 3B: final battery consumption divided by `1 + .25 * copies`, giving 1/2/4 copies 1.25/1.5/2x endurance (20/33.3/50% less drain). No hard stacking cap beyond module slots. Recommended supporting defaults remain Rare, loot-only, no own power surcharge and battery-only; update LootLab and existing module description/UI paths on implementation. Replacing a powered module removes its surcharge too, so real slot swaps may save more. Do not mislabel +25% endurance as -25% drain.
- **Rarity names:** Abundant / Common / Uncommon / Rare / Epic / Legendary / Mythic, preserving seven existing colors and rarity semantics, not randomized quality stats.
- **Power proposal:** .0008% base and additions +.1 to +1.0. Suggested intermediate table (not separately selected): .1/.15/.25/.4/.6/.8/1.0. One maximum-cost module gives 2x base module factor; sixteen give 17x, not a 1x total cap. Current saved .1 remains until deliberately updated under implementation authorization.

Calculated at sample weapon factor sqrt(212.5/80*30/15)=2.304886, four shots/sec, 90-minute day, full battery, no reload pauses: sixteen +.1 modules give 23.17 hours; average +.5 gives 6.69 hours; sixteen +1 give 3.54 hours. These are cost scenarios, not assertions that sixteen singleton modules form a valid loadout. Using only the logged 16-copy old total surcharge 16.7 and the proposed seven-band mapping, feasible mapped totals range 8.8-9.8; resulting reference duration is 5.58-6.15 hours before reloads. Exact per-module composition was not logged, so no exact current-loadout number is claimed.

**Remaining choice:** 2A retain the owner's .0008 proposal and accept that expensive builds can fall below six hours; Regulator extends life at a slot cost. 2B recommended if the prior six-hour target remains important: keep the .1-1.0 additions but use .00045 base, yielding approximately 6.3 hours at sixteen highest-cost additions on this reference weapon. Neither is a universal minimum across different weapons, fire rates and day lengths. Existing no-idle-cost behavior and separate weapon factor remain. No patch/version/save changes in this discussion. The known inventory rarity tooltip failure remains part of the next corrective scope.

## C168 - Approved implementation

**C168 / 0.2.46 installed and verified; owner test pending.** Owner approved revised 2B: .00045% base battery use, additive rarity surcharges .1/.15/.25/.4/.6/.8/1.0, plus C167 packing/weight/Regulator/names. Regulator provides +25% endurance per copy, battery-only, no self-surcharge; all module item weights are .2. Seven names end in Epic/Legendary/Mythic. Inventory rarity tooltip uses exposed UI methods. [Patch](../PATCH_v0.2.46.md) | [focused test](../TEST_v0.2.46.md).

16,046 Kahlua assertions, 760 native translations, 113 compiled files, native write/read, three independent package selections and 51 Firearms weapons pass. LootLab 0.2.46 is deployed with 29 modules/208 entries; 77 API/page tests and desktop/mobile browser checks pass. Owner/rendered gameplay acceptance remains pending.

**Packing remains unfinished, despite approved implementation scope.** The ordinary-Lua native buffer route and generic object loaders still require unavailable buffer positioning/version decoding; no safe arbitrary-item restore path has been proven. Existing exact-item pickup/placement retains full contents weight. No Java dependency, partial item reconstruction or equipped-only substitution ships. Further progress requires a supported native bridge or a separately discussed dependency, not another balance choice.
