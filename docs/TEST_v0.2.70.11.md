# 0.2.70.11 verification and owner test

Status: automated and native checks passed; local delivery in progress; connected acceptance pending.

40,498 assertions pass. Eight frozen pre-fix paths fail at their named regression checks. Native write/read, Traps-only, Turrets-only, combined startup and dedicated combat/service probes pass with zero connected clients. [Evidence](evidence/c517-checks.json). The native ownership fixture was corrected to expose its real grid squares before reporting; its initial failed run is retained. The expiry fixture explicitly retains the stale occupant, preventing a vacuous pass.

The C517 response suite covers fresh occupancy, first laser contact, delayed passive-trap metadata, independent trigger reports, continuous dart draw coordinates, moving-target attachment/retraction, actual client aim, flight transit, rotary bounds and active-flight fairness. Frozen old modules must fail their corresponding assertions before corrected code is accepted. Existing whole-catalog damage, control, module, performance and permission suites remain included. [Audit matrix and limits](MULTIPLAYER_RESPONSE_C517.md).

## Owner checklist

After upload, update/restart the server and both clients to 0.2.70.11. No new world required. Keep Diagnostic Logging and Detailed Logging enabled for the two packages during this test.

- First crossings: wire, panels, Poke Floor, Bed Spikes
- Spike Barrier front, sides and safe rear
- Tether flight, attachment, pull and cooldown
- Turret aim and projectiles on both clients
- Pressure plates, lasers and linked devices
- Tacks, Martyrdom and corpse exclusion

Retain actual failures separately from automated passes. Native tests with zero connected clients cannot establish smooth multiplayer rendering.
