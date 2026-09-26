# Phase 1 test repair and diagnostics

Date: 2026-09-25. Package: **0.1.2-p1debug**. Scope: inspect the owner's console/screenshots, correct evidenced faults, and add useful runtime diagnostics following Horde Night's tagged, Sandbox-controlled console logging. No artwork, sibling project or Workshop change.

## What failed

The owner console loaded `0.1.1-p1batch` on B42.20.4. It recorded a potato at `7820:11278:0`, barriers at `7818:11276:0` and `7821:11275:0`, plus two range rejections. No OMHTT exception or firing command appeared in the inspected run. The log alone could not explain rendering or missing menu text because those facts were not captured.

Both screenshots showed raw `ContextMenu_OMHTT_*` and `UI_OMHTT_*` keys. The package used obsolete `ContextMenu_EN.txt`, `UI_EN.txt` and `Sandbox_EN.txt`. This installed build's `Translator.tryFillMapFromFile` reads `media/lua/shared/Translate/EN/<category>.json`. The earlier validation wrongly treated compiling Lua translation tables and finding keys as sufficient evidence. It never exercised the native translation loader. That verification gap is corrected here.

The screenshots also showed the large diagnostic report covering the placed cubes. Routine mutations no longer open that report; they display a native player notification. Explicit Inspect still opens the full translated report. Failed requests previously printed `agreement=Agrees` when neither side had been compared; they now report `NotCompared`, and do not replace a useful existing tile snapshot with rejected empty state.

The first-object tile selection policy is now logged and displayed in the menu; a wrong-tile selection is not conclusively established by the old log. No speculative selection or collision rewrite was made. Cube geometry/art is unchanged. Per-thump retaliation and MP firing remain deferred.

## Diagnostics added

**Prototype Diagnostic Logging** defaults ON for this development package and is active only with Foundation Test Controls. Existing test saves with the new option absent also enable it. Logs use `[OMHTT-Diag]`, package version, SP/client/server side, sequence, wall-clock milliseconds, event and scalar fields.

- Startup translation audit reports 14 representative missing keys even when detailed logging is OFF; the validator checks all packaged strings through the native loader and formatter.
- Menu capture records picked objects, selected tile, mouse/viewport scale, player coordinates and up to eight picked-object descriptions.
- Each client request and authority result records command/request ID, exact tile/identity/revision/epoch, player distance, ammo, shot count, cooldown and whether world state was actually included.
- Object snapshots include native index, name, sprite/texture presence, dimensions/offsets, tile projection, marker state, and native barrier health/collision flags. Local marker agreement does not imply rendering success.
- Firing records attempt, bounded candidate decisions and obstruction reasons, search cap, before/after native hit stages, ammo and splash outcome. Effects record queue and first render coordinates once per effect.
- Lifecycle snapshots cover construction/attachment, reconciliation and removal. Scheduler summaries occur once per 600 ticks, without a diagnostic world scan.
- **Log nearby defense diagnostics** scans at most 25 nearby squares and 128 objects on demand. Detailed logs have a 120-line/second cap; the next emitted line reports suppressed entries. Values are bounded and newline-sanitized.

The [current capture menu](../../OMH.cmd) saves an immutable copy of console.txt, extracted OMHTT trace, error context, installed manifest and capture hash under `diagnostics/captures/<timestamp>/`. It does not upload anything. The original owner evidence is retained in [this capture](../../diagnostics/captures/20260925-215124-0526/console.txt) and [pre-patch snapshot](../../diagnostics/p1debug/console-before-patch.txt).

## Verification

[Validation log](../../diagnostics/p1debug/validation.log): 50 strings loaded and formatted by the installed Java Translator, six runtime Lua files compiled, 74 behavioral assertions passed, native table persistence passed, and 23 packets serialized (largest 397 bytes). The harness now uses native translation text instead of returning key names. Missing-translation and missing-texture regressions, rate limiting, nonmodal mutation reports and rejected-state comparison are covered. World/player/UI/rendering remain doubles.

The first dedicated check exposed native load order: `GameServer.main` initializes Translator before server mods load, so a UI audit there returns missing strings even with correct files. The shipped startup audit therefore runs on the client. The isolated smoke adds a temporary test-only script which reloads Translator after mods are present, resolves a representative string from all three categories and requires `native-translations checked=3 missing=0`, then saves and quits. The probe is removed after the run and is never packaged or installed. [Console evidence](../../diagnostics/p1debug/server-restart-console.log). This proves actual engine category loading, not player interaction or native sprite placement. Existing vanilla/PZ Optimizer environment warnings are not presented as mod failures.

The installer backs up a managed old package, verifies all new hashes, and retires only old manifest-owned files whose bytes still match their previous hashes. Unmanaged or user-modified files remain untouched. [Current manifest](../../diagnostics/p1debug/manifest.json) and [archive](../../artifacts/OMHTT-0.1.2-p1debug.zip) identify the patch. No save is edited by installation.

Final result: the dedicated run passed in 57.9 seconds with three categories resolved and clean save/shutdown; no player connected. The managed upgrade regression removed obsolete translation files and preserved an unrelated sentinel. Local installation completed at `C:/Users/bandi/Zomboid/mods/OneMoreHorde_TurretsAndTraps`, all 33 package files hash-verified; only the three JSON translation files remain in the installed EN directory. The temporary smoke probe is absent from source, installation and archive. Visual/player confirmation remains pending.

## Owner test

1. Fully restart PZ and reopen the disposable test save with Foundation Test Controls ON. Leave Prototype Diagnostic Logging ON. The menu should say **OMH Foundation Test 0.1.2-p1debug** with readable action names.
2. Place one nearby potato or barrier. Expect a short notification, a visible cube and no large automatic report. The submenu displays its selected tile coordinates.
3. Choose **Inspect this tile**. Expect readable version, identity, condition and supply values; close the report. Inspect a far tile once: expect a readable range rejection without a false agreement claim.
4. Beside a device, choose **Log nearby defense diagnostics**. If testing a potato, turn its head and fire once at a visible zombie, then immediately retry; expect one ammo spend followed by cooldown rejection, with no report hiding the impact.
5. Stop there and report that the run is ready for log review. Leave console.txt available, or run **OMH.cmd option 6** to preserve it. No written description of the fault is needed; screenshots are optional supplementary evidence. I will inspect the trace before advancing checkpoint acceptance.

Handoff: **Test now**. All Phase 1 acceptance remains pending.
