# 0.2.71.4 verification

## Automated evidence

- Full validation: 44,455 Kahlua assertions, 266 Lua files, 464 source files and 640 packaged files.
- Six frozen 0.2.71.3 controls fail at the expected behavior: commit-time fan, first-arrival latency, late native ID, owner aim, firing eligibility and primary position snapshot. Corrected code passes all six.
- First-arrival and retransmission checks cover 1, 2, 5, 6 and 16 Splitters at 0, 100, 249, 250, 350 and 750 ms. A serialized primary plus six-child burst arrives together and cannot replay after display. Existing stacked actual-contact, busy-victim, corpse and damage protocol tests remain in the full suite.
- Tests retain native ownership, late/duplicate/recycled-ID rejection, report expiry, explicit forward fire and visible-wall clipping. Existing catalog coverage includes ten heads and 360 head/module cells.
- Isolated source native lifecycle probe passes with a real IsoZombie: ID assigned after creation resolves without an update callback; unloaded ID rejects. The probe adapts the client-mode predicate on a dedicated server and does not simulate a connected client.

Packaged native write/read passes in 94.5/93.1 seconds, including the real-actor C536 lifecycle probe. Traps-only, turrets-only and combined startups pass in 95.2/74.0/89.6 seconds. Stock dedicated turret authority/services also pass. [Durable verification and hashes](evidence/c536-verification.json). Installed and staged from immutable `test/v0.2.71.4` / `2f651b8`. All464 source and640 tag/package/install/archive/stage files and previous backups verify; page metadata/preview are byte-identical. [Delivery](evidence/c536-delivery.json). No Workshop upload, live-server or sibling changes. **Test now after uploading0.2.71.4 and restarting server and clients. No new world or saved-setting reset required.** GitHub mirror pending.

## Remaining acceptance

No connected clients participated in automated probes. The actor lookup defect is fixed; missing native spawn visibility is not established as fixed. Native server multiplier writes conflict with the installed pause mod; general paused zombie sliding remains unresolved. No pause-mod change is included.

Owner checklist after the new build is delivered and server/clients restart:

- M16 with six Splitters
- Empty turret stops firing visuals
- Potato aiming and Splitter directions
- Horde Manager spawn visibility
- Trap damage on newly spawned zombies

No new world or settings reset.
