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
