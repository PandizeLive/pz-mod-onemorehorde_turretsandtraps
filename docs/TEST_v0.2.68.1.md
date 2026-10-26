# 0.2.68.1 - Corrective patch verification

## Approval and evidence

C467 owner approval 2026-10-25 covers C465/C466. Production changes are coordinated with Trait Shop 0.9.1.1 and Horde/Cure 0.6.16.7.

- T&T full installed-Kahlua regression, Lua/translation compilation and package validator pass;437 source files,596 packaged files,399 translation keys. 27,741 assertions passed. Custom input covers narrow/wide layouts and invalid intermediate text. Native furniture/device validation and rotary posture tests pass. Package-scoped diagnostics tests pass.
- Trait Shop 60 defense XP assertions,8 production Authority SP-startup assertions and191 Phase 1 checks pass. Bob-to-final-name startup preserves the same account/life. Seven turret plus two personal ordinary kills yield11 XP, duplicates add zero, reconnect preserves balances, zero-rate yields zero. Minimum recipient shares are merged once, fractional values>= 1 retained, banked values never floored again on delivery.
- Horde 608 settings/persistence/defense/score assertions pass. Current generated Turrets-only, Traps-only and combined defaults all classify neutral.160 whitelist assertions pass. Run Options lifecycle/draft/permissions/bounds and three rendered score suffix fixtures pass. These fixtures do not establish GPU appearance.
- Native stock 42.21 coordinated package startup/save/restart passes. Exact versions 0.2.68.1/0.9.1.1/0.6.16.7 load. Pending 12.5 XP and minimum 1 XP, victim cooldown and assist/source state persist across fresh processes; same-life delivery is once. Write 50.2s/read 47.6s, zero connected clients; diagnostics/v0.2.68.1/xp-release/result.json.
- Traps-only 49.5s, Turrets-only 50.1s and combined 51.3s native startup/save/shutdown pass with 0.2.68.1. Zero connected clients; diagnostics/v0.2.68.1/packages-*.json. Final changes after those native probes only refine object logging scope, occupied floor-device rejection and snapshot dirtiness after delivered XP; final regression checks cover them.

The first regression run exposed a missing native posture method on a test double; the fixture was corrected. Native Guid-table warnings are existing tooling output, not new OMH exceptions. Tools use installed Kahlua/42.21 even where older runner labels say42.20.4. No owner live test is claimed. Named sibling chats were unavailable in the inventory; local source/contracts supplied the evidence.

## Limits and installation

Owner client appearance, live progression and connected-player transport remain pending. No fabricated backpay, historical flag deletion, saved gameplay tuning change, Workshop upload or sibling remote push. Existing Trait Shop release-tool/Workshop edits predate this task and are excluded. C452 acceptance of 0.2.67 stays closed. Tagged installation and backups are verified below.

## Owner checklist

Restart with Trait Shop enabled. Ordinary zombies, 2 XP reward, 50% defense, eligible solo owner:

- Seven turret kills, two manual: +11 XP.
- Custom rarity editing
- Turret Specialist icon
- Rotary targets on ground
- Controller placement
- Run Options and Debug settings

Connected multiplayer remains deferred. No additional long testing instructions.

## Local installation and rollback

Installed on 2026-10-25 from immutable local development tags:

| Project | Tag | Gameplay commit | Verified files |
| --- | --- | --- | --- |
| T&T | test/v0.2.68.1 | 028eed6cf68cc2e21e93211c3c0d5b8b0b0eab78 | 596 |
| Trait Shop | v0.9.1.1 | db6a5ce1b1ed1f5e5ed0cc8eecfc95a3c766e847 | 37, local and staging |
| Horde/Cure | test/v0.6.16.7 | 81738de7ea3058cc9f1f22bf4edeb99d904ffc25 | 172, local and staging |

Independent SHA256 verification matches all 437 T&T source files and 596 generated package files to the tag archive, current package and local install. Both previous 0.2.68 package backups verify. Trait Shop's 37 and Horde/Cure's 124+48 files match source at both local and Workshop staging destinations. Evidence: diagnostics/v0.2.68.1/xp-install-verification.json. No Workshop upload occurred.

Backups:

- T&T: diagnostics/p1c1/install-backups/20261025-145809-9265.
- Trait Shop: C:/Users/bandi/Zomboid/OMH-TraitShop-local-backups/before-v0.9.1.1-20261025-145759-4557.
- Horde/Cure: C:/Users/bandi/Zomboid/OMH-local-backups/before-v0.6.16.7-20261025-145802-1319.

The private T&T checkpoint and test tag use the required C108 Mirror command and existing [draft PR1](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/pull/1); no merge. Horde mirroring remains manual-only. Trait Shop's unrelated pre-existing release-tool/Workshop edits remain untouched and uncommitted; no sibling remote push. No settings or owner save data were edited.

All intended versions loaded in the isolated stock native server. The owner's normal client has not loaded this patch yet. Restart before the short single-player checklist above. **Test now**; rendered acceptance and connected multiplayer remain pending.

## C468 - Owner test complete with reported failures (2026-10-25)

Owner reports oversized Specialist art, Controller overlaps, failed kit replacement, apparent conditional-module inactivity and one-side barb failure. [Audit and remaining decisions](FEEDBACK_C468.md). Exact loaded versions and game42.21 confirmed from capture20261025-170559-1540. Last world logs55 paid defense settlements/55XP; earlier10 zero-reward events reflect effective configured source reward0. No cross-world balance is inferred. Tooltip raw-percent formatting warning confirmed; source copy corrected in Horde for the next build.

Focused installed-Kahlua checks reproduce stacked-item rejection, missing BlocksPlacement validation and missing-health-baseline skips; conditional damage74 and10% Execute pass when health is known. Opposite-face record/geometry checks pass without establishing live dual-face contact/persistence.27,657 assertions pass in this standalone run with13 focused audit assertions; world/UI objects are test doubles. This session is complete, but failed features and connected multiplayer remain unaccepted. No new owner test, installation or version/tag change.

## C469 - Pixel Strike clarification and duplicate-item follow-up (2026-10-25)

Owner confirms the20 damage observation came from Pixel Strike against completely healthy targets, not Manage's Damage field. Production integration forwards actual confirmed loss; Initial Blow is therefore recorded as a live failure needing diagnosis. Execute remains inconclusive/untested. No new console session or fabricated target trace is inferred.

Legacy Poke item is now hidden in Source only. Native42.21 Item.DoParam/isHidden/getObsolete checks pass3 assertions and installed item-list Lua excludes hidden definitions.3 calculation assertions cover the proposed Execute shot-count comparison. These are not installed-gameplay acceptance. See C469 in FEEDBACK_C468.md;0.2.68.1 remains installed with its failed features unaccepted.

## C470 - Selected Execute source regression (2026-10-25)

Owner selects3A18/+2. Staged shared fallback and Sandbox defaults agree.27,646 installed-Kahlua assertions pass, covering exact18% and just-above thresholds, floating-point boundary tolerance,0-16 active copies, duplicate-kill prevention, saved10/1 settings and explicit0/0 disabling. Translation JSON parses. Diagnostics/c470/kahlua-output.txt records this source-only check; no generated package or installed build changed. Initial Blow's reported live failure and the rest of the corrective patch remain open; no owner retest requested.
