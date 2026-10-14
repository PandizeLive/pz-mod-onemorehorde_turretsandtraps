# OMH: Turrets & Traps

**C240 implementation in progress:** [Multiplayer/Horde changes, verification and remaining work](docs/PATCH_C240_PROGRESS.md). Collision is neutral; active effects require receiving-run consent. Server pack transactions and core scoring integration are implemented, but the production MP port remains unfinished and uninstalled.

**Approved scoring contract:** [Multiplayer and Horde Night scoring](docs/MULTIPLAYER_HORDE_PATCH.md). Divide by5, explicit per-run opt-in and default-or-harder eligibility audit. C240 above records actual implementation separately from remaining MP enforcement and acceptance.

**Active development:** [C240 combined-patch progress](docs/PATCH_C240_PROGRESS.md), retaining the approved C235 content/Void work and [C236 foundation](docs/PATCH_C236_PROGRESS.md). Installed0.2.49 remains unchanged; player testing is deferred. MP is an original requirement and production authority/transactions remain unfinished. Deferred testing does not stop approved development.

Latest LootLab correction: [shared saved rarity anchors](docs/LOOTLAB_TIER_PERSISTENCE.md#c185-shared-rarity-anchors-2026-10-12), C185.

Current patch: **0.2.49 / C207**, new head prototypes and C191 timing refinements implemented; owner acceptance pending. [New turret heads](docs/PATCH_v0.2.49.md) | [Short test](docs/TEST_v0.2.49.md) | [Current status](docs/CURRENT_STATUS.md).

**Development build â€” testing pending. No official release yet.** The private [GitHub repository](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps) uses `dev` for current code and planning. Start with [Planning](docs/PLANNING.md), [current status](docs/CURRENT_STATUS.md) and the [development/release workflow](docs/GITHUB_WORKFLOW.md). Cloud discusses and documents plans; the local PC implements and tests them. Every completed update and versioned test finding is mirrored to GitHub under C108. Current owner findings: [0.2.34 completed with findings](docs/TEST_v0.2.34.md#owner-result-and-console-review-2026-10-08), [0.2.35 owner findings](docs/TEST_v0.2.35.md#owner-findings-and-console-review-2026-10-09); automated results remain in [release evidence](docs/RELEASE.md). Official releases are tracked separately after confirmed Workshop publication.

Project foundation created 2026-09-25. **Previous feature patch 0.2.47:** [Module Packs, owner loot weights and battery hours](docs/PATCH_v0.2.47.md), implemented under C177. [Current status](docs/CURRENT_STATUS.md) | [five-step test](docs/TEST_v0.2.47.md) | [release state](docs/RELEASE.md). LootLab is deployed with preserved saved tuning. C171 capacity warnings were corrected in 0.2.47.2; rendered pack/tooltip acceptance is pending. Packed-turret weight reduction remains abandoned under C170.

One Workshop product with independent **OMH: Turrets** and **OMH: Traps** entries. Enable either or both in fresh worlds; neither requires the other. [Current phases and checkpoint status](docs/ROADMAP.md#current-checkpoint-status-and-next-work) is the canonical next-work index: ongoing R1C3 performance, R2C4 concertina acceptance, and the independent Phase 3 head-selection/module-contract tracks. [Unique head development](docs/TURRET_HEAD_PROPOSALS.md#c193-three-head-development-scope-2026-10-12) covers Ballista, Rotary Blades and Rotary Bat, implemented in0.2.49 with automated/native proof and rendered acceptance pending. The project adds maintainable defensive equipment to Project Zomboid Build 42, with optional Horde Night, Trait Shop, and Cure Defense integrations. Recheck the installed game build before implementing any engine-dependent behavior.

C81 adds [offensive module and battery-endurance checkpoints](docs/checkpoints/R3_OFFENSIVE_MODULES.md) to the plan: stackable effects including Splitter and Fragment Module, with long battery life and explicit head compatibility. Behavior proposals and unresolved tuning remain separate from owner-confirmed direction; no new module or head is implemented by this planning update.

[R3C8: improvised components and compact expansion](docs/checkpoints/R3C8_IMPROVISED_EXPANSION.md) records the accepted **2/4/8/12/16** module-slot progression and the craftable Makeshift kit, with a compact Manage grid independent of upgrade groups. C104 settles the remaining tuning/recipes and implements that progression in 0.2.34; saved Sandbox values remain unchanged.

## Start here

| Document | Purpose |
| --- | --- |
| [Planning](docs/PLANNING.md) | Current approved/proposed work and the active GitHub branch/PR |
| [Decisions](docs/DECISIONS.md) | Owner-confirmed requirements, proposals, and unanswered questions |
| [Design](docs/DESIGN.md) | Gameplay, signals, ownership, and operating behavior |
| [Content and balance](docs/CONTENT_AND_BALANCE.md) | Device roster, progression, balance targets, and deferred ideas |
| [Sandbox options](docs/SANDBOX_OPTIONS_SPEC.md) | One edition's feature controls and proposed defaults |
| [Architecture](docs/ARCHITECTURE.md) | Runtime responsibilities, persistence, networking, and performance |
| [Integrations](docs/INTEGRATIONS.md) | Horde scoring, shared XP, offline rewards, and final-phase simulation |
| [Roadmap](docs/ROADMAP.md) | Phases, checkpoint dependencies, deliverables, and acceptance gates |
| [Validation](docs/VALIDATION.md) | Smallest useful checks, multiplayer coverage, and evidence policy |
| [Release state](docs/RELEASE.md) | Packaging, publication baseline, and what has actually shipped |
| [First implementation checkpoint](docs/checkpoints/P1C1_FOUNDATION.md) | Historical foundation scope; current next work is in the revised roadmap |
| [Artwork brief](art/README.md) | Required visual/audio states and source-asset tracking |

## Current direction

- Final art will be sourced by the owner without AI. The [white cube placeholder](art/placeholders/cube_turret/README.md) is only for mechanics/rotation testing and establishes no aesthetic direction.
- Potato turret: cheap, quiet, farmable ammunition; new defaults of 35 damage (0.35 native HP), magazine 1, overlapping two-second reload/cooldown, higher knockdown chance, and a satisfying potato pop with 25-percent splash damage within 1.5 tiles, capped at three secondary targets. Default ammo capacity is 100; the earlier 3-5 hit target and Hard-night budget are historical calibration, not guarantees at this lower damage. Player balance acceptance remains pending.
- Implemented traps: Spike Barrier, 1x2 Bed Spikes and one-tile Barbed Panel. Bed Spikes use player brush-through movement, 20/50 fall damage and six wear per fresh fall. Barbed Panel supports ordinary single-panel doors, window frames, walls and fences. C106 records tentative owner passes and a zombie-trip overshoot failure; 0.2.35 still failed rendered acceptance; 0.2.36 replaces the zombie clip for the [focused test](docs/TEST_v0.2.36.md). Spike Barriers retain front/end collision, open rear and directional-risk vaulting. Concertina becomes a linked 1x2 trap with shared 50 HP and whole-trap service in [0.2.39](docs/PATCH_v0.2.39.md); R2C4 rendered owner acceptance remains pending.
- Crafting produces portable defenses; inventory placement reuses native rotation and validation, with Building preferring a carried item and falling back to its original recipe. Five-barrier bundles retain 67% reduced encumbrance.
- Buttons emit pulses; pressure plates and beam sensors stay ON while occupied or obstructed. Devices own their firing/reset cadence.
- Poke Floor is the retractable spike device; there is no separate duplicate spike-strip feature.
- A control unit changes targeting for one compatible smart defense or all compatible linked defenses, including players, other factions, or no one. Passive objects ignore these filters. Persistent device ownership can determine the reward faction without a base boundary.
- Defense kills create one reduced Trait Shop XP pool divided across faction members. Including offline members is toggleable and defaults ON. The exact reward rate and eligibility details remain unresolved.
- Target Horde scoring follows Trait Shop's modifier approach. An 80% reduction is the current proposed starting value, not an implemented or validated official rule.
- Cure defense simulation is the final phase and is not a requirement for the first playable release.

Confirmed facts live in [Decisions](docs/DECISIONS.md). A draft recommendation elsewhere does not turn into owner approval through repetition.

## Folder policy

`docs/` contains specifications and evidence; `docs/checkpoints/` contains checkpoint briefs and the reusable record template; `art/` contains the asset brief and will hold source artwork; `tools/` documents planned local validation and release tooling.

Canonical runtime/assets live in `Source/`. `tools/build_packages.py` generates `Contents/mods/OneMoreHorde_Traps/` and `Contents/mods/OneMoreHorde_Turrets/`, each with `42.20/` and `common/`. Edit Source and rebuild; do not edit generated copies. Identical shared helper paths execute once when both are enabled. Current native validation targets stock B42.21.0. Isolated probes use stock-first classes because of an old optimizer override; the owner has demonstrated normal 42.21 client startup. Test-only Sandbox controls default OFF. Potato/firearm firing and barrier retaliation are SP-only. Constructed turrets consume real potatoes and power; old developer-menu prototypes remain separate diagnostic objects. Core automatic fire and four module effects are implemented in 0.2.14; stat-module effects are implemented in 0.2.17; rewards remain deferred. The barrier marker route has normal-speed SP damage evidence and is not certified lossless under skipped/fast-forwarded animation updates.

The [combined owner test](docs/checkpoints/R1_PACKAGE_SPLIT.md#combined-owner-test-for-the-next-playable-build) is closed by owner waiver; older patch tests are historical, not additional rounds. Barrier recipes and servicing remain unchanged; basic/reinforced loose weights are 4/5. Turret recipes, tools, XP and power defaults remain documented in their implementation checkpoints. Use [OMH.cmd](OMH.cmd) for local installation/readiness checks, development mirroring and log capture. See the [naming and release process](docs/RELEASE_TOOLS.md). Workshop actions remain unavailable until separately configured.
