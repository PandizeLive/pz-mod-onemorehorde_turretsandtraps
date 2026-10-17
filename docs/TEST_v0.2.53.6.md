# 0.2.53.6 — verification and focused owner test

C300, 2026-10-17. Corrects C297 owner findings against 0.2.53.5 and implements the approved copper-orange C299 choice. Owner has not tested this build yet.

## Automated verification

- Full validator passes **20,986 assertions**, compiling 215 runtime/translation inputs and loading 994 translated keys. Package manifest contains 288 source files and 367 generated package files.
- Tests cover nearby offline/unassigned physical Stockpile transfers, exact destination/callback retention, full storage, removal restrictions, favorites, unauthorized access, mismatched/expired remote sessions and cancellation. Existing 600-round transfer test still schedules 30 bounded batches; test-double timings are not an in-game performance measurement.
- Actual installed native `ISButton:setEnable` behavior is exercised, including its mutable background setters. Actual installed `ISInventoryPane` construction, native children and empty-container refresh run in Kahlua with UI adapters. Compact Controller page restoration and 600p Manage with Lure/Lobber controls are checked geometrically. These are not GPU rendering tests.
- Native dedicated write/read pass. C300 markers confirm exact backup-battery selection, replay/out-of-stock rejection, bidirectional offline-nearby head transfer, theft rejection and NetTimedAction construction. Exact stockpile/turret state survives save/restart. Probes have zero connected clients.
- Traps-only, Turrets-only and combined startup pass. Static package closure passes with 160 unique Sandbox options and 69 identical shared files. New optional Turrets-only dependencies are inside the existing turret-Manage callback or the explicit OMHTTTurret-container branch; Traps-only startup requires neither path. Shipped Lua passes the pcall/xpcall/ipairs/next call ban.
- During development, the new native button test exposed mutable shared colors, and the expanded compact-layout assertion caught a two-pixel frame overflow. Both were corrected and the full validator rerun. A package-check attempt stopped on a deliberately stale generated file during editing; packages were rebuilt and the isolation sequence restarted.
- Owner console is unchanged since the C297 0.2.53.5 session (266003 bytes; 2026-10-17 16:47:46 local). There is no 0.2.53.6 owner-test result to claim.

Installed from immutable `test/v0.2.53.6` / `c84fb616dc4e5c2cc376f6b0ec5aeaa51d6a5514`. All 288 source and 367 tagged/packaged/installed/archive files match; both 0.2.53.5 backups verify. [Release evidence](../diagnostics/v0.2.53.6/local-release.json). Rendered SP and connected dedicated/listen multiplayer acceptance remain pending.

## Short test

1. Restart with **0.2.53.6**. Open Manage and Controller: check copper-orange headers, red/white titles, separate action rows and normal title-bar dragging. Toggle turret power: red/off, green/on. Open/close **+ Details** and **Load Order**.
2. Stand beside Controller. Add a charged ordinary **Battery** through its new slot; try selecting a spare from Stockpile, then removing/reinserting it. Confirm power and charge update without a duplicate item.
3. Use the attached Stockpile to drag a head, module, magazine and ammunition into a nearby turret's Manage slots, then drag removable components back. Repeat from your inventory. Confirm HUD inventory stays where you left it and unrelated items cannot enter Stockpile.
4. Assign a turret a few tiles away, Open Manage through the powered Controller and repeat one transfer. Close both menus during/after a drag; reopen and check item counts. Report completion and any failure so **console.txt** can be checked.

No new horde stress test is requested. Connected dedicated/listen acceptance stays deferred; native zero-client probes are not that test.
