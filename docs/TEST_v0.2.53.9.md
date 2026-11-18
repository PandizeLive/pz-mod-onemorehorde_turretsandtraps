# 0.2.53.9 — Verification and short test

C305, 2026-10-17. Approved context-aware silhouettes using ordinary icons drawn black. C306 below records the subsequent owner feedback; it is not blanket acceptance.

## Automated verification

Full validation passes 21,529 assertions, 217 compiled Lua/translation inputs and 997 translation keys. Static closure passes 160 Sandbox options and 70 identical shared files. Native write/read and Traps-only, Turrets-only and combined startup pass. No connected clients participated. The first expanded head-swap fixture exposed missing methods in its Spear script double; completing that fixture fixed the test. A runner log-file lock was also corrected before the successful rerun. No runtime fault was masked. Focused checks cover empty/occupied/locked/not-needed states; native draw RGBA and bounds; zero hint-item creation; texture lookup caching; missing and multi-icon modded scripts; swaps among Potato, Ballista, Scrapshot, Lobber, rotary and firearm heads; matching calibre/removable magazine; absent versus installed Void; and preserved Controller battery counting/deposits. Independent package closure is checked. UI/world objects in Kahlua are test doubles, and native dedicated probes have no connected clients.

## Short owner test

1. Restart with **0.2.53.9**. Empty Turret and Controller battery slots should show different black battery shapes; empty Head/Expansion/Module slots keep their labels. Custom icons may still be cubes.
2. Swap between Ballista, Scrapshot, Lobber and a gun: empty Ammo follows the head; only a gun needing a removable magazine shows its magazine hint. Rotary heads show no ammo hint.
3. Add/remove a Void Module and fill/empty supplies. Hints disappear when filled; next-load/next-shot counts remain readable. Drag a real item between Manage, inventory and Stockpile.
4. Check a locked module slot, open Details, and move both windows. No new overlap or clipping; black silhouettes remain visible on grey. Report findings; Codex will inspect console.txt.

## Delivery

Installed from immutable `test/v0.2.53.9` / `1c0aabbd367725329b9162acbe601b153842059f`. All 289 source and 369 tagged/packaged/installed/archive files match; both 0.2.53.8 backups verify. [Release evidence](../diagnostics/v0.2.53.9/local-release.json). Development delivery uses the existing branch/draft PR under C108; no merge or Workshop upload. Rendered and connected multiplayer acceptance remain pending.

## C306 owner feedback, 2026-10-17

Owner: "I think this is working!" Confirms pressure-plate activation, reports confusing linking and zombies thumping plates, and requests Controller world-click aiming for the next patch. Treat silhouettes/menu behavior as tentative positive feedback; do not claim every checklist state or connected multiplayer passed. R4C1 remains open for the plate correction and usability/aiming work.

Captured the current SP **0.2.53.9** console: 2,254,783 bytes, 10,047 lines, SHA-256 `7118cfb14b878abc234240888522c74e378c9a720b2ba4f28cb24f9be218c4fc`; last T&T diagnostic frame97167, sequence7287. No T&T Lua exception found. Present errors concern native fonts/tiles/map data, other script/assets and Firearms translation formatting. Logs do not independently prove the thumping behavior or rule out gameplay defects. [Review metadata](../diagnostics/v0.2.53.9/owner-review-20261017.json); full snapshot retained locally in diagnostics. [Next-patch contract and decision](CORRECTIONS_C306.md). Installed0.2.53.9 remains unchanged.
