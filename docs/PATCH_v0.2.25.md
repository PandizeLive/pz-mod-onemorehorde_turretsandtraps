# 0.2.25 — broader finds and turret servicing

C76 implements the approved loot, servicing, feedback and conventional-firearm update. It remains single-player development content; multiplayer authority/performance acceptance is still required.

## Player changes

- Broaden component loot to GarageTools, CrateTools, ToolStoreTools, ToolStoreMisc and MechanicShelfTools. The twelve native pools now contain 102 themed entries. Apply lower weights in ordinary electronics and workshop pools while retaining richer storage/gun-accessory pools. Keep the approved global/per-component defaults and existing saved overrides. Previously generated containers are unchanged.
- LootLab uses the same pool scales/subsets, with 75 eligible native routing rules and 18,514 candidate containers. It reports find probability, the share of successful finds containing one or two components, and the share containing five or more. At default model settings these shares are approximately 77.1% and 5.5%; expected countywide total is 3,505.23, increased by broader coverage. These are estimates, not exact game-save contents.
- Generated containers holding five or more total components have larger circles, independent of which component is visible. Probability-overlay circle size represents the container's chance of a five-plus haul. Tooltips explain totals/chances; zoomed-out markers remain aggregates. Refresh rerolls the world; hide/show does not.
- Power uses a recognizable ring/stem symbol, green when enabled and red when disabled, with a short state tooltip.
- Right-click a damaged turret base → Repair. It takes ten seconds, costs no materials, cancels on movement and repairs only the base. It does not repair the actual gun, restore ammunition or charge the battery. Destroyed bases retain the existing salvage policy.
- Potato zombie hearing defaults to eight tiles. New Potato sound volume defaults to 35 percent and affects firing, reload and impact playback separately from zombie hearing. Existing saves retain explicit Sandbox overrides.
- Additional Firing, Detection, Filter, 360 and Autoloader modules are rejected with “This module doesn't stack.” Installed copies and pending transfers both count. Stackable modules still work, and old duplicate copies remain removable.
- Conventional firearm heads are detected from native gun data rather than a three-item whitelist. All twenty real vanilla firearms pass native loading/firing probes. Matching ammunition, magazines, chamber state, condition and attachments remain actual game items; native range, critical values, models and sound events feed the existing shared turret rules. Conventional modded guns can use recognized reload mechanisms; toys, multi-ammo-per-shot and unknown custom mechanisms are rejected explicitly. This is not a promise to run arbitrary weapon-mod Lua. Gun accuracy/mechanical timings remain turret approximations, not character animations executed without a character.

## Verification

Kahlua/native validation: 3,121 assertions, 52 runtime/translation files, 453 native translation keys and 148 packaged files. Stock 42.21.0 probes cover twenty real firearms, magazine/internal/revolver loading, ammunition conservation, base-only repair, destruction and fresh-process persistence. Loot model checks cover scaled native thresholds, themed subsets, seeded totals, haul distribution and jackpot marker sizing. Website API/page suite: 71 tests. Exact installation and hosted deployment evidence is recorded in RELEASE.md after release.

Headless checks do not certify rendered poses, sound mix, frame smoothness or physical mobile display. The standard isolated stock-game WorldGen/ladder diagnostics are unrelated to mod acceptance. No Steam upload or GitHub push is authorized.

## Quick combined test

1. Restart and confirm **0.2.25**. For an existing save, set Potato hearing radius to **8** and Potato sound volume to **35** if it retained older values.
2. Open Manage: check the green/red Power symbol, switch off and confirm firing/tracking/feeding stop; switch on again.
3. Damage a base. Right-click → Repair, interrupt once by walking, then complete the ten-second action. Base health should be full; gun condition and battery charge should not refill.
4. Try inserting a second Detection/Firing module, including two in one drag. Expect a rejection message. Two stackable stat modules should still be accepted.
5. Mount a revolver, double-barrel shotgun and M16 with suitable ammunition/magazines. Fire through a reload; verify alignment and sounds. Save/reload a supplied turret and check its exact head, supplies and charge.
6. Fire a potato turret near you: listen for quieter thump/reload/splat and check the projectile still starts at the barrel and reaches the impact.
7. Refresh hosted LootLab, zoom to container dots and hover/tap a large one. Generated five-plus hauls should be larger; the chance overlay should report five-plus probability. Refresh changes the seed, hiding a component does not, and saved tuning should survive refresh.

After testing, report Test Complete and the observed issues. The next checkpoint remains P2C3e: shared budgets, clocks and multiplayer authority before enabling multiplayer.
