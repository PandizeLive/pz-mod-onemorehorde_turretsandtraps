The new Controller Connections widget used `update` for a helper that expected its parent window. Zomboid invoked it as the widget's native callback, causing repeated exceptions and severe UI slowdown during the owner's 0.2.55 test. The helper now has a distinct name, with a recursive UI-update regression covering the missed callback path.

Controller section scrollbars now use explicit bounds without deferred native anchoring. The in-game map opens by default, and the Grid toggle is removed. Existing server-authorized links, inventory transfers and combat behavior are preserved.

Validation passes 21,849 assertions plus native map and deferred-scrollbar-resize probes. Native save/reload and all three independent-package checks also pass. The installed test/v0.2.55.1 build matches all 298 source and 383 packaged files; both previous-version backups verify. See [the version test record](docs/TEST_v0.2.55.1.md) and [release evidence](diagnostics/v0.2.55.1/local-release.json). Rendered and connected-client acceptance remain pending. The error storm is verified; single-core saturation and the final process-exit cause are not measured.

This draft continues the existing cumulative development branch into `dev`; no Workshop upload or merge is requested.

Planning and acceptance: [Current status](docs/CURRENT_STATUS.md), [Planning](docs/PLANNING.md), [C324 correction](docs/CONTROLLER_MAP_C316.md#c324--controller-error-storm-scrollbar-correction-and-in-game-map-2026-10-18).
