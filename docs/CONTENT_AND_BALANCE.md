# Content and balance plan

Current summary through **0.2.34**, synchronized 2026-10-08. [Decisions](DECISIONS.md) records approval; [release state](RELEASE.md) records verification; [roadmap status](ROADMAP.md#current-checkpoint-status-and-next-work) identifies remaining work. Earlier values in historical patch documents are not current defaults. Saved Sandbox values remain unchanged by new defaults. New recipes, skills and XP require owner discussion before implementation.

## Existing content

| Content | Current direction/defaults | Evidence/limits |
| --- | --- | --- |
| Spike Barrier | 1x2; front/exposed-end collision, open rear, see-through; 10 damage per front/side thump, shared 100 HP | Native player vaulting and directional scratch denominator 5 (one in five); damage/HP/risk configurable. Connected edges retain per-barrier identity |
| Reinforced Spike Barrier | 25 thump damage, twice basic maximum HP; upgrade restores full condition | Implemented, with positive owner feedback. Distinct artwork input; final art external |
| Barrier transport/service | Loose basic/reinforced weight 4/5; five-item same-tier packs 6.6/8.25; five-second placement/pickup, free ten-second repair, full-condition recovery | Pack/Unpack naming; packing/service/deployment grant no XP. Do not generalize barrier condition-reset policy to turret contents |
| Bed Spikes, basic/reinforced | 1x2; 20/50 fall damage, six wear, 100/200 durability; fresh zombie trip default 40%; weights 3/4 | Bush-like player traversal, sprint-trip/landing injury and recovery changes await combined rendered acceptance; R2C1-R2C2 implemented |
| Barbed Panel | One tile, backed by ordinary single-panel doors/window frames/walls/fences; immediate/default 10 damage then every two seconds; weight 2 | Finite supports share HP; window frames and non-finite supports use independent 50 HP with one wear per damaging activation. R2C3 implemented; rendered acceptance held |
| Potato launcher | 35 direct damage; magazine 1; overlapping two-second reload/cooldown; 100 total-potato default; eight-tile zombie hearing | Fresh base knockdown 40%; 25% splash within 1.5 tiles, at most three secondary targets. Shared recovery protection; no secondary knockback |
| Firearm mount | Actual conventional gun, native ammo/magazine/condition and stat inputs; firearm-wide rate .75; separate reload/cycling | Adapter, not complete player firing pipeline. Ordinary/precision range-accuracy defaults 60/80%; isolated modded evidence is not universal compatibility |
| Modules/Expansion Kits | Inventory installation, declared stacking, actual resources/power; standard loot items plus craft-only Improvised Detection/Firing/Expansion | See [current modular-turret summary](MODULAR_TURRETS.md). Kits replace one another in one dedicated socket |
| Loot/LootLab | Normalized 5x weights; overall/per-component controls default to 1; sixteen themed pools; uncommon five-plus jackpots | New containers only; map outcomes are estimates. Package split implements component-aware local exports/availability; jackpots do not boost ordinary loot |

Current base recipes and XP are in [the approved turret checkpoint](PHASE_2_CHECKPOINT_3.md#approved-recipes). Basic barrier recipe: four interchangeable planks/crafted spears, four binding units, retained sharp knife/cleaver, Carpentry 1 and 10 base crafting XP. Reinforcement: Carpentry 3, two additional planks, eight nails, retained hammer, 30 base XP. No recipe changes are implied by replanning.

## Remaining confirmed/planned roster

Planned content is not implemented or numerically approved merely because it appears here.

| Device | Role | Open design/proof | Revised checkpoint |
| --- | --- | --- | --- |
| Concertina | Contact damage and previously planned movement slowdown | Revisit slowdown against C81 Horde Night compatibility concern before implementation; reversible composition, upkeep/caps/recipe remain unresolved | R2C4 |
| Button / pressure plate | Pulse / ON while occupied | Links, access, occupancy, power and recipe | R4C1 |
| Poke Floor | Retractable spike strike with legal reset cadence | Strike window, safety, targets, power/wear/recipe | R4C2 |
| Dart emitter | Fixed triggered firing lane | Ammo, optional recovery, cadence and resources | R4C2 |
| Beam sensor | ON while obstructed | Alignment, power, obstruction and range | R4C3 |
| Control unit | Individual/all-linked compatible smart-device targeting | Authorization, players/factions/collateral, recognition capability | R4C3 |
| Explosive launcher/trap | Broad specialized crowd-damage concept | Mechanism, ammo, minimum range, collateral and performance all undecided | R3C3, optional |

Unique turret suggestions are kept separately in [TURRET_HEAD_PROPOSALS.md](TURRET_HEAD_PROPOSALS.md), with risks and recommendations. Toggle switches, trip alarms and manual drop-weight traps remain optional ideas, not confirmed additions.

## Trap constraints

Bed Spikes and Poke Floor are different devices: implemented passive short trip spikes versus a planned signal-driven retractable mechanism. C91 replaces automatic jumping with foliage-style player movement. Basic/reinforced beds occupy 1x2 on clear floor; C101 permits placement beside fence/panel edges while retaining obstruction checks. C94 recipe/tool/skill/XP costs match barriers. C104 sets placement/pickup to five seconds; repair/reinforcement remain ten seconds. Barbed flooring is dropped; concertina remains planned, while Barbed Panel is implemented.

C101-C103: walking is safe; running/sprinting retains 20% scratch risk per whole-bed entry. Sprinting adds configurable 20% player trip chance; a new landing on the bed causes one environmental laceration. Noclip/ghost bypasses custom traversal. Both tiers use a fresh 40% zombie trip default; forward trip and running brush animations are implemented but rendered acceptance remains held. Fresh falls from any source deal 20/50 zombie damage and six shared durability wear; existing prone zombies/crawlers take no repeated hits. Durability is 100/200, lasting 17/34 damaging falls. Shared five-second protection after getting up replaces the three-fall counter. See [0.2.32](PATCH_v0.2.32.md), [0.2.33](PATCH_v0.2.33.md) and the single [current test](TEST_v0.2.34.md). Restraining total effectiveness remains an acceptance goal.

Passive traps ignore smart-device filters. Barbed Panel uses exposed-side contact and one shared per-zombie interval across sections. C99 settles conditional durability: fixed window-frame barbs remain across open/smashed glass without adding window HP; door contact follows the leaf. Attachment grants no support repair. Independent durability is repairable. Exact support identity, unloaded/removed handling and native evidence are recorded in [R2C3](checkpoints/R2C3_BACKED_BARBED_SECTIONS.md). Multi-panel/garage doors and player barb injury remain unimplemented.

Concertina should damage only during contact. Recommend strongest-slow-only composition and a movement floor, with correct exit/death/despawn/unload cleanup. These are proposed safeguards, not an invented claim that a safe native movement API exists.

## Balance and release checks

C104 implements fresh module-slot totals **2/4/8/12/16** for None/Improvised/Small/Medium/Large, successive gains **+2/+4/+4/+4**, in two rows of eight. Improvised Detection/Firing/Expansion are craft-only; kits replace one another in the dedicated socket. Reserve bonuses are +25/+50/+100/+200. Saved Sandbox values and item access are preserved. [R3C8](checkpoints/R3C8_IMPROVISED_EXPANSION.md) records implementation/evidence and held owner acceptance; recipes, layout and migration are no longer pending decisions.

C81 schedules stackable Splitter/Fragment/Impact direction plus proposed Piercing/Initial Blow/Execute in [R3C4-R3C7](checkpoints/R3_OFFENSIVE_MODULES.md). These are not live effects. Fragment means five radial shots, not a lingering damage area; minimum separation is pending between 30 and 45 degrees, with 30 recommended. Exclude Homing, Bleed and slowing turret effects. Preserve existing potato splash and module-specific stacking rules.

Module intensity must increase power usage without making batteries a daily replacement/recharging chore in ordinary use. Recalibrate base drain and modest effect costs together using defined firing workloads, test ordinary and heavily stacked loadouts, and state sustained-fire endurance separately. Exact duration, costs and idle draw remain tuning decisions. Acceptance must cover combinations with current Rapid-Fire and loading modules; do not label an unmeasured battery as lasting a fixed number of days.

Measure kills per refill, damage/delay per resource, service time, structure survival, target progress and repeated crowd control, plus aggregate frame/network cost. Compare no defenses, one device, mixed defenses and a dense setup at the same difficulty/resources. Renewable ammunition cannot be balanced by construction expense alone.

Shared reward pool size and score modifiers remain unresolved integration policy; historical 25% XP and x0.20 score figures are proposals, not shipped settings. Offline inclusion remains confirmed default ON. Do not fake attribution or duplicate rewards across packages.

Incendiaries, live CCTV/remote aim, deep physical pits, general circuit programming, unlimited weapon-mod compatibility and automatic distraction loops remain deferred. Cure simulation is last. A smaller verified content release need not wait for the entire roster.
