# Phases and checkpoints

**C182 / 0.2.47.3:** approved rotation ticks (1B), pickup selection cue (2B), custom rarity audio pending owner files (3C), and a pulse-only four-second fade (4B). Pack audio uses native UI events with one shared bounded tick stream, no catch-up burst and cleanup on Collect. LootLab now shows calculated rarity in the normal list, refreshes draft feedback, and automatically groups equal weights when reopening. Confirmed tier weights persist for the page session; full reload derives centers from loaded weights. [Patch](PATCH_v0.2.47.3.md) | [Test](TEST_v0.2.47.3.md) | [Contract and pitch limitation](PACK_POLISH.md).

Native pitch variation requested, but additional randomized pitch is **not implemented**: the installed event path ignores clip pitch and the emitter setter writes every queued/active sound. Native rotation is played unchanged; no unrelated audio is modified. Custom rarity sounds remain pending, with the approved pickup cue providing selection feedback. No particles. No loot/default/rarity-formula changes.

## Product and existing work

**Previous installed 0.2.41** extends Magazine, Splitter and Fragment with Enhanced Firing/Detection and the current corrections, alongside Bed Spikes, Barbed Panel and subsequent crafting, Building, traversal and starter-module changes. Native evidence is in [release state](RELEASE.md); the latest [performance comparison](TEST_v0.2.38.1.md#owner-result-and-console-comparison-2026-10-10) is positive for perceived lag, with residual gaps and no repeat checklist requested. C106 records the earlier test findings; pending rendered checks are not passes or waivers. R1C3 includes diagnostic gating and aim/LOS cleanup; the reported lag fix is owner-accepted in 0.2.38.1. Broader performance/authority work remains separate and does not require continued play for this fix.

One Workshop product/download: **OMH: Turrets & Traps**, with independent selectable entries **OMH: Turrets** (`OneMoreHorde_Turrets`) and **OMH: Traps** (`OneMoreHorde_Traps`). Neither requires the other or a third Core entry. Canonical shared helpers are generated into both with identical virtual paths.

Existing SP content includes basic/reinforced Spike Barriers, portable items/packs, construction/vaulting/servicing, modular potato turrets, conventional firearm mounts, inventory/modules/power, loot and LootLab. Do not schedule their implementation again. Automated evidence covers twenty native guns and an isolated 51-gun Firearms B42 probe; full-modpack rendering, dense-client performance and MP are not certified.

Shared combat scheduling and active-time clocks exist. Render/maintenance costs and integrated authority remain open. The Louisville hang is unassigned; preserve useful evidence if it recurs, without claiming OMH caused it or has been cleared. Final art/audio remain owner-sourced. Makeshift Detection/Firing/Expansion are craftable; standard module crafting remains deferred.

## Current checkpoint status and next work

**C177 / 0.2.47:** pack/weights/hour correction implemented; use the focused [current test](TEST_v0.2.47.md). C171 capacity warnings remain open. Historical acceptance gaps below are not new test requests or newly claimed passes. C170 packed-weight cancellation remains final.

| Phase / checkpoints | Status | Remaining work / next gate |
| --- | --- | --- |
| 1: R1C1-R1C2 package split | Implemented and native-verified in 0.2.29; remaining owner regression waived by C89 | Closed to further split regression; retain fresh-world policy and independent-package checks for changes |
| 1: R1C3 performance/authority | C154 / 0.2.43 bounded transfers and five runtime optimizations installed; native checks pass | Relevant checks carried into the focused 0.2.46 test; broader authority/load scope remains |
| 2: R2C1-R2C2 Bed Spikes | Implemented with native checks, revised through subsequent patches | C106 tentative passes; verify corrected zombie landing/recovery in the focused 0.2.38 test |
| 2: R2C3 Barbed Panel | Implemented with native contact/construction/persistence checks | C106 tentative passes; revised Building acceptance; player injuries added in 0.2.38; multi-panel/garage doors remain unimplemented |
| 2: R2C4 concertina | C133 linked 1x2 conversion installed/native-verified in 0.2.39 | Focused paired-wire owner acceptance remains; see TEST_v0.2.39.md |
| 3: R3C1-R3C2 new head | Candidates documented; none selected for implementation | Select one head and settle its concrete contract before prototyping |
| 3: R3C3 explosive head | Optional, unscoped | Collateral/resource/effect-budget decisions and feasibility first |
| 3: R3C4-R3C7 offensive modules/battery | C177 / 0.2.47 adds weighted packs, 15% corpse acquisition and adaptive battery hours after the C168 endurance/Regulator update | R3C7 focused 0.2.47 owner test pending; packed-weight work abandoned under C170 |
| 3: R3C8 starter modules/expansion | C104 implemented, verified and installed in 0.2.34 | C106 tentative passes; 4/6/6 layout acceptance in 0.2.35; include maximum loadouts in future R3C7 endurance checks |
| 4: R4C1-R4C4 signals/connected traps | Planned | Signal contract first; devices then optional turret receiver |
| 5: R5C1-R5C3 MP/integrations/release | Planned; no certification or publication | Validate only the selected release scope; optional features need not all ship |
| 6: R6C1-R6C3 Cure simulation | Deferred, last | Matching contracts and loaded-combat controls first |

The phase order is not a mandatory queue through every feature. R1C3 continues alongside relevant SP content, and Phase 3 may proceed without finishing every passive trap. R3C1 head selection and R3C4 module contract/battery baseline are separate entry points; neither requires a new head to be implemented first. C120 selects and implements the 0.2.38 passive-content bundle; C125 selected the module track; C177 completes the approved pack/weight/hour bundle; C171 capacity warnings remain open and packed-weight compression is abandoned (C170).

**Documented module sequence: R3C4 -> R3C5 -> R3C6 -> R3C7.** The assistant's suggestion to make Initial Blow/Execute the next content patch was an unapproved reorder; those effects were already listed under R3C6. Battery baseline already belongs to R3C4. Keep any proposed reorder explicit until the owner selects it. R3C8 was separately approved and implemented under C104; its later ID does not make completed work a future task.

## Phase 1: selectable packages and shared foundation

| ID | Deliverable | Completion evidence |
| --- | --- | --- |
| R1C1 | Split design and installed-build loading probe: exact mod IDs/load order, shared-source ownership, settings/loot/menu ownership, old combined-ID/save handling | Traps-only and both load correctly; evaluate turret-only. No duplicate globals/events or accidental dependency. Record any packaging limit before choosing a workaround |
| R1C2 | Implement the approved package boundary; adapt installer, manifests, backups, version reporting and component-aware LootLab/export | Traps-only loads no turret recipes/items/module loot/model registration/update loops. Both reproduce current behavior exactly once. Relevant settings/UI only; preserve IDs/state where feasible, without promising safe mid-save uninstall |
| R1C3 | Measure mixed-defense performance and audit authority/transactions | Measure scans/rays/impacts/render/maintenance at meaningful density; fix measured bottlenecks. Define server-owned state and transport boundaries without duplicating gameplay rules. This does not enable MP |

**R1C1-R1C2 implemented and native-verified in 0.2.29; remaining owner checks closed by C89 waiver, not passed.** The [package checkpoint](checkpoints/R1_PACKAGE_SPLIT.md) retains tile-registry, installer and test-disposition evidence. R1C3 remains the active technical checkpoint. Performance/authority work can accompany passive-trap prototypes; completing all multiplayer work is not a prerequisite for another small SP feature.

## Phase 2: passive traps

| ID | Deliverable | Completion evidence |
| --- | --- | --- |
| R2C1 | C91 short-spike bed: 1x2 player brush-through and zombie trip/contact prototype | Prove foliage movement and native zombie falls onto the bed. Agree trip chance, fall damage, player speed/injury and crawler handling; prevent double rolls across the two tiles and repeated trip chains |
| R2C2 | Finish basic/reinforced Bed Spikes: construction, servicing, wear, Sandbox and persistence | Approve both recipes/tools/skills/XP and tier differences first; bounded contact processing, exact single fall damage, save/reload and absent-Turrets checks |
| R2C3 | [Barbed Panel](checkpoints/R2C3_BACKED_BARBED_SECTIONS.md) | C99 / 0.2.31 implements walls/fences, single-panel doors and independent 50-HP window-frame barbs; later changes include 0.2.35 Building. Native checks pass; C106 records tentative owner acceptance of unmentioned behavior. Multi-panel/garage doors remain unproven |
| R2C4 | Concertina movement feasibility, then content if it passes | Contact-only damage; reversible slowing that composes with other effects and ends on exit/death/unload. No permanent movement mutation or silent substitute for slowing |

C81 rejected general slowing turret effects; C157-C160 explicitly approve temporary Tack contact fields. C116 explicitly accepts concertina contact-only slowing, with the same requested behavior for Barbed Panels, following the Horde Night concern discussion. C117 approves divisor 2 and C119 approves the remaining current content details; native displacement scaling is implemented with real-object API proof; rendered acceptance remains. See [R2C4 investigation](checkpoints/R2C4_CONCERTINA.md).

Bed Spikes content began in 0.2.30 under C95, with native API, recipe and persistence checks. Later traversal/recovery/placement changes are included in 0.2.34. Use only [the current combined test](TEST_v0.2.38.md) for outstanding rendered acceptance; older patch tests are historical. Phase 2 is not fully accepted; concertina is implemented in 0.2.38 with owner testing pending.

## Phase 3: distinct turret heads and offensive modules

| ID | Deliverable | Completion evidence |
| --- | --- | --- |
| R3C1 | Select one head from [the proposal shortlist](TURRET_HEAD_PROPOSALS.md); settle purpose, resources, module effects and limits | Approve a concrete mechanic and recipe; explain overlap with existing heads and engine/performance concerns. The shortlist is not a commitment |
| R3C2 | Prototype that head on the existing universal base, then finish it if viable | Reuse inventory, aiming, cadence, persistence and diagnostics; declare module compatibility; bounded hits and exact resources; owner-sourced final assets |
| R3C3 | Optional explosive-head feasibility | First agree minimum range, friendly/structure damage, ammo/cost and effect budget. Explosives/incendiaries are not required for the first release |
| R3C4 | Offensive module contract and battery baseline | Resolve listed choices in [the checkpoint brief](checkpoints/R3_OFFENSIVE_MODULES.md); head capabilities, bounded propagation, stack rules and realistic endurance workloads. Record confirmed behavior versus proposed tuning |
| R3C5 | Directional-shot proof, Magazine/Splitter/Fragment combined under C136 | Real misses/obstructions, random angular separation including wraparound, bounded children, saved alternation, exact ammo/power transactions and measured dense-frame cost. No recursive effects |
| R3C6 | Piercing and conditional-hit modules, one effect at a time | Ordered penetration; C140 Initial Blow has an uncapped healthy-target bonus and Execute a lethal 7%-per-copy threshold; Impact needs its revised curve, proven stumble, first-round eligibility and recovery protection. Approve each concrete slice and combinations |
| R3C7 | Combined module balance, endurance and lifecycle acceptance | Ordinary and heavily stacked loadouts preserve long battery life; calibrated intensity-based costs, save/reload/pickup, slots/UI/loot/Sandbox, native/modded guns and existing potato splash. No MP claim without R5C1 |
| R3C8 | [Craftable improvised components and compact expansion](checkpoints/R3C8_IMPROVISED_EXPANSION.md) | C104 implemented/native-verified/installed in 0.2.34: two rows of eight, 2/4/8/12/16 fresh totals, approved recipes, 75% detection, 15% click-only failures and +25 improvised reserve. Saved values/items preserved. Owner acceptance remains in the combined test; larger loadouts remain part of R3C7 |

R3C8's former recipe/layout/migration gates were resolved independently by C104. Do not reopen them under R3C4. C104 originally selected a two-row eight-column grid; C106/C107 supersede it with the current 4/6/6 layout. Earlier layouts are historical. R3C7 still measures the complete selected loadout. See [current module contract](MODULAR_TURRETS.md#improvised-components-and-expansion).

C82 removes Extinguisher and Pneumatic Ram from the head shortlist and replaces Rotary Flail with **Rotary Blades** as the close-defense concept for R3C1 discussion. R3C2 must prove fixed-reach swept contacts, visible timing, obstructions and bounded damage cadence; physics, recipes and a gameplay patch are not implicitly approved.

The generic gun mount already exists; a newly compatible gun is not a new custom turret. This phase can start after the package boundary and relevant performance checks without waiting for every trap. Recommend one head at a time. R3C4 precedes module implementation; R3C5 and R3C6 follow in small reviewed slices without requiring a new head first. Establish affordable power tuning in every slice; R3C7 verifies the combined result rather than deferring battery cost until the end. C81 schedules this direction, not every suggested number or immediate gameplay changes.

## Phase 4: connected traps and controls

| ID | Deliverable | Completion evidence |
| --- | --- | --- |
| R4C1 | Button, pressure plate, links and bounded signal contract | Pulse versus held ON; no queued cooldown burst; restore real occupancy on reload; stable identity/access/broken-link/power handling. Confirm OR semantics and link limits |
| R4C2 | Poke Floor and fixed dart emitter, as separate implementation slices | One bounded strike/cycle, legal cadence, safe retraction, actual ammo/wear and no double damage/reward. Traps-only remains functional |
| R4C3 | Beam sensor and control unit | Power/alignment/obstruction proof; individual/all-compatible-linked control; passive hazards ignore filters. Decide player/faction/collateral policy before enabling it |
| R4C4 | Optional cross-package turret signal receiver | Traps uses a small capability interface when Turrets is enabled; neither assumes the other is loaded. Signals cannot bypass aim/ammo/power/cooldown |

Proposed ownership: controls, sensors and fixed triggered hazards in Traps; aimed swappable heads in Turrets. Validate future signal/content isolation in R4C1/R4C4 against the completed package boundary, without reopening R1C1. Powered traps must not require turret content. General circuit programming and automatic noise-lure feedback loops stay deferred.

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

## Active follow-up

- [x] Review [0.2.34 owner feedback and captured console](TEST_v0.2.34.md#owner-result-and-console-review-2026-10-08). Preserve tentative owner passes separately from log proof; do not repeat the complete checklist.
- [ ] Address C106 crafting/Building organization, three-row Manage layout and zombie trip-travel findings in a scoped corrective patch. Clarify Building inputs; retain 16-slot capacity and diagnose movement before changing damage eligibility.
- [ ] R1C3: measure the reported mixed-defense pauses; use [the audit](checkpoints/R1C3_PERFORMANCE_AUDIT_20261007.md) and current patch evidence to select any further optimization. Prove integrated authority before MP claims.
- [ ] R2C4: C120 / 0.2.38 implementation is complete; finish focused rendered acceptance. Divisor 2 and the C119 content/inventory contract remain unchanged.
- [ ] R3C1: select one unique head if taking the head track; shortlist membership is not implementation approval.
- [ ] R3C4: if taking the module track, resolve Fragment angle/propagation/range, stack caps, Splitter ammunition, Impact eligibility, compatibility and battery workload/target before offensive content.
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

C106 reopens the simplified Building interface after the 0.2.34 test and requests corresponding Normal/Reinforced/Packed organization. Installed gameplay remains crafting plus inventory placement. Clarify whether Building places crafted items or consumes raw materials before implementation; packed transport bundles require unpacking. Reuse placement validation, identity and resource transactions rather than creating a second divergent path. This supersedes indefinite Building deferral, not the distinction between creating and placing an item.


## C136 - approved module patch (2026-10-11)

Owner: "Approved." This approves the complete C135 Fragment baseline alongside Magazine and Splitter, and authorizes implementation/verification/install. No further gameplay decision is required for this slice. [0.2.40 patch](PATCH_v0.2.40.md) implements the selected rules; automated/native/package verification and tagged installation pass. [Combined test/evidence](TEST_v0.2.40.md) includes the held paired-Concertina check. R3C4 contract is settled for this slice; R3C5 is implemented pending verification and rendered acceptance. R3C6 stays next for later discussion; R3C7 combined balance/endurance remains pending. Earlier open-choice paragraphs are historical and superseded by this approval.
