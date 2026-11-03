# 0.2.71.12 connected Rotary and Martyrdom test

The owner approved packaging C555 on its own. [Prototype and comparison](RECEIPT_DISPATCH_C555.md) · [Release scope](PATCH_v0.2.71.12.md)

To repeat the release-source replay, run `python tools/check_receipt_dispatch_c555.py --release --repeat 1`. It uses the working release source without a prototype overlay, exercises duplicate receipts, FIFO order and Horde/XP finishing blows, and compares the recorded Rotary and Martyrdom timings. It also runs the eight-rotary fixture and the 100-zombie mixed base at 100 and 310 ms round trip.

## Release verification

The release-source replay passed 809 focused assertions. The two matched damage displays took 336 and 281 ms with the original network timings held fixed. All 3,424 expected hits applied in the eight-rotary fixture. At 100 ms round trip all 2,621 mixed-base requests applied, including 84/84 rotary hits. At 310 ms round trip 2,395 of 2,415 applied. Twenty contacts expired, including 17 rotary contacts (Bat 35/43 and Blades 34/43). All 100 server and owner health records matched in each run. These are simulator results.

The general release validator passed 51,974 assertions and checked 466 source files and 642 packaged files. The native dedicated server saved and reloaded in a fresh process. Traps alone, Turrets alone and both entries together loaded version 0.2.71.12 and shut down cleanly with zero connected players.

## Two-player retest

Upload with T&T CMD option 3, then restart the server and both clients on 0.2.71.12. Use the existing test world and keep Turrets Detailed Logging enabled on the server and observing client for comparison with C554.

- Rotary Blades and Bat with Martyrdom in a crowd.
- Compare damage numbers and finishing blows on both clients.

Report the approximate test time if either player sees a delay. Connected multiplayer acceptance is pending.
