# OMH: Turrets & Traps

Project foundation created 2026-09-25. **Current installed 0.2.30:** [Bed Spikes and performance diagnostics](docs/PATCH_v0.2.30.md), retaining fully independent Traps and Turrets. Installation evidence is in [RELEASE.md](docs/RELEASE.md). The [focused six-step test](docs/TEST_v0.2.30.md) covers new beds and the heavy turret workload; audio stall elimination remains unproven. The owner-waived 0.2.29 regression round stays waived. Native checks do not certify client rendering or frame smoothness.

One Workshop product with independent **OMH: Turrets** and **OMH: Traps** entries. Enable either or both in fresh worlds; neither requires the other. [Revised phases and split todo](docs/ROADMAP.md) and [unique head proposals](docs/TURRET_HEAD_PROPOSALS.md) track the next work. The project adds maintainable defensive equipment to Project Zomboid Build 42, with optional Horde Night, Trait Shop, and Cure Defense integrations. Recheck the installed game build before implementing any engine-dependent behavior.

C81 adds [offensive module and battery-endurance checkpoints](docs/checkpoints/R3_OFFENSIVE_MODULES.md) to the plan: stackable effects including Splitter and Fragment Module, with long battery life and explicit head compatibility. Behavior proposals and unresolved tuning remain separate from owner-confirmed direction; no new module or head is implemented by this planning update.

[R3C8: improvised components and compact expansion](docs/checkpoints/R3C8_IMPROVISED_EXPANSION.md) records the accepted **2/4/8/12/16** module-slot progression and the craftable Improvised kit, with a compact Manage grid independent of upgrade groups. Current installed capacities remain unchanged.

## Start here

| Document | Purpose |
| --- | --- |
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
- Initial defense concepts: Bed Spikes, Spike Barrier/cheval de frise, concertina, and barbed barricades. Approved Bed Spikes use a 1x2 footprint and player brush-through movement, with 20/50 fall damage; construction/service defaults are approved under C94. The [0.2.30 content/performance patch](docs/PATCH_v0.2.30.md) implements Bed Spikes with six durability wear per fresh fall; [focused testing](docs/TEST_v0.2.30.md) remains pending. Spike Barriers retain their front/end collision, open rear and directional-risk vaulting.
- Native construction is the gameplay placement flow. P2C1b implements individual barrier items; P2C1c adds five-barrier bundles weighing 33% of their combined loose weight (67% reduction). Portable items are implemented in 0.2.1; five-item packs are implemented in 0.2.2.
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

The [combined owner test](docs/checkpoints/R1_PACKAGE_SPLIT.md#combined-owner-test-for-the-next-playable-build) is closed by owner waiver; older patch tests are historical, not additional rounds. Barrier recipes and servicing remain unchanged; basic/reinforced loose weights are 4/5. Turret recipes, tools, XP and power defaults remain documented in their implementation checkpoints. Use [OMH.cmd](OMH.cmd) for local installation/readiness checks and log capture. See the [Horde Night-aligned naming and release process](docs/RELEASE_TOOLS.md). GitHub/Workshop actions remain unavailable until configured.
