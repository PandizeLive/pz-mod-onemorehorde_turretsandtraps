# 0.2.47.4 - Focused rarity test

## Automated evidence

- 16,137 assertions; 117 Lua/translation files compile; 208 source / 256 packaged files validate.
- Shared Lua/JS fixtures cover exact anchors, proportional boundaries, rarer ties, surcharge/color mapping, invalid/partial anchors and automatic defaults.
- Edge: real drag/drop, seven-band screenshot values, individual overrides, duplicate rejection, Confirm + actual reload, matching reopen, downloaded Sandbox settings, existing direct-weight flow and mobile bounds; zero page errors. Screenshot inspected.
- 82 API/page tests pass; account persistence remains the existing tested C183 schema/merge path.
- Traps-only, Turrets-only and both native package selections pass. Native write/read startup and existing save/restart probes pass; both processes verify registration of all seven native settings and correct runtime rarity/surcharges. [Native evidence](../diagnostics/v0.2.47.4/rarity-native.json).
- Hosted deployment and protected-route/public-endpoint verification pass. [Evidence](../diagnostics/v0.2.47.4/lootlab-release.json).
- Reviewed changed shipped Lua: no protected calls, per-tick work, additional event loop or dependency between packages. The rarity helper follows Alex's annotations/guard/style conventions; existing unrelated style debt is not claimed resolved.

Owner acceptance remains pending. Current console.txt still identifies **0.2.47.1**, so it cannot validate this build. Native/browser tests are not rendered owner acceptance.

## Short owner test

1. Refresh LootLab, open Plan with tiers: modules at their row's weight have that row's name and color.
2. Move one module, Confirm, refresh and reopen: its weight, rarity and matching row remain.
3. Export Sandbox settings. Apply the module weights and seven RarityWeight settings together, then restart with **0.2.47.4**.
4. In Manage or a module tooltip, compare that module's rarity with LootLab; check its displayed battery drain agrees with the tier. Report any mismatch and I will inspect console.txt.

No repeated combat/stress test is requested for this cache-only classification correction. Existing pack audio/visual acceptance remains separate.
