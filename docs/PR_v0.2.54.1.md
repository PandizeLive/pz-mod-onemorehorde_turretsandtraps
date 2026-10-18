# Controller input assignment and Legendary Siphon

New buttons and pressure plates automatically join the nearest writable Controller with capacity within 20 tiles on the same floor. Remote controls renew access immediately when selection/assignment/power changes and explain the actual restriction. Existing inputs can be assigned and linked from the Controller.

Siphon is corrected to Legendary loaded weight 3. The live LootLab catalog now includes all 32 controls and preserves saved tuning; deployed production code and access/public endpoints were verified.

[Contract](CORRECTIONS_C310.md) · [Patch](PATCH_v0.2.54.1.md) · [Tests](TEST_v0.2.54.1.md).

21,655 assertions, native save/reload, all three independent package startup and LootLab desktop/mobile checks pass; 86 backend tests pass. Headless native checks do not establish connected multiplayer or rendered acceptance. No Workshop upload or merge.

Installed from immutable `test/v0.2.54.1` / `0a65f67ad2cd3a3eb0ff417ec7eae255e9b5ae1f`. All 293 source and 374 tagged/packaged/installed/archive files match; both 0.2.54 backups verify. [Release evidence](../diagnostics/v0.2.54.1/local-release.json). Development delivery uses the existing branch and draft PR #1 under C108.
