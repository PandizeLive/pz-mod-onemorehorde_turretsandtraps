# R1C1-R1C2: selectable packages

Implemented in 0.2.29 under C87/C88 (2026-10-06). Owner approves full independence and fresh worlds; testing is deferred. Offensive modules, new traps, recipes and the expanded Manage grid remain separate checkpoints.

## Loading investigation

Installed 42.21.0 `ZomboidFileSystem.loadModTileDefs` and `loadModTileDefPropertyStrings` track tile-definition numbers across enabled mods. A repeated number emits an error and skips the second registration. The current `OMHTT_Barriers` definition (7316) includes both barrier and turret sprites, including persisted world identities. Copying that declaration into two independent entries is not a clean split.

The owner chose full independence. Traps (`OneMoreHorde_Traps`) owns registry 7316 / `omhtt_barrier_01`, with 28 tiles. Turrets (`OneMoreHorde_Turrets`) owns registry 7317 / `omhtt_turret_01`, with 21 tiles and matching base depth geometry. Neither has a required mod. The canonical combined registry remains only a build input; it is not shipped. This is a fresh-world development transition, not migration of existing combined saves.

Canonical `Source/` generates both packages. Identical shared helpers/translations use the same virtual paths and load once when both are enabled. Recipes, Sandbox options, models, module loot and runtime loops stay with their component. Separate enable/debug controls prevent one master disabling the other; the firearm audit follows Turrets diagnostics. Item IDs, state keys, recipes and tuning are unchanged. Local LootLab exports declare Turrets ownership and disable loot in Traps-only scenarios; hosted LootLab is unchanged.

## Historical loading probe

`tools/probe_package_loading.py` uses two isolated fixture mods and the installed stock game JAR (42.21, SHA-256 `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`). Three fresh-process checks passed on 2026-10-06:

| Selection | Native result |
| --- | --- |
| Base only | Base loads, addon remains absent, shared Lua executes once |
| Addon only | Native `require=` automatically loads Base, shared Lua executes once |
| Addon before Base | Dependency order resolves, shared Lua still executes once |

All three checks reached server startup and clean shutdown without missing-directory exceptions. Evidence is in `diagnostics/package-loading/{base,addon,reverse}.json` and matching logs; installed `ZomboidFileSystem` bytecode is retained there. Initial exploratory logs predate the fixture-directory correction and are superseded by these three runs.

That fixture established native dependency/shared-Lua behavior. Actual package evidence now supersedes it for content isolation: `diagnostics/v0.2.29/packages-{traps,turrets,both}.json` and logs pass startup and clean shutdown. Traps-only has zero module loot, no turret item/model/runtime registration or turret settings; Turrets-only has no barrier content. Combined startup (Turrets first) has one shared hook, no duplicate Sandbox options and independent masters. Full native persistence probes use the opposite order, Traps first. Static checks verify 93 distinct options, closed Lua requires and 27 identical shared files.

The complete source passes 3,439 Kahlua assertions and 474 native translations. Native write/read verifies objects, exact inventories, ammunition, charge, cooldowns and both sprite registries. Firearms B42 passes 51 supported guns, two rejected cap guns and 153 conserved shots. Installer fixtures cover legacy backup/retirement, repeat install, modified/untracked/unmanaged refusal, read-only readiness and rollback after an injected second-package move failure. These checks do not establish rendered SP or multiplayer acceptance. Cumulative Workshop notes remain pending.

## Combined owner test for the next playable build

This is the single pending test for 0.2.29, replacing separate 0.2.27/0.2.28 rounds. Do it later when convenient. Use a fresh world for each package selection, not an existing combined save; retain each world's selection across save/restart. Deferred player checks are not passes.

1. Restart PZ; confirm **OMH: Traps 0.2.29** and **OMH: Turrets 0.2.29** in the mod list. Use your compatible gun mods, the enabled component's Diagnostic logging ON, Detailed logging OFF and loot multipliers at 1. The console `packages-ready` line must report 0.2.29 and the selected entries.
2. Start with Traps only: build/deploy a basic and reinforced barrier, vault from front/rear, repair and pick up. Turret recipes, module loot, turret settings and turret diagnostics must be absent.
3. Start a fresh Turrets-only world: build/deploy a potato and firearm turret; supply ammo, battery, required magazine, Detection and Firing. Both work, while barrier recipes/settings are absent. Save/restart once and confirm each turret retains its contents.
4. Start a fresh world with both entries: each menu/recipe appears once, barriers and turrets work together, and disabling one component's Sandbox master does not disable the other. Restore both switches before continuing.
5. Check reduced Engagement range and Max, shrinking Suppression noise ring, shooting across low fences/barriers and blocked shots at solid walls/closed doors. Accuracy should improve closer in; check head/base alignment, audio and persistent firing or visual stutter.
6. Pause during firing/reloading, resume, then save/restart and pick up/redeploy. Supplies, components, charge and selected range persist; there is no catch-up burst or free completed reload.
7. After at least thirty seconds of gameplay, search unvisited mechanic/garage/electronics containers. Expect broader one/two-module finds with occasional jackpots. Refresh LootLab and confirm retained settings and the occupied-container metric; its hosted loot baseline remains 0.2.28 because weights are unchanged.
8. Report **Test Complete** with the loaded version, enabled entries and issues so the audit totals and runtime log can be reviewed. Do not deliberately reproduce the unresolved Louisville hang on a main save; preserve the early log if it recurs.

Next recommendation after this split is R1C3 performance/authority measurement. Fresh-world rendered SP acceptance remains pending; combat is still SP-only.
