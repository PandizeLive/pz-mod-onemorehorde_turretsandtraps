The new Controller Connections widget used `update` for a helper that expected its parent window. Zomboid invoked it as the widget's native callback, causing repeated exceptions and severe UI slowdown during the owner's 0.2.55 test. The helper now has a distinct name, with a recursive UI-update regression covering the missed callback path.

Controller section scrollbars now use explicit bounds without deferred native anchoring. The in-game map opens by default, and the Grid toggle is removed. Existing server-authorized links, inventory transfers and combat behavior are preserved.

Validation passes 21,849 assertions plus native map and deferred-scrollbar-resize probes. Native save/reload and all three independent-package checks also pass. Installation evidence is tracked in [the version test record](docs/TEST_v0.2.55.1.md). Rendered and connected-client acceptance remain pending. The error storm is verified; single-core saturation and the final process-exit cause are not measured.

This draft continues the existing cumulative development branch into `dev`; no Workshop upload or merge is requested.
