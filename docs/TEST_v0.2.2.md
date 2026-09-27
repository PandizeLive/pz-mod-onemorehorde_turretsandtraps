# 0.2.2 owner test review — failed acceptance

Captured 2026-09-27 from `diagnostics/captures/20260927-021736-2035/console.txt`. Both recorded sessions loaded 0.2.2 on B42.20.4 with PZ Optimizer. [Machine review](../diagnostics/v0.2.2/owner-test-review.json) records the console SHA-256 and counts.

- Nine world-menu exceptions: `BarrierMenu.fillMenu` indexed `slot` on nil. Shared `BarrierServiceAction` and client `BarrierMenu` required server-only modules before their paths were registered; cached local nil references persisted. No service completed. Repair/pickup acceptance failed.

- 8,529 bundle tooltip formatter warnings: the literal percent in `67%.` reached the native formatter. The previous translation harness supplied dummy arguments and did not fail on the formatter warning path.

- Six native destruction exceptions: removing a sibling during `OnObjectAboutToBeRemoved` re-entered native multi-tile removal and removed the engine's in-progress object. The game rejects that. Installed `IsoGridSquare.RemoveTileObject` and `IsoObjectUtils.safelyRemoveTileObjectFromSquare` bytecode confirms the guard and grouped removal path.

- 6,724 repeated description-layout messages obscured useful diagnostics. Native layout measures multiple widths; log the description only when its content changes.

- Barrier combat and shared wear were observed, but that does not compensate for the service/destruction failures. Vaulting was explicitly deferred in 0.2.2 and was not present.

0.2.3 resolves server dependencies at action/menu use time, retires ledger identity immediately but defers remaining native removal to bounded scheduling, fixes the tooltip wording and deduplicates layout logging. Regression tests now load the shared/client service entry points before server modules, use installed ISBaseTimedAction, prohibit nested world removals and validate formatter patterns directly. Rendered UI, timed action movement/progress and actual zombie destruction still require the new player test.

