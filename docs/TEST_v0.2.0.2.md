# v0.2.0.2: category and placement failure review

Owner report: only one untranslated category, apparently unrestricted/overlapping placement, an error, and a misleading Steak Knife ingredient label. Testing is incomplete, not accepted.

Captured console.txt at 2026-09-26 23:29:45 EDT using the stable release tool. Evidence: `diagnostics/captures/20260926-232945-5145/`; SHA-256 `AE84732B7068839F93C6E2B106E3EAB5226C2B798BF085F5456BF74AE15FE8EB`.

- Lines 513/975 confirm 0.2.0.2 authority/client. Menu diagnostics confirm Build Cheat ON and the flat visibility callback returning true.
- The adapter appended its category while native BuildLogic was still empty. ISWidgetRecipeCategories marked that nonempty list initialized and never populated the later native categories. The correction leaves an empty startup list empty.
- `IGUI.json` was an invalid native translation filename. The actual engine registry uses `IG_UI.json`. The earlier direct-file translation test accepted a filename that startup never loads; it now checks Translator.BY_NAME and the real startup probe verifies the category string.
- First creation at line 1050 reports invalid SpriteConfig, followed by `missing argument #1 to match` at Construction.lua:71. File-backed sprites were cached without names. Native components could not identify their part, then the OnCreate callback crashed before assigning paired collision/ownership state. Numerous repeated attempts left untracked objects.
- The correction names all eight placeholder part sprites before native construction, preserves their distinct names during adoption/sync, and verifies real native IsoThumpable/SpriteConfig instances. It does not delete objects left by the failed test. Retest in a fresh disposable SP save.

Installed ISWidgetInput:updateScriptValues displays a representative/satisfied item from a tagged input group, optionally cycling icons; its item name is not the entire requirement. Native CarveSpear uses `base:sharpknife` or `base:meatcleaver`, retained and not dull. Native SawLogs uses `base:saw`; SawLongStick additionally accepts `base:crudesaw`. Saws are not a default substitute for spear carving. Preserve the approved knife/cleaver requirement and add a native recipe tooltip explaining the alternatives. No materials, tools, skill or XP eligibility changes are approved by this repair.

Remaining acceptance includes the rendered menu, actual player transactions, traversal and save/reload. File-backed sprites still require reload evidence; the named-sprite test is not a save-format or rendered-client test. The existing ledger reconciliation is not proof that native entity components restore correctly after reload. Native tile definitions may be required before full persistence acceptance.
