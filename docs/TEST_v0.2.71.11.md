# 0.2.71.11 two-player test build

The six promoted Lua files match the verified [C550 prototype](PAIRED_RECEIPTS_C550.md) byte for byte. The release runner reads the current Source tree directly and clears the prototype override. Run `python tools/check_paired_receipts_c550.py --release` to reproduce the focused, rotary and mixed-base checks.

The 200 focused assertions passed, including independent expiry, replay, lost acknowledgements, owner handoff, native death, XP and Horde finishing-blow credit. The earlier eight-rotary regression applied all 3,424 expected hits. At six rotaries plus Concertina, all 2,543 rotary hits and 188 wire hits applied.

| Release-source replay | Applied / requested | Rotary Blades | Rotary Bat | Concertina | M16 with six Splitters |
| --- | ---: | ---: | ---: | ---: | ---: |
| 100 ms round trip | 2,932 / 2,933 | 42 / 42 | 42 / 42 | 380 / 380 | 72 / 72 |
| 300 ms round trip | 2,846 / 2,857 | 44 / 44 | 41 / 44 | 380 / 380 | 48 / 48 |

Each mixed-base replay used 100 moving zombies, 14 turrets, 90 traps and Tack fields, and two linked pressure plates. Every source applied damage. The server and owning client agreed on each zombie's final health. At 300 ms, five queued requests were cancelled, five expired and one was rejected. Neither replay needed the nearby-square search for a Spike Barrier strike. The [prototype comparison](PAIRED_RECEIPTS_C550.md) records repeated latency measurements against 0.2.71.10.

The release validator passed 51,974 assertions and verified 466 source files and 642 generated package files. Native dedicated save and fresh-process reload passed. Traps alone, Turrets alone and both entries together started with the exact version and shut down cleanly with zero connected players.

## Two-player check

Use the existing T&T test world. After the unlisted Workshop upload, restart the server and both clients with 0.2.71.11. Both clients need the paired-hit protocol.

- Confirm both players see 0.2.71.11.
- Compare Rotary Blades and Bat hits in a crowd.
- Watch Concertina and Spike Barrier damage from both clients.
- Check M16 Splitter impacts and finishing blows.

Report when complete with the approximate test time and which player saw any delay. Connected multiplayer acceptance is pending.
