# Content and balance plan

Current summary through **0.2.28**, updated with C80 package planning and C81 offensive-module/battery direction. [Decisions](DECISIONS.md) records approval; [release state](RELEASE.md) records verification. Earlier values in historical patch documents are not current defaults. New recipes, skills and XP require owner discussion before implementation.

## Existing content

| Content | Current direction/defaults | Evidence/limits |
| --- | --- | --- |
| Spike Barrier | 1x2; front/exposed-end collision, open rear, see-through; 10 damage per front/side thump, shared 100 HP | Native player vaulting and directional scratch denominator 5 (one in five); damage/HP/risk configurable. Connected edges retain per-barrier identity |
| Reinforced Spike Barrier | 25 thump damage, twice basic maximum HP; upgrade restores full condition | Implemented, with positive owner feedback. Distinct artwork input; final art external |
| Barrier transport/service | Loose basic/reinforced weight 4/5; five-item same-tier bundles 6.6/8.25; free ten-second repair/pickup, full-condition recovery | Packing/service/deployment grant no XP. Do not generalize barrier condition-reset policy to turret contents |
| Potato launcher | 35 direct damage; magazine 1; overlapping two-second reload/cooldown; 100 total-potato default; eight-tile zombie hearing | Higher direct-hit knockdown; 25% splash within 1.5 tiles, at most three secondary targets. Shared recovery protection; no secondary knockback |
| Firearm mount | Actual conventional gun, native ammo/magazine/condition and stat inputs; firearm-wide rate .75; separate reload/cycling | Adapter, not complete player firing pipeline. Ordinary/precision range-accuracy defaults 60/80%; isolated modded evidence is not universal compatibility |
| Modules/Expansion Kits | Inventory installation, declared stacking, actual resources/power, Sandbox gains/limits, loot-only | See [current modular-turret summary](MODULAR_TURRETS.md). Small/Medium/Large kits occupy one dedicated socket |
| Loot/LootLab | Normalized 5x weights; overall/per-component controls default to 1; sixteen themed pools; uncommon five-plus jackpots | New containers only; map outcomes are estimates. C80 will make availability/export component-aware |

Current base recipes and XP are in [the approved turret checkpoint](PHASE_2_CHECKPOINT_3.md#approved-recipes). Basic barrier recipe: four interchangeable planks/crafted spears, four binding units, retained sharp knife/cleaver, Carpentry 1 and 10 base crafting XP. Reinforcement: Carpentry 3, two additional planks, eight nails, retained hammer, 30 base XP. No recipe changes are implied by replanning.

## Remaining confirmed/planned roster

Planned content is not implemented or numerically approved merely because it appears here.

| Device | Role | Open design/proof | Revised checkpoint |
| --- | --- | --- | --- |
| Bed spikes / punji | Passive stake bed, automatic player crossing | Footprint, native crossing, contact trigger, injury, wear and recipe | R2C1-R2C2 |
| Barbed barricade | Barbs attached to an existing barricade, damaging exposed-side thumps | Supported host types, shared HP/upgrade policy, wear, cleanup and recipe | R2C3 |
| Concertina | Contact damage and previously planned movement slowdown | Revisit slowdown against C81 Horde Night compatibility concern before implementation; reversible composition, upkeep/caps/recipe remain unresolved | R2C4 |
| Button / pressure plate | Pulse / ON while occupied | Links, access, occupancy, power and recipe | R4C1 |
| Poke Floor | Retractable spike strike with legal reset cadence | Strike window, safety, targets, power/wear/recipe | R4C2 |
| Dart emitter | Fixed triggered firing lane | Ammo, optional recovery, cadence and resources | R4C2 |
| Beam sensor | ON while obstructed | Alignment, power, obstruction and range | R4C3 |
| Control unit | Individual/all-linked compatible smart-device targeting | Authorization, players/factions/collateral, recognition capability | R4C3 |
| Explosive launcher/trap | Broad specialized crowd-damage concept | Mechanism, ammo, minimum range, collateral and performance all undecided | R3C3, optional |

Unique turret suggestions are kept separately in [TURRET_HEAD_PROPOSALS.md](TURRET_HEAD_PROPOSALS.md), with risks and recommendations. Toggle switches, trip alarms and manual drop-weight traps remain optional ideas, not confirmed additions.

## Trap constraints

Bed spikes and Poke Floor are different devices: passive stakes versus a signal-driven retractable mechanism. Automatic bed-spike traversal is not already solved by Spike Barrier vaulting. Prove the visible movement and blocked landing; do not substitute teleporting or faction immunity. Digging/grave workflow and replaceable stake bundles remain alternatives requiring a decision.

Passive traps ignore smart-device filters. Barbed attachments must not attack through the protected side, remain after host destruction or process the same thump repeatedly. Clarify upgrade/repair behavior consistently with the owner's full-repair-on-upgrade preference before implementation.

Concertina should damage only during contact. Recommend strongest-slow-only composition and a movement floor, with correct exit/death/despawn/unload cleanup. These are proposed safeguards, not an invented claim that a safe native movement API exists.

## Balance and release checks

C86 sets planned module-slot totals to **2/4/8/12/16** for None/Improvised/Small/Medium/Large, successive gains of **+2/+4/+4/+4**. The Improvised kit is craftable, and all kits replace one another in the dedicated socket. Physical UI rows are independent of unlock groups. [R3C8](checkpoints/R3C8_IMPROVISED_EXPANSION.md) covers compact-menu readability, existing-save/item preservation and crafting review. These planned values do not replace the installed 4/6/8/10 defaults until implementation; ammo bonuses remain separate.

C81 schedules stackable Splitter/Fragment/Impact direction plus proposed Piercing/Initial Blow/Execute in [R3C4-R3C7](checkpoints/R3_OFFENSIVE_MODULES.md). These are not live effects. Fragment means five radial shots, not a lingering damage area; minimum separation is pending between 30 and 45 degrees, with 30 recommended. Exclude Homing, Bleed and slowing turret effects. Preserve existing potato splash and module-specific stacking rules.

Module intensity must increase power usage without making batteries a daily replacement/recharging chore in ordinary use. Recalibrate base drain and modest effect costs together using defined firing workloads, test ordinary and heavily stacked loadouts, and state sustained-fire endurance separately. Exact duration, costs and idle draw remain tuning decisions. Acceptance must cover combinations with current Rapid-Fire and loading modules; do not label an unmeasured battery as lasting a fixed number of days.

Measure kills per refill, damage/delay per resource, service time, structure survival, target progress and repeated crowd control, plus aggregate frame/network cost. Compare no defenses, one device, mixed defenses and a dense setup at the same difficulty/resources. Renewable ammunition cannot be balanced by construction expense alone.

Shared reward pool size and score modifiers remain unresolved integration policy; historical 25% XP and x0.20 score figures are proposals, not shipped settings. Offline inclusion remains confirmed default ON. Do not fake attribution or duplicate rewards across packages.

Incendiaries, live CCTV/remote aim, deep physical pits, general circuit programming, unlimited weapon-mod compatibility and automatic distraction loops remain deferred. Cure simulation is last. A smaller verified content release need not wait for the entire roster.
