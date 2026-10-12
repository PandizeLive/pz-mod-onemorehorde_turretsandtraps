# Conservation, native ammo batching and compact Manage (0.2.43)

Large ammunition transfers repeatedly scanned the turret inventory, while Manage disabled native batching. Both paths now use bounded native preparation and private operation-scoped acceptance summaries; Manage groups light ammo up to 20 items with matching native duration and exact ownership/limits. The approved optimization pass also reduces trap reconciliation, contact lookups, duplicate stat resolution, renderer housekeeping and ray/debug queue work.

Adds the loot-only Conservation Module and matching LootLab catalog, compact 4/6/6 Manage layout, grouped Installed Modules effects with per-row details, and a battery-local cost/volley/runtime tooltip. Fractional ammunition progress persists on the exact head without changing power per volley or Impact's empty-reload rule.

[Planning](PLANNING.md) | [approved contract](checkpoints/R3_AMMO_SAVER_MANAGE.md) | [patch](PATCH_v0.2.43.md) | [tests](TEST_v0.2.43.md) | [release evidence](RELEASE.md).

Automated/native evidence and isolated transfer timings do not certify rendered layout or dense-client frame smoothness. One focused owner round is pending. SP only; no Workshop publication or merge.
