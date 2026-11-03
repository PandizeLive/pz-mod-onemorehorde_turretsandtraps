# C555 rotary receipt timing prototype

The owner selected C554 option 1A. This prototype replays the two detailed Martyrdom-to-rotary sequences against the packaged 0.2.71.11 source and a two-file server overlay. Both use the game's Kahlua runtime and network table codec. The simulated owner applies health and raises the damage display. No players were connected during these runs.

## Matched timing

| Hit | Sample age at admission | Time waiting for Martyrdom | Extra wait on .11 | Released display | Prototype display |
| --- | ---: | ---: | ---: | ---: | ---: |
| 67 | 107 ms | 157 ms | 37 ms | 373 ms | 336 ms |
| 62 | 96 ms | 121 ms | 64 ms | 345 ms | 281 ms |

The fixture supplies the measured sample age, arrival of the prior receipt, next queue tick and send-to-display leg. It records when the actual queue emits the rotary packet and when the owner displays the loss. The two builds received the same timing inputs. Earlier dispatch removed 37 and 64 ms in these cases. The prior transaction still has to settle. The cause of the earlier 319 ms observation remains unknown. [Connected observations](ROTARY_LATENCY_C554.md)

## Queue behavior

After a successful nonlethal receipt completes, including hit callbacks and damage events, the damage worker may visit the first waiting victim immediately. It does so only when that victim matches the acknowledgement. Other victims retain their place. A paused game, exhausted budget or different first victim leaves the work for the normal queue. Both entry points share the existing allowance of 32 starts and two milliseconds per tick. A single expensive dispatch can still exceed the time slice and cause the worker to yield.

Contact expiry, per-hit authorization, health application, paired receipts and native kill credit use the same code as the released build. The change is shared by all damage sources. It adds no per-head setting, saved state or network message.

## Reproduction

From the project directory with the 0.2.71.11 source, run `python tools/check_receipt_dispatch_c555.py`. The runner verifies the baseline and builds the overlay in diagnostics. The normal game suite runs before each fixture. The focused checks exercise duplicate and forged responses, queue expiry, reordered acknowledgements, a slow dispatch, a 40-victim burst, reentrant callbacks, paired settlement, pause, ownership transfer, death and Horde/XP attribution. [Candidate patch](../tools/prototypes/c555-ack-dispatch.patch) · [Runner](../tools/check_receipt_dispatch_c555.py)

## Crowded base

The mixed replay uses 100 moving zombies, 14 turrets, ten of each of nine trap or Tack configurations, two linked pressure plates and two simulated owners. Each row pools three runs per build. At 100 and 300 ms round trip, receipts arrive on a device tick. At 110 and 310 ms, packets can arrive between the 50 ms ticks. The runner alternates build order. Real elapsed time drives the worker budgets, so the number of attacks submitted can differ between runs. The final column shows the median of three server-step p95 measurements, including server receipt handling between ticks.

| Round trip | Rotary applied/submitted, .11 | Rotary, prototype | Whole base, .11 | Whole base, prototype | Server step p95, .11 / prototype |
| --- | ---: | ---: | ---: | ---: | ---: |
| 100 ms | 252/252 | 252/252 | 8,015/8,018 | 7,956/7,957 | 25.2 / 26.0 ms |
| 110 ms | 252/252 | 252/252 | 7,779/7,780 | 7,611/7,612 | 23.4 / 23.8 ms |
| 300 ms | 263/264 | 262/264 | 7,620/7,630 | 7,586/7,594 | 26.1 / 27.1 ms |
| 310 ms | 150/258 | 211/258 | 7,196/7,319 | 7,274/7,326 | 25.6 / 24.8 ms |

At 310 ms, the two rotary heads together landed 50 of 86 contacts on .11 in each repeat. The prototype landed 70, 70 and 71. Of the 258 contacts submitted, 47 still failed to apply. At 300 ms with receipts aligned to the tick, the prototype lost one additional rotary contact across the three repeats. The server timing varied in both directions. These runs support earlier service for eligible hits. They do not establish a general frame-rate improvement.

All 100 owner and server health records reconciled in each completed run. The separate eight-rotary fixture matched 3,424 of 3,424 expected crossings. Both builds passed all 809 focused assertions, including the Horde and XP finisher checks.

**Coverage gaps.** One initial candidate run stopped at the Ballista zero-hit assertion. It recorded no shot or submission count. A diagnostic run then exposed an empty-percentile error in the harness. The corrected harness retains these gaps in its results and reports incomplete coverage at the end. In the 24 completed scenes, a stock Ballista fired twice with zero damage submissions, and a candidate Scrapshot fired four times with zero submissions. The original Ballista case has no equivalent breakdown. In the additional 300 ms control with a fixed worker clock, both builds applied 3,321 of the same 3,363 requests, including all five Ballista hits and all 54 Scrapshot hits. These checks isolate damage delivery from variable shot and contact opportunities. The cause of the projectile misses remains open. [Per-run evidence](evidence/c555-receipt-dispatch.json)

**Decision needed.** **1A, recommended.** Package the prototype for a connected Rotary and Martyrdom retest. **1B** keeps 0.2.71.11 in testing. The current installation and Workshop stage still use 0.2.71.11.

## C556 further latency review

Of 38 rotary hits in the detailed connected capture, 33 had a reconstructed admission-to-send wait of zero and two waited 1 ms. The other three waited 70, 185 and 194 ms. The median delay from movement sample to damage display was 170 ms. The median sample age at hit admission was 103.5 ms and the median estimated send-to-display time was 65 ms. Neither interval isolates network transit from scheduling. The client already flushes pending observations on tick. Its 100 ms refresh rule for small movements runs before the timestamp of the next sample. Subtracting 100 ms from these measurements would count the wrong interval.

To assess whether the existing pair message could help earlier, we compared each applied Martyrdom send with the next rotary admission for the same victim while the first receipt was outstanding. Of 14 Martyrdom completions, two had a following rotary admission within 40 ms, at 3 and 38 ms. A 5 ms window included only the first. If Martyrdom had been held until its companion arrived and both hits could have left immediately, the same observed transport legs give hypothetical rotary displays of 179 and 160 ms respectively. This arithmetic does not replay pairing or establish a live result. A bounded hold can also delay a lone explosion, and tick granularity may extend it. Twelve of the fourteen Martyrdom hits had no matching rotary within that window.

**1A, recommended.** Package C555 on its own and measure the connected result first. **1B.** Before packaging, prototype briefly holding Martyrdom for a same-victim hit using the existing pair message. Measure both the rotary improvement and the delay added to lone Martyrdom hits, expiry, Horde attribution and crowded-base load. Either option preserves server authorization. Further work on typical hit latency should first separate client observation buffering from network transit. No additional gameplay change was approved in C556.
