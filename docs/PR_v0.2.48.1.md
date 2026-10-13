# Staggered pack reels (0.2.48.1)

Module Pack reels previously moved and stopped together. They now start 350 ms apart, run six seconds each and open at twice the previous speed. Rows reveal independently from top to bottom; the final row triggers the existing shared selection/rarity audio. Immediate collection and reward odds are preserved.

Validation: 16,180 assertions and 117 Lua/translation compilations pass, including exact winners, staggered timing, independent pulses and bounded audio after long frames. The 500-frame probe adds no items/text wraps. Native write/read and all three package combinations pass. Tagged installation verifies 264 files and both backups; see the [versioned test](docs/TEST_v0.2.48.1.md). C191 records owner acceptance of the reel behavior and console confirmation; 150-ms spacing and a 250-ms earlier rarity cue are approved for the next patch, not implemented here.

[Planning](docs/PLANNING.md) | [Current status](docs/CURRENT_STATUS.md) | [Contract](docs/PACK_POLISH.md) | [Release](docs/RELEASE.md)

Development only; no merge, Workshop upload or official release. Includes the prior 0.2.48 custom audio and owner weights; hosted LootLab remains on that verified baseline.

C192: New-head selection (R3C1) is now the active content discussion; seven candidates recorded in [the shortlist](docs/TURRET_HEAD_PROPOSALS.md#c192-active-new-head-selection-2026-10-12). No individual head or implementation approved. C191 pack timing remains queued for the next patch.

C193: Owner selects Ballista, Rotary Blades and Rotary Bat for development. [Head contract and choices](docs/TURRET_HEAD_PROPOSALS.md#c193-three-head-development-scope-2026-10-12) records remaining behavior/recipe decisions and shared rotary architecture. No new gameplay implemented; C191 timing polish stays queued.

C194 confirms crafted-spear ammunition, directional rotary coverage with 360 upgrade and player contact damage. [Module adaptations](docs/TURRET_HEAD_PROPOSALS.md#c194-confirmed-head-rules-and-module-adaptations-2026-10-12) are under discussion; no gameplay implementation yet.

C195: Owner selects continuous physical rotary attacks, defers secondary-effect adaptations and excludes Range/Accuracy plus magazine-cycle modules initially. [Confirmed rotary scope](docs/TURRET_HEAD_PROPOSALS.md#c195-continuous-physical-rotary-scope-2026-10-12); remaining tuning/recipes are open. No gameplay patch this turn.

C196 excludes rotary Splitter and records [simpler compatibility recommendations](docs/TURRET_HEAD_PROPOSALS.md#c196-simpler-rotary-compatibility-2026-10-12). Piercing/Conservation exclusions are proposed, not approved. No gameplay change.

C197 confirms inherent Bat/Blades multi-target sweep contact and excludes Piercing/Conservation. [Current head contract](docs/TURRET_HEAD_PROPOSALS.md#c197-inherent-rotary-multi-target-contact-2026-10-12). Planning only; stats/recipes and native proof remain.
