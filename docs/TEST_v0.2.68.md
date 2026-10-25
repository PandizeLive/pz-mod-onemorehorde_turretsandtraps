# 0.2.68 - Shared defense XP verification

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

Tag/install/hash evidence pending final packaging. Horde follows its manual-only mirror policy. T&T follows standing C108/C119 automatic private development mirroring.

## Owner checklist

Single-player after restart, with Trait Shop enabled:

- Turret kill XP
- Trap kill XP
- Ordinary kill XP
- XP after save/reload

Connected faction/assist/offline tests are retained for multiplayer acceptance after coordinated publication. They are not represented as completed or requested for an unpublished hosted build.
