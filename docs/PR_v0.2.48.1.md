# Staggered pack reels (0.2.48.1)

Module Pack reels previously moved and stopped together. They now start 350 ms apart, run six seconds each and open at twice the previous speed. Rows reveal independently from top to bottom; the final row triggers the existing shared selection/rarity audio. Immediate collection and reward odds are preserved.

Validation: 16,180 assertions and 117 Lua/translation compilations pass, including exact winners, staggered timing, independent pulses and bounded audio after long frames. The 500-frame probe adds no items/text wraps. Native write/read and all three package combinations pass. Tagged installation verifies 264 files and both backups; see the [versioned test](docs/TEST_v0.2.48.1.md). C191 records owner acceptance of the reel behavior and console confirmation; 150-ms spacing and a 250-ms earlier rarity cue are approved for the next patch, not implemented here.

[Planning](docs/PLANNING.md) | [Current status](docs/CURRENT_STATUS.md) | [Contract](docs/PACK_POLISH.md) | [Release](docs/RELEASE.md)

Development only; no merge, Workshop upload or official release. Includes the prior 0.2.48 custom audio and owner weights; hosted LootLab remains on that verified baseline.
