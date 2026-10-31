# 0.2.71.3 verification

## Automated and native evidence

- Full validation: 44,376 Kahlua assertions, 266 Lua files; 464 source and 640 package files verified.
- Five frozen 0.2.71.2 controls fail their expected behavior: busy firearm recipient, late ray receipt, outer wall edge, zero-rate pause and battery defaults. Corrected production code passes. The old clock receives only a former-behavior API adapter.
- Stacked ray checks cover 1, 2, 5, 6 and 16 children, late/dead recipients and duplicate prevention. Warning checks cover 0, 4, 8, 20 and 30 tiles.
- Native write/read passes in64.5/57.5 seconds, including actual zero-rate queued Tether movement, grass/fern versus blocking bushes, four-direction construction, actual head profiles and persistence.
- Traps-only, Turrets-only and combined dedicated starts pass in58.5/53.3/56.5 seconds.
- Horde Night baseline:610 settings, persistence, defense-authority and scoring assertions pass.
- Evidence: diagnostics/c534 validation.log, final-negative.log, final-native-write.log, final-native-read.log, packages.log, horde-baseline.log; [durable result and hashes](evidence/c534-verification.json).

## Limits

All dedicated probes had zero connected clients. They establish native API, simulation and persistence behavior, not rendered multiplayer smoothness. General zombie sliding during MPFF pause is not proven fixed. The exact obstacle in the vegetation screenshot remains unidentified. Real-time battery estimates depend on the captured normal/enhanced module costs and90-minute days; stock M16 differs from the captured modded profile.

Local tagged installation/staging is being completed; no upload or live-server change.

## Owner retest

Upload both staged versions, then restart server and clients. Existing saved battery values require the seven targeted changes in [the contract](UPDATE_C534.md#battery-reference-and-saved-tuning); no new world or blanket settings reset.

- Stacked Splitter, empty turret
- Warning sound distance
- Paused traps, sounds and zombie movement
- Poke grass placement and stabilizer boundaries
- Battery endurance
