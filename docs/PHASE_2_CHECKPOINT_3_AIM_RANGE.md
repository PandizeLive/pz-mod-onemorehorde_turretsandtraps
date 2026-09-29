# P2C3 aiming, selection range and balance — 0.2.13

## Changes

The 0.2.12 owner test confirms working ammo and substantial progress, but reports a floating head and incorrect aim. The head now follows the base's previous 16-pixel downward shift: height 0.4 becomes 0.3166667; scale remains 0.512. Combat heading increases toward negative world Y, while native model yaw increases toward positive world Y. Negating heading corrects model rotation without changing targets or saved headings. No new artwork or model proportions.

Manage says **Magazine**, including cycle feedback. Default damage is 35 points (0.35 native HP); magazine 1, reload 2 seconds, shot cooldown 2 seconds. Timers overlap: sustained shots are two seconds apart, not four. Both remain independent for future Reload/Rapid-Fire effects. Total capacity stays 85 including magazine rounds. The earlier Hard-night calculation was based on five potatoes per reference zombie; it is not a guarantee at 35 damage. No hidden depletion or automatic ammo increase.

Left-clicking a turret base, hovering its context-menu options, or opening Manage selects it for a cyan ground-plane range ring and aiming arrow. Another object click replaces mouse selection; closing Manage clears its selection source. The ring reflects current 360-degree manual targeting, not a new cone restriction. Obstacles still block actual targeting; the ring shows maximum geometric range, not a wall-clipped visibility map. Empty, removed, unloaded, unseen and different-floor turrets do not show a range. Draws clip to their local viewport and run before UI controls. General → Show turret range defaults on, tooltip: “Show range when selected.”

A 90-degree forward-only policy was offered as an optional clarification because it changes gameplay. Until selected, preserve existing radial manual combat. Detection and 360 modules remain later work, alongside all module effects and multiplayer. No persistence schema changes.

## Evidence

- Owner log: `diagnostics/captures/20260929-183350-0950`, loaded 0.2.12. Successful native transfers and seventeen potato shots; direct input 0.5 agrees with old 50 damage. No new Manage exception identified. Visual acceptance failed on head height/yaw.
- Current stock installed 42.21.0 bytecode: `Core.DoPushIsoStuff`, `ItemModelRenderer.WorldModelCamera.Begin`, `IsoUtils.XToScreen/YToScreen`, and `UIManager` selection/pre-UI events. Historical decompilation was discovery only. Manifest hashes record current evidence.
- Native JOML/Isometric projection compares eight model aim vectors against actual world projection and verifies the 16-pixel vertical correction. This is mathematical/native API proof, not a GPU screenshot.
- Validation passes 1,728 assertions, 37 runtime Lua files, 245 native translation keys and 23 packets; 103 package files are manifested. Kahlua regressions cover actual default damage/reload timing, independent yaw, selection lifecycle, range radius, camera/zoom/viewport/floor conversion, UI draw order and visibility/toggle/head-removal guards. World/UI objects are doubles.
- Native startup/save/shutdown passed in 40.5 seconds, including real inventory in-process save/restore and four-sided collision/clear sight. No fresh-process restore rerun is claimed; this patch does not change persistence.
- Selection diagnostics identify the turret/source/range; renderer mode records height, scale and yaw convention. Existing firing logs provide actual aim and damage. No per-frame logging.

## Complete owner test

Single-player, 3D items on, with a potato head, charged battery, potatoes and visible zombies available. Existing saves keep their old Sandbox values: set Potato damage **35**, reload **2**, cooldown **2**, magazine **1**, ammo **85** for this test. General → Show turret range should be on.

1. Restart and confirm **0.2.13** in Foundation Test Controls. Open Manage; confirm **Magazine** and the configured damage/timers.
2. Left-click the base, then try hovering Turret menu options and opening Manage. Expect a range ring with aim arrow, centered on the base and staying aligned while zooming. The ring is 360° because manual targeting currently is too.
3. Fire at visible zombies from several sides. Expect the head/arrow to point at the chosen target, a seated head, one potato per shot and no shot sooner than two seconds. A direct hit should show 35 damage where the indicator uses that scale.
4. Remove the head after unloading: its range should disappear. Reinstall it; toggle Show turret range off/on and verify the display follows. Contents/charge should remain correct.
5. Finish with **Test complete**. Capture console via OMH.cmd → 6. Send a screenshot if alignment or range placement still looks wrong. No separate calibration exercise is required.
