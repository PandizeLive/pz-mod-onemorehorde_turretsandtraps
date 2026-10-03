# 0.2.24 — approved LootLab defaults

C75 applies the owner's current hosted tuning to new-world T&T defaults. Source: account scenario revision 84, saved 2026-10-03 01:03:38 UTC (October 2 locally); sanitized snapshot in diagnostics/v0.2.24/approved-loot-settings.json.

- Overall module loot multiplier: **6**.
- Firing, Detection, Small Expansion Kit, Large Expansion Kit and Autoloader: **3** each.
- Filter, 360, Suppression, Rapid-Fire, Reload, Velocity, Range, Medium Expansion Kit, Critical and Accuracy: **2** each.
- Base weights, seven eligible pools and component subsets remain unchanged. The combined multiplier is 18 or 12 times each component's base weight.

Existing saves retain their Sandbox overrides and generated loot. LootLab's new defaults match the package; existing account scenarios and offline drafts retain their tuning when their baseline migrates. Material abundance 0.6, roll multiplier 1, retention 1, map seed and display selections are model inputs, not additional mod defaults. No production account settings are overwritten.

Validation: 3,035 assertions; 52 runtime/translation files; 448 native translation keys; 148 packaged files. Stock 42.21.0 write/read probes pass, including actual registered Sandbox defaults and all 75 injected component weights. Site model checks and all 71 API/page tests pass. At the approved model inputs, 256 generated worlds yield mean 2,020.09 and central 90% interval 1,886–2,154; these remain estimates rather than exact game loot counts.

## Combined acceptance

Carry the six-step [0.2.23 test](PATCH_v0.2.23.md#quick-combined-test) forward. No separate randomized loot hunt is required for this defaults-only change.

1. Restart the game and confirm 0.2.24.
2. Start a new Sandbox configuration; under OMH: T&T - Loot confirm overall 6, Firing/Detection 3 and Filter 2.
3. Existing saves should retain their previous settings.
4. Refresh hosted LootLab. Your saved values should remain; Set to Default now selects the approved tuning (use only when you want to reset your scenario).

Native/headless checks do not certify rendered combat, sounds or frame smoothness. No Workshop publication or GitHub push.
