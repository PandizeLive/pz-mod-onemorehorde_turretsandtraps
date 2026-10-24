# 0.2.66 verification and owner checklist

Scope: C444 selects the C443 selective tuning table with C438/C440 management and tooltip corrections. Previous installed baseline: test/v0.2.65 / 8a977bc60ea4845646f8bfb20a8eb7d7cd4b5f19. No new owner playtest is claimed.

## Automated evidence

- Stock-game Kahlua/packaging validation: **27,678 assertions**, 329 runtime/translation files compiled, 1,456 native translation keys, 422 source files and 574 packaged files. Source SHA-256 manifest is in diagnostics/v0.2.66/manifest.json.
- Selected first/sixteen-copy coefficients, zero-copy behavior, saved custom duplicate values and the removed ordinary bonus floors/ceilings are checked. Fractional Conservation consumes ten physical rounds over 95 uses at 9.5, with a mid-sequence native table save/restore.
- Regression checks cover inactive Grid/Siphon/Void/Firing/Detection and battery surcharge, serialized priority, sorting without activation changes, exact-item kit swaps, replay/access/favorite rejection, interrupted batches, final exchange rollback, partial floor-delivery failure and full-inventory fallback.
- Icon/text rectangles remain separate across four font heights and compact/tall cells. Feature continuation stays grey, consumption labels stay white while their values use rating colors, and following stats return to white. Native tooltip wrapping is cached over 600 frames. These are UI geometry/render-call checks, not GPU screenshots.
- A 7,809-tile configured acquisition range over a 3x3 loaded island visits exactly 25 squares in four bounded slices. Existing mixed-device, transfer and proc stress regressions pass. This does not establish gameplay FPS.

## Native engine evidence

The dedicated native probe uses the installed stock game classes, actual InventoryItem/ItemContainer/IsoThumpable objects and zero connected clients. It confirms exact kit identity, thirteen returned rounds plus the old kit on the native floor, magazine/chamber/extended-feed conservation, preserved fractional debt, cancelled stale load timers, inactive effect filtering, saved module order through pickup/redeployment and seven retained native timed-action constructor arguments, including the native null sentinel.

Write/start/save/shutdown passes in **53.8 seconds**. Fresh-process read passes in **65.0 seconds**. Traps-only (**59.1s**), Turrets-only (**53.5s**) and combined (**76.6s**) startups pass with clean shutdown. Exact constructor argument comparison recognizes the native null sentinel rather than treating it as a lost optional argument. Earlier attempts exposed outdated test assumptions for selected coefficients, cached wrapped tooltips, a synthetic full-inventory fixture and native null argument encoding. The current checks retain the relevant invariants; errors were not suppressed. Partial-return failure handling was explicitly corrected and tested before native delivery.

## Delivery

Installed from immutable **test/v0.2.66 / 7d56836bc097711ee426e0fdda9bf8a3598bbf76**. All **422 source and 574 package/tag/install/archive files** match their SHA-256 manifest. Both managed 0.2.65 backups verify (219 Traps files / 351 Turrets files). Installer backup: `C:\Users\bandi\Zomboid_Modding\OMH\Turrets & Traps\diagnostics\p1c1\install-backups\20261024-114857-0231`. Archive SHA-256: `54c5b971cc01299be953f9850474494ff92dd5960a078aa83148a6aa2407440a`. Local proof: diagnostics/v0.2.66/local-release.json. Workshop and hosted LootLab are unchanged.

## Owner checklist

- First-copy and duplicate module bonuses
- Expansion swaps and ammunition overflow
- Inactive modules and saved activation order
- Rarity sorting, Details and window resizing
- Tooltip colors and wrapped feature text

Existing saved Sandbox values are preserved; use fresh defaults to assess the selected duplicate tuning. Rendered UI, listening, live balance, active Horde Night integration, stress FPS and connected dedicated/listen multiplayer acceptance remain pending. **Test now** after restarting when available.
