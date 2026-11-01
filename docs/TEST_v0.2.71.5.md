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

Container-sync error attribution and the existing pause conflict remain unresolved; rendered spear orientation needs acceptance. Installation/staging is the remaining delivery step.
