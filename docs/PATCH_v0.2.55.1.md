# 0.2.55.1 — Controller UI recovery

Owner reports a freeze/exit, repeated errors and a displaced scrollbar in 0.2.55, then suggests one overloaded CPU core. This corrective patch is within the existing implementation authorization. Owner also selects the in-game map as the normal Controller view.

- Controller update error fix
- Stable section scrollbars
- Default in-game map

The Connections panel's static `Graph.update(controller)` helper also became its native `update(self)` callback. Zomboid called it with the graph widget, which has no `graph` field, producing 454 identical exceptions in the captured owner log. The helper now has a distinct name and runs only from its Controller owner. No errors are caught or suppressed.

Connections, Selected Device and its nested input list use explicit scrollbar geometry instead of combining manual layout with deferred native anchors. Their bars retain the containing section's clipping. The native UIElement probe reproduces displaced anchored bars and verifies the corrected positions after successive resizes.

Controller opens its native visited-area map directly. The Grid/Native Map toolbar and grid drawing are removed. Map data loads once per open window; resizing and drawing reuse it. If the world disables map data, device positions and linking remain available on a plain background with an explanatory tooltip. Multiplayer permissions, action authority, inventories and combat rules are unchanged.

See [verification and short test](TEST_v0.2.55.1.md). CPU saturation was not measured; the repeated UI fault is confirmed, but the final process exit is not established as a native crash.
