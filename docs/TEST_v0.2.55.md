# 0.2.55 verification — C323

## Implemented

Controller now combines Triggers/Defenses and their links, Grid/Native Map, separate selected-device action groups and the retained native Stockpile. Its existing 64-object / 2 ms incremental scan and five-second rescan remain. Graph text/anchors refresh on geometry/data change or at 500 ms, and draw only visible rows; map marker labels/widths are cached with the graph. Accepted drops use the existing server-authorized Link timed action. Selection/panning/resizing do not fire weapons or mutate inventory.

Both windows use native ISResizeWidget and ISLayoutManager, with player-specific local geometry keys, viewport clamps, title dragging and outside-release cleanup. Manage reflows the existing 16 slots without replacing them; Details expands when space permits and otherwise uses its dedicated page. Stockpile switches to its attached page below 1000 pixels rather than squeezing native inventory columns. These menus require a practical viewport; the tested compact cases start at 900 pixels wide / 600 pixels high for Manage and 900 pixels wide for Controller. This is not a claim of phone-sized native-game support.

Private naming reservations cover turrets, triggers and passive traps independently of Controller membership. Duplicate custom labels receive suffixes without changing network IDs; first fresh Button is Button #1. Exact recovered items retain reservations. Old radio Buttons retain a legacy native entity definition and migrate to the new switch entity without becoming native light switches. Left-click queues the existing momentary Pulse through native adjacent-walk/action handling.

## Automated evidence

- Stock-JAR-first installed Build 42.21 validator: **21,843 assertions**, 231 Lua/translation files compiled; 298 source and 383 packaged files manifested. No shipped `pcall`, `xpcall`, `ipairs` or bare `next` calls.
- New cases exercise window sizes, 16 retained module slots, Details growth/collapse, Load Order bounds, simultaneous Lure/Landing controls, changed player viewport, native resize release, real ISLayoutManager write/read functions with in-memory file adapters, local-only geometry, 32-input/32-output graph scrolling and 1,024-link projection reuse, drag linking, duplicate/read-only rejection, map selection without firing, and display-name conflicts/pickup/native table persistence.
- Native UIWorldMap v3 probe validates construction, projection, pan/zoom, data/images API and mouse-event handling. It does not render a game frame.
- Source-derived SVG geometry traces were inspected for section separation. Their widgets/fonts/icons are test adapters, not native screenshots or acceptance evidence.
- Native write/save probe passes after fixing the legacy Button entity gap. A repeated-run numbering fixture now checks the next reserved number rather than assuming an already-used test world is fresh. The isolated barb object fixture runs after native GlobalModData saving; it now stores a matching private-name snapshot alongside its object binaries and compares table fields without depending on serialization order. A separate normal-save check verifies private naming reservations across a fresh server process.

[Validator](../diagnostics/v0.2.55/validation.log) · [Native map API](../diagnostics/v0.2.55/native-controller-map.log) · [Manifest](../diagnostics/v0.2.55/manifest.json).

## Acceptance limits

Native server probes have zero connected clients. Rendered native map/menus, real mouse drag/drop, listen-server/two-client convergence, and the owner's saved world remain untested for this build. Existing combat/transfer authority is retained; passing stubs/native API calls does not establish complete multiplayer acceptance. No Workshop upload or merge.

## Short owner test

1. Restart and confirm **0.2.55**. Open a powered Controller: Connections left, Map above Selected Device, Stockpile right.
2. Resize both menus smaller/larger; release outside the window. Check all module slots, Details, Load Order and narrow-window Stockpile. Close/reopen, then restart to check saved sizes.
3. Select a trigger/defense in the lists and map, pan/zoom, then toggle Native Map. Selection should not press the Button. Drag a trigger to a turret and check one connection; disconnect in Selected Device.
4. Transfer a head/module between Stockpile and Manage after resizing. Confirm the exact item and permissions remain correct.
5. Place and left-click a Button. It should use switch art and request one cycle. Check numbered names, duplicate custom names, and pickup/replacement/save-load preservation.
6. When multiplayer testing is available, repeat linking and transfers as owner, allowed faction/public user and disallowed user; confirm both clients converge.


## Package isolation

Traps-only, Turrets-only and both-package native startup pass in 133.9 / 130.2 / 128.2 seconds. These checks register shared controls once and verify the new switch Button definition in each package selection.


## Native save/reload result

The final write and fresh-process read runs pass. The read run confirms the normal-save display name, reserved number and private registry entry before creating new fixtures. Both runs retain device ownership/links, exact stockpile/ammunition contents, legacy Button migration and trap object identities. The late-shutdown barb fixture now restores its matching naming snapshot; its field comparisons pass. These are isolated zero-client probes.
