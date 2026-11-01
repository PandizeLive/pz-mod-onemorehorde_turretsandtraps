# 0.2.71.7 verification

Owner approved C5411A and reaffirmed simple shared mechanisms for custom-head compatibility. [Implementation](UPDATE_C542.md).

**44,794 assertions passed.** Four frozen old-code controls reproduce their named failures. Native 42.21 save/read and Traps-only, Turrets-only and combined starts passed. All 464 source and 640 package files validate. [Evidence](evidence/c542-verification.json). Installed and staged from immutable `test/v0.2.71.7` / `0f1fde8`. All 464 source and 640 tag/package/install/archive/stage files and prior backups verify; page metadata/preview preserved. [Delivery](evidence/c542-delivery.json). No Workshop upload, live-server or sibling changes. **Test now after uploading 0.2.71.7 and restarting server and clients. No new world required.** GitHub mirror blocked by automatic approval review: C542 is a new public export not covered by the prior release-specific approvals. Specific owner approval requested; no export attempted through another route. Connected multiplayer and rendered acceptance remain pending; automated/native checks must not be presented as their replacement.

## Owner checklist

After uploading0.2.71.7, restart server and clients. Keep the current world.

- Turret lights while turning away
- Rotary contact damage in crowds
- Tether activation and reset
- Turret motion during pause and resume

General zombie sliding during multiplayer pause remains a separate native/MPFF conflict. Report whether turret motion freezes separately from zombie movement.
