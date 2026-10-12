# Fix Module Pack viewport bounds, empty-pool drops and tooltip work

Inventory tooltips now reuse wrapped footer text. Module Pack reveals stay within the player's viewport with fixed controls and scrollable reward rows, and use native script metadata instead of constructing 29 temporary items. Empty reward pools suppress new packs; existing packs remain intact and recover when rewards are re-enabled.

Keeps the approved drop rates, weights and three-reward transaction. Regression audit runs in normal validation; native metadata/loot/inventory and save/load checks are recorded in [TEST_v0.2.47.1.md](TEST_v0.2.47.1.md). Owner-rendered acceptance and the older C171 capacity-warning investigation remain open. No Workshop publication.
