# C489 - multiplayer readiness audit

2026-10-26. Owner: "I cant test now, let's work on the next update as well, readiness audit". This selects the multiplayer readiness track proposed in C486. Owner testing is deferred, not failed or waived. C488's leaderboard candidate remains local and deployment approval is still pending.

## Conclusion

The production authority paths are present; the historical C236 SP-only restrictions are not current. No new inventory duplication, Controller ownership bypass or defense-XP payout defect was reproduced in this bounded audit. Two Tack synchronization issues should be corrected before the next connected-player test. This is not a multiplayer certification or a claim that automated tests replace connected dedicated/listen-server evidence.

## Confirmed findings

### Medium - an area snapshot can be dropped permanently

`TurretTackView.update` uses the simulation clock for its five-second request interval and records the new area immediately. `TurretTackServer.command` uses real time for its five-second rate limit and silently drops early requests. Once the client has recorded the new area, standing still prevents another request even after the server throttle expires.

The production-path Kahlua reproduction starts outside an existing field, advances one real second and six simulation seconds, then moves into its area. The client requests the field; the server drops the request. Ten additional real seconds and twenty stationary updates produce no retry and no local field. Retrying the same server request then supplies the existing field successfully. This demonstrates a synchronization defect under accelerated time; it does not claim a captured live multiplayer incident.

Impact: nearby Tack data can remain missing until another area transition. `TurretTackContact` and `TurretTackMarkers` consume that client view, so local contact feedback/handling and markers can be absent while server-owned zombie damage remains active. The fixture isolates snapshot delivery; it does not simulate an actual sleeping server or rendered player collision.

Evidence: `Source/42.20/media/lua/client/OMHTT/TurretTackView.lua` (`update`, `receive`, `start`); `server/OMHTT/TurretTackServer.lua` (`command`); `tools/tests/readiness_c489.lua`.

### Medium - Tack changes broadcast to every connection

`TurretTackServer.publish` uses the three-argument `sendServerCommand` overload for field creation and removal. The installed Build 42.21 JAR's `LuaManager.GlobalObject.sendServerCommand` calls `GameServer.sendServerCommand(String,String,KahluaTable)`, which loops over all UDP connections without proximity filtering. The nearby snapshot request already filters positions, and general `DefenseEffects.send` already targets nearby players, making Tack publication inconsistent with those paths.

The bounded fixture invokes 512 field creations and removals and confirms 1,024 global broadcasts. At 32 connections this implies 32,768 connection deliveries before transport overhead, including distant clients. This is a delivery-count calculation, not a measured bandwidth/FPS result or a claim that 512 fields occur every frame. The current server's 512-field safety budget remains intact.

Prefer nearby field updates and removals, with area snapshots supplying existing fields when players arrive. Preserve split-screen handling and expiry cleanup so reducing recipients cannot leave stale local hazards. Do not add global polling or a second field store.

## Reviewed boundaries and retained limitations

| Area | Current evidence | Remaining acceptance |
| --- | --- | --- |
| Controller privacy and remote operations | `ControlAccess.visible`, `remoteAllowed` and `ControlRemote.valid/command` require the correct owner network, current assignment, power, range and authenticated sender. Native batch payload and existing stale/foreign-device fixtures pass. | Two owners, explicitly shared Controller access and concurrent edits on real connections. |
| Inventory and expansion transfers | Shared timed actions revalidate current state and exact items on server `complete`, synchronize native add/remove operations, and preserve rollback on failed insertion. Existing stale transfer/repair and bounded bulk fixtures pass. | Simultaneous users, disconnect during transfers, native container ordering and reconnect views. |
| Combat authority | Owner-bound Prepare/Commit/receipt/handoff paths, per-victim ordering, identity/consent checks and duplicate handling pass existing production-path fixtures. | Real zombie ownership migration, native attacks interleaved with turret hits, delayed packets and observer animation. |
| Disconnect outcome | Existing five-second receipt deadline can abandon an uncertain hit after disconnect; ammo/power are not refunded and the hit is not blindly replayed. This is the documented C246 best-effort limit, not a new exactly-once guarantee. | Confirm acceptable behavior on dedicated and listen servers. |
| Defense XP | Trait Shop server store owns rewards/offline banking. Positive sub-1 shares are raised once after merging; delivery is life-bound and does not apply the minimum again. 60 defense and eight SP startup assertions pass. | Connected faction sharing, offline return, death expiry and PvP bleedout. |
| Persistence and packages | Accepted 0.2.70.1 already has native write/read and separate Traps/Turrets/both startup evidence, all with zero connected clients. This audit leaves shipped files unchanged. | Connected reconnect/restart acceptance; no fresh native-server result is implied here. |

Native `NetTimedAction.set` was rechecked in the installed JAR: it reads each constructor argument by its exact name from the action table. Recent shared Controller/batch/transfer actions retain named arguments and server revalidation; the 64-ID batch table survives native serialization at 1,523 bytes. Object/world fixtures are doubles, so this is not end-to-end network reconstruction evidence for every action.

An apparent injury-session inconsistency was investigated but excluded from confirmed live-path findings: the old `DefenseInjury.request`/`blast` helpers omit the session field, but no production caller was found. Current turret/poke senders carry sessions. No speculative gameplay fix is approved on that basis.

## Verification and provenance

- Freshly compiled `tools/KahluaCheck.java` against the installed game runs the current main suite plus `readiness_c489.lua`: **35,333 assertions pass**, including six audit assertions that reproduce the current defects. This replaces the optional module-pack audit for this invocation; it is not a full packaging/release validation run and does not supersede the accepted release's 35,424-assertion record.
- Existing transfer fixture: 600 items in 30 batches; largest fixture batch 7.31 ms in this run. Existing proc fixture: 160 bursts / 486 zombies / 441 callbacks. Test-double timings are not in-game frame budgets.
- Native serialization: 64 batch identities / 1,523 bytes; existing packet fixture 28 packets, largest 392 bytes. These are fixture payload bounds, not the largest possible mod message.
- Trait Shop `tools/Test-DefenseXP.ps1`: 60 defense-XP and eight SP-startup assertions pass against actual production modules. No sibling gameplay change.
- Installed game JAR SHA-256: `e1a69eb743ede60b213a0fe7f8b83d4fcab773036d256cc4543a336f3b058a33`.
- Evidence: `diagnostics/c489/kahlua.log`, `trait-shop-xp.log`, `net-timed-action-bytecode.txt`, `lua-manager-bytecode.txt`, `game-server-bytecode.txt`. These are local diagnostic files; the reproducible audit fixture is committed.
- Read-only fetch found zero newer commits on `origin/dev`. `Source` and `Contents` are unchanged. Owner `docs/AMMO_UI_C446.md` remains untouched, SHA-256 `24506649c189a6e0b9f9e7fd04ab53fba940d3741a79ec38c267b75b75207fba`.

## Recommended next update

**1A, recommended:** correct both Tack delivery paths. Use real time only for network throttling; retain simulation time for field deployment/lifetime. Replace silent request drops with bounded deferred/coalesced delivery, so the latest requested area eventually receives a snapshot without stationary polling. Restrict field changes to relevant nearby recipients, retaining removals, expiry and late-arrival coverage. Convert the defect reproductions into passing regression expectations and verify normal/accelerated time, split-screen, movement and bounded recipient counts.

**1B:** defer the correction and retain both documented issues. Not recommended before multiplayer acceptance.

This approval would cover a focused T&T corrective patch, local validation/package installation and documentation. It would not authorize C488's separate website deployment or a Workshop upload. No new balancing choice or larger networking framework is needed.

## Connected checks when the owner is available

Run once on dedicated and once on listen server, with two clients. Retain both client logs and the server log. Use server-synchronized items; client-only debug items cannot prove authoritative transfers. The initial stress case should combine Arc/Tack activity with concurrent inventory work and an ownership handoff; expand load only after correctness holds.

- Private Controllers and shared access.
- Concurrent ammo and expansion-kit transfers.
- Arc/Tack combat, ownership changes and disconnect.
- Fast-forward, area changes and Tack expiry.
- Offline faction XP, reconnect and character death.
- Server restart and retained inventories.

No owner test is requested now. Private mirroring remains blocked by the earlier automatic approval review requiring explicit destination/payload authorization; no retry or bypass. **Decision needed: approve the focused Tack correction.**

## C490 resolution - 2026-10-27

Owner selects1A and adds multiplayer text verification. Both confirmed findings are corrected in [0.2.70.2](PATCH_v0.2.70.2.md); the original defect fixture now runs corrected expectations in the regular suite. Connected acceptance remains pending. See the version test record for actual release/install evidence.
