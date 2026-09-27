# OMH: Turrets & Traps

Project foundation created 2026-09-25. **0.2.6 implements the approved connected barrier outline**: front edges, exposed outer end caps and an open rear. It includes the overlay and native-input/contact corrections from the uninstalled 0.2.5.1 draft. [Checkpoint and owner test](docs/PHASE_2_CHECKPOINT_2_OUTLINE.md). 1,433 Kahlua assertions and native startup/write/read checks pass; rendered single-player acceptance remains pending. No Workshop release exists.

One edition with a Sandbox toggle menu. The planned mod adds maintainable defensive equipment to Project Zomboid Build 42, with optional Horde Night, Trait Shop, and Cure Defense integrations. Recheck the installed game build before implementing any engine-dependent behavior.

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
| [First implementation checkpoint](docs/checkpoints/P1C1_FOUNDATION.md) | Concrete scope for the next development step |
| [Artwork brief](art/README.md) | Required visual/audio states and source-asset tracking |

## Current direction

- Final art will be sourced by the owner without AI. The [white cube placeholder](art/placeholders/cube_turret/README.md) is only for mechanics/rotation testing and establishes no aesthetic direction.
- Potato turret: cheap, quiet, farmable ammunition; one shot per second, a 3-5 direct-hit reference kill target, higher knockdown chance, and a satisfying potato pop with tiny splash damage. Current fixed 0.50 HP damage targets 4-5 hits against Normal toughness; player balance acceptance remains pending.
- Initial defense concepts: bed spikes/punji, Spike Barrier/cheval de frise, concertina, and barbed barricades. Players automatically jump over bed spikes; new Spike Barriers block their front and exposed ends, leave the rear open, and provide directional-risk player vaulting. Exact recipes and several behavior details remain proposals.
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

The test package is `Contents/mods/OneMoreHorde_TurretsAndTraps/42.20/`, with an accompanying `common/` directory. It targets the locally verified B42.20.4 installation. Test-only Sandbox controls default OFF. Potato firing and barrier retaliation are SP-only. Free diagnostic rounds remain; real inventory servicing, automatic fire and rewards are not implemented. The barrier marker route has normal-speed SP damage evidence and is not certified lossless under skipped/fast-forwarded animation updates.

**0.2.6 is the current SP candidate**; the failed 0.2.5 test remains historical. Follow the [combined outline test](docs/PHASE_2_CHECKPOINT_2_OUTLINE.md#owner-test). Build a Spike Barrier with Carpentry 1, a retained sharp knife/cleaver, four planks/basic crafted wooden spears in any mix, and four binding units (ripped sheets, dirty ripped sheets or twine uses). Raw-material construction or portable crafting awards 10 base Carpentry XP. A portable barrier weighs a provisional 6 encumbrance. Deploy Spike Barrier consumes one finished item and awards no XP. Basic barriers default to 100 shared durability and 10 damage, both configurable in Sandbox; the approved Carpentry 3 reinforced upgrade is scheduled separately. Master and Spike Barrier toggles default ON; debug controls are unnecessary for construction or retaliation of these built barriers. SP only; player cursor/material/traversal acceptance is pending. The [0.1.6 partial SP pass](docs/TEST_v0.1.6.md) remains historical evidence. Use [OMH.cmd](OMH.cmd) for local install/checks and log capture. See the [Horde Night-aligned naming and release process](docs/RELEASE_TOOLS.md). GitHub/Workshop actions remain unavailable until configured. [Modular turret proposals](docs/MODULAR_TURRETS.md) remain separate; no component inventory exists yet.
