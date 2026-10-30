# 0.2.70.8 verification and owner test

Status: automated/native package checks passed; connected owner acceptance pending.

40,287 Kahlua assertions, current-version native save/read and Traps-only, Turrets-only and combined package starts pass. All 456 source files match the C509 proof after normalizing only the version field; 629 generated package files validate. Native probes have zero connected clients.

Package checks passed; local tagged installation and managed staging are next. Connected acceptance remains pending.

[Verification evidence](evidence/c510-verification.json). [Catalog coverage and limits](MULTIPLAYER_COVERAGE_C509.md).

## Owner checklist

Upload using CMD option 3, then update/restart the server and both clients to 0.2.70.8. No new world required. Enable existing Detailed Logging for Turrets and Traps for this focused test.

- Bed Spikes landing damage
- Poke Floor crossings and corpse dragging
- Concertina, Barbed Panels, Tacks and Martyrdom
- Spike Barriers and Tether Darts
- Turret range, aim, hits and kills
- Arc chains, triggers and stacked modules
- Other-player effects and Module Pack icons
- Horde Night credit and Trait Shop XP

The previous GitHub automatic approval-review rejection still blocks mirroring to the remote destination; the local tagged checkpoint will be retained. Workshop publication and live-server updates are separate owner actions.
