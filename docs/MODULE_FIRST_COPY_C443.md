# C443 - First-copy bonuses and additive duplicate tuning

Date: 2026-10-24. Owner asks to calculate every stackable and consider strengthening the first copy, reducing later gains, or both. This reopens numerical tuning before approval of the C442 combined patch; it does not undo additive stacking or authorize gameplay edits. Installed build remains 0.2.65. **All candidate numbers below are proposals.**

## Recommendation and scope

Use `benefit(n) = first + (n - 1) * extra` for one or more active copies, with no effect at zero. Fixed subsequent contributions preserve additive growth and useful duplicates. Do not apply a universal first-copy multiplier: some modules already unlock a strong effect with one copy; count effects, probability, damage, radius and efficiency have different consequences.

Recommend the selective candidate below. Strengthen weak first copies, reduce excessive duplicate growth, and leave already suitable effects alone. Do not make extra copies negligible: that would push every turret toward one of everything and undermine the owner's specialization goal. Current rarity assignments, exact loot weights, tier battery surcharges, head baselines and capability roles stay unchanged.

There are **19 stackable module families**, verified against `Turret.MODULES` minus unique roles, their variants and the four one-socket expansion kits. Firing/Detection variants, 360, Filter, Autoloader, Synergy, Grid, Lure, Void and expansion kits are outside this duplicate-stat proposal. The earlier tooltip/storage/layout corrections remain pending.

## Full calculation

The baseline is **C442 uncapped additive gains**, not the installed capped build. All percentages below are additive percentages of the stated base, or explicit probability points. A +340% speed bonus means 4.4x speed; it does not mean removing 340% of a duration. Range/radius is in tiles. Chance totals are bounded by 100% after the head's base chance is included.

| Module / measured effect | Current uncapped first / extra | Proposed first / extra | Proposed total at 1 / 4 / 8 / 16 | Current uncapped at 16 |
| --- | --- | --- | --- | --- |
| Rapid Fire: % speed | 25 / 25 | 40 / 20 | 40 / 100 / 180 / 340 | 400 |
| Reload: % speed | 25 / 25 | 50 / 25 | 50 / 125 / 225 / 425 | 400 |
| Velocity: % damage | 20 / 20 | 30 / 15 | 30 / 75 / 135 / 255 | 320 |
| Range: tiles | 2 / 2 | 3 / 1 | 3 / 6 / 10 / 18 | 32 |
| Magazine: % base magazine | 35 / 35 | 50 / 25 | 50 / 125 / 225 / 425 | 560 |
| Accuracy: chance points | 5 / 5 | 10 / 4 | 10 / 22 / 38 / 70 | 80 |
| Critical: chance points | 5 / 5 | 15 / 5 | 15 / 30 / 50 / 90 | 80 |
| Initial Blow: % conditional damage | 25 / 25 | 50 / 20 | 50 / 110 / 190 / 350 | 400 |
| Fragment: % parent damage per ray | 20 / 5 | 25 / 4 | 25 / 37 / 53 / 85 | 95 |
| Execute: % health threshold | 10 / 2 | 10 / 1 | 10 / 13 / 17 / 25 | 40 |
| Impact: % stagger chance | 60 / 2 | 60 / 2 | 60 / 66 / 74 / 90 | 90 |
| Splitter: extra shots | 1 / 1 | 1 / 1 | 1 / 4 / 8 / 16 | 16 |
| Piercing: extra penetrations | 1 / 1 | 1 / 1 | 1 / 4 / 8 / 16 | 16 |
| Conservation: uses per round | 2 / 1 | 2 / 0.5 | 2 / 3.5 / 5.5 / 9.5 | 17 |
| Regulator: % added cost divisor | 25 / 25 | 25 / 25 | 25 / 100 / 200 / 400 | 400 |
| Siphon: refund multiplier | 2 / 1 | 2 / 0.5 | 2 / 3.5 / 5.5 / 9.5 | 17 |
| Suppression: % hearing reduction | 60% first; +0.6 divisor/extra | 60% first; +0.6 divisor/extra | 60 / 85.71 / 92.31 / 96 | 96 |
| Martyrdom: radius tiles | 1.5 / 0.25 | 1.5 / 0.15 | 1.5 / 1.95 / 2.55 / 3.75 | 5.25 |
| Tack: radius tiles | 1 / 0.25 | 1.25 / 0.15 | 1.25 / 1.7 / 2.3 / 3.5 | 4.75 |

Sixteen-copy endpoints for each alternative, in the same units:

| Module | First-copy-only change at 16 | Duplicate-only change at 16 | Combined candidate at 16 |
| --- | ---: | ---: | ---: |
| Rapid Fire (% speed) | 415 | 325 | 340 |
| Reload (% speed) | 425 | 400 | 425 |
| Velocity (% damage) | 330 | 245 | 255 |
| Range (tiles) | 33 | 17 | 18 |
| Magazine (% base magazine) | 575 | 410 | 425 |
| Accuracy (chance points) | 85 | 65 | 70 |
| Critical (chance points) | 90 | 80 | 90 |
| Initial Blow (% conditional damage) | 425 | 325 | 350 |
| Fragment (% parent damage per ray) | 100 | 80 | 85 |
| Execute (% health threshold) | 40 | 25 | 25 |
| Impact (% stagger chance) | 90 | 90 | 90 |
| Splitter (extra shots) | 16 | 16 | 16 |
| Piercing (extra penetrations) | 16 | 16 | 16 |
| Conservation (uses per round) | 17 | 9.5 | 9.5 |
| Regulator (% added cost divisor) | 400 | 400 | 400 |
| Siphon (refund multiplier) | 17 | 9.5 | 9.5 |
| Suppression (% hearing reduction) | 96 | 96 | 96 |
| Martyrdom (radius tiles) | 5.25 | 3.75 | 3.75 |
| Tack (radius tiles) | 5 | 3.25 | 3.5 |

## Interpretation and secondary effects

- **Rapid Fire / Reload:** rate divides duration. Proposed Rapid is 1.4x / 2x / 2.8x / 4.4x at 1/4/8/16; Reload is 1.5x / 2.25x / 3.25x / 5.25x. Reload receives a first-copy buff without a duplicate nerf because it supports fast and small-magazine builds. It does not improve default sustained DPS where an unchanged cooldown already covers the reload; Autoloader also supersedes it. Do not advertise universal DPS per Reload copy.
- **Velocity:** proposed damage is 1.3x / 1.75x / 2.35x / 3.55x. Also propose its applicable knockdown bonus as **+5 points first, +3 points extra**, rather than +5 each: +5/+14/+26/+50 points at 1/4/8/16. Keep the natural 100% ceiling and existing head eligibility; Arc/Lobber main contacts do not use this knockdown stat.
- **Magazine:** percentages are of the original head magazine, not each successively expanded magazine. Keep minimum +1 round for each contribution and round up the final capacity. M4's base 30 becomes 45/68/98/158 rounds at 1/4/8/16, versus 41/72/114/198 with current uncapped gains. Small magazines therefore do not follow the raw percentage row exactly. This preserves capacity/Conservation/Void accounting rather than changing the meaning of a round.
- **Accuracy / Critical:** points add to the head's base chance. Natural saturation remains visible; more modules cannot promise more than 100% and no overflow mechanic is selected. Proposed Accuracy takes M4 near/far from 71/60 to 81/70 with one, versus 76/65 currently. Critical's stronger first copy is justified separately: on a 20%-base, 4x-crit M4, +15 points raises expected damage by 28.125%, close to first Velocity's +30%; on a zero-base, 2x-crit head it is only +15%. Damage plus Critical can multiply effectively even when a pure Critical stack loses to pure Velocity. No claim of equal value across all heads.
- **Initial Blow / Execute:** these are conditional, not always-on DPS. Initial Blow retains the >=90% pre-hit-health gate. Execute retains the <= threshold gate before damage; lowering duplicate gain prevents sixteen modules executing every target already below 40% health, while the first module remains useful at 10%. No player-budget bypass or new effect propagation is proposed.
- **Fragment:** retain five terminal rays, range, source style, excluded origin victim and Synergy rules; only per-ray damage changes. 25% with one, 85% with sixteen. Five rays are not five guaranteed hits, and they do not all hit the initial zombie. Increasing damage is cheaper than multiplying ray count.
- **Impact:** already front-loaded at 60% plus 2 points per extra. Keep it. Eligible-shot rules and shared five-second victim recovery still apply; 90% at sixteen does not mean a 90% chance to interrupt every attack or permanent stun.
- **Splitter / Piercing:** keep +1 per copy. Splitter already gives a paid extra shot at 50% damage and follows the accepted underfilled full-volley rule. A first-copy count buff adds workload and ammo demand immediately. Piercing retains 70% damage per penetration; ideal ordinary-ray total damage is 1.7x at one and about 3.326x at sixteen, assuming distinct aligned targets and no obstruction. This is inherent falloff, not a new cap. Arc continuation, shared marking and finite lineage remain as designed.
- **Conservation:** first copy already doubles firing uses per round. Keep that and lower duplicates to +0.5 use. Sixteen becomes 9.5 uses/round, an 89.47% ordinary ammo-cost reduction, rather than 17 uses/round and 94.12%. This is fractional consumption bookkeeping, not half a projectile; actual rounds remain integers. The existing debt arithmetic handles 95 ordinary uses at divisor 9.5 as ten consumed rounds in the isolated probe. Full exact-item/clip/Void/save/network verification remains part of implementation.
- **Regulator:** keep its current additive divisor `1 + .25*n`. It adds no module battery surcharge. Actual savings are 20%/50%/66.67%/80% at 1/4/8/16, so the first copy already gives the largest marginal saving. A further first-copy buff is unnecessary and could make one Regulator feel compulsory.
- **Siphon:** retain **45% proc chance** and **2x actual paid-cost refund first**, lower extra refund to +0.5x. At one eligible kill per paid root attack, mean refund is 90%/157.5%/247.5%/427.5% at 1/4/8/16, versus 90%/225%/405%/765%. Two copies still average 112.5%, retaining the owner's intended stacked sustain. This is not a guarantee: survival until a proc, overkill, available targets and full-battery waste matter. Multiple eligible kills scale the expectation; one module can already sustain above 1.111 eligible kills per paid attack on average. Secondary kills require the existing Synergy eligibility. No Controller battery refund or independent proc roll per installed copy is added. Do not claim this adjustment prevents all self-sustaining builds.
- **Suppression:** retain 60% initial hearing reduction and `remaining = .4 / (1 + .6*(n-1))`. Duplicate divisor increments are additive; the resulting hearing reduction is nonlinear. Whole-tile hearing rounding and the separate 10% playback-volume floor mean 96% theoretical hearing reduction is not 96% quieter audio. It already rewards one copy strongly and does not need another first bonus.
- **Martyrdom / Tack:** keep damage, timing, triggers and lineage. Radius affects area quadratically: sixteen proposed radii cover approximately 51.0%/54.3% of the corresponding uncapped baseline area. One Tack's 1.25-tile radius is a 56.25% area increase over one tile, not just a 25% coverage buff. Martyrdom's first radius stays 1.5. These changes retain further useful coverage while limiting growth through gains rather than a radius ceiling; bounded spatial work remains necessary.

## DPS and mixed builds

| Head | Prior uncapped Rapid / Velocity DPS | Candidate Rapid / Velocity DPS |
| --- | ---: | ---: |
| Potato | 37.50 / 73.50 | 36.09 / 62.12 |
| Ballista | 111.11 / 168.00 | 104.76 / 142.00 |
| Scrapshot | 484.85 / 640.00 | 451.28 / 540.95 |
| Arc | 100.00 / 84.00 | 88.00 / 71.00 |
| RotaryBat | 166.67 / 140.00 | 146.67 / 118.33 |
| RotaryBlades | 333.33 / 280.00 | 293.33 / 236.67 |
| Lobber | 72.58 / 114.55 | 69.23 / 96.82 |
| M4_FirearmsB42 | 1187.08 / 1832.45 | 1121.30 / 1548.85 |
| M9_FirearmsB42 | 406.72 / 612.29 | 383.33 / 517.53 |

These are sixteen-copy isolated raw sustained-DPS fixtures with no other modules, after removing the old artificial shot floor. Arc is per victim; rotaries assume continuous available contact and the default sweep; Lobber is nominal payload; guns use installed Firearms B42 properties. Reload/rack are included; accuracy, criticals, armor, target availability/turning, overkill and actual workload admission are excluded. Sixteen copies leave no default slots for automation. The first-copy changes do not force parity: Velocity remains stronger for reload-heavy raw DPS; Rapid remains stronger for Arc/rotaries and can improve kill throughput once damage would otherwise be wasted.

Source-executed mixed examples, using the same caveats:

| M4 build | C442 uncapped DPS | Candidate DPS | Meaning |
| --- | ---: | ---: | --- |
| One Rapid + one Velocity | 621.89 | 732.68 | Earlier two-slot payoff; manual comparison fixture |
| Seven Rapid + seven Velocity + Firing/Detection | 2107.27 | 1869.27 | Full sixteen-slot specialization remains strong |
| Four Rapid + four Velocity + two Reload + two Magazine + two Regulator + Firing/Detection | 1719.98 | 1731.00 | Full sixteen-slot mixed build stays approximately level |

For the candidate M4, including expected critical damage but still ignoring misses/armor/overkill: the seven Rapid/seven Velocity autonomous build gives 2990.83 DPS versus 2831.57 for seven Velocity/seven Critical with the same two automation roles. The former fires about 4.53 times/second versus 2.33; the latter uses fewer rounds and has different rarity-based power costs. This is evidence for distinct build tradeoffs, not proof those are the optimal builds. Early mixed Arc rises from 30 to 36.4 raw DPS per victim; seven/seven plus automation falls from 132 to 114.4.

**Balance limits:** strengthening first copies favors mixed builds and spreading modules across multiple turrets. Larger battery costs are not a sufficient restraint once Siphon/Regulator/grid options are involved. Removing bonus caps remains separate from keeping loaded-world, probability, state, PvP and scheduler protections. Custom slot counts can exceed sixteen; verify larger supported loads and bounded work before delivery. At forty hypothetical active copies, candidate Rapid is 9.2x and Velocity 7.15x, so this is not an implicit sixteen-copy ceiling. No live FPS, kill-rate, Horde Night or connected-player acceptance is claimed.

## Alternatives for owner selection

**1A - Selective first/duplicate tuning (recommended).** Use the per-module candidate table: both adjustments where warranted, first-only for Reload/Critical, duplicate-only for Execute/Conservation/Siphon/Martyrdom, and unchanged Impact/Splitter/Piercing/Regulator/Suppression. Velocity's associated knockdown duplicate adjustment is included. This is one reviewable proposal; individual row overrides remain welcome.

**1B - First-copy improvements only.** Use candidate first values but retain every existing duplicate gain. Safer for preserving large-stack power, but increases early and mixed-build power without addressing high-count ammo refunds or large effect coverage.

**1C - Duplicate reductions only.** Retain existing first values and use candidate duplicate gains. Contains large-stack power but leaves weak initial drops weak. Retains additive growth; not a new diminishing-gain curve.

The alternative endpoint table above calculates all three at sixteen; no choice is selected by this calculation. Expose useful First Copy / Additional Copy settings within the existing Modules category, with clear units/formatting, if this tuning is approved. Preserve exact existing custom settings and LootLab rarity/weight overrides; do not infer permission to rewrite saved tuning. Verify default-versus-custom migration before implementation handoff. The approved core stacking direction and C438/C440 corrections stay selected; numerical tuning and the combined patch approval remain pending.

## Evidence and handoff

Read current `TurretStats.resolve`, `Turret.MODULES/SINGLE`, `TurretHeads.supports`, `TurretConditionalHit`, `TurretSiphon`, `TurretVolley`, `TurretConservation`, `TurretBatteryEstimate` and rarity/loot definitions. No external balance claims or guessed engine APIs are needed for these source-based calculations.

An isolated Lua probe temporarily substitutes candidate stat functions around shipped resolution/duration logic under the installed Kahlua runtime and restores them afterwards. It produces 436 comparison/stat rows; a separate coefficient calculation covers all nineteen families at 1/2/4/8/16 across uncapped, first-only, duplicate-only and selective cases. Source-inventory coverage is asserted. Four new checks pass for Rapid/Velocity totals, fractional Conservation arithmetic and native table serialization. Existing harness fixtures also run; its historical 27,460 printed count is not a new release test total. Local scripts/log/JSON are in `diagnostics/c443/`; no Source/Contents or installed package changed.

**Decision needed: 1A selective candidate, 1B first-copy-only, or 1C duplicate-only.** This is a balance discussion, not a new owner test or patch installation. Current 0.2.65 stays installed; no version, Workshop draft, publication or hosted LootLab change.
