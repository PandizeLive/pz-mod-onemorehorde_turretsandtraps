# 0.2.36 focused owner test

Historical checklist: superseded by [TEST_v0.2.36.1.md](TEST_v0.2.36.1.md) under C112; no pending checks are inferred passed.

Status: partial owner feedback received on 2026-10-09; Turrets grouping is unsuitable. Remaining gameplay checks are pending. Test normal costs with Build Cheat off; use the existing fresh test world. Do not repeat the old full regression round.

1. Restart and confirm **0.2.36** in the developer menu. In crafting **list view**, open OMH: Traps / OMH: Turrets: expand/collapse **Normal, Reinforced, Packed**. Building should have Normal/Reinforced, with no Packed group.
2. From Building, place two carried traps consecutively without reopening Place Trap; rotate between them. With materials for one more, click the next location to craft/place it. Right-click to cancel. Repeat consecutive placement briefly with Barbed Panels and a loaded turret; its contents must survive.
3. Lure a few zombies over Bed Spikes. They should **collapse forward locally**, take fall damage and get back up if alive. Listen for trip/landing/impact sounds, without repeated hits or sound while lying down.
4. Walk/run/sprint through the bed once: brush-through and player tripping should remain unchanged. Report any failure, then say **test complete** so console.txt can be captured and checked against the loaded version.

Automated: 3,880 assertions, native save/reload and Traps-only/Turrets-only/both startup pass. For evidence see [release state](RELEASE.md) and [patch scope](PATCH_v0.2.36.md). Rendered/audio acceptance is not established by automated passes. Any owner findings must be recorded here and mirrored to GitHub under C108.

## Owner grouping feedback and console review, 2026-10-09

Owner reports that OMH: Turrets contains a Normal collapsible group and questions its usefulness. This is a semantic organization failure even though the group implementation passed automated checks. Proposed correction: root Turret Base/complete turret recipes, Heads and Modules groups (including expansion kits), trap tier/pack groups retained, and no redundant turret group in Building. Implementation approval is pending; C111 authorizes durable review instructions and documentation only. No completed test or unmentioned passes inferred.

Captured with root OMH.cmd: `diagnostics/captures/20261009-204321-3664/console.txt`, SHA-256 `9a1f7c1eb8c0afcea7a8a02fddeaf874da5dc894402f90f295080d883b0b8edf`. Its packages-ready marker confirms 0.2.36, both entries, game 42.21. After that marker there are five ERROR lines from native CellLoader for missing vegetation_groundcover_01 tiles (22, 18, 23, 19, 21); no Exception/STACK TRACE matches. This is not an error-free console or proof of unrelated gameplay acceptance. No evidence here attributes those tile messages to this patch. [Structured findings](../diagnostics/v0.2.36/owner-findings-20261009.json).

C112 follow-up: owner subsequently approved the organization correction and requested a cross-system review. Implemented as 0.2.36.1; use its replacement checklist. Original findings and console evidence above remain unchanged.
