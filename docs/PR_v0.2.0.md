# v0.2.0: native Spike Barrier construction

Previously defenses could only be placed from developer controls. In single-player, Spike Barrier now appears in the native Building menu with a four-facing 1x2 preview and a hammer/four-plank/eight-nail construction recipe. Completed native parts join the existing shared-condition/directional-damage ledger; invalid placement is rejected before recipe consumption. Master/barrier switches preserve structures and stop construction/retaliation when disabled.

Validation: 232 behavioral assertions, installed native construction Lua execution with controlled recipe/world doubles, 12 Kahlua module compilations, 61 native translation keys and actual B42.20.4 entity/recipe registration/startup/save/shutdown. Player preview, inventory transactions, traversal and reload acceptance remain pending. Construction and combat remain SP-only; the server loader check does not establish MP gameplay support.

No individual inventory barrier item or bundle ships yet. P2C1b/P2C1c schedule those, including five-item bundles at the owner-confirmed 67% reduction. Existing Phase 1 acceptance gaps remain tracked. No public upload or remote push.
