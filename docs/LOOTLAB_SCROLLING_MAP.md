# C172 - LootLab scrolling map and bottom statistics

2026-10-12. Owner requests a map that follows scrolling and statistics at the bottom. Implemented as a hosted LootLab layout update; game 0.2.46 is unchanged.

The desktop/tablet tuning area contains the module sidebar and a CSS-sticky map panel. The map toolbar follows with it, below the measured sync-banner height. The panel releases at the tuning area's end, before the statistics, without overlaying them. Its map height adapts to the viewport. All summary metrics, sample totals, town/pool tables, caveats and methodology occupy one full-width section below the tuning area. Statistics and Back to tuning links provide direct navigation.

At widths of 700px or less, the map retains normal page flow above the controls to avoid covering them on phones; statistics remain last. Existing Show/Hide controls remain sticky. No scroll handler, repeated probability calculation, reroll or account/schema change is introduced. The existing ResizeObserver updates the sticky offset only when the sync banner changes height.

Browser checks pass at 1360x900, 1024x600 and 390x844: middle/end module scrolling, map visibility and release boundary, full-width bottom metrics, unchanged generated sample on scroll, mobile order/overflow and no page errors. The direct-weight browser suite also passes (saved values, edits, import/export, reset and visibility). All 77 API/page tests pass. Initial checks caught a map/statistics overlap; the tuning-only parent now bounds sticky positioning. [Deployment evidence](../diagnostics/loot-layout/release.json).

C171 game tooltip/capacity/unit-format findings remain pending; packing remains abandoned. No gameplay test acceptance or game patch is implied. **Test now:** refresh LootLab and scroll down the module controls; statistics follow at the bottom.
