# 0.2.47 - Module Packs and loot tuning

C177 implements the approved C173-C176 scope and 15% corpse rate. [Contract](checkpoints/R3_MODULE_PACK.md#c177-15-percent-body-rate-and-implementation) | [Test](TEST_v0.2.47.md).

- Module Packs
- Optional rolling reward reveal
- Zombie-body pack drops
- Updated module loot weights
- Adaptive battery hours/minutes
- Inventory module tooltip correction

Each .2-weight pack opens in two seconds for three independent weighted rewards from all 29 module/expansion entries; duplicates are possible. Opening grants real items before the optional four-second reveal. Skip/Close changes presentation only. Packs supplement loose loot in the sixteen existing pools at weight 1.0. Newly killed zombies have an independent 15% pack chance, once per body, including turret kills. Both acquisition settings are configurable; corpse chance zero disables it.

New/reset defaults use the supplied effective weights. Existing world/account values are preserved on the same multiplier scale. Rarity colors and power costs follow those weights; Regulator defaults to weight 6 / Uncommon. The battery unit correction does not rebalance drain. Tooltip descriptions bypass the native format-key path that rejected percent text.

LootLab 0.2.47 is live, with protected routes verified and saved tuning preserved. Its map/counts still cover loose modules only; packs and their rewards are additional. C171 capacity warnings remain unresolved. SP only; rendered owner acceptance pending. Viewpoint remains separate, and packed-turret weight reduction is abandoned. Cumulative unpublished Workshop notes retained.
