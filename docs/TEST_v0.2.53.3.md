# 0.2.53.3 verification and short test

**C292 audit:** five additional integration defects reproduced; see [findings](AUDIT_C292_v0.2.53.3.md). Owner test remains deferred. Installed0.2.53.3 is unchanged; recommend correcting these before running the retained short test.

## Automated evidence

Full validator:20,909 assertions;205 runtime/translation compilations;283 Source and357 package files (134 Traps,223 Turrets);297 literal translation references. Native UIElement coordinates and installed Lua scrolling initialization are exercised. UI checks cover aligned sections, equal Ammo/Void, adjacent actions, fixed name/footer, accessible Details, nested stencil bounds and600px viewport. Name tests cover Enter-plus-blur deduplication, blur saving, blank gray placeholder and read-only rejection. Stockpile tests cover unrelated-item rejection,500-weight batch admission and unchanged ordinary inventory behavior. Multiplayer authority/serialization and existing regression checks remain included.

Native stock-jar write/read checks pass: Controller radio-to-cube conversion and valid facing metadata, supply admission, unrelated-item withdrawal, exact250-item heavy stockpile save/reload and5,000-round preservation. Traps-only, Turrets-only and combined startup pass (52.2s/47.8s/45.7s). Both texture packs decode, including all80/25 sprite identities across33 pages. Installed from immutable `test/v0.2.53.3` / `9aab2905ab6e003654e1ac1e7f4df1e51ab623b5`; all283 source and357 tagged/packaged/installed/archive files match, and both0.2.53.2 backups verify. [Verified release hashes](../diagnostics/v0.2.53.3/local-release.json). These probes use zero connected clients; rendered and connected-client acceptance remain pending.

Probe maintenance: the heavy stockpile fixture now uses249 allowed two-weight panels plus its battery instead of rejected planks; persistence expects250 exact items. Texture-pack checks include the eight new Controller identities and two independent texture pages. A reused native save cache restored the proc test's prior one-second injury guard; that test now explicitly clears only its fixture player's guard before checking two immediate hits. No production combat behavior was changed for this test isolation.

## Test now

1. Restart and confirm **0.2.53.3**. Open Manage; scroll both ways. Slots and headers should move together. Expand **Details** and view **Installed Modules**.
2. Rename with Enter, rename by clicking away, then clear it. Reopen: automatic name should appear gray; weight stays beside it. Check adjacent **Reload / Load Order**.
3. Open the cube Controller and drag/release both windows. Its own selection has no rename field. Open a linked turret's Manage.
4. In the native stockpile, try a module/ammo/battery and a shirt/plank: only supplies should enter. Take an existing unrelated item out; close/reopen the windows.

Capture console after the report, including any repeated cleared-action warning. Connected two-client acceptance remains pending; no repeat combat/balance test here.
