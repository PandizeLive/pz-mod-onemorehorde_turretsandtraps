# Current development and planning handoff

Updated 2026-10-11. Read with [AGENTS](../AGENTS.md) and [Planning](PLANNING.md).

**C160 / 0.2.44 implemented and automatically verified.** Manage sections/rarity/bars, reload-aware battery feedback, Once Each and Synergy/Martyrdom/Tack are complete under the [approved contract](checkpoints/R3_MANAGE_RARITY_SYNERGY.md). Bounded admission precedes resource commitment; terminal effects cannot recurse. [Patch](PATCH_v0.2.44.md) | [one six-step test](TEST_v0.2.44.md).

15,931 Kahlua assertions, native write/read, all three package selections and 51 supported Firearms guns pass. LootLab matches 28 modules / 193 entries; 76 API/page tests and browser model/import checks pass. These checks do not certify rendered gameplay or client frame smoothness. The prior 676-ms gap remains unassigned. Held 0.2.43 checks join this test; no old round is newly marked passed.

- **Release:** 0.2.44 is prepared; tagged installation and exact hashes are recorded in [release state](RELEASE.md). No Workshop upload; cumulative pending notes preserved.
- **Roadmap:** R3C6 implementation is complete; R3C7 combined module/power acceptance and relevant R1C3 performance checks remain active. [Canonical index](ROADMAP.md#current-checkpoint-status-and-next-work). New heads, MP and signals remain separate decisions.
- **Prior findings:** C138 closes 0.2.41 with no reported issues; unmentioned individual checks are not certified. C123 accepts the reported lag improvement. The Louisville hang remains unassigned.
- **Limits:** SP combat only, fresh-world item-ID policy, native inventory weight limits and owner-sourced final art. Bounded overload delays firing; markers/audio are paced separately. No promise of lag-free crowds.
- **GitHub:** `codex/performance-barbed-audit`, [draft PR #1](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/pull/1) into dev. C108/C119 requires the completed update and evidence to be mirrored. No merge or publication.

**Wait for a patch:** release installation/mirror verification is the final step; no further design decision is needed.
