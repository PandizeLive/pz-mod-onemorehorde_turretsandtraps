# P1C1 implementation and test record

## Identity and authorization

- State: implemented; awaiting player evidence, not accepted.
- Approved by the owner after the concrete P1C1 proposal on 2026-09-25.
- Package: `OneMoreHorde_TurretsAndTraps`, version `0.1.0-p1c1`, version directory `42.20`, accompanying `common` directory.
- Installed game: **42.20.4**, revision `b0bbce05d5`, Steam build `24909800`, with PZ Optimizer overrides. The engine's `getCore():getVersionNumber()` reports `42.20`; the dedicated startup log supplies the full patch/revision.
- Original recommendation: Medium reasoning; Fast for the estimated 30-60 minute implementation/check pass.
- Scope: this project's shell, technical cube sprite, validation/installation tools and docs. No sibling edits, gameplay combat, final art or publication.
- Source identity: [package/file and game-source SHA-256 manifest](../../diagnostics/p1c1/manifest.json). A matching package ZIP is retained in `artifacts/OMHTT-0.1.0-p1c1.zip`.

## Implemented behavior

The default-OFF Foundation Test Controls Sandbox option enables a temporary context menu. SP can use it; MP additionally requires the engine's `UseDebugContextMenu` capability. Server checks independently enforce permission, live sender, package version, finite integer coordinates, same floor, nearby loaded floor and clear placement space.

A placed object starts at condition 100 and receives a monotonically allocated `test-N` identity. The menu can set condition to 37, inspect the exact object, remove it, or replay the last mutation for duplicate protection testing. It cannot submit arbitrary damage, rewards or condition values. The owner string is a temporary diagnostic identity, not final faction ownership or access policy.

Authoritative state lives in server global ModData; the engine separately saves the IsoObject and its namespaced marker. Its exact object name plus marker ID/schema identify it, independently of sprite or object-list index. Unrelated objects sharing a tile or sprite are not selected. Client commands submit expected ID/revision/tile epoch, and the server rejects stale mutations. Retained tile epochs reject old placement requests even after removal and restart. The prototype ledger is deliberately limited to **64 distinct tiles per test world**, including removed locations; this is not a gameplay balance limit.

LoadGridsquare performs one tile lookup and inspects objects only for a tracked active device. No periodic world scan, per-device tick handler or persistent Java reference is used. A matching object receives the authoritative condition. Missing or duplicate identities produce a conflict diagnostic without recreation, deletion or condition reset. Native object removal retires the matching record. Disabling test controls preserves existing state.

The model is represented by a static transparent sprite rendered directly from the approved white cube geometry. This proves neither native 3D model import nor head rotation. No final art was produced.

## Current-build evidence

Installed source root: `C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid`.

| Choice | Inspected evidence |
| --- | --- |
| Native global-object alternative | `media/lua/server/Map/SGlobalObjectSystem.lua`: registration, loading, chunk cleanup and object mutation callbacks. Its default square-based selection requires additional identity overrides; the small indexed registry keeps this checkpoint narrower. |
| Server global ModData | `media/lua/server/Vehicles/ProfessionVehicles.lua`: `ModData.getOrCreate` and `OnInitGlobalModData`; current ModData API and packet behavior. No incoming global table is stored by this mod. |
| IsoObject creation/removal | `media/lua/server/Camping/SCampfireGlobalObject.lua`, `addObject`/`removeObject`; `IsoObject(square, sprite, name)`, `AddTileObject`, `transmitCompleteItemToClients`, `transmitRemoveItemFromSquare`. |
| Identity/sprite persistence | Current installed `IsoObject` constructor and `save/load` bytecode: custom object name, sprite name and modData are serialized; missing sprite lookup falls back to the stored texture name. [Captured bytecode](../../diagnostics/p1c1/IsoObject.javap.txt). |
| Plain texture loading | Current `IsoSpriteManager.getSprite/AddSprite` and `IsoSprite.LoadSingleTexture`. The code does not call the Lua `getTexture` helper with a dotted sprite name. |
| Role permission / menu | `media/lua/client/DebugUIs/DebugContextMenu.lua`, `doDebugMenu`, uses `UseDebugContextMenu`; native world context menus and `ISModalRichText` provide the temporary UI. |
| Named command reply | `media/lua/server/ClientCommands.lua`, server-bound sender and targeted `sendServerCommand`; SP uses the same server handler and vanilla OnServerCommand event. |

Published API cross-checks: [IsoObject](https://projectzomboid.com/modding/zombie/iso/IsoObject.html), [ModData](https://projectzomboid.com/modding/zombie/world/moddata/ModData.html). Installed source/bytecode and actual load logs take precedence for this build.

## Verification

| Check | Result / limitations | Evidence |
| --- | --- | --- |
| Installed Kahlua compilation | Six runtime and translation files passed. | [Validation log](../../diagnostics/p1c1/validation.log) |
| Lifecycle, permissions and client flow | 38 assertions passed: duplicate/replayed placement, native table serialization, save reconstruction, unavailable tile/return, authority repair, permission/toggle/version/range/floor checks, malformed input, exact removal, stale replacement requests, conflicts, bounded ledger and SP/MP UI command flow. World/player/UI/network delivery are doubles. | [Tests](../../tools/tests/server.lua), [client tests](../../tools/tests/client.lua) |
| Native packet serialization | 22 captured request/reply packets; largest 263 bytes. This verifies serializability, not live transport or ordering. | [Kahlua runner](../../tools/KahluaCheck.java) |
| Package checks | BOM/indentation, translations, original grayscale/transparent sprite and file hashes passed; sprite visually inspected. | [Validator](../../tools/validate_foundation.py), manifest above |
| Real dedicated load and save | Isolated localhost server loaded the package, initialized its registry, reached SERVER STARTED, saved GlobalModData and quit. Initial missing empty AnimSets/actiongroups directories were added. | [First startup](../../diagnostics/p1c1/server-start-first.log) |
| Real dedicated restart | Corrected package loaded the existing test save, reached SERVER STARTED, saved and shut down cleanly. No player connected and no device was placed in this run. Existing vanilla sound/property/map warnings remain; no OMHTT Lua exception was observed. | [Restart console](../../diagnostics/p1c1/server-restart-console.log) |
| Local installation | Installer tested in an isolated destination and installed to `C:/Users/bandi/Zomboid/mods/OneMoreHorde_TurretsAndTraps`; all package hashes verified. | Installed `.omhtt-foundation-install.json` |
| SP player lifecycle/rendering | Pending owner test below. | Pending |
| Dedicated connected-player lifecycle | Pending after first SP result; startup smoke does not satisfy this criterion. | Pending |

The final package adds an `origin=load` versus `origin=inspect` reconciliation diagnostic after the dedicated smoke; compilation/behavior checks and installation were rerun. Runtime logic is otherwise unchanged from the restart smoke.

## Owner test: single-player first

1. Restart PZ, enable **OMH: Turrets & Traps - Foundation Test**, and create a disposable Custom Sandbox world with **OMH: Turrets & Traps > Foundation Test Controls** ON. Use this test mod alone. The context menu must show **0.1.0-p1c1**.
2. Stand beside a clear floor tile, right-click it and choose **OMH Foundation Test > Place test cube**. Expect one white cube device and condition **100**. Record its ID and coordinates from the report.
3. Reopen the same menu and choose **Repeat last change request (test)**: expect an old-request rejection and still one device. Then choose **Set test condition to 37**, followed by **Inspect this tile**; authority/local condition should both be **37** and agree.
4. Quit to the menu, reload the save and inspect that tile. Expect the same ID, condition **37**, and one matching object. No duplicate or refill should appear.
5. Travel roughly **300 tiles away**, return and inspect again. Expect the same state. The later log review will check for `origin=load` evidence; distance alone is not proof that streaming occurred.
6. Choose **Remove this test device**, replay that removal, then quit/reload and inspect the original tile. Expect no test device, count **0**, and condition **-1** for empty state; nearby ordinary objects remain.
7. Report pass/fail and the recorded ID, plus any missing sprite, disagreement or error. Leave `C:/Users/bandi/Zomboid/console.txt` and the latest `Logs` available for inspection before another run replaces them. Dedicated connected-player acceptance is still required before marking P1C1 complete.

## Rollback and next checkpoint

This is a disposable test-world schema, not a promised public save migration. To stop testing, disable the test control or disable this mod for subsequent test-world loads. Disabling the control does not delete devices. Remove test devices through the exact-device menu before retiring a test world; never use a broad sprite/type cleanup. The installer backs up any earlier managed installation and refuses to overwrite an unmanaged one. No existing production save/server settings were changed.

No Workshop item, upload, gameplay integration or score policy changed. There is no Workshop release baseline to reset and no public gameplay changelog is advertised for this developer test. P1C2 remains blocked on this checkpoint's acceptance evidence, not merely a successful compile.

Handoff: **Test now** for the SP sequence above. P1C1 remains awaiting player evidence.
