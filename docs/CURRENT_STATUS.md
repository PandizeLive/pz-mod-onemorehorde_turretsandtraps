# Current development and planning handoff

## C167 - Selected packing, module weight, Regulator and rarity (2026-10-12)

Owner selects 1C (full automatic packing), adds module item weight .3 -> .2, selects 3B named **Regulator Module**, and 4A **Abundant / Common / Uncommon / Rare / Epic / Legendary / Mythic**. Packing remains a native feasibility task; this does not authorize an added Java dependency or lossy restoration. The revised power proposal is base **.0008%** with **+.1x to +1x per module**, explicitly submitted for evaluation. [Updated contract and calculations](checkpoints/R3_POWER_PACKING_OPTIONS.md#c167---selected-directions-and-revised-power-evaluation-2026-10-12). With the tested weapon/day/cadence, sixteen highest-cost modules give only 3.54 hours before reloads, so the prior six-hour target needs qualification or lower base drain. **Decision needed:** retain .0008 for stronger power tradeoffs, or use .00045 for about 6.3 hours on that high-cost reference build. No gameplay patch or saved-setting change this discussion; existing tooltip defect remains queued.

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

**Decision needed:** see C167 above; 0.2.45 remains installed with a confirmed inventory-tooltip error. Packed-weight compression is unfinished.
