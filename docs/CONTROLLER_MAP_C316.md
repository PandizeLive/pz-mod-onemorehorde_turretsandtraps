# C316 — Controller map and connection-view discussion

## Status and preservation

Owner asks to consider a Controller Menu rework, explicitly follows with “Let's discuss,” and wants the current menu saved because it is good. Existing Stockpile appearance/behavior must be retained. This is planning only: no gameplay/UI implementation, new version, install, or new acceptance claim.

The current Grouped Controller Menu is preserved by immutable `test/v0.2.54.1` at `0a65f67ad2cd3a3eb0ff417ec7eae255e9b5ae1f`, the GitHub mirror, and the verified local `artifacts/OMHTT-0.2.54.1.zip` archive. A prototype must be separate from this baseline; preserving it does not require shipping duplicate UI implementations or a permanent legacy-mode setting.

Owner proposes a grid map with optional satellite view, accurate trigger/turret positions, drag-to-connect links, clickable hierarchy that focuses/selects the map device, and device details including Name, Open Manage, Access and assignment. The supplied image groups Button #1 + Pressure Plate #1 over a shared output and another plate over two outputs. Owner then suggests two connected lists: Inputs/Outputs or Triggers/Turrets/Traps. Treat this as an alternative to the hierarchy, not an instruction to display all layouts simultaneously.

## Current evidence

Inspected installed Build 42.21 vanilla Lua: `ISUI/Maps/ISMiniMap.lua` constructs `UIWorldMap`, loads map data/images, uses world/UI coordinate conversion and center/zoom methods. Accurate icon placement, selection and focus are technically grounded; production integration and rendered acceptance are not yet tested.

`ISMiniMap.lua` line 10 sets `TERRAIN_IMAGE = false`; the disabled branch at lines 304–332 includes a terrain-image toggle using `ImagePyramid`, `newPyramidLayer`, and `pyramid.zip`. The installed Muldraugh map includes those packaged image files. This supports investigating a textured background, not promising it works or depicts current player-built walls, interiors or changes. A live world camera would be separate, substantially more involved work; no verified live-satellite implementation is claimed. Ordinary native map layers are the lower-risk first approach. Preserve map-mod fallbacks and existing visibility/access policy.

Current `ControlWorld.link` accepts Plate/Button inputs and Turret receivers. Passive traps are not newly made controllable by a UI change. Only supported receivers belong in the connectable Outputs list; Traps can become a subtype when an actual receiver contract exists. Preserve the 20-tile same-floor rules, 32-input/32-output caps, Firing requirement and current signal semantics. Multiple inputs retain existing any-input behavior, not new AND logic.

## Recommendations awaiting decisions

**1 — Names.** Recommend **1A Inputs / Outputs**, with Buttons/Plates and Turrets/future supported Traps as types within the lists. **1B Triggers / Defenses** is friendlier wording but less general for future signal devices. Three separate Triggers/Turrets/Traps lanes are not recommended: receiver type should not change the connection model.

**2 — Layout.** Recommend **2A Map / Connections views occupying the same main area**, retaining selection and links when switching; the existing Stockpile remains at the right, with selected-device information beneath the main area. Connections shows Inputs on the left and Outputs on the right; each device appears once and can have several connections. Map shows accurate positions and clicking/focusing behavior. A Find on Map action switches views and centers the selected device. **2B Lists and map visible together** trades immediate cross-reference for less map/detail space and more clutter, especially with Stockpile open. Avoid adding a fourth permanent information column.

**3 — Background.** Recommend **3A Grid + native map toggle** first. **3B Investigate the disabled textured terrain-image mode before choosing the background**; probe results must be discussed before calling it supported. Static map imagery is not a live snapshot of player construction.

Proposed interaction default: click a marker/list row to select; drag from a visible connection point to a valid receiver, with select-input/select-output fallback. Blank map drag pans; device gestures do not move world objects. Emphasize selected connections, show direction and current signal state, and offer explicit Disconnect on a selected link. Duplicate links are rejected. Grouping/selection does not change signal behavior or assignment automatically.

## Performance, compatibility and scope

Reuse the existing device IDs, synchronized state, remote authorization and native timed-action mutation path. Render the map/list locally while the menu is open; cache device and connection layouts and refresh changed data at the existing bounded cadence. Do not scan the world or rebuild the graph every frame. Drag preview stays local; one accepted drop submits one link action, and the server rechecks permissions, proximity to the Controller, power, range, assignment and receiver compatibility. Concurrent removal/access changes must cancel or reject stale interactions clearly.

Receiver links, Controller assignment and access are distinct; the UI must label these clearly. View changes must preserve selected device and the Stockpile widget, not open a second independent inventory system. Do not add live zombie tracking, multi-floor control, passive-trap powering or new logic gates under this redesign.

Once the owner selects the layout/background direction, prepare a focused interactive mockup before approving production code. For a later implementation, high reasoning is appropriate for native map input/MP/UI integration; use Fast if the planned implementation exceeds 25 minutes. No model setting was changed.
