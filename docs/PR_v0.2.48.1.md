# New turret heads and pack timing (0.2.49)

Adds craftable Ballista, Rotary Bat and Rotary Blades to the universal base. Ballista consumes crafted spears with selected accuracy and battery cost; rotaries use paired physical sectors, optional360 spin, motor-time power and guarded player injuries. Mounting materials are integrated into each recipe, with eight Ballista nails. Module compatibility and Manage feedback follow each head; original heads remain unchanged. Pack rows start150ms apart and rarity audio leads the final stop250ms.

Contact work uses the existing shared scheduler and bounded local scans. Long stalls bill elapsed operating time without replaying attacks. Final art remains owner-sourced; technical cubes and rendered/audio acceptance are explicitly pending.

Validation:16,574 assertions,120 Lua/translation compilations, three actual native recipe transactions and retained tools, new-head native item save/reload, and Traps-only/Turrets-only/combined package startup. [Versioned evidence and focused owner test](docs/TEST_v0.2.49.md). Tagged installation evidence is recorded in [Release](docs/RELEASE.md).

[Planning](docs/PLANNING.md) | [Current status](docs/CURRENT_STATUS.md) | [Head contract](docs/TURRET_HEAD_PROPOSALS.md) | [Roadmap](docs/ROADMAP.md)

Development only: this draft PR targets dev. No merge, Workshop upload or official release. Hosted LootLab and owner loot settings remain unchanged.

Cloud planning C211-C221 has been picked up under C222 from `planning/lobber-ammunition` at `5b623ef`. [Next-head decisions](docs/TURRET_HEAD_PROPOSALS.md#c222-pc-planning-reconciliation-2026-10-13) now cover the Lobber payload/priority/fuse/range rules and Scrapshot6x15-damage direct feed. These are planning approvals only; the heads are not implemented by these documentation commits. Native bomb health damage remains a PC follow-up, and0.2.49 testing is deferred.
