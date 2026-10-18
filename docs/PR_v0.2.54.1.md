# Controller input assignment and Legendary Siphon

New buttons and pressure plates automatically join the nearest writable Controller with capacity within 20 tiles on the same floor. Remote controls renew access immediately when selection/assignment/power changes and explain the actual restriction. Existing inputs can be assigned and linked from the Controller.

Siphon is corrected to Legendary loaded weight 3. The live LootLab catalog now includes all 32 controls and preserves saved tuning; deployed production code and access/public endpoints were verified.

[Contract](CORRECTIONS_C310.md) · [Patch](PATCH_v0.2.54.1.md) · [Tests](TEST_v0.2.54.1.md).

21,655 assertions, native save/reload, all three independent package startup and LootLab desktop/mobile checks pass; 86 backend tests pass. Headless native checks do not establish connected multiplayer or rendered acceptance. No Workshop upload or merge.

Installed from immutable `test/v0.2.54.1` / `0a65f67ad2cd3a3eb0ff417ec7eae255e9b5ae1f`. All 293 source and 374 tagged/packaged/installed/archive files match; both 0.2.54 backups verify. [Release evidence](../diagnostics/v0.2.54.1/local-release.json). Development delivery uses the existing branch and draft PR #1 under C108.

Planning: [C321 revised Controller layout](CONTROLLER_MAP_C316.md#c321--full-height-stockpile-on-the-right-wider-map-2026-10-18) moves Stockpile into a full-height far-right column beside the wider Map and Selected Device. Connections remains full-height on the left. Separate Controls, Connections, and Access & Assignment groups, head subtitles and Stockpile styling remain. Layout, independent scrolling/wire alignment, mouse/touch and responsive checks pass. [C318 naming/Button audit](CONTROLLER_MAP_C316.md#c318--visual-approved-identity-and-button-corrections-2026-10-18) identifies missing world-wide display-name uniqueness and left-click activation. First Button #1, duplicate suffixing and a temporary native light-switch graphic remain required next-patch corrections. These gameplay changes are not implemented in the preserved 0.2.54.1 build.
