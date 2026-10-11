# 0.2.42 combined test

## Owner test - pending

1. Start a fresh SP debug world with **0.2.42**, default power settings and damage feedback. Place a battery-powered firearm turret; spawn the four new modules using OMHTTModule. Confirm names, slots and tooltips.
2. Compare Manage's cost with the same module loadout on M9 and MSR788: rifle costs about 2.31x per volley. Add/remove a module: cost changes. Let it idle: charge stays steady.
3. Use a single-projectile firearm and Piercing against lined-up zombies: extra aligned victims take decreasing damage; a wall stops the ray. A shotgun/potato head shows Piercing as inactive.
4. Try Initial Blow and Execute on zombies durable enough to survive hits: healthy targets take stronger initial hits; sufficiently wounded targets are finished. Secondary side shots/fragments should not inherit these effects.
5. Try Impact with repeated empty reloads: first shots can stagger standing zombies; later shots and partial top-ups do not rearm it. Staggered zombies recover; ordinary potato knockdown still takes priority.
6. Save/reload once and check charge, modules and cooldowns. Confirm LootLab has all four modules and retains your tuning. Report completion and any issues; Codex checks console.txt for this exact version.

## Automated and native evidence

- 5,241 Kahlua assertions; 98 runtime/translation files; 664 native translation keys; 23 packet serializations (largest 390 bytes). Power tests cover module aliases, physical counts, broken modules, expansion exclusion, per-type weights, default/reference endurance, saved overrides, one-cost-per-volley, insufficient power and queue backpressure.
- Conditional tests cover pre-hit thresholds, uncapped Initial Blow, deterministic Execute, single death/award, Horde Night baseline preference, unknown-health fallback, partial/empty reload entitlement, shared Impact guard, and bounded 70/49-percent piercing with a wall obstruction. Native float boundary failure was corrected with a 1e-7 fractional tolerance and regression checks.
- Native 42.21 write/read pass in 114.0/138.8 seconds, including real M9/MSR788 power, sixteen-module alias accounting, generator factor, threshold evaluation and exact saved Impact flags. Twenty native firearm adapters preserve ammunition; the installed Firearms-mod check passes 51 supported guns / 153 firing transactions.
- Package static checks pass: 137 disjoint Sandbox options, closed Lua dependencies and 31 identical shared files. Final Traps-only/Turrets-only/both startup results and install hashes are recorded at release completion below.
- LootLab model/default/static checks and 74 isolated API/page tests pass. Hosted 0.2.42 is deployed and bundle-verified; twelve anonymous admin paths remain protected, two public API endpoints retain 200. Saved tuning survives read migration. Catalog: 24 modules/16 pools/170 entries; model estimates 81.28 percent one/two-module successful finds and 4.78 percent five-plus. These exclude physical capacity/story losses.

Earlier native attempts exposed the health float boundary and test-helper/server-load assumptions; those failed attempts are not pass evidence. A legacy dependency-loading fixture also ran; it is not proof of the actual independent packages. Only the versioned packages-*.json results establish that. No owner gameplay result is inferred. Automated thresholds do not establish rendered animation or crowd performance. No MP certification or Workshop publication.


## Installed handoff

Immutable `test/v0.2.42` / `2354a7ff3ed4ef174a0bbeb4d7d0051a620bc5d7`; installed through OMH.cmd. 192 source / 232 package, tagged, installed and archived hashes verify; previous 0.2.41 backups verify. Actual package startups pass: Traps 110.3s, Turrets 108.2s, both 111.4s. Initial package test expected the old 150-entry catalog; corrected to 170, then affected selections passed. [Machine record](../diagnostics/v0.2.42/local-release.json). **Test now**; owner results and console capture pending.


## C149 owner finding: bulk ammo transfer freeze (2026-10-11)

Owner reports disruptive freezes when transferring approximately 600 rounds through ordinary turret inventory, versus individually through Manage. Wants both fast and equal in rate. The test round is still in progress; do not infer passes for other checks or require another immediate reproduction.

Console capture confirms OMHTT diagnostics version=0.2.42, side=sp. Summary sequences 74/77/78 report 106/300/194 transfers (600 combined), with maximum active-update gaps 49/343/542 ms; sequence 84 reports 100 transfers and 563 ms maximum. Concurrent firing/Manage rendering prevents attribution of all elapsed time to transfer code. No transfer-stage profiler exists yet. Source review confirms native groups up to 20 light items, Manage merging disabled, and repeated full-container validation scans; these are concrete optimization targets rather than a verified complete root cause.

Local evidence: diagnostics/v0.2.42/console-c149-ammo-transfer.txt; 146,809 bytes; SHA-256 6ff4737a6940ab8183d6ecebedab8dd280e02c954032018e37d1195df6a75805; original last write 2026-10-11 18:35:14 local. Raw full console remains local. [Next-update contract](PERFORMANCE_AUDIT_v0.2.42.md#c149-bulk-ammo-transfer-follow-up-2026-10-11) retains C148 and prioritizes shared fast/bounded ammo transfers with correct pending-item accounting. **Wait for a patch** for this finding. No fix implemented or verified; installed 0.2.42 unchanged.
