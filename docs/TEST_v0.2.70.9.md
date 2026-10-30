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

All package checks pass; tagged installation and staging are next.
