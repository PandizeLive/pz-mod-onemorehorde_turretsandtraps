# Project working agreement

Read README.md, docs/DECISIONS.md, and docs/ROADMAP.md before project changes. The workspace AGENTS.md also applies.

- This is OMH: Turrets & Traps, a single edition controlled through Sandbox options. Do not recreate the abandoned Survival/Engineering/Siege edition plan.
- Preserve the distinction between owner-confirmed requirements, proposed defaults, verified implementation, and release evidence. Ask only about decisions that materially affect the current work; continue independent authorized work.
- The 2026-09-25 authorization covers documentation, the cube-only technical placeholder, P1C1, and the owner's subsequent request to batch further checkpoints before player testing. P1C2-P1C4 prototype work is authorized; acceptance still requires evidence. Preserve the art restriction. Sibling-project changes and external publication remain outside scope.
- Use the PZ modding skills and current installed game evidence for implementation. Historical decompiled references are discovery aids, not proof of current compatibility.
- On 2026-09-26 the owner approved beginning Phase 2, including scheduling individual barrier items and five-item bundles with 67% reduced encumbrance. Implement in small checkpoints and verify each; this does not waive outstanding Phase 1 tests or authorize sibling changes/publication.
- Before major implementation, recommend the lowest sufficient reasoning effort and estimate the work. Follow the owner's workspace timing preferences. Keep checkpoints small and independently verifiable.
- Preserve one shared defense XP pool. Include Offline Members is toggleable and defaults ON. Do not silently substitute connected-only rewards or a full pool per member.
- Preserve potato impact pop and tiny damaging splash. Direct-hit knockdown and splash crowd-control restrictions remain separately tracked balance decisions.
- Passive objects without smarts ignore controller target filters. Players automatically jump over bed spikes; the Spike Barrier blocks walking into it. The owner now requests player vaulting with a 20% front-side scratch chance and a safe rear; runtime vaulting remains blocked until its native collision prototype passes. Prove traversal in the installed game before claiming it works.
- Cure defense simulation is last. Offline reward eligibility does not imply simulated combat in unloaded areas or while the server is stopped.
- Keep Horde Night's event/score authority and Trait Shop's progression authority in their respective projects. New integration contracts must be explicit and verified; do not invent API capabilities.
- Local tests must establish the exact loaded package version. Supply complete owner tests in 4-8 short numbered steps and inspect logs after the test.
- Do not publish, push, modify public listings, or initialize a remote project without authorization. Keep Workshop upload evidence per item and follow the workspace cumulative-changelog policy.
- End handoffs with Test now, Wait for a patch, or Decision needed, accurately reflecting whether a playable build exists.

## Rules
- [2026-09-26] Review crafting ingredients, required tools/skills and crafting XP with the owner before implementing recipe changes. The owner objected to selecting the v0.2.0 temporary recipe without consultation. General Phase 2 approval does not settle those recipe choices.
- [2026-09-25] For OMH: Turrets & Traps, the owner will source final art without AI. Do not generate concept art, stylistic designs, textures, icons or final visual assets, or otherwise direct the art. The explicitly authorized temporary white cube-only mechanical placeholder is an exception; its proportions and appearance are not design direction.
- [2026-09-25] The owner additionally authorized temporary developer textures with white direction arrows and distinct object identifiers to make testing readable. These functional markers are not final artwork or aesthetic direction.

## Release conventions (owner direction, 2026-09-26)

- Follow docs/RELEASE_TOOLS.md, aligned with the reviewed Horde Night process. Use OMH: Turrets & Traps as the public name; preserve the internal mod ID and save keys.
- Use numeric three-field feature versions and fourth-field corrective versions; no checkpoint suffix in modversion. Keep historical build identifiers unchanged in evidence.
- Use only the root OMH.cmd release menu and stable tools. Commit complete source on a non-main local branch and create an annotated test/v<version> rollback tag before installing. Do not invent a remote, Workshop ID or uploader.
- Spike Barriers are 1x2, two tiles across and one deep. Front and side ends retaliate; the rear is safe. Preserve both-tile identity, condition, rotation and retirement.

- [2026-09-27] Owner approved combining barrier pickup, repair and five-item bundles. Pickup returns a full-condition item; free Repair and pickup each take ten seconds and interrupt on movement. This supersedes condition-preserving basic-barrier recovery. No service/packing/redeployment XP. Keep vaulting pending native proof, and final damaged artwork owner-sourced.

- [2026-09-27] Owner selected fence-style collision for P2C2-vault, preserving the 1x2 build footprint. New construction/deployment uses edge collision; older full-square barriers are recovered/redeployed for conversion. Combine its owner test with the still-unaccepted 0.2.3 repair. Native proof does not replace rendered SP acceptance.

- [2026-09-27] C35-C38 approve native Interact/run/sprint inputs, low-fence animation/native trips, zombie blocking, contact-time scratch denominator 0-50 (default 5; 0 off), corner joins, collision debugging, safe service approaches and short Repair wording. Repair remains tool-free. Always ground engine behavior in current installed vanilla code and the PZ skills.
- [2026-09-27] Proactively expose useful Sandbox controls as defenses/features are implemented. Separate General, each defense and Debug categories. Favor the shortest useful tooltip. No inert speculative settings.
- [2026-09-27] C40 supersedes C39: owner approved a shared native outline with front edges and exposed end caps; the rear is open for players and zombies. Only outermost ends of connected runs are capped. Perpendicular front edges may meet without internal dividers; actual gaps remain open. Removal/destruction must expose surviving end caps. Each 1x2 barrier retains independent identity and durability. No centered actor-specific collision, Java dependency, shared passability toggles or No Clip. See docs/PHASE_2_CHECKPOINT_2_OUTLINE.md.
