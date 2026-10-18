# 0.2.54.1 verification

## Automated findings

- Full validator: **21,655 assertions**, 222 compiled runtime/translation files, 1,027 native translation keys, 293 source / 374 packaged files. No banned Lua calls added.
- Native Build 42.21 write/read: a new Plate 10 tiles from its Controller automatically assigns; serialized native linking works remotely and fails after Controller power loss. Saved access and links survive restart.
- Focused tests cover nearest eligible Controller, inaccessible/private candidates, unpowered placement assignment, no eligible Controller, preserved assignment, unauthorized users and the 32-input limit. Siphon resolves to default Legendary weight 3 and +0.8 battery surcharge.
- LootLab: native catalog export and source verification pass; model, weights, tiers, appearance and cloud catalog checks pass. Desktop/mobile saved-weight and tier-browser checks pass, including audio audition. The latter now waits for actual playback instead of assuming 150 ms is sufficient.
- **86 backend tests pass** against the patched production bundle and helper modules. Two obsolete mocked page tests lack the current tier-list mounting API; they were replaced for acceptance by the real desktop/mobile browser checks, not counted as passing.
- Live Worker matches the tested deployment **e4c47e3b-94ad-45e2-ac0b-9b4d9e22d0df**. Thirteen admin routes remain protected; both public API checks remain HTTP 200. Only the catalog section changed in the fetched production bundle, with verified existing bindings/configuration and ten sanitized LootLab assets. No production database write.

The first native fixture used the already-migrated plate visual before native entity construction, producing an invalid SpriteConfig warning. The fixture now starts with the real construction sprite and lets production migration run; write/read checks pass without that warning. No unrelated gameplay sprite change was made.

## Delivery and limits

Independent Traps, Turrets and both-package startup checks pass (62.2 / 61.8 / 53.6 seconds). Installation and GitHub evidence are recorded after verification. Native probes use **zero connected clients**; live client convergence, rendered layout and owner acceptance remain pending. No Workshop upload or merge.

[Validator](../diagnostics/v0.2.54.1/validation.log) · [native evidence](../diagnostics/v0.2.54.1/native-evidence.txt) · [LootLab tests](../diagnostics/v0.2.54.1/loot-tests.txt) · [desktop/mobile](../diagnostics/v0.2.54.1/loot-browser.txt) · [tiers](../diagnostics/v0.2.54.1/loot-tiers-browser.txt) · [hosted release](../diagnostics/v0.2.54.1/lootlab-release.json).

## Short owner test

1. Restart and confirm **0.2.54.1**. Place a Button and Plate several tiles from a Controller, within 20 tiles on the same floor.
2. At the powered Controller, confirm both inputs are assigned. Link each to a turret without walking to the input; verify power-off and private-access restrictions still apply.
3. For an older unassigned input, use Assign at the Controller, then link it. Save/reload and check its assignment and receiver link.
4. Refresh hosted LootLab: Siphon should be present at weight **3 / Legendary** with default tiers. Your other weights and tier settings should be unchanged. Check the in-game Siphon tooltip/pack eligibility too.
