# C349 — Saved M4 battery baseline and Siphon balance

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
