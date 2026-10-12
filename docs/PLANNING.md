# Planning

**C160 / 0.2.44 implemented and automatically verified.** Manage sections/rarity/bars, reload-aware battery feedback, Once Each and Synergy/Martyrdom/Tack are complete under the [approved contract](checkpoints/R3_MANAGE_RARITY_SYNERGY.md). Bounded admission precedes resource commitment; terminal effects cannot recurse. [Patch](PATCH_v0.2.44.md) | [one six-step test](TEST_v0.2.44.md).

15,931 Kahlua assertions, native write/read, all three package selections and 51 supported Firearms guns pass. LootLab matches 28 modules / 193 entries; 76 API/page tests and browser model/import checks pass. These checks do not certify rendered gameplay or client frame smoothness. The prior 676-ms gap remains unassigned. Held 0.2.43 checks join this test; no old round is newly marked passed.

Updated 2026-10-11 under C119/C133. This is the shared entry point for planning in the local PC chat and **OMH: Turrets & Traps - Planning**. Detailed contracts and approval history remain in the linked records; this page indexes them rather than replacing them.

## Read the current branch

Current unmerged work is on **codex/performance-barbed-audit**, [draft PR #1](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/pull/1), targeting dev. [Open Planning on that branch](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/blob/codex/performance-barbed-audit/docs/PLANNING.md). **0.2.44 / C160 is implemented and automatically verified**; [release evidence](RELEASE.md) records tagged installation status. [Combined owner test](TEST_v0.2.44.md) remains pending. Earlier entries below preserve history and do not replace this handoff.

Fetch the remote and check open development/planning PRs before using dev alone as the current state. Read the active branch's AGENTS.md, this page and [CURRENT_STATUS.md](CURRENT_STATUS.md). Record which branch/commit was inspected. A chat's older answer or an old Cloud checkout is not a current checkpoint. Preserve unmerged work and reconcile incoming plans; do not reset, force-push or merge automatically.

## Previous combined update: 0.2.38 installed; provisional function report, lag reproduced

C120 explicitly approves patching the whole current plan on 2026-10-10: [C119](DECISIONS.md#c119-approved-combined-plan-and-mandatory-github-planning-handoff-2026-10-10). Exact behavior, recipes and evidence limits: [combined checkpoint contract](checkpoints/R2C4_CONCERTINA.md).

| Change | State | Contract / remaining technical work |
| --- | --- | --- |
| Concertina Wire | Implemented; automated checks pass | One-tile independent coil and approved recipe/durability/service defaults |
| Shared barbed-contact slowdown | Implemented; native delta proof passed | Half speed only in contact, no stacking/stale speed restoration; include Horde Night zombies |
| Barbed-contact player injuries | Implemented; automated checks pass | Bed Spikes walking/running/sprint/fresh-landing rules for wire and panels |
| Independent Bed Spikes durability and servicing | Implemented; automated checks pass | Two independent tiles, per-tile wear/breakage, pair placement and honest single-tile pickup |
| Sandbox header organization | Implemented; automated checks pass | Correct missing starter mappings, readable headings and semantic order; preserve saved IDs/values |
| Improvised/Makeshift naming | Implemented; automated checks pass | Alternate head recipe versus actual starter-item tier; identical standard head output |
| Redundant complete-turret recipe removal | Implemented; automated checks pass | Keep base/head crafting and manual assembly |

No unresolved owner choice remains for this approved bundle. The exposed native displacement path passes real-object probes; rendered movement and interaction with other movement hooks remain acceptance checks. [Patch and test handoff](PATCH_v0.2.38.md) distinguish native evidence from owner acceptance. Existing performance, rendered collapse and audio acceptance remain open in [current status](CURRENT_STATUS.md); none is claimed solved by this plan.

## Proposals and deferred work

[ROADMAP.md](ROADMAP.md#current-checkpoint-status-and-next-work) remains the canonical phase order. R1C3 performance continues; unselected head candidates remain deferred; C125 selects the R3C4 offensive-module/battery contract for active discussion. Do not reclassify them as approved by "All approved" for the current bundle. Keep rejected/superseded options in decision history, out of the current implementation queue.

## Required planning handoff

For every substantive project planning discussion, correction or approval, including a documentation-only turn:

1. Reconcile the existing checkpoint contract and append approval/proposal provenance in DECISIONS.md. Separate the owner's words from assistant recommendations and technical findings.
2. Update this page's affected state and link, plus CURRENT_STATUS.md and ROADMAP.md when their scope/order changes. Keep unchanged history intact.
3. Commit and mirror before handoff under C108/C119. Local PC uses root OMH.cmd -Action Mirror. Cloud follows the documented planning branch/PR workflow and reports any unavailable mirror prerequisite rather than claiming a push.
4. Keep a visible Planning link in the development/planning PR description. Verify the remote commit; a local edit/commit alone is not synchronized. Report any remaining failure plainly.
5. Move states only with evidence: Proposed -> Approved -> Implemented -> Verified. Record automated verification separately from owner acceptance; Published requires the existing release evidence. Include affected version findings when actual tests occur.

Either chat can originate plans. The named Planning chat is optional; GitHub is the shared handoff and does not depend on automatic chat-history transfer. This protocol neither schedules background polling nor sends messages to another chat. A future chat must fetch/read the current checkpoint before advising.

## Latest owner test and proposed follow-up (C121, 2026-10-10)

0.2.38 generally functions according to the owner, but mixed Bed Spikes/Concertina/turret play still lags. [Versioned findings](TEST_v0.2.38.md#owner-findings-and-console-review-2026-10-10) confirm 1,077-ms update gaps and 674-ms elapsed runtime-pitch calls; trap and reload costs remain unmeasured. General function is provisional, not automatic acceptance of every test item.

**Superseded by C122, never implemented:** remove per-play pitch randomization in both turret audio paths, preserving clips/variants/volume/hearing, and add gated aggregate reload/trap timings. Less pitch variation is the explicit tradeoff. No gameplay/source/package changes are made in this report. R1C3 remains open; Phase 3 decisions are still deferred. The subsequent C122 instruction below replaces this proposal.

## Previous corrective update: C122 / 0.2.38.1 installed and verified

Owner requests preserving pitch variation and optimizing again. The implementation uses native sound-script clip pitch and random clip selection at all original 101 pitch values, avoiding FMODSoundEmitter.setPitch. Existing clips/weights/volume/hearing and native event-authored variation remain. Concertina skips adjacent unoccupied coils before object resolution, and aggregate reload/trap timing fills diagnostic gaps. No new content or balance change.

[Patch](PATCH_v0.2.38.1.md) | [Four-step performance comparison and verification](TEST_v0.2.38.1.md) | [R1C3 checkpoint](checkpoints/R1C3_PERFORMANCE_AUDIT_20261007.md). Automated/native checks, tagged installation and source/package/archive/backup hashes pass. Native tests establish parser/queued playback behavior; audible acceptance remains unconfirmed; C123 below records the positive mixed-workload lag result with residual-gap limits. This supersedes C121's proposed loss of pitch variation and does not reopen Phase 3 decisions.

## Latest owner result: C123 / 0.2.38.1

Handoff correction: the current owner lag test is complete and accepted for the reported issue; no further play is required. Broader R1C3 work remains separate. Next-patch selection is still deferred.

Owner reports noticeable lag apparently gone. [Console comparison](TEST_v0.2.38.1.md#owner-result-and-console-comparison-2026-10-10) supports the improvement: audio max 3 ms versus 674 ms; trap callbacks max 2 ms. Residual update gaps up to 368 ms and a smaller firing sample prevent a universal performance claim. No repeat stress checklist or new patch is requested. Normal play can continue; audio quality and unmentioned checks remain unconfirmed. R1C3 retains residual-gap/large-load/authority scope, and deferred content decisions stay deferred.

Owner follow-up: "Yea seems fine." Satisfaction with the current lag improvement is confirmed; no new work or separate test is requested. Existing console evidence and remaining scope are unchanged.


## Historical decision: next checkpoint (C124)

No next patch is selected or underway. The 0.2.38.1 lag test is complete. Recommend R3C4 offensive-module contract and battery baseline, followed by R3C5 Splitter/Fragment, R3C6 Piercing/Initial Blow/Execute/Impact, then R3C7 combined balance/endurance checks. R3C1 new-head selection and R3C2 prototype are an independent alternative. No change to phase order or implementation authorization. Existing unconfirmed individual content checks do not require another test before this planning discussion. See the corrected [checkpoint table](ROADMAP.md#current-checkpoint-status-and-next-work). Inspected active branch at 378dbac and fetched origin; draft PR #1 is the only open PR and targets dev.


## Active checkpoint: R3C4 module contract and battery baseline (C125)

Owner selected Modules. [Contract and current choices](checkpoints/R3_OFFENSIVE_MODULES.md#c125-module-track-selected-first-contract-choices-2026-10-10) now owns active planning: Splitter ammunition/stack cap, Fragment stacking and bounded propagation, followed by concrete compatibility/range/power rules. R3C5 Splitter/Fragment is the first implementation stage after settlement and native proof. R3C6 conditional/penetrating effects and R3C7 combined acceptance follow; no new head is selected. No gameplay implementation or numerical proposal is approved by this track choice. Inspected active branch at 4dc3836 and fetched origin before this update.


C126: confirmed slot-limited Splitter and fixed-five Fragment with capped damage stacking. Discussing a Magazine Module for loaded capacity (separate from reserve expansion); Splitter extra-ammo option remains open. Proposed +2 rounds/module and firearm feed-extension approach require owner settlement/native proof. [Detailed evidence and unresolved interactions](checkpoints/R3_OFFENSIVE_MODULES.md#c126-selected-stacking-and-proposed-magazine-module-2026-10-10). Inspected fe67208 and fetched origin. No code/test/version changes.


C127 supersedes C126's flat +2 magazine suggestion: owner requests percentage growth and rounding up, suggesting linear 25% per module. Working formula: ceil(base capacity * (1 + 0.25 * count)). Base-1 capacity remains two for modules 1-4 and reaches three at five; this affects paid Splitter slot efficiency. [Current contract](checkpoints/R3_OFFENSIVE_MODULES.md#c127-linear-percentage-magazine-growth-and-final-rounding-2026-10-10). No patch approval; Splitter ammo/leftover-round policy remains open. Inspected 9b36cb8 and fetched origin.


C128 supersedes C127 plateaus: owner confirms minimum +1 ready round per module. At linear 25%, capacity = ceil(base + count * max(1, base * 0.25)). Base 1 now progresses 1/2/3/4/5 with 0/1/2/3/4 modules. Requested examples are in the checkpoint; remaining R3C4 choices unchanged. Inspected 3368a34 and fetched origin.


C129: confirmed magazine scaling is now linear 35%, minimum +1/module, rounded once. One-round Splitter ammo exception requested; effective one-round capacity versus last loaded round remains a material clarification. Recommend effective capacity one to avoid intentional underloading for free side shots; no interpretation is approved yet. Active checkpoint remains R3C4. Inspected 9ba8df8 and fetched origin.


C130 confirms C129 option B: any last loaded round permits the full Splitter volley, consumes that round, and waives extra-round charges regardless of capacity. Deliberate single-round loading is accepted. Next ammo decision: when two or more rounds remain but cannot pay the full volley, recommend full volley consuming all remaining rounds; alternative is affordable projectile count with the special one-round exception. Neither generalized rule is approved yet. R3C4 stays active; inspected 77e0f5d and fetched origin.


C131 settles insufficient ammo: full Splitter volley, consume min(ready rounds, normal volley cost), require at least one round; no direct reserve charge for the shortfall. This includes C130's final-round exception. Magazine growth is 35% linear/minimum +1/final ceiling. Remaining R3C4 choices: Fragment damage increment/cap, range/coverage/propagation, compatibility and power/endurance. No implementation or new owner test. Inspected a773151 and fetched origin.


C132 adds approved 1x2 Concertina conversion to upcoming patch scope: one item places a linked pair with shared HP and whole-trap service/breakage, matching Spike Barrier identity rather than independent Bed Spikes. Existing recipe, weight 2, total HP 50 and contact behavior retained. [Contract](checkpoints/R2C4_CONCERTINA.md#c132-one-paired-1x2-concertina-trap-for-the-upcoming-patch-2026-10-11). C133 approves implementation, now in 0.2.39; native verification/install is tracked in TEST_v0.2.39.md. Module contract choices remain open. C131 full-volley ammo rule is already confirmed and mirrored.


## Previous discussion: C134 Magazine + Splitter

Owner requests adding Magazine and checking Splitter, then asks to discuss module rules this turn before implementation. Recommend Magazine + Splitter first; Fragment remains optional and R3C6 effects remain later. The [C134 choices](checkpoints/R3_OFFENSIVE_MODULES.md#c134-current-module-discussion-and-choices-2026-10-11) cover scope, safe capacity removal, side-shot coverage/effects and power. Existing C129-C131 growth/ammo choices stay confirmed. New defaults are recommendations, not approvals. Inspected fb51d09 and fetched origin; no source/version/install/test changes. Installed 0.2.39 remains available; its owner test can join the module patch.


## Current decisions: C135

Owner selects Magazine + Splitter + Fragment; surplus loaded ammo returns reserve -> player inventory -> floor. Splitter coverage may leave the targeting cone with a 180-degree fan limit, children are direct-only, and power adds 25% of base per copy; Magazine has no surcharge. These replace the corresponding C134 proposals. [Remaining Fragment baseline](checkpoints/R3_OFFENSIVE_MODULES.md#c135-selected-module-rules-and-remaining-fragment-baseline-2026-10-11) proposes damage growth/cap, four-tile radius, primary-only single burst, distinct victims and additive power. New Fragment tuning remains unapproved. Native inventory/floor fallback source is verified; complete capacity lifecycle still requires runtime proof. Installed 0.2.39 is unchanged; combine its held owner check with the eventual module patch.


## C136 - approved module patch (2026-10-11)

Owner: "Approved." This approves the complete C135 Fragment baseline alongside Magazine and Splitter, and authorizes implementation/verification/install. No further gameplay decision is required for this slice. [0.2.40 patch](PATCH_v0.2.40.md) implements the selected rules; automated/native/package verification and tagged installation pass. [Combined test/evidence](TEST_v0.2.40.md) includes the held paired-Concertina check. R3C4 contract is settled for this slice; R3C5 is implemented pending verification and rendered acceptance. R3C6 stays next for later discussion; R3C7 combined balance/endurance remains pending. Earlier open-choice paragraphs are historical and superseded by this approval.
