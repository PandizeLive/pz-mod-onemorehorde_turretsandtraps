# C349 — Saved M4 battery baseline and Siphon balance

**C355 / Implementation approved (2026-10-20).** Owner approved the settled battery/Siphon and mechanical Poke/Building scope. Implemented in [0.2.58](PATCH_v0.2.58.md); 25,906 assertions, native save/reload and independent packages pass; installed from immutable test/v0.2.58 with verified rollback backups. Rendered and connected-player acceptance remains pending. Lever/emitter content remains separate. No new loot weights or unselected recipes.

**C355 / Implementation approved (2026-10-20).** Owner approved the settled battery/Siphon and mechanical Poke/Building scope. Implemented in [0.2.58](PATCH_v0.2.58.md); 25,906 assertions, native save/reload and independent packages pass; installed from immutable test/v0.2.58 with verified rollback backups. Rendered and connected-player acceptance remains pending. Lever/emitter content remains separate. No new loot weights or unselected recipes.

## C354 — Owner replaces the tier surcharge schedule

Owner supplies seven percentages in the order of the preceding Abundant-to-Mythic table. Selected direct additions are **Abundant +10%, Common +15%, Uncommon +25%, Rare +50%, Epic +75%, Legendary +100%, Mythic +150%**. These replace C353's selected tier values; they are not an extra multiplier on top of that schedule. Retain additive stacking, the current ModulePowerBonus scaling, zero direct surcharge for Expansion Kits and Regulator, and the existing Regulator reduction formula. Preserve actual loot weights, rarity anchors and assignments.

Head adjustments remain firearms x1.5, Scrapshot x1.25, Ballista unchanged. Siphon remains 45% proc / 2x first refund / +1x per additional module, with the same source and Synergy restrictions. Head consumption labels remain selected.

Reference-loadout consequence: after removing Siphon/Regulator, four Mythic, four Legendary, two Epic, two Rare, one Common and one Uncommon module give 1 + 4*1.5 + 4*1 + 2*.75 + 2*.5 + .15 + .25 = **13.9x** head base cost, replacing the earlier proposed 11.44x (current installed 10.6x). With the retained head factors, the earlier model estimates become M9 ~98, M4 ~31, Ballista ~23 and Scrapshot ~52 real unpaused minutes. These supersede older proposed endurance figures and remain calculations, not gameplay tests.

No further confirmation needed for this explicit numerical replacement. Selected for pending patch; no gameplay, version, save, installation or Workshop change this turn.

## C353 — Gentler values selected; per-module surcharge audit

Owner selects C352 **1A** and asks for battery multipliers for each module. Exact pending tuning is now settled: firearms x1.5, Scrapshot x1.25, Ballista head cost unchanged; Epic/Legendary/Mythic surcharges rise by 10% relative. This selects balance, not implementation of unresolved Lever/emitter recipes. Installed 0.2.57.2 is unchanged.

The direct module component is additive: `1 + sum(surcharges) * ModulePowerBonus / 5`. The latest owner session has ModulePowerBonus=5. Add the surcharge once per working, head-supported physical module; alias roles do not double-charge. The table uses the latest logged save settings and current LootDefinitions weights with TurretRarity's geometric anchor boundaries, not a blanket claim about every save or future LootLab assignment.

| Rarity | Current addition to head base | Selected addition | Modules at the saved settings |
| --- | ---: | ---: | --- |
| Abundant | +10% | +10% | Accuracy, Reload |
| Common | +15% | +15% | Filter, Magazine, Range, Rapid-Fire |
| Uncommon | +25% | +25% | Firing, Detection, Lure |
| Rare | +40% | +40% | Critical, 360, Piercing, Suppression, Velocity |
| Epic | +60% | +66% | Conservation, Impact, Initial Blow, Splitter |
| Legendary | +80% | +88% | Execute, Fragment, Martyrdom, Siphon, Tack |
| Mythic | +100% | +110% | Autoloader, Enhanced Firing, Enhanced Detection, Grid, Synergy, Void |

Example after the selected patch: one Legendary plus one Mythic means `1 + .88 + 1.10 = 2.98x` base head cost. Do not multiply 1.88 by 2.10. Each additional installed copy contributes its surcharge again where stacking is supported.

Exceptions: all Expansion Kits add zero direct surcharge. Regulator adds zero and divides draw by `1 + .25 * count`: one gives x0.8, two x0.6667, three x0.5714, four x0.5. Makeshift Firing/Detection are absent from loot weights and currently use the neutral Abundant +10% fallback, not inferred loot rarity assignments. Broken or head-unsupported modules do not contribute. Grid's surcharge still matters during battery fallback; eligible mains use does not debit a battery.

This table covers direct module surcharges, not every effect on endurance. Rapid-Fire/Enhanced Firing and reload/magazine changes alter shots per time; rotary speed alters motor draw. Scrapshot/Lobber also multiply shot cost by `1 + .5 * Splitter count`, plus their existing Velocity/Range factors, in addition to the direct surcharge. Ordinary firearm and Ballista formulas do not add that Splitter-specific factor. Siphon refunds occur after eligible kills and do not remove its own surcharge; the selected 45%/2x/+1x rule and Controller exclusion remain.

Keep tooltip numbers, effective stats and Sandbox behavior aligned when implementing. Do not modify the owner's rarity anchors, loot weights or assignments to obtain these battery changes. Planning recorded/mirrored; no code, package, save or Workshop mutation.

## C352 — Gentler hybrid balance and consumption labels (2026-10-19)

Owner rejects the strength of C351's x3 firearm / x2.5 Scrapshot proposal, accepts deliberate differences in DPS/immediate effect, and selects the direction of smaller head-family adjustments followed by a small high-tier module increase. Owner requests Low/Medium/High battery-consumption tooltip labels with appropriate colors and a recap. This is not approval of invented exact multipliers.

Clarification: firearms currently share a stat-derived head-cost formula; named M4/M9 overrides are unnecessary. Apply a separate firearm-family factor so Potato's shared base setting is not accidentally increased. Ballista and Scrapshot already have separate head rules. Module surcharges follow loaded rarity, independently of head families. Do not equalize all heads' endurance or change their damage, ammunition or cadence.

**Revised concrete proposal, pending numerical confirmation:** firearm head costs x1.5 (+50%), Scrapshot x1.25 (+25%), Ballista unchanged; increase only Epic/Legendary/Mythic module surcharges by 10% relative (0.6 -> 0.66, 0.8 -> 0.88, 1 -> 1.1). Lower-tier surcharges remain unchanged. Regulator retains its existing no-surcharge exception and 25%-per-module divisor. Preserve loaded rarity assignments, all loot weights, and the selected Siphon 45% / 2x / +1x behavior.

For C351's reference fourteen-module loadout, high-tier surcharge subtotal is 8.4 and lower-tier subtotal 1.2, so the combined multiplier rises from 10.6 to 11.44, approximately 7.9% more total draw from the module change. Including both adjustments gives approximately M9 120, M4 37, Ballista 28 and Scrapshot 64 real unpaused minutes from full. Ballista's head cost stays unchanged; its smaller runtime comes only from the high-tier modules. These are calculated estimates with the previous continuous-target/reload/ammo assumptions and Siphon/Regulator removed.

**New confirmation 1A (recommended):** use those revised values. **1B:** smaller head changes, firearms x1.25 and Scrapshot x1.1, retaining the same 10% high-tier surcharge adjustment and unchanged Ballista head cost. Owner-selected hybrid direction is settled; precise values are not.

### Head tooltip

Selected feature: a clearly labeled Battery Consumption line with Low/Medium/High. Recommend green Low, amber Medium, red High; retain the actual word so color is not the only cue. Color only the rating and restore normal text color afterwards; this is an explicit head-rating exception to the earlier white module-description preference, not a global tooltip recolor.

Recommend rating the head's estimated sustained base consumption, including normal firing/reload cadence, standard ammo and no installed turret modules or Siphon refunds. A brief head-only qualifier prevents confusing it with installed final draw. Per-cycle cost alone exaggerates slow heads, so it should not determine the rating. Use one consistent reference calculation for inventory and Manage head tooltips, respect saved Sandbox tuning and supported firearm stats, and retain numeric effective draw where available. TurretHeadDescription.get currently accepts optional effective stats in Manage but builds bare-head stats in inventory; do not accidentally produce inconsistent base labels between those callers. Determine/document shared thresholds against the complete head roster, including rotary/payload cases, before claiming final rating assignments.

### Pending-update recap

- Siphon proc chance
- Gentler head-family consumption
- Higher-tier module consumption
- Colored head consumption rating
- Mechanical Poke Floor
- Building menu corrections
- Lever trigger
- Wall-mounted dart emitter

Siphon 45%/2x/+1x and mechanical Poke/Building correction scope are settled; the hybrid direction and tooltip feature are selected, with numerical proposal above awaiting confirmation. Lever and emitter remain planning scope under their respective contracts; no unreviewed recipes, dart targeting policy or remaining interaction choices become approved by this recap. Multiplayer authority, local-battery Siphon restriction, independent packages, no trap modules and existing saved tuning remain requirements. No gameplay or install change.

## C351 — Siphon selected; head-versus-module comparison (2026-10-19)

Owner selects C349 **1A: 45% proc chance, 2x first refund, +1x per additional Siphon**, then asks whether to raise high-tier module costs or head costs, including Ballista, Scrapshot, modded M4 and a cheap pistol. This settles Siphon for the pending patch; the head rebalance below is a proposal, not approved implementation.

Compare the saved turret's fourteen remaining modules after physically removing Siphon and Regulator, with both empty slots left empty. Shared module multiplier is 10.6. This includes Enhanced Firing, Splitter and Conservation; all fourteen are supported by these four heads. Base.Pistol is the M9 in the owner's loaded Firearms mod, not an asserted vanilla-unmodified pistol. The latest session audit reports M9 damage 132.4999988079071, range 15, base cooldown 666.666667 ms, rack 1600 ms and reload 2700 ms. Installed FirearmsBETA/42.16/Firearms_Items_Handguns.txt confirms MaxAmmo 15. M4 source/session evidence is above/below; TurretHeads defines Ballista 240 damage/24 range/6-second cooldown/6-second reload/5 magazine, Scrapshot 320 damage/8 range/2-second cooldown/3-second reload/10 magazine.

TurretStats Enhanced Firing shortens cooldowns by 4/3; reload durations remain unchanged. After that module, M9/M4/Ballista/Scrapshot cooldowns are .5/.222222/4.5/1.5 seconds. Physical firearm reload requires subsequent chambering (1.2 seconds after tuning). TurretFeed starts custom-head reload on empty, overlapping cooldown. Splitter's two ammo uses and Conservation's divisor two mostly cancel; the last single loaded round adds a free cycle before its carried fractional consumption completes.

Calculated from the source equations and a small deterministic ammunition/cycle arithmetic loop, with full battery, continuous aligned targets, unlimited replenishment and functioning equipment:

| Head | Battery percent per paid cycle | Cost per cycle relative to M4 | Full battery, real unpaused minutes |
| --- | ---: | ---: | ---: |
| M9 pistol, loaded mod version | 0.006138769% | 0.65x | ~193 |
| Modded M4 | 0.009427540% | 1x | ~60 |
| Ballista | 0.265% | 28.11x | ~30 |
| Scrapshot | 0.0318% | 3.37x | ~86 |

These are comparable-model estimates, not four measured endurance runs. Physical ammunition path assumed; batch timing, target turning, accuracy, jams, ammo/condition and fractional final charge alter real sessions. The previous C349 rounded M4 estimate remains valid. Every displayed time is real unpaused time; at the saved 90-minute day, multiply real minutes by 24/90 for game hours at normal speed. No claim of equal combat strength: kills depend on ammo, hits, secondary effects and targets.

**Finding:** they are not energy-equivalent. Ballista's slow cadence still drains about twice as fast as the M4 over sustained operation; Scrapshot currently drains about 0.70x as fast as M4 despite costing more per cycle. The pistol drains about 0.31x as fast as M4. Current Ballista cost is already high enough that a blanket head-cost increase would be inappropriate.

**Recommendation:** tune head families first, retain existing rarity surcharges. Current surcharges are 0.1/0.15/0.25/0.4/0.6/0.8/1 for Abundant through Mythic, applied additively over base head cost. Thus a Legendary module adds 80% of the base cost, not 80% of the final loaded cost; this loadout already pays 10.6x base. Raising tiers further punishes utility and combat modules alike and does not fix head-to-head ratios. Rarity is derived from loaded loot tuning, so further coupling drain to tiers also increases the power consequences of loot edits; do not alter LootLab weights or tier assignments.

**New drain choice 1A (recommended):** firearm head consumption x3, Scrapshot x2.5, Ballista unchanged. Same reference loadout yields approximately M9 64–65 real minutes, M4 20 minutes, Ballista 30 minutes, Scrapshot 34 minutes. Keep damage, cadence, ammo, rarity and Regulator unchanged. Apply firearms adjustment as its own configurable factor; do not change PotatoBatteryPercentPerShot globally because firearms currently share that setting with Potato. Expose the actual Scrapshot base/factor rather than hiding its adjustment. Other heads require their own audit before a full roster rebalance.

**New drain choice 1B:** prioritize higher-tier module surcharges instead, retaining current head costs. Exact surcharge amounts would need a comparison/selection; none are invented as approved here. This is not recommended as the first fix because the existing cross-head imbalance remains.

Increasing head cost changes drain and absolute Siphon credits together; it does not change the selected Siphon break-even kill ratio. At one eligible kill per cycle, one/two Siphons still return 90%/135% on average, before lost overflow, with extra module surcharge included in actual paid cost. Sustain is not guaranteed for all combat patterns. Controller energy stays excluded.

No source/version/install/save/Workshop change this discussion. Siphon selection is settled; drain 1A/1B remains pending.

Owner asks to verify battery drain without Siphon/Regulator, considers 1.5x at 75%, and leans toward the earlier 1B (retain 2x). These are balance discussion, not a new selected multiplier or patch approval. Owner also asks whether the runtime is real or game time.

## Read-only evidence (2026-10-19)

Latest console identifies loaded save `Sandbox/2026-10-15_19-42-41`, version 0.2.57.2, and M4 turret `turret-1329947052`. Its final effective-stats record reports damage 187.5, range 25, cooldown 222.222222 ms, reload 2700 ms, and batteryPercent 0.008111242198331894. Its resource-spent entries confirm actual local-battery debits of 0.00008111242198331894 charge fraction. There are 88 recorded paid cycles for this turret in that console.

Read the save's global_mod_data.bin without launching or writing the world. Kahlua table scalar/table serialization was checked against the installed projectzomboid.jar using javap; decoding consumed all 19,208 bytes exactly. Controller record control-2 identifies the M4 at 9860,12754,0. The corresponding map/1232/1594.bin contains the current turret ID and inventory labels in the turret container region: Enhanced Firing, Lure, Filter, Martyrdom, Splitter, Synergy, one Regulator, Suppression, Execute, Conservation, Fragment, one Siphon, Void, 360, Enhanced Detection, Tack; Large Expansion and Car Battery are separate components. The sixteen modules match the logged module count. This is read-only binary inspection, not a native world-load/endurance test.

Loaded settings: PotatoBatteryPercentPerShot 0.00045; ModulePowerBonus 5; FirearmRateMultiplier 0.75; EnhancedFireMultiplier 4/3; FirearmReloadMultiplier and FirearmCycleMultiplier 1; Siphon loaded loot weight 3 with Legendary rarity surcharge 0.8. DayLength is 4. Installed SandboxOptions.getDayLengthMinutes bytecode confirms this means 90 real minutes per game day.

## Calculation

TurretStats uses percent points, while TurretBattery.spend receives a charge fraction. Do not confuse 0.00943 percent with 0.00943 of the battery.

- Base M4 shot cost: 0.00045 * sqrt((187.5 / 80) * (25 / 15)) = 0.0008893905919223566 percent.
- One Regulator divides cost by 1.25 and adds no surcharge itself.
- Current module multiplier is 11.4, inferred from the exact logged cost and confirmed formula.
- Physically removing Siphon also removes its 0.8 surcharge; removing Regulator removes the 1.25 divisor. Keep the other fourteen modules and leave the two slots empty.
- Result: 0.008111242198331894 * 1.25 - 0.0008893905919223566 * 0.8 = **0.009427540274376983% per paid firing cycle**.
- Full battery: approximately **10,607 firing cycles**.
- Configured cooldown-only rate: **4.5 cycles/second**, giving **39.29 real minutes** before reload/target delays.
- M4 magazine holds 30; Splitter and Conservation approximately offset the extra round demand. The final single-round conservation carry can produce an extra cycle. Reload is 2.7 seconds and chambering is 1.2 seconds after Enhanced Firing/rate tuning. Including ordinary reload/chambering gives approximately **60–61 real minutes**, assuming uninterrupted supply, functioning equipment and continuous aligned targets.
- At normal speed and this save's 90-minute day, about **16 in-game hours**. Pauses, missing targets, turning, empty ammo and other delays extend wall-clock endurance. TurretClock/ActiveTime use unpaused real time, so fast-forward cannot be converted by blindly treating firing as game-clock cadence.

This is full-to-empty local-battery endurance, not remaining runtime at the saved charge, not total Controller-bank endurance, and not a measured gameplay trial. Actual ammunition, weapon condition and target supply may end continuous firing first. Merely disabling benefits while leaving Siphon's surcharge installed would give a different result; this estimate physically removes both modules.

## Siphon alternatives

Expected refund fraction of paid energy is `proc probability * refund multiplier * eligible kills per paid cycle`, before capacity clipping and interrupted/lost source credits. At one eligible kill per cycle:

| Chance | First-module refund | Expected return |
| --- | --- | --- |
| 75% | 1.5x | 112.5% |
| 60% | 2x (earlier 1B) | 120% |
| 50% | 2x | 100% |
| 45% | 2x | 90% |
| 60% | 1.5x | 90% |
| 66 2/3% | 1.5x | 100% |

75%/1.5x breaks even at 8/9 eligible kills per paid cycle, not at one kill. 60%/2x breaks even at 5/6. Misses, multiple shots per kill, Splitter and Synergy-enabled secondary kills change that ratio. Exact expected break-even is not guaranteed survival: random failures and discarded overflow at full charge matter.

Recommend **1A: 2x at 45%, +1x per additional module**, preserving the owner's preferred 2x refund and producing 90%/135% expected return for one/two modules at one eligible kill per cycle. **1B: 2x at 50%** gives mathematical first-module break-even under that same assumption. **1C: retain earlier 2x at 60%**, accepting first-module positive return in efficient combat. These are new comparison choices, not retrospective relabeling of C348. The latest 75% proposal reopens chance selection; neither it nor a changed multiplier is selected.

No proc-per-kill tuning can guarantee a single module never sustains across every kill rate without an additional cap/change to reward eligibility; no such cap is authorized. Keep the roll shared across the stack, +1x amount stacking, Synergy gate, same-local-battery rule, Controller exclusion and loaded loot tuning. No gameplay, save, installed package or Workshop changes.

## C371 — Full consumption spectrum requested (2026-10-20)

Owner requests the complete OMH palette, with higher bands allowed to remain unused until Sandbox changes. [Seven-band fixed-threshold proposal](TETHER_PLACEMENT_C371.md#battery-spectrum-proposal) preserves the module-free head estimate and existing 5/15 percentage-points-per-real-hour boundaries. Current code already reads loaded Sandbox settings. No consumption, rarity, loot weight or surcharge changes are proposed. New labels/cutoffs await selection and patch approval.

## C372 — Targeted head increases discussed (2026-10-20)

Owner asks whether any heads have room for increased drain to use the proposed spectrum. This is discussion, not selection or gameplay approval. Reviewed current TurretHeads, TurretStats, TurretAmmo and TurretHeadDescription. Local arithmetic reproduces baseline rating formulas; no game/session endurance test was run.

At default settings without modules, continuous consumption is Potato 0.81, Scrapshot 4.286, Ballista 15, standard Makeshift Lobber 13.091, and both rotary heads 16.667 percentage points per real unpaused hour. These are module-free comparison values, not the owner's upgraded turret or remaining battery estimates. Runtime excludes idle time and assumes unlimited ammunition/targets and functioning equipment. Bare-head firing is a comparison baseline; practical automatic setups require their modules and therefore draw more.

Best candidates: Rotary Blades currently shares Bat consumption despite 40 versus 20 hit damage; Bat retains stronger shove (40 versus 10), so damage alone does not prove twice the overall value. Lobber provides area damage and can justify a modest additional energy tradeoff, but already spends crafted/explosive ammunition. Preserve cheap Potato/pistol roles. Leave Scrapshot, Ballista and firearms unchanged after the recent C354 increases; reference upgraded M4/Ballista endurance is already approximately 31/23 real minutes without Siphon/Regulator.

**1A (recommended):** Rotary Blades consumption x1.5 and Lobber consumption x1.5; every other head and module surcharge unchanged. Blades becomes 25%/hour (four continuous real hours instead of six), still High under proposed C371 bands. Makeshift Lobber becomes 19.636%/hour (about 5.09 hours instead of 7.64), moving Medium to High. Use separate configurable head factors; changing RotaryBatteryHours alone would also penalize the Bat and is not this proposal. Preserve saved Sandbox values and apply the factors consistently to payment and head-rating calculations.

**1B:** Rotary Blades x2, Lobber x1.5. Blades becomes 33.333%/hour (three hours), reaching Very High; the larger increase needs stronger justification/testing than color coverage alone. Other heads unchanged. Neither option selected. Leaving consumption unchanged is also viable; the spectrum does not need every band populated at defaults.

Lobber payload-specific costs are .02/.03/.04 for Makeshift/Aerosol/Pipe Bomb. At x1.5, actual module-free payload draw would be 19.636/29.455/39.273% per hour, respectively. The inventory head rating deliberately uses the Makeshift baseline, so a loaded Pipe Bomb does not turn that head tooltip into Very High. Do not silently change the head label to installed/payload-specific consumption. No automatic increase to all firearm costs, module tiers, loot weights, damage, cadence or Siphon rules. Raising shot cost also raises absolute eligible Siphon refund; it does not change the expected refund fraction.

C371 placement correction and seven-band proposal remain unapproved, and its numerical thresholds remain proposed. This does not accept or alter installed 0.2.59. Planning only, mirrored under C108/C119. Decision needed.


## C373 - approved corrective build (2026-10-20)

**0.2.59.1 / C373 installed (2026-10-20).** Approved placement/wall corrections, Rotary Blades x2 / Lobber x1.5, seven consumption bands, owner Performance icons and five native module categories are installed. **26,133 assertions**, 84 native construction cases, write/restart and all three package startup checks pass. Immutable `test/v0.2.59.1` / `810c5768f09c93edb696435a91e78f290f881fb5`; all **322 source and 422 tagged/package/install/archive files** match, with both 0.2.59 backups verified. [Patch](PATCH_v0.2.59.1.md) / [Owner test](TEST_v0.2.59.1.md) / [Release evidence](../diagnostics/v0.2.59.1/local-release.json). SP/server Lua branches use native objects with synthetic square lookup; rendered/connected acceptance remains pending. C108 development mirror uses the existing branch/draft PR; no merge, LootLab deployment or Workshop upload. **Test now** after restart.
