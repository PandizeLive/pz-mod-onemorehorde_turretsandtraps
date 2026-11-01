# 0.2.71.6 verification

Owner selected C539 **1B**. The shared Lobber head minimum is zero; existing acquisition, server-validated manual controls and the client landing slider consume that value. No parallel override or additional targeting path was added.

Checks cover zero, fractional and near distances in SP/server profiles, the unchanged maximum, valid and invalid manual commands, slider lower bound, all three bomb payloads landing at 0/0.1/1/5 tiles, the retained landing fuse and exactly one positive damage application per blast. Position and damage adapters are test doubles; native runtime checks do not include connected clients or GPU rendering.

**44,580 assertions passed.** Native 42.21 save/read and Traps-only, Turrets-only and combined starts passed. All 464 source and 640 package files validate. [Evidence](evidence/c540-verification.json). Installed and staged from immutable `test/v0.2.71.6` / `434053b`. All 464 source and 640 tag/package/install/archive/stage files and prior backups verify; page metadata/preview preserved. [Delivery](evidence/c540-delivery.json). No Workshop upload, live-server or sibling changes. **Test now after uploading 0.2.71.6 and restarting server and clients. No new world required.** Owner explicitly approved the C540 patch and verification export on 2026-11-01. GitHub mirror verified at `3510356` through draft PR1, including immutable `test/v0.2.71.6`; the approval-review block is resolved.

## Owner checklist

After uploading 0.2.71.6, restart server and clients. Keep the current world.

- Lobber targets inside six tiles
- Manual landing distance below six
- Close-range bomb landings and explosions

Previous multiplayer presentation acceptance, unattributed native container errors and the pause-mod conflict remain open. This patch does not establish their resolution.

## C541 connected owner feedback, 2026-11-01

**C541 / Connected retest remains incomplete (2026-11-01).** Both sides load0.2.71.6. [Findings and proposed correction](MULTIPLAYER_FEEDBACK_C541.md) confirms facing-gated light expiry and reproduces two rotary lost-contact paths. During62.1 seconds of client pause, server pause state changes411 times, consistent with the installed MPFF/native speed conflict; exclusive sliding attribution remains unproven. Tether records23 applied dart hits, but intermittent nonactivation is not attributed. TurretDetailedLogging is off. Ten focused assertions and44,493 full-harness assertions demonstrate failures, not fixes; no connected replay or gameplay/package/install/server/sibling changes. Recommend1A complete light/rotary/Tether follow-up with separate external pause scope;1B lights only. Owner documents preserved. GitHub mirror pending. **Decision needed.**

Owner reports disappearing lights/indicator on turning, paused zombie sliding, inconsistent rotary damage and occasional Tether nonactivation. These reports do not specifically accept or reject the C540 Lobber minimum removal. Preserve its pending acceptance separately.
