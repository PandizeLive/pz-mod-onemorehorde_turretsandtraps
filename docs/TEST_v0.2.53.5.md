# 0.2.53.5 — verification and focused owner test

C296, 2026-10-17. Owner reports 0.2.53.4 launch slowdown solved, but Manage Details/scrolling and Controller reach require corrections. The clarification is explicitly **standing inside its world tile**, not merely having the Controller menu open. No complete acceptance of 0.2.53.4 is inferred.

## Automated verification

- Full Kahlua/native translation and asset validator: **20,989 assertions**, 209 compiled Lua/translation inputs, 985 translated keys. Layout/page/read-only/order tests use UI doubles; they do not establish rendered acceptance.
- Native server write probe passes adjacent access in six directions and diagonal edge handling; platform orders commit once, reject stale/cross-family requests, publish and survive pickup/redeployment. Native restart/read and Traps-only, Turrets-only and both-package startup checks pass.
- Static package closure passes: Traps/Turrets stay independent, 160 combined sandbox options and 66 identical shared files. No shipped pcall/xpcall.
- Owner console reviewed through its 0.2.53.4 shutdown at frame 56322: no T&T exception/stack overflow. Existing world metadata, missing vegetation tiles and another mod's skeleton warning do not prove this UI symptom's cause.

Rendered SP and connected dedicated/listen acceptance remain pending. Installed from immutable `test/v0.2.53.5` / `6de361a8db328f1b75d9c32ee7a011e6b7a42504`. All 285 source and 361 tagged/packaged/installed/archive files match; both 0.2.53.4 backups verify. [Release evidence](../diagnostics/v0.2.53.5/local-release.json).

## Short test

1. Restart with **0.2.53.5**. Open Manage, hover the Equipment/Ammunition/Modules headers, open **+ Details**, inspect **Module Stats**, then close Details. The main page must not scroll; drag the title bar normally.
2. Open **Load Order** with at least two bomb or spear types and some other-family ammunition in Void. Move one type up, Apply, reopen and confirm the priority stayed within its platform. Back must return to the same Manage window.
3. Stand beside the Controller. Select the Controller itself and try Access. Then add a charged ordinary **Battery** to its Stockpile (or provide electricity), select a turret, Assign it and Open Manage. Try this from both sides without entering the Controller's tile.
4. Pick up/reinstall the turret and reopen Load Order. Confirm priorities persist. If a control remains disabled, note its tooltip and the selected device; report completion so console.txt can be checked.

No new stress test is requested. Connected multiplayer testing remains deferred rather than claimed complete.
