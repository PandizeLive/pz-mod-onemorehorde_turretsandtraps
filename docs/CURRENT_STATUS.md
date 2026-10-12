# Current development and planning handoff

## C166 - Endurance and packing discussion (2026-10-12)

Owner reports battery drain works but the late-game turret lasts about 1.5 in-game minutes. Latest saved Battery use is 0.1, twenty times the shipped .005 default; log confirms 4.07965% per shot. Console also confirms repeated inventory rarity-tooltip errors at TurretMenu.lua:24. Battery acceptance is partial; the rest of the patch is not cleared. [Evidence and numbered options](checkpoints/R3_POWER_PACKING_OPTIONS.md) cover safe pickup alternatives, six-hour endurance tuning, Power Efficiency and seven rarity names. These are discussion proposals, not new gameplay approval. Packing remains unfinished. **Decision needed** on the four choice groups; no repeat test requested while discussing the corrective patch.

Updated 2026-10-12. Read with [AGENTS](../AGENTS.md) and [Planning](PLANNING.md).

**C165 / 0.2.45 installed and automatically verified.** Tack startup, delayed effects/audio, shotgun accuracy/Piercing, rarity-based power, concise module/battery feedback and slider polish are complete. [Patch](PATCH_v0.2.45.md) | [five-step test](TEST_v0.2.45.md). Installed from immutable `test/v0.2.45`; owner acceptance remains pending.

16,011 Kahlua assertions, native write/fresh-process read, all three independent-package selections and 51 supported Firearms weapons pass. These checks do not certify rendered layout, audible timing or crowded-client frame smoothness.

**Packed-weight compression remains approved but unfinished.** Pick Up should automatically pack the turret, preserve its normal contents summary, and unpack through existing placement. The tested native opaque-buffer restoration is unavailable to ordinary Lua; exact arbitrary-item preservation is not proven. Existing pickup weight remains. No equipped-only substitute or partial property reconstruction ships.

C164 LootLab colors, family shapes and sticky Show all / Hide all are already deployed and verified. R3C7 combined acceptance and relevant R1C3 performance work remain active. No Workshop publication.

- **Release:** All 203 source / 251 tagged, packaged, installed and archived files match; both 0.2.44 backups verify. [Release evidence](RELEASE.md).
- **Roadmap:** R3C6 implementation is complete; R3C7 and R1C3 acceptance remain open. [Canonical index](ROADMAP.md#current-checkpoint-status-and-next-work). New heads, MP and signals remain separate decisions.
- **Prior findings:** C138 closes 0.2.41 with no reported issues; unmentioned individual checks are not certified. C123 accepts the reported lag improvement. The Louisville hang and prior 676-ms gap remain unassigned.
- **Limits:** SP combat only, fresh-world item-ID policy, native inventory weight limits and owner-sourced final art. Bounded overload delays firing; no promise of lag-free crowds.
- **GitHub:** `codex/performance-barbed-audit`, [draft PR #1](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/pull/1) into dev. C108/C119 requires mirroring the completed update/evidence; no merge or publication.

**Decision needed:** see C166 above; 0.2.45 remains installed with a confirmed inventory-tooltip error. Packed-weight compression is unfinished.
