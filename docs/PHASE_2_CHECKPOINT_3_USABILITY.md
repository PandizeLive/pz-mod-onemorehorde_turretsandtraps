# P2C3 usability and integrated turret — 0.2.11

## Approved scope

On 2026-09-29 the owner approved the combined patch after the 0.2.10 flicker report. C53 adopts the recommended 85 total potatoes, overlapping timers and two retained tool types with the integrated turret/collision/menu work. This supersedes the isolated probe delivery. No final art is generated; all visuals reuse the authorized white cube geometry and technical markers.

- Stationary base-only tile; the actual installed head item draws through vanilla RenderOpaqueObjectsInWorld / Render3DItem. There is no second ground item to loot, duplicate or synchronize. The event supplies the current player viewport. Head scale 0.512 and height 0.4 are the owner's recorded starting calibration, not final artist export requirements.
- Explicit per-instance yaw bypasses the item atlas. Aiming no longer replaces the base sprite or repeatedly invalidates its render chunk. Native 3D-items OFF selects the existing 16-direction sprite fallback; switching back restores the hybrid route. Registry entries retire when removed/unloaded, including with 3D disabled. No per-frame inventory or world scan is used.
- The 1x1 base blocks players and zombies and remains see-through/thumpable. Existing world turrets adopt the same collision on load. Native adjacent-object pathing handles Manage and pickup. The Debug collision overlay includes bases. No fence-vault behavior is added.
- Right-click Turret → Manage opens both native inventory panes, selects the turret container and adds status/manual Fire controls. Walking away closes the status panel. Real drag/drop inventory transfers remain authoritative. Unload potatoes before swapping the head; pickup keeps actual contents and charge.
- Crafting and Building use OMH: Traps and OMH: Turrets. Native filtering replaces the old duplicate injected category. Turret placement no longer draws barrier edges. Turret crafting retains screwdriver plus wrench OR pipe wrench; materials, skill requirements and XP remain C49's approved values.

## Shared firing cycle

Defaults: reserve capacity 85 INCLUDING loaded potatoes, magazine 1, reload 1 second, shot cooldown 0.5 seconds. Reload begins when an empty magazine receives ammo and immediately after its last shot. Reload and cooldown run concurrently: default sustained fire is one shot per second. A larger magazine uses 0.5-second intervals until empty, then reloads. Sandbox exposes each quantity separately with short tooltips.

Loaded rounds are a count over real potatoes already in the native container, never additional invented ammo. Firing removes exactly one item and commits power once only after finding a valid target. The exact head item's modData carries loaded count/reload deadline/shot deadline through transfers and native saves. Removing ammo reconciles loaded count; no-target attempts spend nothing. Pickup retains the base's existing cooldown too. The cycle accepts separate effective values so later Rapid-Fire, Reload and Autoloader modules can affect independent stages; module effects and automatic targeting remain P2C3d.

The 85-potato default is a reference budget: current Horde Night OMH_Progression.lua computes first solo Hard quota as floor(8 * (1 + (1.3 - 1) * 4)) = 17; five potatoes per reference zombie gives 85. Hard toughness is mixed (10/78/12 fragile/normal/tough), so this is not a guaranteed exact kill budget for every randomized horde. Faction scaling, custom difficulty, damage settings, splash and other defenses change actual use. No forced daily depletion or hidden ammo loss is introduced.

Existing saves retain their own Sandbox values; changing a shipped default does not overwrite a saved/custom ammo limit or cooldown. For the new balance test select 85 / 1 / 1s / 0.5s explicitly if the old world's values differ.

## Evidence

Current installed stock B42.21.0 / 4a0e9546ec is authoritative; recorded hashes are in diagnostics/v0.2.11/manifest.json. Vanilla source references: Fishing/Bobber.lua (actual inventory item rendered without a ground object), ISPlace3DItemCursor.lua (opaque world pass), luautils.walkAdjObject, ISInventoryPage:setPinned/refreshBackpacks/selectButtonForContainer/setForceSelectedContainer. Current bytecode confirms Render3DItem passes explicit yaw and the native chunk-option override. Historical 42.20.2 decompilation was a discovery aid only.

1,588 Kahlua assertions pass, including overlapping cycle timing, full-reserve depletion, zero-reload cooldown, pending save restoration, ammo withdrawal, per-instance render ownership/culling and Manage reach/native-container selection. All 34 runtime Lua files compile; 206 native JSON translations and 23 packet checks pass. UI/world doubles do not establish rendered acceptance.

Native importer converts the original 48-vertex/24-triangle head. Fresh-process world/packed-item write/read verifies real inventory identity, charge, condition, magazine state and cooldown. Native base probes block players/zombies on four sides, permit sight and adjacent reach, leave firing queries clear, and classify as a full-square thumpable in both pathfinders. Hybrid and fallback SpriteConfigs remain valid through all 16 aiming headings. The five native recipes succeed with only the two approved tool types and retain them.

GPU flicker, actual draw ordering/lighting and final mount alignment remain the visible acceptance gate. This patch removes the old probe's repeated chunk invalidation and duplicate ground-item route; no headless result proves the reported flicker is visually resolved. Artist export requirements remain provisional. The standalone probe's placement/calibration menu is retired; saved probes retain a removal option.

## Combined owner test — Test now after installation

Use single-player with native 3D items enabled; a disposable world is recommended. Mechanics 4/Electrical 1 cover both recipe routes, or use native crafting/building cheats for placement. Debug Foundation Test Controls show the loaded version. Existing worlds may need the new Potato defaults selected manually.

1. Restart and confirm 0.2.11. Check Potato settings: ammo 85, magazine 1, reload 1s, cooldown 0.5s.
2. Check Crafting/Building for OMH: Traps and OMH: Turrets. Craft a complete turret and a separate base/head; only screwdriver and wrench/pipe wrench should be retained tools.
3. Deploy two turrets, rotating/cancelling once. Expect a 1x1 base preview without barrier lines, a fixed base tile, and a head only when installed.
4. Use Turret → Manage, drag potatoes and a charged car battery into the selected loot container. Expect ammo/loaded status; the first potato loads in one second.
5. Fire at nearby zombies. Expect about one shot per second, one potato spent per hit attempt that finds a target, independent head aiming, and no flicker/disappearing bases. Walking into the base should be blocked while sight remains clear.
6. Unload potatoes, swap the head, then reload it. Pick up/redeploy a loaded turret from adjacent ground; supplies and battery charge should survive without walking into the base forever.
7. Save/reload, then toggle native 3D items off/on. Expect the sprite fallback, followed by the separate head; ammo, condition and charge stay intact. Debug collision lines should outline one tile if enabled.
8. Finish with “Test complete”; capture console.txt through OMH.cmd → 6. Send a screenshot/clip if any visible fault remains. No separate calibration test is requested.
