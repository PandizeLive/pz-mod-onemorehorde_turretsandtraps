# 0.2.47.1 - Combined short test

Single-player; this replaces the uncompleted 0.2.47 sequence. No long stress test or all-zero-settings test is needed; automated checks cover that edge case.

1. Restart and confirm **0.2.47.1**. Spawn two **OMHTTModulePack** items; open one normally and Skip the other. Each gives exactly **three** rewards with readable icons/names/colors. On a short viewport, scroll the rows; Skip/Close should stay visible.
2. Disable **Module Pack animation** and open another. Expect three rewards after the action; interrupt another opening by walking and confirm the pack remains.
3. Kill a small group, including turret kills, and inspect bodies. Packs may drop, at most one per body; a small sample need not equal exactly 15%.
4. Hover several modules and the turret battery. Tooltips should be readable without errors; estimates of at least 60 in-game minutes should show hours. Save/reload with an unopened pack and open it for three rewards. Report **Test complete** plus issues; Codex will inspect console.txt.

## Automated verification

Foundation plus corrective audit: **16,094 assertions**, 117 runtime/translation compilations, 775 native keys, 23 packet checks, 208 source / 256 package files. The corrected audit runs in the normal validator.

- 600 unchanged tooltip frames: one wrapping call; width/font/description changes each invalidate it.
- 300 reveal frames: zero new item factories or wrapping calls; opening uses zero display-item factories. 360-pixel viewport overflow is zero; larger fonts and wheel/arrow access to final rewards pass. Tests use UI doubles, not GPU rendering.
- 10,000 unique deaths plus 10,000 repeated callbacks: exactly 1,500 packs across exhaustive RNG boundaries, zero component-weight reads per death. Empty eligibility stops acquisition before RNG. Unchanged pool calls reuse entries.
- Partial reward-2/reward-3 failure, failed pack removal and same-outcome retry checks pass.
- Native write verifies script metadata for all 29 entries, no pack injection across all 16 pools with zero weights, retained unopened packs and successful opening after weights return. Native write/fresh-process read pass in 77.7/63.7 seconds, retaining reward names and duplicates. Traps-only/Turrets-only/both isolation passes in 67.8/57.5/54.8 seconds. These are headless checks, not player sessions.

Current client console still reflects an older session; no rendered 0.2.47.1 pass is claimed. C171 capacity warnings remain unresolved separately. LootLab is unchanged at verified 0.2.47.

Installed from immutable `test/v0.2.47.1`; all 256 package/archive/installed hashes and both previous-package backups verify. Guideline scan: 101 source / 117 packaged / 117 installed Lua files, zero pcall/xpcall, tabs or BOMs; new-pack non-guard inline-conditional scan is clear. [Evidence](../diagnostics/v0.2.47.1/audit/guidelines.json).
