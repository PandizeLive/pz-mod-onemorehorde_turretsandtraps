# Phases and checkpoints

Status as of 2026-09-26: Phase 0 and cube-only asset preparation complete. P1C1 implementation is recorded in the [historical record](checkpoints/P1C1_RECORD.md). The owner authorized additional checkpoints before player testing: P1C2 native obstruction/health observation, P1C3 SP manual potato/impact, and P1C4 resource persistence/bounded scheduling are now partially implemented. See the [batch evidence and remaining gates](checkpoints/P1_BATCH_RECORD.md). The first owner test exposed a translation packaging fault, repaired with native-loader validation and diagnostic instrumentation in [0.1.2-p1debug](checkpoints/P1_DEBUG_RECORD.md). The completed SP run now supplies partial placement/thump/fire evidence; [0.1.3 visibility work](checkpoints/P1_MARKERS_RECORD.md) addresses unreadable object identity and adds readiness checks. Full Phase 1 acceptance remains pending; P2 onward is unstarted.

## Phase 0: project foundation

Historical repair: [0.1.4 combat record](checkpoints/P1_COMBAT_RECORD.md). The owner confirms rotation works but reports missing retaliation, inconsistent knockdown and firing-related disappearance. The current repair addresses cadence, heading and knockdown requests; per-thump retaliation remains unresolved.

The [completed 0.1.4 player review](checkpoints/P1_COMBAT_OWNER_REVIEW.md) confirms requested falls, valid textures and native barrier destruction. Next combat work follows the owner's shove-style reaction preference and 20 damage per actual thump; no periodic substitute was selected. Phase 1 remains partial.

| ID | Deliverable | Acceptance | Status |
| --- | --- | --- | --- |
| P0C1 | Decisions, content/balance, Sandbox spec, architecture, integration plan, roadmap, checkpoint template, art/tool briefs, validation and release state | Owner corrections preserved; proposals labeled; local links checked; no claim of runtime implementation | Complete |

## Phase 1: prove the engine paths

Current candidate: [0.1.6 / Phase 1 checkpoint 2](PHASE_1_CHECKPOINT_2.md). The [completed 0.1.6 SP review](TEST_v0.1.6.md) verifies front/rear filtering, paired condition, observed rotations and potato behavior. Side-end hits, reload, cleanup, traversal, legacy expansion and MP still require their acceptance evidence. No Phase 1 checkpoint is marked fully complete.

Keep assets and recipes minimal. Do not construct the full content library before proving combat and synchronization.

The [white cube placeholder](../art/placeholders/cube_turret/README.md) is available for the approved turret visual prototype. It has a fixed base, separate head pivot, aim cube, standard exports and an offline two-instance rotation preview. PZ per-instance rotation/rendering, occlusion and multiplayer remain unproven. Final art will be sourced without AI; do not convert this technical placeholder into an art-direction proposal. Add the native rotation/occlusion proof before polished assets or combat effects at P1C3.

| ID | Deliverable | Dependencies | Acceptance evidence |
| --- | --- | --- | --- |
| P1C1 | Current-build evidence, confirmed package identity, minimal loadable shell, exact-object persistence and placement lifecycle | Review [brief](checkpoints/P1C1_FOUNDATION.md); confirm target build/ID | Place/load/unload/reload/remove exact test object without duplication or unrelated changes; client/server state agrees |
| P1C2 | One damaging obstruction prototype | P1C1 | Correct attacker/face and cadence; per-thump feasibility decided from actual evidence; no duplicate retaliation; native destruction and death/corpse/loot agree |
| P1C3 | Potato shot/impact prototype with primary hit, knockdown and tiny splash | P1C1; reuse P1C2's proven damage path | Occlusion, single impact, crowd limit, no double damage, two observers see consistent knockdown/death/pop |
| P1C4 | Persistence and performance gate | P1C2-P1C3 | Restart and active-area transition preserve supplies/condition; density budget measured; no frame/world scans per device; log review |

Exit: enough evidence to implement content without relying on invented API hooks. A failed thump approach is resolved or a proposed alternative is reviewed before dependent content begins.

## Phase 2: initial playable defenses

| ID | Deliverable | Dependencies | Acceptance evidence |
| --- | --- | --- | --- |
| P2C1 | Native Sandbox menu, per-content toggles, construction/service UI and ownership foundation | P1; resolve Q03/Q08 as applicable | Settings authority, disabled behavior, exact material transactions, no refills through toggling or pickup |
| P2C2 | Bed-spike jump prototype, non-vaultable Spike Barrier, punji/cheval and barbed barricade gameplay | P2C1; resolve placement and remaining danger details | Automatic player jump visibly synchronized; blocked landing handled; no barrier entry/manual or automatic vault; passive hazards ignore target filters; current-HP host upgrade, correct faces, wear/destruction |
| P2C3 | Potato gameplay, recipes, ammo/power choice and impact assets | P2C1; resolve firing mode and tuning | 3-5 direct-hit reference target; one-second base cadence; higher knockdown; tiny splash; servicing and paired-turret balance |
| P2C3a | Modular inventory feasibility and slot contract, if approved | P2C1/P2C3; review [proposal](MODULAR_TURRETS.md) | Install/remove actual components once; persist exact items; reject incompatible/stacked modules; no cooldown/ammo reset; defaults remain functional without modules |
| P2C4 | Concertina movement feasibility; initial content balance pass | P2C2-P2C3 | Speed restored on exit/death/unload; mod interaction reviewed; solo/pair/combo and unattended loaded-area comparisons |

Exit: a candidate standalone playable set, not a public compatibility claim. Concertina may remain deferred if its movement proof fails; do not replace slowing with a different mechanic silently.

## Phase 3: Horde scoring and faction XP

| ID | Deliverable | Dependencies | Acceptance evidence |
| --- | --- | --- | --- |
| P3C1 | Horde adapter and approved score-policy proposal implemented across core/export/website | P2; resolve Q07 and score baseline; coordinated sibling scope | Proposed x0.20 stacks once with x0.50 and x1.20; history survives toggles/removal; no quota/cleanup intrusion; official claims only after matching validator |
| P3C2 | Authoritative device death attribution and shared XP pool | P2; resolve Q01-Q03 and mixed-kill attribution; Trait Shop contract | One pool per eligible death; all snapshotted eligible members divide it; no personal+faction duplicate; no skipped fractions |
| P3C3 | Offline-member entitlement delivery, default-ON toggle and provenance | P3C2 | Offline share survives restart; same-life settlement once; death/faction/toggle policy verified; no retrospective redivision |
| P3C4 | Integration release candidate | P3C1-P3C3 | SP, dedicated two-player/offline/reconnect and dependency combinations; capture logs and exact versions |

P3 does not implement virtual combat. Real kills can reward offline faction members before P6 exists. No existing Horde-completion eligibility rule is changed as a side effect.

## Phase 4: connected traps

| ID | Deliverable | Dependencies | Acceptance evidence |
| --- | --- | --- | --- |
| P4C1 | Control unit, individual/all-compatible-linked targeting, button, pressure plate, link UX and bounded signal runtime | P2; smart-device capability, signal/danger/link-policy decisions | Authorized smart-device/group changes; passive objects unaffected; player/faction/no-one policy, pulse versus maintained ON, OR proposal resolved, busy pulses bounded, inputs restored from reality on reload |
| P4C2 | Dart emitter and Poke Floor | P4C1 | Pulse gives one cycle; held ON permits legal cadence; OFF prevents new cycles and retracts safely; damage/XP only once |
| P4C3 | Beam sensor and concertina gameplay if feasible | P4C1; P2C4 movement proof | Blocked/clear and powered states agree across clients; opaque obstacles and close/open doors; slowdown cleanup |
| P4C4 | Connected-defense balance and release candidate | P4C2-P4C3 | Crowd/links budget, broken controller, multiple inputs, save/unload, ammo/wear and paired-trap exploitation |

## Phase 5: advanced weapons and complete loaded-combat release

| ID | Deliverable | Dependencies | Acceptance evidence |
| --- | --- | --- | --- |
| P5C1 | One supported firearm sentry and camera/controller targeting | P4; targeting/player policy confirmed | Acquisition/turning/occlusion, real ammo, sound/noise, consistent deaths and receipts; no blanket modded-gun support |
| P5C2 | Explosive device prototype and gameplay decision | P5C1; explosive defaults/collateral confirmed | Range/obstruction/target limits, collateral, resource transaction, large-crowd effect/network budget |
| P5C3 | Complete loaded-combat tuning and release gate | P5C1-P5C2 plus prior relevant regressions | Content switches and score classification reviewed; packaged assets/recipes/translations verified; release baseline and limitations documented |

An early release can occur after an earlier phase's accepted release candidate. The single-edition product gains features over time; do not wait for every advanced weapon merely to test or ship proven content.

## Phase 6: Cure defense simulation, last

| ID | Deliverable | Dependencies | Acceptance evidence |
| --- | --- | --- | --- |
| P6C1 | Explicit core/addon simulation contract and loaded-control measurements | Accepted loaded-combat content; reread current Horde/Cure runtime | Core owns population/deaths; device resources and recipient receipts have clear owner; lane approximation and limitations reviewed |
| P6C2 | Defense engagement, attrition, exposed approaches and resource reconciliation | P6C1 | Attacks split between valid defenses/Cure; failures transfer pressure; no virtual refill/heal or duplicated survivors |
| P6C3 | Simulation rewards and adversarial lifecycle validation | P6C2; P3 receipts | Real/simulated/restored kills deduplicate; offline toggle honored; restart/PauseEmpty/state-switch loops confer no benefit |
| P6C4 | Final balance and simulation release | P6C3 | Comparable loaded/unloaded outcomes; no unloading advantage; verified publication of matching contracts before compatibility claim |

## Checkpoint procedure

1. Read the decision register and applicable project instructions, review current source/build and related task updates, then name unresolved decisions for that checkpoint only.
2. Give the owner a concise effort/time recommendation for runtime work and obtain the required implementation scope approval. Documentation authorization does not authorize unrelated sibling patches or publishing.
3. Use the [checkpoint template](checkpoints/TEMPLATE.md) for exact files, changes, assumptions, rollback and evidence.
4. Run the smallest meaningful automated/static check, then an appropriate complete 4-8-step owner test if in-game evidence is needed. Inspect logs afterward.
5. Mark complete only when the acceptance evidence exists. Separate implemented, statically verified, player-tested, and published states. Update cumulative Workshop notes only for actual player-facing changes.

Do not preassign version numbers or dates to unimplemented checkpoints. Phase 0 has no gameplay version or Workshop content upload.
