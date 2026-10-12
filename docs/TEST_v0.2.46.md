# 0.2.46 - Focused owner test

Use SP and your existing test turret. Packing is excluded because it remains unfinished.

1. Restart and confirm **0.2.46** in the developer menu. Check Sandbox **Battery use = 0.00045**; other worlds retain their saved setting.
2. Hover several modules in inventory and Manage. Confirm no rising error counter, readable colored rarity, and **0.2** weight on newly spawned modules. Check a tooltip near the bottom of the screen.
3. With a full battery, compare the turret with zero/one/two working Regulators, keeping other modules fixed where slots allow. Estimated life should scale **1x / 1.25x / 1.5x** and shot cost should fall. Generator use should not change.
4. Fire briefly with your usual effects, then save/reload. Confirm battery consumption, installed modules and effects still work without errors. The estimate is continuous firing, not a promise for every loadout/day length.
5. Open LootLab: confirm Regulator appears, previous tuning remains and Show/Hide works. Report **Test complete** and any issue; Codex will check console.txt.

## Automated evidence

16,046 Kahlua assertions; 113 runtime/translation files compiled; 760 native translation keys; 23 packets serialized. Focused checks cover Regulator stacking, broken copies, physical slot counting, zero own surcharge, generator isolation, exact .00045 defaults and preserving custom Sandbox values, rarity bands, and a method-only tooltip double with no exposed padding fields. All 204 source / 252 package files are covered by the manifest.

Native write/fresh-process read pass in 46.2/46.5 seconds. Traps-only/Turrets-only/both startup pass in 63.5/47.0/58.6 seconds. The 51-gun Firearms probe preserves 153 firing transactions. Initial runs exposed stale fixture component counts; corrected expectations retain the full native parser/persistence checks. Passing runs have known stock asset/world diagnostics but no failed OMHTT probes.

LootLab numerical/default/appearance checks, 77 API/page tests and desktop/mobile browser checks pass. Saved 0.2.44 tuning migrates without rescaling; Regulator defaults are added. The deployed bundle and protected/public routes verify. [Deployment evidence](../diagnostics/v0.2.46/lootlab-release.json).

No rendered game acceptance, universal crowd-performance claim, or packed-weight success is implied. The prior 0.2.45 inventory tooltip failure remains recorded in its versioned test record. Final native probes precede line-ending-only normalization and tooltip-number formatting validation; the final Kahlua/package suite passes afterward.

## Installed handoff

Installed from immutable `test/v0.2.46`; all 204 source / 252 package, installed and archive files match. Both 0.2.45 backups verify. The closed existing test save received only the approved Battery use correction to .00045, with a verified backup. [Release evidence](../diagnostics/v0.2.46/local-release.json) | [Save correction](../diagnostics/v0.2.46/test-save-setting.json). **Test now.**
