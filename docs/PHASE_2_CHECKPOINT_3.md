# P2C3a-c: modular potato turret foundation — 0.2.9

Owner approved the complete next-update recap on 2026-09-28, using High effort. The held P2C2b/0.2.8 barrier test is combined with this candidate. Implementation is single-player; rendered acceptance and multiplayer remain separate gates.

## Scope and checkpoints

| Checkpoint | Implemented behavior | Acceptance |
| --- | --- | --- |
| P2C3a | Native container-based base/head inventory, one head and battery, bounded ammunition/module storage, exact-item transfers, contents tooltip and full carried weight | Native recipe/container/serialization checks; owner drag/drop, tooltip and pickup test pending |
| P2C3b | Five recipes, native Deploy Turret preview/rotation, exact loaded-item adoption and ten-second interruptible pickup | Native ingredient transactions and all 16 aim sprite bindings; owner placement/cancellation test pending |
| P2C3c | Manual potato firing, actual ammo/power consumption, battery fallback, categorized Sandbox controls and diagnostics | Resource/cooldown/obstruction regression checks; owner combat and power test pending |
| P2C3d | Automatic firing/detection/filter behavior and upgrade-module effects | Future; no module effects enabled in this package |
| P2C3e | Dedicated multiplayer authority, two-observer synchronization and performance | Future; gameplay gates remain closed in multiplayer |

The base is one InventoryContainer item. Its actual head, ammunition, battery and module items move into the native world ItemContainer during construction, and back into a carried base during pickup. Head removal requires unloading potatoes. Unrelated items, second heads/batteries and excess ammo/modules are rejected. Modules are storage prototypes available through debug item spawning; there are no module recipes, loot injection or active effects yet.

The player commands Fire from the world menu while nearby. This checkpoint retains the prototype's nearest unobstructed zombie selection; automatic detection cones/target priorities are P2C3d. No physical projectile travel-time system is claimed. The quiet visual potato pop, tiny splash and guarded standing-target knockdown remain.

## Approved recipes

| Output | Consumed materials | Required skills | Base XP |
| --- | --- | --- | --- |
| Universal Base | 2 MetalPipe, 2 SmallSheetMetal, 1 ScrapMetal, 8 Screws | Mechanics 2 | 15 Mechanics |
| Potato Head | 1 MetalPipe, 1 SmallSheetMetal, 2 ScrapMetal, 2 ElectronicsScrap, 1 ElectricWire, 1 TirePump, 2 DuctTape uses | Mechanics 2, Electrical 1 | 15 Mechanics, 5 Electrical |
| Improvised Potato Head | Same, replacing TirePump with 4 additional ScrapMetal | Mechanics 4, Electrical 1 | Same |
| Complete Potato Turret | Exact sum of base and pump-head materials | Mechanics 2, Electrical 1 | 30 Mechanics, 5 Electrical |
| Complete Improvised Potato Turret | Exact sum of base and improvised-head materials | Mechanics 4, Electrical 1 | Same |

Retained tools: screwdriver, wrench or pipe wrench, metal snips; head/complete recipes also require pliers. No magazine or Carpentry requirement. Separate and complete routes produce the same modular base with a real head item inside. Add a separately crafted head by inventory transfer; assembling finished components, deploying, picking up and swapping award no XP. The native build recipe consumes the exact selected loaded base once, transferring its contents in the construction callback.

Initial empty-base/head/module weights are 6/4/0.3. Weight reduction is zero. Contents are never automatically ejected on pickup. Destruction drops surviving contents; pickup is a separate transaction. State and charge are not refreshed by swapping or deployment.

## Power and tuning

Valid indoor grid power is preferred, then a connected active generator actually powering the square, then a working charged car battery. All three vanilla car-battery types work. Turrets do not charge batteries; use vanilla battery chargers. No cable-placement system is added.

Because generic IsoThumpable objects are not native registered electrical appliances, this checkpoint charges generator fuel explicitly per successful shot. It does not fabricate an entry in the generator appliance list or alter the game's aggregate power counter. Loaded generators are indexed through native object/load events. No target, obstruction, cooldown or invalid action spends ammo or electricity.

Defaults: 100 durability, 30 potatoes, four stored modules, 50 direct damage points (0.5 engine health), one-second cooldown, six-tile range, 70% knockdown chance, 0.1 splash damage points, 1.1-tile splash radius, 0.1% battery charge or 0.001 generator fuel units per shot. Separate Potato Turret Sandbox page exposes these values and the content/power toggles. Existing General, Spike Barrier and Debug pages remain. Module bonuses and projectile speed settings await functioning mechanics.

## Current-build evidence

Installed game changed from 42.20.4 to **42.21.0 / 4a0e9546ec**. The installed old PZOptimizer LuaCompiler override fails normal engine initialization with `NoSuchMethodError: LuaCompiler.register(KahluaTable)`. Isolated current-build validation uses `OMHTT_STOCK_CLASSES=1` (stock JAR before loose overrides); game installation and optimizer files are untouched. A normal player launch needs that external mismatch resolved first.

Native references: `ISBuildIsoEntity.create/setInfo` and `CraftRecipeData.getAllConsumedItems` for exact build adoption; `ItemContainer.setAcceptItemFunction` for inventory filters; `ISInventoryTransferAction.isValid/transferItem` for native transfer validation; `InventoryContainer` for weight and nested-item serialization; `ISWorldObjectContextMenu.handleCarBatteryCharger` for grid/generator/battery conventions; `IsoGenerator.isPoweringSquare/getFuel/setFuel` for exact source charging. Native `SpriteConfig` must match every aim sprite: four visual entities cover the sixteen registered directions, while old barrier tile IDs remain unchanged.

Evidence files are under `diagnostics/v0.2.9/`. Lua/unit tests are not rendered gameplay acceptance. Native server fixture checks do not enable or certify multiplayer turret combat.

Final checks passed: 1,545 Kahlua assertions, 29 runtime Lua files, 184 native translation keys, 23 packet checks and 91 packaged files. Separate native write/read processes passed in 41.2/41.7 seconds, retaining exact item identities, charge, condition and cooldown in both world and carried turrets. All five crafting routes, loaded construction adoption, 48 registered sprite mappings and 26 texture pages passed. Release-tool fixtures passed. The package manifest records stock-first native source hashes.

## Combined owner test

Use a disposable single-player world after resolving the stale optimizer override. Mechanics 4 and Electrical 1 cover both recipe routes; recipe screens list ingredients/tools. Building/Crafting cheats are suitable for placement tests, but disable them when checking costs and XP. Developer controls expose the loaded mod version; debug item spawning supplies modules while their recipes remain deferred.

1. Restart, enable the mod and confirm **0.2.9** in the foundation developer menu. Check the Potato Turret Sandbox page and readable Crafting/Building entries.
2. Craft a complete Potato Turret, then a separate base/head. Check the listed costs, retained tools and XP; drag the separate head into its base.
3. Use **Building → Turrets & Traps → Deploy Turret**. Rotate, cancel, try occupied locations, then place it: cancellation keeps the item; deployment consumes one loaded base without extra XP.
4. Use the loot panel to add potatoes, one car battery and a few debug modules. Unrelated items and a second battery/head are refused. Unload potatoes before removing the head. Module effects are intentionally inactive.
5. Fire at nearby zombies. Each successful shot spends one potato and charge; rapid repeat attempts respect the cooldown. Walls/no target spend nothing. Check damage, knockdown and the small impact pop.
6. Remove the battery and test within an active connected generator's powered area; firing works. Turn off the generator; firing stops unless a charged battery is installed. Logs record the charged power source and amount.
7. Interrupt pickup by moving, then complete its ten-second action. Check contents/charge/total weight, save/reload while carrying, redeploy and save/reload again: no lost items, refills or disappearing turret.
8. Recheck right-click selection/highlighting on both barrier halves and reinforced barriers. Finish the test, run **OMH.cmd → 6**, and report “Test complete” for console review.

## Remaining limits

Final art remains owner-sourced; only existing authorized white cube/arrow markers are reused. Gun heads, native firearm reuse, module effects, pressure plates/lasers, faction rewards and Horde integrations remain later checkpoints. No Workshop upload or GitHub push is part of this patch.
