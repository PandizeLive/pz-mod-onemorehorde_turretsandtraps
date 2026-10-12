# Current development and planning handoff

**C163 sound selected:** Martyrdom uses 4G, native AttackStomp, with audio starting before its .75-second post-death pop so the main impact aligns. The captured attack suggests an initial .20-second audio lead (.55 seconds after death); rendered synchronization still needs verification. C162 power/accuracy/Fragment/Tack directions remain. [Current contract](checkpoints/R3_EFFECT_POLISH.md#c163---martyrdom-stomp-selection-and-audio-lead-2026-10-12). Planning only: installed 0.2.44 still has the confirmed Tack initialization failure.



Updated 2026-10-12. Read with [AGENTS](../AGENTS.md) and [Planning](PLANNING.md).

**C160 / 0.2.44 installed and automatically verified.** Manage sections/rarity/bars, reload-aware battery feedback, Once Each and Synergy/Martyrdom/Tack are complete under the [approved contract](checkpoints/R3_MANAGE_RARITY_SYNERGY.md). Bounded admission precedes resource commitment; terminal effects cannot recurse. [Patch](PATCH_v0.2.44.md) | [one six-step test](TEST_v0.2.44.md).

15,931 Kahlua assertions, native write/read, all three package selections and 51 supported Firearms guns pass. LootLab matches 28 modules / 193 entries; 76 API/page tests and browser model/import checks pass. These checks do not certify rendered gameplay or client frame smoothness. The prior 676-ms gap remains unassigned. Held 0.2.43 checks join this test; no old round is newly marked passed.

- **Release:** 0.2.44 is installed from immutable `test/v0.2.44`; 202 source / 250 tagged, packaged, installed and archived files match. Exact evidence is recorded in [release state](RELEASE.md). No Workshop upload; cumulative pending notes preserved.
- **Roadmap:** R3C6 implementation is complete; R3C7 combined module/power acceptance and relevant R1C3 performance checks remain active. [Canonical index](ROADMAP.md#current-checkpoint-status-and-next-work). New heads, MP and signals remain separate decisions.
- **Prior findings:** C138 closes 0.2.41 with no reported issues; unmentioned individual checks are not certified. C123 accepts the reported lag improvement. The Louisville hang remains unassigned.
- **Limits:** SP combat only, fresh-world item-ID policy, native inventory weight limits and owner-sourced final art. Bounded overload delays firing; markers/audio are paced separately. No promise of lag-free crowds.
- **GitHub:** `codex/performance-barbed-audit`, [draft PR #1](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/pull/1) into dev. C108/C119 requires the completed update and evidence to be mirrored. No merge or publication.

**Wait for a patch:** the Martyrdom sound decision is settled in C163. The corrective/content patch is not implemented or installed. 0.2.44 remains installed with failed Tack initialization; no repeat test is requested before correction.
