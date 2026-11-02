# Rotary crowd stress test on 0.2.71.9

The owner selected 1B while the connected retest was deferred. Three independent JVM runs of the released build gave the same per-turret and per-target-interval hit comparisons. The eight-turret geometric replay counted every crossing. Under sustained load the multiplayer damage queue stopped converting detected hits into health loss. All outcomes below refer to the 12 measured seconds after warmup.

| Turrets | Expected crossings | Contact-only matches | Confirmed health deductions | Contact packet p95 (ms) | MP server work p95 (ms) |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 416 | 416 | 416 | 3.05 | 3.99 |
| 2 | 832 | 832 | 832 | 4.86 | 6.26 |
| 4 | 1,711 | 1,711 | 1,711 | 8.06 | 9.97 |
| 6 | 2,543 | 2,543 | 35 | 12.69 | 14.03 |
| 8 | 3,424 | 3,424 | 0 | 16.45 | 18.18 |

The one-turret contact packet took 3.05 ms at p95 in this layout. The earlier C546 figure was 2.454 ms with its single turret centered in the crowd. The matched 1/2/4/6/8 rows above use the same actor paths and report cadence. The board uses separate adjacent turret tiles, each aimed differently. Zombies have artificial health reserves and stay standing to keep the load constant. Physics crowd separation, pathfinding, rendering and actual network IO are outside this replay.

## Where damage was lost

At six turrets, 35 of 2,543 expected hits deducted health. At eight, 138 hits applied during warmup, then zero of 3,424 expected hits applied in the measured window. The receipt path recorded 5,452 attempts including repeat attempts after rejection. Of these, 3,516 were rejected at intake and 1,936 were cancelled. No combat command was sent to the owner in the eight-turret measured window. The geometric control, which accepts damage immediately, showed zero missing and zero extra contacts on every turret. The stalled run's time includes rejected work and should not be read as the cost of successfully processing all those hits.

The released queue inspects up to 16 entries per server tick, serializes hits on each victim and expires late work. Inspection can be spent on a victim whose earlier job still has to finish. Rotary also restores its previous pass/frame after a failed damage callback, allowing repeated attempts under overload. As a diagnostic control, the harness gave the existing damage queue four passes per tick with the same targets, clock, packet timing, capacity limits and expiry rules. This restored all 3,424 health deductions in each run. Median p95 of the measured server work was 19.30 ms. This isolates queue service as a material cause in this scenario. It does not establish a safe turret limit for live servers or attribute the owner's previous single-turret report to overload.

## Method and replay

Each count uses the same 32 targets moving inside a two-tile radius shared by the heads. Each head uses Enhanced Detection, Enhanced Firing and 360. The real spatial dispatch, motor, swept-contact calculation and line-check functions run against simulated loaded squares. The independent reference counts half-turns against the changing target bearing, checking each turret, victim and 100 ms interval individually. The fixture verifies each motor advances 20 degrees per interval. There are 25 warmup packets and 120 measured packets per case. Observations are 65 ms old on receipt. The damage comparison runs the real queue, server and client combat handlers with native packet serialization on a simulated connection with 50 ms each way. It drains all callbacks and checks the server and client health for every actor. Server timing excludes the simulated client, oracle and fixture setup. Turret inventory, power, authority publishing, cosmetic effects and crowd reactions use adapters. Timing figures are medians of run-specific 95th percentiles.

Pass the project root and [rotary_crowd_c547.lua](../tools/tests/rotary_crowd_c547.lua) to the existing KahluaCheck runner after compiling it with the 0.2.71.9 validation workflow. Run in a fresh JVM three times. The probe runs last and installs test adapters for the process lifetime. [Per-turret counts, rejection reasons and all timing repetitions](evidence/c547-rotary-crowd.json).

## Next decision

**1A (recommended).** Repair multiplayer damage scheduling. Prioritize ready victims, preserve ordered single application per victim, and keep expired work and retries from crowding out fresh hits. Verify against these per-turret and health totals, test mixed traps and turrets, and remeasure processing time before packaging.

**1B.** Keep the current candidate for the planned connected test and defer the queue repair. The live retest still matters for what the player sees and how often a real base reaches this load.
