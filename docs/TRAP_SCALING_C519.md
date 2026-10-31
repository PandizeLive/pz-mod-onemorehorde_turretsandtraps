# C519 - Endgame trap coverage and sustainable output

Owner asks how to prevent endgame bases converging on thousands of Poke Floors without simply replacing them with Concertina or another trap. Discussion only: no damage, recipes, upkeep, recovery or deployment changes are approved. C518 multiplayer/projectile/rotary and bomb-loading work remains pending separately.

## Current source evidence

- Poke defaults: 45 damage per eligible zombie, 1.5-second cycle, 200 health, 1 wear. `ControlPoke.step` charges wear once per successful cycle (`cycle.worn`), not once per damaged victim. Multiple victims admitted to one stroke therefore increase damage without additional wear. Devices have independent stroke histories; successive tiles can hit the same victim independently.
- `ControlPokeAction` restores full health using one Scrap Metal and a Wrench, with the current four-second repair profile. Poke is mechanical and does not spend a battery for each strike. At defaults, full condition supplies 200 wear-charged successful cycles absent other damage. A one-target-per-cycle illustration gives 9,000 nominal damage before overkill and target eligibility; multi-target strokes can exceed that. This is arithmetic, not a measured horde kill count.
- Poke construction already has meaningful ingredients: the pump recipe uses one Tire Pump, four Metal Bars, two Small Metal Sheets and eight Screws, plus tools and Mechanics 1. An improvised recipe also exists. Thousands of deployed traps are not established as a typical attainable endgame from this report alone.
- Concertina defaults: 10 damage per contact interval, normally two seconds. `BarbContact.step` uses one per-zombie timer across barb sections, so moving between adjacent sections does not grant each a fresh immediate damage tick. Independent wire/attachment health is 50 and wears by one per positively damaged target. Wire slows movement while touching it.
- `BarbSupport.wear` does not apply attack wear to shared-health attachments; these depend on native backing damage. This distinction must be included before claiming equal recurring costs across all trap families. It is existing design, not automatically a bug.
- Bed Spikes default to 20/50 damage, 50/100 health and six wear per confirmed damaging fall, with a five-second recovery rule. They are conditional trip/fall traps, not guaranteed damage every step.
- Poke pickup records carried health; wire packing also preserves health. There is no confirmed pickup-healing exploit from the inspected paths. Repair and recovery consistency still belongs in any balance patch's regression checks.

## Recommendation: finite output, distinct jobs, useful investment

The goal should be that large trap fields are expensive, consumable defensive depth with diminishing tactical value, rather than the universally best self-sufficient endgame. Thousands of functioning traps should remain powerful given that investment. No finite numerical nerf can guarantee an arbitrarily large field never kills a finite horde; guaranteeing that requires a hard rule or countermechanic. Do not promise wear alone eliminates every trap-only strategy.

1. **Remove Poke's crowd-efficiency subsidy.** Charge wear per successfully damaged target, with coefficients chosen against actual damage and service cost. Preserve once-per-victim stroke protection, committed-hit accounting and server authority. Extend the same sustained-output accounting review to wire, barbs, beds and barriers; do not blindly force identical coefficients onto different roles. In particular, decide how shared-health barbed attachments pay for sustained offense.
2. **Balance repair output across families.** Compare useful damage/control per unit of materials and time. Consider materials restoring a defined amount of condition rather than every repair refilling every trap for one common item. Do not balance primarily through long hold-to-repair timers or thousands of individual maintenance clicks. Convenient bounded servicing may be needed if upkeep becomes the main cost; it is not authorized by this discussion.
3. **Give traps different jobs.** Poke: strong short-range burst with limited endurance under a crowd. Wire/panels: control and attrition, lower killing efficiency; existing shared barb cadence and non-multiplying slowdown help. Beds: opportunistic trips/fall damage. Barriers: directional retaliation while exposed to attacks. Turrets: sustained ranged finishing paid for with ammo/power. Traps may still kill; a universal nonlethal floor is not proposed.
4. **Evaluate layouts, not individual DPS alone.** Compare Poke-only, wire-only, mixed beds/Poke/wire, barriers, turret-only and mixed trap/turret defenses with equal construction and replenishment budgets. Include short versus deep corridors, continuous versus burst crowds and fast versus slow crossings. Measure kills/leaks, resources spent, conditions remaining, control duration and service effort. Include different Sandbox values and single-player/faction resource scales. Exact coefficients should follow these comparisons.

Keep physical activation responsive. A balance change must not disguise the remaining multiplayer timing defects as intended activation delay. Expose meaningful wear, durability and repair tuning in the existing Traps Sandbox page; defaults and native-support interactions need owner review.

## Choices

**1A - Shared upkeep and role rebalance (recommended).** Start with per-victim Poke wear, a whole-trap damage/control-per-repair comparison and differentiated roles. No arbitrary placed-count limit, universal invulnerability timer or new corpse system. Select actual numbers after the comparison.

**1B - Add corpse obstruction as well.** Killing lanes can eventually clog or disable traps until cleared, giving dense fields a physical counter. This needs a consistent rule for relevant floor hazards, legible feedback, server/client synchronization and bounded corpse queries. It risks becoming repetitive cleanup, undermining intentional corpse barricades, or shifting the optimum to non-floor defenses. Investigate only if 1A cannot meet the desired endurance target.

**1C - Construction-cost nerf only.** Easy to explain and implement, but mainly delays accumulation; it does little to control indefinitely cheap operation after the base is built. Not recommended as the main answer.

Avoid an arbitrary global cap, unexplained temporary immunity to all traps, hidden proximity penalties, and increasing placement/repair time as the principal solution. Each can discourage valid mixed layouts or turn maintenance into the challenge instead of defense design.

No implementation, packaging, upload or new player test. **Decision needed: balancing direction.**
