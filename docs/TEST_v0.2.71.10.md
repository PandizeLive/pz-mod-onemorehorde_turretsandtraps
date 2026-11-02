# Shared damage queue verification for 0.2.71.10

The owner selected C547 option 1A and requested a mixed stress test and a review against Alex's guidelines. Three pairs of independent JVM runs compared the released damage and rotary code with the candidate. Each measured window lasted 12 simulated seconds with 32 continuously moving, standing zombies and one normal damage queue update per 100 ms server tick. Bat/Blades and other head/module checks run in the regular suite. The crowded configuration uses Rotary Blades with Enhanced Firing, Enhanced Detection and 360.

| Scene | Previous rotary hits applied | New rotary applied / expected | New trap applied / attempted | Previous server p95 (ms) | New server p95 (ms) |
| --- | ---: | ---: | ---: | ---: | ---: |
| 1 rotary | 416 | 416 / 416 | 0 / 0 | 3.80 | 3.01 |
| 4 rotary | 1,711 | 1,711 / 1,711 | 0 / 0 | 10.20 | 7.06 |
| 6 rotary | 35 | 2,543 / 2,543 | 0 / 0 | 14.02 | 10.24 |
| 8 rotary | 0 | 3,424 / 3,424 | 0 / 0 | 18.22 | 12.15 |
| 6 rotary plus Poke Floor | 6 | 2,543 / 2,543 | 256 / 256 | 14.36 | 10.43 |
| 6 rotary plus Concertina Wire | 61 | 2,541 / 2,543 | 188 / 188 | 14.65 | 11.03 |

Server and owning-client health agreed for each victim after draining the queue. Contact geometry found all expected crossings. The new eight-turret run reduced median p95 server work by 33% while applying all 3,424 hits. Giving the queue four calls per tick was only a diagnostic control. The ordinary build uses one call. An additional eight-turret variant charged actual elapsed wall time against the two-millisecond service budget. Its three applied-hit counts were 3423, 3424, 3424 out of 3,424.

The six-turret wire case produced two owner-confirmed expirations. The independent per-victim FIFO reference assumes unlimited global capacity, immediate service as soon as a victim is free, the same ordering and network delays, and drops work it predicts cannot reach the owner by expiry. It predicts exactly those two late rotary hits by count. The probe checks per-victim health and per-tick geometric contacts. It does not match the expiry oracle to individual network tokens. The mixed Poke case delivered every requested hit. These simulated counts and wall times are specific to this fixture and machine.

## Optimizations and Alex's guidelines

A waiting victim has one service entry and a bounded FIFO of up to eight pending hits. The server keeps up to 256 waiting hits and retains the existing network limit. It retires expired jobs before dispatch, including expired trap contacts behind a longer-lived shot. Each service round starts at most one job per waiting victim, with at most 32 starts per tick. It yields after a victim if wall time reaches two milliseconds. Callbacks may enqueue new work. Per-victim order, fresh consent, identity and exactly-once health changes are checked. Explicit expiry affects that contact alone. An overload refusal or expiry cannot rewind rotary travel for another try.

In the eight-turret call-count capture, profile builds fell from 64,320 to 1,920. Line checks fell from 37,612 to 4,864. Contacts still check physical reach and obstruction at the crossing. Detection can reuse a confirmed target for the current motor update. Standby accepts the already resolved stats and validated target. The damage path removes duplicate capacity checks, duplicate local health settlement and a transient per-tick table. Reviewed imports and expanded non-guard one-line conditionals in the three touched combat files. The static scan covered 267 runtime Lua files for tabs, BOM, banned calls and require paths ending in .lua. Dynamic cross-module references and per-contact callbacks still exist; this audit concentrates on the measured combat path. The timing reduction measures the combined change.

51,984 assertions passed in the stock-engine validation harness. Focused tests cover cancellation behind an active hit, reentrant enqueue, capacity, ordering, time-budget yield, count-budget yield, stale reports and duplicate receipts. Native dedicated save/reload and Traps-only, Turrets-only and combined launches passed with zero connected players. The benchmark uses production contact, queue and MP handlers with native packet serialization, plus simulated actors, transport timing, map objects and trap clocks. Connected presentation on the owner's server remains pending. [Measurements](evidence/c548-crowd.json) and [replay](../tools/tests/rotary_crowd_c547.lua).

- Overlapping turrets firing into one crowd
- Poke Floor and Concertina Wire under turret fire

Installed and staged from test/v0.2.71.10 at 654349c0. All 642 packaged files match the tagged build, installation, ZIP and Workshop stage. [Delivery](evidence/c548-delivery.json). **Test now when available** after uploading and restarting the server and clients. The existing test world is compatible.
