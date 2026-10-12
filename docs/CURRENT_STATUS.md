# Current development and planning handoff

Updated 2026-10-12. Read [AGENTS](../AGENTS.md) and [Planning](PLANNING.md).

**C177 / 0.2.47 implemented; final installation checks in progress.** Module Packs contain three independently weighted rewards, including expansion kits and duplicates. Packs supplement loose modules at container weight 1.0 and a separately configurable **15% per zombie body**, including turret kills. Optional default-on four-second reveal with Skip; two-second opening. All 29 owner-exported weights are the new defaults. Battery estimates switch to hours at 60 in-game minutes; inventory module descriptions bypass the native translation-key formatting failure.

[Patch](PATCH_v0.2.47.md) | [Five-step test](TEST_v0.2.47.md) | [Approved contract](checkpoints/R3_MODULE_PACK.md#c177-15-percent-body-rate-and-implementation) | [Release evidence](RELEASE.md).

Existing Sandbox/account tuning is preserved; new/reset defaults use the export. Rarity and power costs follow those loaded weights. LootLab 0.2.47 is deployed; its map still estimates loose modules only, excluding pack drops/rewards. Capacity warnings from C171 remain open. Rendered reveal/tooltip and R3C7 owner acceptance remain pending; native checks do not establish those passes. Packed-turret weight reduction remains abandoned (C170); Viewpoint remains a separate unapproved prototype. No Workshop upload.

GitHub: `codex/performance-barbed-audit`, [draft PR #1](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/pull/1), into `dev`. C108/C119 mirror applies to plans, patches and versioned findings. Source work began at 69f4755f8924a27487d1d6f43332a1917f010de6 after fetching origin with no incoming dev commits.

R1C3 performance work and R3C7 acceptance remain open. The owner accepted the earlier perceived-lag improvement in 0.2.38.1; do not reopen that test or claim universal performance certification. SP/fresh-world policy and independent Turrets/Traps packages remain. C171 records 0.2.46 minutes-only/tooltip/capacity findings; this build addresses the first two, not the capacity warnings. No old test is silently marked passed or waived.

**Wait for a patch:** final install/mirror pending; this status will be updated after verification.
