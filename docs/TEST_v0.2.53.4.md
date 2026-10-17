# 0.2.53.4 verification and short test

## C295 owner report, 2026-10-17

Owner reports whole-PC slowdown starting at the main menu and stopping on minimize/exit. Current console confirms 0.2.53.4 loaded; this does not establish a pass for the deferred four-step corrective test. [Resource samples, limitations and proposed diagnostic](LAUNCH_LAG_C295.md). No confirmed culprit or production change. Preserve pending rendered/connected acceptance.

## Automated evidence

Full validator passes 20,982 assertions, 209 runtime/translation compilations and 26 native-format command tables (largest 392 bytes). Package manifest covers 285 source files and 361 generated files: 136 Traps, 225 Turrets. All 300 literal translation references resolve. No shipped `pcall`/`xpcall` calls.

`control_corrections.lua` replaces C292's adverse expectations with regression checks for exact bag destination, full/removed/restricted/unsupported bags, changed access, rollback, repeat completion, cancelled callbacks, delayed replacement-item callbacks, timeout/handler retirement, legacy-item recovery, unassigned-head names, custom/empty names, numbered names, 181 crowded-square candidates, bounded list updates, shared renewal requests, server acknowledgements, flood limits, stale replies, power/assignment/range/access loss, SP queue avoidance and expiry. The stale-lease/local-turret-reach case is included. World/UI/network objects in these checks are controlled fixtures.

Native write/read passes (54.9/62.8 seconds). The exact bag withdrawal and removed-bag rejection run on native items; native `NetTimedAction.set` retains the top-level destination and the argument table encodes to 119 bytes. Heavy stockpile and 5,000-round save/reload remain intact. Traps-only/Turrets-only/both startup passes (52.8/61.4/49.8 seconds), with zero connected clients. The static package checker now distinguishes ten reviewed, lazily accessed cross-package integrations and validates the four independent Controller sprite mappings; all 160 Sandbox options and 66 identical shared files pass. It previously flagged the existing guarded integrations as missing mandatory dependencies.

Probe corrections: the isolated fixture player had no square during shutdown encoding, and invoking the native constructor there crossed the Lua thread boundary. Constructor extraction now runs on the actual game Lua thread; shutdown byte encoding temporarily restores the fixture square. Both failed probes were rejected before the passing runs. Neither failure established a production exception. The final six English caption-only changes followed native probes; the final full validator and rebuilt manifest include those captions. Rendered SP and connected dedicated/listen acceptance remain pending; argument extraction/encoding is narrower evidence than a live connected transfer. Current owner `console.txt` remains the earlier 0.2.53.2 session, last written 2026-10-17 at03:54 local; no new owner test is inferred.

## Installed build

Installed from immutable `test/v0.2.53.4` / `9519a3399bfd4bf499582aa9c0ef13420a17253f`. All 285 source and 361 tagged/packaged/installed/archive files match. Both previous 0.2.53.3 package backups verify. [Installation record](../diagnostics/v0.2.53.4/install.json) | [Release hashes and backup evidence](../diagnostics/v0.2.53.4/local-release.json). C108 development delivery uses the existing branch/draft PR; no Workshop publication.

## Test now, when available

1. Restart and confirm **0.2.53.4**. Scroll Manage and open **Details**; check headings/controls move together and Stockpile/Load labels have consistent capitals.
2. Clear a turret's custom name, swap its head without assigning a controller, and reopen. Its gray automatic name should match the head; a custom name should stay unchanged.
3. Open **Stockpile**. Deposit a valid module, then withdraw it into a carried bag. It should land in that bag; new clothing/backpack deposits should remain blocked.
4. Use Controller/remote Manage while a long inventory transfer runs. Check device selection, usable controls and no growing renewal queue. Close/reopen, then report any issues; Codex checks `console.txt` afterward.

No need to repeat the settled combat test. This remains a deferred owner test until actually performed.
