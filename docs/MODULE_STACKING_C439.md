# C439 - Rarity sorting selected; balance stacking instead of ceilings

**Current decision:** [C442 additive stacking and updated DPS](#c442---additive-selected-uncapped-dps-and-next-update-2026-10-24). Owner selects the additive route. C441 accelerating/milestone alternatives are not selected. Existing per-copy gains are the comparison baseline; the consolidated patch remains pending approval and implementation.

Date: 2026-10-24. Source/build remains **0.2.65**, `test/v0.2.65` / `8a977bc60ea4845646f8bfb20a8eb7d7cd4b5f19`. Discussion/audit only; no new gameplay build, test result or balance implementation.

## Owner correction and current status

Owner selects C438 **1B**: rarity first, then category and name, highest rarity first. Preserve activation priority independently of display sorting; group active/unavailable modules separately. This settles the sorting question, not an instruction to stop the new stacking discussion and install the previous plan immediately.

Owner: "Why do we cap them? What else do we cap? Our balancing should be based on the stacking, not by capping it."

Record as project balance direction: tune stacking formulas, slot investment and operating costs rather than arbitrary total-bonus cutoffs. This supersedes the C438 recommendation to retain existing bonus caps and merely expose them. It does not by itself specify new numerical bonuses, probability formulas, over-100% crit mechanics, unlimited recursive effects or removal of processing safeguards. The earlier tooltip/kit/inactive-storage requirements remain selected and pending.

## Why the limits exist

[The original 0.2.17 implementation record](PHASE_2_CHECKPOINT_3D2.md#effective-tuning) calls Rapid Fire, Reload, Velocity and Range values "adjustable implementation defaults, not separately owner-selected balance values." They provided coarse bounds on speed, damage and reach. They are mod design choices, **not demonstrated limits imposed by the PZ engine**. The 0.25-second shot floor must not be presented as an engine requirement; Enhanced Firing and rotary timing already bypass that exact value in different ways.

[Fragment C135/C136](checkpoints/R3_OFFENSIVE_MODULES.md#c136---approved-module-patch-2026-10-11) later approved five fragments, 20% initial damage, +5 percentage points per extra copy, capped at 40%. The latest direction replaces balance-by-ceiling; it does not reopen the fixed fragment count or approve recursive fragmentation.

Charging extra module power after an ordinary stat has stopped improving is particularly poor feedback for a stacking-focused design. The previous audit correctly described the current behavior but retaining that behavior is no longer the recommended balance direction.

## Current stack-related limits at defaults

Runtime source: `Source/42.20/media/lua/shared/OMHTT/TurretStats.lua` (`S.bonus`, `S.resolve`, `S.hearingRadius`), `Turret.lua` (`T.SINGLE`), `FirearmAccuracy.lua`; server `TurretConditionalHit.lua`, `TurretProc.lua`, `TurretPlayerHit.lua`, `TurretVolley.lua`, `TurretOrdnance.lua`, `PrototypeCombat.lua`.

| Effect | Current limit | What stops improving / classification |
| --- | --- | --- |
| Rapid Fire | +200% rate at eight copies; default 0.25s pre-enhancement shot interval; rack floor 0.1s | Balance bonus cap and mod timing floors. Faster base heads can reach a floor earlier. Rotary uses motor speed instead. |
| Reload | +200% reload speed at eight copies; default 0.25s reload floor | Balance cap/floor; Autoloader overrides reload to zero. |
| Velocity damage | +100% at five copies | Balance ceiling: 2x base damage. |
| Velocity knockdown | 90% total, preserving an already higher base chance | A 90% balance ceiling below the natural 100% probability bound. Actual head applicability differs; Arc/Lobber main contacts do not consume this stat. |
| Range | +10 tiles at five copies; total 30 tiles for custom heads / 50 for firearms | Balance/geometric envelope in mod code, not proof of native maximum. Removing it needs loaded-world, acquisition, obstruction and search-cost verification. |
| Fragment | 40% parent damage per fragment at five copies; always five fragments | Damage ceiling. Fixed projectile count is a separate effect definition, not a duplicate-copy cap. |
| Accuracy | 100% close/far probability | Natural probability boundary; can reach it within 16 slots depending on head. Additional copies do not become damage automatically. |
| Critical | 100% critical probability | Natural probability boundary; no overflow/multicrit behavior currently exists. |
| Impact | 100% chance; 60% first copy, +2 points per additional | Natural probability boundary; 16 copies give 90%, so ordinary default slot count does not reach it. Five-second shared victim recovery and eligible-first-shot rules also restrict practical control. |
| Suppression | Player playback volume floor 10%; hearing radius rounded upward to whole tiles | Playback floor is distinct from zombie hearing, which keeps shrinking with diminishing returns but may have no visible integer change. No duplicate-count cap beyond slots. |
| Execute | No explicit combined threshold cap | 10% first copy, +2 points per extra: 40% at 16. At 100% threshold it naturally covers all ordinary health states; crossing 100% cannot add further ordinary targets. |

Other current stack formulas have **no separate total-bonus ceiling**: Magazine (+35% base capacity/copy with minimum one round and final rounding), Initial Blow (+25% per copy), Conservation (1 + count uses per round), Regulator (divide cost by 1 + 0.25 * count), Siphon (45% per eligible kill; refund multiplier count + 1), Splitter (one side shot per copy), Piercing (one extra penetration per copy with 70% retention), Martyrdom/Tack (radius +0.25 tiles per extra copy). Their practical results still depend on slot capacity, resources, supported heads, target availability, rounding and effect eligibility. Siphon cannot charge beyond a full battery.

Nonstacking capability roles are explicitly limited to one: Firing and its variants, Detection and its variants, Filter, 360, Autoloader, Synergy, Grid, Lure and Void. One dedicated expansion socket is separate. These capability rules should not be silently redesigned as stat stacks. Lure's selected radius is 5-20 tiles, independently of Range modules.

## Other caps which must be distinguished

- **Effect definitions:** Arc has six normal targets by default, followed by configured Piercing continuation; Splitter opportunities are finite per paid shot. Potato splash has three secondary victims. Fragment has five terminal projectiles. Martyrdom/Synergy permits one additional generation. These are separately selected behavior/lineage rules, not all evidence of modules ceasing to stack.
- **Crowd-control recovery:** native-state checks and shared recovery intervals restrict repeated knockdown/stagger. Removing these blindly risks permanent stun loops even if damage/power are balanced.
- **Player damage:** per-root-shot, per-player damage/wound accounting prevents child projectiles multiplying the full player injury budget. Friendly/PvP scaling remains separate from zombie damage; generic cap removal must not undo the earlier PvP decisions.
- **Workload admission:** current projectile/grenade queues admit up to 256 reserved/active jobs; proc bursts/fields have 512 budgets. Worker deadlines and per-tick slices bound processing. These are implemented resource safeguards, not claimed universal engine capacities. At pressure they can delay/refuse admission; uncapped bonuses do not promise unlimited engine throughput. Do not spend resources for an unadmitted attack or silently delete paid effects.
- **Physical/validity limits:** real storage/weight, available ammunition, battery charge, supported heads, loaded squares, line of sight and finite positive timing remain relevant. Sandbox input ranges and exact-integer serialization bounds are not synonymous with total stack-bonus caps.

## Proposed replacement direction

Recommend **1A: additive growth for ordinary numerical stats**, preserving the current per-copy gains as the initial comparison point, then tuning gains only where head/combination evidence warrants it. Remove ordinary bonus ceilings and review arbitrary timer/range floors together; otherwise those would become hidden replacement caps. Keep positive finite timing, bounded work and loaded-world rules. This is not approval to erase all clamps.

Illustrative uncapped formulas using existing gains:

| Copies | Rapid / Reload speed | Velocity damage | Extra Range | Damage per Fragment |
| ---: | ---: | ---: | ---: | ---: |
| 1 | 1.25x | 1.20x | +2 tiles | 20% |
| 4 | 2.00x | 1.80x | +8 tiles | 35% |
| 8 | 3.00x | 2.60x | +16 tiles | 55% |
| 16 | 5.00x | 4.20x | +32 tiles | 95% |

Speed uses `baseTime / (1 + gain * count)`, not repeated compounding or subtracting enough seconds to hit zero. Five times firing rate is not necessarily five times sustained DPS once reload, aiming and workload admission apply. Fragment percentages describe each of the fixed five rays and remain subject to target/obstruction constraints; five rays are not five hits on one zombie.

**1B: diminishing gains for ordinary numerical stats**, so every extra copy still helps, but less than the previous one. This avoids a sudden cutoff while weakening heavily specialized stacks; it is more complicated to communicate. No specific curve is selected or proposed as settled.

For probability effects, recommend separately reviewing a diminishing chance to fail rather than retaining a 90% balance ceiling, granting impossible raw probabilities or inventing multi-crit overflow. This permits continuing statistical improvement without casually guaranteeing control. Exact curves and handling existing 100%-base heads are still unresolved. Do not silently replace the approved +5-point Velocity or other chance gains this turn.

Operating costs and slots already constrain builds. Damage, cadence, Splitter, Fragment and Synergy also interact multiplicatively, so isolated sixteen-copy examples cannot establish whole-mod balance. Subsequent verification should compare mixed loadouts and battery/kill efficiency, plus high-density simulation work; no new live stress or DPS pass is claimed here.

## Handoff

**Decision needed:** 1A additive ordinary-stat stacking (recommended), or 1B diminishing ordinary-stat stacking. Rarity-first sorting is settled. Then consolidate the concrete probability/timing/range treatment and scope before a gameplay patch; do not add a redundant question about whether the owner wants arbitrary stack caps removed.

## C441 - Accelerating returns and build specialization (2026-10-24)

Owner asks to explain the alternatives and pitch benefits/issues, proposing the illustration **one module +10%, two +25%, three +70%, four +175%**. This is a considered direction, not approval of exact values or a formula for five through sixteen copies. Expand the discussion to accelerating returns; do not force the earlier two-choice menu or treat this as selecting diminishing growth.

### Meaning and verified arithmetic

- Additive: each copy contributes the same amount, e.g. +10/+20/+30/+40% total.
- Diminishing: each further copy contributes less than the previous one.
- Accelerating: each further copy contributes more than the previous one. The owner's marginal additions are +10, +15, +45 and +105 percentage points.
- Ordinary constant compounding is one possible accelerating curve, but +10% compounded four times yields only +46.41%; it does not reproduce the owner's much steeper example.
- A **+175% bonus means 2.75x base**, not 1.75x. Applying that curve separately to damage and firing rate gives 2.75 * 2.75 = **7.5625x ideal firing DPS** at four copies of each, before reload/aim/target/resource/workload constraints. This is not a measured sustained-DPS result.

An illustrative gentler curve is a +10-point first contribution with each additional copy's contribution growing by +5 points: contributions 10, 15, 20, 25, etc. Total bonus is `0.10*n + 0.05*n*(n-1)/2`. No hard bonus ceiling, no compounding each whole previously resolved stat, and no arbitrary extrapolation of the owner's four example values.

| Copies | Flat +10 points each | Gentle acceleration example | Owner illustration |
| ---: | ---: | ---: | ---: |
| 1 | +10% | +10% | +10% |
| 2 | +20% | +25% | +25% |
| 3 | +30% | +45% | +70% |
| 4 | +40% | +70% | +175% |
| 8 | +80% | +220% | Not specified |
| 16 | +160% | +760% | Not specified |

All columns use a hypothetical 10% starting effect solely to compare growth shapes; this does **not** replace the installed Rapid +25% or Velocity +20%. The gentle example is already 8.6x base at sixteen, so "gentle" describes the early acceleration relative to the owner's example, not a proven balanced endpoint. Arithmetic checked locally in diagnostics/c441/stacking-comparison.json; no game/simulation test claimed.

### Benefits worth pursuing

1. Duplicate drops stay desirable and the next matching copy can feel like a meaningful upgrade. Low-rarity modules can remain useful late rather than automatically being replaced by rarer unrelated effects.
2. Dedicated burst, cadence or ammunition builds gain identity. It creates a reason to spend more slots in one role and give up other utilities, protection or control.
3. Collection and expansion-kit progression can have stronger payoffs without adding new item types or hard unlocks. Larger kits permit meaningful specialization; an unavailable copy must not contribute to the same-type count.
4. Concentrating valuable modules in one turret offers a real tradeoff in coverage, redundancy and loss if that defense is destroyed. Multiple ordinary turrets may still serve different lanes better than one powerful turret.
5. A damage-only coefficient is cheap to calculate at loadout changes. Stronger damage need not mean more projectiles or more per-frame processing.

### Risks and counter-cases

1. **Concentration can dominate:** a steep curve may make a fifth identical module more valuable than an entire distinct role, shrinking build diversity. Mixed stats also multiply: with flat +10% bonuses, eight damage copies give 1.8x versus four damage/four rate at 1.96x ideal DPS; with the gentle accelerating example those become 3.2x versus 2.89x. This demonstrates a changed build incentive, not a universal optimum once reload/energy/other modules apply.
2. **Early stacks versus progression:** lowering the first-copy value to fund later power can make early drops feel weak and produce long waits for a matching set. The owner's example does not itself instruct a first-copy nerf. Skill, crafting and loot progression must be assessed with the finished curve, not presumed to balance it.
3. **Different stats have different consequences:** damage increases an existing hit; firing speed increases attacks/audio/effects and power per time; projectile-count bonuses add work per shot; larger radius increases searched area roughly with radius squared. A shared growth shape should use module-specific coefficients, and count/radius modules should not automatically inherit aggressive damage scaling.
4. **Chance and efficiency effects:** applying +175 percentage points to chance is not meaningful. Critical/Accuracy/Impact/Velocity knockdown require chance-specific treatment. Strong Siphon/Regulator and grid access can undermine battery cost as the sole restraint. Siphon's existing intended stack sustain is preserved; no new cap is proposed by pointing out this interaction.
5. **Battery accounting is not simply linear throughput:** module surcharge is additive per copy, but faster firing also pays that surcharge more often; some heads price damage/range separately. Strong damage can improve damage-per-round while faster shots spend more ammunition. Compare actual kills, overkill, reload and battery efficiency, not only displayed multipliers.
6. **Curve completeness:** the owner supplied four illustrative points, not a rule for larger stacks. The normal sixteen-slot window still permits substantial stacks after automation, and custom Sandbox slot settings can go higher. Validate the full supported range and mixed loadouts before choosing the endpoint; do not extrapolate an exponential and claim it is the owner's design.
7. **Player comprehension and modding:** a short shared growth rule with per-module parameters is easier to explain and extend than unrelated hand-written tables. If using milestones, show progress toward the next threshold. Keep effective/next-copy benefits accurate in tooltips/Details, preserve rarity-first presentation and count only active eligible modules. LootLab rarity changes must not secretly rewrite the effect curve.

### Cases to pitch, not yet selected

**1A - Gradual accelerating returns (recommended).** Use a small increasing contribution per matching copy for suitable numerical effects, starting from existing single-copy identity unless reviewed otherwise. The 10/25/45/70 example illustrates the shape, not selected module values. Tune each family; keep radius/projectile counts and probabilities on appropriate separate formulas. Every extra copy can help without a sudden dead cutoff, while specialization has a deliberate payoff. Full-count balance remains work.

**1B - Matching-set milestones.** Ordinary incremental gains plus visible boosts at matching-count thresholds, such as two/four/eight. This makes collection goals exciting and gives tuning more control, but produces power cliffs and awkward intermediate counts. No exact thresholds/boosts are selected. Continue ordinary gains beyond thresholds instead of disguising a cap as a finished set.

**1C - Steep accelerating specialization.** Pursue the feel of 10/25/70/175 with very strong matching sets. Best case is an intentional late-game power fantasy and satisfying duplicate jackpots. Costs: larger progression/loot/Horde Night and mixed-build rebalance, weak early-copy risk, potential dominant stacks and increased workload for rate/branch effects. Battery pricing alone cannot be assumed sufficient. The fifth-through-supported-maximum curve and scope would need explicit design; the four points are not adopted as final defaults.

Recommendation: **1A**, because it preserves the owner's escalating reward idea while leaving room for useful mixed builds and predictable performance. Retain 1C as a valid deliberate power-fantasy direction rather than rejecting it as technically impossible. No gameplay edit, new tests, installation, Workshop/hosted change or art work this turn. C438/C440 corrective scope remains pending; rarity-first sorting remains selected. **Decision needed:** choose the desired feel among these three cases before settling exact module-specific curves.

## C442 - Additive selected; uncapped DPS and next update (2026-10-24)

Owner: "Let's stick to our additive route. With uncapped, what's the new DPS comparison. Also recap next update". This settles the growth-model choice in favor of ordinary additive stacking, superseding the unselected C441 acceleration/milestone cases. It requests calculation and recap, not installation. Preserve the existing per-copy gains; no new coefficient, rarity, battery surcharge or loot weight is selected.

### Comparison and evidence

Executed the installed-source stat resolver and duration estimator in the stock game's Kahlua runtime, loading all 240 numeric/boolean source Sandbox defaults. A temporary in-memory override compares installed caps, bonus-only removal, and bonus plus firing/reload-floor removal; original functions/settings are restored afterwards. Source, packaged Contents and installed files are untouched. Local probe/log: `diagnostics/c442/balance.lua` and `diagnostics/c442/balance.log`; parsed results and hashes: `diagnostics/c442/evidence.json`.

Sixteen Rapid Fire copies: `1 + 16 * .25 = 5x` firing speed. Sixteen Velocity copies: `1 + 16 * .20 = 4.2x` damage. These use additive bonuses, not repeated compounding. The comparison has no other modules, including Reload, Enhanced Firing or automation.

| Head | Base raw DPS | 16 Rapid Fire raw DPS | 16 Velocity raw DPS | Rapid / base | Velocity / base |
| --- | ---: | ---: | ---: | ---: | ---: |
| Potato Launcher | 17.50 | 37.50 | 73.50 | 2.14x | 4.20x |
| Ballista | 40.00 | 111.11 | 168.00 | 2.78x | 4.20x |
| Scrapshot | 152.38 | 484.85 | 640.00 | 3.18x | 4.20x |
| Arc Emitter, per victim | 20.00 | 100.00 | 84.00 | 5.00x | 4.20x |
| Rotary Bat | 33.33 | 166.67 | 140.00 | 5.00x | 4.20x |
| Rotary Blades | 66.67 | 333.33 | 280.00 | 5.00x | 4.20x |
| Lobber, nominal payload | 27.27 | 72.58 | 114.55 | 2.66x | 4.20x |
| M4, installed Firearms B42 | 436.30 | 1187.08 | 1832.45 | 2.72x | 4.20x |
| M9, installed Firearms B42 | 145.78 | 406.72 | 612.29 | 2.79x | 4.20x |

For ammunition heads, rate is `magazine * 1000 / duration(stats, head, magazine + 1)`: the interval from the first shot of one full magazine to the first shot after reloading. This includes reload and applicable rack delay and represents one steady magazine cycle. It is not a long-running combat simulation. Arc uses `1000 / cooldown`; rotary uses its default 90-degree sweep contact cadence. The M4/M9 fixtures match installed Firearms B42 weapon properties, not vanilla weapon balance; effective baseline values were checked against the captured 0.2.65 console. Lobber is nominal payload scaling, not an AoE/falloff encounter result.

Accuracy, crits, armor, target acquisition/turning, overkill, victim scarcity, splash, chains beyond the named Arc victim, Fragment/Splitter and workload admission are excluded. Sixteen copies fill all default slots, so this is a comparison fixture, not an autonomous Detection/Firing build. No live engine throughput, GPU, listening, owner acceptance or connected-player pass is claimed.

The old 0.25-second firing floor must also go for this comparison. Removing only bonus caps leaves Rapid at **80 Arc DPS, 547.71 M4 DPS and 304.83 M9 DPS**, versus **100, 1187.08 and 406.72** in the table. Other listed heads are unchanged by that floor at sixteen copies. The 0.1-second firearm rack floor is still present in the probe, but M4/M9 resolve to 0.32 seconds, so removing it would not change these rows. No Reload copies are fitted; removing the reload floor does not change this comparison.

Native execution exited 0 and both added arithmetic assertions passed. The existing compiled harness also ran its historical fixtures; its printed 27,458 total is not a new release-suite count or a replacement for the recorded 0.2.65 release verification. This is calculation evidence only.

**Interpretation:** Velocity wins this raw sustained-DPS comparison on reload-heavy heads; Rapid wins Arc and rotaries. More fire-rate modules cannot eliminate reload time. Velocity also uses fewer rounds for the same raw damage, but may waste that damage once a hit already kills; Rapid can then clear available targets faster. Different module energy surcharges and firing frequencies mean this is not a battery-efficiency comparison. Retain current gains for this patch instead of forcing parity through a new unrequested rebalance. Mixed builds and stress acceptance remain necessary.

### Concrete stacking treatment proposed for patch approval

- Keep existing loaded per-copy coefficients; remove ordinary Rapid/Reload/Velocity/Range bonus ceilings and the Fragment damage ceiling. Sixteen default Fragment copies give 95% parent damage per fragment, still five terminal rays.
- Remove arbitrary firing/reload/rack timing floors as balancing devices; resolve positive finite intervals from base time and additive speed. Keep bounded scheduling/admission and no catch-up storm or resource charge for an unadmitted attack. No universal attainable attacks-per-second guarantee.
- Replace the arbitrary 30/50-tile total range ceilings with loaded-world, line-of-sight and bounded acquisition behavior. Range continues adding two tiles per default active copy. Verify query/trajectory/render paths and custom settings before claiming the range work complete; do not replace a ceiling with an unbounded square scan.
- Preserve ordinary probability semantics and existing additive chance gains. Proposed Velocity knockdown ceiling becomes the natural 100%, replacing the arbitrary 90%; existing head applicability/recovery remains. Accuracy/Critical/Impact cannot exceed 100% and receive no invented overflow/multicrit or diminishing-chance mechanic. This supersedes the earlier unselected probability-curve suggestion, subject to approval of this consolidated scope.
- Preserve unique capability modules, fixed effect/lineage definitions, shared victim recovery, player injury accounting and workload budgets. Suppression playback minimum is outside this ordinary-stat cap removal; hearing retains its existing diminishing formula. No new Siphon/Regulator rule or turret/trap power tuning.
- Remove obsolete cap controls and misleading capped text from current UI/schema while preserving valid saved per-copy settings and exact LootLab rarity/weight overrides. Do not silently normalize owner tuning. Tooltip/Details must show effective active values, including natural probability saturation.

### Consolidated next update

- Uncapped additive module stacking
- Trigger consumption colors
- Consistent grey Feature tooltips
- Readable Controller/Turret expansion benefits
- Player-focused descriptions and loaded Damage/Health
- Rarity-first module sorting
- Inactive module storage
- Atomic expansion replacement and ammunition overflow
- Unsupported-head module feedback
- Details/resize icon layout corrections

[C438](FEEDBACK_C438.md) and its C440 section retain the detailed UI, authority and persistence requirements. Inactive modules contribute neither effects nor battery draw; display sorting cannot change activation priority. Replace kits against incoming capacity directly, return the old kit safely, and transfer only excess ammunition to player inventory then ground with exact-item authority and bounded work. Preserve chamber/clip state, Conservation/Void accounting, item condition and Controller's actual expanded capacity. Controller stockpile dumping is not authorized. Poke remains 45 damage/200 health; the earlier 50 was an example of tooltip format, not selected tuning.

Installed build stays **0.2.65**. No version/changelog change, new owner test, Workshop upload or hosted LootLab deployment. **Decision needed: approve this consolidated corrective patch.** No additive-versus-accelerating choice remains open.
