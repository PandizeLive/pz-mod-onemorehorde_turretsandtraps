# Hybrid rendering checkpoint — 0.2.10

The owner approved the cube-only rendering feasibility checkpoint on 2026-09-29. This package adds an isolated single-player debug scene, not a replacement turret renderer. Existing gameplay recipes, capacities, timing and categories remain unchanged. The requested OMH: Traps / OMH: Turrets categories and the proposed 85-potato magazine/reload/menu correction remain queued separately.

## Implementation

A stationary IsoObject uses new stable tile `omhtt_barrier_01_48`. Its image contains only the base cube from the existing authorized GLB. An actual IsoWorldInventoryObject displays a separate static mesh containing the original head and aim cubes. Their item marker links the two objects; the native world-item path owns rendering, lighting, depth and persistence. No Java override or custom render callback is shipped.

The head is a debug-only item with no crafting or loot distribution. A native world item remains movable/lootable; this is acceptable only for the isolated probe. Production integration must prevent duplicating a real installed head into a second lootable item, define removal/unload ownership, restore a sprite fallback, and prove observer synchronization before adopting this approach.

Debug context controls place/remove a probe, rotate its head by 45 degrees, toggle a 10 Hz turn, and adjust height/scale. At most eight heads can spin, only within four tiles of their operator. Rotation stops when the operator leaves; automatic spinning is deliberately not saved. Native item yaw, scale, height and marker are saved. Head and base do not share transforms. No automatic targeting is implied.

The base remains at one tile while the head can move vertically from 0 to 0.9 floor units in 0.1 increments; scale ranges from 0.1 to 4. These are calibration controls, not final dimensions. Spin advances at 36 degrees per real second, with bounded catch-up; it is not an approved turret turning speed.

## Evidence and acceptance

The existing GLB is the only geometry source. `tools/build_hybrid_probe.py` exports its two head cubes to a static DirectX text mesh, plus the base-only tile and a plain white 8x8 texture. Native Jassimp import and PZ StaticMesh processing pass with one mesh, 48 vertices and 24 triangles. The head has no skeleton or animation requirement for yaw rotation.

Current installed game sources are authoritative. Relevant call sites: `media/lua/server/BuildingObjects/ISPlace3DItemCursor.lua:renderOpaqueObjectsInWorld`, `media/lua/client/Foraging/ISBaseIcon.lua:render3DItem`, and `media/lua/client/ISUI/ISExtendedPlacementUI.lua`. Current Java signatures were checked in `projectzomboid.jar`: `InventoryItem.setWorldZRotation/setWorldScale`, `IsoWorldInventoryObject.setOffset/getWorldPosZ`, `LuaManager.GlobalObject.Render3DItem`, and `ProcessedAiScene.process`. Older 42.20.2 decompiled sources explain the path but are not current compatibility proof.

Rendering depends on the native 3D-ground-items option. With it disabled, the item can appear as an inventory icon. This probe does not force graphics settings or claim that icon is an acceptable production fallback. Native item rotation may interact with the game's atlas/chunk cache; actual rotation, visual alignment, lighting, occlusion, upper-floor positioning and performance remain rendered acceptance gates.

No screenshot, headless import or serializer test should be called successful in-game rendering. The owner test below is required before issuing a final artist export contract.

Final headless results: 1,545 existing regression assertions, 31 compiled runtime Lua files, 194 native translation keys, 97 packaged files and native texture-pack validation (49 identities/27 pages). Separate native write/read processes passed in 98.6/82.4 seconds. The actual model script resolves from the debug item; two real items retain independent yaw; the head reloads at yaw 135, scale 1.25, height 0.3 with its model/link marker intact. Current 42.21 stock-first class loading is recorded in the manifest. The owner's earlier 0.2.9 console confirms ordinary client startup; the historical isolated optimizer mismatch is not treated as a current blanket blocker.

## Complete owner test

Use a disposable single-player world with **Debug → Foundation Test Controls** enabled and native **3D items** enabled. Restart after installation and confirm **0.2.10** in the foundation menu. This is a separate render probe; ordinary turrets still use sprites.

1. Right-click a nearby clear tile → **OMH: Hybrid render probe → Place cube probe**. Expect a fixed cube base and a separate two-cube head. Place a second probe nearby.
2. Rotate one head in 45-degree steps, then toggle its rotation. The first head should turn while both bases and the second head stay still. Toggle again to stop.
3. Raise/lower and enlarge/shrink one head. Confirm only that head changes; record the useful settings shown in `hybrid-probe-action` logs.
4. Walk around a wall/fence beside it, zoom, and compare daylight/shadow or a flashlight. Note incorrect draw order, visibility through walls, lighting, flicker or disappearance. Walking over four tiles away stops auto-spin.
5. Save/reload after changing yaw, height and scale. Both parts and adjustments should return, with rotation stopped. Repeat placement on an upper floor if accessible.
6. Toggle native 3D items off/on to identify the fallback, then remove each probe using its menu. Capture logs with **OMH.cmd → 6** and report “Test complete” with screenshots of any alignment/occlusion problem. Avoid picking up the debug head; if picked up, delete that debug item separately.

## Artist handoff while acceptance is pending

Keep an editable source for each separate head, its texture and a clearly identified mount pivot/muzzle marker. Do not bake the base into head geometry. Static meshes can rotate as whole objects; bones are only needed for future independently moving parts, if approved. The existing placeholder's axes and dimensions are not aesthetic or production requirements.

The tested importer format is `.x`; the game also has an FBX import path, but no artist FBX has been validated here. Retain editable source and postpone final scale, axis conversion, mount height, texture resolution and export preset until visual calibration. A real representative artist export must pass the same importer and in-game test before bulk delivery. The requested tile-base/model-head architecture remains a candidate until these checks pass.
