# Phases and checkpoints

2026-10-08: C104 / 0.2.34 implements the R3C8 starter-module/expansion slice and further R1C3 aim/LOS cleanup. See PATCH_v0.2.34.md and TEST_v0.2.34.md. Standard module crafting, offensive modules, battery-endurance acceptance and client-stall resolution remain separate.

Replanned 2026-10-04 under C80, extended 2026-10-06 under C81 for offensive modules and battery endurance. C87/C88 approve fully independent packages and fresh worlds. **0.2.29** implements the split and retains SP combat; native isolation checks pass for Traps, Turrets and both. C89 closes the remaining owner test by waiver; [test disposition](TEST_v0.2.29.md) and [release evidence](RELEASE.md) distinguish observed results from skipped checks. Do not gate further planning on another full 0.2.29 regression round.

New checkpoint IDs use **R** for the revised roadmap. Historical P0-P6 IDs and evidence remain in [the previous roadmap](ROADMAP_LEGACY_20261004.md) and individual patch records. Do not reuse their IDs or erase incomplete acceptance.

## Product and existing work

**0.2.30 adds Bed Spikes under C95**, with native recipe/API/save-load checks and six shared wear per damaging fall. The focused rendered test is TEST_v0.2.30.md. R1C3 removes unnecessary diagnostic work and adds audio-stage measurements; elimination of the reported client stalls remains open.

One Workshop product/download: **OMH: Turrets & Traps**, with independent selectable entries **OMH: Turrets** (`OneMoreHorde_Turrets`) and **OMH: Traps** (`OneMoreHorde_Traps`). Neither requires the other or a third Core entry. Canonical shared helpers are generated into both with identical virtual paths.

Existing SP content includes basic/reinforced Spike Barriers, portable items/packs, construction/vaulting/servicing, modular potato turrets, conventional firearm mounts, inventory/modules/power, loot and LootLab. Do not schedule their implementation again. Automated evidence covers twenty native guns and an isolated 51-gun Firearms B42 probe; full-modpack rendering, dense-client performance and MP are not certified.

Shared combat scheduling and active-time clocks exist. Render/maintenance costs and integrated authority remain open. The Louisville hang is unassigned; preserve useful evidence if it recurs, without claiming OMH caused it or has been cleared. Final art/audio remain owner-sourced; module crafting remains deferred.

## Phase 1: selectable packages and shared foundation

| ID | Deliverable | Completion evidence |
| --- | --- | --- |
| R1C1 | Split design and installed-build loading probe: exact mod IDs/load order, shared-source ownership, settings/loot/menu ownership, old combined-ID/save handling | Traps-only and both load correctly; evaluate turret-only. No duplicate globals/events or accidental dependency. Record any packaging limit before choosing a workaround |
| R1C2 | Implement the approved package boundary; adapt installer, manifests, backups, version reporting and component-aware LootLab/export | Traps-only loads no turret recipes/items/module loot/model registration/update loops. Both reproduce current behavior exactly once. Relevant settings/UI only; preserve IDs/state where feasible, without promising safe mid-save uninstall |
| R1C3 | Measure mixed-defense performance and audit authority/transactions | Measure scans/rays/impacts/render/maintenance at meaningful density; fix measured bottlenecks. Define server-owned state and transport boundaries without duplicating gameplay rules. This does not enable MP |

**R1C1-R1C2 implemented and native-verified in 0.2.29; owner acceptance pending.** The [package checkpoint](checkpoints/R1_PACKAGE_SPLIT.md) records separate tile registries, installer rollback and the single deferred test. R1C3 performance/authority measurement is the next recommended technical checkpoint; new content remains separately scoped. Splitting before new content avoids additional coupling. Performance/authority work can accompany passive-trap prototypes; completing all multiplayer work is not a prerequisite for another small SP feature.

## Phase 2: passive traps

| ID | Deliverable | Completion evidence |
| --- | --- | --- |
| R2C1 | C91 short-spike bed: 1x2 player brush-through and zombie trip/contact prototype | Prove foliage movement and native zombie falls onto the bed. Agree trip chance, fall damage, player speed/injury and crawler handling; prevent double rolls across the two tiles and repeated trip chains |
| R2C2 | Finish basic/reinforced Bed Spikes: construction, servicing, wear, Sandbox and persistence | Approve both recipes/tools/skills/XP and tier differences first; bounded contact processing, exact single fall damage, save/reload and absent-Turrets checks |
| R2C3 | [Backed barbed section](checkpoints/R2C3_BACKED_BARBED_SECTIONS.md) | C99 / 0.2.31 implements walls/fences, single-panel doors and independent 50-HP window-frame barbs; native construction/contact/persistence checks and held combined owner test. Multi-panel/garage doors remain unproven |
| R2C4 | Concertina movement feasibility, then content if it passes | Contact-only damage; reversible slowing that composes with other effects and ends on exit/death/unload. No permanent movement mutation or silent substitute for slowing |

C81 rejects slowing turret effects because they undermine OMH Horde Night zombies. Revisit concertina's separately planned slowdown with the owner before R2C4; do not silently delete or implement it under the turret-module decision.

Bed Spikes content is implemented in 0.2.30 under C95, with native API, recipe and persistence checks. Rendered traversal/falls and dense-client smoothness remain pending in TEST_v0.2.30.md; the reported audio stalls remain under investigation.

## Phase 3: distinct turret heads and offensive modules

| ID | Deliverable | Completion evidence |
| --- | --- | --- |
| R3C1 | Select one head from [the proposal shortlist](TURRET_HEAD_PROPOSALS.md); settle purpose, resources, module effects and limits | Approve a concrete mechanic and recipe; explain overlap with existing heads and engine/performance concerns. The shortlist is not a commitment |
| R3C2 | Prototype that head on the existing universal base, then finish it if viable | Reuse inventory, aiming, cadence, persistence and diagnostics; declare module compatibility; bounded hits and exact resources; owner-sourced final assets |
| R3C3 | Optional explosive-head feasibility | First agree minimum range, friendly/structure damage, ammo/cost and effect budget. Explosives/incendiaries are not required for the first release |
| R3C4 | Offensive module contract and battery baseline | Resolve listed choices in [the checkpoint brief](checkpoints/R3_OFFENSIVE_MODULES.md); head capabilities, bounded propagation, stack rules and realistic endurance workloads. Record confirmed behavior versus proposed tuning |
| R3C5 | Directional-shot proof, then Splitter and Fragment in separate implementation slices | Real misses/obstructions, random angular separation including wraparound, bounded children, saved alternation, exact ammo/power transactions and measured dense-frame cost. No recursive effects |
| R3C6 | Piercing and conditional-hit modules, one effect at a time | Ordered penetration; Initial Blow/Execute use bounded damage bonuses; Impact requires a proven stumble, first-round eligibility and recovery protection. Approve each concrete slice and combinations |
| R3C7 | Combined module balance, endurance and lifecycle acceptance | Ordinary and heavily stacked loadouts preserve long battery life; calibrated intensity-based costs, save/reload/pickup, slots/UI/loot/Sandbox, native/modded guns and existing potato splash. No MP claim without R5C1 |
| R3C8 | [Craftable improvised components and compact expansion](checkpoints/R3C8_IMPROVISED_EXPANSION.md) | C84/C86: upgrades add 2/4/4/4; total slots 2/4/8/12/16 for None/Improvised/Small/Medium/Large. Separate unlock groups from visual rows. Set ammo bonuses, review recipes/tools/skills/XP, prove role replacement and click-only failed-trigger timing, preserve installed items/Sandbox values through base-capacity reduction, readable slots and safe kit downgrade. Include maximum loadouts in R3C7 |

R3C8 is an added checkpoint ID, not a requirement to run it after final balance acceptance: scope it in R3C4, implement the reviewed starter components/UI alongside module slices, then run R3C7 on the complete selected set. C86 replaces the five-row pyramid with simpler upgrade increments and a compact layout direction. Maximum remains 16; a two-row eight-column grid is recommended, with readable four-column alternatives explored. Improvised adds two slots for four total. See [module plan](MODULAR_TURRETS.md#planned-improvised-components-and-centered-expansion-layout).

C82 removes Extinguisher and Pneumatic Ram from the head shortlist and replaces Rotary Flail with **Rotary Blades** as the close-defense concept for R3C1 discussion. R3C2 must prove fixed-reach swept contacts, visible timing, obstructions and bounded damage cadence; physics, recipes and a gameplay patch are not implicitly approved.

The generic gun mount already exists; a newly compatible gun is not a new custom turret. This phase can start after the package boundary and relevant performance checks without waiting for every trap. Recommend one head at a time. R3C4 precedes module implementation; R3C5 and R3C6 follow in small reviewed slices without requiring a new head first. Establish affordable power tuning in every slice; R3C7 verifies the combined result rather than deferring battery cost until the end. C81 schedules this direction, not every suggested number or immediate gameplay changes.

## Phase 4: connected traps and controls

| ID | Deliverable | Completion evidence |
| --- | --- | --- |
| R4C1 | Button, pressure plate, links and bounded signal contract | Pulse versus held ON; no queued cooldown burst; restore real occupancy on reload; stable identity/access/broken-link/power handling. Confirm OR semantics and link limits |
| R4C2 | Poke Floor and fixed dart emitter, as separate implementation slices | One bounded strike/cycle, legal cadence, safe retraction, actual ammo/wear and no double damage/reward. Traps-only remains functional |
| R4C3 | Beam sensor and control unit | Power/alignment/obstruction proof; individual/all-compatible-linked control; passive hazards ignore filters. Decide player/faction/collateral policy before enabling it |
| R4C4 | Optional cross-package turret signal receiver | Traps uses a small capability interface when Turrets is enabled; neither assumes the other is loaded. Signals cannot bypass aim/ammo/power/cooldown |

Proposed ownership: controls, sensors and fixed triggered hazards in Traps; aimed swappable heads in Turrets. Validate in R1C1. Powered traps must not require turret content. General circuit programming and automatic noise-lure feedback loops stay deferred.

## Phase 5: multiplayer, integrations and release

| ID | Deliverable | Completion evidence |
| --- | --- | --- |
| R5C1 | Server-owned combat, service and inventory for selected release content | Two-player concurrent requests/replay/reconnect, exact resources, zombie ownership and consistent hits/deaths/effects. Share rules with SP; only authority/transport branches |
| R5C2 | Optional Horde Night scoring and Trait Shop shared-XP contracts | Review current sibling APIs and approve coordinated scope. One eligible-death XP pool; default-ON offline toggle; durable exactly-once delivery. No guessed killers/private-ledger mutation; numerical reward/score factors remain undecided |
| R5C3 | Release gate for a selected subset | Both/traps-only and intended turret-only combinations; saves, upgrades, defaults, translations, performance, owner assets and recovery. MP claims require R5C1; integration claims require R5C2. Separate publication authorization |

Authority design/testing begins with each device; R5C1 is integrated proof, not permission to defer all architecture. Optional integrations, explosives and the whole future roster do not block a smaller truthful release. An SP-only release must explicitly say so.

## Phase 6: Cure simulation, last

| ID | Deliverable | Completion evidence |
| --- | --- | --- |
| R6C1 | Versioned core/addon contract and loaded-combat controls | Core retains population/death authority; devices own declared resources; absent-package handling and approximation limits documented |
| R6C2 | Engagement, attrition, breach and resource reconciliation | No virtual refills or duplicate survivors; compare loaded controls; bounded computation |
| R6C3 | Rewards and lifecycle release gate | Real/simulated/restored kills deduplicate; offline rewards, restart/pause and load/unload cannot grant an advantage; matching sibling contracts precede compatibility claims |

## Immediate todo

- [x] C97: audit existing performance paths and verify the GitHub process/access; record [operation-count evidence and proposed optimizations](checkpoints/R1C3_PERFORMANCE_AUDIT_20261007.md). No gameplay patch or proven stall fix.
- [x] C97: revise barb design to wall/fence-backed sections sharing support health; hold the 0.2.30 owner playtest while away.
- [x] C98: run [initial native barb host/contact checks](checkpoints/R2C3_NATIVE_FEASIBILITY_20261007.md); distinguish constructed health persistence from map-fence counter reset and controlled motion from rendered acceptance.
- [x] C99: implement backed barbs, conditional durability, fixed window frames, door-edge geometry, native construction and service. No player injuries; multi-panel/garage doors remain pending. See PATCH_v0.2.31.md for validation and release limitations.
- [x] Record C80 split requirement, revised roadmap and preserved historical evidence.
- [x] Review collaboration guidance and require critical, evidence-based recommendations.
- [x] Separate existing plans from new turret-head proposals.
- [x] Record C81 offensive module direction, Fragment naming/angle alternatives and long battery life; revise head proposals around excluded and shared effects.
- [ ] Scope R3C4: Fragment 30/45-degree choice, propagation, range, stack caps, Splitter ammo, Impact eligibility and battery workload/target.
- [x] Carry pending 0.2.27/0.2.28 owner checks into one next-patch test without duplicate rounds or inferred passes.
- [ ] Review the next-patch combined owner test/full-modpack weapon audit when the owner tests later.
- [ ] Scope R1C1 loading/dependency proof and old combined-ID/save handling.
- [ ] Select a unique head; none is approved by this documentation update.
- [x] C91 selects 1x2 short trip spikes, reinforced variant and player brush-through animation; barbed flooring dropped.
- [x] C95 settles Bed Spikes tuning/servicing/recipes; 0.2.30 implements the content with native parsing/API/persistence proof.
- [ ] Complete focused 0.2.30 rendered Bed Spikes and dense-turret performance test; native checks do not certify animation or smoothness.
- [ ] Measure mixed-defense performance; prove authority before MP claims.
- [ ] Capture an earlier log or live thread evidence if the Louisville hang recurs.

## Historical mapping

| Old work | Revised location |
| --- | --- |
| P0/P1 engine foundations | Existing evidence; remaining gaps R1C3/R5C1 |
| Implemented P2 barriers/turrets and P5 firearm prototype | Existing content retained through R1C2; compatibility evidence ongoing |
| Unimplemented P2 bed spikes/barbs/concertina | R2C1-R2C4 |
| Remaining P2C3e performance/MP | R1C3/R5C1, plus per-feature gates |
| P3 score/shared XP/offline delivery | R5C2 |
| P4 signals, Poke Floor, dart, beam, control unit | R4C1-R4C4 |
| P5 explosives/release | R3C3/R5C3 |
| P6 Cure simulation | R6C1-R6C3, still last |

Discuss scope/tradeoffs before each gameplay checkpoint; recommend sufficient reasoning effort. Approval authorizes implementation, not a claim of feasibility. Record native/source proof, meaningful checks and complete 4-8-step owner tests. Mark implemented, verified, owner-accepted and published separately. Do not preassign versions or add planned work to the cumulative Workshop changelog.

## Deferred placement alternative (C102, 2026-10-07)

Retain the owner's idea of reintroducing a simplified Building interface. Current direction remains crafting plus inventory placement; do not re-enable duplicate construction/deployment recipes. Revisit only after the current crafting organization and placement repairs are accepted, with a clear distinction between creating an item and placing it.
