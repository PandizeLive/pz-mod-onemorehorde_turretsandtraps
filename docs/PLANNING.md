# Planning

Updated 2026-10-10 under C119. This is the shared entry point for planning in the local PC chat and **OMH: Turrets & Traps - Planning**. Detailed contracts and approval history remain in the linked records; this page indexes them rather than replacing them.

## Read the current branch

Current unmerged work is on **codex/performance-barbed-audit**, [draft PR #1](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/pull/1), targeting dev. [Open this Planning page on the active branch](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/blob/codex/performance-barbed-audit/docs/PLANNING.md). The **installed 0.2.38 build** implements the approved bundle. Native/automated checks and tagged installation verify; [release state](RELEASE.md) records the evidence. Owner/rendered acceptance remains pending.

Fetch the remote and check open development/planning PRs before using dev alone as the current state. Read the active branch's AGENTS.md, this page and [CURRENT_STATUS.md](CURRENT_STATUS.md). Record which branch/commit was inspected. A chat's older answer or an old Cloud checkout is not a current checkpoint. Preserve unmerged work and reconcile incoming plans; do not reset, force-push or merge automatically.

## Current combined update: 0.2.38 installed and verified; owner test pending

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

[ROADMAP.md](ROADMAP.md#current-checkpoint-status-and-next-work) remains the canonical phase order. R1C3 performance continues; unselected head candidates and the R3C4 offensive-module/battery contract remain deferred. Do not reclassify them as approved by "All approved" for the current bundle. Keep rejected/superseded options in decision history, out of the current implementation queue.

## Required planning handoff

For every substantive project planning discussion, correction or approval, including a documentation-only turn:

1. Reconcile the existing checkpoint contract and append approval/proposal provenance in DECISIONS.md. Separate the owner's words from assistant recommendations and technical findings.
2. Update this page's affected state and link, plus CURRENT_STATUS.md and ROADMAP.md when their scope/order changes. Keep unchanged history intact.
3. Commit and mirror before handoff under C108/C119. Local PC uses root OMH.cmd -Action Mirror. Cloud follows the documented planning branch/PR workflow and reports any unavailable mirror prerequisite rather than claiming a push.
4. Keep a visible Planning link in the development/planning PR description. Verify the remote commit; a local edit/commit alone is not synchronized. Report any remaining failure plainly.
5. Move states only with evidence: Proposed -> Approved -> Implemented -> Verified. Record automated verification separately from owner acceptance; Published requires the existing release evidence. Include affected version findings when actual tests occur.

Either chat can originate plans. The named Planning chat is optional; GitHub is the shared handoff and does not depend on automatic chat-history transfer. This protocol neither schedules background polling nor sends messages to another chat. A future chat must fetch/read the current checkpoint before advising.
