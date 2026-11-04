# 0.2.70.9 verification and owner test

Status: automated/native package checks passed; connected owner acceptance pending.

- 40,292 Kahlua assertions, including 339 head/module hit cases and the complete barrier marker/report/acknowledgement replay.
- Real native UdpConnection reproduces the previous failure; corrected production handlers validate native owner identity, foreign senders, handoff and duplicate reports.
- The native probe uses real engine objects and Lua exposure; contact/damage sinks and geometry lookup are test adapters. It has no connected clients and does not render the animation.
- Native save/read and Traps-only, Turrets-only and combined package starts pass. [Evidence](evidence/c512-verification.json).

## Owner checklist

Upload using CMD option3, then update/restart the server and both clients to0.2.70.9. No new world required. Enable existing Diagnostic Logging and Detailed Logging for Turrets and Traps during this test.

- Bed Spikes landing damage
- Poke Floor fast crossings and corpse dragging
- Concertina, Barbed Panels and Tacks
- Spike Barrier retaliation from front and sides
- Spike Barrier safe rear
- Turret damage and kills

Check these barrier summary counters when reviewing the next connected log: `barrier-contact-start`, `barrier-contact-unresolved`, `barrier-report-sent`, `barrier-report-received`, `barrier-report-accepted`, `barrier-damage-confirmed`. Zero-client replay evidence cannot establish that the owner's native animation generates its markers.

The earlier GitHub automatic approval-review rejection over destination authorization remains; retain the local checkpoint without bypassing it.

## Delivery verification

Installed and staged from immutable `test/v0.2.70.9` / `4b3e956`; all629 tag/package/install/archive/stage files and previous managed backups verify. Workshop page text/preview preserved. **Test now after uploading0.2.70.9 and updating/restarting server and both clients. No new world required.**

## C513 - Connected retest failed (2026-10-30)

Owner reports Concertina, Poke Floor and other traps remain delayed. [Captured evidence and codepath review](MULTIPLAYER_FEEDBACK_C513.md) confirms0.2.70.9 on both sides and repairs to the ownership exception, but does not establish responsive multiplayer behavior. Six Barrier contact starts produce no strike reports. Bed landing damage remains unconfirmed. Successful Poke/barbed health changes and a Poke corpse are partial functional evidence only. Full contact-to-visible timing was not recorded;82-105ms server transaction timings must not be presented as that measurement. No new playable build or repeat acceptance test is requested.
