# v0.2.0.3: native category startup and barrier creation repair

Opening Building could finalize the category list before native recipes loaded, leaving only an untranslated mod category. Defer the custom entry until native categories exist and use the engine's `IG_UI.json` filename. Preserve Carpentry and the mod filter over the same recipe.

Creating a barrier used unnamed file-backed sprites, invalidating its native SpriteConfig and throwing before the parts joined the defense ledger. Initialize all eight part names before construction and retain each part's native sprite during adoption/sync. Keep obstruction and duplicate checks active with vanilla Build Cheat. Add recipe text explaining that the knife icon represents the accepted sharp knife/cleaver group; saws and all recipe eligibility remain unchanged.

Validation: 254 Kahlua assertions, including installed category-widget startup and Build Cheat overlap/obstruction cases; 13 runtime modules and 64 native translation keys. The isolated B42.20.4 smoke creates eight real native thumpables with valid SpriteConfig part identities, resolves the category through normal translation loading, checks the native menu callback and all 75 ingredient combinations, then saves/shuts down cleanly (74.4 seconds). Rendering, actual player transactions and component save/reload acceptance remain pending. Earlier doubles missed the native name and lifecycle faults; these tests specifically cover them.

See [owner evidence](TEST_v0.2.0.2.md), [checkpoint test](PHASE_2_CHECKPOINT_1.md#owner-test) and [release state](RELEASE.md). Failed-test remnants are preserved; use a fresh disposable save. No remote push or Workshop upload.
