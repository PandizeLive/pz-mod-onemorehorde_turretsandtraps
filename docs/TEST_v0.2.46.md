# 0.2.46 - Focused owner test

**C171 findings, 2026-10-12:** owner reports minutes-only duration display. Console confirms 0.2.46 with a new tooltip-formatting exception and repeated native capacity warnings. [Details and console evidence](LOOTLAB_DIRECT_WEIGHTS.md#game-findings-not-a-completed-test-pass). Test remains incomplete; prior automated passes do not clear these rendered findings. LootLab direct-weight controls are now deployed separately.

Use SP and your existing test turret. Packed-weight reduction is abandoned under C170; no packing test is needed.

1. Restart; confirm **0.2.46** and Sandbox **Battery use = 0.00045**.
2. Spawn a fresh module and hover modules in inventory/Manage, including near the screen bottom. Expect **0.2 weight**, readable rarity labels and no error-counter increase.
3. At full battery, compare zero/one/two working Regulators with all other modules unchanged. Battery estimates should scale approximately **1x / 1.25x / 1.5x**; cost per shot decreases. Leave spare slots for this comparison.
4. Fire at a small group for about 30 seconds, then save/reload. Confirm normal firing/effects, retained modules and battery charge, and no new errors or disruptive pauses.
5. Open LootLab: Regulator appears, prior tuning remains, and Show/Hide works. Reply **Test complete** with any issues; Codex will inspect console.txt.

## Automated evidence

16,046 Kahlua assertions; 113 runtime/translation files compiled; 760 native translation keys; 23 packets serialized. Focused checks cover Regulator stacking, broken copies, physical slot counting, zero own surcharge, generator isolation, exact .00045 defaults and preserving custom Sandbox values, rarity bands, and a method-only tooltip double with no exposed padding fields. All 204 source / 252 package files are covered by the manifest.

Native write/fresh-process read pass in 46.2/46.5 seconds. Traps-only/Turrets-only/both startup pass in 63.5/47.0/58.6 seconds. The 51-gun Firearms probe preserves 153 firing transactions. Initial runs exposed stale fixture component counts; corrected expectations retain the full native parser/persistence checks. Passing runs have known stock asset/world diagnostics but no failed OMHTT probes.

LootLab numerical/default/appearance checks, 77 API/page tests and desktop/mobile browser checks pass. Saved 0.2.44 tuning migrates without rescaling; Regulator defaults are added. The deployed bundle and protected/public routes verify. [Deployment evidence](../diagnostics/v0.2.46/lootlab-release.json).

No rendered game acceptance, universal crowd-performance claim, or packed-weight success is implied. The prior 0.2.45 inventory tooltip failure remains recorded in its versioned test record. Final native probes precede line-ending-only normalization and tooltip-number formatting validation; the final Kahlua/package suite passes afterward.

## Installed handoff

Installed from immutable `test/v0.2.46`; all 204 source / 252 package, installed and archive files match. Both 0.2.45 backups verify. The closed existing test save received only the approved Battery use correction to .00045, with a verified backup. [Release evidence](../diagnostics/v0.2.46/local-release.json) | [Save correction](../diagnostics/v0.2.46/test-save-setting.json). **Test now.**
