# Shared LootLab and game rarity anchors (0.2.47.4)

Saved tier rows previously disagreed with card colors because only cards used the game's min/max classifier. Custom tier weights now define classification in both systems, including battery surcharge. Sandbox export carries all seven anchors; automatic-mode saves retain their existing behavior and no loot defaults change.

Validation: focused browser/persistence/export checks, Lua parity fixtures, native option/rarity probes and independent-package checks. See [versioned test](docs/TEST_v0.2.47.4.md) for current evidence and pending owner acceptance.

[Planning](docs/PLANNING.md) | [Current status](docs/CURRENT_STATUS.md) | [Contract](docs/LOOTLAB_TIER_PERSISTENCE.md) | [Release](docs/RELEASE.md)

Development only; no merge, Workshop upload or official release.
