# C511 - 0.2.70.8 connected trap damage failure

2026-10-29 owner report: traps no longer damage zombies; Spike Barrier takes attacks without retaliatory damage. Fragment/module presentation remains imperfect but passable. This is failed connected acceptance, not acceptance of all module behavior or final visual polish.

## Confirmed evidence

The saved SFTP login was used for read-only capture of the current server console, latest debug log, Sandbox settings and both package versions. The local client console was captured separately. Raw captures remain in ignored `diagnostics/c511`; no live server files or settings changed.

- Client and both server packages load **0.2.70.8**.
- Server console records **8,079 Java RuntimeException entries** for `attempted index: havePlayer of non-table: zombie.core.raknet.UdpConnection` in `DefenseContactServer.observe`, line 35.
- No `owner-contact-accepted` or `owner-contact-stale` counters appear. Reports reach the ownership guard and throw before `Contacts.observe`; this directly explains the loss of report-driven Bed Spikes, Poke Floor, wire/panel and Tack damage.
- The same session records **261 applied combat results** and **37 combat-lethal results** in diagnostic summaries. These show the damage exchange still completes for some attacks; they are not proof of every turret/module interaction or independently counted corpse creation.
- Spike Barrier health decreases while being attacked. Its server strike handler also calls `zombie:getOwner():havePlayer(player)` and would fail if that guard is reached. This capture contains no BarrierRetaliation exception or confirmed barrier strike. Its client marker/report path must be checked rather than assuming the common defect fully explains its symptom.

This is a mod-side Java/Lua boundary error. The captures do not support attributing it to the owner's internet connection.

## Why the earlier tests missed it

`contact_path.lua`, `corrections_c503.lua` and `multiplayer_matrix_c509.lua` supplied Lua tables with a callable `havePlayer` method as connection doubles. Real UdpConnection objects are not callable that way through the game's Lua bridge. Native zero-client checks did not enter this connected-owner branch. The C509 results established behavior against an incorrectly permissive boundary fixture; they did not validate this particular engine call. Retain the historical results, but explicitly narrow their evidential value.

The current installed 42.21 jar confirms `IsoZombie.getOwnerPlayer()` returns the owning IsoPlayer and `setOwnerPlayer()` exists. Production `DefenseCombatServer.current` already compares the native owner player directly. Both affected clients send their report using `zombie:getOwnerPlayer()`, so exact sender equality is the appropriate proposed check here. Preserve the existing connection identity, liveness, identity, distance, freshness and replay guards.

## Recommended corrective scope

**1A - focused correction (recommended):** replace both invalid connection-method calls with native owner-player identity validation; remove the permissive connection mocks and exercise the real exposed Lua/Java ownership boundary, including foreign senders and ownership changes. Trace Spike Barrier's client animation marker, report admission and confirmed damage before packaging. Preserve the approved server authority and existing balance. No effect redesign is needed for this correction.

**1B - investigation only:** retain the current installed build while completing the barrier-path proof; do not describe the broken trap build as ready for further acceptance testing.

No production code, package, version, install, Workshop upload, live-server configuration or sibling project changed in this investigation. No patch approval is inferred solely from this new failed test report. The previous GitHub automatic approval-review rejection over destination authorization remains; no alternate push route was attempted.

Decision needed: corrective scope. The next patch must prove the real ownership boundary, not merely increase the fixture assertion count.
