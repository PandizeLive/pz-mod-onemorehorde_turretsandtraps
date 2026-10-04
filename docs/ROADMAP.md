# Phases and checkpoints

**Current: [0.2.28 loot coverage and startup audit](PATCH_v0.2.28.md).** C79 adds four ordinary pool variants, normalized 5x weights and bounded all-gun diagnostics. The Louisville hang remains unassigned; no speculative engine patch. Release evidence: RELEASE.md.

**Next: P2C3e authority/performance hardening.** C76 brings conventional firearm admission forward; all twenty native real guns pass mechanism probes, while custom weapon code is not universally supported. Keep the shared aggregate-budget/clock audit and multiplayer authority gate from ARCHITECTURE.md. The complete trap roster remains planned below; this update does not displace it.

**Previous: [0.2.19.1 correction](PATCH_v0.2.19.1.md).** C67 fixes exposed compatibility duplicates, starts the potato visual at the barrel tip and removes redundant firing work with bounded diagnostic output. Owner reports the rest of 0.2.19 worked well. Install status: RELEASE.md.

**Previous: [P2C3d3 repair - 0.2.19](PHASE_2_CHECKPOINT_3D3_REPAIR.md).** C66 approves Install/input diagnostics, accurate component IDs with legacy aliases, Medium kit naming, synchronized delayed hits and owner-supplied audio. Release status is in RELEASE.md; one focused test covers the reported failures.

**Previous: [P2C3d3 — Expansion Kits and usability, 0.2.18](PHASE_2_CHECKPOINT_3D3.md).** C65 approved implementation; source/native verification and installation status are in RELEASE.md. One combined client test covers the held rendering/management findings.

**Previous: [P2C3d2 active stat modules, 0.2.17](PHASE_2_CHECKPOINT_3D2.md).** C63 approves implementation and Reload stacking. Rapid-Fire, Reload, Velocity and Range stack; Capacity has one dedicated socket; Autoloader removes reload delay. Shared effective stats, safe storage, grouped tuning and loot are implemented. Verification/install status is in RELEASE.md. Carry the entire held 0.2.16.1 test into the eight-step combined owner test; no rendered acceptance is implied.

**Next acceptance gate: [0.2.28 combined test](PATCH_v0.2.28.md#quick-combined-test).** Carry unfinished P5C1a rendered checks forward. P2C3e multiplayer/performance remains required before enabling MP; include the shared aggregate-budget and clock audit in ARCHITECTURE.md. Custom weapon mechanisms, additional recipes and planned trap roster remain later work.

**Current: [P2C3a-c — modular potato turret foundation, 0.2.9](PHASE_2_CHECKPOINT_3.md).** C48-C50 approve inventory/persistence, revised metal recipes, native deployment and powered manual firing. Combine player acceptance with the held P2C2b test. Module storage is implemented; P2C3d adds module effects and P2C3e proves multiplayer/performance. Version 0.2.9 is installed and archived, with exact tagged hashes and a verified 0.2.8 backup recorded in RELEASE.md. Native furniture Install/Pickup stays deferred.

**Previous candidate: P2C2 outline correction, version 0.2.6.** C40 approves shared native front edges plus exposed outer end caps and an open rear, replacing the C39 full-block/separate-player proposal. Connected runs and perpendicular corners omit internal caps; removal restores newly exposed ends. [Scope, evidence and owner test](PHASE_2_CHECKPOINT_2_OUTLINE.md). 1,433 Kahlua assertions and native write/read checks pass; rendered SP acceptance remains pending. Reinforcement and multiplayer remain pending.

## Previous checkpoint status

Status as of 2026-09-27: **0.2.4 implements P2C2-vault with C34 fence-style collision; its combined owner test includes the unaccepted 0.2.3 repair.** Phase 0 and cube-only asset preparation complete. Phase 1 remains partially accepted. The owner approved combining the persistence repair with P2C1b. [Version 0.2.1](PHASE_2_CHECKPOINT_1B.md) implements stable native tile identities, existing-part migration, portable crafting and one-item native deployment. The 0.2.1 log proves undamaged restoration without the former warnings. [0.2.2](PHASE_2_CHECKPOINT_1C.md) implements the Crafting category/description repair, P2C1c bundles and SP pickup/free repair from P2C1d. Player acceptance and the new directional vault prototype remain pending; reinforcement remains scheduled. No later phase or multiplayer acceptance is implied.

**0.2.3 correction:** the 0.2.2 player test failed servicing/destruction acceptance. [Current repair and full test](PHASE_2_CHECKPOINT_1C_REPAIR.md) also adds configurable basic damage/HP and default damage 10. The owner subsequently authorized advancing to the next checkpoint and testing it together with this correction; 0.2.3 player acceptance remains pending. Reinforcement remains pending.

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

Owner-authorized on 2026-09-26, with the combined P2C1a persistence repair and P2C1b implementation requested on 2026-09-27. The 0.2.1 player run confirms crafting/deployment and undamaged native restoration. Version 0.2.2 combines the requested menu correction, P2C1c bundles and the SP pickup/repair portion of P2C1d; player acceptance is pending. Remaining Phase 1 acceptance stays open.

Recipe follow-up: C24-C27 approve four interchangeable planks/crafted wooden spears, four binding units, a retained sharp knife/cleaver, Carpentry 1 and 10 base XP. Implemented in the 0.2.0.1 P2C1a follow-up before P2C1b inventory-item work; player acceptance remains pending. Reinforcement at P2C2a is approved separately below. Packing/unpacking/redeployment must not grant crafting XP.

The owner selected native construction in the building menu on 2026-09-26 and requested continuing while the remaining Phase 1 tests stay pending. Start with the Spike Barrier's two-tile preview, rotation and material transaction. Individual barrier items can coexist with material construction. A Spike Barrier Pack contains five individual barriers with a confirmed 67% encumbrance reduction (combined loose weight x 0.33); see C22/C23 in [Decisions](DECISIONS.md). The owner approved the existing basic recipe and XP for portable crafting. C44 sets basic/reinforced weights to 4/5 and five-item packs to 6.6/8.25. Basic-barrier recovery/free repair is implemented in the combined 0.2.2 P2C1c/P2C1d candidate under C32. This sequencing does not mark Phase 1 acceptance or multiplayer combat complete.

| ID | Deliverable | Dependencies | Acceptance evidence |
| --- | --- | --- | --- |
| P2C1 | Native Sandbox menu, per-content toggles, native building-menu construction with placement preview/rotation, service UI and ownership foundation | P1 evidence relevant to each path; resolve Q03/Q08 as applicable; remaining P1 acceptance stays open | Settings authority, disabled behavior, both footprint tiles validated, cancellation preserves materials, exact material transactions, no duplicated items or turret-resource refills; basic-barrier restoration follows C32 |
| P2C1a | Native Spike Barrier construction, two-tile/four-direction preview, material recipe, master/barrier toggles and construction diagnostics | Begin now; existing paired barrier lifecycle | Native menu discovery and recipe loading; invalid/cancelled build consumes nothing; completed build consumes once, joins persistent paired-defense runtime, and retaliates without debug controls; SP first |
| P2C1b | Individual barrier inventory item, crafting and native deployment; implemented in 0.2.1, partial SP evidence recorded | P2C1a repair combined by owner direction | One item creates one complete 1x2 barrier; no extra raw-material charge; cancel/failure preserves item; recipe/XP are owner-approved; individual weight remains provisional |
| P2C1c | Spike Barrier Pack containing five individual barriers; pack/unpack recipes | P2C1b; C22 | Five in/five out; bundled weight = 5 x individual weight x 0.33 (67% reduction); no duplication on cancellation/reload; basic-barrier full-condition pickup is intentional under C32; incompatible/damaged input policy verified |
| P2C1d | Servicing, recovery and ownership foundation; construction multiplayer gate | SP service combined with P2C1c by owner direction; MP/access remains separate | Basic-barrier pickup returns full condition and free repair uses the same ten-second action under C32; other resources/tier state must remain conserved; access/transfer rules explicit; dedicated-server two-observer material, placement and reconnect evidence before multiplayer construction is enabled |
| P2C2-vault | Native player vault and directional scratch prototype; [feasibility checkpoint](PHASE_2_CHECKPOINT_2_VAULT.md) | Owner authorized combined testing with 0.2.3; fence-style collision selected (C34); implemented in 0.2.4, rendered SP acceptance pending | Native collision/movement probe plus blocked landing, all headings, rear safety, single front roll, interruptions and unchanged zombie blocking; rendered client proof required |
| P2C2-outline | Connected front-and-end collision, open rear, overlay/input/contact fixes; implemented in 0.2.6 | C40 approval, failed 0.2.5 review; replaces separate actor collision feasibility | All headings, joined runs/corners, exposed caps after removal, actual gaps, native inputs/trips, front-only scratch, safe service, directional retaliation and save/reload; rendered SP acceptance pending |
| P2C2 | Bed-spike jump prototype, directional-risk Spike Barrier vault prototype, punji/cheval and barbed barricade gameplay | P2C1; resolve placement and remaining danger details | Automatic player jump visibly synchronized; blocked landing handled; barrier walking blocked; player front vault has one 20% scratch roll, rear is safe, and zombie blocking remains intact; passive hazards ignore target filters; current-HP host upgrade, correct faces, wear/destruction |
| P2C2a | Implemented in 0.2.7; rendered SP acceptance pending. Reinforce an existing Spike Barrier: Carpentry 3, two extra planks, eight nails, retained hammer, 30 base XP, twice maximum durability and 25 damage per thump | P2C1 paired lifecycle and transaction evidence; C25/C26 | Consume once, upgrade both halves as one device, fully repair while retaining facing/owner, preserve tier after reload/recovery, reject repeated upgrades, award XP once; no retroactive upgrade of basic barriers |
| P2C2b | Reliable barrier picking, paired menu highlight, independent reinforced texture inputs and diagnostics | C45 approval; same native collision and saved IDs | Both halves/ground/edge picks, distinct corner choices, bounded misses, hover cleanup, separate pages and preserved reload identity |
| P2C3 | Modular potato turret foundation; split into P2C3a-c in 0.2.9 | Approved C48-C50; existing potato combat path | One-second base cadence, real resources, native construction and exact persistence; combined player test pending |
| P2C3a | Inventory, contents tooltip, full carried weight and persistence | Approved; native proof in 0.2.9 | Exact actual items; one head/battery; ammo/module limits; no duplication or resource/cooldown reset |
| P2C3b | Five recipes, native deployment and ten-second pickup | P2C3a; approved metal recipe/skills/tools/XP | Equal complete/separate costs; no deployment XP; invalid/cancelled placement preserves item; all directions save correctly |
| P2C3c | Powered manual potato firing and categorized settings/diagnostics | P2C3a-b | Real potatoes, battery or valid external source; fuel/charge spent once; blocked/cooling/no-target shots spend nothing |
| P2C3d | Firing/Detection/Filter then Rapid-Fire/Velocity/Range/Capacity/360 module effects | P2C3a-c; numerical bonuses and module recipes need review | Inventory-driven changes, approved stacking, capacity removal safeguards, target/obstruction budgets |
| P2C3e | Multiplayer authority and performance gate | P2C3a-d; existing P1/P2 evidence | Dedicated two-player transactions, save/reconnect, consistent shots/deaths, aggregate work budget, pause/fast-forward clocks, density measurements |
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
| P5C1a (early slice) | [Supported-firearm mount prototype](PHASE_5_CHECKPOINT_1A.md) | C64/C69 approve early prototype; C70 repairs partial test | Three vanilla mechanisms, actual gun/ammo identity, shared modules, bounded targeting and persistence |
| P5C1 | Swappable firearm head feasibility, native attack/reload reuse, Reload and Autoloader modules | P4; prove native firing feasibility before choosing adapters | Preserve actual gun/chamber/magazine/condition; no blanket modded-gun compatibility; category fallbacks only where needed; Reload shortens reload, Autoloader removes reload delay without removing shot cadence |
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

## Current P2C3d1 follow-up

0.2.14 owner test reported working, including native turret thumping. C60 approves [0.2.15 polish](PHASE_2_CHECKPOINT_3D1_POLISH.md): independent management opening, search animation, balance defaults and temporary shot presentation. Sound production is with the owner. No stat-module effects, recipe expansion or multiplayer are folded into this patch. Player acceptance of 0.2.15 remains pending.

C61 approves [0.2.16 turning/presentation](PHASE_2_CHECKPOINT_3D1_TURNING.md) before stat-module work. Head/base depth and projectile/audio presentation remain a rendered acceptance gate; 0.2.15 was generally accepted with those follow-ups. No extra module recipes or multiplayer scope.

C78 implements the first P2C3e shared-budget/clock slice in 0.2.27. Isolated Firearms B42 mechanism/classification probes cover 51 conventional guns; full modpack rendering, mixed-turret frame measurements and multiplayer authority remain open. No additional turret heads or trap roster entries are silently marked complete.
