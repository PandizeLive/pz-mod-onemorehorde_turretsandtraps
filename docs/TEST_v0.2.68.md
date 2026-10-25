# 0.2.68 - Shared defense XP verification

## C465 owner test outcome (2026-10-25)

Owner reports Test Complete with failures. Captured console confirms normal-client T&T 0.2.68, Trait Shop 0.9.1 and Horde/Cure 0.6.16.6 loaded. [Full diagnosis and pending choices](FEEDBACK_C465.md); capture `diagnostics/captures/20261025-125054-8293`.

- Failed/source-supported: Custom entry visibility and 2,493 empty-number errors, absent Specialist icon, rotary hits on grounded enemies and Controller/furniture overlap.
- Reproduced in installed Kahlua: saved current-default T&T settings produce Hardened, Lessened and Unknown (151 policy issues). Four enabled external IDs fail the current exact whitelist lookup; that is not reviewed proof of unfairness.
- Owner-reported/open: low XP. Expected solo rates are 1 ordinary / 2.5 Horde defense XP with earning enabled. Saved GlobalModData is the initial 12:31:07 snapshot, older than completed combat; no final paid-kill count can be inferred. Native death ordering does not demonstrate a consume-guard failure. Actual lethal-hit-to-ledger and rendered/save-reload acceptance remain pending.
- Requested presentation: colored score suffixes on Run Options, remove assistance wording, reuse a selected existing icon.

This supersedes the earlier request for the now-completed owner test. No new build installed or repeat test requested. Earlier automated results remain scoped to their fixtures; they do not close these failures. Connected multiplayer remains unaccepted. **Decision needed** for the next corrective patch.

## Automated evidence (2026-10-25)

- T&T: **27,729** Kahlua assertions; 436 source and 595 generated package files validated. Receipt checks cover matched sender/token, forged owner/XP rejection, malformed/expired/duplicate replies, optional Trait Shop absence, and client recipient/deduplication.
- Trait Shop: **56** targeted XP checks; **191** lifecycle/feedback, **262** shop/UI/physical and **207** reward/settings and **45** native Horde callback integration checks pass. Covers equal shares, mixed faction/assist owner, nominal ignored hit, later unrelated bleed tick, native serialization, repeat reconnect, cooldown, replacement life, out-of-order receipts, stale recovery, independent Traps options, offline toggle, corrupt ledger and Horde participation/source gates.
- Horde: **472** settings/persistence/defense authority/score checks pass, including offline personal/faction permission and opt-out.
- Installed stock **42.21** native WeaponHit.process confirms real injury adds a participant and an ignored hit does not. `diagnostics/defense-xp-feasibility/result.json`: productionPlayerCredit=true, ignoredRejected=true, zero connected clients. Jar SHA256 e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33.
- Coordinated native startup/save/restart: actual packages **0.2.68 / 0.9.1 / 0.6.16.6** loaded together. Offline 12.5 XP, victim cooldown and assist/source record survive a fresh process; same-life delivery is exactly once. `diagnostics/v0.2.68/xp-release/result.json`; 51.2s write, 47.3s read, clean shutdown, zero connected clients.
- Standard T&T native persistence write/read pass (56.1s / 51.9s). Traps-only, Turrets-only and combined 0.2.68 startup/save/shutdown pass (56.0s / 50.6s / 48.5s), zero connected clients. Horde reports zero undefined calls; Git whitespace checks accept the existing CRLF line endings.

The older Trait Shop Checkpoint 8 runner omitted the already-required Horde defense module; loading the actual module restored all 45 callback checks. A formatting-only package freshness mismatch stopped the first read invocation before server startup; source line endings were restored, packages rebuilt and the read probe rerun. This was not a gameplay runtime failure.

## Limits

Native synthetic actors and test doubles are not connected multiplayer acceptance. Live two-player injury/death ordering, bleedout/recovery, faction assists, disconnect/reconnect and presentation remain pending. Third-party direct player Hit implementations without the native post-hit callback are not promised personal-assist coverage. Unknown legacy passive builders are not assigned guessed XP owners. Failed/missing receipt does not establish defense credit; no fabricated payout fallback. Four named sibling chats were unavailable in the thread inventory; local source/contracts supplied the evidence.

No Workshop content upload, public release, existing owner save mutation or mod-selection change. 0.2.67's accepted SP round stays closed. The prior Trait Shop release-tool/Workshop edits were present before this patch and are excluded from this patch's commits.

## Local release

Installed from immutable local tags on 2026-10-25:

| Project | Tag | Gameplay commit | Verified local package files |
| --- | --- | --- | --- |
| T&T | test/v0.2.68 | 70736f0eaaa360a9eb9ba9a63517f4c6633b1723 | 595 |
| Trait Shop | v0.9.1 | 5fb6f2b964490475fbd51e68de5cf1bf55b565b1 | 37, plus matching staging copy |
| Horde/Cure | test/v0.6.16.6 | 29d0c7debf636e6d37287ce2385d486784b99cb1 | 172, plus matching staging copy |

Installers verified rollback points, copied hashes and retained backups. Independent SHA256 comparison confirms every destination file against the source; see `diagnostics/v0.2.68/xp-install-verification.json`. Backups:

- T&T: `diagnostics/p1c1/install-backups/20261025-031100-9502`.
- Trait Shop: `C:/Users/bandi/Zomboid/OMH-TraitShop-local-backups/before-v0.9.1-20261025-031052-7924`.
- Horde/Cure: `C:/Users/bandi/Zomboid/OMH-local-backups/before-v0.6.16.6-20261025-031055-4118`.

T&T gameplay commit and test tag were verified on the existing private [draft PR 1](https://github.com/PandizeLive/pz-mod-onemorehorde_turretsandtraps/pull/1) under C108/C119; deployment documentation follows in a separate commit. No merge or Workshop upload. Horde's manual-only policy remains: use its root OMH.cmd, option 2, when ready to mirror. Trait Shop's unrelated pre-existing release-tool/Workshop edits are still uncommitted and untouched; its mirror remains pending. No attempt was made to bypass its clean-tree release check.

All three intended versions were loaded by the isolated native server. The owner's normal client has not yet loaded this build; restart with Trait Shop enabled for the short single-player test. **Test now (single-player)**; connected testing remains deferred.

## Owner checklist

Single-player after restart, with Trait Shop enabled:

- Turret kill XP
- Trap kill XP
- Ordinary kill XP
- XP after save/reload

Connected faction/assist/offline tests are retained for multiplayer acceptance after coordinated publication. They are not represented as completed or requested for an unpublished hosted build.
