# P2C3d3 — turret usability and Expansion Kits (0.2.18)

Approved by owner after the 0.2.17 test and Capacity naming discussion (C65). Rendered client acceptance remains pending; installed verification is recorded in RELEASE.md.

## Final scope

One dedicated Expansion slot holds one Small, Standard or Large Expansion Kit. Default bonuses are +50/+100/+200 potatoes and +2/+4/+6 ordinary slots, respectively. Relative loot weights are 0.5/0.25/0.1 in the existing four native pools, with global and individual multipliers; these are relative weights, not drop percentages. Base defaults remain 100 potatoes and four slots, making tier totals 150/6, 200/8, 300/10. Existing Capacity items keep Base.OMHTTModuleCapacity and existing tuning keys, becoming Standard kits without item conversion. New tiers have separate bonus/loot options. Removing a working kit cannot leave excess ammo/modules; legacy duplicates do not add their bonuses together. Broken/over-capacity contents remain recoverable. No module crafting.

Manage displays ten compact ordinary slots together, inactive ones dimmed; higher Sandbox limits use wheel-scrolled rows with a short hint. Installed names omit Module; native inventory names/tooltips remain complete. Changed result/rejection text briefly brightens. Manual search/aim completion and cancellation update the result instead of leaving Aiming displayed after completion.

Sandbox page order follows native custom-option registration: General, Traps, Turrets, Automation, Modules, Loot, Debug. Every page starts OMH: T&T -; Spike Barrier and Potato Turret are headings within parent pages. Existing option IDs stay unchanged. Pending barbed barricades, concertina/barbed wire, bed/punji/poke traps, sensors, control units, firearm/explosive heads and Horde/XP integration remain in CONTENT_AND_BALANCE.md and ROADMAP.md; this patch does not implement them.

Inventory Install offers the selected packed base to native BuildLogic and uses the existing ISBuildIsoEntity preview, rotation, timed approach and deployment callback. Preview/cancellation spend nothing; dropping the selected item invalidates its cursor. Native input selection is checked with another matching packed base present. Deployment continues consuming one exact base and adopting actual contents. Native building cheat still skips walking; no custom furniture Pickup rewrite.

Manual Fire queues one bounded search per turret, capped at 32 queued turrets, at most four 64-work-unit slices and two milliseconds per tick. Pending manual search/aim takes priority over automatic targeting. Known automatic/manual aim targets skip the previous redundant full candidate scan; obstruction and resource validation still run at commitment. Splash remains a separate bounded search (64 candidates, three victims). Diagnostics record search slices/work/wait time and firing duration; this is instrumentation and bounded-work coverage, not a hardware FPS certification.

The base now has native cube-depth metadata and a matching depth PNG instead of FloorOverlay. BuildBaseDepth.java generates it with the installed 42.21 TileGeometryUtils projection; the existing procedural white cube artwork and calibrated head anchor are retained. Geometry parsing and complete visible-pixel coverage are verified headlessly. Native GPU texture loading requires a graphical client: a deliberate headless load attempt cannot establish rendering and was removed from the automated probe. No final or AI art.

## Source grounding and verification

Current installed 42.21 Lua: ISBuildIsoEntity constructor/walkTo/isValid/create, ISBuildingObject.tryBuild, ISInventoryPaneContextMenu.getContainers, ISCraftInventoryPanel manual input offers, ServerSettingsScreen custom page construction. Current JAR: BuildLogic manual selection, PropertyContainer.unset, TileGeometryUtils, TileGeometryFile and depth PNG loading. Historical 42.20.2 decompiled files were discovery aids, not assumed current signatures. Native renderer import/projection checks and tagged manifest evidence accompany this build. Gameplay remains SP-only until P2C3e multiplayer certification.

Final automated result: 2,161 assertions; 45 runtime Lua files; 372 native translations; 114 packaged files. Native write/read passed in 96.3/95.2 seconds. Renderer/client interaction remains unaccepted.

## Complete combined owner test

Existing save settings remain authoritative. Use default 100 ammo/four slots for the numbers below; spawn supplies through debug. No extended stress session is needed.

1. Restart and confirm 0.2.18. Check ordered OMH: T&T pages: General, Traps, Turrets, Automation, Modules, Loot, Debug; defense headings and separate kit tuning appear.
2. Carry two packed turrets with different contents. Right-click the intended one → Install; rotate, cancel once, then place with building cheat OFF. Character approaches; only the selected item is consumed, and its contents arrive intact. Ordinary Building placement should still work.
3. Inspect the white base/head at several zooms and near a wall: no shallow plate, floating gap or disappearing head. Select for coverage; Manage opens alone with ten compact slots and dimmed unavailable slots.
4. Try Small, Standard and Large kits separately: defaults 150/6, 200/8, 300/10. Put excess ammo/modules in; removal refuses and the changed message briefly brightens. Remove excess and recover the kit. Old Capacity becomes Standard. Installed names omit Module; inventory names remain complete.
5. Two Rapid-Fire and two Reload modules give 0.75 shots/second and 1.33s Reload at defaults. Two Velocity and two Range give 49 damage and 10-tile range; Autoloader sets Reload to zero. Removing copies restores stats without free ammo/shots.
6. Detection + Firing + power: head turns before firing, stays within the placement cone, respects walls; 360 opens full coverage. Removing power stops tracking. Check brown projectile, brown impact and splat2 sound.
7. Automation OFF, Turn speed 30: click Fire once toward an off-angle zombie/crowd. Expect one shot after searching/turning; compare first and later clicks for hitching. Repeat and immediately walk away: no shot or ammo spent, and result stops saying Aiming/Searching.
8. Pick up loaded with a partially charged battery and a kit. Tooltip/weight, exact supplies, tier and stats survive Install and save/reload. Send Test Complete and any remaining issue.

Next: supported-firearm mount prototype (vanilla pistol, pump shotgun, bolt-action rifle) on the universal base, followed by multiplayer/performance certification. Broad modded-gun support and crafting are not implied.
