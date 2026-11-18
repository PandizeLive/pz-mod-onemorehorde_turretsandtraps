# 0.2.36.1: turret recipe organization

C112 approves the correction after the 0.2.36 owner finding. OMH: Turrets keeps Turret Base and complete-turret recipes at the root, with Heads and Modules collapsibles; Modules includes expansion kits. OMH: Traps retains Normal/Reinforced/Packed. Building contains placeable defenses and the turret base at root, without component groups. Native icon view remains flat.

Grouping now respects both the OMHTT namespace and recipe category; known component recipes use explicit mappings. Unknown turret recipes remain native root entries rather than silently inheriting trap tiers. Exact recipes, inputs, output items, callbacks and filtered results are preserved. No combat, audio, assets, costs, timings or balance changed.

The [cross-system review](REVIEW_v0.2.36.1.md) records confirmed presentation issues, performance investigation paths and existing gameplay limits. Those recommendations are not implemented by this patch. The art brief and per-turn review guidance are synchronized.

Verification: 3,891 Kahlua assertions, 91 compiled runtime/translation files, 556 native translations and 23 packet serializations pass. Group tests exercise native list selection/collapse/filtering, root base/complete recipes, both head recipes, modules/expansion, hidden entries and Building separation. Release/install evidence is recorded in [RELEASE.md](RELEASE.md). Only the [short active test](TEST_v0.2.36.1.md) remains; it carries forward the unaccepted 0.2.36 rendered checks without reopening old full regressions.
