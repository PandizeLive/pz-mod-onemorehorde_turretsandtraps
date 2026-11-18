# Test 0.2.56.1

## Automated and native evidence

- Full installed-42.21 Kahlua/API/content/package validation: **23,751 assertions passed**; final result in [validation.log](../diagnostics/v0.2.56.1/validation.log).
- UI tests cover four columns, saved order, locked labels, compact and expanded layouts, Add Group bounds, disabled out-of-reach writes and collapse/restore. Geometry traces were rendered and inspected; they are test-double traces, not native GPU screenshots.
- Native UIWorldMap consumes the right-button down/up pair exactly once without parent click-through; individual/All disconnect callbacks are covered by the controller workflow tests.
- Native dedicated-server write/read probes use real world objects and inventory. C330 turns, reloads and consumes exactly one real potato after repeated presses, then powers off. Fresh-process save/restart passes. No player connected.
- Trigger regressions cover SP/server paths, plate release, reload/aim/cooldown, repeated presses, manual Off/rearm, empty supply, expiry, final-link removal and rotary-pass completion.
- Independent Traps-only, Turrets-only and combined startup results are recorded alongside the version manifest. Existing native fixture/world-generation warnings are not represented as new mod failures.
- Shipped Lua banned-call/style checks pass. Cycle requests are bounded to one per active receiver; contents reuse existing caches. Window chrome geometry changes only when window dimensions change. No background global polling or new network command was added.

Rendered appearance, connected-client input/combat replication and owner acceptance remain pending. Do not infer those from these checks. Existing broader multiplayer test debt is retained.

## Combined owner test — Test now after installation

1. Restart and confirm **0.2.56.1**. Right-click a turret repeatedly; confirm no new error counter and no Fire context entry.
2. Open Manage with and without expansion. Confirm **4/4/4/4**, saved module order, one centered Unavailable label, expansion hint and working Details. Resize both menus; inspect headers, buttons and Stockpile edges.
3. Try close, pin/collapse and keep-open lock. Walk out of reach: a locked window may remain visible, but equipment changes and controls must be unavailable.
4. Add/rename a group. Link two triggers to a defense, then right-click its map marker: disconnect one, then All. Repeat from Connections and confirm both views update.
5. With ammo, battery and Firing installed, press a Button during turning/reloading, then repeat with a Plate and step off immediately. Confirm the accepted action finishes with one shot before power-off; rapid Button presses must not queue later shots.
6. Repeat with a rotary head, then manually turn Off during an action. The normal release finishes its pass; manual Off stops immediately. Send console.txt and any screenshots if behavior differs.

Fresh worlds remain the supported test policy. Keep the immutable 0.2.56 rollback snapshot; do not claim successful Workshop publication.

## Local installation

Installed 2026-10-19 from immutable `test/v0.2.56.1` / `9b43b46f8db940360edaba9980d3d3866ebc640f`. All 303 source and 393 tagged/package/install/archive hashes match. Both 0.2.56 backups verify. [Release record](../diagnostics/v0.2.56.1/local-release.json). No Workshop publication; owner and connected acceptance remain pending.

## Owner availability — 2026-10-19

Owner cannot test now. The six-step check is deferred, not failed or passed. No new console inspection is represented as an owner test; installed 0.2.56.1 and automated evidence are unchanged.
