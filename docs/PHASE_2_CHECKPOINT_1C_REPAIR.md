# P2C1c/d correction and Sandbox tuning - 0.2.3

Owner-authorized repairs follow the [failed 0.2.2 test](TEST_v0.2.2.md). The owner also requests configurable damage/HP and basic damage 10. Recipes, XP, free ten-second servicing and full-condition pickup remain unchanged.

## Implemented

- Resolve server-only modules when the service menu/action is used, after world startup. Single-player, identity, distance and duplicate-completion guards remain.
- Native destruction immediately retires both ledger slots. Clean remaining native parts outside the removal callback, through the existing four-slot update budget or on tile load. Exact identity protects replacements/unrelated objects. No recursive native removal during the callback.
- Bundle tooltip says `67 percent` to avoid the native formatter failure. Description logs emit once per changed content instead of once per layout measurement.
- Native Sandbox **Spike Barrier Damage**: integer 0-1000, default 10. Zero disables retaliation. **Spike Barrier Maximum Durability**: integer 1-10000, default 100. Bounds are implementation choices.
- Both tiles share one configured HP pool. New builds/deployments use the maximum. Existing records without a maximum assume 100. Reconciliation first applies outstanding wear on both halves, then preserves remaining percentage on maximum changes, rounding to the nearest integer with at least 1 HP for a living barrier. Incomplete/unloaded pairs wait until both parts load. Repair restores the configured maximum.
- Selected build/craft/deploy descriptions show current settings; static hover text points to Sandbox settings. World menus show actual remaining/shared maximum HP. Startup/migration logs expose effective settings.

## Verification and limits

337 Kahlua assertions pass: 18 runtime modules, 85 native translation keys, 23 native packet serializations. New cases load shared/client service entry points before server modules, use installed ISBaseTimedAction, reject nested removals, validate native formatter patterns, and cover configured/zero damage, combined wear, maximum changes, old saves, restart and repair. Actors, world objects and UI/font metrics remain doubles.

Installed B42.20.4 natively loads the integer Sandbox defaults and zero-argument bundle tooltip, executes existing recipe and pack/unpack transactions, and saves/restores 16 native object streams at **37/200 HP**. Separate write/read processes passed in **33.9/33.9 seconds**, with clean shutdown. Logs: `diagnostics/v0.2.3/`. The first fixture run failed the new maximum assertion because its objects still used the native default; corrected fixtures explicitly set 200. This was a fixture setup failure, not player testing.

Real SP menus, walking/progress/cancel behavior, zombie destruction and rendered descriptions still require the owner test. No player has loaded 0.2.3 yet. Vaulting and its 20% front scratch roll remain the next collision/animation prototype; current barriers still block vaulting. MP acceptance remains deferred.

## Complete owner test

1. Fully restart into **0.2.3** on a disposable SP save with Diagnostic Logging and Foundation Test Controls on. Confirm the version in the developer menu. Keep at least 6 free inventory capacity and five loose barriers for the bundle test; leave crafting/building cheats off for recipe checks.
2. In OMH Sandbox settings, check Damage **10**, Maximum Durability **100**. Select barrier craft/build/deploy entries and resize the menus: purpose and statistics should remain readable. Both native and Turrets & Traps categories should work. Hover the pack entry without an error flood.
3. Use Foundation Test -> Set test condition to 37 on a built barrier. Right-click either half -> Spike Barrier: expect **37/100**, Pickup and enabled Repair. Begin Repair, then walk away: no healing. Retry while still: ten seconds, then **100/100**, no materials/XP.
4. Damage it again; begin Pickup and cancel by walking, then complete it. Both halves disappear and exactly one fresh item enters inventory after ten seconds. Redeploy at full HP without extra materials/XP. Pack five barriers: one pack weighing 9.9; unpack: five barriers, no XP.
5. Let zombies thump front/side ends: approximately **10** actual damage per strike in Pixel Indicator (final killing damage may be smaller). Rear strikes should do none. Let a barrier be destroyed: both halves disappear without errors or leftover collision.
6. On a separate disposable Sandbox test, set Damage **5**, Maximum Durability **200**. New builds, selected descriptions and world menus should agree; Repair restores 200. If your existing setup supports changing Sandbox settings on a save, a 37/100 barrier should become 74/200 after reconciliation. Otherwise leave migration to the automated evidence.
7. Save/reload and check remaining condition/settings and item counts. Say **Test Complete**. I will review `console.txt` for loaded version, actions, damage, cleanup and restoration. Vaulting is not part of this test.

## Release

Use OMH.cmd, annotated test/v0.2.3, a matching archive/manifest and full managed backup of 0.2.2. No remote or Workshop publication. [Install evidence](RELEASE.md).
