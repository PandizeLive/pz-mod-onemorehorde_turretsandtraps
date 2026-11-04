# Mixed-base multiplayer stress test on 0.2.71.10

At 100 ms simulated round trip, 8,984 of 8,987 damage requests applied. At 300 ms, 8,435 of 8,686 applied. Increasing latency reproduced missed contacts on both rotary heads, Concertina Wire and Bed Spikes. Final health matched on the server and owning client for all 100 zombies in every run. These counts start when a device requests damage. They exclude intentional misses, travel before contact, and any physical crossing that never generated a request.

## What ran together

- 100 moving, high-health zombies in ten lanes. Two simulated player identities each owned 50 zombies.
- 14 powered turrets. Potato, Arc, Ballista, Scrapshot, Rotary Bat, Rotary Blades, three Lobbers (Makeshift, Aerosol, Pipe), M16, M4, pistol, shotgun and hunting rifle. The M16 had six Splitters. All heads had detection, firing, their enhanced variants and 360. Each head dealt damage in every run.
- Ten each of Poke Floor, basic and reinforced Bed Spikes, Concertina Wire, Barbed Panel, basic and reinforced Spike Barrier and Tether Dart. Ten active Tack fields brought the damaging trap and field count to 90. Each individual source registered positive damage. Two pressure plates were linked to separate Tethers. Both repeatedly changed state with traffic.
- Three independent JVM runs per latency and implementation, with alternating implementation order. Each scene ran for 20 simulated seconds at 50 ms ticks and delivered 20,000 timestamped actor observations in batches of up to 32. Shots, barrier strike markers, owner health applications and acknowledgements used the production combat paths. Separate counters recorded shots, requests, applied hits and distinct sources. Positive loss was checked against health on both sides after draining submitted damage. In-flight projectile and ordnance jobs at the end of the firing window are recorded separately.
- Stock game Kahlua and native table serialization, with simulated world objects, constant power/ammo availability, favorable hit rolls, simplified firearm item data, scripted paths and landing/thump markers. The two player identities share one harness process. Combat scheduler workers retain their wall-time budgets. The fixture bypasses physical construction, stockpile/reloads, active standby, trap wear-out, motion/knockback and several cosmetic broadcasts. Selected observer packets were serialized to two recipients. Rendering, actual network jitter/loss, engine pathfinding, other mods, observer playback and lethal attribution were outside this timing run.

## Findings

| Shipped build, three runs combined | 100 ms round trip | 300 ms round trip |
| --- | ---: | ---: |
| Damage applied / requested | 8,984 / 8,987 | 8,435 / 8,686 |
| Concertina Wire | 1,140 / 1,140 | 1,018 / 1,140 |
| Rotary Bat | 126 / 126 | 106 / 132 |
| Rotary Blades | 126 / 126 | 115 / 132 |
| Both Bed Spikes tiers | 2,790 / 2,790 | 2,723 / 2,790 |
| Poke Floor | 420 / 420 | 419 / 420 |
| Tether Dart | 302 / 302 | 302 / 302 |
| M16 with six Splitters | 213 / 213 | 199 / 199 |

The M16's owning-client health change worsened from 100–150 ms at the 95th percentile to 600–850 ms, measured from the server's damage request. An observed trap contact also spends time getting to the server. At 300 ms round trip, 134 requests expired, 114 were cancelled and three were rejected. At 100 ms, the three rejections came from Aerosol Lobber requests. Their payloads were not individually traced. The bounded global queue never needed to hold every zombie at once. Even the highest observed number of outstanding damage requests was 99. Each victim can still have only one active receipt, and contact damage has a 500 ms deadline. Those two constraints interact when several defenses hit the same zombie.

The measured combat and report work took about 12 ms at the 95th percentile at either latency. Report handling, including test serialization, accounted for the largest measured section at roughly 7 ms p95. Stock worst ticks were 49–62 ms. The maxima include harness/JVM costs. The largest delays in health application can span many ticks even when an individual tick is fast.

## Optimization experiments

**Barrier lookup.** The shipped command resolves the reported attacker by searching up to 25 squares, each of which can read a spatial bucket. An isolated source overlay tried the existing actor ID index first and kept the original nearby search as a fallback. The normal authority, outfit, floor, distance, face and strike checks stayed in place. The same layout produced 7,278 square-list reads per 100 ms run and 7,239 per 300 ms run. The index resolved every attacker in these runs and removed all those reads. Median barrier p95 fell from 3.50 to 0.35 ms at 100 ms RTT and from 3.42 to 0.35 ms at 300 ms RTT. Whole-scene p95 changed from 12.04 to 11.02 ms and from 12.01 to 13.03 ms respectively. The lookup saves barrier work. It did not consistently improve the whole scene or cure high-latency contact expiry. A shipping change needs focused checks for a cold or recycled ID, an incorrect floor or owner, and a forged strike.

**Shared receipts for queued hits.** A separate capture recorded 2,799 actual requests with their victim, arrival and deadline at 300 ms RTT. The current code applied 2,730 in this run. An idealized per-victim FIFO with one hit per receipt predicted 59 late hits. Allowing two already-waiting hits to share a receipt reduced predicted deadline losses to one and reduced p95 owner delay from 450 to 350 ms. Four predicted zero deadline losses on this trace. The model dispatches immediately when idle, preserves arrival order and omits engine budgets, death, ownership changes, consent, packet loss and retries. Its single-hit baseline differs from the runtime by ten outcomes. The grouped counts establish a reason to prototype. They are not multiplayer verification.

**Decision needed.** Recommend **1A**. Validate the indexed barrier lookup and prototype at most two already-waiting hits per victim per receipt. Keep individual deadlines, source IDs, per-hit results and server authority. Compare current and candidate runs on this scene, then exercise expiry, lethal hits, Horde credit, replay and owner changes. **1B** would deliver only the barrier optimization and leave the high-ping misses open. This audit changed test tooling and records. The playable build remains 0.2.71.10.

[Per-run timings and counts](evidence/c549-mixed-base.json) · [Mixed scene](../tools/tests/mixed_base_c549.lua) · [Runner and receipt model](../tools/check_mixed_base_c549.py). Run `python tools/check_mixed_base_c549.py` and `python tools/check_mixed_base_c549.py --trace-only` from the project directory.
