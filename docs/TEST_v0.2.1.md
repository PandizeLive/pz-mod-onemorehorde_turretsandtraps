# v0.2.1 owner test: partial SP pass

The owner reported Test Complete on 2026-09-27. Captured console.txt using OMH.cmd at 01:35 EDT in `diagnostics/captures/20260927-013500-6405/`. SHA-256: `D5682C624FC3BE2F9C15974E31A9C1BE5D1A952FEBBB02CA2D04592084C7D456`. [Machine-readable review](../diagnostics/v0.2.1/owner-test-review.json).

The running authority/client identify 0.2.1. Two portable crafts each report one correctly named/type-matched item at weight 6. Three native barriers complete with six valid, distinct persistent parts: one raw construction and two deployments, with Build Cheat off. Preview rotation and two blocked results are recorded. The deployed barrier deals two 20-damage front hits and a final approximately 12.04-damage killing hit, bounded by the target's remaining health.

A later world initialization loads all three devices and both halves with valid native SpriteConfig and unchanged sprite IDs, facing, ownership and condition. Twelve restoration entries include repeated load callbacks; they do not represent twelve objects. The previous Invalid SpriteConfig warnings are absent. No OMHTT Lua exception appears; unrelated vanilla map, vegetation and Piano errors remain.

All restored barriers have 100 condition, and the initial ledger was empty. This does not prove damaged-barrier persistence or old-file-sprite migration. The capture also does not independently measure every inventory/XP delta, visual frame, traversal attempt, or area-unload transition.

The owner reports missing Crafting category and clipped/unhelpful selected-recipe text. These are accepted UI defects and addressed in 0.2.2. Pickup was not implemented in 0.2.1. The follow-up explicitly approves full-condition recovery, free ten-second repair/pickup and combining these with bundles; requested directional-risk vaulting remains a native prototype gate. See [the next checkpoint](PHASE_2_CHECKPOINT_1C.md).
