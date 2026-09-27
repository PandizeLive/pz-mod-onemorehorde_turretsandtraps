# v0.2.0.1: Building-menu report

The owner could not find the Spike Barrier in Building and requested both the corresponding native category and a custom Turrets & Traps category. The later instruction cancels a custom requirement bypass: use vanilla Build Cheat.

Captured `C:/Users/bandi/Zomboid/console.txt` with `OMH.cmd -Action Capture` at 2026-09-26 21:16:57 EDT. Local evidence: `diagnostics/captures/20260926-211657-1052/`; console SHA-256 `70D54254ADCB2F6189B4C53A70731D785B7766572C05283FCF28AE1844AFA72E`.

- Lines 514 and 988 confirm authority/client loaded 0.2.0.1. The client translation audit reports 14 checked, zero missing.
- Line 475 reports `Recipe OMHTTSpikeBarrier missing UiConfigScript`, with a SpriteConfig icon fallback. This confirms registration and a missing UI configuration; it does not prove why the recipe was hidden.
- No construction-menu predicate or placement evidence appears in the captured run. Recipe consumption, XP, cursor and traversal acceptance remain open.

The native visibility path explains the missing entry: `ISRecipeScrollingListBox` and `ISTiledIconPanel` call the global `callLuaBool`, whose installed B42.20.4 bytecode uses `LuaManager.env.rawget(func)`. It does not traverse a dotted table path. The old `OMHTT_Construction.onAddToMenu` script value therefore fails without executing the predicate. `BaseCraftingLogic.callLuaBool` is a different method and does support dotted paths; inspecting that method alone would miss this bug.

The 0.2.0.2 patch registers the flat global `OMHTT_ConstructionMenuAvailable` for that exact menu path. Native UI metadata removes the separate missing-UiConfig error. It repairs cached recipe names when opening Building, exposes the same recipe under Carpentry and the custom mod filter, and logs recipe enumeration, native callback visibility, names, category/filter state and Build Cheat. No materials, skill, XP or custom bypass changes.
