# 0.2.64.3 verification

- Effects icons in inventory and Manage
- Effects rarity colors

The eight owner PNGs are 32x32 RGBA, nonempty and copied byte-for-byte. The validator now verifies their hashes alongside the previous Performance and Utility sets. Added effective-rarity coverage checks all nine Effects components across all seven rarity bands; the unsupported-category check now uses Detection, which still lacks supplied artwork.

Full validation passes 27,390 assertions and compiles 319 runtime/translation files; the manifest verifies 398 source and 545 packaged files. Installed from immutable test/v0.2.64.3 / c62972a02e31f9fce80f2489399e88b32776ed24. All 398 source and 545 package/tag/install/archive files match; both complete 0.2.64.2 backups verify. Evidence: diagnostics/v0.2.64.3/icon-release.json. C108 development mirror accompanies handoff. This is a presentation-only update; dedicated startup/save probes will not be repeated. The preceding 0.2.64.1 engine/authority evidence is a baseline, not new 0.2.64.3 execution. In-game rendered acceptance remains pending.


## C425 owner test findings (2026-10-22)

Loaded 0.2.64.3 SP confirmed in captured console `diagnostics/captures/20261022-213548-2693`. Owner reports Arc audio/effect visibility and fade failures, Lever wall misalignment, elevated Tether visuals and equipment layout issues. [Diagnosis, requested additions and proposed correction](FEEDBACK_C425.md). No OMHTT exception/stack entries found in the targeted console search; unrelated warnings remain. Rendered acceptance is not passed. No new gameplay build or validation claimed.
