# 0.2.53.1 verification and short test

## Automated checks

Full validator passes **20,856 assertions**, 199 Lua/runtime/translation compilations, 280 source files and 351 package files (131 Traps, 220 Turrets), with 302 literal translation keys.

New checks cover: native 42.21 `tostring`/UI path formatting on Controller and its name entry; separate title hit area; Equipment/Modules visibility and scroll reset; fixed title/footer during expanded Details scrolling; non-overlapping content; dedicated scrollbar gutter; equal reserves and retained 4/6/6 slots; contextual Controller actions; stockpile replacement and parent/remote-Manage cleanup; one Controller per player; large-font details in a 600px-high viewport. Existing server authority, permissions, remote sessions, exact-item transfers, ammo/Void, plate links and combat/Horde regressions remain included.

Native write/read persistence passes with clean shutdown and no connected clients. Traps-only, Turrets-only and both-package native startups pass (121.2 / 120.1 / 125.0 seconds). Final validation includes the Controller ammo/weight overview and native backup meter; these UI callbacks do not alter the server code exercised by the persistence probes. The initial package pass was stopped before startup by the stale-generated-file guard while the final UI refinement was underway; regenerated packages passed all three selections.

Installed through root OMH.cmd from immutable `test/v0.2.53.1` / `983dcf13217f7f2b20b96366e406d74bc8d3f0e8`. All280 source and351 tagged/packaged/installed/archive files match; both0.2.53 backups verify. [Machine-readable release evidence](../diagnostics/v0.2.53.1/local-release.json). Archive SHA-256: `1cb8ab19e7eb95db29416380f8be665450b2363c6ba63b80bc694e763b082552`.

Rendered and connected-client acceptance remain pending. The retained owner console from C286 is pre-patch evidence, not a successful retest.

## Test now — four checks

1. Restart and confirm **0.2.53.1**. Open Turret Manage, drag its title bar, and switch **Equipment & Ammo / Modules**. Check spacing and **Details**; scroll if needed.
2. Confirm **Load Order**, **Reload**, power and range still work; inspect one module tooltip/benefit. Lure/Lobber controls should appear only when applicable.
3. Open Controller, select/assign a turret, rename it and open remote Manage. Select a plate too: the available actions should change to match it.
4. Open/reopen the stockpile from Controller and remote Manage; move one item, then close the parent. No duplicate/orphan window or black screen. Close/reopen Controller once more.

After the report, capture and review console.txt for the loaded version and errors. Connected multiplayer remains a later two-client check; this corrective test does not require repeating damage, capacity or persistence balance tests.
