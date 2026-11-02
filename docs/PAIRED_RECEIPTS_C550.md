# C550 mixed-base multiplayer prototype

The owner selected C549 option 1A. The candidate uses the existing zombie ID index for Spike Barrier strikes and lets two hits already waiting on the same zombie travel in one owner transaction. An idle lane still dispatches its first hit immediately. This is a reproducible source prototype against `test/v0.2.71.10`.

## How combat works

The server retains each device ID, hit amount, effect kind, observation deadline and Horde authorization. The owner resolves the hits in order against current health at one application time. An expired member can be skipped independently. A lethal first hit consumes the remaining health and leaves zero damage for the second. The server recomputes both outcomes, commits native death, assigns XP and Horde credit to the actual finisher, and runs each callback separately. Distinct presentation tokens allow each confirmed hit to display once.

Both hits use the existing token, sequence, prior-owner status and reconciliation mechanism. If the same owner misses a paired acknowledgement, the server retries the identical message once after half the existing timeout. A cached acknowledgement recovers an applied transaction. A missing original application can apply only members whose initial deadlines still permit it. An unreachable owner can still time out.

Spike Barriers use the index when owner, ID, outfit, generation, floor and local square match. An index miss falls back to the bounded nearby search. Collider, strike direction, range, consent and duplicate-marker checks still run.

## Controlled comparison

| Metric, three independent runs per build | 0.2.71.10 | C550 candidate |
| --- | ---: | ---: |
| Applied / requested at 100 ms round trip | 9,057 / 9,061 | 8,966 / 8,970 |
| Applied / requested at 300 ms round trip | 8,376 / 8,645 | 8,656 / 8,684 |
| Rotary Blades at 300 ms | 103 / 132 | 132 / 132 |
| Rotary Bat at 300 ms | 113 / 132 | 130 / 132 |
| Concertina at 300 ms | 1,026 / 1,140 | 1,131 / 1,140 |
| Both Bed Spikes tiers at 300 ms | 2,704 / 2,790 | 2,779 / 2,790 |
| M16 owner health-change p95 at 300 ms, median run | 1,350 ms | 450 ms |
| Barrier processing p95 at 300 ms, median run | 3.41 ms | 0.31 ms |
| Total measured server work p95 at 300 ms, median run | 12.05 ms | 11.06 ms |

At 300 ms, the candidate sent 426 paired packets across the three runs. The 28 requests without damage comprised 15 expirations, 12 cancellations and one rejection. The released build had 269 requests without damage. At 100 ms both builds recorded four rejected requests. M16 health-change latency is measured from server request to application on its owning client. The three candidate M16 p95s were 450, 450 and 800 ms. The fast barrier path avoided all 7,239 nearby square-list reads in each high-latency replay.

The C549 layout ran for 20 simulated seconds per replay. It contained 100 moving zombies, 14 turrets including the six-Splitter M16, ten of each damaging trap and ten Tack fields, and two pressure plates linked to separate Tethers. Every individual trap and turret damaged a target in each run. The harness drained submitted damage and compared every zombie's final server and owner health. The real wall-time budgets affect which shots are offered during each window, so compare each build against its own request count. The two simulated owners ran in one JVM. The fixture used favorable rolls, constant ammunition and power, and scripted contact. It measures the mod's combat work and controlled transport. Connected play, hardware differences, real packet jitter and rendering remain untested.

## Fault and regression checks

- 200 focused assertions passed after the regular suite. The focused run completed 52,077 assertions in total. The candidate and control used the installed game's `TableNetworkUtils.save/load` for combat packets in the final comparison.
- Verified independent expiry in both orders, both members expired, lethal hits in both slots, two distinct damage indicators, duplicate packets and callbacks, forged outcomes and sender, a lost packet, a lost acknowledgement, old-owner handoff before and after application, and reconciliation against lower health on a replacement owner.
- Exercised the local Horde Night integration's authorization, damage classification and finishing-blow consumption. A stale or disabled run could not receive credit. The actual finisher produced one XP credit call. The Horde engine, XP recipient and network endpoints were fixtures.
- The barrier fixture exercised warm, cold and recycled index entries, the wrong sender or outfit, another floor, a forged collider, the safe rear and a duplicate strike.
- The earlier eight-rotary regression matched all 3,424 expected hits. The six-rotary Poke Floor and Concertina scenes also completed with matching server and owner health.

The candidate and replay can be inspected in [the prototype patch](../tools/prototypes/c550-receipts.patch), [focused tests](../tools/tests/paired_receipts_c550.lua) and [per-run evidence](evidence/c550-paired-receipts.json). Run `python tools/check_paired_receipts_c550.py` from the T&T project with the 0.2.71.10 Source tree. It recreates the candidate under diagnostics. The staged and installed build is still 0.2.71.10.

**Decision needed.** Recommend **1A** to promote this candidate to a multiplayer test build and verify it with two connected players. **1B** keeps the prototype available for later.
