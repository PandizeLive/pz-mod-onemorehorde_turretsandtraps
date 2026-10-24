# C439 - Rarity sorting selected; balance stacking instead of ceilings

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
