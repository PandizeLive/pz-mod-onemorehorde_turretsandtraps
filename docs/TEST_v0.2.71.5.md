# 0.2.71.5 verification

Owner approved the full C537 option 1A. [Implementation](TARGETING_C538.md).

## Automated checks

Eight frozen-code controls reproduce unconfirmed acquisition and child contacts, blind retry, stale area radius, missing multiplayer idle sweep, undercharged batch loading, missed native-list reconciliation and missing native spear world rendering. Corrected suite: **44,490 assertions passed**. Native 42.21 write/read persistence, zero-client combat authority, real native spear/ammunition checks, and Traps-only, Turrets-only and combined starts passed. All 464 source and 640 packaged files validate. [Evidence](evidence/c538-verification.json).

These checks use native Kahlua/serialization and test doubles unless explicitly identified as native engine probes. No connected clients participate in automated server starts. Module compatibility and individual-hit coverage are not connected acceptance.

## Owner checklist

After uploading this version, restart server and clients. Keep this world. Enable Turret Diagnostic Logging; Detailed Logging helps resolve remaining timing questions.

- Lobber detection beyond eight tiles
- Idle scanning, wakeup and target tracking
- Potato and Ballista target accuracy
- Splitter and Fragment spear visuals
- Moving-target module effects
- Scrap and spear stack loading
- Missing-target retries and console errors

Container-sync error attribution and the existing pause conflict remain unresolved; rendered spear orientation needs acceptance. Installed and staged from immutable `test/v0.2.71.5` / `0b67c27`. All 464 source and 640 tag/package/install/archive/stage files and previous backups verify; page metadata/preview are byte-identical. [Delivery](evidence/c538-delivery.json). No Workshop upload, live-server or sibling changes. **Test now after uploading0.2.71.5 and restarting server and clients. No new world or saved-setting reset required.** GitHub mirror verified through draft PR1 at `837bfa0`, including immutable `test/v0.2.71.5`. Owner explicitly approved exporting this C538 patch and verification after automatic review required payload-specific authorization; that block is resolved.
