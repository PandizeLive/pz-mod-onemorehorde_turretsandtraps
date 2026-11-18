# 0.2.71.7 verification

Owner approved C5411A and reaffirmed simple shared mechanisms for custom-head compatibility. [Implementation](UPDATE_C542.md).

**44,794 assertions passed.** Four frozen old-code controls reproduce their named failures. Native 42.21 save/read and Traps-only, Turrets-only and combined starts passed. All 464 source and 640 package files validate. [Evidence](evidence/c542-verification.json). Installed and staged from immutable `test/v0.2.71.7` / `0f1fde8`. All 464 source and 640 tag/package/install/archive/stage files and prior backups verify; page metadata/preview preserved. [Delivery](evidence/c542-delivery.json). No Workshop upload, live-server or sibling changes. **Test now after uploading 0.2.71.7 and restarting server and clients. No new world required.** On 2026-11-01, the owner explicitly approved this C542 public GitHub mirror and reaffirmed standing approval for future completed T&T updates to the existing repository. GitHub mirror verified at `9f0c6db` through draft PR1, including immutable `test/v0.2.71.7`; the approval-review block is resolved. Connected multiplayer and rendered acceptance remain pending; automated/native checks must not be presented as their replacement.

## Owner checklist

After uploading0.2.71.7, restart server and clients. Keep the current world.

- Turret lights while turning away
- Rotary contact damage in crowds
- Tether activation and reset
- Turret motion during pause and resume

General zombie sliding during multiplayer pause remains a separate native/MPFF conflict. Report whether turret motion freezes separately from zombie movement.


## Connected owner retest: failed (2026-11-01, C543)

Owner reports less frequent Rotary Blades hits and delayed wakeup with Enhanced Firing/Detection +360; Rapid Fire uncertain. Client/server logs confirm0.2.71.7. [Investigation](ROTARY_FEEDBACK_C543.md) reproduces a scheduling/contact-window gap in both current and prior rotary code. This overrides the pending acceptance status for rotary behavior; automated checks did not establish the connected workflow. Lights and Tether are not newly accepted by this report. No replacement build was produced. **Decision needed: proposed1A corrective scope.**
